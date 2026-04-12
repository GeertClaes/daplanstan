# APPROACH.md

## Tech Stack

### Runtime
- **Ruby 3.4.2** — managed via mise (`mise use --global ruby@3.4.2`)
- **Rails 8.1.3**
- **Node.js 20+** — available but not required for Tailwind or DaisyUI

### Backend
- **Rails 8.1** — full stack, server-rendered
- **SQLite** — default database, single file, self-hosted friendly
- **Hotwire (Turbo + Stimulus)** — reactive UI without a JS framework
- **ActionMailbox** — inbound email routing (built into Rails 8), ingress via Postmark
- **Active Storage** — file uploads (receipt photos, media, attachments)
- **Solid Queue** — background jobs for AI parsing (built into Rails 8)
- **Solid Cache** — caching (built into Rails 8)

### Frontend
- **TailwindCSS v4** — via `tailwindcss-rails` gem (standalone binary, no Node.js required, no `tailwind.config.js`)
- **DaisyUI v5** — downloaded as a self-contained ESM file into `app/assets/tailwind/plugins/daisyui.js`, loaded with `@plugin "./plugins/daisyui.js"` in the CSS entry point. This directory is gitignored — re-download after cloning (see CLAUDE.md)
- **Leaflet.js** — interactive maps with OSM tiles
- **Nominatim** — free geocoding (OpenStreetMap), no API key required

### Authentication
- **OmniAuth** with `omniauth-google-oauth2` and `omniauth-apple` gems
- Multiple providers per user via `user_identities` table
- No email/password accounts
- Optional beta invite gating: new sign-ins require a valid `Invite` token (stored in session by the `/i/:token` route) or an existing account

### AI
- **Anthropic Claude Haiku** — cloud AI via the `anthropic` gem
- Called via background jobs (Solid Queue), never blocking the request cycle
- `ParseInboxItemJob` uses Claude Haiku with tool/function calling to extract structured travel data (travel legs, accommodations, bookings, shortlist items, expenses) from emails
- `ParseReceiptJob` sends a base64-encoded receipt image to Claude Haiku vision and extracts amount, currency, merchant, date, and category
- All AI calls wrapped in begin/rescue; failures set `parse_status: :failed` on the inbox_item and are logged

### Photos
- **Pexels API** — `FetchTripCoverImageJob` fetches a landscape cover photo when a trip is created or its title changes
- Strips 4-digit years from the title for better search results
- Stores `cover_image_url` on the trip record

### Email
- **Postmark** — inbound webhook → ActionMailbox → `TripMailbox` → `ParseInboxItemJob`
- Each trip gets a unique inbound address (e.g. `puglia-2025-a3f9@whats.daplanstan.com`)
- Outgoing transactional email (pending sender notifications, trip invites) also via Postmark
- MX record for `whats.daplanstan.com` → `inbound.postmarkapp.com`

### Geocoding
- **geocoder gem** with Nominatim (OpenStreetMap) — free, no API key required
- Called after creating accommodations, shortlist items, and travel leg arrivals from parsed emails
- Stores `latitude` / `longitude` on the record for map display
- Fallback chain: address with city bias → name + trip title → name alone

### File storage
- **Active Storage with local disk** for v1 (self-hosted)
- Swap to S3/Cloudflare R2 later via single config change

---

## Architecture Decisions

### SQLite over PostgreSQL
Rails 8 treats SQLite as a first-class citizen. For a self-hosted single-server app with low concurrent write volume, SQLite is simpler and sufficient. Three database files are used: main app data, Solid Queue jobs, and Solid Cache.

