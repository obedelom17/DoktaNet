// Usage : node db-setup.mjs [schema] [seed]   (sans argument : schema puis seed)
import { readFileSync, existsSync } from 'node:fs';
import { neon } from '@neondatabase/serverless';

let url = process.env.DATABASE_URL;
if (!url && existsSync('.dev.vars')) {
  const m = readFileSync('.dev.vars', 'utf8').match(/^DATABASE_URL=(.+)$/m);
  if (m) url = m[1].trim();
}
const dry = process.argv.includes('--dry');
if (!url && !dry) { console.error('DATABASE_URL manquant (variable d\'environnement ou .dev.vars)'); process.exit(1); }

const steps = process.argv.slice(2).filter((a) => !a.startsWith('--'));
const files = (steps.length ? steps : ['schema', 'seed']).map((s) => `${s}.sql`);
const sql = dry ? null : neon(url);

for (const f of files) {
  const statements = readFileSync(f, 'utf8')
    .split(/;\s*\n/)
    .map((s) => s.split('\n').filter((l) => !l.trim().startsWith('--')).join('\n').trim())
    .filter(Boolean);
  console.log(`${f} : ${statements.length} requêtes`);
  if (dry) continue;
  for (const st of statements) {
    try { await sql.query(st); }
    catch (e) { console.error(`Erreur dans ${f} :\n${st.slice(0, 160)}...\n${e.message}`); process.exit(1); }
  }
}
console.log('Terminé.');
