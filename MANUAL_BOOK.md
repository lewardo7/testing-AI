# Manual Book CliniPath

Versi dokumen: 1.0  
Pembaruan terakhir: 9 Juli 2026

## 1. Pengantar

CliniPath adalah aplikasi web untuk mengelola Clinical Pathway rumah sakit. Aplikasi ini membantu proses pembuatan dokumen, review klinis, approval final, publikasi, arsip, komentar, riwayat versi, lampiran dokumen, dan pengelolaan user berdasarkan role.

Tujuan utama aplikasi:

- Menyimpan Clinical Pathway secara terpusat.
- Memperjelas status dokumen: draft, review, revisi, publish, atau arsip.
- Mempercepat alur review dan approval.
- Menyediakan riwayat versi dan audit aktivitas.
- Membantu administrator mengelola user dan role.

## 2. Teknologi Singkat

Aplikasi menggunakan:

- React, TypeScript, dan Vite untuk frontend.
- Supabase untuk autentikasi, database, storage, dan edge function.
- PostgreSQL sebagai database.
- Supabase Storage untuk attachment dokumen pendukung.
- Git/GitHub untuk version control.

Saat development lokal, Supabase dijalankan menggunakan Docker Desktop.

## 3. Role Pengguna

CliniPath memiliki lima role utama.

### 3.1 Administrator

Administrator adalah role dengan akses paling luas.

Hak akses:

- Melihat seluruh Clinical Pathway.
- Membuat dan mengelola user.
- Mengubah role user.
- Mengubah departemen user.
- Mengaktifkan atau menonaktifkan user.
- Mengakses halaman Users & Roles.
- Mengakses halaman Settings.
- Melihat audit history.
- Mengarsipkan pathway.
- Memulihkan pathway dari arsip.
- Melihat approval queue.
- Membantu proses approval bila diperlukan.

Administrator cocok untuk:

- Admin sistem.
- Tim mutu.
- Komite medis yang mengelola sistem.
- Super user rumah sakit.

### 3.2 Author / DPJP

Author adalah pengguna yang membuat dan menyusun Clinical Pathway.

Hak akses:

- Membuat Clinical Pathway baru.
- Menyimpan pathway sebagai draft.
- Mengedit pathway dengan status Draft.
- Mengedit pathway dengan status Revision.
- Mengirim pathway untuk review.
- Melihat Clinical Pathway miliknya.
- Melihat komentar dan riwayat versi.
- Menambahkan komentar klinis.
- Menambahkan attachment dokumen pendukung.

Author cocok untuk:

- DPJP.
- Dokter penyusun Clinical Pathway.
- Tim klinis pembuat dokumen.

### 3.3 Reviewer

Reviewer adalah pengguna yang meninjau isi Clinical Pathway sebelum diteruskan ke approval final.

Hak akses:

- Melihat pathway yang ditugaskan untuk review.
- Membaca detail pathway.
- Memberikan keputusan review:
  - Setujui.
  - Minta revisi.
  - Tolak.
- Menulis catatan keputusan.
- Menambahkan komentar klinis.

Reviewer cocok untuk:

- Komite medis.
- Tim mutu klinis.
- Dokter reviewer.
- Tim standar pelayanan.

### 3.4 Approver

Approver adalah pengguna yang memberikan persetujuan final sebelum pathway dipublikasikan.

Hak akses:

- Melihat pathway yang sudah melewati tahap reviewer.
- Melakukan approval final.
- Memberikan keputusan:
  - Setujui dan publikasikan.
  - Minta revisi.
  - Tolak.
- Menulis catatan keputusan.
- Menambahkan komentar klinis.

Approver cocok untuk:

- Ketua komite medis.
- Direktur pelayanan medis.
- Pejabat atau tim yang berwenang melakukan final approval.

### 3.5 Viewer

Viewer adalah pengguna dengan akses baca terbatas.

Hak akses:

- Melihat Clinical Pathway yang sudah aktif/published.
- Membuka detail pathway yang tersedia.
- Tidak dapat membuat, mengedit, mengirim review, atau melakukan approval.

Viewer cocok untuk:

- Staf klinis yang hanya membutuhkan akses baca.
- Unit pelayanan.
- Pengguna umum internal rumah sakit.

## 4. Status Clinical Pathway

Setiap Clinical Pathway memiliki status.

### 4.1 Draft

Status awal ketika pathway dibuat oleh Author.

