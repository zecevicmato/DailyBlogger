# DailyBlogger

A small photo-feed app for sharing what your day looks like. Originally written as an Android Kotlin app with Firebase, now rebuilt in Flutter with a glassmorphism UI and Supabase as the backend.

| | |
|---|---|
| **Stack** | Flutter (Dart), Supabase (Auth + Postgres + Storage) |
| **Platforms** | iOS, Android |
| **UI** | Glassmorphism, dark/light auto, subtle motion via `flutter_animate` |

## 1. Setup

### 1.1 Supabase project

1. Create a free project at https://supabase.com/dashboard
2. **Settings → API** → copy:
   - **Project URL**
   - **anon public** key (NOT the `service_role` key)
3. **SQL Editor → New query** → paste contents of [`supabase_schema.sql`](./supabase_schema.sql) → **Run**.
   - Creates `profiles` + `posts` tables, RLS policies, and two public Storage buckets.
4. Run [`supabase_migration_001_auto_profile.sql`](./supabase_migration_001_auto_profile.sql) the same way. This adds a Postgres trigger that auto-creates a `profiles` row whenever a new user signs up (and back-fills any existing users).
5. **Authentication → Providers → Email** → for development, disable **Confirm email** so accounts work immediately.

### 1.2 Local credentials

Credentials live in a `.env` file that is **not** committed.

```bash
cp .env.example .env
# then edit .env and paste the Project URL + anon key from step 1.1
```

## 2. Running

```bash
flutter pub get
./run.sh             # iOS / Android device or simulator, reads .env
```

`run.sh` is a thin wrapper around `flutter run` that loads `.env` and passes the values as `--dart-define`. You can also do it manually:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR-PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJ...
```

If the credentials are missing the app fails fast at startup with a clear message.

## 3. Project layout

```
lib/
  config/
    supabase_config.dart   # Reads SUPABASE_URL / SUPABASE_ANON_KEY at compile time
    theme.dart             # Light + dark glassmorphism themes (system mode)
  models/
    profile.dart
    post.dart
  services/
    supabase_service.dart  # Auth + DB + Storage facade (singleton)
  screens/
    main_screen.dart       # Landing — Login / Register / Guest
    login_screen.dart
    register_screen.dart   # With image_picker for avatar
    guest_screen.dart      # Read-only feed
    app_screen.dart        # Authenticated feed + FAB
    add_post_screen.dart   # Compose post (image + description)
  widgets/
    glass_card.dart
    glass_button.dart
    glass_text_field.dart
    gradient_background.dart   # Animated drifting color blobs
    post_card.dart
  main.dart
assets/
  images/                  # Logo + user placeholder PNGs
supabase_schema.sql                       # Base tables + RLS + buckets
supabase_migration_001_auto_profile.sql   # Trigger that auto-creates profiles on signup
```

## 4. Features

- Email + password auth via Supabase GoTrue
- Public feed of photo posts (image + caption + author + relative timestamp)
- Sign up with optional profile photo
- Authenticated feed with pull-to-refresh + create post (FAB)
- Guest mode — read-only feed without an account
- Glassmorphism look, animated gradient backgrounds, hero transitions, staggered list animations
- Auto light / dark theme based on system setting

## 5. Notes on the migration

This started as an Android Kotlin project (Firebase Auth / Firestore / Storage). Mapping for anyone curious:

| Kotlin | Flutter |
|---|---|
| Fragments + ViewBinding | Screens (`StatefulWidget`) + `go_router` |
| `FirebaseAuth` | Supabase Auth (`signInWithPassword`, `signUp`) |
| Firestore collections | Postgres tables (`profiles`, `posts`) with RLS |
| Firebase Storage | Supabase Storage buckets (`user-photos`, `post-images`) |
| Glide | `cached_network_image` |
| `CircleImageView` | `CircleAvatar` |
| RecyclerView + Adapter | `ListView.builder` + `PostCard` |

A few bugs from the original were fixed along the way:
- `User` model now correctly stores `(id, username, photo_url)` instead of `User(userName, email, password)` constructed against a 3-arg `(uid, userName, userPhoto)` data class.
- Posts are linked to their author by `user_id` (FK) instead of looking up users by email substring (`userName.contains(email)`).
- Profile avatar is loaded once on the feed screen rather than re-downloaded per post item.

## 6. License

MIT, do what you want.
