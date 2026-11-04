import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:tani_inventaris/l10n/app_localizations.dart';

import '../db/database.dart';
import '../models/item.dart';

/// Layar input sekali-jalan: kamera inline (tak pernah pindah layar),
/// jepret beruntun + voice-note + harga, satu tombol simpan.
class InputScreen extends StatefulWidget {
  const InputScreen({super.key, this.existing});

  /// Item yang diubah; null = mode catat baru.
  final InvItem? existing;

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  CameraController? _cam;
  String? _camError;
  bool _videoMode = false;
  bool _recordingVideo = false;
  final List<String> _photos = [];
  String? _videoPath;

  final _rec = AudioRecorder();
  bool _recordingVoice = false;
  int _voiceSecs = 0;
  Timer? _voiceTimer;
  String? _voicePath;

  final _nama = TextEditingController();
  final _jenis = TextEditingController();
  final _ukuran = TextEditingController();
  final _harga = TextEditingController();
  final _stok = TextEditingController();
  final _sku = TextEditingController();
  final _lokasi = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final ex = widget.existing;
    if (ex != null) {
      _nama.text = ex.nama;
      _jenis.text = ex.jenis;
      _ukuran.text = ex.ukuran;
      _harga.text = _fmtRp(ex.hargaRp.toString());
      _stok.text = ex.stok.toString();
      _sku.text = ex.sku;
      _lokasi.text = ex.lokasi;
      _photos.addAll(ex.photoPaths);
      _voicePath = ex.voicePath;
    }
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cams = await availableCameras();
      if (cams.isEmpty) {
        setState(() => _camError = 'noCamera');
        return;
      }
      final ctrl = CameraController(
          cams.firstWhere((c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => cams.first),
          ResolutionPreset.veryHigh,
          enableAudio: false);
      await ctrl.initialize();
      if (!mounted) return;
      setState(() {
        _cam = ctrl;
        _camError = null;
      });
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() => _camError = e.code == 'CameraAccessDenied'
          ? 'denied'
          : 'failed:${e.description ?? e.code}');
    }
  }

  @override
  void dispose() {
    _cam?.dispose();
    _rec.dispose();
    _voiceTimer?.cancel();
    _nama.dispose();
    _jenis.dispose();
    _ukuran.dispose();
    _harga.dispose();
    _stok.dispose();
    _sku.dispose();
    _lokasi.dispose();
    super.dispose();
  }

  Future<Directory> _mediaDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final d = Directory(p.join(docs.path, 'media'));
    if (!await d.exists()) await d.create(recursive: true);
    return d;
  }

  Future<void> _capture() async {
    final cam = _cam;
    if (cam == null || !cam.value.isInitialized) return;
    try {
      if (_videoMode) {
        if (_recordingVideo) {
          final f = await cam.stopVideoRecording();
          final dest = p.join((await _mediaDir()).path,
              'vid_${DateTime.now().millisecondsSinceEpoch}.mp4');
          await File(f.path).copy(dest);
          setState(() {
            _recordingVideo = false;
            _videoPath = dest;
          });
        } else {
          await cam.startVideoRecording();
          setState(() => _recordingVideo = true);
        }
      } else {
        final shot = await cam.takePicture();
        final dest = p.join((await _mediaDir()).path,
            'img_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await File(shot.path).copy(dest);
        setState(() => _photos.add(dest));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                AppLocalizations.of(context)!.captureFailed('$e'))));
      }
    }
  }

  Future<void> _toggleVoice() async {
    if (_recordingVoice) {
      final path = await _rec.stop();
      _voiceTimer?.cancel();
      setState(() {
        _recordingVoice = false;
        if (path != null) _voicePath = path;
      });
    } else {
      if (!await _rec.hasPermission()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.micDenied)));
        }
        return;
      }
      final dest = p.join((await _mediaDir()).path,
          'voice_${DateTime.now().millisecondsSinceEpoch}.m4a');
      await _rec.start(const RecordConfig(encoder: AudioEncoder.aacLc),
          path: dest);
      _voiceTimer?.cancel();
      setState(() {
        _recordingVoice = true;
        _voiceSecs = 0;
        _voicePath = null;
      });
      _voiceTimer = Timer.periodic(
          const Duration(seconds: 1), (_) => setState(() => _voiceSecs++));
    }
  }

  String _camErrorText(AppLocalizations t) {
    final e = _camError;
    if (e == null) return '';
    if (e == 'noCamera') return t.noCamera;
    if (e == 'denied') return t.camDenied;
    if (e.startsWith('failed:')) return t.camFailed(e.substring(7));
    return e;
  }

  void _bumpStok(int delta) {
    final cur = int.tryParse(_stok.text) ?? 0;
    setState(() => _stok.text = (cur + delta).clamp(0, 999999).toString());
  }

  String _fmtRp(String digits) {
    final n = int.tryParse(digits.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return n.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  Future<void> _save() async {
    if (_saving) return;
    if (_nama.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.nameRequired)));
      return;
    }
    setState(() => _saving = true);
    try {
      final media = [..._photos];
      if (_videoPath != null) media.add(_videoPath!);
      final ex = widget.existing;
      final item = InvItem(
        id: ex?.id,
        nama: _nama.text.trim(),
        jenis: _jenis.text.trim(),
        ukuran: _ukuran.text.trim(),
        hargaRp:
            int.tryParse(_harga.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
        photoPaths: media,
        voicePath: _voicePath,
        stok: int.tryParse(_stok.text) ?? 0,
        sku: _sku.text.trim(),
        lokasi: _lokasi.text.trim(),
        source: ex?.source ?? 'manual',
        createdAt: ex?.createdAt ?? DateTime.now(),
      );
      if (ex?.id != null) {
        await InvDb.update(item);
      } else {
        await InvDb.insert(item);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(AppLocalizations.of(context)!.saveFailed('$e'))));
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final cam = _cam;
    final t = AppLocalizations.of(context)!;
    return PopScope(
      canPop: !_saving,
      child: Scaffold(
      appBar: AppBar(
          title: Text(widget.existing == null
              ? t.inputTitleNew
              : t.inputTitleEdit)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          AspectRatio(
            aspectRatio: 3 / 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: _camError != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.no_photography_outlined),
                              const SizedBox(height: 8),
                              Text(_camErrorText(t),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall),
                              TextButton(
                                  onPressed: _initCamera,
                                  child: Text(t.retry)),
                            ],
                          ),
                        ),
                      )
                    : cam == null || !cam.value.isInitialized
                        ? const Center(child: CircularProgressIndicator())
                        : FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: 720,
                              height: 960,
                              child: CameraPreview(cam),
                            ),
                          ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                      value: false,
                      label: Text(t.modePhoto),
                      icon: Icon(Icons.photo_camera_outlined)),
                  ButtonSegment(
                      value: true,
                      label: Text(t.modeVideo),
                      icon: Icon(Icons.videocam_outlined)),
                ],
                selected: {_videoMode},
                onSelectionChanged: (s) =>
                    setState(() => _videoMode = s.first),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed:
                    cam == null || !cam.value.isInitialized ? null : _capture,
                icon: Icon(_videoMode && _recordingVideo
                    ? Icons.stop
                    : Icons.fiber_manual_record),
                label: Text(_videoMode
                    ? (_recordingVideo ? t.videoStop : t.videoRecord)
                    : t.snapCount(_photos.length)),
              ),
            ],
          ),
          if (_photos.isNotEmpty || _videoPath != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 64,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final ph in _photos)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(File(ph),
                            width: 64, height: 64, fit: BoxFit.cover),
                      ),
                    ),
                  if (_videoPath != null)
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.videocam),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: IconButton.filled(
              onPressed: _toggleVoice,
              icon: Icon(_recordingVoice ? Icons.stop : Icons.mic),
              style: _recordingVoice
                  ? IconButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.errorContainer)
                  : null,
            ),
            title: Text(_recordingVoice
                ? t.voiceRecording(_voiceSecs)
                : _voicePath != null
                    ? (_voiceSecs > 0
                        ? t.voiceSavedSecs(_voiceSecs)
                        : t.voiceSavedReady)
                    : t.voicePrompt),
            subtitle: _recordingVoice
                ? Text(t.voiceStopHint)
                : null,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nama,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
                labelText: t.fieldName, hintText: t.fieldNameHint),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _jenis,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                      labelText: t.fieldType, hintText: t.fieldTypeHint),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _ukuran,
                  decoration: InputDecoration(
                      labelText: t.fieldSize, hintText: t.fieldSizeHint),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _harga,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) {
              final f = _fmtRp(_harga.text);
              _harga.value = TextEditingValue(
                  text: f,
                  selection:
                      TextSelection.collapsed(offset: f.length));
            },
            decoration: InputDecoration(
              labelText: t.fieldPrice,
              prefixText: 'Rp ',
              hintText: t.fieldPriceHint,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _stok,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                      labelText: t.fieldStock, hintText: t.fieldStockHint),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove),
                tooltip: t.stockDown,
                onPressed: () => _bumpStok(-1),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: t.stockUp,
                onPressed: () => _bumpStok(1),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _sku,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                      labelText: t.fieldSku, hintText: t.fieldSkuHint),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _lokasi,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                      labelText: t.fieldLocation,
                      hintText: t.fieldLocationHint),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(_saving
                  ? t.saving
                  : (widget.existing == null ? t.saveNew : t.saveEdit)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.phaseNote,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      ),
    );
  }
}