Pada status ini:

- Author dapat mengedit isi pathway.
- Author dapat menyimpan perubahan.
- Author dapat mengirim pathway untuk review.

### 4.2 In Review / Review

Status ketika pathway sudah dikirim ke Reviewer.

Pada status ini:

- Reviewer dapat meninjau dokumen.
- Reviewer dapat menyetujui, meminta revisi, atau menolak.
- Author tidak mengedit langsung sampai ada keputusan revisi/penolakan.

### 4.3 Revision

Status ketika Reviewer atau Approver meminta revisi atau menolak pathway.

Pada status ini:

- Author dapat membuka kembali pathway.
- Author dapat memperbaiki dokumen.
- Author dapat mengirim ulang pathway untuk review.

### 4.4 Approved

Status setelah Reviewer menyetujui dan pathway diteruskan ke Approver.

Pada status ini:

- Approver melakukan pemeriksaan final.
- Approver dapat menyetujui dan mempublikasikan.
- Approver juga dapat meminta revisi atau menolak.

### 4.5 Published / Active

Status setelah pathway disetujui final.

Pada status ini:

- Pathway dianggap aktif.
- Viewer dapat melihat pathway.
- Admin dapat mengarsipkan pathway bila sudah tidak digunakan.

### 4.6 Archived

Status pathway yang sudah diarsipkan.

Pada status ini:

- Pathway tidak dianggap aktif.
- Admin dapat memulihkan pathway menjadi Published kembali.

## 5. Alur Kerja Utama

Alur utama Clinical Pathway:

```text
Author membuat Draft
-> Author kirim untuk Review
-> Reviewer melakukan review
-> Jika disetujui, lanjut ke Approver
-> Approver melakukan approval final
-> Jika disetujui, pathway menjadi Published
```

Jika ada revisi:

```text
Reviewer/Approver minta revisi atau menolak
-> Pathway menjadi Revision
-> Author memperbaiki dokumen
-> Author mengirim ulang untuk Review
```

Jika sudah tidak digunakan:

```text
Published
-> Admin arsipkan
-> Status menjadi Archived
```

## 6. Cara Login

1. Buka aplikasi CliniPath di browser.
2. Masukkan email.
3. Masukkan password.
4. Klik tombol `Masuk ke CliniPath`.

Jika login berhasil, pengguna akan masuk ke dashboard sesuai akses role.

## 7. Lupa Password

1. Pada halaman login, masukkan email.
2. Klik `Lupa password?`.
3. Jika email terdaftar, sistem akan mengirim link reset password.
4. Buka email dan ikuti instruksi reset password.

Catatan:

- Fitur ini menggunakan Supabase Auth.
- Pengiriman email tergantung konfigurasi email di Supabase.

## 8. Dashboard

Dashboard menampilkan ringkasan data Clinical Pathway.

Informasi yang tersedia:

- Total pathway.
- Pathway aktif.
- Pathway yang menunggu persetujuan.
- Pathway yang akan ditinjau.
- Grafik aktivitas pathway enam bulan terakhir.
- Distribusi status pathway.
- Daftar pathway yang baru diperbarui.

Tombol penting:

- `Buat Pathway`: menuju halaman pembuatan Clinical Pathway, hanya muncul untuk role yang boleh membuat pathway.
- `Lihat semua`: menuju Pathway Library.

## 9. Pathway Library

Pathway Library adalah halaman untuk melihat daftar Clinical Pathway.

Fitur:

- Search berdasarkan nama atau kode pathway.
- Filter status:
  - All.
  - Active.
  - Draft.
  - Review.
  - Archived.
- Filter departemen.
- Urutkan berdasarkan judul.
- Pagination 10 data per halaman.
- Buka detail pathway.

Cara membuka detail:

1. Masuk ke Pathway Library.
2. Cari pathway yang diinginkan.
3. Klik baris pathway.
4. Halaman detail pathway akan terbuka.

## 10. Detail Clinical Pathway

Halaman detail menampilkan informasi lengkap pathway.

Bagian utama:

- Status pathway.
- Kode pathway.
- Judul pathway.
- Departemen.
- Author/pemilik dokumen.
- Versi.
- Tujuan klinis.
- Kriteria inklusi.
- Alur perawatan.
- Informasi dokumen.
- Riwayat versi.
- Komentar klinis.
- Dokumen pendukung.
- Audit history untuk Administrator.

Tombol yang mungkin tersedia:

