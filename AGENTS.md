# AGENTS

Rentacar SaaS — a multi-tenant car-rental platform. Single Flutter codebase that
builds a **public storefront** (`APP_MODE=public`, default) and an **admin panel**
(`APP_MODE=admin`), backed by an optional **PostgreSQL + PostgREST** stack
(`docker-compose.yml`). Standard commands and env vars are documented in `README.md`.

## Cursor Cloud specific instructions

The update script (`flutter pub get`) only refreshes Dart packages. The Flutter SDK,
Docker, and Chrome are already installed in the VM snapshot — do not reinstall them.

### Services & how to run them
- **Flutter web app (the product).** Dev: `flutter run -d web-server --web-port 8090 --web-hostname 0.0.0.0`
  (or `flutter run -d chrome`). Admin panel: add `--dart-define=APP_MODE=admin`.
  Lint/test/build commands are the standard `flutter analyze` / `flutter test` /
  `flutter build web` (see `README.md` / `.github/workflows/ci.yml`).
- **Backend (optional).** `sudo docker compose up -d` → Postgres on `5432`, PostgREST on
  `3000` (migrations in `database/migrations/` auto-apply on first DB init). The Docker
  daemon is NOT managed by systemd here — start it once per VM with `sudo dockerd &`
  before `docker` commands.

### Non-obvious gotchas (read before running the web GUI)
1. **Flutter SDK is on PATH only for login shells** (added to `~/.bashrc`:
   `export PATH="$HOME/flutter/bin:$PATH"`). In non-interactive shells call it as
   `~/flutter/bin/flutter` or export the PATH first.
2. **Blank white page on web = the `passkeys_web` transitive dep** (pulled via
   `supabase_flutter` → `gotrue`). Its web plugin `registerWith` calls
   `PasskeyAuthenticator.init` on an undefined global and aborts Flutter bootstrap because
   `web/index.html` does not load the Passkeys JS SDK. The app never uses passkeys, so to
   run the GUI add a stub **before** `<script src="flutter_bootstrap.js" async>` in
   `web/index.html` (this is a local run-time shim — keep it out of committed code unless
   you intend to fix it properly):
   ```html
   <script>
     window.PasskeyAuthenticator = window.PasskeyAuthenticator || {
       init: function () {}, register: function () { return Promise.reject('n/a'); },
       login: function () { return Promise.reject('n/a'); },
       cancelCurrentAuthenticatorOperation: function () {},
       isUserVerifyingPlatformAuthenticatorAvailable: function () { return Promise.resolve(false); },
       isConditionalMediationAvailable: function () { return Promise.resolve(false); },
       hasPasskeySupport: function () { return false; }
     };
   </script>
   ```
   Restart `flutter run` (or rebuild) after editing `index.html`.
3. **Run the app in DEMO mode** (`USE_DEMO_FALLBACK=true`, the default). That is the only
   fully working data path: storefront vehicles, the 4-step reservation wizard, and the
   admin demo login (`admin@premium-rent.com` / `admin123`) all work on simulated data.
4. **Live backend mode (`USE_DEMO_FALLBACK=false`) does not actually reach PostgREST.**
   `supabase_flutter` prefixes requests with `/rest/v1/`, but the self-hosted PostgREST
   serves at the root (`/vehicles`), so every call 404s and the app silently falls back to
   demo. The backend itself is healthy (verify with `curl http://localhost:3000/vehicles`);
   wiring the app to it would require a reverse proxy mapping `/rest/v1/* → /*` (or code
   changes). The seeded admin bcrypt hash in `003_*.sql` also does not match `admin123`, so
   live admin login fails — use demo mode.
5. **Headless screenshots:** Chrome here has no GPU, and CanvasKit needs WebGL. Use
   `google-chrome --headless=new --enable-unsafe-swiftshader --use-angle=swiftshader
   --user-data-dir=/tmp/<dir> --virtual-time-budget=20000 --screenshot=out.png <url>`.
   The interactive `computerUse` Chrome renders fine once the passkeys stub (gotcha 2) is in place.
