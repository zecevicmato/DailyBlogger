-- Run all of this in Supabase SQL Editor.
-- It prints current state, force-backfills profiles, and prints state again.

-- 1) Current state
select
  (select count(*) from auth.users)                                                 as auth_users,
  (select count(*) from public.profiles)                                            as profiles,
  (select count(*) from pg_trigger where tgname = 'on_auth_user_created')           as trigger_exists,
  (select count(*) from pg_proc    where proname = 'handle_new_user')               as function_exists;

-- 2) Force backfill (runs as admin -> bypasses RLS)
insert into public.profiles (id, username)
select
  u.id,
  coalesce(
    u.raw_user_meta_data->>'username',
    split_part(u.email, '@', 1),
    'user-' || substr(u.id::text, 1, 8)
  )
from auth.users u
where not exists (select 1 from public.profiles p where p.id = u.id);

-- 3) New state
select id, username, photo_url, created_at from public.profiles order by created_at;