- `Edit Pathway`: untuk Author/Admin jika status Draft atau Revision.
- `Kirim untuk Review`: untuk Author/Admin jika pathway siap dikirim.
- `Unduh PDF`: untuk mencetak atau menyimpan pathway sebagai PDF.
- `Arsipkan`: untuk Administrator pada pathway Published.
- `Pulihkan`: untuk Administrator pada pathway Archived.

## 11. Membuat Clinical Pathway

Role yang dapat membuat pathway:

- Administrator.
- Author.

Langkah:

1. Klik menu `Authoring` atau tombol `Buat Pathway`.
2. Isi informasi dasar:
   - Nama Clinical Pathway.
   - Kode pathway.
   - Departemen.
   - Diagnosis.
   - Kode ICD-10.
   - Tujuan klinis.
   - Ringkasan klinis.
3. Isi alur pelayanan.
4. Tambahkan tahapan bila diperlukan.
5. Klik `Simpan Draft` jika belum siap review.
6. Klik `Kirim untuk Review` jika dokumen sudah siap ditinjau.

Catatan:

- Pathway yang disimpan akan masuk status Draft.
- Pathway yang dikirim akan masuk status Review.

## 12. Mengedit Draft atau Revision

Role yang dapat mengedit:

- Author pemilik pathway.
- Administrator.

Syarat:

- Status pathway harus Draft atau Revision.

Langkah:

1. Buka Pathway Library.
2. Klik pathway dengan status Draft atau Revision.
3. Klik `Edit Pathway`.
4. Perbarui data yang diperlukan.
5. Klik `Simpan Perubahan`.
6. Jika sudah siap, kirim kembali untuk review.

## 13. Approval Queue

Approval Queue digunakan oleh Reviewer dan Approver.

Role yang dapat mengakses:

- Administrator.
- Reviewer.
- Approver.

### 13.1 Reviewer

Reviewer meninjau dokumen pada tahap review klinis.

Langkah:

1. Buka menu `Approval Queue`.
2. Pilih pathway yang menunggu review.
3. Klik `Tinjau Dokumen`.
4. Baca tujuan klinis, kriteria, dan alur pelayanan.
5. Isi catatan bila perlu.
6. Pilih keputusan:
   - `Setujui Review`.
   - `Minta Revisi`.
   - `Tolak`.

Jika reviewer menyetujui:

- Pathway diteruskan ke Approver.

Jika reviewer meminta revisi atau menolak:

- Pathway kembali ke Author dengan status Revision.

### 13.2 Approver

Approver memberikan approval final.

Langkah:

1. Buka menu `Approval Queue`.
2. Pilih pathway pada tahap persetujuan final.
3. Klik `Tinjau Dokumen`.
4. Periksa dokumen.
5. Isi catatan bila perlu.
6. Pilih keputusan:
   - `Setujui & Publikasikan`.
   - `Minta Revisi`.
   - `Tolak`.

Jika approver menyetujui:

- Pathway menjadi Published/Active.

Jika approver meminta revisi atau menolak:

- Pathway kembali ke Author dengan status Revision.

## 14. Komentar Klinis

Komentar klinis tersedia di detail pathway.

Kegunaan:

- Memberikan catatan diskusi.
- Mencatat masukan klinis.
- Melengkapi proses review.

Langkah menambahkan komentar:

1. Buka detail pathway.
2. Scroll ke bagian `Komentar Klinis`.
3. Tulis komentar.
4. Klik `Kirim Komentar`.

## 15. Riwayat Versi

Riwayat versi menampilkan daftar versi pathway.

Informasi yang ditampilkan:

- Nomor versi.
- Versi aktif.
- Ringkasan perubahan.
- Tanggal dibuat.

Fitur ini membantu melihat perkembangan dokumen dari waktu ke waktu.

## 16. Attachment Dokumen Pendukung

Attachment digunakan untuk menyimpan dokumen pendukung pathway.

File yang didukung saat ini:

- PDF.
- PNG.
- JPG/JPEG.
- DOCX.

Langkah upload:

1. Buka detail pathway.
2. Scroll ke bagian `Dokumen Pendukung`.
3. Klik `Upload Lampiran`.
4. Pilih file.
5. Tunggu sampai upload selesai.

Langkah membuka file:

1. Buka bagian `Dokumen Pendukung`.
2. Klik `Buka` pada file yang diinginkan.

Langkah menghapus file:

