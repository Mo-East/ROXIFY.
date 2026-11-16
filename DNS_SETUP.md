# Roxify — DNS and SSL Setup

## Important limitation about “exact” records

Cloudflare Pages does **not** provide one universal fixed A-record IP for every Pages project. The exact Pages hostname and the two Cloudflare nameservers are assigned only after the developer creates the Cloudflare Pages project and adds the custom domain. Do not invent A records and do not point the apex domain at an arbitrary IP.

For the apex domain `roxify.site`, the recommended and supported setup is to use Cloudflare as the authoritative DNS provider. Cloudflare will assign the nameservers. For `www.roxify.site`, Cloudflare Pages normally uses a CNAME to the project’s actual `pages.dev` hostname.

## Before changing Namecheap

1. Sign in to Namecheap and export or record the current DNS zone.
2. Inventory every existing record, especially MX, SPF, DKIM, DMARC, verification TXT, and other mail or subdomain records.
3. Do not delete or modify email records during the website migration.
4. Create the Cloudflare Pages project and add the custom domain in Cloudflare before changing nameservers.

## Recommended apex setup — `roxify.site`

In Cloudflare:

1. Add `roxify.site` as a Cloudflare zone on the same Cloudflare account that owns the Pages project.
2. Add the existing DNS records from Namecheap to the Cloudflare DNS zone. Recreate all MX and TXT records exactly before changing nameservers.
3. In Cloudflare Pages → `roxify` → **Custom domains**, select **Set up a domain** and enter `roxify.site`.
4. Cloudflare will display two assigned authoritative nameservers. They will look like two unique Cloudflare hostnames; they cannot be known in advance.
5. In Namecheap → Domain List → Manage → Nameservers, choose **Custom DNS** and enter exactly the two nameservers shown by Cloudflare.
6. Save the change and wait for Cloudflare to show the zone as **Active**.
7. Confirm Cloudflare HTTPS/SSL is active before redirecting traffic.

The apex record is therefore:

```text
Type: No manual A record required for the recommended Pages apex setup
Hostname: roxify.site / @
Action: Delegate authoritative nameservers to the two nameservers assigned by Cloudflare
```

## `www.roxify.site` CNAME

After the Pages project exists, Cloudflare will show its actual Pages hostname. Replace the placeholder below with that exact hostname:

```text
Type: CNAME
Name: www
Target: <actual-project-name>.pages.dev
TTL: Auto
Proxy: Proxied if Cloudflare manages the zone
```

The developer must first associate `www.roxify.site` with the Pages project under **Pages → Custom domains**. Do not only create a CNAME and skip the Pages custom-domain association.

## Canonical hostname

Choose one canonical hostname. Recommended:

```text
Canonical: https://roxify.site
Redirect: https://www.roxify.site/* → https://roxify.site/:splat
```

The developer can configure the redirect in Cloudflare Redirect Rules after both custom domains are active. If the owner prefers `www` as canonical, reverse the direction instead. Do not configure both directions.

## Email protection

Changing Namecheap nameservers transfers DNS authority to Cloudflare. Email will continue only if the existing email records are copied into Cloudflare first. Preserve:

```text
MX records
SPF TXT records
DKIM TXT or CNAME records
DMARC TXT record
Email provider verification records
Other business-critical TXT records
```

Website CNAME or HTTPS changes must not replace MX or TXT records. Never proxy MX records. Use the email provider’s required DNS values exactly.

## SSL and verification

1. Wait for the Cloudflare zone to become active.
2. Add both apex and `www` under Cloudflare Pages custom domains.
3. Confirm both HTTPS URLs load without certificate warnings.
4. Confirm the preferred canonical redirect returns the expected 301/308 behavior.
5. Test mail delivery in both directions after the DNS change.
6. Check `https://roxify.site/manus-routes.json` and all application routes after propagation.

## DNS propagation and rollback

Namecheap notes that nameserver changes can take up to 24–48 hours in some environments. Keep the previous deployment available during propagation. For rollback, restore the previous Namecheap nameservers or previous DNS records from the saved zone export, then verify MX/TXT records and email delivery.

## No token included

This document contains no Cloudflare API token, Namecheap password, DNS secret, or private credential. Keep those in the owner’s password manager or protected Cloudflare/CI secret store.

## Official references

- Cloudflare Pages custom domains: https://developers.cloudflare.com/pages/configuration/custom-domains/
- Cloudflare Pages redirects: https://developers.cloudflare.com/pages/configuration/redirects/
- Namecheap DNS and Cloudflare nameservers: https://www.namecheap.com/support/knowledgebase/article.aspx/9607/2210/how-to-set-up-dns-records-for-your-domain-in-a-cloudflare-account/
