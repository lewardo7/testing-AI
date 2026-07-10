create table if not exists public.hospitals (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  code text not null unique,
  location text not null,
  address text,
  phone text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

drop trigger if exists hospitals_updated on public.hospitals;
create trigger hospitals_updated
before update on public.hospitals
for each row execute function public.set_updated_at();

alter table public.hospitals enable row level security;

create policy "authenticated read hospitals"
on public.hospitals
for select
to authenticated
using (true);

create policy "admin manage hospitals"
on public.hospitals
for all
to authenticated
using (public.current_role() = 'administrator')
with check (public.current_role() = 'administrator');

insert into public.hospitals(name,code,location)
select
  coalesce(value->>'name','RS Sehat Sentosa'),
  coalesce(value->>'code','RS'),
  coalesce(value->>'location','Jakarta Pusat')
from public.app_settings
where key = 'hospital'
on conflict (code) do nothing;

insert into public.hospitals(name,code,location)
select 'RS Sehat Sentosa','RS','Jakarta Pusat'
where not exists(select 1 from public.hospitals);
