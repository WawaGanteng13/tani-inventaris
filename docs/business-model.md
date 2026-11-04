# Tani Inventaris — Business Model (v1.0, Nov 2026)

> Aplikasi inventarisasi tanaman via smartphone: moto + ngomong → AI menulis database → export SQL/XLSX/DOCX/PDF.

## 1. Proposisi Nilai

Nursery dan kolektor tanaman hias mencatat stok manual (buku/foto berserakan di galeri WA). Tani Inventaris memangkas pencatatan satu item dari ±5 menit mengetik menjadi ±30 detik bicara: foto/video + voice-note ("agave besar, pot 20 senti, lima puluh ribu") → AI gabungkan visi + suara → baris database rapi → satu ketuk export ke format pembukuan/nota/katalog.

Prinsip UX: **input sekali jalan** — kamera tak pernah dibuka-tutup antar-field.

## 2. Segmen Pelanggan

| Segmen | Ciri | Kemauan bayar |
|---|---|---|
| Nursery kecil-menengah (contoh: SnS Nursery) | 200–5.000 item, multi jenis/ukuran/harga, jualan via WA/medsos | Tinggi — butuh katalog + nota cepat |
| Kolektor / seller online | <500 item, butuh foto + harga rapi untuk posting | Sedang |
| Kios/toko tani, landscaper | Stok campur + jasa, butuh rekap + PDF penawaran | Sedang–tinggi |
| Penyuluh / dinas (B2G, nanti) | Pendataan kelompok tani | Proyek |

## 3. Revenue Streams

1. **Langganan freemium (inti):**
   - *Semai* (gratis): 100 item, export XLSX/PDF watermark, AI on-device saja.
   - *Tumbuh* (Rp 25rb/bln): 2.000 item, export penuh + DOCX/SQL, hybrid cloud AI, backup file.
   - *Kebun* (Rp 75rb/bln): item tanpa batas, multi-user 3 kursi, prioritas AI, tanpa watermark.
2. **Add-on sekali bayar:** paket export massal / template nota custom (Rp 50–150rb).
3. **B2B/API (nanti):** sinkronisasi ke sistem toko/POS, lisensi per gerai.

## 4. Struktur Biaya (per user aktif/bln, estimasi)

| Komponen | Estimasi |
|---|---|
| Inferensi vision + STT cloud (hybrid, hanya saat confidence rendah) | Rp 3–8rb |
| Penyimpanan (foto terkompresi lokal + backup opsional) | < Rp 1rb |
| Distribusi (Play Console $25 sekali; Firebase/opsional) | ~Rp 0 |
| Support + iterasi | waktu founder |

Margin kotor target per user berbayar: >70%. On-device first = biaya AI hanya untuk kasus sulit.

## 5. Go-to-Market

1. Dogfood di SnS Nursery (bukti + testimoni + konten).
2. Komunitas nursery/kolektor (IG/WA groups): "katalog 500 tanaman dalam sehari".
3. Freemium → konversi saat item >100 atau butuh nota tanpa watermark.
4. Bundel dengan Hai Tani (opsional, tetap produk terpisah): nursery yang siap jual grosir → temukan buyer.

## 6. Moat & Risiko

- **Moat:** dataset foto+voice tanaman Indonesia (dialek, nama lokal), UX sekali-jalan, harga IDR.
- **Risiko:** akurasi klasifikasi spesies mirip → mitigasi kartu konfirmasi user + confidence threshold; API key di aplikasi → pindah ke backend kecil saat skala; Play review untuk izin kamera/mic → justifikasi jelas di listing.

## 7. Metrik Kunci

Aktivasi (item pertama <5 menit install), item/user/minggu, konversi free→berbayar (>5%), retensi 30 hari (>40%), akurasi klasifikasi top-1 (>85% cloud, >70% on-device).
