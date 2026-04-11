# Plan: Import from AI

Status: **DONE — built 2026-04-09**

## What

Users ask any AI assistant (ChatGPT, Claude, etc.) to generate trip ideas using a provided prompt template that produces a specific JSON format. They then paste the JSON or upload a `.json` file. The app parses it directly — no AI call — and creates TripItems with `status: idea` for review on the itinerary.

---

## User flow

1. User opens the Trip tab, taps the sparkle (lightbulb) icon in the owner action pill
2. Import screen opens (boarding-pass card style, no navbar)
3. Screen shows a copyable prompt template and a textarea + file upload
4. User pastes or uploads JSON → first submit renders a preview list
5. User confirms → items created as `idea`, redirect to itinerary tab

---

## Prompt template (shown in-app)

```
Return ONLY a JSON array:

[
  {
    "kind": "stay | eat | do | shop | other",
    "name": "...",
    "address": "... (optional)",
    "notes": "... (optional)",
    "starts_at": "YYYY-MM-DDTHH:MM (optional)"
  }
]

My trip: [DESCRIBE YOUR TRIP HERE]
```

Kind values match TripItem kinds exactly. Only Stay/Eat/Do/Shop/Other — transport kinds excluded from prompt (users don't import flight/train/car via AI ideas).

---

## JSON format

```json
[
  {
    "kind": "eat",
    "name": "Ristorante Il Frantoio",
    "address": "Fasano, Italy",
    "notes": "Traditional masseria dining, book in advance",
    "starts_at": "2026-05-12T20:00"
  },
  {
    "kind": "do",
    "name": "Trulli of Alberobello",
    "address": "Alberobello, Italy"
  }
]
```

Unknown `kind` values → coerced to `"other"`. Unknown fields → ignored. Missing `name` → item skipped (count shown).

---

## Files created / modified

| File | Change |
|---|---|
| `config/routes.rb` | Added `collection do get/post :import end` inside `resources :trip_items` |
| `app/controllers/trip_items_controller.rb` | Added `import` action (two-pass: preview then confirm) + private `bulk_create_items` / `parse_import_time` |
| `app/views/trip_items/import.html.erb` | New screen: copyable prompt, textarea + file upload, preview list, confirm |
| `app/javascript/controllers/json_file_controller.js` | New Stimulus controller: reads `.json` file into the textarea on file select |
| `app/views/trips/_trip_panel.html.erb` | Added lightbulb icon to owner action pill |
