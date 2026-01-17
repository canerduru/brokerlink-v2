# 🏆 BROKER TRUST SCORE - Detaylı Tasarım Dokümanı

## Ne Demek?

**Broker Trust Score**, her broker için otomatik olarak hesaplanan bir **güvenilirlik puanı**dır. Bu puan, brokerin platformdaki tüm aktivitelerine, başarılarına ve diğer brokerlardan aldığı geri bildirimlere dayanarak hesaplanır.

---

## 🎯 AMAÇ

### Problem:
```
Türkiye'de emlakçılara güven yok.
Müşteri düşünür: "Bu broker güvenilir mi? Komisyonu şişirecek mi?"
Broker düşünür: "Bu diğer broker profesyonel mi? İşbirliği yapmalı mıyım?"
```

### Çözüm:
```
Trust Score = Kanıtlanabilir, şeffaf, manipüle edilemez güven ölçüsü
```

---

## 📊 PUAN SİSTEMİ

### Toplam Puan: 0-100

| Puan Aralığı | Seviye | Rozet |
|--------------|--------|-------|
| 90-100 | 🏆 Elmas Broker | Diamond Elite |
| 80-89 | 🥇 Altın Broker | Gold Trusted |
| 70-79 | 🥈 Gümüş Broker | Silver Reliable |
| 60-69 | 🥉 Bronz Broker | Bronze Growing |
| 40-59 | ⭐ Yeni Broker | Rising Star |
| 0-39 | 🔰 Başlangıç | Newcomer |

---

## 🧮 HESAPLAMA ALGORİTMASI

### Trust Score = Weighted Average of 6 Metrics

```
TRUST_SCORE = (
    PROFILE_SCORE × 0.10 +      // Profil Tamamlama (10%)
    MATCH_SCORE × 0.25 +        // Eşleşme Başarısı (25%)
    RESPONSE_SCORE × 0.15 +     // Yanıt Hızı (15%)
    ACTIVITY_SCORE × 0.15 +     // Aktivite (15%)
    PEER_SCORE × 0.20 +         // Broker Yorumları (20%)
    COMPLETION_SCORE × 0.15     // İşlem Tamamlama (15%)
)
```

---

## 📈 6 METRİK DETAYI

### 1. 📋 PROFILE_SCORE (Profil Tamamlama) - %10

**Ne ölçer:** Brokerin profilini ne kadar eksiksiz doldurduğu

| Alan | Puan |
|------|------|
| Fotoğraf yüklendi | +10 |
| Şirket bilgisi | +10 |
| Lisans numarası | +15 |
| Hizmet bölgeleri | +15 |
| Uzmanlık alanları | +10 |
| İletişim bilgileri | +10 |
| Biyografi | +10 |
| Sosyal medya bağlantıları | +10 |
| Doğrulanmış telefon | +5 |
| Doğrulanmış e-posta | +5 |
| **Toplam:** | **100** |

```javascript
profile_score = (tamamlanan_alanlar / toplam_alanlar) × 100
```

---

### 2. 🤝 MATCH_SCORE (Eşleşme Başarısı) - %25

**Ne ölçer:** Eşleşme onay/red oranı

| Durum | Etki |
|-------|------|
| Onaylanan eşleşme | +5 puan |
| Reddedilen eşleşme | -2 puan |
| Tamamlanan işlem | +15 puan |
| Karşı tarafın reddi | -1 puan |

**Formül:**
```javascript
match_score = min(100, (approved_matches × 5 - rejected_matches × 2 + completed × 15))

// Normalize: 0-100 arasına getir
// Örnek: 10 onay, 2 red, 3 tamamlanan
// = (10×5) - (2×2) + (3×15) = 50 - 4 + 45 = 91
```

**Neden önemli:**
- Gereksiz yere red yapanlar cezalandırılır
- Sadece kaliteli eşleşmeleri kabul edenler ödüllendirilir
- İşlem tamamlayanlar en yüksek puanı alır

---

### 3. ⚡ RESPONSE_SCORE (Yanıt Hızı) - %15