1. Buka bagian `Dokumen Pendukung`.
2. Klik `Hapus`.
3. Konfirmasi penghapusan.

Hak hapus:

- Pemilik file.
- Administrator.

## 17. Export PDF

Fitur export PDF tersedia di detail pathway.

Langkah:

1. Buka detail pathway.
2. Klik `Unduh PDF`.
3. Browser akan membuka dialog print.
4. Pilih tujuan `Save as PDF`.
5. Klik `Save`.

Catatan:

- PDF dibuat menggunakan halaman cetak browser.
- Hasil PDF mengikuti data pathway yang sedang dibuka.

## 18. Archive dan Restore

Fitur ini hanya untuk Administrator.

### Archive

Digunakan untuk mengarsipkan pathway yang sudah Published.

Langkah:

1. Login sebagai Administrator.
2. Buka detail pathway dengan status Active/Published.
3. Klik `Arsipkan`.
4. Status berubah menjadi Archived.

### Restore

Digunakan untuk memulihkan pathway yang sudah Archived.

Langkah:

1. Login sebagai Administrator.
2. Buka detail pathway dengan status Archived.
3. Klik `Pulihkan`.
4. Status berubah kembali menjadi Published.

## 19. Audit History

Audit History hanya dapat dilihat oleh Administrator.

Audit mencatat aktivitas penting, seperti:

- Pathway dibuat.
- Pathway diperbarui.
- Pathway dikirim untuk review.
- Keputusan approval.
- Pathway diarsipkan.
- Pathway dipulihkan.

Audit membantu pelacakan aktivitas dan akuntabilitas sistem.

## 20. Users & Roles

Halaman ini hanya dapat diakses Administrator.

Fitur:

- Melihat daftar user.
- Membuat akun baru.
- Mengubah role user.
- Mengubah departemen user.
- Mengaktifkan atau menonaktifkan akses user.

### Membuat User Baru

Langkah:

1. Login sebagai Administrator.
2. Buka menu `Users & Roles`.
3. Klik `Buat Akun`.
4. Isi data:
   - Nama lengkap.
   - Email.
   - Password awal.
   - Nomor pegawai.
   - Role.
   - Departemen.
5. Klik `Simpan Akun`.

Catatan:

- Pembuatan user dilakukan melalui Supabase Edge Function `admin-users`.
- Untuk development lokal, pastikan edge function berjalan bila fitur buat user digunakan.

### Mengubah Role User

Langkah:

1. Buka `Users & Roles`.
2. Cari user.
3. Pilih role baru pada kolom Role.
4. Perubahan tersimpan otomatis.

### Mengubah Departemen User

Langkah:

1. Buka `Users & Roles`.
2. Cari user.
3. Pilih departemen baru.
4. Perubahan tersimpan otomatis.

### Mengaktifkan atau Menonaktifkan User

Langkah:

1. Buka `Users & Roles`.
2. Cari user.
3. Klik tombol status `Aktif` atau `Nonaktif`.

## 21. Settings

Halaman Settings hanya dapat diakses Administrator.

Bagian Settings:

- Identitas rumah sakit.
- Kebijakan pathway.
- Kebijakan lampiran.

### Identitas Rumah Sakit

Data yang dapat diatur:

- Nama rumah sakit.
- Lokasi.
- Kode singkat.

Data identitas rumah sakit kini dikelola sebagai master data rumah sakit/cabang. Administrator dapat menambahkan lebih dari satu rumah sakit dengan lokasi berbeda.

Fitur master rumah sakit:

- Tambah rumah sakit baru.
- Edit nama, kode, lokasi, alamat, dan telepon.
- Aktifkan atau nonaktifkan rumah sakit.
- Pilih rumah sakit aktif dari kartu rumah sakit di sidebar.

Jika ada lebih dari satu rumah sakit aktif, sidebar menampilkan pilihan rumah sakit. Saat pengguna memilih rumah sakit lain, nama, lokasi, dan kode singkat pada sidebar akan berubah mengikuti pilihan tersebut.

### Kebijakan Pathway

Data yang dapat diatur:

- Interval review berkala.
- Tahap review awal.
- Wajib atau tidaknya catatan revisi/penolakan.

### Kebijakan Lampiran

Data yang dapat diatur:

- Maksimal ukuran file.
- Tipe file yang diizinkan.

Catatan:

