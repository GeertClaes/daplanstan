# DaPlanStan

> **What's the plan, Stan?**

A self-hosted, open source trip planning app built with Ruby on Rails 8.1 — for families and friends who actually travel together.

One shared space for your whole group: forward booking confirmation emails and let AI parse them, pin places on an interactive map, track what everyone spends, and keep the whole itinerary in sync.

🌐 [daplanstan.com](https://daplanstan.com) · 📖 [Setup guide](docs/SETUP.md) · ⚖️ [O'Saasy License](LICENSE.md)

---

## Stack

- **Ruby 3.4 / Rails 8.1** — full-stack, server-rendered, no JS framework needed
- **SQLite** — single-file database, self-hosted friendly
- **Hotwire** (Turbo + Stimulus) — reactive UI without a separate frontend
- **TailwindCSS v4 + DaisyUI v5** — themeable UI via standalone binary
- **Leaflet.js + OpenStreetMap** — interactive map, no API key needed
- **ActionMailbox + Postmark** — inbound email routing
- **Solid Queue** — background jobs (built into Rails 8)
- **Anthropic Claude Haiku** — AI for parsing booking confirmation emails
- **Pexels API** — trip cover images
- **Cloudflare Tunnel** — zero-config HTTPS for self-hosters

> 💡 **Recommended environment:** [Omarchy](https://omarchy.org) — an opinionated Linux setup built for Rails developers. Gets you from zero to running in minutes.

---

## Features

- Create and share a trip with your family or friend group
- Forward booking confirmation emails to a trip-specific address — AI parses and adds them after your review
- Shortlist restaurants, sights, and activities on an interactive map
- Track actual spend with multi-currency support
- Shared expense view for the whole group
- Invite travel partners by email or shareable invite link
- Auto-fetch trip cover images from Pexels
- AI-assisted trip idea import (paste a prompt into ChatGPT, import the JSON)
- Installable as a PWA — add to home screen on iOS and Android
- 20+ themes including a custom DaPlanStan theme

---

## Self-hosting

### Prerequisites

- Ruby 3.4+ (`mise use --global ruby@3.4`)
- [Anthropic API key](https://console.anthropic.com/) — for email parsing
- [Pexels API key](https://www.pexels.com/api/) — for cover images (optional)
- A domain with Cloudflare DNS

### Quick start

```bash
git clone https://github.com/GeertClaes/daplanstan.git
cd daplanstan
bundle install

# DaisyUI plugin (gitignored — re-run after every fresh clone)
mkdir -p app/assets/tailwind/plugins
curl -sL -o app/assets/tailwind/plugins/daisyui.js https://cdn.jsdelivr.net/npm/daisyui@5/+esm

cp .env.example .env   # fill in your credentials
bin/rails db:encryption:init
bin/rails db:create db:migrate db:seed
bin/dev
```

See [docs/SETUP.md](docs/SETUP.md) for the full guide covering Cloudflare tunnels, Postmark inbound email, Google/Apple OAuth, and PWA installation.

### Key environment variables

```
ANTHROPIC_API_KEY=              # AI email parsing
PEXELS_API_KEY=                 # Trip cover images (optional)
GOOGLE_CLIENT_ID=               # OAuth
GOOGLE_CLIENT_SECRET=
POSTMARK_API_TOKEN=             # Inbound + outbound email
POSTMARK_FROM_EMAIL=            # e.g. noreply@yourdomain.com
TRIP_EMAIL_DOMAIN=              # e.g. app.yourdomain.com
RAILS_INBOUND_EMAIL_PASSWORD=
```

---

## Design principles

1. **Email-first** — forwarding a confirmation is the lowest-friction way to add a booking
2. **Review before saving** — AI parses, humans confirm; nothing is added silently
3. **Simple over powerful** — every screen should be immediately obvious
4. **Self-hosted friendly** — one server, one process, SQLite by default

---

## License

[O'Saasy License](LICENSE.md) — free to self-host and fork; you may not resell it as a competing hosted SaaS. See [osassy.dev](https://osassy.dev) for details.

---

## Status

Beta 0.1 — core features complete: email ingestion, AI parsing, interactive map, expense tracking, trip sharing, and PWA install. Actively maintained.
