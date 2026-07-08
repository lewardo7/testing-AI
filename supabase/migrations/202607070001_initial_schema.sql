create extension if not exists "pgcrypto";

create type public.app_role as enum ('administrator','author','reviewer','approver','viewer');
create type public.pathway_status as enum ('draft','in_review','revision','approved','published','archived');
create type public.approval_status as enum ('pending','approved','rejected','revision_requested');
create type public.notification_type as enum ('approval','rejected','comment','published','expired');

create table public.departments (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  created_at timestamptz not null default now()
);

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  employee_id text unique,
  role public.app_role not null default 'viewer',
  department_id uuid references public.departments(id),
  avatar_url text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.clinical_pathways (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  title text not null,
  summary text,
  diagnosis_name text,
  icd10_code text,
  department_id uuid not null references public.departments(id),
  owner_id uuid not null references public.profiles(id),
  status public.pathway_status not null default 'draft',
  current_version integer not null default 1 check (current_version > 0),
  review_due_at date,
  published_at timestamptz,
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.pathway_versions (
  id uuid primary key default gen_random_uuid(),
  pathway_id uuid not null references public.clinical_pathways(id) on delete cascade,
  version_number integer not null check (version_number > 0),
  change_summary text,
  clinical_objective text,
  inclusion_criteria text[] not null default '{}',
  exclusion_criteria text[] not null default '{}',
  content jsonb not null default '{}'::jsonb,
  created_by uuid not null references public.profiles(id),
  created_at timestamptz not null default now(),
  unique(pathway_id, version_number)
);

create table public.pathway_steps (
  id uuid primary key default gen_random_uuid(),
  version_id uuid not null references public.pathway_versions(id) on delete cascade,
  position integer not null check (position > 0),
  title text not null,
  description text,
  target_duration_hours integer check (target_duration_hours >= 0),
  indicators jsonb not null default '[]'::jsonb,
  unique(version_id, position)
);

create table public.approvals (
  id uuid primary key default gen_random_uuid(),
  pathway_id uuid not null references public.clinical_pathways(id) on delete cascade,
  version_id uuid not null references public.pathway_versions(id) on delete cascade,
  reviewer_id uuid not null references public.profiles(id),
  stage text not null check (stage in ('review','final_approval')),
  status public.approval_status not null default 'pending',
  notes text,
  decided_at timestamptz,
  created_at timestamptz not null default now(),
  unique(version_id, reviewer_id, stage)
);

create table public.comments (
  id uuid primary key default gen_random_uuid(),
  pathway_id uuid not null references public.clinical_pathways(id) on delete cascade,
  version_id uuid references public.pathway_versions(id) on delete cascade,
  author_id uuid not null references public.profiles(id),
  parent_id uuid references public.comments(id) on delete cascade,
  body text not null check (length(trim(body)) > 0),
  resolved_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.attachments (
  id uuid primary key default gen_random_uuid(),
  pathway_id uuid not null references public.clinical_pathways(id) on delete cascade,
  version_id uuid references public.pathway_versions(id) on delete cascade,
  file_name text not null,
  storage_path text not null unique,
  mime_type text,
  size_bytes bigint check (size_bytes >= 0),
  uploaded_by uuid not null references public.profiles(id),
  created_at timestamptz not null default now()
);

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  type public.notification_type not null,
  title text not null,
  message text,
  pathway_id uuid references public.clinical_pathways(id) on delete cascade,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create table public.audit_logs (
  id bigint generated always as identity primary key,
  actor_id uuid references public.profiles(id) on delete set null,
  action text not null,
  entity_type text not null,
  entity_id uuid,
  old_data jsonb,
  new_data jsonb,
  created_at timestamptz not null default now()
);

create index pathways_status_idx on public.clinical_pathways(status);
create index pathways_department_idx on public.clinical_pathways(department_id);
create index pathways_owner_idx on public.clinical_pathways(owner_id);
create index approvals_reviewer_status_idx on public.approvals(reviewer_id, status);
create index notifications_user_unread_idx on public.notifications(user_id, read_at);
create index comments_pathway_idx on public.comments(pathway_id);

create or replace function public.set_updated_at() returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end $$;
create trigger profiles_updated before update on public.profiles for each row execute function public.set_updated_at();
create trigger pathways_updated before update on public.clinical_pathways for each row execute function public.set_updated_at();
create trigger comments_updated before update on public.comments for each row execute function public.set_updated_at();

create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles(id, full_name, role)
  values(new.id, coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)), 'viewer');
  return new;