**Ne ölçer:** Eşleşmelere ve mesajlara ne kadar hızlı yanıt verdiği

| Yanıt Süresi | Puan |
|--------------|------|
| < 1 saat | 100 |
| 1-4 saat | 90 |
| 4-12 saat | 75 |
| 12-24 saat | 50 |
| 24-48 saat | 25 |
| > 48 saat | 0 |

**Formül:**
```javascript
avg_response_time = sum(response_times) / count(responses)
response_score = calculateScoreFromTime(avg_response_time)
```

**Neden önemli:**
- Hızlı brokerlar daha güvenilir
- Müşteriler bekletilmek istemez
- Profesyonellik göstergesi

---

### 4. 📊 ACTIVITY_SCORE (Aktivite) - %15

**Ne ölçer:** Platformdaki düzenli aktivite

| Aktivite | Puan/Hafta |
|----------|------------|
| Günlük giriş | +2 |
| Yeni portföy ekleme | +5 |
| Yeni talep ekleme | +5 |
| Eşleşme inceleme | +3 |
| Mesaj gönderme | +2 |
| Profil güncelleme | +3 |

**Formül:**
```javascript
// Son 30 günlük aktivite ortalaması
weekly_activity = sum(activity_points_last_30_days) / 4
activity_score = min(100, weekly_activity × 2)

// Örnek: Haftalık 40 puan → activity_score = 80
```

**Neden önemli:**
- Aktif brokerlar daha güvenilir
- "Hayalet hesaplar" düşük puan alır
- Platform engagement artırır

---

### 5. ⭐ PEER_SCORE (Broker Yorumları) - %20

**Ne ölçer:** Diğer brokerların bu broker hakkındaki görüşleri

**İşbirliği sonrası değerlendirme:**

```
Mert Yılmaz ile işbirliğinizi değerlendirin:

⭐⭐⭐⭐⭐ Profesyonellik
⭐⭐⭐⭐⭐ İletişim
⭐⭐⭐⭐⭐ Doğruluk
⭐⭐⭐⭐⭐ Tekrar çalışır mıyım?

💬 Yorum: "Harika bir işbirliği oldu..."
```

**Formül:**
```javascript
peer_score = (sum(all_ratings) / count(ratings)) × 20

// Örnek: 4.5/5 ortalama → peer_score = 90
```

**Anti-Manipulation:**
- ⚠️ Sadece eşleşme/işlem sonrası yorum yapılabilir
- ⚠️ Kendi kendine puan verme YOK
- ⚠️ Spam yorumlar AI ile tespit edilir
- ⚠️ Karşılıklı bonding tespiti

---

### 6. ✅ COMPLETION_SCORE (İşlem Tamamlama) - %15

**Ne ölçer:** Başlanan işlemlerin ne kadarının tamamlandığı

| İşlem Durumu | Etki |
|--------------|------|
| Tamamlanan satış/kiralama | +20 |
| İptal edilen (broker hatası) | -10 |
| İptal edilen (müşteri) | -2 |
| Devam eden | 0 |

**Formül:**
```javascript
completion_rate = completed_deals / (completed_deals + cancelled_deals)
completion_score = completion_rate × 100

// Örnek: 10 tamamlanan, 2 iptal → 10/12 = 83
```

**Neden önemli:**
- Sadece başlatan değil bitiren brokerlar ödüllendirilir
- Güvenilirliğin en net göstergesi
- Müşteri memnuniyeti

---

## 🖥️ UI/UX TASARIMI

### 1. Dashboard'da Trust Score Kartı:

```
┌─────────────────────────────────────────────┐
│  🏆 GÜVEN PUANINIZ                          │
│                                             │
│     ╭──────────────────╮                    │
│     │       94         │  🥇 Altın Broker   │
│     │   ───────────    │                    │
│     │   ████████░░     │  Top 5% 🔥         │
│     ╰──────────────────╯                    │
│                                             │
│  📊 Detaylar                                │
│  ├─ Profil: 95/100 ████████████░░          │
│  ├─ Eşleşme: 88/100 ████████████░░         │
│  ├─ Yanıt: 100/100 ███████████████         │
│  ├─ Aktivite: 90/100 █████████████░        │
│  ├─ Broker Yorumları: 92/100 ████████████░ │
│  └─ Tamamlama: 95/100 █████████████░       │
│                                             │
│  💡 Puanını Artır: 3 portföy ekle (+5)     │
│  📈 Son 30 gün: +3 puan artış              │
└─────────────────────────────────────────────┘
```

