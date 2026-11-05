import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tani_inventaris/l10n/app_localizations.dart';

import '../db/database.dart';
import '../models/item.dart';
import '../models/mutation.dart';

/// Riwayat mutasi satu item + catat masuk/keluar cepat.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.item});

  final InvItem item;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<_HistoryData> _future;

  @override
  void initState() {
    super.initState();
    InvDb.revision.addListener(_onRev);
    _future = _load();
  }

  @override
  void dispose() {
    InvDb.revision.removeListener(_onRev);
    super.dispose();
  }

  Future<_HistoryData> _load() async {
    final id = widget.item.id!;
    // Paralel: satu jendela async cukup untuk keduanya (plus lebih cepat).
    final results = await Future.wait([
      InvDb.byId(id),
      InvDb.mutationsFor(id),
    ]);
    final item = results[0] as InvItem?;
    final muts = results[1] as List<StockMutation>;
    return _HistoryData(stok: item?.stok ?? widget.item.stok, muts: muts);
  }

  void _reload() {
    // Blok-body (bukan arrow): jangan kembalikan Future dari setState.
    final future = _load();
    setState(() {
      _future = future;
    });
  }

  void _onRev() {
    if (!mounted) return;
    _reload();
  }

  String _kindLabel(AppLocalizations t, String kind) => switch (kind) {
        'seed' => t.mutSeed,
        'in' => t.mutIn,
        'out' => t.mutOut,
        'adjust' => t.mutAdjust,
        _ => kind,
      };

  String _fmt(DateTime d) =>
      '${d.day}/${d.month} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  Future<void> _recordSheet() async {
    final t = AppLocalizations.of(context)!;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (c) => _RecordSheet(itemId: widget.item.id!),
    );
    // Tanpa _reload manual: adjustStock memicu revision → _onRev me-reload.
    // (Reload ganda di sini membuat future kedua nyangkut spinner di tes.)
    if (ok == true && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.mutRecorded)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(t.historyTitle)),
      body: FutureBuilder<_HistoryData>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(t.loadError('${snap.error}')),
                  TextButton(onPressed: _reload, child: Text(t.retry)),
                ],
              ),
            );
          }
          final data = snap.data!;
          if (data.muts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.item.nama,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(t.stockLine(data.stok),
                        style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 16),
                    Text(t.historyEmpty,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(widget.item.nama,
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(t.stockLine(data.stok),
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: data.muts.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final m = data.muts[i];
                    final up = m.delta >= 0;
                    return ListTile(
                      leading: Icon(
                        up ? Icons.arrow_downward : Icons.arrow_upward,
                        color: up ? cs.primary : cs.error,
                      ),
                      title: Text(
                          '${up ? '+' : ''}${m.delta} · ${_kindLabel(t, m.kind)}'),
                      subtitle: Text(
                          '${m.stokBefore} → ${m.stokAfter} · ${_fmt(m.createdAt)}'
                          '${m.note.isEmpty ? '' : '\n${m.note}'}'),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _recordSheet,
        icon: const Icon(Icons.add),
        label: Text(t.mutRecordTitle),
      ),
    );
  }
}

class _HistoryData {
  final int stok;
  final List<StockMutation> muts;
  const _HistoryData({required this.stok, required this.muts});
}

/// Form catat mutasi: tipe masuk/keluar + jumlah + catatan.
class _RecordSheet extends StatefulWidget {
  const _RecordSheet({required this.itemId});

  final int itemId;

  @override
  State<_RecordSheet> createState() => _RecordSheetState();
}

class _RecordSheetState extends State<_RecordSheet> {
  bool _isIn = true;
  final _qty = TextEditingController(text: '1');
  final _note = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _qty.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final qty = int.tryParse(_qty.text) ?? 0;
    if (qty <= 0) return;
    setState(() => _saving = true);
    await InvDb.adjustStock(widget.itemId, _isIn ? qty : -qty,
        note: _note.text.trim());
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            16, 12, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(t.mutRecordTitle,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                    value: true,
                    label: Text(t.mutTypeIn),
                    icon: const Icon(Icons.arrow_downward)),
                ButtonSegment(
                    value: false,
                    label: Text(t.mutTypeOut),
                    icon: const Icon(Icons.arrow_upward)),
              ],
              selected: {_isIn},
              onSelectionChanged: (s) => setState(() => _isIn = s.first),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _qty,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(labelText: t.mutQty),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _note,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                  labelText: t.mutNote, hintText: t.mutNote),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(_saving ? t.saving : t.mutSave),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
