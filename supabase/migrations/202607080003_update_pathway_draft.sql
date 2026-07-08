create or replace function public.update_pathway_draft(
  p_pathway_id uuid,
  p_code text,
  p_title text,
  p_department_id uuid,
  p_summary text default null,
  p_diagnosis_name text default null,
  p_icd10_code text default null,
  p_clinical_objective text default null,
  p_inclusion_criteria text[] default '{}',
  p_steps jsonb default '[]'::jsonb
) returns void
language plpgsql security definer set search_path=public as $$
declare
  p public.clinical_pathways;
  v_version_id uuid;
  v_step jsonb;
begin
  select * into p from public.clinical_pathways where id=p_pathway_id for update;
  if p.id is null or not public.can_edit_pathway(p) then raise exception 'Not allowed'; end if;
  if p.status not in ('draft','revision') then raise exception 'Only draft or revision can be edited'; end if;
  if length(trim(p_code))<3 or length(trim(p_title))<3 then raise exception 'Code and title are required'; end if;
  if not exists(select 1 from public.departments where id=p_department_id) then raise exception 'Department not found'; end if;

  select id into v_version_id from public.pathway_versions
  where pathway_id=p.id and version_number=p.current_version for update;
  if v_version_id is null then raise exception 'Current version is missing'; end if;

  update public.clinical_pathways set
    code=upper(trim(p_code)),title=trim(p_title),department_id=p_department_id,
    summary=nullif(trim(p_summary),''),diagnosis_name=nullif(trim(p_diagnosis_name),''),
    icd10_code=nullif(trim(p_icd10_code),'')
  where id=p.id;
  update public.pathway_versions set
    clinical_objective=nullif(trim(p_clinical_objective),''),
    inclusion_criteria=coalesce(p_inclusion_criteria,'{}')
  where id=v_version_id;
  delete from public.pathway_steps where version_id=v_version_id;
  for v_step in select value from jsonb_array_elements(coalesce(p_steps,'[]'::jsonb)) loop
    if length(trim(coalesce(v_step->>'title','')))>0 then
      insert into public.pathway_steps(version_id,position,title,description,target_duration_hours)
      values(v_version_id,coalesce((v_step->>'position')::integer,1),trim(v_step->>'title'),nullif(trim(v_step->>'description'),''),nullif(v_step->>'target_duration_hours','')::integer);
    end if;
  end loop;
  insert into public.audit_logs(actor_id,action,entity_type,entity_id,new_data)
  values(auth.uid(),'update','clinical_pathway',p.id,jsonb_build_object('status',p.status,'version',p.current_version));
end $$;

grant execute on function public.update_pathway_draft(uuid,text,text,uuid,text,text,text,text,text[],jsonb) to authenticated;
