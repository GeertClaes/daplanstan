# Daplanstan — Self-Hosted Setup Guide

This guide covers everything you need to configure to run Daplanstan in production:
a Cloudflare tunnel, Postmark inbound email, Google and Apple OAuth, and PWA installation.

---

## Architecture overview

```
Browser / mobile
    │
    ├── daplanstan.com          → marketing page (public)
    └── whats.daplanstan.com    → app (requires sign-in)
              │
        Cloudflare Tunnel
              │
        Rails app on localhost:3000
              │
        whats.daplanstan.com ← Postmark inbound webhook
```

---

## 1. DNS records (Cloudflare)

All records managed in the Cloudflare dashboard. Set proxy status to **Proxied** (orange cloud) for everything.

| Type | Name | Content | Notes |
|------|------|---------|-------|
| CNAME | `daplanstan.com` | `<tunnel-id>.cfargotunnel.com` | Marketing |
| CNAME | `www` | `<tunnel-id>.cfargotunnel.com` | www redirect |
| CNAME | `whats` | `<tunnel-id>.cfargotunnel.com` | App subdomain |
| MX | `whats` | `inbound.postmarkapp.com` | Inbound email (priority 10) |
| TXT | `whats` | `v=spf1 include:spf.mtasv.net ~all` | SPF for Postmark |

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
cloudflared tunnel create dev-tunnel
```

### Config file (`~/.cloudflared/config.yaml`)
```yaml
tunnel: <tunnel-id>
credentials-file: /home/<user>/.cloudflared/<tunnel-id>.json

ingress:
  - hostname: daplanstan.com
    service: http://127.0.0.1:3000
  - hostname: www.daplanstan.com
    service: http://127.0.0.1:3000
  - hostname: whats.daplanstan.com
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
2. Open the application for `daplanstan.com`
3. Add a policy: **Action = Bypass**, **Selector = Path**, **Value = `/rails/action_mailbox/*`**

This lets Postmark POST to the inbound webhook without a session cookie.
The endpoint has its own password-based authentication so it is not left open.

---

## 3. Postmark — inbound email

