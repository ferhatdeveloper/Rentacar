# Irak — Dil ve Ödeme Entegrasyonu

## Diller

| Kod | Dil | Yön |
|-----|-----|-----|
| `ar` | Arapça | RTL |
| `tr` | Türkçe | LTR |
| `en` | İngilizce | LTR |
| `ckb` | Kürtçe (Sorani) | RTL |

Navbar ve Admin → Ayarlar üzerinden dil seçilebilir. Tercih `shared_preferences` ile saklanır.

Varsayılan dil: **Arapça** (`ar-IQ`).

## Para Birimi

- **IQD** (Irak Dinarı)
- Fiyat gösterimi: `CurrencyFormatter` (RTL dillerde `125000 د.ع`)

## Ödeme Yöntemleri

| Yöntem | Ortam Değişkeni | Açıklama |
|--------|-----------------|----------|
| **FIB** | `FIB_API_URL`, `FIB_MERCHANT_ID` | First Iraqi Bank cüzdan |
| **FastPay** | `FASTPAY_API_URL` | FastPay dijital cüzdan |
| **Switch** | `SWITCH_API_URL` | Switch ödeme geçidi |
| **Nebula** | `NEBULA_URL` | PAX POS WebService (varsayılan: `localhost:9092`) |

Demo modda (`USE_DEMO_FALLBACK=true`) tüm ödemeler simüle edilir.

### Nebula WebService

Dokümantasyon: `Nebula Solution for all 20250820/`

**Kurulum (ECR / kasa bilgisayarı):**
1. Nebula WebService'i Windows'a kurun (`Install on ECR_Windows/`)
2. WebService'i başlatın (varsayılan port: **9092**)
3. POS cihazını USB / WiFi / Cloud ile bağlayın

**Flutter yapılandırması:**
```bash
flutter run -d windows \
  --dart-define=NEBULA_URL=http://localhost:9092 \
  --dart-define=USE_DEMO_FALLBACK=false
```

**API uç noktaları (Postman koleksiyonundan):**

| Metod | Uç Nokta | Açıklama |
|-------|----------|----------|
| GET | `/isConnected` | Terminal bağlantı durumu |
| POST | `/createRequest` | Sale, PreAuth, Refund, Void vb. |
| POST | `/subscribe?replyURL=` | Callback kaydı |
| GET | `/cancelTrans` | İşlem iptali |

**Satış örneği:**
```json
POST /createRequest
{
  "CATEGORY": "com.pax.payment.Sale",
  "parm": {
    "amount": 150000,
    "currencyCode": "IQD"
  }
}
```

Kod: `lib/features/payments/data/gateways/nebula_gateway.dart`
