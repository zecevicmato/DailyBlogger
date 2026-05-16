-- DailyBlogger Supabase schema
-- Paste this entire file into Supabase Dashboard → SQL Editor → New query → Run.
-- It is idempotent: safe to run multiple times.

----------------------------------------------------------------------
-- 1. profiles table (1:1 with auth.users)
----------------------------------------------------------------------
create table if not exists public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  username    text not null,
  photo_url   text,
  created_at  timestamptz not null default now()
);

alter table public.profiles enable row level security;

drop policy if exists "profiles_select_all"   on public.profiles;
drop policy if exists "profiles_insert_self"  on public.profiles;
drop policy if exists "profiles_update_self"  on public.profiles;

create policy "profiles_select_all"
  on public.profiles for select
  using (true);

create policy "profiles_insert_self"
  on public.profiles for insert
  with check (auth.uid() = id);

create policy "profiles_update_self"
  on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

----------------------------------------------------------------------
-- 2. posts table
----------------------------------------------------------------------
create table if not exists public.posts (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references public.profiles(id) on delete cascade,
  image_url    text not null,
  description  text not null default '',
  created_at   timestamptz not null default now()
);

create index if not exists posts_created_at_idx on public.posts (created_at desc);

alter table public.posts enable row level security;

drop policy if exists "posts_select_all"   on public.posts;
drop policy if exists "posts_insert_self"  on public.posts;
drop policy if exists "posts_delete_self"  on public.posts;

create policy "posts_select_all"
  on public.posts for select
  using (true);

create policy "posts_insert_self"
  on public.posts for insert
  with check (auth.uid() = user_id);

create policy "posts_delete_self"
  on public.posts for delete
  using (auth.uid() = user_id);

----------------------------------------------------------------------
-- 3. Storage buckets (public for simple image hosting)
----------------------------------------------------------------------
insert into storage.buckets (id, name, public)
values
  ('user-photos', 'user-photos', true),
  ('post-images', 'post-images', true)
on conflict (id) do update set public = excluded.public;

-- Bucket policies: authenticated users can upload their own files; everyone can read.
drop policy if exists "user_photos_read"           on storage.objects;
drop policy if exists "user_photos_write_self"     on storage.objects;
drop policy if exists "post_images_read"           on storage.objects;
drop policy if exists "post_images_write_self"     on storage.objects;

create policy "user_photos_read"
  on storage.objects for select
  using (bucket_id = 'user-photos');

create policy "user_photos_write_self"
  on storage.objects for insert
  with check (
    bucket_id = 'user-photos'
    and auth.role() = 'authenticated'
    and (storage.foldername(name))[1] is not null
  );

create policy "post_images_read"
  on storage.objects for select
  using (bucket_id = 'post-images');

create policy "post_images_write_self"
  on storage.objects for insert
  with check (
    bucket_id = 'post-images'
    and auth.role() = 'authenticated'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
