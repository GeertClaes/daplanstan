# MISSION.md

## What we are building

A self-hosted, open source trip planning web application built with Rails 8. Working title: **Daplanstan**.

## Why it exists

Existing tools like Wanderlog and Polarsteps are either overpriced, too generic, or not designed for the way real travellers plan trips — with multiple people contributing bookings from different sources, a mix of confirmed plans and shortlisted ideas, and a need to track actual spend on the ground.

Daplanstan is built for a small group of travellers (typically 2–5 people) who want one shared place to:
- Organise confirmed bookings and accommodation
- Maintain a shortlist of places to eat, see, and visit on a map
- Forward booking confirmation emails and have them parsed automatically
- Track actual spend during the trip with receipt photos
- Share photos and videos as a live feed and post-trip album

## Who it is for

Primary: Couples and small groups planning multi-destination trips, particularly those who:
- Make bookings across multiple platforms (Booking.com, airline sites, tour operators)
- Receive confirmation emails they want captured automatically
- Want a shared visual map of shortlisted places
- Travel internationally with mixed currencies

Secondary: Anyone who wants a self-hosted alternative to subscription travel tools.

## Design principles

1. **Email-first contributions** — the lowest friction way to add a booking is to forward the confirmation email. Everything else is secondary.
2. **Review before saving** — AI parses content but humans confirm before it enters the itinerary. No silent errors.
3. **Simple over powerful** — resist feature creep. Every screen should be immediately obvious.
4. **Self-hosted friendly** — minimal external dependencies, SQLite by default, runs on a single server.
5. **Open source** — built in the open, shareable, forkable.

## What success looks like for v1

A working web app that a non-technical person can use to:
- Create a trip
- Forward a Booking.com confirmation email and see it appear in their itinerary after review
- Add shortlisted restaurants and see them on a map
- Upload a receipt photo and log an expense
- Share the trip with a partner who can contribute

## Out of scope forever (for this project)

- Native mobile app
- Flight/hotel booking engine
- Social network features
- AI-generated itinerary suggestions
