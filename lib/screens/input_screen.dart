import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

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
      _photos.addAll(ex.photoPaths);
      _voicePath = ex.voicePath;
    }
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cams = await availableCameras();
      if (cams.isEmpty) {
        setState(() => _camError = 'Tidak ada kamera di perangkat ini.');
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
          ? 'Izin kamera ditolak. Buka Pengaturan > Aplikasi > Tani Inventaris > Izin, lalu coba lagi.'
          : 'Kamera gagal dibuka: ${e.description ?? e.code}');
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
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mengambil gambar: $e')));
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Izin mikrofon ditolak. Aktifkan di Pengaturan.')));
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

  String _fmtRp(String digits) {
    final n = int.tryParse(digits.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return n.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  Future<void> _save() async {
    if (_saving) return;
    if (_nama.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Isi nama tanaman dulu.')));
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final cam = _cam;
    return PopScope(
      canPop: !_saving,
      child: Scaffold(
      appBar: AppBar(
          title: Text(
              widget.existing == null ? 'Catat Tanaman' : 'Ubah Tanaman')),
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
                              Text(_camError!,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall),
                              TextButton(
                                  onPressed: _initCamera,
                                  child: const Text('Coba lagi')),
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
                segments: const [
                  ButtonSegment(
                      value: false,
                      label: Text('Foto'),
                      icon: Icon(Icons.photo_camera_outlined)),
                  ButtonSegment(
                      value: true,
                      label: Text('Video'),
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
                    ? (_recordingVideo ? 'Stop' : 'Rekam')
                    : 'Jepret (${_photos.length})'),
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
                ? 'Merekam… $_voiceSecs dtk (sebut nama, ukuran, harga)'
                : _voicePath != null
                    ? 'Voice-note tersimpan (${_voiceSecs > 0 ? '$_voiceSecs dtk' : 'siap'})'
                    : 'Rekam voice-note (nama, ukuran, harga)'),
            subtitle: _recordingVoice
                ? const Text('Ketuk stop bila selesai')
                : null,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nama,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
                labelText: 'Nama tanaman', hintText: 'mis. Agave victoria'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _jenis,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                      labelText: 'Jenis', hintText: 'mis. Hias'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _ukuran,
                  decoration: const InputDecoration(
                      labelText: 'Ukuran', hintText: 'mis. Pot 20 cm'),
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
            decoration: const InputDecoration(
              labelText: 'Harga (Rp)',
              prefixText: 'Rp ',
              hintText: 'mis. 50.000',
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(_saving
                  ? 'Menyimpan…'
                  : (widget.existing == null
                      ? 'Simpan ke Inventaris'
                      : 'Simpan Perubahan')),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Fase 1: AI mati. Nama, jenis, ukuran, dan harga diisi manual. Fase 2: AI mengisi otomatis dari foto + voice.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      ),
    );
  }
}
