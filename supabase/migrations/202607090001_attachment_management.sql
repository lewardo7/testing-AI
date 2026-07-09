create policy "delete own attachments"
on public.attachments
for delete
to authenticated
using (uploaded_by = auth.uid() or public.current_role() = 'administrator');

create policy "admin delete attachment files"
on storage.objects
for delete
to authenticated
using (bucket_id = 'pathway-attachments' and public.current_role() = 'administrator');
