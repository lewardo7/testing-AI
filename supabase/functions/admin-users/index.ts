import { createClient } from 'npm:@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  try {
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) throw new Error('Sesi tidak ditemukan');
    const url = Deno.env.get('SUPABASE_URL')!;
    const anon = Deno.env.get('SUPABASE_ANON_KEY')!;
    const serviceRole = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const userClient = createClient(url, anon, { global: { headers: { Authorization: authHeader } } });
    const { data: { user }, error: userError } = await userClient.auth.getUser();
    if (userError || !user) throw new Error('Sesi tidak valid');
    const adminClient = createClient(url, serviceRole);
    const { data: profile } = await adminClient.from('profiles').select('role,is_active').eq('id', user.id).single();
    if (profile?.role !== 'administrator' || !profile.is_active) throw new Error('Hanya administrator yang dapat membuat akun');

    const { email, password, full_name, role, department_id, employee_id } = await req.json();
    if (!email || !password || !full_name || !role) throw new Error('Nama, email, password, dan role wajib diisi');
    if (password.length < 8) throw new Error('Password minimal 8 karakter');
    const allowedRoles = ['administrator','author','reviewer','approver','viewer'];
    if (!allowedRoles.includes(role)) throw new Error('Role tidak valid');

    const { data: created, error: createError } = await adminClient.auth.admin.createUser({
      email: String(email).trim().toLowerCase(), password, email_confirm: true,
      user_metadata: { full_name: String(full_name).trim() },
    });
    if (createError) throw createError;
    const { error: profileError } = await adminClient.from('profiles').update({
      full_name: String(full_name).trim(), email: String(email).trim().toLowerCase(), role,
      department_id: department_id || null, employee_id: employee_id?.trim() || null, is_active: true,
    }).eq('id', created.user.id);
    if (profileError) { await adminClient.auth.admin.deleteUser(created.user.id); throw profileError; }
    return new Response(JSON.stringify({ id: created.user.id }), { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
  } catch (error) {
    return new Response(JSON.stringify({ error: error instanceof Error ? error.message : 'Gagal membuat akun' }), { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
  }
});
