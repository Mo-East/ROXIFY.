# Roxify — Manual Deployment Handover

## Project

Roxify is a React + Vite single-page application. The source export includes the homepage, Personal Engine, Corporate Engine, The Vault, PPN Model, Pricing, Dashboard demo, AI Concierge, browser voice agent, routing, CSS, and media assets.

This handover is for manual deployment by the human development team. No automated Cloudflare deployment or DNS change is being performed from this handover.

## Requirements

- Node.js 22 LTS or the current supported Node.js LTS
- npm 10 or newer
- A Cloudflare account with Workers & Pages access
- Access to the Namecheap account that controls `roxify.site`

## Install and build

From the repository root:

```bash
npm install
npm run build
```

For a reproducible installation from the committed lockfile, use:

```bash
npm ci
npm run build
```

The exact production output directory is:

```text
dist/
```

The build must produce `dist/index.html`. The project also copies the following deployment files into `dist/`:

```text
dist/_redirects
dist/manus-routes.json
```

The `_redirects` file preserves direct loading of SPA routes such as `/vault`, `/personal`, `/corporate`, `/partners`, and `/dashboard`.

## Local verification

Start the development server:

```bash
npm run dev
```

Open the displayed local URL and verify these routes:

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

To serve the production build locally:

```bash
npm run preview
```

## Environment variables

No environment variables are currently required. The application has no backend API, database, server route, OAuth integration, or runtime secret. The AI Concierge uses local React state and creates `mailto:` links. The Mercury experience is a demo and does not move funds. The voice agent uses the browser Web Speech API.

`.env.example` is included for future additions. Do not add API tokens or private credentials to Git, this ZIP, or the client bundle.

## Cloudflare Pages — dashboard deployment

1. Sign in to the Cloudflare account that will own the site.
2. Open **Workers & Pages** and choose **Create application** → **Pages**.
3. Choose **Upload assets** for a manual deployment.
4. Create a project named `roxify` or another final project name.
5. Run `npm ci && npm run build` locally.
6. Upload the contents of the local `dist/` directory, not the project source directory.
7. Open the generated `https://<project-name>.pages.dev` URL.
8. Test every route listed above by opening it directly and refreshing the page.

## Cloudflare Pages — Git deployment

Alternatively, connect the Git repository in **Workers & Pages** and use:

```text
Root directory: repository root
Build command: npm ci && npm run build
Build output directory: dist
Node.js version: 22 LTS or current supported LTS
```

Cloudflare Pages must use the repository root as the build working directory because `package.json` is at the root.

## Cloudflare Pages — Wrangler deployment

After authenticating Wrangler with the owner’s Cloudflare account:

```bash
npm ci
npm run build
npx wrangler pages project create roxify
npx wrangler pages deploy dist --project-name roxify
```

Use a temporary, account-restricted Cloudflare API token with **Account → Cloudflare Pages → Edit** only. Keep the token in a protected environment variable or CI secret and revoke it after deployment. Never put it in `HANDOVER.md`, `DNS_SETUP.md`, Git, or the ZIP.

## Application QA

Before changing DNS, test the temporary `pages.dev` deployment on desktop and mobile:

- Homepage design, video/poster assets, navigation, and mobile menu
- AI Concierge Personal and Corporate flows and generated mailto CTAs
- Personal Engine and Corporate Engine content, pricing, and CTA links
- Corporate link to The Vault
- The Vault cards, request CTA, and Dashboard demo link
- Dashboard demo interaction and “No funds are moved” disclaimer
- Browser voice controls, play/pause, cancellation, and waveform state
- Direct route loads and refreshes for every route
- Browser console for errors and missing assets
- HTTPS certificate and canonical-domain redirect behavior

## Rollback

Keep the existing Manus site available until the Cloudflare version passes QA. If the independent deployment fails, do not change DNS or remove the Manus version. Cloudflare Pages can redeploy the previous successful deployment or previous Git commit. Restore the prior DNS records from the exported Namecheap/Cloudflare zone if a DNS cutover has already occurred.

## Owner access checklist

The owner should retain independent access to:

- The Git repository
- The Cloudflare account and Pages project
- Cloudflare DNS and SSL settings
- The Namecheap registrar account and domain renewal settings
- The email provider represented by existing MX/TXT records
- The source ZIP and production backup ZIP

## Included files

- `package.json` and `package-lock.json`
- `src/`
- `public/`
- `public/media/`
- `vite.config.js`
- `wrangler.toml`
- `.env.example`
- `public/_redirects`
- `public/manus-routes.json`
- `HANDOVER.md`
- `DNS_SETUP.md`
