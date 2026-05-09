# 💰 MyFinance — Personal Finance Tracker

แอปบันทึกรายรับรายจ่ายส่วนตัว สร้างด้วย Flutter + SQLite เก็บข้อมูลในเครื่อง ไม่ต้องพึ่ง Backend หรืออินเทอร์เน็ต

---

## ✨ Features

- 💵 **บันทึกรายรับ/รายจ่าย** — เพิ่ม แก้ไข ลบ transaction ได้ทันที
- 🏷️ **หมวดหมู่** — จัดกลุ่มรายการ เช่น อาหาร, เดินทาง, เงินเดือน
- 📊 **Dashboard** — ยอดรวมเดือนนี้, รายรับ vs รายจ่าย, กราฟ Pie/Bar
- 📅 **ดูย้อนหลังรายเดือน** — สรุปแต่ละเดือน, เทียบเดือนที่แล้ว
- 🔍 **ค้นหา & กรอง** — กรองตามวัน, หมวด, ประเภท (รับ/จ่าย)
- 📝 **บันทึกโน้ต** — แนบรายละเอียดให้แต่ละรายการ
- 🌙 **Dark Mode** — สลับ Light/Dark theme ได้ จำการตั้งค่าไว้
- 🗃️ **Offline First** — เก็บข้อมูลใน SQLite บนเครื่อง ใช้ได้โดยไม่มีเน็ต
- 📤 **Export CSV** — ส่งออกข้อมูลเป็นไฟล์ CSV เพื่อนำไปใช้ต่อ

---

## 🧱 Tech Stack

### Core
| Technology | เหตุผลที่เลือก |
|------------|---------------|
| Flutter 3 | Cross-platform iOS + Android, UI สวย |
| Dart | ภาษาหลักของ Flutter, type-safe |
| SQLite (sqflite) | เก็บข้อมูล local ไม่ต้องมี backend |
| Provider | State management เรียบง่าย เหมาะมือกลาง |

### Packages
| Package | ใช้ทำอะไร |
|---------|-----------|
| `sqflite` | SQLite database บน mobile |
| `path` | จัดการ path ของ database file |
| `provider` | State management |
| `fl_chart` | กราฟ Pie, Bar, Line สวยงาม |
| `table_calendar` | ปฏิทินเลือกวันที่ |
| `intl` | Format วันที่และตัวเลขสกุลเงิน |
| `shared_preferences` | จำ theme setting |
| `csv` | Export ข้อมูลเป็น CSV |
| `share_plus` | แชร์ไฟล์ออกจากแอป |
| `uuid` | Generate unique ID |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────┐
│                  Flutter UI Layer                │
│  Dashboard │ Transactions │ Add/Edit │ Summary   │
│  Light/Dark Mode Toggle                          │
└─────────────────┬───────────────────────────────┘
                  │ Provider (State Management)
┌─────────────────▼───────────────────────────────┐
│               Provider Layer                     │
│                                                  │
│  TransactionProvider  →  CRUD, Filter, Summary   │
│  CategoryProvider     →  Manage categories       │
│  ThemeProvider        →  Dark/Light mode         │
└─────────────────┬───────────────────────────────┘
                  │ Repository Pattern
