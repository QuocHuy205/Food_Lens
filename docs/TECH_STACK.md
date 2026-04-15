# 🔧 TECH STACK — Chi tiết công nghệ

---

## Flutter

- **Version:** 3.x stable
- **Language:** Dart 3.x
- **Platform target:** Android (chính), iOS (optional)

### Packages chính:

| Package | Version | Mục đích |
|---------|---------|---------|
| `firebase_core` | ^3.1.0 | Kết nối Firebase |
| `firebase_auth` | ^5.1.0 | Authentication |
| `cloud_firestore` | ^5.1.0 | NoSQL database |
| `flutter_riverpod` | ^2.5.1 | State management |
| `riverpod_annotation` | ^2.3.5 | Code generation |
| `go_router` | ^14.1.4 | Navigation |
| `dio` | ^5.4.3 | HTTP client |
| `image_picker` | ^1.1.2 | Camera + gallery |
| `cached_network_image` | ^3.3.1 | Image caching |
| `fl_chart` | ^0.68.0 | Charts/graphs |
| `intl` | ^0.19.0 | Date formatting |
| `uuid` | ^4.4.0 | Generate UUIDs |
| `logger` | ^2.3.0 | Debug logging |

---

## Firebase

### Authentication
- Provider: Email/Password
- Tự động handle session persistence
- `authStateChanges()` stream cho auth guard

### Cloud Firestore
- NoSQL document database
- Offline persistence enabled
- Security rules based on `request.auth.uid`

### Lý do chọn Firebase:
- Miễn phí (Spark plan đủ cho demo)
- Setup nhanh
- Không cần backend server riêng cho auth/db
- Real-time updates
- Offline support tốt

---

## Cloudinary

- **Mục đích:** Lưu trữ ảnh món ăn
- **Upload preset:** Unsigned (không cần API secret trên client)
- **Free tier:** 25GB storage, 25GB bandwidth/tháng
- **URL format:** `https://res.cloudinary.com/{cloud_name}/image/upload/{public_id}`

### Tại sao không dùng Firebase Storage?
- Cloudinary có CDN tốt hơn
- Transform ảnh tự động (resize, compress)
- Miễn phí tier rộng hơn cho prototype

---

## AI Backend

### Option A: Mock FastAPI (cho demo)
- Python + FastAPI
- Rule-based + random confidence
- Chạy local hoặc deploy lên Render/Railway miễn phí

### Option B: Real AI (nếu có thời gian)
- Model: MobileNetV2 hoặc EfficientNetB0 (nhẹ hơn cho mobile)
- Framework: TensorFlow/Keras hoặc PyTorch
- Dataset: Vietnamese Food 101 hoặc tự thu thập
- Deploy: FastAPI + Docker → Render/Fly.io

### Model training (nếu làm thật):
```python
# Transfer learning với MobileNetV2
base_model = MobileNetV2(weights='imagenet', include_top=False)
base_model.trainable = False  # Freeze base

model = Sequential([
    base_model,
    GlobalAveragePooling2D(),
    Dense(256, activation='relu'),
    Dropout(0.5),
    Dense(num_classes, activation='softmax')
])

model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])
```

---

## Deployment (cho demo bảo vệ)

| Service | Dùng cho | Chi phí |
|---------|---------|---------|
| Firebase (Spark) | Auth + Firestore | Miễn phí |
| Cloudinary | Image storage | Miễn phí |
| Render.com | Mock AI API | Miễn phí (sleep sau 15 phút idle) |
| Local device | Flutter app | - |

> **Tip demo:** Warm up Render server trước bảo vệ 2 phút bằng cách gửi 1 request test.