end $$;
create trigger on_auth_user_created after insert on auth.users for each row execute function public.handle_new_user();

create or replace function public.current_role() returns public.app_role language sql stable security definer set search_path = public as $$
  select role from public.profiles where id = auth.uid() and is_active
$$;

create or replace function public.protect_profile_privileges() returns trigger language plpgsql as $$
begin
  if (new.role is distinct from old.role or new.is_active is distinct from old.is_active)
     and coalesce(public.current_role() = 'administrator', false) = false then
    raise exception 'Only administrators can change role or active status';
  end if;
  return new;
end $$;
create trigger protect_profile_privileges before update on public.profiles for each row execute function public.protect_profile_privileges();

create or replace function public.can_edit_pathway(pathway public.clinical_pathways) returns boolean language sql stable as $$
  select public.current_role() = 'administrator' or
    (pathway.owner_id = auth.uid() and public.current_role() = 'author' and pathway.status in ('draft','revision'))
$$;

create or replace function public.submit_pathway(p_pathway_id uuid) returns void language plpgsql security definer set search_path = public as $$
declare p public.clinical_pathways;
begin
  select * into p from public.clinical_pathways where id = p_pathway_id for update;
  if p.id is null or not public.can_edit_pathway(p) then raise exception 'Not allowed'; end if;
  if not exists(select 1 from public.pathway_versions where pathway_id=p.id and version_number=p.current_version) then raise exception 'Current version is missing'; end if;
  update public.clinical_pathways set status='in_review' where id=p.id;
  insert into public.audit_logs(actor_id,action,entity_type,entity_id,new_data) values(auth.uid(),'submit','clinical_pathway',p.id,jsonb_build_object('status','in_review'));
end $$;

create or replace function public.decide_approval(p_approval_id uuid, p_status public.approval_status, p_notes text default null) returns void language plpgsql security definer set search_path = public as $$
declare a public.approvals; next_status public.pathway_status;
begin
  select * into a from public.approvals where id=p_approval_id for update;
  if a.id is null or (a.reviewer_id <> auth.uid() and public.current_role() <> 'administrator') then raise exception 'Not allowed'; end if;
  if a.status <> 'pending' or p_status = 'pending' then raise exception 'Invalid decision'; end if;
  update public.approvals set status=p_status, notes=p_notes, decided_at=now() where id=a.id;
  next_status := case when p_status='revision_requested' or p_status='rejected' then 'revision'::public.pathway_status when a.stage='final_approval' and p_status='approved' then 'published'::public.pathway_status else 'approved'::public.pathway_status end;
  update public.clinical_pathways set status=next_status, published_at=case when next_status='published' then now() else published_at end where id=a.pathway_id;
  insert into public.audit_logs(actor_id,action,entity_type,entity_id,new_data) values(auth.uid(),'approval_decision','approval',a.id,jsonb_build_object('status',p_status,'notes',p_notes));
end $$;

alter table public.profiles enable row level security;
alter table public.departments enable row level security;
alter table public.clinical_pathways enable row level security;
alter table public.pathway_versions enable row level security;
alter table public.pathway_steps enable row level security;
alter table public.approvals enable row level security;
alter table public.comments enable row level security;
alter table public.attachments enable row level security;
alter table public.notifications enable row level security;
alter table public.audit_logs enable row level security;

