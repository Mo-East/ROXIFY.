# Roxify → Cloudflare Integration Plan

## Goal

Deploy the Roxify website independently on Cloudflare Pages and connect `roxify.site` without interrupting email or deleting existing DNS records.

The website is a static React + Vite application. It does not currently require a backend, database, Manus API, or runtime environment variables.

## Phase 1 — Prepare the project

1. Download and extract the Roxify source ZIP.
2. Open a terminal in the project root.
3. Confirm Node.js and npm are installed:

```bash
node --version
npm --version
```

Use Node.js 22 LTS or the current supported Node.js LTS.

4. Install dependencies and create a production build:

```bash
npm ci
npm run build
```

5. Confirm that the build creates:

```text
dist/index.html
dist/_redirects
dist/manus-routes.json
```

Do not upload the source directory directly to Cloudflare Pages. Cloudflare must receive the contents of `dist/` for a manual upload.

## Phase 2 — Create the Cloudflare Pages project

Use one of these deployment methods.

### Recommended: Cloudflare dashboard upload

1. Sign in to the owner’s Cloudflare account.
2. Open **Workers & Pages**.
3. Select **Create application** → **Pages**.
4. Choose **Upload assets**.
5. Create the project with the name `roxify`.
6. Upload the contents of the locally generated `dist/` directory.
7. Open the generated `https://<project-name>.pages.dev` address.

### Git-connected deployment

If the source is stored in GitHub or another supported Git provider, connect the repository and use:

```text
Root directory: repository root
Build command: npm ci && npm run build
Build output directory: dist
Node version: 22 LTS or current supported LTS
```

### Wrangler deployment

If the developer prefers the CLI:

```bash
npm ci
npm run build
npx wrangler pages project create roxify
npx wrangler pages deploy dist --project-name roxify
```

Use a temporary Cloudflare API token restricted to the correct account with **Account → Cloudflare Pages → Edit**. Keep it in a secure environment variable or CI secret. Never place it in Git, the ZIP, or any website file. Revoke the token after deployment.

## Phase 3 — Test the temporary Pages site

Before changing DNS, test the `pages.dev` URL on desktop and mobile.

Open each route directly:

```text
/
/vault
/personal
/corporate
/partners
/pricing
/dashboard
/privacy
/terms
```

Confirm that:

- The homepage and mobile navigation work.
- The Personal and Corporate pages render correctly.
- The Vault PPN section appears above the final CTA.
- The voice-agent controls work where the browser supports Web Speech API.
- The Dashboard moves from Connect to Identity Verification, shows the two KYC fields, displays the two-second inline loading state, and then opens The Vault.
- AI Concierge paths and mailto CTAs work.
- Direct route refreshes do not produce a 404.
- There are no missing images, video files, JavaScript errors, or CSS errors.
- The demo disclaimer remains visible and no real funds are moved.

Do not connect the domain until this test passes.

## Phase 4 — Add the custom domain in Cloudflare

1. In Cloudflare, open **Workers & Pages** → the `roxify` project.
2. Open **Custom domains**.
3. Select **Set up a domain**.
4. Add:

```text
roxify.site
```

5. Add `www.roxify.site` as a second custom domain if both hostnames will be supported.

Cloudflare must know about the custom domain in Pages before relying on DNS records. Adding a DNS record alone is not sufficient.

## Phase 5 — Configure DNS at Namecheap

### Apex domain: `roxify.site`

Cloudflare Pages does not provide one universal fixed A-record IP. Do not invent an A record or point the apex domain to an arbitrary address.

For the recommended setup:

1. In Cloudflare, add `roxify.site` as a zone.
2. Copy every existing Namecheap DNS record into Cloudflare before changing nameservers.
3. Pay special attention to MX, SPF, DKIM, DMARC, verification TXT, and mail-related records.
4. Cloudflare will assign two authoritative nameservers.
5. In Namecheap → **Domain List** → **Manage** → **Nameservers**, choose **Custom DNS**.
6. Enter the two nameservers assigned by Cloudflare exactly.
7. Save and wait for Cloudflare to show the zone as active.

The apex setup is therefore:

```text
A record for @: none required for the recommended Cloudflare Pages zone setup
Action: delegate nameservers to Cloudflare’s assigned nameservers
```

### `www.roxify.site`

After the Pages project has been created, Cloudflare will show the actual Pages hostname. The usual record is:

```text
Type: CNAME
Name: www
Target: <actual-project-name>.pages.dev
TTL: Auto
```

Replace `<actual-project-name>.pages.dev` with the exact hostname shown by Cloudflare. Do not guess this value.

## Phase 6 — Configure HTTPS and canonical redirects

1. Wait until Cloudflare reports the custom domain as active.
2. Confirm both URLs load over HTTPS:

```text
https://roxify.site
https://www.roxify.site
```

3. Choose one canonical hostname. Recommended:

```text
Canonical: https://roxify.site
Redirect: https://www.roxify.site → https://roxify.site
```

4. Configure the redirect in Cloudflare Redirect Rules.
5. Do not configure redirects in both directions.
6. Confirm there are no certificate warnings or redirect loops.

## Phase 7 — Protect email

Changing nameservers moves DNS authority from Namecheap to Cloudflare. Website records do not automatically preserve email records.

Before switching nameservers, recreate these records in Cloudflare exactly:

```text
MX
SPF TXT
DKIM TXT or CNAME
DMARC TXT
Email verification TXT/CNAME
Other business-critical records
```

Do not proxy MX records. After the DNS change, send a test email to and from the business mailbox.

## Phase 8 — Final acceptance test

After HTTPS and DNS are active:

1. Test `https://roxify.site` on desktop and mobile.
2. Test the `www` hostname and canonical redirect.
3. Refresh every application route directly.
4. Test the AI Concierge Personal and Corporate paths.
5. Test the Vault CTA and all mailto links.
6. Test the Dashboard KYC flow.
7. Test voice controls in a supported browser.
8. Test email delivery in both directions.
9. Check the browser console for errors.
10. Confirm all media assets load over HTTPS.

## Rollback plan

Keep the previous Manus deployment available during DNS propagation.

If the Cloudflare site fails:

1. Do not delete the Pages project.
2. Disable or remove the Pages custom-domain mapping only if necessary.
3. Restore the previous Namecheap nameservers or DNS records from the saved zone export.
4. Confirm MX/TXT records and email delivery.
5. Redeploy the last known-good Cloudflare Pages deployment or Git commit.

## Owner access to retain

The owner must retain access to:

- The source-code repository
- The Cloudflare account and Pages project
- Cloudflare DNS and SSL settings
- The Namecheap registrar account
- The email provider account
- The original source ZIP and backup ZIP

## Important security rule

Never put Cloudflare API tokens, Namecheap passwords, email passwords, or private DNS credentials in the repository, the ZIP file, `HANDOVER.md`, `DNS_SETUP.md`, or this plan.