### Create a server
1. Log in to [postmark.com](https://postmarkapp.com) → **Servers → Add server**
2. Name it (e.g. "Daplanstan production")
3. Note your **API token** — add it to `.env` as `POSTMARK_API_TOKEN`

### Configure sending
- **From email**: set `POSTMARK_FROM_EMAIL` (e.g. `noreply@daplanstan.com`)
- **Reply-to**: set `POSTMARK_REPLY_TO` (e.g. `hey@daplanstan.com`)
- Add and verify your sending domain in Postmark → **Sender Signatures**
- Add the DKIM TXT record Postmark shows you to Cloudflare DNS

### Configure inbound email
1. Postmark → your server → **Settings → Inbound**
2. Set **Inbound domain**: `whats.daplanstan.com`
3. Set **Webhook URL** (with embedded credentials):
   ```
   https://actionmailbox:<RAILS_INBOUND_EMAIL_PASSWORD>@whats.daplanstan.com/rails/action_mailbox/postmark/inbound_emails
   ```
   Replace `<RAILS_INBOUND_EMAIL_PASSWORD>` with the value from your `.env`.
4. Click **Check** — you should receive a **200** response.
5. Set **Inbound stream**: Default Inbound Stream

### How inbound email works
- Each trip gets a unique inbound address: `puglia-<token>@whats.daplanstan.com`
- Forward booking confirmation emails to that address
- Only **approved senders** are auto-processed; others land in the inbox for review
- Postmark parses the email and POSTs it to the Rails webhook
- `TripMailbox` routes it, `ParseInboxItemJob` calls Claude Haiku to extract structured data
- Parsed data is stored but **not yet added to the trip** — the user reviews the email and clicks "Add to trip"
- "Add to trip" calls `InboxItem#confirm_and_create_items!` which creates TripItems and Expenses
- The trip page receives a live update via Turbo Streams (`broadcasts_refreshes_to :trip`) when a new email arrives

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
     https://whats.daplanstan.com
     ```
   - Authorised redirect URIs:
     ```
     https://whats.daplanstan.com/auth/google_oauth2/callback
     ```
5. Copy **Client ID** → `GOOGLE_CLIENT_ID` in `.env`
6. Copy **Client secret** → `GOOGLE_CLIENT_SECRET` in `.env`

---

## 5. Apple Sign In

1. Go to [developer.apple.com](https://developer.apple.com) → **Certificates, IDs & Profiles**
2. **Identifiers → App IDs** — register an App ID with Sign In with Apple enabled
3. **Identifiers → Services IDs** — register a Services ID
   - Description: Daplanstan
   - Identifier: `com.daplanstan.web` (or your chosen bundle ID) → `APPLE_CLIENT_ID`
   - Enable Sign In with Apple → Configure
   - Domains: `whats.daplanstan.com`
   - Return URLs: `https://whats.daplanstan.com/auth/apple/callback`
4. **Keys** — create a key with Sign In with Apple enabled
   - Download the `.p8` file
   - Note the **Key ID** → `APPLE_KEY_ID`
5. Note your **Team ID** (top right of developer portal) → `APPLE_TEAM_ID`
6. Set `APPLE_PRIVATE_KEY` to the contents of the `.p8` file (newlines as `\n`)

---

## 6. Claude API (Anthropic)

Used for parsing forwarded booking emails and receipts.

1. Sign up at [console.anthropic.com](https://console.anthropic.com)
2. Create an API key → `ANTHROPIC_API_KEY` in `.env`
3. The app uses **Claude Haiku** (fast and cheap) for all parsing jobs

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
APPLE_CLIENT_ID=com.daplanstan.web
APPLE_TEAM_ID=
APPLE_KEY_ID=
APPLE_PRIVATE_KEY=

# Postmark
POSTMARK_API_TOKEN=
POSTMARK_FROM_EMAIL=noreply@daplanstan.com
POSTMARK_REPLY_TO=hey@daplanstan.com

# ActionMailbox
TRIP_EMAIL_DOMAIN=whats.daplanstan.com
RAILS_INBOUND_EMAIL_PASSWORD=

# Rails
RAILS_MASTER_KEY=                          # from config/master.key — never commit this

# Active Record Encryption (generate with: rails db:encryption:init)
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

# Download DaisyUI (gitignored)
mkdir -p app/assets/tailwind/plugins
curl -sL -o app/assets/tailwind/plugins/daisyui.js https://cdn.jsdelivr.net/npm/daisyui@5/+esm

# Copy and fill in environment variables
cp .env.example .env
# edit .env with your values

# Generate encryption keys (paste output into .env)
bin/rails db:encryption:init

# Set up database
bin/rails db:create db:migrate

# Start the app
bin/rails server

# Start the Cloudflare tunnel (separate terminal or as a service)
cloudflared tunnel run dev-tunnel
```

---

## 9. Adding the app to your home screen (PWA)

Daplanstan is a Progressive Web App — install it directly without going through an app store.

### iPhone / iPad (Safari)
1. Open **Safari** and go to `https://whats.daplanstan.com`
2. Tap the **Share** button (box with arrow pointing up)
3. Scroll down and tap **Add to Home Screen**
4. Confirm the name and tap **Add**

The app icon will appear on your home screen and the app opens full-screen with no browser chrome.

### Android (Chrome)
1. Open **Chrome** and go to `https://whats.daplanstan.com`
2. Tap the **three-dot menu** (⋮) in the top right
3. Tap **Add to Home screen** (or **Install app** if Chrome shows a banner automatically)
4. Confirm and tap **Add**

### Android (Samsung Internet)
1. Open the page and tap the **menu icon**
2. Tap **Add page to** → **Home screen**

> **Note:** The app must be served over HTTPS (handled by Cloudflare) for PWA install to work.
> On iOS, only Safari supports Add to Home Screen — Chrome and Firefox on iOS do not.

---

## 10. Ongoing maintenance

- **Logs**: `tail -f log/development.log` (or `production.log`)
- **Failed email parses**: check the Inbox tab inside the trip — failed items show a retry button
- **Database backups**: `cp storage/development.sqlite3 backups/$(date +%Y%m%d).sqlite3`
- **Updating**: `git pull && bundle install && bin/rails db:migrate && touch tmp/restart.txt`
