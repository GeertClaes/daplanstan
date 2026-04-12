# DaPlanStan — Self-Hosted Setup Guide

This guide covers everything you need to run DaPlanStan in production on your own server:
a Cloudflare tunnel, Postmark inbound email, Google and Apple OAuth, and PWA installation.

> **Recommended setup:** DaPlanStan runs beautifully on [Omarchy](https://omarchy.org) —
> an opinionated, batteries-included Linux environment built for Ruby on Rails developers.
> If you're starting fresh, Omarchy gives you a fully configured Rails-ready machine in minutes.
> That said, any Linux server with Ruby 3.3+ will work fine.

---

## Why Ruby on Rails?

DaPlanStan is built on [Ruby on Rails 8](https://rubyonrails.org) — the full-stack web framework
that has been quietly powering some of the most productive apps on the internet for over 20 years.

No microservices. No separate frontend framework. No Dockerfile maze. One process, one SQLite
database, Hotwire for reactive UI — and it runs comfortably on a $6/month VPS. Rails 8 makes
self-hosting genuinely pleasant. If you've never used Rails before, this is a great first app to
explore it with.

---

## Architecture overview

```
Browser / mobile
    │
    ├── yourdomain.com          → marketing page (GitHub Pages, optional)
    └── app.yourdomain.com      → DaPlanStan app (requires sign-in)
              │
        Cloudflare Tunnel
              │
        Rails app on localhost:3000
              │
        app.yourdomain.com ← Postmark inbound webhook
```

> **Subdomain choice:** You can use any subdomain for the app — `app.`, `plan.`, `whats.`,
> whatever fits. The examples below use `app.yourdomain.com`.

---

## 1. DNS records (Cloudflare)

All records managed in the Cloudflare dashboard. Set proxy status to **Proxied** (orange cloud).

| Type | Name | Content | Notes |
|------|------|---------|-------|
| CNAME | `yourdomain.com` | `<tunnel-id>.cfargotunnel.com` | Marketing / root |
| CNAME | `www` | `<tunnel-id>.cfargotunnel.com` | www redirect |
| CNAME | `app` | `<tunnel-id>.cfargotunnel.com` | App subdomain |
| MX | `app` | `inbound.postmarkapp.com` | Inbound email (priority 10) |
| TXT | `app` | `v=spf1 include:spf.mtasv.net ~all` | SPF for Postmark |

Replace `<tunnel-id>` with your tunnel UUID (visible in `~/.cloudflared/config.yaml`).

---

## 2. Cloudflare Tunnel

### Install and authenticate
```bash
# Install cloudflared
curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared.deb

# Authenticate (opens browser)
cloudflared tunnel login

# Create tunnel
cloudflared tunnel create my-tunnel
```

### Config file (`~/.cloudflared/config.yaml`)
```yaml
tunnel: <tunnel-id>
credentials-file: /home/<user>/.cloudflared/<tunnel-id>.json

ingress:
  - hostname: yourdomain.com
    service: http://127.0.0.1:3000
  - hostname: www.yourdomain.com
    service: http://127.0.0.1:3000
  - hostname: app.yourdomain.com
    service: http://127.0.0.1:3000
  - service: http_status:404
```

### Run as a service
```bash
sudo cloudflared service install
sudo systemctl enable cloudflared
sudo systemctl start cloudflared
```

### Zero Trust — bypass ActionMailbox webhook
If you have a Cloudflare Access application protecting your domain, Postmark's servers
will be blocked (returns 403). Add a bypass rule:

1. Cloudflare dashboard → **Zero Trust → Access → Applications**
2. Open the application for `yourdomain.com`
3. Add a policy: **Action = Bypass**, **Selector = Path**, **Value = `/rails/action_mailbox/*`**

This lets Postmark POST to the inbound webhook without a session cookie.
The endpoint has its own password-based authentication so it is not left open.

---

## 3. Postmark — inbound email

### Create a server
1. Log in to [postmark.com](https://postmarkapp.com) → **Servers → Add server**
2. Name it (e.g. "DaPlanStan production")
3. Note your **API token** — add it to `.env` as `POSTMARK_API_TOKEN`

### Configure sending
- **From email**: set `POSTMARK_FROM_EMAIL` (e.g. `noreply@yourdomain.com`)
- **Reply-to**: set `POSTMARK_REPLY_TO` (e.g. `hey@yourdomain.com`)
- Add and verify your sending domain in Postmark → **Sender Signatures**
- Add the DKIM TXT record Postmark shows you to Cloudflare DNS

### Configure inbound email
1. Postmark → your server → **Settings → Inbound**
2. Set **Inbound domain**: `app.yourdomain.com`
3. Set **Webhook URL** (with embedded credentials):
   ```
   https://actionmailbox:<RAILS_INBOUND_EMAIL_PASSWORD>@app.yourdomain.com/rails/action_mailbox/postmark/inbound_emails
   ```
   Replace `<RAILS_INBOUND_EMAIL_PASSWORD>` with the value from your `.env`.
4. Click **Check** — you should receive a **200** response.
5. Set **Inbound stream**: Default Inbound Stream

### How inbound email works
- Each trip gets a unique inbound address: `puglia-<token>@app.yourdomain.com`
- Forward booking confirmation emails to that address
- Only **approved senders** are auto-processed; others land in the inbox for review
- Postmark parses the email and POSTs it to the Rails webhook
- `TripMailbox` routes it, `ParseInboxItemJob` calls Claude Haiku to extract structured data
- Parsed data is stored but **not yet added to the trip** — the user reviews and clicks "Add to trip"
- "Add to trip" creates TripItems and Expenses; the trip page updates live via Turbo Streams

### Generate the inbound password
```bash
rails secret | head -c 32   # or any random 32-char string
```
Add it to `.env` as `RAILS_INBOUND_EMAIL_PASSWORD`.

---

## 4. Google OAuth

1. Go to [console.cloud.google.com](https://console.cloud.google.com)
2. Create a project (or use an existing one)
3. **APIs & Services → OAuth consent screen**
   - User type: External
   - App name, support email, developer email
   - Scopes: `email`, `profile`, `openid`
4. **APIs & Services → Credentials → Create credentials → OAuth Client ID**
   - Application type: **Web application**
   - Authorised JavaScript origins:
     ```
     https://app.yourdomain.com
     ```
   - Authorised redirect URIs:
     ```
     https://app.yourdomain.com/auth/google_oauth2/callback
     ```
5. Copy **Client ID** → `GOOGLE_CLIENT_ID` in `.env`
6. Copy **Client secret** → `GOOGLE_CLIENT_SECRET` in `.env`

---

## 5. Apple Sign In

1. Go to [developer.apple.com](https://developer.apple.com) → **Certificates, IDs & Profiles**
2. **Identifiers → App IDs** — register an App ID with Sign In with Apple enabled
3. **Identifiers → Services IDs** — register a Services ID
   - Description: DaPlanStan
   - Identifier: `com.yourdomain.app` (or your chosen bundle ID) → `APPLE_CLIENT_ID`
   - Enable Sign In with Apple → Configure
   - Domains: `app.yourdomain.com`
   - Return URLs: `https://app.yourdomain.com/auth/apple/callback`
4. **Keys** — create a key with Sign In with Apple enabled
   - Download the `.p8` file
   - Note the **Key ID** → `APPLE_KEY_ID`
5. Note your **Team ID** (top right of developer portal) → `APPLE_TEAM_ID`
6. Set `APPLE_PRIVATE_KEY` to the contents of the `.p8` file (newlines as `\n`)

---

## 6. Claude API (Anthropic)

Used for parsing forwarded booking emails.

1. Sign up at [console.anthropic.com](https://console.anthropic.com)
2. Create an API key → `ANTHROPIC_API_KEY` in `.env`
3. DaPlanStan uses **Claude Haiku** (fast and cheap) for all parsing jobs — typical cost is
   fractions of a cent per email

---

## 7. Environment variables reference

Copy `.env.example` to `.env` and fill in all values.

```
# Anthropic
ANTHROPIC_API_KEY=sk-ant-...

# Google OAuth
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=

# Apple Sign In
APPLE_CLIENT_ID=com.yourdomain.app
APPLE_TEAM_ID=
APPLE_KEY_ID=
APPLE_PRIVATE_KEY=

# Postmark
POSTMARK_API_TOKEN=
POSTMARK_FROM_EMAIL=noreply@yourdomain.com
POSTMARK_REPLY_TO=hey@yourdomain.com

# ActionMailbox
TRIP_EMAIL_DOMAIN=app.yourdomain.com
RAILS_INBOUND_EMAIL_PASSWORD=

# Rails
RAILS_MASTER_KEY=                          # from config/master.key — never commit this

# Active Record Encryption (generate with: bin/rails db:encryption:init)
ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=
ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=
ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT=
```

---

## 8. First run

```bash
# Clone and install
git clone https://github.com/GeertClaes/daplanstan.git
cd daplanstan
bundle install

# Download DaisyUI plugin (gitignored — re-run after every fresh clone)
mkdir -p app/assets/tailwind/plugins
curl -sL -o app/assets/tailwind/plugins/daisyui.js https://cdn.jsdelivr.net/npm/daisyui@5/+esm

# Copy and fill in environment variables
cp .env.example .env
# edit .env with your values

# Generate encryption keys (paste output into .env)
bin/rails db:encryption:init

# Set up database
bin/rails db:create db:migrate db:seed

# Start the app
bin/dev

# Start the Cloudflare tunnel (separate terminal or as a service)
cloudflared tunnel run my-tunnel
```

---

## 9. Adding the app to your home screen (PWA)

DaPlanStan is a Progressive Web App — install it directly from the browser, no app store needed.

### iPhone / iPad (Safari)
1. Open **Safari** and go to `https://app.yourdomain.com`
2. Tap the **Share** button (box with arrow pointing up)
3. Tap **Add to Home Screen** → confirm and tap **Add**

The app opens full-screen with no browser chrome, just like a native app.

### Android (Chrome)
1. Open **Chrome** and go to `https://app.yourdomain.com`
2. Tap the **three-dot menu** (⋮) → **Add to Home screen** (or **Install app**)
3. Confirm and tap **Add**

### Android (Samsung Internet)
1. Tap the **menu icon** → **Add page to** → **Home screen**

> **Note:** HTTPS is required for PWA install — handled automatically by Cloudflare.
> On iOS, only Safari supports Add to Home Screen.

---

## 10. Ongoing maintenance

```bash
# View logs
tail -f log/production.log

# Update to latest
git pull && bundle install && bin/rails db:migrate && touch tmp/restart.txt

# Backup the database
cp storage/production.sqlite3 backups/$(date +%Y%m%d).sqlite3
```

- **Failed email parses**: check the Inbox tab inside the trip — failed items show a retry button
- **Database**: SQLite lives at `storage/production.sqlite3` — back it up regularly

---

## Built with ❤️ on Ruby on Rails

DaPlanStan exists because Rails makes building and self-hosting a full-featured web app
genuinely enjoyable. If this project inspires you to build something of your own,
[rubyonrails.org](https://rubyonrails.org) is the place to start — and
[Omarchy](https://omarchy.org) will have your dev environment ready in minutes.
