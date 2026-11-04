import 'dart:io';

import 'package:flutter/material.dart';

import '../db/database.dart';
import '../models/item.dart';
import 'input_screen.dart';

/// Daftar inventaris: rows (bukan card-soup), search, hitung 0/1/N.
class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final _q = TextEditingController();
  late Future<List<InvItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = InvDb.all();
  }

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  void _reload() => setState(() => _future = InvDb.all(query: _q.text));

  String _rp(int n) => 'Rp ${n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  String _count(int n) =>
      n == 0 ? 'Belum ada item' : n == 1 ? '1 item' : '$n item';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tani Inventaris'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SearchBar(
              controller: _q,
              hintText: 'Cari nama / jenis…',
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
                    Text('Gagal memuat: ${snap.error}'),
                    TextButton(
                        onPressed: _reload, child: const Text('Coba lagi')),
                  ],
                ),
              ),
            );
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
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
                          ? 'Tidak ada hasil untuk "${_q.text.trim()}"'
                          : 'Belum ada tanaman tercatat.',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      searching
                          ? 'Coba kata kunci lain atau hapus filter.'
                          : 'Ketuk + untuk mencatat tanaman pertama.',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: Text(_count(items.length),
                    style: Theme.of(context).textTheme.bodySmall),
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
                            title: const Text('Hapus item?'),
                            content: Text(
                                '"${it.nama}" akan dihapus permanen.'),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.of(d).pop(false),
                                  child: const Text('Batal')),
                              FilledButton(
                                  onPressed: () =>
                                      Navigator.of(d).pop(true),
                                  child: const Text('Hapus')),
                            ],
                          ),
                        );
                        return ok == true;
                      },
                      onDismissed: (_) async {
                        if (it.id != null) await InvDb.remove(it.id!);
                        _reload();
                      },
                      child: ListTile(
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
                        subtitle: Text(
                            '${it.jenis.isEmpty ? '-' : it.jenis} · ${it.ukuran.isEmpty ? '-' : it.ukuran}'
                            '${it.voicePath != null ? ' · voice' : ''}'),
                        trailing: Text(
                          _rp(it.hargaRp),
                          style: const TextStyle(
                              fontFeatures: [FontFeature.tabularFigures()],
                              fontWeight: FontWeight.w600),
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
        onPressed: () async {
          final saved = await Navigator.of(context).push<bool>(MaterialPageRoute(
              builder: (_) => const InputScreen()));
          if (saved == true) _reload();
        },
        icon: const Icon(Icons.add),
        label: const Text('Catat'),
      ),
    );
  }
}
