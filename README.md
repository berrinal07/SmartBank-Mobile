# SmartBank Mobile

SmartBank, kullanıcıların banka hesaplarını yönetebildiği, para transferi gerçekleştirebildiği ve finansal işlemlerini takip edebildiği bir mobil bankacılık uygulamasıdır.

Bu repository, SmartBank projesinin **Flutter mobil uygulamasını** içerir.

##  Özellikler

*  Kullanıcı giriş işlemleri
*  JWT tabanlı kimlik doğrulama
*  Access token yenileme
*  Çoklu banka hesabı yönetimi
*  Vadesiz ve vadeli hesap desteği
*  Hesaplar arası ve kullanıcılar arası para transferi
*  İşlem geçmişi
*  Bildirimler ve okunmamış bildirim sayacı
*  Profil bilgilerini görüntüleme ve güncelleme
*  Şifre değiştirme
*  Güvenli çıkış
*  Pull-to-refresh ve infinite scroll
*  Loading, hata ve boş durum yönetimi

##  Teknolojiler

* **Flutter**
* **Dart**
* **Riverpod** — State management
* **Dio** — HTTP client
* **flutter_secure_storage** — Güvenli token saklama

##  Proje Yapısı

Proje, **feature-based** bir klasör yapısı ve katmanlı bir organizasyon kullanmaktadır.

```text
lib/
├── core/
│   ├── constants/
│   ├── network/
│   ├── storage/
│   └── theme/
│
├── features/
│   │
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   └── services/
│   │   ├── domain/
│   │   │   └── providers/
│   │   └── presentation/
│   │       ├── screens/
│   │       └── widgets/
│   │
│   ├── accounts/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   └── services/
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   └── providers/
│   │   └── presentation/
│   │       └── screens/
│   │
│   ├── dashboard/
│   │   └── presentation/
│   │       └── screens/
│   │
│   ├── transfers/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   └── services/
│   │   ├── domain/
│   │   │   └── providers/
│   │   └── presentation/
│   │       └── screens/
│   │
│   ├── transactions/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   └── services/
│   │   ├── domain/
│   │   │   └── providers/
│   │   └── presentation/
│   │       └── screens/
│   │
│   ├── notifications/
│   │   ├── data/
│   │   ├── domain/
│   │   │   └── models/
│   │   └── presentation/
│   │       ├── providers/
│   │       └── screens/
│   │
│   └── profile/
│       ├── data/
│       │   ├── models/
│       │   └── services/
│       ├── domain/
│       │   └── providers/
│       └── presentation/
│           └── screens/
│
├── shared/
│   └── widgets/
│
└── main.dart
```

### Core

Uygulamanın feature'lar tarafından ortak kullanılan altyapı bileşenlerini içerir.

* `constants/` — Uygulama genelinde kullanılan sabitler
* `network/` — API ve HTTP iletişimi
* `storage/` — Güvenli veri ve token saklama işlemleri
* `theme/` — Uygulamanın tema ve görsel yapılandırmaları

### Features

Uygulamanın temel özellikleri feature-based olarak ayrılmıştır.

Her feature, ihtiyacına göre `data`, `domain` ve `presentation` katmanlarını içerir.

* `data/` — API servisleri ve veri modelleri
* `domain/` — Provider ve domain modelleri
* `presentation/` — Kullanıcı arayüzü ve ekranlar

Başlıca feature'lar:

* `auth/` — Kullanıcı kayıt, giriş ve authentication işlemleri
* `accounts/` — Banka hesaplarının yönetimi
* `dashboard/` — Ana dashboard ekranı
* `transfers/` — Para transferleri
* `transactions/` — İşlem geçmişi
* `notifications/` — Bildirimler
* `profile/` — Profil ve şifre yönetimi

### Shared

Feature'lar arasında ortak olarak kullanılabilecek UI bileşenlerini içerir.

* `widgets/` — Tekrar kullanılabilir ortak Flutter widget'ları

##  Authentication

Uygulama JWT tabanlı kimlik doğrulama kullanmaktadır.

Authentication akışı:

```text
Login / Register
       ↓
SmartBank Backend API
       ↓
Access Token + Refresh Token
       ↓
Secure Storage
       ↓
API Requests
       ↓
401
 ↓
Token Refresh
 ↓
Yeni Access Token
```

