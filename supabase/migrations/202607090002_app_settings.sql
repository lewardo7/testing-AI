create table if not exists public.app_settings (
  key text primary key,
  value jsonb not null default '{}'::jsonb,
  description text,
  updated_by uuid references public.profiles(id) on delete set null,
  updated_at timestamptz not null default now()
);

alter table public.app_settings enable row level security;

create policy "authenticated read app settings"
on public.app_settings
for select
to authenticated
using (true);

create policy "admin manage app settings"
on public.app_settings
for all
to authenticated
using (public.current_role() = 'administrator')
with check (public.current_role() = 'administrator');

insert into public.app_settings(key,value,description)
values
  ('hospital', '{"name":"RS Sehat Sentosa","location":"Jakarta Pusat","code":"RS"}', 'Identitas fasilitas pelayanan kesehatan.'),
  ('pathway_policy', '{"review_interval_months":6,"default_reviewer_stage":"review","require_revision_notes":true}', 'Kebijakan umum siklus clinical pathway.'),
  ('attachment_policy', '{"max_file_size_mb":10,"allowed_types":["PDF","PNG","JPG","DOCX"]}', 'Batas dan tipe dokumen pendukung.')
on conflict (key) do nothing;
