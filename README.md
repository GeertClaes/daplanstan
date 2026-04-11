# Daplanstan

A self-hosted, open source trip planning app built with Rails 8.1.

Designed for small groups (2–5 people) who want one shared place to organise a trip — confirmed bookings, a shortlist map, forwarded confirmation emails parsed automatically, expense tracking, and a shared photo feed.

## Stack

- **Ruby 3.4.2 / Rails 8.1.3**
- **SQLite** — single-file, self-hosted friendly
- **Hotwire** (Turbo + Stimulus) — reactive UI without a JS framework
- **TailwindCSS v4 + DaisyUI v5** — via `tailwindcss-rails` standalone binary
- **Leaflet.js** — interactive map with OSM tiles
- **ActionMailbox + Postmark** — inbound email routing
- **Solid Queue** — background jobs
- **Anthropic Claude Haiku** — AI for email parsing and receipt OCR (via API)
- **Pexels API** — trip cover images

## Features (v1)

- Create and share a trip with your travel partners
- Forward booking confirmation emails to a trip-specific address — AI parses and adds them after your review
- Shortlist restaurants, sights, and activities on an interactive map
- Upload receipt photos to log and auto-extract expenses
- Track actual spend with mixed-currency support
- Invite travel partners by email or via shareable invite link
- Auto-fetch trip cover images from Pexels
- Account-level traveler management (add travel companions, link by email)
- Beta invite gating (optional)

## Setup

### Prerequisites

- Ruby 3.4.2 (via mise: `mise use --global ruby@3.4.2`)
- Rails 8.1.3 (`gem install rails -v 8.1.3`)
- An [Anthropic API key](https://console.anthropic.com/) for AI parsing
- A [Pexels API key](https://www.pexels.com/api/) for cover images (optional)

### Install

```bash
git clone https://github.com/GeertClaes/daplanstan.git
cd daplanstan
bundle install

# DaisyUI plugin (gitignored, must be downloaded)
mkdir -p app/assets/tailwind/plugins
curl -sL -o app/assets/tailwind/plugins/daisyui.js https://cdn.jsdelivr.net/npm/daisyui@5/+esm

cp .env.example .env   # fill in your credentials
rails db:encryption:init
rails db:create db:migrate db:seed
bin/dev
```

### Postmark (inbound email)

1. Create a Postmark server for Daplanstan
2. Add an MX record: `whats.daplanstan.yourdomain.com` → `inbound.postmarkapp.com` (priority 10)
3. Set the inbound webhook URL in Postmark: `https://actionmailbox:YOUR_PASSWORD@yourdomain.com/rails/action_mailbox/postmark/inbound_emails`
4. Enable **"Include raw email content in JSON payload"** in Postmark inbound settings

## Environment variables

See `.env.example` for all required variables with descriptions. Key ones:

```
ANTHROPIC_API_KEY=          # AI email parsing and receipt OCR
PEXELS_API_KEY=             # Trip cover images (optional)
GOOGLE_CLIENT_ID=           # OAuth
GOOGLE_CLIENT_SECRET=
POSTMARK_API_TOKEN=         # Inbound + outbound email
POSTMARK_FROM_EMAIL=
TRIP_EMAIL_DOMAIN=          # e.g. whats.daplanstan.yourdomain.com
RAILS_INBOUND_EMAIL_PASSWORD=
```

## Design principles

1. **Email-first** — forwarding a confirmation is the lowest-friction way to add a booking
2. **Review before saving** — AI parses, humans confirm
3. **Simple over powerful** — every screen should be immediately obvious
4. **Self-hosted friendly** — runs on a single server, SQLite by default

## Status

Active development — core email ingestion, AI parsing, expense tracking, and invite flow working.