---

### 2. Profil Sayfasında Trust Badge:

```
┌─────────────────────────────────────────────┐
│  👤 Caner Duru                              │
│  Remax Premium | Beşiktaş                   │
│                                             │
│  🏆 94 Trust Score                          │
│  🥇 Altın Broker                            │
│                                             │
│  🏅 Rozetler:                               │
│  ├─ 🌟 Süper Yanıtlayıcı (<1 saat)         │
│  ├─ 🏠 Beşiktaş Uzmanı                      │
│  ├─ 🤝 50+ İşbirliği                        │
│  └─ ⚡ 30 Gün Aktif                         │
│                                             │
│  ⭐ 4.8/5 (23 broker yorumu)                │
│  📊 47 Başarılı Eşleşme                     │
│  ✅ 12 Tamamlanan İşlem                     │
└─────────────────────────────────────────────┘
```

---

### 3. Eşleşme Kartında Trust Gösterimi:

```
┌─────────────────────────────────────────────┐
│  📋 Yeni Eşleşme                            │
│                                             │
│  Mert Yılmaz                                │
│  Remax Premium                              │
│  🏆 87 Trust Score | 🥇 Altın Broker        │
│                                             │
│  "Kadıköy'de Daire Arıyorum"                │
│  40M - 60M TL | Kadıköy                     │
│                                             │
│  💡 Güvenilir broker - İşbirliği önerilir   │
│                                             │
│     [ Reddet ]     [ ✅ Onayla ]            │
└─────────────────────────────────────────────┘
```

---

### 4. Ağ Sekmesinde Sıralama:

```
🔍 "Beşiktaş Daire Uzmanı" ara

Sonuçlar (Trust Score'a göre sıralı):

1. 🥇 Caner Duru - 94 Trust Score
   Beşiktaş Uzmanı | 47 portföy

2. 🥇 Ahmet Yılmaz - 91 Trust Score
   Beşiktaş | 32 portföy

3. 🥈 Mehmet Kaya - 78 Trust Score
   Beşiktaş | 21 portföy
```

---

## 🎮 GAMİFİCATION (Oyunlaştırma)

### Rozetler:

| Rozet | Koşul | 
|-------|-------|
| 🌟 Süper Yanıtlayıcı | Ortalama yanıt < 1 saat |
| 🤝 İşbirliği Ustası | 50+ başarılı eşleşme |
| ⚡ Hız Şampiyonu | 10 işlem < 30 gün |
| 🏠 Bölge Uzmanı | Bir bölgede #1 |
| 💎 Elmas Broker | 90+ Trust Score ulaşma |
| 🔥 Ateşli Başlangıç | İlk 30 günde 70+ score |
| 📈 Yükseliş Trendi | 3 ay üst üste artış |

### Haftalık Liderlik Tablosu:

```
🏆 Bu Hafta En Çok Yükselenler

1. 🚀 Ayşe Demir +8 puan (82 → 90)
2. 📈 Mehmet Kaya +5 puan (73 → 78)
3. ⬆️ Ali Vural +4 puan (68 → 72)
```

---

## 💾 VERİTABANI ŞEMASI

