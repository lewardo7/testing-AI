# Progress Pengembangan CliniPath

Pembaruan terakhir: 8 Juli 2026

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
- Menyiapkan fungsi akses data untuk pathway, departemen, profil, approval, dan notifikasi.
- Menyiapkan skema database Supabase, Row Level Security, fungsi database, migrasi, konfigurasi lokal, dan seed data.
- Menambahkan dokumentasi kebutuhan produk dan petunjuk backend.
- Memverifikasi aplikasi dengan build produksi. Build berhasil tanpa error pada 8 Juli 2026.

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
- `BACKEND.md` — petunjuk menjalankan dan melakukan deployment backend.
- `prd.md` — kebutuhan produk dan roadmap awal.
- `.gitignore` — daftar file yang tidak disimpan ke Git.

## Masalah yang Belum Selesai

- Unduh PDF belum memiliki fungsi.
- Halaman Settings masih berupa placeholder.
- Grafik aktivitas dashboard masih belum menggunakan agregasi data bulanan.
- Pagination pada Pathway Library belum diperlukan sampai jumlah data melebihi satu halaman dan belum diimplementasikan.
- Alur lupa password belum dibuat.
- Audit history, attachment, serta archive/restore belum tersedia pada antarmuka.
- Beberapa karakter pada teks antarmuka mengalami masalah encoding, misalnya panah, tanda lebih besar atau sama dengan, dan bullet.
- Belum ada pengujian otomatis untuk komponen, fungsi API, maupun alur utama pengguna.
- Repository Git belum memiliki commit awal; seluruh file saat ini masih berstatus belum dilacak.

## Langkah Berikutnya

1. Menambahkan archive dan restore pathway beserta audit history pada antarmuka.
2. Menambahkan attachment dokumen pendukung.
3. Mengembangkan halaman Settings.
4. Menambahkan ekspor atau unduh PDF.
5. Menambahkan pengujian otomatis untuk autentikasi, authoring, library, dan approval.
6. Menambahkan agregasi grafik aktivitas dashboard dan pagination Library ketika dibutuhkan.
7. Menjalankan pemeriksaan akhir lalu membuat commit Git pertama sebagai baseline proyek.

## Status Saat Ini

Aplikasi telah mencapai MVP fungsional. Workflow approval dua tahap, manajemen pengguna, editor draft/revisi, dashboard/detail, Library, notifikasi, riwayat versi, dan komentar klinis sudah tersedia. Build produksi berhasil.
