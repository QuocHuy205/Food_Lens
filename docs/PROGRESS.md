# ✅ TIẾN ĐỘ DỰ ÁN — Food Lens AI

> Mục tiêu hiện tại: giữ app/server đồng bộ với model đã train, khóa lại mapping dinh dưỡng cho 100 class, đồng bộ Daily Calories theo TDEE profile, và hoàn tất kiểm tra end-to-end ổn định.

---

## 📊 TỔNG QUAN HIỆN TẠI

| Hạng mục             | Trạng thái       | Ghi chú                                                  |
| -------------------- | ---------------- | -------------------------------------------------------- |
| Server AI            | ✅ Hoàn tất core | FastAPI đã có `/health`, `/predict`, `/analyze`          |
| Model train          | ✅ Hoàn tất      | Model đã train lại, export `.h5` và `.tflite`            |
| App Flutter          | ✅ Hoàn tất core | Clean Architecture, Riverpod, Dio, Firestore, Cloudinary |
| Auth                 | ✅ Hoàn tất      | Login/Register/Google/Forgot Password                    |
| Profile              | ✅ Hoàn tất      | Firestore profile + BMI/TDEE + legacy target migrate     |
| Scan flow            | ✅ Hoàn tất      | Upload ảnh, analyze, hiển thị result, lưu history        |
| History/Daily log    | ✅ Hoàn tất core | Firestore-backed, edit quantity + sync calories          |
| Daily Calories       | ✅ Hoàn tất      | Lấy target từ TDEE profile, không còn default 2200       |
| Stats/Recommendation | ✅ Hoàn tất core | Dashboard + calories/macros                              |
| UI/UX polish         | ✅ Hoàn tất      | 10 screens đã được design đồng bộ                        |
| Testing              | 🟡 Đang kiểm tra | Cần verify end-to-end lần cuối sau các chỉnh sửa mapping |
| Release APK          | ⏳ Chưa chốt     | Debug build ok, release build cần chạy lại khi cần       |

---

## ✅ NHỮNG PHẦN ĐÃ XONG

### 1) AI Server

- FastAPI runtime đã sẵn sàng với các endpoint chính.
- Model đã được train lại để giảm underfitting.
- Có file export `model_v1.h5` và `model_v1.tflite`.
- Kết quả eval hiện tại:
  - loss: `1.7821`
  - accuracy: `0.5376` (`53.76%`)
  - top-3 accuracy: `0.7278` (`72.78%`)

### 2) App Flutter

- Auth, Profile, Home, Scan, History, Stats, Settings đều đã wire.
- Scan flow đi đúng tầng: upload Cloudinary -> gọi AI server -> hiển thị result -> lưu Firestore.
- App đang ưu tiên API call + state management, không đặt business logic trong UI.
- Daily Calories ở Home lấy `dailyCalorieTarget` từ profile; profile cũ có giá trị legacy `2200` sẽ được normalize sang TDEE khi load.
- Scan Result và History đã đồng bộ format hiển thị calories và snackbar khi lưu/chỉnh số lượng.

### 3) Mapping dữ liệu

- `nutrition_db.py` đã được cập nhật để không còn rơi về label chung quá sớm.
- Các class thiếu mapping sẽ được sinh tên tiếng Việt hợp lý thay vì luôn hiển thị “Món ăn hỗn hợp”.

---

## 🔎 ĐIỂM CẦN CHỐT

- Cần restart server để nạp lại thay đổi trong `ai_server/nutrition_db.py`.
- Cần test lại các class cụ thể, nhất là `bun_dau_mam_tom`, để xác nhận `food_name_vi` không còn fallback sai.
- Cần kiểm tra lại luồng scan thật trên app sau khi server reload.
- Nếu user vẫn thấy 2200 ở Home, kiểm tra profile Firestore cũ và luồng normalize trong `ProfileRepositoryImpl` trước khi sửa UI.
- Nếu còn lint/info cũ, xử lý theo từng nhóm nhỏ, không refactor lan rộng.

---

## 🧪 VALIDATION ĐÃ CÓ

- `flutter run` đã chạy thành công trong session trước.
- Model training và evaluation đã chạy xong.
- AI server trước đó đã phục vụ request phân tích thành công.
- `flutter analyze` đã chạy sạch sau các thay đổi Daily Calories và quantity/history.

---

## 📌 NEXT STEPS

1. Restart AI server.
2. Gửi lại request thật để kiểm tra `food_name`, `food_name_vi`, `top_predictions`.
3. Xác nhận Home Daily Calories lấy đúng TDEE từ profile và không còn default 2200.
4. Chạy lại `flutter run` nếu cần xác minh UI trên device.

---

## 📎 GHI CHÚ NGẮN

- Server xử lý AI, app chỉ gọi API và hiển thị UI.
- Không thêm logic nghiệp vụ vào widget.
- Giữ thay đổi nhỏ, tập trung vào correctness trước khi tối ưu thêm.
