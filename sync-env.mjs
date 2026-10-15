// Copie DATABASE_URL (pooled, pour l'API) de .env.local / .env vers .dev.vars (lu par `wrangler pages dev`).
import { readFileSync, writeFileSync, existsSync } from 'node:fs';

const read = (f) => (existsSync(f) ? readFileSync(f, 'utf8') : '');
const get = (txt, k) => (txt.match(new RegExp(`^${k}=(.+)$`, 'm')) || [])[1]?.trim().replace(/^["']|["']$/g, '');
const src = get(read('.env.local'), 'DATABASE_URL') || get(read('.env'), 'DATABASE_URL');
if (!src) { console.log('sync-env : aucun DATABASE_URL dans .env.local / .env (lancer `neon env pull`)'); process.exit(0); }

let dev = read('.dev.vars') || read('.dev.vars.example');
dev = /^DATABASE_URL=.*$/m.test(dev) ? dev.replace(/^DATABASE_URL=.*$/m, `DATABASE_URL=${src}`) : `DATABASE_URL=${src}\n${dev}`;
writeFileSync('.dev.vars', dev);
console.log('sync-env : DATABASE_URL écrit dans .dev.vars');
