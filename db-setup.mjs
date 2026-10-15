// Usage : node db-setup.mjs [schema] [seed] [--dry]   (sans argument : schema puis seed)
// Migrations : on préfère DATABASE_URL_UNPOOLED (connexion directe), sinon DATABASE_URL.
import { readFileSync, existsSync } from 'node:fs';
import { neon } from '@neondatabase/serverless';

function fromFile(file, key) {
  if (!existsSync(file)) return undefined;
  const m = readFileSync(file, 'utf8').match(new RegExp(`^${key}=(.+)$`, 'm'));
  return m ? m[1].trim().replace(/^["']|["']$/g, '') : undefined;
}
const files0 = ['.env.local', '.env', '.dev.vars'];
const pick = (key) => process.env[key] || files0.map((f) => fromFile(f, key)).find(Boolean);
const url = pick('DATABASE_URL_UNPOOLED') || pick('DATABASE_URL');

const dry = process.argv.includes('--dry');
if (!url && !dry) {
  console.error("DATABASE_URL manquant : lancer `neon env pull` (écrit .env.local) ou renseigner .dev.vars");
  process.exit(1);
}

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
