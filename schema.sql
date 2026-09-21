-- LevelUp Fitness — Supabase schema
-- Run this once in Supabase → SQL Editor.
-- This app has NO auth (personal use only). RLS is enabled with a permissive
-- policy scoped to the anon key so the app works without login, but a
-- random visitor still can't do anything unless they have your anon key.

create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------------
-- profile (single row)
-- ---------------------------------------------------------------------
create table if not exists profile (
  id uuid primary key default gen_random_uuid(),
  name text,
  age int,
  height_cm numeric,
  weight_kg numeric,
  sex text check (sex in ('male', 'female')) default 'male',
  activity_level text default 'light',
  deficit_preset text default 'moderate', -- mild | moderate | aggressive
  updated_at timestamptz default now()
);

-- ---------------------------------------------------------------------
-- schedule: one row per weekday (0=Sun .. 6=Sat)
-- ---------------------------------------------------------------------
create table if not exists schedule (
  day_of_week int primary key check (day_of_week between 0 and 6),
  is_training_day boolean default false,
  split_slot int -- order position among training days, assigned by the app
);

-- ---------------------------------------------------------------------
-- player_stats (single row)
-- ---------------------------------------------------------------------
create table if not exists player_stats (
  id uuid primary key default gen_random_uuid(),
  total_exp int default 0,
  streak_count int default 0,
  last_full_day_date date,
  str_stat int default 0,
  vit_stat int default 0,
  agi_stat int default 0,
  updated_at timestamptz default now()
);

-- ---------------------------------------------------------------------
-- exp_log: append-only history of exp gains
-- ---------------------------------------------------------------------
create table if not exists exp_log (
  id uuid primary key default gen_random_uuid(),
  date date not null default current_date,
  source text not null, -- 'daily_quest' | 'training_quest' | 'rest_quest'
  detail text,
  exp_gained int not null,
  created_at timestamptz default now()
);

-- ---------------------------------------------------------------------
-- quest_completions: tracks which quests were completed on which date
-- ---------------------------------------------------------------------
create table if not exists quest_completions (
  id uuid primary key default gen_random_uuid(),
  date date not null default current_date,
  quest_type text not null, -- 'daily' | 'training' | 'rest'
  quest_key text not null,  -- e.g. 'hydration', 'training_day1'
  exp_reward int not null default 0,
  completed boolean default true,
  created_at timestamptz default now(),
  unique (date, quest_type, quest_key)
);

-- ---------------------------------------------------------------------
-- weight_log
-- ---------------------------------------------------------------------
create table if not exists weight_log (
  id uuid primary key default gen_random_uuid(),
  date date not null default current_date,
  weight_kg numeric not null,
  created_at timestamptz default now()
);

-- ---------------------------------------------------------------------
-- Row Level Security — open to the anon key (no login), since this is a
-- single-user personal app. Keep your Supabase anon key private-ish; it's
-- safe to ship in client code by design, but don't post it publicly.
-- ---------------------------------------------------------------------
alter table profile enable row level security;
alter table schedule enable row level security;
alter table player_stats enable row level security;
alter table exp_log enable row level security;
alter table quest_completions enable row level security;
alter table weight_log enable row level security;

create policy "anon full access" on profile for all using (true) with check (true);
create policy "anon full access" on schedule for all using (true) with check (true);
create policy "anon full access" on player_stats for all using (true) with check (true);
create policy "anon full access" on exp_log for all using (true) with check (true);
create policy "anon full access" on quest_completions for all using (true) with check (true);
create policy "anon full access" on weight_log for all using (true) with check (true);

-- ---------------------------------------------------------------------
-- Seed default rows
-- ---------------------------------------------------------------------
insert into profile (name, age, height_cm, weight_kg, sex, activity_level, deficit_preset)
select 'Hunter', 25, 170, 65, 'male', 'light', 'moderate'
where not exists (select 1 from profile);

insert into player_stats (total_exp, streak_count)
select 0, 0
where not exists (select 1 from player_stats);

-- Default schedule: Mon-Fri training, Sat-Sun rest (editable in-app)
insert into schedule (day_of_week, is_training_day, split_slot)
values
  (0, false, null), -- Sun
  (1, true, 1),      -- Mon
  (2, true, 2),      -- Tue
  (3, true, 3),      -- Wed
  (4, true, 4),      -- Thu
  (5, true, 5),      -- Fri
  (6, false, null)   -- Sat
on conflict (day_of_week) do nothing;
