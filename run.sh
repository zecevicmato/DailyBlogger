#!/usr/bin/env bash
# Run the Flutter app, loading Supabase credentials from .env.
# Copy .env.example to .env and fill in your values before running.

set -euo pipefail

if [ ! -f .env ]; then
  echo "Missing .env file. Copy .env.example to .env and add your Supabase URL + anon key." >&2
  exit 1
fi

# shellcheck disable=SC1091
set -a
. ./.env
set +a

: "${SUPABASE_URL:?SUPABASE_URL not set in .env}"
: "${SUPABASE_ANON_KEY:?SUPABASE_ANON_KEY not set in .env}"

exec flutter run "$@" \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"
