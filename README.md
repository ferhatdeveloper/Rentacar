# Rentacar SaaS

Çok kiracılı (multi-tenant) araç kiralama yönetim platformu.

**Stack:** Flutter · PostgreSQL · PostgREST · Riverpod

## Özellikler

- **Kiracı vitrin sitesi** — Hero, araç listesi, 4 adımlı rezervasyon wizard
- **4 dil desteği** — Arapça, Türkçe, İngilizce, Kürtçe (Sorani) + RTL
- **Irak ödemeleri** — FIB, FastPay, Switch, Nebula POS
- **Admin paneli** — Dashboard, KPI, rezervasyonlar, filo, müşteriler, ödemeler, raporlar, check-in/out
- **Auth** — Demo admin girişi (`admin@premium-rent.com` / `admin123`)
- **Premium Mobility** tasarım sistemi — Lacivert + kehribar palet
- **PostgreSQL** — RLS multi-tenant, EXCLUDE constraint ile double-booking önleme

## Mimari

```
lib/
├── core/           # Config, API client, design system
├── features/
│   ├── auth/       # Admin oturum yönetimi
│   ├── customers/  # Müşteri CRUD
│   ├── payments/   # Ödeme kayıtları & gelir raporu
│   ├── inspections/# Check-in / check-out
│   ├── fleet/      # Araç & şube — domain / data / providers
│   ├── rentals/    # Rezervasyon, fiyat, dashboard stats
│   ├── public_web/ # Kiracı vitrin sitesi
│   └── admin_web/  # Operasyon paneli
database/migrations/
  001_initial_schema.sql
  002_api_layer.sql   # Views, RPC, seed data
  003_auth_inspections_payments.sql
  004_iraq_completion.sql
```

### API (PostgREST RPC)
| Fonksiyon | Açıklama |
|-----------|----------|
| `calculate_rental_price` | Fiyat hesaplama |
| `create_rental` | Rezervasyon oluştur (double-booking korumalı) |
| `create_customer` | Vitrin rezervasyonunda müşteri kaydı |
| `complete_checkin` | Araç teslim |
| `complete_checkout` | Araç iade |
| `record_payment` | Ödeme kaydı |
| `get_revenue_report` | Gelir raporu |
| `get_dashboard_stats` | Admin KPI |

### Admin rotaları

| Rota | Açıklama |
|------|----------|
| `/admin/login` | Giriş |
| `/admin/rentals` | Rezervasyon listesi (Teslim / İade) |
| `/admin/checkin/:id?mode=pickup\|return` | Check-in / check-out |
| `/admin/customers` | Müşteriler |
| `/admin/payments` | Ödemeler |
| `/admin/reports` | Gelir raporu |

### Ortam değişkenleri

```bash
flutter run -d chrome \
  --dart-define=API_URL=http://localhost:3000 \
  --dart-define=APP_MODE=admin \
  --dart-define=USE_DEMO_FALLBACK=true
```

`USE_DEMO_FALLBACK=true` iken API kapalı olsa bile demo veri ile çalışır.

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
| `NEBULA_URL` | Nebula WebService adresi | `localhost:9092` |
| `FIB_API_URL` | FIB ödeme API | — |
| `FASTPAY_API_URL` | FastPay API | — |
| `SWITCH_API_URL` | Switch API | — |

Detaylı Irak yapılandırması: [docs/IRAQ_PAYMENTS.md](docs/IRAQ_PAYMENTS.md)

## Lisans

Proprietary — Tüm hakları saklıdır.
