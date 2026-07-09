# Progress Pengembangan CliniPath

Pembaruan terakhir: 9 Juli 2026

## Ringkasan Pekerjaan yang Sudah Dilakukan

- Menyiapkan aplikasi React, TypeScript, dan Vite.
- Membuat antarmuka CliniPath yang responsif untuk desktop dan perangkat bergerak.
- Membuat halaman login dan menghubungkannya ke Supabase Authentication.
- Membuat dashboard yang berisi statistik, grafik aktivitas, distribusi status, dan daftar pathway terbaru.
- Membuat Pathway Library dengan pencarian, filter status, tabel data, dan halaman detail pathway.
- Membuat formulir authoring untuk menyusun clinical pathway, menambah tahapan pelayanan, menyimpan draft, dan mengirim pathway untuk ditinjau.
- Membuat Approval Queue dan menghubungkannya ke data approval Supabase.
- Menyelesaikan workflow approval berbasis role: author mengirim ke reviewer, reviewer meneruskan ke approver, dan approver mempublikasikan pathway.
- Menambahkan keputusan setujui, tolak, dan minta revisi beserta catatan dan notifikasi kepada pengguna terkait.
- Memperbaiki pengiriman ulang pathway setelah revisi agar penugasan reviewer lama dapat diaktifkan kembali tanpa konflik data.
- Membatasi menu Authoring, Approval Queue, Users & Roles, dan Settings berdasarkan role pengguna.
- Menghubungkan statistik dashboard dan detail pathway ke data Supabase.
- Mengaktifkan tombol Buat Pathway dari Library, filter departemen, pengurutan judul, serta panel notifikasi belum dibaca.
- Menambahkan halaman Users & Roles untuk administrator: daftar akun, pembuatan akun, perubahan role/departemen, dan aktivasi/nonaktivasi akses.
- Menambahkan Edge Function `admin-users` agar pembuatan akun menggunakan service role secara aman di sisi server.
- Mengaktifkan editor pathway untuk Author pada status Draft dan Revision.
- Menambahkan riwayat versi dan komentar klinis pada detail pathway.
- Menambahkan archive/restore khusus Administrator beserta audit history pathway.
- Menambahkan attachment dokumen pendukung pada detail pathway, termasuk upload, buka/unduh, dan hapus lampiran.
- Mengembangkan halaman Settings untuk identitas rumah sakit, kebijakan review pathway, dan kebijakan attachment.
- Menambahkan ekspor PDF dari detail pathway menggunakan dialog cetak browser.
- Mengganti grafik dashboard agar menggunakan agregasi data created/published enam bulan terakhir dari database.
- Merapikan teks aplikasi yang mengalami masalah encoding pada source aktif.
- Menyiapkan fungsi akses data untuk pathway, departemen, profil, approval, dan notifikasi.
- Menyiapkan skema database Supabase, Row Level Security, fungsi database, migrasi, konfigurasi lokal, dan seed data.
- Menambahkan dokumentasi kebutuhan produk dan petunjuk backend.
- Memverifikasi aplikasi dengan build produksi. Build berhasil tanpa error pada 9 Juli 2026.

## File yang Sudah Dibuat atau Diubah

### Frontend

- `src/main.tsx` — entry point aplikasi React.
- `src/App.tsx` — halaman login, layout utama, dashboard, library, detail pathway, authoring, approval, users, dan settings.
- `src/styles.css` — seluruh styling dan aturan tampilan responsif aplikasi.
- `src/lib/supabase.ts` — konfigurasi klien Supabase.
- `src/lib/api.ts` — fungsi autentikasi dan akses data Supabase.
- `src/ExistingPathwayEditor.tsx` — editor draft dan revisi pathway.
- `src/PathwayHistoryComments.tsx` — riwayat versi dan diskusi klinis.
- `src/vite-env.d.ts` — deklarasi tipe lingkungan Vite.
- `index.html` — dokumen HTML utama.
- `package.json` dan `package-lock.json` — dependensi dan perintah pengembangan aplikasi.
- `tsconfig.json` — konfigurasi TypeScript.

### Backend dan Dokumentasi

- `supabase/config.toml` — konfigurasi Supabase lokal.
- `supabase/seed.sql` — data awal untuk pengembangan.
- `supabase/migrations/202607070001_initial_schema.sql` — skema awal database, tabel, relasi, dan kebijakan akses.
- `supabase/migrations/202607070002_api_grants.sql` — hak akses API database.
- `supabase/migrations/202607070003_service_role_profile_admin.sql` — dukungan administrasi profil melalui service role.
- `supabase/migrations/202607070004_create_pathway_draft.sql` — fungsi pembuatan draft pathway beserta versinya.
- `supabase/migrations/202607080001_complete_approval_workflow.sql` — penugasan reviewer/approver otomatis, validasi role, keputusan approval, audit log, dan notifikasi.
- `supabase/migrations/202607080002_profile_email.sql` — email profil untuk pengelolaan pengguna.
- `supabase/migrations/202607080003_update_pathway_draft.sql` — penyimpanan perubahan draft dan revisi pathway.
- `supabase/migrations/202607080004_archive_restore_pathway.sql` — archive/restore pathway dengan validasi role dan audit log.
- `supabase/migrations/202607090001_attachment_management.sql` — kebijakan hapus lampiran untuk pemilik file dan administrator.
- `supabase/migrations/202607090002_app_settings.sql` — tabel konfigurasi aplikasi dan data awal Settings.
- `BACKEND.md` — petunjuk menjalankan dan melakukan deployment backend.
- `prd.md` — kebutuhan produk dan roadmap awal.
- `.gitignore` — daftar file yang tidak disimpan ke Git.

## Masalah yang Belum Selesai

- Pagination pada Pathway Library belum diperlukan sampai jumlah data melebihi satu halaman dan belum diimplementasikan.
- Alur lupa password belum dibuat.
- Dokumen `prd.md` masih memiliki beberapa karakter encoding lama dan perlu dirapikan saat perubahan dokumen tersebut sudah aman untuk disentuh.
- Belum ada pengujian otomatis untuk komponen, fungsi API, maupun alur utama pengguna.
- Commit baseline awal sudah dibuat; perubahan fitur archive/restore, audit history, attachment, Settings, PDF export, dan dashboard analytics masih perlu commit lanjutan setelah diverifikasi.

## Langkah Berikutnya

1. Menambahkan pengujian otomatis untuk autentikasi, authoring, library, dan approval.
2. Menambahkan pagination Library ketika jumlah data sudah besar.
3. Menambahkan alur lupa password.
4. Merapikan encoding dokumen `prd.md` setelah perubahan dokumen tersebut siap disatukan.
5. Membuat commit lanjutan setelah fitur terbaru selesai diverifikasi.

## Status Saat Ini

Aplikasi telah mencapai MVP fungsional. Workflow approval dua tahap, manajemen pengguna, editor draft/revisi, dashboard/detail, Library, notifikasi, riwayat versi, komentar klinis, archive/restore, audit history, attachment dokumen pendukung, Settings dasar, PDF export, dan dashboard analytics berbasis data sudah tersedia. Build produksi berhasil.
