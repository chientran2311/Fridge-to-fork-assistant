# 🥗 Fridge to Fork Assistant

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![AI](https://img.shields.io/badge/Google%20Gemini-8E75B2?style=for-the-badge&logo=google&logoColor=white)

**Ứng dụng quản lý tủ lạnh thông minh - Giúp bạn tận dụng tối đa nguyên liệu và giảm lãng phí thực phẩm**

[Tính năng](#-tính-năng-chính) • [Cài đặt](#-cài-đặt) • [Hướng dẫn sử dụng](#-hướng-dẫn-sử-dụng) • [Công nghệ](#-công-nghệ-sử-dụng)

</div>

---

## 📖 Giới thiệu

**Fridge to Fork Assistant** là một ứng dụng di động được phát triển bằng Flutter, giúp người dùng quản lý nguyên liệu trong tủ lạnh một cách thông minh và hiệu quả. Ứng dụng sử dụng trí tuệ nhân tạo (AI) để gợi ý công thức nấu ăn dựa trên những nguyên liệu có sẵn, từ đó giúp giảm thiểu lãng phí thực phẩm và tiết kiệm chi phí cho gia đình.

### 🎯 Mục tiêu của dự án

- **Giảm lãng phí thực phẩm**: Nhắc nhở người dùng về những nguyên liệu sắp hết hạn
- **Tiết kiệm thời gian**: Gợi ý công thức nấu ăn phù hợp với nguyên liệu có sẵn
- **Quản lý thông minh**: Theo dõi và quản lý kho thực phẩm dễ dàng
- **Lên kế hoạch bữa ăn**: Hỗ trợ lập kế hoạch bữa ăn cho cả tuần

---

## ✨ Tính năng chính

### 🧊 Quản lý Tủ lạnh (Fridge Management)
- **Thêm nguyên liệu**: Thêm thủ công hoặc quét mã vạch (barcode)
- **Theo dõi hạn sử dụng**: Phân loại nguyên liệu theo độ ưu tiên (Eat Me First / In Stock)
- **Thông báo hết hạn**: Nhận thông báo khi nguyên liệu sắp hết hạn
- **Chỉnh sửa & xóa**: Cập nhật số lượng hoặc xóa nhiều nguyên liệu cùng lúc

### 🍳 Gợi ý Công thức AI (AI Recipe Suggestions)
- **Tạo công thức tự động**: Sử dụng Google Gemini AI để gợi ý món ăn
- **Dựa trên nguyên liệu có sẵn**: Tối ưu hóa việc sử dụng nguyên liệu trong tủ lạnh
- **Lưu công thức yêu thích**: Lưu lại các công thức hay để sử dụng sau
- **Chi tiết công thức**: Xem hướng dẫn nấu ăn chi tiết từng bước

### 📅 Lập kế hoạch Bữa ăn (Meal Planning)
- **Lịch bữa ăn**: Lên kế hoạch bữa ăn cho từng ngày trong tuần
- **Tùy chỉnh linh hoạt**: Thêm, sửa, xóa các bữa ăn dễ dàng
- **Tích hợp công thức**: Thêm công thức vào kế hoạch bữa ăn

### 🛒 Danh sách Mua sắm (Shopping List)
- **Tự động tạo**: Tạo danh sách mua sắm từ kế hoạch bữa ăn
- **Quản lý dễ dàng**: Đánh dấu đã mua, chỉnh sửa số lượng

### 📊 Barcode Scanner
- **Quét mã vạch nhanh**: Thêm nguyên liệu bằng cách quét barcode
- **Tự động điền thông tin**: Nhận diện sản phẩm và điền thông tin tự động
- **Sinh mã vạch**: Công cụ sinh barcode cho nguyên liệu mới

### 🔔 Thông báo thông minh
- **Nhắc nhở hết hạn**: Thông báo khi nguyên liệu sắp hết hạn
- **Deep linking**: Nhấn vào thông báo để đi thẳng đến tính năng liên quan

### 🌐 Đa ngôn ngữ
- Hỗ trợ tiếng Việt và tiếng Anh
- Dễ dàng chuyển đổi trong cài đặt

---

## 🛠 Công nghệ sử dụng

| Công nghệ | Mô tả |
|-----------|-------|
| **Flutter** | Framework phát triển ứng dụng đa nền tảng |
| **Dart** | Ngôn ngữ lập trình chính |
| **Firebase** | Backend-as-a-Service (Authentication, Firestore, Cloud Messaging) |
| **Google Gemini AI** | Tạo công thức nấu ăn bằng AI |
| **Provider** | State Management |
| **GoRouter** | Navigation và Deep Linking |
| **Mobile Scanner** | Quét mã vạch |

---

## 📁 Cấu trúc dự án

```
lib/
├── main.dart                 # Entry point
├── firebase_options.dart     # Firebase configuration
├── data/
│   ├── repositories/         # Data repositories
│   └── services/             # Business logic services
│       ├── auth_service.dart
│       ├── firebase_service.dart
│       ├── gemini_service.dart
│       ├── household_service.dart
│       └── notification_service.dart
├── l10n/                     # Localization files
├── models/                   # Data models
│   ├── ingredient.dart
│   ├── inventory_item.dart
│   ├── household_recipe.dart
│   └── shopping_item.dart
├── providers/                # State management
├── router/                   # App routing
├── screens/                  # UI screens
│   ├── auth/                 # Authentication screens
│   ├── fridge/               # Fridge management
│   ├── recipe/               # Recipe screens
│   ├── meal&plan/            # Meal planning
│   └── settings/             # Settings screens
├── utils/                    # Utility functions
└── widgets/                  # Reusable widgets
```

---

## 🚀 Cài đặt

### Yêu cầu hệ thống

- **Flutter SDK**: >= 3.4.0
- **Dart SDK**: >= 3.4.0
- **Android Studio** hoặc **VS Code**
- **Firebase Account**

### Bước 1: Clone repository

```bash
git clone https://github.com/your-username/fridge-to-fork-assistant.git
cd fridge-to-fork-assistant
```

### Bước 2: Cài đặt dependencies

```bash
flutter pub get
```

### Bước 3: Cấu hình Firebase

1. **Cài đặt FlutterFire CLI:**
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. **Configure Firebase:**
   ```bash
   flutterfire configure
   ```

3. **Thêm Google Services:**
   - Tải `google-services.json` từ Firebase Console
   - Đặt vào thư mục `android/app/`

> 📖 Chi tiết xem thêm tại file [FIREBASE_SETUP.md](FIREBASE_SETUP.md)

### Bước 4: Cấu hình Environment Variables

Tạo file `assets/.env` với nội dung:

```env
GEMINI_API_KEY=your_gemini_api_key_here
```

### Bước 5: Chạy ứng dụng

```bash
# Chạy trên Android
flutter run

# Chạy trên iOS
flutter run -d ios

# Chạy trên Web
flutter run -d chrome

# Build APK
flutter build apk --release

# Build App Bundle (cho Google Play)
flutter build appbundle --release
```

---

## 📱 Hướng dẫn sử dụng

### 1. Đăng ký / Đăng nhập
- Mở ứng dụng và đăng ký tài khoản mới hoặc đăng nhập
- Hỗ trợ đăng nhập bằng Email/Password

### 2. Quản lý Tủ lạnh
- **Thêm nguyên liệu**: Nhấn nút `+` → Nhập thông tin hoặc quét barcode
- **Xem nguyên liệu**: Danh sách hiển thị theo 2 nhóm:
  - 🔴 **Eat Me First**: Nguyên liệu sắp hết hạn (trong 3 ngày)
  - 🟢 **In Stock**: Nguyên liệu còn hạn sử dụng
- **Chỉnh sửa**: Nhấn vào nguyên liệu để sửa thông tin
- **Xóa nhiều**: Nhấn giữ để chọn nhiều nguyên liệu và xóa

### 3. Gợi ý Công thức AI
- Vào tab **Recipe** → Ứng dụng tự động gợi ý công thức dựa trên nguyên liệu
- Nhấn **"Tạo lại công thức"** để lấy gợi ý mới
- Nhấn vào công thức để xem chi tiết

### 4. Lập kế hoạch Bữa ăn
- Vào tab **Meal Plan** → Chọn ngày trong lịch
- Thêm công thức vào các bữa ăn trong ngày

### 5. Cài đặt
- Thay đổi ngôn ngữ (Tiếng Việt / English)
- Quản lý thông báo
- Debug Tools (dành cho developer)

---

## 🗄 Cấu trúc Database (Firestore)

```
Firestore
├── ingredients/              # Master data nguyên liệu
│   └── {ingredientId}
│       ├── name
│       ├── barcode
│       ├── category
│       └── defaultUnit
│
├── households/               # Hộ gia đình
│   └── {householdId}
│       ├── inventory/        # Kho nguyên liệu
│       ├── household_recipes/ # Công thức đã lưu
│       ├── meal_plans/       # Kế hoạch bữa ăn
│       └── shopping_list/    # Danh sách mua sắm
│
└── users/                    # Thông tin người dùng
    └── {userId}
```

---

## 🧪 Debug & Testing

### Seed Database (Khởi tạo dữ liệu mẫu)
1. Mở ứng dụng → **Settings** → **Debug Tools**
2. Nhấn **"Seed Database"** để tạo dữ liệu mẫu

### Barcode Generator
1. **Settings** → **Debug Tools** → **Barcode Generator**
2. Xem và in barcode để test chức năng quét mã

---

## 🤝 Đóng góp

Chúng tôi hoan nghênh mọi đóng góp! Vui lòng:

1. Fork repository
2. Tạo branch mới (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Mở Pull Request

---

## 📄 License

Dự án này được phân phối dưới giấy phép MIT. Xem file `LICENSE` để biết thêm chi tiết.

---

## 📞 Liên hệ

Nếu bạn có câu hỏi hoặc góp ý, vui lòng liên hệ:

- **Email**: chien2977@gmail.com

---

<div align="center">

**⭐ Nếu dự án hữu ích, hãy cho chúng tôi một star! ⭐**

Made with ❤️ by Fridge to Fork Team

</div>