```sql
-- Trust Score Ana Tablosu
CREATE TABLE trust_scores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Ana Skor
    total_score INTEGER DEFAULT 0 CHECK (total_score >= 0 AND total_score <= 100),
    level TEXT DEFAULT 'newcomer',
    
    -- Alt Skorlar
    profile_score INTEGER DEFAULT 0,
    match_score INTEGER DEFAULT 0,
    response_score INTEGER DEFAULT 0,
    activity_score INTEGER DEFAULT 0,
    peer_score INTEGER DEFAULT 0,
    completion_score INTEGER DEFAULT 0,
    
    -- İstatistikler
    total_matches INTEGER DEFAULT 0,
    approved_matches INTEGER DEFAULT 0,
    rejected_matches INTEGER DEFAULT 0,
    completed_deals INTEGER DEFAULT 0,
    total_peer_reviews INTEGER DEFAULT 0,
    avg_response_time_hours DECIMAL(5,2),
    
    -- Metadata
    last_calculated_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    CONSTRAINT unique_user_trust UNIQUE (user_id)
);

-- Broker Yorumları Tablosu
CREATE TABLE peer_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reviewer_id UUID REFERENCES auth.users(id),
    reviewed_id UUID REFERENCES auth.users(id),
    match_id UUID REFERENCES matches(id),
    
    -- Puanlar (1-5)
    professionalism INTEGER CHECK (professionalism >= 1 AND professionalism <= 5),
    communication INTEGER CHECK (communication >= 1 AND communication <= 5),
    reliability INTEGER CHECK (reliability >= 1 AND reliability <= 5),
    would_work_again INTEGER CHECK (would_work_again >= 1 AND would_work_again <= 5),
    
    overall_rating DECIMAL(2,1),
    comment TEXT,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    CONSTRAINT one_review_per_match UNIQUE (reviewer_id, match_id)
);

-- Rozetler Tablosu
CREATE TABLE badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id),
    badge_type TEXT NOT NULL,
    badge_name TEXT NOT NULL,
    earned_at TIMESTAMPTZ DEFAULT NOW(),
    
    CONSTRAINT unique_user_badge UNIQUE (user_id, badge_type)
);

-- Trust Score Geçmişi (Trend için)
CREATE TABLE trust_score_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id),
    total_score INTEGER,
    calculated_at DATE DEFAULT CURRENT_DATE,
    
    CONSTRAINT one_score_per_day UNIQUE (user_id, calculated_at)
);
```

---

## ⚙️ HESAPLAMA TRIGGER'I

```sql
-- Trust Score otomatik güncelleme
CREATE OR REPLACE FUNCTION calculate_trust_score(p_user_id UUID)
RETURNS INTEGER AS $$
DECLARE
    v_profile_score INTEGER;
    v_match_score INTEGER;
    v_response_score INTEGER;
    v_activity_score INTEGER;
    v_peer_score INTEGER;
    v_completion_score INTEGER;
    v_total_score INTEGER;
BEGIN
    -- Her metriği hesapla...
    -- (detaylı implementasyon)
    
    v_total_score := (
        v_profile_score * 0.10 +
        v_match_score * 0.25 +
        v_response_score * 0.15 +
        v_activity_score * 0.15 +
        v_peer_score * 0.20 +
        v_completion_score * 0.15
    )::INTEGER;
    
    -- Kaydet
    INSERT INTO trust_scores (user_id, total_score, ...)
    ON CONFLICT (user_id) DO UPDATE SET ...;
    
    RETURN v_total_score;
END;
$$ LANGUAGE plpgsql;
```

---

## 🚀 İMPLEMENTASYON ADIMLARI

### Faz 1: Temel (2-3 gün)
1. ✅ Veritabanı tablolarını oluştur
2. ✅ Profile score hesaplama
3. ✅ Dashboard'da trust score kartı
4. ✅ Profilde trust badge

### Faz 2: Metrikler (2-3 gün)
1. ✅ Match score hesaplama
2. ✅ Response score hesaplama
3. ✅ Activity score hesaplama

### Faz 3: Peer Review (2-3 gün)
1. ✅ Peer review UI
2. ✅ Review sonrası puan güncelleme
3. ✅ Anti-manipulation kontrolleri

### Faz 4: Gamification (1-2 gün)
1. ✅ Rozet sistemi
2. ✅ Liderlik tablosu
3. ✅ Bildirimler

---

## ❓ SORULAR

1. Hangi fazla başlamak istersin?
2. UI mockup görmek ister misin?
3. Direkt implementasyona geçelim mi?
