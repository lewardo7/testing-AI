-- Complete the role-based two-stage approval workflow.
create or replace function public.submit_pathway(p_pathway_id uuid) returns void
language plpgsql security definer set search_path = public as $$
declare
  p public.clinical_pathways;
  v_version_id uuid;
  v_reviewer_id uuid;
begin
  select * into p from public.clinical_pathways where id=p_pathway_id for update;
  if p.id is null or not public.can_edit_pathway(p) then raise exception 'Not allowed'; end if;
  if p.status not in ('draft','revision') then raise exception 'Pathway cannot be submitted in its current status'; end if;

  select id into v_version_id from public.pathway_versions
  where pathway_id=p.id and version_number=p.current_version;
  if v_version_id is null then raise exception 'Current version is missing'; end if;

  select id into v_reviewer_id from public.profiles
  where role='reviewer' and is_active and id<>auth.uid()
  order by (department_id=p.department_id) desc, created_at asc limit 1;
  if v_reviewer_id is null then raise exception 'No active reviewer is available'; end if;

  insert into public.approvals(pathway_id,version_id,reviewer_id,stage)
  values(p.id,v_version_id,v_reviewer_id,'review')
  on conflict(version_id,reviewer_id,stage) do update
  set status='pending',notes=null,decided_at=null,created_at=now();

  update public.clinical_pathways set status='in_review' where id=p.id;
  insert into public.notifications(user_id,type,title,message,pathway_id)
  values(v_reviewer_id,'approval','Pathway menunggu review',p.title,p.id);
  insert into public.audit_logs(actor_id,action,entity_type,entity_id,new_data)
  values(auth.uid(),'submit','clinical_pathway',p.id,jsonb_build_object('status','in_review','reviewer_id',v_reviewer_id));
end $$;

create or replace function public.decide_approval(
  p_approval_id uuid,
  p_status public.approval_status,
  p_notes text default null
) returns void
language plpgsql security definer set search_path = public as $$
declare
  a public.approvals;
  p public.clinical_pathways;
  v_role public.app_role;
  v_approver_id uuid;
  v_next_status public.pathway_status;
begin
  select * into a from public.approvals where id=p_approval_id for update;
  if a.id is null then raise exception 'Approval not found'; end if;
  v_role := public.current_role();
  if a.reviewer_id<>auth.uid() and v_role<>'administrator' then raise exception 'Not allowed'; end if;
  if v_role<>'administrator' and ((a.stage='review' and v_role<>'reviewer') or (a.stage='final_approval' and v_role<>'approver')) then
    raise exception 'Your role cannot decide this approval stage';
  end if;
  if a.status<>'pending' or p_status='pending' then raise exception 'Invalid decision'; end if;
  if p_status in ('rejected','revision_requested') and length(trim(coalesce(p_notes,'')))<3 then
    raise exception 'Decision notes are required';
  end if;

  select * into p from public.clinical_pathways where id=a.pathway_id for update;
  update public.approvals set status=p_status,notes=nullif(trim(p_notes),''),decided_at=now() where id=a.id;

  if p_status in ('rejected','revision_requested') then
    v_next_status := 'revision';
    insert into public.notifications(user_id,type,title,message,pathway_id)
    values(p.owner_id,'rejected',case when p_status='rejected' then 'Pathway ditolak' else 'Revisi pathway diminta' end,p_notes,p.id);
  elsif a.stage='review' then
    select id into v_approver_id from public.profiles
    where role='approver' and is_active and id<>auth.uid()
    order by (department_id=p.department_id) desc,created_at asc limit 1;
    if v_approver_id is null then raise exception 'No active approver is available'; end if;
    insert into public.approvals(pathway_id,version_id,reviewer_id,stage)
    values(p.id,a.version_id,v_approver_id,'final_approval')
    on conflict(version_id,reviewer_id,stage) do update set status='pending',notes=null,decided_at=null;
    v_next_status := 'approved';
    insert into public.notifications(user_id,type,title,message,pathway_id)
    values(v_approver_id,'approval','Pathway menunggu persetujuan final',p.title,p.id);
  else
    v_next_status := 'published';
    insert into public.notifications(user_id,type,title,message,pathway_id)
    values(p.owner_id,'published','Pathway telah dipublikasikan',p.title,p.id);
  end if;

  update public.clinical_pathways
  set status=v_next_status,published_at=case when v_next_status='published' then now() else published_at end
  where id=p.id;
  insert into public.audit_logs(actor_id,action,entity_type,entity_id,new_data)
  values(auth.uid(),'approval_decision','approval',a.id,jsonb_build_object('stage',a.stage,'status',p_status,'notes',p_notes));
end $$;

grant execute on function public.submit_pathway(uuid) to authenticated;
grant execute on function public.decide_approval(uuid,public.approval_status,text) to authenticated;
