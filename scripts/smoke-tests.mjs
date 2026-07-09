import { readFileSync, existsSync } from 'node:fs';

const checks = [
  ['src/App.tsx', 'Login', 'komponen login tersedia'],
  ['src/App.tsx', 'DashboardLive', 'dashboard data aktif tersedia'],
  ['src/App.tsx', 'LibraryLive', 'library pathway tersedia'],
  ['src/App.tsx', 'Approval', 'approval queue tersedia'],
  ['src/App.tsx', 'UsersPage', 'users and roles tersedia'],
  ['src/App.tsx', 'SettingsPage', 'settings tersedia'],
  ['src/App.tsx', 'exportPathwayPdf', 'PDF export tersedia'],
  ['src/lib/api.ts', 'resetPassword', 'reset password tersedia'],
  ['src/lib/api.ts', 'getDashboardData', 'API dashboard tersedia'],
  ['src/lib/api.ts', 'updateAppSettings', 'API settings tersedia'],
  ['src/PathwayHistoryComments.tsx', 'uploadPathwayAttachment', 'attachment tersedia'],
  ['supabase/migrations/202607080001_complete_approval_workflow.sql', 'decide_approval', 'workflow approval database tersedia'],
  ['supabase/migrations/202607090002_app_settings.sql', 'app_settings', 'migration settings tersedia'],
];

const failures = [];
for (const [file, needle, label] of checks) {
  if (!existsSync(file)) {
    failures.push(`${label}: file ${file} tidak ditemukan`);
    continue;
  }
  const content = readFileSync(file, 'utf8');
  if (!content.includes(needle)) failures.push(`${label}: "${needle}" tidak ditemukan di ${file}`);
}

if (failures.length) {
  console.error('Smoke test gagal:');
  for (const failure of failures) console.error(`- ${failure}`);
  process.exit(1);
}

console.log(`Smoke test berhasil: ${checks.length} pemeriksaan utama lolos.`);
