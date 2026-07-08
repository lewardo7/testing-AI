create or replace function public.protect_profile_privileges() returns trigger language plpgsql as $$
begin
  if (new.role is distinct from old.role or new.is_active is distinct from old.is_active)
     and auth.role() <> 'service_role'
     and coalesce(public.current_role() = 'administrator', false) = false then
    raise exception 'Only administrators can change role or active status';
  end if;
  return new;
end $$;