### Account/Traveler model
Users (authentication identities) are decoupled from Travelers (trip participants). Each User owns one Account, which has many Travelers. A Traveler can be linked to a User (someone who has signed in) or unlinked (someone invited by email who hasn't yet joined). This allows adding travel companions before they have an account and preserves trip history if someone later signs up.

```
User ──── Account ──── Traveler ──── TripMember ──── Trip
                  └─── Traveler (pending)
```

### Server-rendered with Hotwire
No separate frontend framework. Turbo Frames and Turbo Streams handle dynamic updates without page reloads. Stimulus controllers handle map initialisation, receipt photo preview, tab state, date pickers, and other lightweight JS behaviour.

### ActionMailbox for email ingestion
Built into Rails, handles inbound email routing natively. Postmark posts raw email to `/rails/action_mailbox/postmark/inbound_emails` — Rails handles the rest. Each trip's inbound address routes to `TripMailbox`. Authentication via HTTP Basic Auth using `RAILS_INBOUND_EMAIL_PASSWORD`.

### Anthropic Claude for AI parsing
Cloud AI via the `anthropic` gem. Claude Haiku is used for both email parsing (tool calling to extract structured data) and receipt OCR (vision API). Jobs retry up to 5 times with exponential backoff. All failures are logged to the inbox_item record so users can see what went wrong.

### Background jobs for AI
Never call AI APIs in a controller. All AI parsing happens in Solid Queue jobs:
- `ParseInboxItemJob` — processes a received email, creates `TripItem` records + linked `Expense` records, geocodes addresses
- `ParseReceiptJob` — sends receipt image to Claude Haiku vision, extracts expense fields
- `FetchTripCoverImageJob` — fetches a Pexels photo for the trip cover

### Review queue pattern
All AI-parsed content lands in `inbox_items` with `review_status: :pending_review`. Nothing is auto-saved to the trip. Users confirm or discard from a review queue UI.

---

## Project Structure

```
app/
  controllers/
    trips_controller.rb
    trip_items_controller.rb
    trip_members_controller.rb
    expenses_controller.rb
    inbox_items_controller.rb
    approved_senders_controller.rb
    invites_controller.rb
    travelers_controller.rb
    settings_controller.rb
    sessions_controller.rb
    home_controller.rb
  mailboxes/
    trip_mailbox.rb
  mailers/
    trip_mailer.rb            # pending sender notifications
    invitation_mailer.rb      # account and trip invite emails
  jobs/
    parse_inbox_item_job.rb   # Claude Haiku email parsing → TripItems + Expenses
    parse_receipt_job.rb      # Claude Haiku receipt OCR
    fetch_trip_cover_image_job.rb  # Pexels cover image
  models/
    user.rb
    user_identity.rb
    account.rb
    traveler.rb
    invite.rb
    trip.rb
    trip_member.rb
    trip_item.rb              # single model for all stops/legs/stays/ideas
    expense.rb
    media_item.rb
    inbox_item.rb
    approved_sender.rb
  views/
    trips/
    trip_items/
    expenses/
    inbox_items/
    invites/
    settings/
    trip_mailer/
    invitation_mailer/
  javascript/
    controllers/
      map_controller.js           # Leaflet map — trip_items only
      receipt_controller.js       # Receipt photo preview
      tabs_controller.js          # Tab switcher with URL sync
      bottom_sheet_controller.js
      category_picker_controller.js
      date_range_controller.js
      flash_controller.js
      location_picker_controller.js
      timeline_controller.js
      trip_nav_controller.js
```

---

## Key Gems

```ruby
gem "omniauth-google-oauth2"
gem "omniauth-apple"
gem "omniauth-rails_csrf_protection"
gem "anthropic"           # Claude Haiku — email parsing and receipt OCR
gem "postmark-rails"      # outgoing email + inbound webhook verification
gem "geocoder"            # address → lat/lng via Nominatim (free)
gem "image_processing"    # Active Storage image variants
gem "pagy"                # pagination
gem "dotenv-rails", groups: [:development, :test]
```

---

## Environment Variables Required

See `.env.example` for the full list with comments. Key variables:

```
# AI
ANTHROPIC_API_KEY=

# Photos
PEXELS_API_KEY=

# Auth
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=

# Email
POSTMARK_API_TOKEN=
POSTMARK_FROM_EMAIL=
TRIP_EMAIL_DOMAIN=whats.daplanstan.com
RAILS_INBOUND_EMAIL_PASSWORD=

# Rails
ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=
ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=
ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT=
```

---

## Database

SQLite with three database files (Rails 8 default):
- `storage/development.sqlite3` — main app data
- `storage/development_queue.sqlite3` — Solid Queue jobs
- `storage/development_cache.sqlite3` — Solid Cache

---

## Conventions

- UUIDs as primary keys on all tables (`id: :uuid`)
- All timestamps in UTC
- Enums defined in models using Rails `enum`
- Soft currency: currency stored per-record as ISO 4217 string
- File uploads via Active Storage, never store file data in DB
- All AI calls wrapped in begin/rescue, failures logged to inbox_item
- Stimulus controllers named after their primary behaviour (map, receipt, tabs, etc.)
