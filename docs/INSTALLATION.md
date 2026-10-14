# Guide d'installation DoktaNet

## Prérequis
- Compte Neon (PostgreSQL), compte Cloudflare (Pages + R2), compte GitHub
- Node.js 18+, Flutter (canal stable)
- Clé Groq (assistant IA). Optionnel : clé Daily.co

## 1. Base de données (Neon)
1. Créer un projet Neon et copier la chaîne de connexion.
2. Copier `.dev.vars.example` en `.dev.vars` et renseigner `DATABASE_URL` et `JWT_SECRET`.
3. `npm install` puis `npm run db:setup` (schéma + données de test).
   - Base déjà créée avant la finalisation : exécuter `migration_final.sql`.
   - Sans données de test : `npm run db:schema`.

## 2. Stockage des ordonnances (R2)
Créer le bucket `doktanet-ordonnances`. Le binding `RX_BUCKET` est déclaré dans `wrangler.toml`.

## 3. Variables (Cloudflare Pages > Settings > Variables)
| Variable | Rôle |
|---|---|
| DATABASE_URL | Chaîne Neon |
| JWT_SECRET | Chaîne aléatoire longue (signe aussi les ordonnances) |
| GROQ_API_KEY, GROQ_MODEL | Assistant IA (défaut openai/gpt-oss-20b) |
| PAY_SANDBOX | 1 = paiement simulé. 0 = brancher PayGate/KKiaPay |
| PAY_WEBHOOK_SECRET | Secret du webhook de paiement |
| COMMISSION_PCT | Commission affichée dans les statistiques |
| REQUIRE_2FA | 1 = 2FA obligatoire pour médecins et admin |
| DAILY_API_KEY | Optionnel (sinon visio Jitsi) |

## 4. Test local
```
npm install
flutter pub get
flutter build web
npx wrangler pages dev build/web
```
Ouvrir http://localhost:8788. Comptes de test : mot de passe `Test1234!` (patient@, dr.kofi@, pharma.lome@, admin@ + `doktanet.test`).

## 5. Déploiement
Secrets GitHub : `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`. Un push sur `main` construit l'application et la déploie sur Cloudflare Pages.

## 6. Compte administrateur
Créer un compte patient, puis dans Neon :
`update users set role='admin', status='active' where email='VOTRE_EMAIL';`

## Mise en production
- `PAY_SANDBOX=0` et intégration du fournisseur de paiement (voir le TODO dans `POST /orders/:id/pay`).
- `REQUIRE_2FA=1`.
- Valider le cadre légal de la téléconsultation avec l'Ordre des Médecins et le Ministère de la Santé.