┌─────────────────▼───────────────────────────────┐
│              Repository Layer                    │
│                                                  │
│  TransactionRepository  →  Query, Insert, Update │
│  CategoryRepository     →  Category CRUD         │
└─────────────────┬───────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────┐
│           SQLite Database (Local)                │
│                                                  │
│  transactions   │  categories                   │
│  ─────────────  │  ──────────                   │
│  id             │  id                           │
│  amount         │  name                         │
│  type           │  type (income/expense)        │
│  category_id    │  icon                         │
│  note           │  color                        │
│  date           │                               │
│  created_at     │                               │
└─────────────────────────────────────────────────┘
```

---

## 📁 Project Structure

```
myfinance/
├── lib/
│   ├── main.dart
│   ├── app.dart                      # MaterialApp + ThemeProvider
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart       # Color palette
│   │   │   └── app_strings.dart      # Text constants
│   │   ├── theme/
│   │   │   └── app_theme.dart        # Light + Dark theme
│   │   └── utils/
│   │       ├── currency_formatter.dart
│   │       └── date_formatter.dart
│   │
│   ├── data/
│   │   ├── database/
│   │   │   └── database_helper.dart  # SQLite init, migration
│   │   ├── models/
│   │   │   ├── transaction.dart
│   │   │   └── category.dart
│   │   └── repositories/
│   │       ├── transaction_repository.dart
│   │       └── category_repository.dart
│   │
│   ├── providers/
│   │   ├── transaction_provider.dart
│   │   ├── category_provider.dart
│   │   └── theme_provider.dart
│   │
│   └── ui/
│       ├── screens/
│       │   ├── dashboard/
│       │   │   └── dashboard_screen.dart
│       │   ├── transactions/
│       │   │   ├── transaction_list_screen.dart
│       │   │   └── add_edit_transaction_screen.dart
│       │   ├── summary/
│       │   │   └── monthly_summary_screen.dart
│       │   └── settings/
│       │       └── settings_screen.dart
│       │
│       └── widgets/
│           ├── transaction_card.dart
│           ├── balance_card.dart
│           ├── pie_chart_widget.dart
│           ├── bar_chart_widget.dart
│           └── category_chip.dart
│
├── assets/
│   └── icons/
│
├── test/
│   ├── unit/
│   └── widget/
│
├── pubspec.yaml
└── README.md
```

---

## 🗄️ Database Schema

```sql
-- หมวดหมู่
CREATE TABLE categories (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  name       TEXT    NOT NULL,
  type       TEXT    NOT NULL,   -- 'income' | 'expense'
  icon       TEXT    NOT NULL,   -- emoji icon
  color      TEXT    NOT NULL,   -- hex color string
  is_default INTEGER DEFAULT 0
);

-- รายการธุรกรรม
CREATE TABLE transactions (
  id          TEXT    PRIMARY KEY,  -- UUID
  amount      REAL    NOT NULL,
  type        TEXT    NOT NULL,     -- 'income' | 'expense'
  category_id INTEGER NOT NULL,
  note        TEXT,
  date        TEXT    NOT NULL,     -- ISO8601: yyyy-MM-dd
  created_at  TEXT    NOT NULL,
  FOREIGN KEY (category_id) REFERENCES categories(id)
);
```

### หมวดหมู่เริ่มต้น (Seed Data)

| หมวด | ประเภท | Icon |
|------|--------|------|
| เงินเดือน | รายรับ | 💼 |
| รายได้อื่นๆ | รายรับ | 💰 |
| อาหาร | รายจ่าย | 🍜 |
| เดินทาง | รายจ่าย | 🚗 |
| ช้อปปิ้ง | รายจ่าย | 🛍️ |
| ค่าบ้าน | รายจ่าย | 🏠 |
| สุขภาพ | รายจ่าย | 💊 |
| บันเทิง | รายจ่าย | 🎮 |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / VS Code
- Android Emulator หรือ iOS Simulator

### ติดตั้งและรัน

```bash
# Clone โปรเจค
git clone https://github.com/tanachotkub/MyFinance-Personal-Finance-Tracker.git
cd myfinance

# ติดตั้ง dependencies
flutter pub get

# รันบน emulator/device
flutter run

# Build APK (Android)
flutter build apk --release

# Build App Bundle สำหรับ Play Store
flutter build appbundle --release
```

### ⚠️ Setup สำหรับ Release Build

ไฟล์ `key.properties` และ `upload-keystore.jks` ไม่ได้อยู่ใน repo เพื่อความปลอดภัย ต้องตั้งค่าเองก่อน build release:

1. วางไฟล์ `upload-keystore.jks` ไว้ที่ `android/`
2. สร้างไฟล์ `android/key.properties` แล้วใส่ข้อมูลดังนี้:

```properties
storeFile=../upload-keystore.jks
storePassword=your_password
keyAlias=upload
keyPassword=your_password
```

> ขอไฟล์ keystore จาก owner โดยตรง หรือสร้างใหม่สำหรับ development ของตัวเอง

---

## ⚙️ Environment & Config

```dart
// lib/core/constants/app_config.dart