create policy "authenticated read departments" on public.departments for select to authenticated using (true);
create policy "authenticated read profiles" on public.profiles for select to authenticated using (true);
create policy "own profile update" on public.profiles for update to authenticated using (id=auth.uid()) with check (id=auth.uid());
create policy "admin manage profiles" on public.profiles for all to authenticated using (public.current_role()='administrator') with check (public.current_role()='administrator');
create policy "read visible pathways" on public.clinical_pathways for select to authenticated using (status='published' or owner_id=auth.uid() or public.current_role() in ('administrator','reviewer','approver'));
create policy "create pathways" on public.clinical_pathways for insert to authenticated with check (owner_id=auth.uid() and public.current_role() in ('author','administrator'));
create policy "edit own pathways" on public.clinical_pathways for update to authenticated using (public.can_edit_pathway(clinical_pathways)) with check (public.can_edit_pathway(clinical_pathways));
create policy "admin delete pathways" on public.clinical_pathways for delete to authenticated using (public.current_role()='administrator');
create policy "read versions" on public.pathway_versions for select to authenticated using (exists(select 1 from public.clinical_pathways p where p.id=pathway_id));
create policy "create versions" on public.pathway_versions for insert to authenticated with check (created_by=auth.uid() and exists(select 1 from public.clinical_pathways p where p.id=pathway_id and public.can_edit_pathway(p)));
create policy "read steps" on public.pathway_steps for select to authenticated using (exists(select 1 from public.pathway_versions v join public.clinical_pathways p on p.id=v.pathway_id where v.id=version_id));
create policy "manage steps" on public.pathway_steps for all to authenticated using (exists(select 1 from public.pathway_versions v join public.clinical_pathways p on p.id=v.pathway_id where v.id=version_id and public.can_edit_pathway(p))) with check (exists(select 1 from public.pathway_versions v join public.clinical_pathways p on p.id=v.pathway_id where v.id=version_id and public.can_edit_pathway(p)));
create policy "reviewer read approvals" on public.approvals for select to authenticated using (reviewer_id=auth.uid() or public.current_role()='administrator' or exists(select 1 from public.clinical_pathways p where p.id=pathway_id and p.owner_id=auth.uid()));
create policy "admin create approvals" on public.approvals for insert to authenticated with check (public.current_role()='administrator');
create policy "read comments" on public.comments for select to authenticated using (exists(select 1 from public.clinical_pathways p where p.id=pathway_id));
create policy "create comments" on public.comments for insert to authenticated with check (author_id=auth.uid());
create policy "edit own comments" on public.comments for update to authenticated using (author_id=auth.uid() or public.current_role()='administrator');
create policy "read attachments" on public.attachments for select to authenticated using (exists(select 1 from public.clinical_pathways p where p.id=pathway_id));
create policy "upload attachments" on public.attachments for insert to authenticated with check (uploaded_by=auth.uid());
create policy "own notifications" on public.notifications for select to authenticated using (user_id=auth.uid());
create policy "mark own notifications" on public.notifications for update to authenticated using (user_id=auth.uid()) with check (user_id=auth.uid());
create policy "admin read audit" on public.audit_logs for select to authenticated using (public.current_role()='administrator');

insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values('pathway-attachments','pathway-attachments',false,10485760,array['application/pdf','image/png','image/jpeg','application/vnd.openxmlformats-officedocument.wordprocessingml.document'])
on conflict (id) do nothing;
create policy "authenticated download attachments" on storage.objects for select to authenticated using (bucket_id='pathway-attachments');
create policy "authenticated upload attachments" on storage.objects for insert to authenticated with check (bucket_id='pathway-attachments' and (storage.foldername(name))[1]=auth.uid()::text);
create policy "owner delete attachments" on storage.objects for delete to authenticated using (bucket_id='pathway-attachments' and owner_id=auth.uid()::text);

grant execute on function public.submit_pathway(uuid) to authenticated;
grant execute on function public.decide_approval(uuid,public.approval_status,text) to authenticated;
