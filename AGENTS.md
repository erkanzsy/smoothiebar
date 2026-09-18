# AGENTS.md — SmoothieBar (iOS oyun, Swift)

Restoran zaman-yönetimi oyunu. App Store fırsat taramasının (apptracker, 2026-09-18) en yüksek
skorlu boşluğundan doğdu: Flipline "Papa's To Go" serisi 2019'dan beri güncellenmiyor ama hâlâ
6 ülkede paid chart'ta. Bu proje o boşluğun modern, Swift-native karşılığı.

**Ürün DNA'sı:** tek elle dikey oynanış · sipariş al → hazırla → karıştır → servis et döngüsü ·
premium $1.99 · IAP/abonelik/reklam YOK · 7 dil (EN,DE,FR,NL,ES,PT,TR) · Game Center + iCloud kayıt ·
portföy stratejisi: aynı motor sonradan farklı temalara çoğaltılacak (Flipline modeli).

## Derleme / çalıştırma

- Xcode projesi `project.yml` (xcodegen) ile üretilir — `SmoothieBar.xcodeproj` commit EDİLMEZ:
  `project.yml` değişince `xcodegen generate` çalıştır
- Build doğrulama (CI'sız):
  `xcodebuild -project SmoothieBar.xcodeproj -scheme SmoothieBar -destination 'generic/platform=iOS Simulator' build`
- Simülatörde aç: `open SmoothieBar.xcodeproj` → Run (iPhone 16, iOS 18+)
- Test/CI yok henüz; doğrulama = build başarılı + simülatörde gün döngüsü oynanır durumda
- Cihaza atmak için signing team gerekli (simülatör için gerekmez)

## Mimari

- Tek target: `SmoothieBar` (iOS 17+). Üçüncü parti bağımlılık YOK — SPM ekleme
- Katmanlar:
  - `Game/DayEngine.swift` — tüm oyun mantığı: `@MainActor final class DayEngine: ObservableObject`.
    UI'sız, saf Swift; skorlama `static func`'lerle test edilebilir
  - `Views/` — SwiftUI ekranları; mantık yazma, sadece `engine` çağır ve render et
  - `Resources/Assets.xcassets` — renkler/ikonlar (v0: emoji tabanlı, sanat sonra)
- SpriteKit HENÜZ YOK. Karıştırma animasyonu/juice görselleştirme istasyona geçildiğinde
  `Views/` altına `SpriteKit` sahne eklenecek; SwiftUI shell kalır

## Anlamsal kararlar (değiştirme)

- Portrait-only, iPhone-only (`TARGETED_DEVICE_FAMILY=1`); iPad sonra
- Fiyat modeli: premium tek alım $1.99. Free/lite versiyon veya IAP ancak v2'de tartışılır
- Skorlama: doğru meyve başına +20, fazla/yanlış -5, tam eşleşme bonusu +30 (DayEngine.score)
- Doğrama bonusu: taban skor × kalite × 0.2 (DayEngine.chopBonus, maks %20); çekirdek skorlama değişmez
- Export compliance: `ITSAppUsesNonExemptEncryption=NO` — yalnızca standart HTTPS, özel şifreleme yok
- Gün = 5 sipariş; blender kapasitesi 5; sipariş 2-4 meyve
- Diller String Catalog ile (`Localizable.xcstrings`, Xcode otomatik üretir) — kodda String
  bırakma, `Text("key")` lokalizasyona hazır olsun (mevcut v0 stub'ları TR, v1 öncesi taşıyacak)
- Oyun içi metrikler/chart analitik: Phase 2'de (önce oyun)

## Yol haritası (v1 = 4-6 hafta)

1. Hafta 1: çekirdek döngü ✅ (v0 stub: sipariş → meyve seç → servis → skor) · müşteri sabır
   zamanlayıcısı · gün sonu ekranı + kazanç
2. Hafta 2: istasyon mekanikleri (doğrama ✅ / karıştırma minigame'leri) · haptics (doğrama tap
   ✅) · ses · 30 level data · Game Center leaderboard
3. Hafta 3-4: sanat (modern soft-3D stil) · yükseltme ekonomisi · iCloud kayıt ·
   lokalizasyon 7 dil · TestFlight
4. Hafta 5-6: ASO (anahtar kelimeler: smoothie game, juice bar, cooking game) ·
   ekran görüntüleri · App Store submission ($1.99)

## Kod stili

- SwiftUI deklaratif; `@StateObject` sadece view sahipliğinde, motor tek instance
- Yorum yazma — kod kendini anlatsın; tasarım kararları bu dosyada
- Emoji = geçici sanat; asset yolu açılınca `Fruit.emoji` çağrılarını Image'a çevir
- Her PR'dan önce: `xcodegen generate` (project.yml deşti ise) + yukarıdaki xcodebuild komutu
