-- ============================================================
-- Recettes App — données initiales (50 recettes DummyJSON)
-- À exécuter APRÈS schema.sql
--
-- 1. Ouvre https://dummyjson.com/recipes?limit=0 dans ton navigateur
-- 2. Copie TOUT le JSON affiché
-- 3. Plus bas, remplace le repère entre les deux $json$ par ce JSON
--    (garde les $json$ autour)
-- 4. SQL Editor > New query > Run
--
-- Les délimiteurs $json$ évitent que les apostrophes des recettes
-- ("Chef's...") cassent la requête.
-- ============================================================

insert into public.recipes (id, name, ingredients, instructions, prep_time_minutes,
  cook_time_minutes, servings, difficulty, cuisine, calories_per_serving,
  tags, meal_type, image, rating, review_count)
select
  (r->>'id')::bigint,
  r->>'name',
  array(select jsonb_array_elements_text(r->'ingredients')),
  array(select jsonb_array_elements_text(r->'instructions')),
  (r->>'prepTimeMinutes')::int,
  (r->>'cookTimeMinutes')::int,
  (r->>'servings')::int,
  r->>'difficulty',
  r->>'cuisine',
  (r->>'caloriesPerServing')::int,
  array(select jsonb_array_elements_text(r->'tags')),
  array(select jsonb_array_elements_text(r->'mealType')),
  r->>'image',
  (r->>'rating')::numeric,
  (r->>'reviewCount')::int
from jsonb_array_elements(($json$ COLLE_ICI $json$::jsonb) -> 'recipes') as r;

-- Vérification : doit afficher 50
select count(*) from public.recipes;