class AppConfig {
  static const String dbName         = 'myfinance.db';
  static const int    dbVersion      = 1;
  static const String currencySymbol = '฿';
  static const String defaultLocale  = 'th_TH';
}
```

---

## 📡 Data Flow

```
User Action (UI)
      │
      ▼
Provider.method()          ← ChangeNotifier
      │
      ▼
Repository.query()         ← Business logic
      │
      ▼
DatabaseHelper.rawQuery()  ← SQLite
      │
      ▼
notifyListeners()          ← UI rebuilds automatically
```

---

## 🖥️ หน้าจอหลัก

| หน้า | รายละเอียด |
|------|-----------|
| **Dashboard** | ยอดรวมเดือนนี้, กราฟ Pie แยกหมวด, รายการล่าสุด 5 รายการ |
| **รายการทั้งหมด** | List ทุก transaction, กรองตามวัน/หมวด/ประเภท |
| **เพิ่ม/แก้ไข** | Form กรอกจำนวนเงิน, หมวด, วันที่, โน้ต |
| **สรุปรายเดือน** | Bar chart แต่ละเดือน, Breakdown ตามหมวดหมู่ |
| **ตั้งค่า** | Dark mode, สกุลเงิน, Export CSV, ล้างข้อมูล |

---

## 🌙 Dark Mode

- สลับ Light/Dark ได้จากหน้า Settings
- จำการตั้งค่าไว้ใน `SharedPreferences`
- โหลดครั้งแรกตาม System Preference อัตโนมัติ

---

## 🗺️ Roadmap

- [x] **v0.1.0** — Database helper + Models + Repository layer
- [x] **v0.2.0** — CRUD transactions + Category management
- [x] **v0.3.0** — Dashboard + ยอดรวมรายเดือน
- [x] **v0.4.0** — กราฟ Pie/Bar ด้วย fl_chart
- [x] **v0.5.0** — ค้นหา & กรอง transactions
- [x] **v0.6.0** — สรุปรายเดือน + เทียบเดือนที่แล้ว
- [x] **v0.7.0** — Dark Mode + Settings screen
- [x] **v0.8.0** — Export CSV + Share
- [ ] **v1.0.0** — ตั้ง budget limit แต่ละหมวด + แจ้งเตือน
- [ ] **v1.1.0** — Widget หน้า Home Screen (Android)
- [ ] **v1.2.0** — Backup/Restore ข้อมูลผ่าน Google Drive

---

## 🎓 สิ่งที่ได้เรียนรู้

| หัวข้อ | รายละเอียด |
|--------|-----------|
| SQLite | CRUD, Foreign Key, Migration, Seed data |
| Provider | ChangeNotifier, MultiProvider, Consumer |
| Repository Pattern | แยก business logic ออกจาก UI |
| fl_chart | PieChart, BarChart, LineChart |
| Form Validation | TextFormField, GlobalKey\<FormState\> |
| DateTime | Format, Parse, Filter by month/year |
| Dark Mode | ThemeMode, SharedPreferences |
| CSV Export | สร้าง CSV file + share ออกจากแอป |
| Flutter Navigation | Navigator 2.0, Named routes |
| State Management | Provider pattern ทั้งแอป |
| Android Release Build | Keystore, signing config, build.gradle.kts |
| Play Store | App bundle, target SDK, Ad ID declaration |

---

## 📄 License

MIT License — ใช้ได้อย่างอิสระ

---

> 💡 โปรเจคนี้สร้างขึ้นเพื่อฝึก Flutter + SQLite โดยเน้น Offline-first และ Clean Architecture แบบเรียบง่าย เหมาะสำหรับใช้งานส่วนตัวจริง