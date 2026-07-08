# CliniPath Backend

Backend menggunakan Supabase: PostgreSQL, Auth, Row Level Security, dan Storage.

## Menjalankan secara lokal

1. Instal Supabase CLI dan Docker Desktop.
2. Jalankan `supabase start`.
3. Jalankan `supabase db reset` untuk menerapkan migrasi dan seed.
4. Salin `.env.example` menjadi `.env.local`, lalu isi URL dan anon key dari output `supabase status`.
5. Jalankan frontend dengan `npm run dev`.

## Deploy ke Supabase Cloud

1. Buat project Supabase.
2. Jalankan `supabase link --project-ref <project-ref>`.
3. Jalankan `supabase db push`.
4. Masukkan Project URL dan anon key ke `.env.local`.

Pembuatan user dilakukan melalui Supabase Authentication. Trigger otomatis membuat baris `profiles`. Karena registrasi publik dinonaktifkan, administrator membuat user melalui Dashboard Supabase atau server tepercaya, lalu mengatur role pada tabel `profiles`.

Jangan pernah menaruh `service_role` key pada frontend.
