import { useEffect, useState, type ChangeEvent, type FormEvent } from 'react';
import { Archive, Check, Clock3, Download, FileText, MessageSquare, RotateCcw, Send, Trash2, Upload } from 'lucide-react';
import {
  addPathwayComment,
  deletePathwayAttachment,
  getAttachmentUrl,
  getCurrentProfile,
  getPathwayAudit,
  listPathwayAttachments,
  setPathwayArchived,
  uploadPathwayAttachment,
  type PathwayAttachment,
} from './lib/api';

export default function PathwayHistoryComments({data,onRefresh}:{data:any;onRefresh:()=>Promise<void>}){
 const versions=[...(data.pathway_versions||[])].sort((a:any,b:any)=>b.version_number-a.version_number);
 const comments=[...(data.comments||[])].sort((a:any,b:any)=>new Date(b.created_at).getTime()-new Date(a.created_at).getTime());
 const current=versions.find((v:any)=>v.version_number===data.current_version);
 const [body,setBody]=useState('');
 const [saving,setSaving]=useState(false);
 const [error,setError]=useState('');
 const [success,setSuccess]=useState('');
 const [audit,setAudit]=useState<any[]>([]);
 const [actionLoading,setActionLoading]=useState(false);
 const [isAdmin,setIsAdmin]=useState(false);
 const [attachments,setAttachments]=useState<PathwayAttachment[]>([]);
 const [attachmentBusy,setAttachmentBusy]=useState(false);

 const loadAttachments=async()=>setAttachments(await listPathwayAttachments(data.id));

 useEffect(()=>{
  let live=true;
  getCurrentProfile().then(p=>{
   if(!live)return;
   const admin=p?.role==='administrator';
   setIsAdmin(admin);
   if(admin)getPathwayAudit(data.id).then(x=>live&&setAudit(x)).catch(()=>live&&setAudit([]));
  });
  loadAttachments().catch(()=>live&&setAttachments([]));
  return()=>{live=false};
 },[data.id]);

 const submit=async(e:FormEvent)=>{
  e.preventDefault();
  if(body.trim().length<2){setError('Komentar minimal 2 karakter.');return}
  setSaving(true);setError('');setSuccess('');
  try{
   await addPathwayComment(data.id,current?.id,body);
   setBody('');
   setSuccess('Komentar berhasil ditambahkan.');
   await onRefresh();
  }catch(e){setError(e instanceof Error?e.message:'Gagal menambahkan komentar')}
  finally{setSaving(false)}
 };

 const changeArchive=async(archived:boolean)=>{
  setActionLoading(true);setError('');setSuccess('');
  try{
   await setPathwayArchived(data.id,archived);
   setSuccess(archived?'Pathway berhasil diarsipkan.':'Pathway berhasil dipulihkan.');
   await onRefresh();
   setAudit(await getPathwayAudit(data.id));
  }catch(e){setError(e instanceof Error?e.message:'Gagal mengubah status pathway')}
  finally{setActionLoading(false)}
 };

 const uploadAttachment=async(e:ChangeEvent<HTMLInputElement>)=>{
  const file=e.target.files?.[0];
  e.target.value='';
  if(!file)return;
  setAttachmentBusy(true);setError('');setSuccess('');
  try{
   await uploadPathwayAttachment(data.id,current?.id,file);
   await loadAttachments();
   setSuccess('Lampiran berhasil diunggah.');
  }catch(e){setError(e instanceof Error?e.message:'Gagal mengunggah lampiran')}
  finally{setAttachmentBusy(false)}
 };

 const openAttachment=async(attachment:PathwayAttachment)=>{
  setAttachmentBusy(true);setError('');
  try{
   const url=await getAttachmentUrl(attachment.storage_path);
   window.open(url,'_blank','noopener,noreferrer');
  }catch(e){setError(e instanceof Error?e.message:'Gagal membuka lampiran')}
  finally{setAttachmentBusy(false)}
 };

 const removeAttachment=async(attachment:PathwayAttachment)=>{
  if(!window.confirm(`Hapus lampiran "${attachment.file_name}"?`))return;
  setAttachmentBusy(true);setError('');setSuccess('');
  try{
   await deletePathwayAttachment(attachment);
   await loadAttachments();
   setSuccess('Lampiran berhasil dihapus.');
  }catch(e){setError(e instanceof Error?e.message:'Gagal menghapus lampiran')}
  finally{setAttachmentBusy(false)}
 };

 return <>
  <div className="history-comments">
   <section className="panel history-panel">
    <div className="panelhead"><div><h3><Clock3 size={16}/> Riwayat Versi</h3><p>Jejak versi clinical pathway.</p></div></div>
    {versions.length===0?<p className="panel-note">Belum ada versi.</p>:versions.map((v:any)=><div className="history-item" key={v.id}><span className="history-dot"/><div><strong>Versi {v.version_number}.0 {v.version_number===data.current_version&&<i>Aktif</i>}</strong><p>{v.change_summary||'Versi dokumen clinical pathway.'}</p><small>{new Date(v.created_at).toLocaleString('id-ID')}</small></div></div>)}
   </section>

   <section className="panel comments-panel">
    <div className="panelhead"><div><h3><MessageSquare size={16}/> Komentar Klinis</h3><p>Diskusi dan catatan terkait dokumen.</p></div></div>
    {error&&<div className="login-error">{error}</div>}
    {success&&<div className="success"><Check size={15}/>{success}</div>}
    <form onSubmit={submit}><textarea rows={3} value={body} onChange={e=>setBody(e.target.value)} placeholder="Tambahkan komentar atau catatan klinis..."/><button className="primary" disabled={saving}><Send size={15}/>{saving?'Mengirim...':'Kirim Komentar'}</button></form>
    <div className="comment-list">{comments.length===0?<p className="panel-note">Belum ada komentar.</p>:comments.map((c:any)=><article key={c.id}><div className="comment-avatar">{(c.profiles?.full_name||'?').split(/\s+/).map((x:string)=>x[0]).join('').slice(0,2).toUpperCase()}</div><div><strong>{c.profiles?.full_name||'Pengguna'}</strong><small>{new Date(c.created_at).toLocaleString('id-ID')}</small><p>{c.body}</p></div></article>)}</div>
   </section>
  </div>

  <section className="panel attachments-panel">
   <div className="panelhead">
    <div><h3><FileText size={16}/> Dokumen Pendukung</h3><p>Upload SOP, referensi, atau dokumen klinis terkait pathway.</p></div>
    <label className="upload-button"><Upload size={15}/>{attachmentBusy?'Memproses...':'Upload Lampiran'}<input type="file" disabled={attachmentBusy} onChange={uploadAttachment} accept=".pdf,.png,.jpg,.jpeg,.docx,application/pdf,image/png,image/jpeg,application/vnd.openxmlformats-officedocument.wordprocessingml.document"/></label>
   </div>
   {attachments.length===0?<p className="panel-note">Belum ada lampiran.</p>:<div className="attachment-list">{attachments.map(attachment=><article key={attachment.id}><div className="docicon"><FileText size={17}/></div><div><strong>{attachment.file_name}</strong><small>{formatBytes(attachment.size_bytes)} • {profileName(attachment.profiles)} • {new Date(attachment.created_at).toLocaleString('id-ID')}</small></div><button className="secondary" disabled={attachmentBusy} onClick={()=>openAttachment(attachment)}><Download size={14}/> Buka</button><button className="danger" disabled={attachmentBusy} onClick={()=>removeAttachment(attachment)}><Trash2 size={14}/> Hapus</button></article>)}</div>}
  </section>

  {isAdmin&&<section className="panel audit-panel">
   <div className="panelhead"><div><h3>Audit History</h3><p>Aktivitas penting pada pathway ini.</p></div><div>{data.status==='published'&&<button className="danger" disabled={actionLoading} onClick={()=>changeArchive(true)}><Archive size={15}/> Arsipkan</button>}{data.status==='archived'&&<button className="primary" disabled={actionLoading} onClick={()=>changeArchive(false)}><RotateCcw size={15}/> Pulihkan</button>}</div></div>
   {audit.length===0?<p className="panel-note">Belum ada audit log.</p>:<div className="audit-list">{audit.map((a:any)=><div key={a.id}><span>{new Date(a.created_at).toLocaleString('id-ID')}</span><strong>{auditLabel(a.action)}</strong><p>Oleh {a.profiles?.full_name||'Sistem'}</p></div>)}</div>}
  </section>}
 </>
}

function auditLabel(action:string){return ({create:'Pathway dibuat',update:'Pathway diperbarui',submit:'Dikirim untuk review',approval_decision:'Keputusan approval',archive:'Pathway diarsipkan',restore:'Pathway dipulihkan'} as Record<string,string>)[action]||action}
function formatBytes(size?:number|null){if(!size)return'Ukuran tidak diketahui';if(size<1024)return`${size} B`;if(size<1024*1024)return`${(size/1024).toFixed(1)} KB`;return`${(size/1024/1024).toFixed(1)} MB`}
function profileName(profile?:{full_name:string}|{full_name:string}[]|null){return Array.isArray(profile)?profile[0]?.full_name||'Pengguna':profile?.full_name||'Pengguna'}
