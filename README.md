# LevelUp Fitness — System

A personal, Solo Leveling-inspired workout tracker. Dumbbell + bodyweight +
walking only, no bench. No login — built for one person (you) to use.

This is a **single static `index.html` file** — no build step, no npm, no
framework install. Just edit two lines, push to GitHub, deploy on Netlify.

- **Daily Quests** — small consistency tasks (hydration, short walk / stretch)
- **Training Quest** — your actual workout for the day, pulled from your 5-day split
- **Rank system** — E → D → C → B → A → S, based on total EXP earned
- **Rest days are yours to choose** — pick training days on the Schedule tab; every
  other day auto-becomes a Recovery Zone with a preview of tomorrow's workout
- **Progression** — as you rank up, sets increase and new exercise variations
  unlock and swap into your split automatically
- **Profile** — enter your stats, get your BMR, maintenance calories (TDEE), and
  a suggested deficit target for fat loss

---

## 1. Set up Supabase (your database)

1. Create a free project at [supabase.com](https://supabase.com).
2. In your project, go to **SQL Editor → New query**.
3. Paste the entire contents of [`schema.sql`](./schema.sql) and run it. This
   creates all tables, seeds one default profile row, a default Mon–Fri
   schedule, and sets permissive RLS policies (no login, but still requires
   your anon key to read/write).
4. Go to **Project Settings → API**. Copy:
   - `Project URL`
   - `anon` `public` key

## 2. Add your keys to `index.html`

Open `index.html` in any text editor and find this block near the top of the
`<script type="module">` section:

```js
const SUPABASE_URL = "YOUR_SUPABASE_PROJECT_URL";
const SUPABASE_ANON_KEY = "YOUR_SUPABASE_ANON_KEY";
```

Replace both with the values you copied from Supabase, e.g.:

```js
const SUPABASE_URL = "https://abcxyz.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIs...";
```

Save the file. That's the entire setup — no `.env`, no environment variables.
The anon key is meant to be public in client-side code by design; your data
is protected by the RLS policies in `schema.sql`, not by hiding the key.

## 3. Try it locally (optional)

You can just double-click `index.html` to open it in a browser, or serve it
with any static server, e.g.:

```bash
npx serve .
```

## 4. Push to GitHub

```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/<your-username>/<your-repo>.git
git push -u origin main
```

## 5. Deploy on Netlify

1. In Netlify, **Add new site → Import an existing project** → connect the
   GitHub repo you just pushed.
2. Build settings are already defined in `netlify.toml` — no build command
   needed, it just publishes the root folder as-is.
3. Deploy. Netlify gives you a free `*.netlify.app` subdomain immediately; you
   can attach a custom domain later under **Domain settings**.

## 6. Install it like an app on your iPhone 12 Pro Max

Open the deployed site in Safari → tap **Share** → **Add to Home Screen**. It
launches full-screen with safe-area padding already handled (no clipping under
the notch or home indicator).

---

## How the system works

- **Split**: your current 5-day routine (Chest/Shoulders/Triceps, Legs,
  Back/Biceps, Legs+Core, Full Body) is seeded directly in `index.html`
  (search for `BASE_SPLIT`). Whichever days you mark as training days on the
  Schedule tab get this split assigned in order, cycling automatically — so
  if you only train 3 days a week, you still move through all 5 split days,
  just spread out.
- **Progression pool** (search for `EXERCISE_POOL`): tagged by the rank that
  unlocks them (C/B/A/S). Once you cross a rank threshold, the app starts
  substituting 1-3 of that day's exercises for newly-unlocked variations
  (e.g. Bulgarian split squats, dumbbell thrusters, devil presses), and adds
  bonus sets at higher ranks — all still dumbbell/bodyweight only.
- **EXP & rank thresholds** — search for `RANK_THRESHOLDS` — edit those
  numbers if you want ranks to come faster or slower.
- **Calorie math** uses the Mifflin-St Jeor formula for BMR, multiplies by
  your activity level for TDEE/maintenance, and offers mild/moderate/
  aggressive deficit presets (search for `calcBMR`).

## Editing your split or the unlock pool

Everything lives in plain JS objects inside `index.html` — edit `BASE_SPLIT`
or `EXERCISE_POOL` any time and just re-save/re-deploy; no database migration
needed.

## Files in this project

- `index.html` — the entire app (markup, styling, logic)
- `schema.sql` — run once in Supabase's SQL Editor
- `netlify.toml` — tells Netlify how to publish the site (no build step)
- `README.md` — this file
