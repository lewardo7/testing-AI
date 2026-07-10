import { useEffect, useMemo, useState } from 'react';

type IcdItem = { kode_icd:string; nama_icd:string; nama_icd_indo?:string };
let cachedIcd: IcdItem[] | null = null;

export default function IcdAutocomplete({value,onChange,onSelect}:{value:string;onChange:(value:string)=>void;onSelect?:(item:IcdItem)=>void}){
 const [open,setOpen]=useState(false); const [items,setItems]=useState<IcdItem[]>(cachedIcd||[]);
 useEffect(()=>{if(cachedIcd)return;fetch('/master_icd_x.json').then(r=>r.json()).then((data:IcdItem[])=>{cachedIcd=data;setItems(data)}).catch(()=>setItems([]))},[]);
 const q=value.trim().toLowerCase();
 const suggestions=useMemo(()=>{
  if(q.length<2) return [];
  return items.filter(item=>{
   const code=item.kode_icd.toLowerCase();
   const en=item.nama_icd.toLowerCase();
   const indo=(item.nama_icd_indo||'').toLowerCase();
   return code.startsWith(q)||en.includes(q)||indo.includes(q);
  }).slice(0,8);
 },[q,items]);
 const pick=(item:IcdItem)=>{onChange(item.kode_icd);onSelect?.(item);setOpen(false)};
 const change=(next:string)=>{
  const normalized=next.toUpperCase();
  onChange(normalized);
  setOpen(true);
  const exact=items.find(item=>item.kode_icd.toUpperCase()===normalized);
  if(exact) onSelect?.(exact);
 };
 return <div className="icd-autocomplete"><input value={value} onFocus={()=>setOpen(true)} onBlur={()=>setTimeout(()=>setOpen(false),150)} onChange={e=>change(e.target.value)} placeholder="Contoh: I63.9"/>{open&&suggestions.length>0&&<div className="icd-options">{suggestions.map(item=><button type="button" key={item.kode_icd} onMouseDown={e=>e.preventDefault()} onClick={()=>pick(item)}><strong>{item.kode_icd}</strong><span>{item.nama_icd_indo||item.nama_icd}</span><small>{item.nama_icd}</small></button>)}</div>}</div>
}