Access ve refresh token bilgileri `flutter_secure_storage` kullanılarak cihaz üzerinde güvenli şekilde saklanmaktadır.

API istekleri `Dio` üzerinden gerçekleştirilmektedir.

##  Uygulama Ekranları

### Dashboard

Kullanıcının hesaplarını, toplam bakiyesini ve hızlı işlem seçeneklerini görüntülediği ana ekrandır.

### Hesaplar

Kullanıcının sahip olduğu banka hesaplarını görüntülemesini ve hesap detaylarına ulaşmasını sağlar.

Desteklenen hesap türleri:

* Vadesiz hesap
* Vadeli hesap

### Para Transferi

Kullanıcının kendi hesapları veya diğer kullanıcıların hesapları arasında para transferi gerçekleştirmesini sağlar.

Transfer sırasında:

* Gönderen hesap seçilebilir.
* Alıcı hesap numarası girilebilir.
* Transfer tutarı belirlenebilir.
* İsteğe bağlı açıklama eklenebilir.

### İşlem Geçmişi

Gerçekleşen finansal işlemlerin listelenmesini sağlar.

Liste aşağı doğru kaydırıldığında daha fazla işlem yüklenebilir.

### Bildirimler

Transfer gibi işlemler sonucunda oluşan bildirimleri görüntüler.

Okunmamış bildirimler ayrıca takip edilir ve bildirimler okundu olarak işaretlenebilir.

### Profil

Kullanıcının kişisel bilgilerini görüntüleyip güncellemesini sağlar.

Ayrıca:

* Şifre değiştirme
* Güvenli çıkış

işlemleri profil ekranı üzerinden gerçekleştirilebilir.

##  Gereksinimler

Projeyi çalıştırabilmek için aşağıdakilerin kurulu olması gerekir:

* Flutter SDK
* Dart SDK
* Android Studio veya Android SDK
* Xcode (iOS geliştirme için)
* Çalışan SmartBank Backend API

Flutter kurulumunu kontrol etmek için:

```bash
flutter doctor
```

##  Projeyi Çalıştırma

Repository'yi klonladıktan sonra proje klasörüne girin:

```bash
cd smartbank_mobile
```

Bağımlılıkları yükleyin:

```bash
flutter pub get
```

Kod analizini çalıştırın:

```bash
flutter analyze
```

Uygulamayı çalıştırın:

```bash
flutter run
```

##  Backend Bağlantısı

SmartBank Mobile, SmartBank Backend API ile haberleşmektedir.

Backend ayrı bir GitHub repository'sinde bulunmaktadır.

Mobil uygulamanın çalışabilmesi için backend API'nin local olarak çalışıyor olması gerekir.

API bağlantısı, mobil uygulamadaki network yapılandırması üzerinden belirlenmektedir.

##  Test

Kod kalitesini kontrol etmek için:

```bash
flutter analyze
```

Uygulamanın temel özellikleri manuel olarak test edilmiştir.

Test edilen başlıca akışlar:

* Kullanıcı kayıt ve giriş
* JWT authentication
* Hesap listeleme ve detay görüntüleme
* Hesap oluşturma
* Para transferi
* İşlem geçmişi
* Bildirimler
* Profil güncelleme
* Şifre değiştirme
* Çıkış yapma

##  Git Branch Yapısı

Projede temel olarak aşağıdaki branch yapısı kullanılmaktadır:

```text
main
  ↑
develop
```

Geliştirme çalışmaları `develop` branch'i üzerinden yürütülmektedir.

Stabil sürümler `main` branch'ine aktarılır.

##  Proje Durumu

SmartBank Mobile uygulamasının temel mobil bankacılık özellikleri tamamlanmıştır.

Mevcut kapsam:

* Authentication
* Dashboard
* Çoklu hesap yönetimi
* Vadesiz ve vadeli hesaplar
* Para transferleri
* İşlem geçmişi
* Bildirimler
* Profil yönetimi
* Şifre değiştirme
* Güvenli çıkış
* UI/UX iyileştirmeleri

Proje, geliştirme ve dokümantasyon aşamalarının sonuna yaklaşmıştır.
