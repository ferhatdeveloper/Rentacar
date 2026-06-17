# Rentacar — Kalan İşler

> Son güncelleme: 2026-06-17  
> Tamamlanan commit: `bc3702e` (Irak lokalizasyonu, ödeme entegrasyonları, admin modülleri)

---

## P0 — Canlıya çıkış (hemen)

- [ ] **Docker backend kurulumu ve test**
  - `docker compose up -d`
  - Migration 001–004'in sorunsuz çalıştığını doğrula
  - PostgREST: `http://localhost:3000` erişilebilir mi?

- [ ] **Demo fallback kapatma testi**
  ```bash
  flutter run -d chrome --dart-define=USE_DEMO_FALLBACK=false --dart-define=API_URL=http://localhost:3000
  ```
  - Vitrin rezervasyon akışı canlı API ile uçtan uca test

- [ ] **Admin panel canlı test**
  ```bash
  flutter run -d chrome --dart-define=APP_MODE=admin --dart-define=USE_DEMO_FALLBACK=false
  ```
  - Giriş: `admin@premium-rent.com` / `admin123` (bcrypt RPC)

---

## P1 — Irak ödeme entegrasyonları (gerçek API)

- [ ] **FIB (First Iraqi Bank)**
  - Resmi API dokümantasyonu alın
  - `FIB_API_URL` ve `FIB_MERCHANT_ID` yapılandır
  - `lib/features/payments/data/gateways/fib_gateway.dart` canlı test

- [ ] **FastPay**
  - Resmi API dokümantasyonu alın
  - `FASTPAY_API_URL` yapılandır
  - Canlı ödeme testi

- [ ] **Switch**
  - Resmi API dokümantasyonu alın
  - `SWITCH_API_URL` yapılandır
  - Canlı ödeme testi

- [ ] **Nebula POS**
  - Kasa PC'ye WebService kur (`Nebula Solution for all 20250820/` — yerel klasör)
  - WebService başlat (varsayılan port: `9092`)
  - POS cihazını USB / WiFi / Cloud ile bağla
  - `flutter run -d windows --dart-define=NEBULA_URL=http://localhost:9092 --dart-define=USE_DEMO_FALLBACK=false`
  - Sale / PreAuth / `subscribe` + `replyURL` callback testi

---

## P2 — UI / lokalizasyon polish

- [ ] **l10n tam kapsam**
  - Admin sayfaları (dashboard, filo, müşteriler, ayarlar) — hâlâ sabit Türkçe metinler var
  - `vehicles_page.dart`, `public_footer.dart`, `booking_search_bar.dart`
  - Trust badges bölümü

- [ ] **Kürtçe (Sorani) font desteği**
  - Arap/Kürt metinlerde font render kontrolü
  - Gerekirse Noto Naskh Arabic / custom font ekle

---

## P3 — Admin operasyon geliştirmeleri

- [ ] **Filo CRUD**
  - Araç ekleme / düzenleme / silme UI
  - `create_vehicle` RPC (migration gerekli)

- [ ] **Müşteri düzenleme**
  - Mevcut listeye edit / kara liste aksiyonu

- [ ] **Rezervasyon detay sayfası**
  - Tek rezervasyon görünümü, ödeme geçmişi, inspection log

- [ ] **Dashboard Gantt**
  - Filo doluluk takvimi (şu an KPI önizleme)

- [ ] **Audit log görüntüleyici**
  - `audit_logs` tablosu hazır, UI yok

---

## P4 — Bildirim & entegrasyonlar

- [ ] **SMS bildirimleri**
  - Rezervasyon onayı, teslim hatırlatma, iade hatırlatma
  - Irak SMS sağlayıcı seçimi

- [ ] **WhatsApp entegrasyonu**
  - `tenant_branding.whatsapp_number` ile deep link / Business API

- [ ] **E-posta bildirimleri**
  - Rezervasyon onay maili, fatura PDF

---

## P5 — Multi-tenant & ölçekleme

- [ ] **Kiracı onboarding**
  - Yeni firma kaydı, subdomain (`slug.rentacar.app`)
  - Plan limitleri (`max_vehicles`)

- [ ] **Gerçek Supabase Auth veya JWT refresh**
  - Mevcut: demo + bcrypt RPC
  - Production: token yenileme, rol bazlı RLS

- [ ] **Production deployment**
  - PostgreSQL managed (Supabase / AWS RDS)
  - PostgREST veya Supabase API
  - Flutter web hosting (Firebase / Cloudflare)
  - SSL, custom domain

---

## P6 — Mobil & saha uygulaması

- [ ] **Android build**
  ```bash
  flutter build apk --release
  ```

- [ ] **iOS build**
  ```bash
  flutter build ios --release
  ```

- [ ] **Saha uygulaması (`APP_MODE=field`)**
  - Check-in/out mobil akış
  - Offline destek (Drift / Hive)
  - Kamera ile hasar fotoğrafı (image_picker mevcut)

---

## P7 — Test & kalite

- [ ] **Unit testler**
  - Repository katmanı (mock Supabase)
  - Payment gateway'ler

- [ ] **Integration testler**
  - Rezervasyon + ödeme + fatura akışı

- [ ] **E2E testler**
  - Admin login → check-in → check-out senaryosu

- [ ] **CI genişletme**
  - `.github/workflows/ci.yml` — integration test job
  - Docker compose ile CI backend

---

## Tamamlanan (referans)

| Modül | Durum |
|-------|--------|
| Vitrin sitesi (hero, araç listesi, rezervasyon wizard) | ✅ |
| 4 dil (ar, tr, en, ckb Sorani) + RTL | ✅ |
| Irak ödemeleri (FIB, FastPay, Switch, Nebula iskelet) | ✅ |
| Admin: dashboard, filo, rezervasyonlar, müşteriler, ödemeler | ✅ |
| Admin: raporlar, bakım, faturalar, web ayarları | ✅ |
| Auth (demo + bcrypt RPC) | ✅ |
| Check-in/out + hasar fotoğrafı | ✅ |
| Rezervasyon iptali | ✅ |
| IQD para birimi | ✅ |
| DB migration 001–004 | ✅ |
| GitHub push | ✅ |

---

## Hızlı başlangıç komutları

```bash
# Backend
docker compose up -d

# Vitrin (demo)
flutter run -d chrome

# Admin
flutter run -d chrome --dart-define=APP_MODE=admin

# Canlı API
flutter run -d chrome \
  --dart-define=USE_DEMO_FALLBACK=false \
  --dart-define=API_URL=http://localhost:3000 \
  --dart-define=NEBULA_URL=http://localhost:9092
```

Detaylı Irak ödeme kurulumu: [docs/IRAQ_PAYMENTS.md](docs/IRAQ_PAYMENTS.md)
