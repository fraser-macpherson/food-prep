-- =============================================================
-- Weekly Meal Plan — Supabase setup
-- Run this whole file once: Supabase dashboard -> SQL Editor ->
-- New query -> paste -> Run. It is safe to run again later.
--
-- Tables are prefixed "meal_" so they can't clash with anything
-- else in the same Supabase project (e.g. another app).
-- =============================================================


-- -------------------------------------------------------------
-- 1. PROFILES: one row per user, holding the name shown as
--    "Added by ...". (Website code can't read auth.users directly,
--    so the display name lives in its own public table.)
-- -------------------------------------------------------------
create table if not exists public.meal_profiles (
  id           uuid primary key references auth.users (id) on delete cascade,
  display_name text not null check (char_length(display_name) between 1 and 60),
  created_at   timestamptz not null default now()
);


-- -------------------------------------------------------------
-- 2. AUTO-CREATE A PROFILE whenever you add a user in the
--    dashboard. Display name = "display_name" from the user's
--    metadata if you set one, otherwise the part of their email
--    before the @.
-- -------------------------------------------------------------
create or replace function public.meal_handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.meal_profiles (id, display_name)
  values (
    new.id,
    left(
      coalesce(
        nullif(btrim(new.raw_user_meta_data ->> 'display_name'), ''),
        nullif(split_part(coalesce(new.email, ''), '@', 1), ''),
        'Cook'
      ),
      60
    )
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists meal_on_auth_user_created on auth.users;
create trigger meal_on_auth_user_created
  after insert on auth.users
  for each row execute function public.meal_handle_new_user();

-- Create profiles for any users that already exist in the project.
insert into public.meal_profiles (id, display_name)
select
  u.id,
  left(
    coalesce(
      nullif(btrim(u.raw_user_meta_data ->> 'display_name'), ''),
      nullif(split_part(coalesce(u.email, ''), '@', 1), ''),
      'Cook'
    ),
    60
  )
from auth.users u
on conflict (id) do nothing;


-- -------------------------------------------------------------
-- 3. RECIPES: every breakfast, lunch and dinner added through
--    the website. user_id is filled in automatically with the
--    signed-in user's id, so it records who added each one.
--    If a user is later deleted, their recipes stay (user_id
--    becomes empty and the site shows "a former member").
-- -------------------------------------------------------------
create table if not exists public.meal_recipes (
  id           uuid primary key default gen_random_uuid(),
  meal_type    text not null check (meal_type in ('breakfast', 'lunch', 'dinner')),
  name         text not null check (char_length(btrim(name)) between 1 and 100),
  ingredients  text[] not null check (cardinality(ingredients) between 1 and 60),
  instructions text not null check (char_length(btrim(instructions)) between 1 and 4000),
  vegetarian   boolean not null default false,
  cost         numeric(8, 2) not null check (cost > 0),
  user_id      uuid default auth.uid() references public.meal_profiles (id) on delete set null,
  created_at   timestamptz not null default now()
);

-- No two recipes of the same type with the same name (ignores case/spaces).
create unique index if not exists meal_recipes_type_name_key
  on public.meal_recipes (meal_type, lower(btrim(name)));

create index if not exists meal_recipes_user_idx
  on public.meal_recipes (user_id);


-- -------------------------------------------------------------
-- 4. ROW LEVEL SECURITY — this is what really enforces the rules.
--    Without it, anyone holding the public key could change data.
-- -------------------------------------------------------------
alter table public.meal_profiles enable row level security;
alter table public.meal_recipes  enable row level security;

-- Profiles: everyone can read names; you can only rename yourself.
drop policy if exists "Anyone can read profiles" on public.meal_profiles;
create policy "Anyone can read profiles"
  on public.meal_profiles for select
  to anon, authenticated
  using (true);

drop policy if exists "Users can rename themselves" on public.meal_profiles;
create policy "Users can rename themselves"
  on public.meal_profiles for update
  to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

-- Recipes: everyone (signed in or not) can read them.
drop policy if exists "Anyone can read recipes" on public.meal_recipes;
create policy "Anyone can read recipes"
  on public.meal_recipes for select
  to anon, authenticated
  using (true);

-- Recipes: only signed-in users can add, and only as themselves.
drop policy if exists "Signed-in users can add recipes" on public.meal_recipes;
create policy "Signed-in users can add recipes"
  on public.meal_recipes for insert
  to authenticated
  with check (user_id = (select auth.uid()));

-- Recipes: you can delete your own, nobody else's.
drop policy if exists "Users can delete their own recipes" on public.meal_recipes;
create policy "Users can delete their own recipes"
  on public.meal_recipes for delete
  to authenticated
  using (user_id = (select auth.uid()));


-- -------------------------------------------------------------
-- 5. PERMISSIONS (table-level; RLS above narrows them further)
-- -------------------------------------------------------------
grant usage on schema public to anon, authenticated;

grant select on public.meal_profiles to anon, authenticated;
grant update (display_name) on public.meal_profiles to authenticated;

grant select on public.meal_recipes to anon, authenticated;
grant insert, delete on public.meal_recipes to authenticated;


-- -------------------------------------------------------------
-- 6. ADMIN VIEW (for you, in the dashboard only): who added what,
--    with their email. Access is revoked from the website roles so
--    emails are never exposed to visitors.
--    Use it with:  select * from public.meal_recipes_admin;
-- -------------------------------------------------------------
create or replace view public.meal_recipes_admin as
select
  r.created_at,
  r.meal_type,
  r.name,
  r.cost,
  r.vegetarian,
  p.display_name as added_by_name,
  u.email        as added_by_email,
  r.id           as recipe_id
from public.meal_recipes r
left join public.meal_profiles p on p.id = r.user_id
left join auth.users u           on u.id = r.user_id
order by r.created_at desc;

revoke all on public.meal_recipes_admin from anon, authenticated;


-- -------------------------------------------------------------
-- OPTIONAL: change how someone's name appears on their recipes
--   update public.meal_profiles
--   set display_name = 'Sam'
--   where id = (select id from auth.users where email = 'sam@example.com');
-- -------------------------------------------------------------
