# DailyBlogger

## 1. Project layout

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

## 2. Features

- Email + password auth via Supabase GoTrue
- Public feed of photo posts (image + caption + author + relative timestamp)
- Sign up with optional profile photo
- Authenticated feed with pull-to-refresh + create post (FAB)
- Guest mode — read-only feed without an account
- Auto light / dark theme based on system setting

## 3. License

MIT, do what you want.
