-- ============================================================
-- Recettes App — schéma Supabase
-- À exécuter une fois dans : SQL Editor > New query > Run
-- ============================================================

-- 1. Table des recettes
create table public.recipes (
  id bigint primary key,
  name text not null,
  ingredients text[] not null default '{}',
  instructions text[] not null default '{}',
  prep_time_minutes int,
  cook_time_minutes int,
  servings int,
  difficulty text,
  cuisine text,
  calories_per_serving int,
  tags text[] not null default '{}',
  meal_type text[] not null default '{}',
  image text,
  rating numeric,
  review_count int
);

-- 2. Row Level Security : lecture réservée aux utilisateurs connectés.
--    Sans token JWT valide, une requête renvoie [] (liste vide, pas d'erreur).
alter table public.recipes enable row level security;

create policy "Lecture réservée aux utilisateurs connectés"
  on public.recipes for select
  to authenticated
  using (true);

-- 3. Vue des catégories (écran Catégories : GET /rest/v1/recipe_tags)
--    security_invoker = true : la vue respecte la RLS de la table recipes.
--    Sans cette option, elle s'exécuterait avec les droits de son créateur
--    et exposerait les catégories aux utilisateurs non connectés.
create view public.recipe_tags
with (security_invoker = true) as
select distinct unnest(tags) as tag
from public.recipes
order by tag;
