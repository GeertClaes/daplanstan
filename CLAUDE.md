# CLAUDE.md

## Project

**DaPlanStan** — a self-hosted, open source trip planning Rails 8.1 app.
See MISSION.md, APPROACH.md, and DATA_MODEL.md for full context.

---

## Running the app

```bash
bundle install
cp .env.example .env   # fill in credentials
bin/rails db:encryption:init
bin/rails db:create db:migrate db:seed
bin/dev
```

---

## Code style

- Never use Unicode curly/smart quotes (`"`, `"`, `'`, `'`) in Ruby source — always use ASCII `"` or `'`.
- Run `bin/rubocop --no-color` before committing. Never run `--autocorrect` without reviewing the diff.

---

## Conventions

- All primary keys are UUIDs — `config.generators.orm :active_record, primary_key_type: :uuid` is set in `application.rb`
- Schema format is `:sql` (`db/structure.sql`) — required for SQLite + UUID columns
- Use Turbo Frames for inline editing where possible
- Keep controllers thin — logic in models or service objects
- Never call AI APIs directly in a controller — always via a job
- All AI calls wrapped in begin/rescue, failures logged to the inbox_item record
- Use Pagy for any list that could grow beyond 20 items

---

## DaisyUI themes

Community themes are defined as plain `[data-theme="name"] { ... }` CSS blocks in
`app/assets/tailwind/application.css`. The `@plugin "daisyui/theme"` syntax requires
Node.js and cannot be used with the standalone Tailwind binary.

The navbar logo uses inline SVG with `fill="var(--color-primary)"` etc. so it
responds to theme changes. Do not use `image_tag` for the logo.