- Pengaturan ini tersimpan di tabel `app_settings`.
- Migration Settings perlu dijalankan sebelum fitur ini digunakan di database lokal.

## 22. Notifikasi

Notifikasi muncul pada ikon lonceng di header.

Contoh notifikasi:

- Pathway perlu direview.
- Pathway ditolak.
- Pathway perlu revisi.
- Pathway dipublikasikan.

Langkah membuka notifikasi:

1. Klik ikon lonceng.
2. Pilih notifikasi yang ingin dibaca.
3. Notifikasi akan ditandai sudah dibaca.

## 23. Testing Aplikasi

Testing otomatis ringan tersedia melalui smoke test.

Perintah:

```powershell
npm run test
```

Perintah ini akan:

- Memeriksa keberadaan fitur utama di source code.
- Menjalankan build produksi.

Jika berhasil, output akan menampilkan bahwa smoke test dan build lolos.

## 24. Testing Manual yang Disarankan

Sebelum commit atau demo, lakukan testing manual berikut:

1. Login sebagai Administrator.
2. Buat user baru di Users & Roles.
3. Login sebagai Author.
4. Buat pathway baru.
5. Simpan draft.
6. Edit draft.
7. Kirim untuk review.
8. Login sebagai Reviewer.
9. Setujui, minta revisi, atau tolak pathway.
10. Jika revisi, login kembali sebagai Author dan perbaiki pathway.
11. Kirim ulang untuk review.
12. Login sebagai Approver.
13. Setujui dan publikasikan pathway.
14. Buka detail pathway.
15. Tambahkan komentar klinis.
16. Upload attachment.
17. Coba buka attachment.
18. Klik `Unduh PDF`.
19. Login sebagai Administrator.
20. Coba archive dan restore pathway.
21. Buka Settings dan simpan perubahan.
22. Cek pagination di Library.
23. Coba fitur lupa password dari halaman login.

## 25. Catatan Development Lokal

Untuk menjalankan aplikasi lokal:

```powershell
npm run dev
```

Untuk menjalankan Supabase lokal:

```powershell
npx supabase start
```

Untuk menerapkan migration baru:

```powershell
npx supabase migration up
```

Untuk menjalankan edge function admin user:

```powershell
npx supabase functions serve admin-users
```

## 26. Batasan Saat Ini

Aplikasi sudah mencapai MVP fungsional, tetapi masih ada batasan:

- Smoke test belum menggantikan test browser end-to-end.
- Export PDF masih menggunakan dialog print browser, belum generator PDF khusus server.
- Integrasi BPJS, INA-CBG, HIS, Financial Intelligence, Claim Explorer, dan Report lanjutan belum dibuat.
- Mobile app native belum dibuat.

## 27. Ringkasan Role dan Akses

| Fitur | Administrator | Author | Reviewer | Approver | Viewer |
|---|---:|---:|---:|---:|---:|
| Login | Ya | Ya | Ya | Ya | Ya |
| Dashboard | Ya | Ya | Ya | Ya | Ya |
| Lihat Library | Ya | Ya | Ya | Ya | Ya |
| Lihat pathway published | Ya | Ya | Ya | Ya | Ya |
| Buat pathway | Ya | Ya | Tidak | Tidak | Tidak |
| Edit draft/revision | Ya | Ya, miliknya | Tidak | Tidak | Tidak |
| Kirim untuk review | Ya | Ya | Tidak | Tidak | Tidak |
| Review pathway | Ya | Tidak | Ya | Tidak | Tidak |
| Approval final | Ya | Tidak | Tidak | Ya | Tidak |
| Minta revisi/tolak | Ya | Tidak | Ya | Ya | Tidak |
| Komentar klinis | Ya | Ya | Ya | Ya | Terbatas baca |
| Attachment | Ya | Ya | Ya | Ya | Terbatas baca |
| Archive/restore | Ya | Tidak | Tidak | Tidak | Tidak |
| Audit history | Ya | Tidak | Tidak | Tidak | Tidak |
| Users & Roles | Ya | Tidak | Tidak | Tidak | Tidak |
| Settings | Ya | Tidak | Tidak | Tidak | Tidak |

## 28. Penutup

Manual book ini menjelaskan penggunaan CliniPath berdasarkan fitur yang sudah tersedia saat ini. Dokumen ini dapat diperbarui kembali ketika fitur lanjutan seperti report, claim explorer, financial intelligence, integrasi BPJS/HIS, atau test end-to-end ditambahkan.
