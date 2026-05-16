-- DailyBlogger Supabase migration 001: auto-create profile on signup
-- Run this AFTER supabase_schema.sql in the SQL Editor.
-- Fixes: posts.user_id FK violation when client-side insert into profiles
-- gets rejected by RLS due to session/JWT propagation race in signUp.

----------------------------------------------------------------------
-- 1. Function: create a profiles row whenever a new auth.users is inserted.
--    Runs as SECURITY DEFINER so it bypasses RLS (the trigger is trusted).
----------------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, username)
  values (
    new.id,
    coalesce(
      new.raw_user_meta_data->>'username',
      split_part(new.email, '@', 1),
      'user-' || substr(new.id::text, 1, 8)
    )
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

----------------------------------------------------------------------
-- 2. Trigger: fire the function after every new auth.users row.
----------------------------------------------------------------------
drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

----------------------------------------------------------------------
-- 3. Backfill: create profiles for any existing auth.users that don't have one yet.
--    Uses the email prefix as a default username.
----------------------------------------------------------------------
insert into public.profiles (id, username)
select
  u.id,
  coalesce(
    u.raw_user_meta_data->>'username',
    split_part(u.email, '@', 1),
    'user-' || substr(u.id::text, 1, 8)
  )
from auth.users u
left join public.profiles p on p.id = u.id
where p.id is null;
