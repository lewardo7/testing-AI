create or replace function public.create_pathway_draft(
  p_code text,
  p_title text,
  p_department_id uuid,
  p_summary text default null,
  p_diagnosis_name text default null,
  p_icd10_code text default null,
  p_clinical_objective text default null,
  p_inclusion_criteria text[] default '{}',
  p_steps jsonb default '[]'::jsonb
) returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_pathway_id uuid;
  v_version_id uuid;
  v_step jsonb;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  if public.current_role() not in ('administrator','author') then raise exception 'Not allowed'; end if;
  if length(trim(p_code)) < 3 or length(trim(p_title)) < 3 then raise exception 'Code and title are required'; end if;
  if not exists(select 1 from public.departments where id=p_department_id) then raise exception 'Department not found'; end if;

  insert into public.clinical_pathways(code,title,summary,diagnosis_name,icd10_code,department_id,owner_id)
  values(upper(trim(p_code)),trim(p_title),nullif(trim(p_summary),''),nullif(trim(p_diagnosis_name),''),nullif(trim(p_icd10_code),''),p_department_id,auth.uid())
  returning id into v_pathway_id;

  insert into public.pathway_versions(pathway_id,version_number,clinical_objective,inclusion_criteria,created_by)
  values(v_pathway_id,1,nullif(trim(p_clinical_objective),''),coalesce(p_inclusion_criteria,'{}'),auth.uid())
  returning id into v_version_id;

  for v_step in select value from jsonb_array_elements(coalesce(p_steps,'[]'::jsonb)) loop
    if length(trim(coalesce(v_step->>'title',''))) > 0 then
      insert into public.pathway_steps(version_id,position,title,description,target_duration_hours)
      values(v_version_id,coalesce((v_step->>'position')::integer,1),trim(v_step->>'title'),nullif(trim(v_step->>'description'),''),nullif(v_step->>'target_duration_hours','')::integer);
    end if;
  end loop;

  insert into public.audit_logs(actor_id,action,entity_type,entity_id,new_data)
  values(auth.uid(),'create','clinical_pathway',v_pathway_id,jsonb_build_object('code',upper(trim(p_code)),'status','draft'));
  return v_pathway_id;
end $$;

grant execute on function public.create_pathway_draft(text,text,uuid,text,text,text,text,text[],jsonb) to authenticated;
