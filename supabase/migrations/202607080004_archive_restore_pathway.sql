create or replace function public.set_pathway_archived(p_pathway_id uuid,p_archived boolean) returns void
language plpgsql security definer set search_path=public as $$
declare p public.clinical_pathways; v_status public.pathway_status;
begin
  if public.current_role()<>'administrator' then raise exception 'Only administrators can archive or restore pathways'; end if;
  select * into p from public.clinical_pathways where id=p_pathway_id for update;
  if p.id is null then raise exception 'Pathway not found'; end if;
  if p_archived and p.status<>'published' then raise exception 'Only published pathways can be archived'; end if;
  if not p_archived and p.status<>'archived' then raise exception 'Only archived pathways can be restored'; end if;
  v_status:=case when p_archived then 'archived'::public.pathway_status else 'published'::public.pathway_status end;
  update public.clinical_pathways set status=v_status,archived_at=case when p_archived then now() else null end where id=p.id;
  insert into public.audit_logs(actor_id,action,entity_type,entity_id,old_data,new_data)
  values(auth.uid(),case when p_archived then 'archive' else 'restore' end,'clinical_pathway',p.id,jsonb_build_object('status',p.status),jsonb_build_object('status',v_status));
end $$;
grant execute on function public.set_pathway_archived(uuid,boolean) to authenticated;
