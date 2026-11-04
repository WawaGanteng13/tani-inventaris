# Tani Inventaris — Business Model & Monetisasi (v2.0, Nov 2026)

> Aplikasi inventarisasi tanaman via smartphone: moto + ngomong → AI menulis database → export SQL/XLSX/DOCX/PDF.
> v2.0 = v1.0 + riset monetisasi Play Store (Nov 2026). Angka kebijakan (fee, API level)
> wajib diverifikasi ulang saat rilis karena Google bisa mengubahnya.

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

## 3. Tier: Semai / Tumbuh / Kebun

|  | Semai (Free) | Tumbuh (Pro) | Kebun (Tim) |
|---|---|---|---|
| Harga | Rp 0 | **Rp 29 rb/bln** atau **Rp 290 rb/thn** (2 bln gratis) | **Rp 79 rb/bln** atau **Rp 790 rb/thn** |
| Item | 100 | 2.000 | Tanpa batas |
| AI | On-device saja | Hybrid cloud (saat confidence rendah) | Hybrid + prioritas antrean |
| Ekspor | XLSX/PDF watermark | Penuh: XLSX/PDF/DOCX/SQL, tanpa watermark | + multi-user 3 kursi |
| Iklan | Banner ringan | Tanpa iklan | Tanpa iklan |
| Backup | — | File backup manual | Backup otomatis + riwayat |

Rasional harga: di antara majoo lite (Rp 50 rb/bln) dan Moka (Rp 249 rb+/bln),
sejajar langganan hiburan (rasa "murah"). Trial 14 hari + masa tenggang 7 hari.

Revenue stream lain (di luar subscription):

1. **Label QR sekali bayar** — template label rak/pot + QR menuju kartu tanaman
   (Rp 49–99 rb/paket desain; cetak fisik via partner = margin afiliasi).
2. **Ekspor PDF white-label** — kop/logo nursery sendiri di nota & katalog
   (Rp 99 rb sekali bayar atau termasuk Kebun).
3. **Paket ekspor massal / nota custom** — Rp 50–150 rb sekali bayar.
4. **Jasa onboarding** — datang/setup + migrasi buku manual ke aplikasi,
   Rp 250–500 rb/kunjungan (Jabodetabek dulu; via gateway eksternal).
5. **B2B/API nanti** — sinkronisasi POS, lisensi per gerai.

## 4. Opsi Monetisasi Play Store (riset Nov 2026)

| Opsi | Cara kerja | Fee Google | Cocok? |
|---|---|---|---|
| Freemium + subscription | Gratis terbatas → langganan via Play Billing | 15% flat recurring | **Ya — model inti** |
| In-app purchase sekali bayar | Template, paket ekspor, desain label | 15% untuk $1 jt pertama/thn, 30% di atasnya | Ya — add-on |
| Paid app | Bayar sekali saat install | 15%/30% (aturan $1 jt sama) | Tidak — hambat adopsi |
| Iklan (AdMob/mediasi) | Banner di tier gratis | Bagi hasil ±68% ke developer | Opsional, tier gratis saja |

Catatan fee: ada info penurunan fee subscription recurring ke 10% (2026) yang
rollout bertahap per region; Indonesia ("rest of world") per riset ini masih
15%/30% sampai rollout regional. Program User Choice Billing tersedia di
Indonesia (pembayaran alternatif dengan service fee didiskon ±5%) — relevan
setelah ada traksi, bukan untuk tahap awal. Praktisnya: subscription digital
100% via Play Billing agar lolos review.

## 5. Pembayaran Lokal Indonesia

Bisa dipakai langsung di Play Billing (region Indonesia): GoPay, OVO, DANA,
ShopeePay, DOKU, QRIS, carrier billing (Telkomsel/Indosat/XL/Tri/Smartfren),
kartu, saldo Play.

Batasan: tunai, virtual account / transfer bank tidak bisa untuk subscription
via Play Billing. Mayoritas user nursery tercakup e-wallet + QRIS.

Gateway eksternal (Midtrans/Xendit/DOKU) hanya untuk revenue NON-digital
(label cetak, jasa onboarding): QRIS, VA semua bank, gerai retail.

## 6. Benchmark Harga Sejenis

Global (tahunan): PictureThis Pro ±$40, Planta Premium $36–48, Greg ±$30 —
ini langit-langit, bukan acuan. Indonesia: Moka POS Rp 249–299 rb/bln, majoo
lite Rp 50 rb/bln, Kasir Pintar/Qasir/Pawoon freemium, BukuWarung gratis.
Daya beli segmen operasional terbukti Rp 25–75 rb/bln — tier Tumbuh Rp 29 rb
duduk pas di rentang ini.

## 7. Struktur Biaya (per user aktif/bln, estimasi)

| Komponen | Estimasi |
|---|---|
| Inferensi vision + STT cloud (hybrid, hanya saat confidence rendah) | Rp 3–8rb |
| Penyimpanan (foto terkompresi lokal + backup opsional) | < Rp 1rb |
| Distribusi (Play Console $25 sekali; Firebase/opsional) | ~Rp 0 |
| Support + iterasi | waktu founder |

Margin kotor target per user berbayar: >70% setelah fee Play 15%.
On-device first = biaya AI hanya untuk kasus sulit.

## 8. Checklist Rilis Play Store

- [ ] Akun Play Console: **$25 sekali bayar**, verifikasi identitas +
      Android Developer Verification.
- [ ] Format **AAB**, target API terbaru yang diwajibkan Google untuk app baru
      (per riset Nov 2026: API 36; cek ulang saat rilis).
- [ ] **Privacy policy**: URL publik, tautan di Console + di dalam aplikasi;
      konsisten dengan perilaku nyata (kamera/mic/foto/voice).
- [ ] **Data safety form**: deklarasikan semua data app + SDK.
- [ ] **Closed testing** (akun personal baru): 12 tester × 14 hari sebelum produksi.
- [ ] App content: content rating, target audience, deklarasi iklan, justifikasi
      izin kamera/mic.
- [ ] **Play Billing Library** versi terbaru yang disyaratkan; katalog produk
      (SKU bulanan/tahunan + add-on) di Console.

## 9. Go-to-Market

1. Dogfood di SnS Nursery (bukti + testimoni + konten).
2. Komunitas nursery/kolektor (IG/WA groups): "katalog 500 tanaman dalam sehari".
3. Freemium → konversi saat item >100 atau butuh nota tanpa watermark.
4. Bundel dengan Hai Tani (opsional, tetap produk terpisah): nursery yang siap jual grosir → temukan buyer.

## 10. Moat & Risiko

- **Moat:** dataset foto+voice tanaman Indonesia (dialek, nama lokal), UX sekali-jalan, harga IDR.
- **Risiko:** akurasi klasifikasi spesies mirip → kartu konfirmasi + confidence threshold; API key di aplikasi → backend kecil saat skala; Play review izin kamera/mic → justifikasi jelas.

## 11. Metrik Kunci

Aktivasi (item pertama <5 menit install), item/user/minggu, konversi free→berbayar (>5%), retensi 30 hari (>40%), akurasi klasifikasi top-1 (>85% cloud, >70% on-device).
