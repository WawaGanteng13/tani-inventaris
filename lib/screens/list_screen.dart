import 'dart:io';

import 'package:flutter/material.dart';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tani_inventaris/l10n/app_localizations.dart';

import '../db/database.dart';
import '../export/export.dart';
import '../i18n/locale.dart';
import '../models/item.dart';
import 'history_screen.dart';
import 'input_screen.dart';
import 'qr_label.dart';
import 'scan_screen.dart';

/// Daftar inventaris: rows (bukan card-soup), search, hitung 0/1/N.
class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> with WidgetsBindingObserver {
  final _q = TextEditingController();
  late Future<List<InvItem>> _future;
  bool _lowOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    InvDb.revision.addListener(_onRev);
    _future = InvDb.all();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _reload();
  }

  @override
  void dispose() {
    InvDb.revision.removeListener(_onRev);
    WidgetsBinding.instance.removeObserver(this);
    _q.dispose();
    super.dispose();
  }

  void _reload() {
    // Jangan kembalikan Future dari closure setState (arrow `=>` dengan
    // assignment Future melempar di debug dan rebuild tidak terjadwal).
    final future = InvDb.all(query: _q.text);
    setState(() {
      _future = future;
    });
  }

  void _onRev() {
    if (!mounted) return;
    _reload();
  }

  bool _navBusy = false;

  Future<void> _openInput([InvItem? existing]) async {
    if (_navBusy) return;
    _navBusy = true;
    try {
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => InputScreen(existing: existing)));
    } finally {
      _navBusy = false;
    }
    if (!mounted) return;
    _reload();
  }

  Future<void> _openScan() async {
    if (_navBusy) return;
    _navBusy = true;
    InvItem? found;
    try {
      found = await Navigator.of(context).push<InvItem>(
          MaterialPageRoute(builder: (_) => const ScanScreen()));
    } finally {
      _navBusy = false;
    }
    if (!mounted || found == null) return;
    _openInput(found);
  }

  Future<void> _openHistory(InvItem item) async {
    if (_navBusy) return;
    _navBusy = true;
    try {
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => HistoryScreen(item: item)));
    } finally {
      _navBusy = false;
    }
  }

  Future<void> _openQrLabel(InvItem item) async {
    await showModalBottomSheet(
      context: context,
      builder: (_) => QrLabelSheet(item: item),
    );
  }

  Future<void> _exportMenu() async {
    final t = AppLocalizations.of(context)!;
    final fmt = await showModalBottomSheet<String>(
      context: context,
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final f in ['xlsx', 'pdf', 'docx'])
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(f.toUpperCase()),
                subtitle: Text(t.exportAs(f)),
                onTap: () => Navigator.of(c).pop(f),
              ),
          ],
        ),
      ),
    );
    if (fmt == null || !mounted) return;
    try {
      final items = await InvDb.all();
      if (!mounted) return;
      if (items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.exportEmpty)));
        return;
      }
      final lang = Localizations.localeOf(context).languageCode;
      final bytes = fmt == 'pdf'
          ? await buildPdf(items, lang: lang)
          : fmt == 'docx'
              ? buildDocx(items, lang: lang)
              : buildXlsx(items, lang: lang);
      final dir = await getTemporaryDirectory();
      if (!mounted) return;
      final path = p.join(dir.path, exportFileName(fmt));
      await File(path).writeAsBytes(bytes);
      await SharePlus.instance.share(ShareParams(files: [XFile(path)]));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.exportedAs(p.basename(path)))));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.exportFailed('$e'))));
    }
  }

  String _rp(int n) => 'Rp ${n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  String _count(AppLocalizations t, int n) =>
      n == 0 ? t.countZero : n == 1 ? t.countOne : t.countMany(n);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: t.scanTitle,
            onPressed: _openScan,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: t.reloadTip,
            onPressed: _reload,
          ),
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: t.exportTip,
            onPressed: _exportMenu,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            tooltip: t.language,
            onSelected: (v) =>
                setLocale(v == 'system' ? null : Locale(v)),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'system', child: Text(t.langSystem)),
              PopupMenuItem(value: 'id', child: Text(t.langIndonesian)),
              PopupMenuItem(value: 'en', child: Text(t.langEnglish)),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SearchBar(
              controller: _q,
              hintText: t.searchHint,
              leading: const Icon(Icons.search),
              trailing: _q.text.isEmpty
                  ? null
                  : [
                      IconButton(
                          onPressed: () {
                            _q.clear();
                            _reload();
                          },
                          icon: const Icon(Icons.clear))
                    ],
              onChanged: (_) => _reload(),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<InvItem>>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 40),
                    const SizedBox(height: 8),
                    Text(t.loadError('${snap.error}')),
                    TextButton(
                        onPressed: _reload, child: Text(t.retry)),
                  ],
                ),
              ),
            );
          }
          final allItems = snap.data ?? [];
          if (allItems.isEmpty) {
            final searching = _q.text.trim().isNotEmpty;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                        searching
                            ? Icons.search_off_outlined
                            : Icons.spa_outlined,
                        size: 48),
                    const SizedBox(height: 8),
                    Text(
                      searching
                          ? t.noResultsFor(_q.text.trim())
                          : t.emptyTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      searching
                          ? t.emptyFilteredHint
                          : t.emptyFirstHint,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          final lowCount =
              allItems.where((e) => e.isLowStock).length;
          final items = _lowOnly
              ? allItems.where((e) => e.isLowStock).toList()
              : allItems;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: Row(
                  children: [
                    Text(_count(t, items.length),
                        style: Theme.of(context).textTheme.bodySmall),
                    if (lowCount > 0) ...[
                      const SizedBox(width: 8),
                      FilterChip(
                        label: Text(t.lowStockChip(lowCount)),
                        selected: _lowOnly,
                        onSelected: (v) => setState(() => _lowOnly = v),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final it = items[i];
                    final thumb = it.photoPaths.isNotEmpty
                        ? it.photoPaths.first
                        : null;
                    return Dismissible(
                      key: ValueKey(it.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Theme.of(context).colorScheme.errorContainer,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.delete_outline),
                      ),
                      confirmDismiss: (_) async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (d) => AlertDialog(
                            title: Text(t.deleteTitle),
                            content: Text(t.deleteBody(it.nama)),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.of(d).pop(false),
                                  child: Text(t.cancel)),
                              FilledButton(
                                  onPressed: () =>
                                      Navigator.of(d).pop(true),
                                  child: Text(t.deleteConfirm)),
                            ],
                          ),
                        );
                        return ok == true;
                      },
                      onDismissed: (_) async {
                        if (it.id != null) await InvDb.remove(it.id!);
                      },
                      child: ListTile(
                        onTap: () => _openInput(it),
                        leading: thumb != null && File(thumb).existsSync()
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(File(thumb),
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover),
                              )
                            : const Icon(Icons.spa_outlined),
                        title: Text(it.nama),
                        subtitle: Text.rich(
                          TextSpan(children: [
                            TextSpan(
                                text:
                                    '${it.jenis.isEmpty ? t.missingValue : it.jenis} · ${it.ukuran.isEmpty ? t.missingValue : it.ukuran}\n'
                                    '${t.stockLine(it.stok)}'),
                            if (it.isLowStock)
                              TextSpan(
                                text: ' · ${t.lowStockTag}',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .error,
                                    fontWeight: FontWeight.w600),
                              ),
                            TextSpan(
                                text:
                                    '${it.sku.isEmpty ? '' : ' · ${it.sku}'}'
                                    '${it.lokasi.isEmpty ? '' : ' · ${it.lokasi}'}'
                                    '${it.voicePath != null ? ' · ${t.voiceTag}' : ''}'),
                          ]),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _rp(it.hargaRp),
                              style: const TextStyle(
                                  fontFeatures: [
                                    FontFeature.tabularFigures()
                                  ],
                                  fontWeight: FontWeight.w600),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (v) => v == 'history'
                                  ? _openHistory(it)
                                  : _openQrLabel(it),
                              itemBuilder: (_) => [
                                PopupMenuItem(
                                  value: 'history',
                                  child: ListTile(
                                    leading:
                                        const Icon(Icons.history),
                                    title: Text(t.menuHistory),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'qr',
                                  child: ListTile(
                                    leading: const Icon(
                                        Icons.qr_code_2),
                                    title: Text(t.menuQr),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openInput(),
        icon: const Icon(Icons.add),
        label: Text(t.fabAdd),
      ),
    );
  }
}
