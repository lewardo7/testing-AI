import { supabase } from './supabase';

export type PathwayStatus = 'draft'|'in_review'|'revision'|'approved'|'published'|'archived';
export type AppRole = 'administrator'|'author'|'reviewer'|'approver'|'viewer';
export type ApprovalDecision = 'approved'|'rejected'|'revision_requested';
export type PathwayInput = { code:string; title:string; summary?:string; diagnosis_name?:string; icd10_code?:string; department_id:string };
export type DraftInput = PathwayInput & { clinical_objective?:string; inclusion_criteria?:string[]; steps:{position:number;title:string;description:string;target_duration_hours?:number}[] };
export type PathwayAttachment = { id:string; pathway_id:string; version_id?:string|null; file_name:string; storage_path:string; mime_type?:string|null; size_bytes?:number|null; uploaded_by:string; created_at:string; profiles?:{full_name:string}|{full_name:string}[]|null };

export async function signIn(email:string,password:string){
  const { data,error }=await supabase.auth.signInWithPassword({email,password});
  if(error) throw error; return data;
}
export async function signOut(){ const {error}=await supabase.auth.signOut(); if(error) throw error; }
export async function getCurrentProfile(){
  const {data:{user}}=await supabase.auth.getUser(); if(!user) return null;
  const {data,error}=await supabase.from('profiles').select('*, departments(*)').eq('id',user.id).single();
  if(error) throw error; return data;
}
export async function listPathways(search='',status?:PathwayStatus){
  let query=supabase.from('clinical_pathways').select('*, departments(name,code), profiles!clinical_pathways_owner_id_fkey(full_name)').order('updated_at',{ascending:false});
  if(search) query=query.or(`title.ilike.%${search}%,code.ilike.%${search}%`);
  if(status) query=query.eq('status',status);
  const {data,error}=await query; if(error) throw error; return data;
}
export async function getPathway(id:string){
  const {data,error}=await supabase.from('clinical_pathways').select('*, departments(*), profiles!clinical_pathways_owner_id_fkey(*), pathway_versions(*, pathway_steps(*)), comments(*, profiles!comments_author_id_fkey(full_name))').eq('id',id).single();
  if(error) throw error; return data;
}
export async function getDashboardData(){
  const {data,error}=await supabase.from('clinical_pathways').select('id,title,code,status,updated_at,current_version,review_due_at,departments(name),profiles!clinical_pathways_owner_id_fkey(full_name)').order('updated_at',{ascending:false});
  if(error) throw error;
  const rows=data||[]; const now=new Date(); const inThirtyDays=new Date(now.getTime()+30*86400000);
  return {rows,total:rows.length,published:rows.filter((x:any)=>x.status==='published').length,pending:rows.filter((x:any)=>x.status==='in_review'||x.status==='approved').length,dueSoon:rows.filter((x:any)=>x.review_due_at&&new Date(x.review_due_at)>=now&&new Date(x.review_due_at)<=inThirtyDays).length};
}
export async function createPathway(input:PathwayInput){
  const {data:{user}}=await supabase.auth.getUser(); if(!user) throw new Error('Authentication required');
  const {data,error}=await supabase.from('clinical_pathways').insert({...input,owner_id:user.id}).select().single();
  if(error) throw error; return data;
}
export async function listDepartments(){
  const {data,error}=await supabase.from('departments').select('id,code,name').order('name');
  if(error) throw error; return data;
}
export async function createPathwayDraft(input:DraftInput){
  const {data,error}=await supabase.rpc('create_pathway_draft',{
    p_code:input.code,p_title:input.title,p_department_id:input.department_id,
    p_summary:input.summary||null,p_diagnosis_name:input.diagnosis_name||null,
    p_icd10_code:input.icd10_code||null,p_clinical_objective:input.clinical_objective||null,
    p_inclusion_criteria:input.inclusion_criteria||[],p_steps:input.steps,
  });
  if(error) throw error; return data as string;
}
export async function updatePathwayDraft(id:string,input:DraftInput){
  const {error}=await supabase.rpc('update_pathway_draft',{
    p_pathway_id:id,p_code:input.code,p_title:input.title,p_department_id:input.department_id,
    p_summary:input.summary||null,p_diagnosis_name:input.diagnosis_name||null,p_icd10_code:input.icd10_code||null,
    p_clinical_objective:input.clinical_objective||null,p_inclusion_criteria:input.inclusion_criteria||[],p_steps:input.steps,
  });
  if(error) throw error;
}
export async function submitPathway(id:string){ const {error}=await supabase.rpc('submit_pathway',{p_pathway_id:id}); if(error) throw error; }
export async function getApprovalQueue(role?:AppRole){
  const {data:{user}}=await supabase.auth.getUser(); if(!user) return [];
  let query=supabase.from('approvals').select('*, clinical_pathways(*, departments(name), profiles!clinical_pathways_owner_id_fkey(full_name)), pathway_versions(version_number,clinical_objective,inclusion_criteria,pathway_steps(position,title,description,target_duration_hours))').eq('status','pending').order('created_at');
  if(role!=='administrator') query=query.eq('reviewer_id',user.id);
  const {data,error}=await query;
  if(error) throw error; return data;
}
export async function decideApproval(id:string,status:ApprovalDecision,notes?:string){
  const {error}=await supabase.rpc('decide_approval',{p_approval_id:id,p_status:status,p_notes:notes||null}); if(error) throw error;
}
export async function listNotifications(){ const {data,error}=await supabase.from('notifications').select('*').is('read_at',null).order('created_at',{ascending:false}); if(error) throw error; return data; }
export async function markNotificationRead(id:string){ const {error}=await supabase.from('notifications').update({read_at:new Date().toISOString()}).eq('id',id); if(error) throw error; }
export async function listUsers(){ const {data,error}=await supabase.from('profiles').select('id,full_name,email,employee_id,role,is_active,department_id,departments(name)').order('full_name'); if(error) throw error; return data; }
export async function createUserAccount(input:{full_name:string;email:string;password:string;role:AppRole;department_id?:string;employee_id?:string}){
  const {data,error}=await supabase.functions.invoke('admin-users',{body:input});
  if(error) throw new Error((data as any)?.error||error.message); if((data as any)?.error) throw new Error((data as any).error); return data;
}
export async function updateUserProfile(id:string,input:{role:AppRole;department_id:string|null;is_active:boolean}){ const {error}=await supabase.from('profiles').update(input).eq('id',id); if(error) throw error; }
export async function addPathwayComment(pathwayId:string,versionId:string|undefined,body:string){
  const {data:{user}}=await supabase.auth.getUser(); if(!user) throw new Error('Authentication required');
  const {error}=await supabase.from('comments').insert({pathway_id:pathwayId,version_id:versionId||null,author_id:user.id,body:body.trim()}); if(error) throw error;
}
export async function listPathwayAttachments(pathwayId:string){
  const {data,error}=await supabase.from('attachments').select('id,pathway_id,version_id,file_name,storage_path,mime_type,size_bytes,uploaded_by,created_at,profiles!attachments_uploaded_by_fkey(full_name)').eq('pathway_id',pathwayId).order('created_at',{ascending:false});
  if(error) throw error; return data as unknown as PathwayAttachment[];
}
export async function uploadPathwayAttachment(pathwayId:string,versionId:string|undefined,file:File){
  const {data:{user}}=await supabase.auth.getUser(); if(!user) throw new Error('Authentication required');
  const cleanName=file.name.replace(/[^\w.\-() ]+/g,'_').slice(0,140);
  const storagePath=`${user.id}/${pathwayId}/${Date.now()}-${cleanName}`;
  const uploaded=await supabase.storage.from('pathway-attachments').upload(storagePath,file,{contentType:file.type||undefined,upsert:false});
  if(uploaded.error) throw uploaded.error;
  const {data,error}=await supabase.from('attachments').insert({pathway_id:pathwayId,version_id:versionId||null,file_name:file.name,storage_path:storagePath,mime_type:file.type||null,size_bytes:file.size,uploaded_by:user.id}).select().single();
  if(error){ await supabase.storage.from('pathway-attachments').remove([storagePath]); throw error; }
  return data;
}
export async function getAttachmentUrl(storagePath:string){
  const {data,error}=await supabase.storage.from('pathway-attachments').createSignedUrl(storagePath,60);
  if(error) throw error; return data.signedUrl;
}
export async function deletePathwayAttachment(attachment:PathwayAttachment){
  const removed=await supabase.storage.from('pathway-attachments').remove([attachment.storage_path]);
  if(removed.error) throw removed.error;
  const {error}=await supabase.from('attachments').delete().eq('id',attachment.id);
  if(error) throw error;
}
export async function setPathwayArchived(id:string,archived:boolean){ const {error}=await supabase.rpc('set_pathway_archived',{p_pathway_id:id,p_archived:archived}); if(error) throw error; }
export async function getPathwayAudit(id:string){ const {data,error}=await supabase.from('audit_logs').select('id,action,old_data,new_data,created_at,profiles(full_name)').eq('entity_id',id).order('created_at',{ascending:false}); if(error) throw error; return data; }
