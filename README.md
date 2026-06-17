# Rentacar SaaS

Çok kiracılı (multi-tenant) araç kiralama yönetim platformu.

**Stack:** Flutter · PostgreSQL · PostgREST · Riverpod

## Özellikler

- **Kiracı vitrin sitesi** — Hero, araç listesi, 4 adımlı rezervasyon wizard
- **Admin paneli** — Dashboard, KPI, Gantt filo önizleme, web sitesi ayarları
- **Premium Mobility** tasarım sistemi — Lacivert + kehribar palet
- **PostgreSQL** — RLS multi-tenant, EXCLUDE constraint ile double-booking önleme

## Hızlı Başlangıç

### Flutter

```bash
flutter pub get

# Müşteri vitrin sitesi (varsayılan)
flutter run -d chrome

# Admin paneli
flutter run -d chrome --dart-define=APP_MODE=admin
```

### Backend (Docker)

```bash
docker compose up -d
```

- PostgreSQL: `localhost:5432`
- PostgREST API: `http://localhost:3000`

## Proje Yapısı

```
lib/
├── app/                    # MaterialApp, router seçimi
├── core/
│   ├── config/             # Tenant branding
│   ├── design_system/      # Tema, renkler, spacing
│   └── providers/          # Riverpod global providers
├── features/
│   ├── public_web/         # Kiracı vitrin sitesi
│   ├── admin_web/          # Operasyon paneli
│   └── fleet/              # Domain entities
├── shared/widgets/         # AppButton, AppVehicleCard, AppKpiCard
database/migrations/        # PostgreSQL şema
docker-compose.yml          # Postgres + PostgREST
```

## Ortam Değişkenleri

| Değişken | Açıklama | Varsayılan |
|----------|----------|------------|
| `APP_MODE` | `public` veya `admin` | `public` |

## Lisans

Proprietary — Tüm hakları saklıdır.
