# 🎨 UI DESIGN GUIDE — Gợi Ý Thiết Kế Tất Cả Giao Diện

> Hướng dẫn thiết kế chi tiết cho từng màn hình, bao gồm layout, components, states, flow.

---

## 📋 DANH SÁCH 10 SCREENS + COMPONENTS

| Thứ Tự | Route           | Tên Màn               | Trạng Thái     | Mục Đích                             |
| ------ | --------------- | --------------------- | -------------- | ------------------------------------ |
| 1      | `/`             | **SplashScreen**      | ✅ Exists      | Logo → Auto Redirect                 |
| 2      | `/login`        | **LoginScreen**       | 🟡 Placeholder | Email/Password login + Register link |
| 3      | `/register`     | **RegisterScreen**    | 🟡 Placeholder | Signup + Login link                  |
| 4      | `/home`         | **HomeScreen**        | ✅ Exists      | Dashboard + Bottom Nav               |
| 5      | `/scan`         | **ScanScreen**        | ✅ Exists      | Camera/Gallery picker                |
| 6      | `/scan/result`  | **ScanResultScreen**  | ✅ Exists      | AI result + Save button              |
| 7      | `/history`      | **HistoryScreen**     | ✅ Exists      | List scan items                      |
| 8      | `/stats`        | **StatsScreen**       | ✅ Exists      | Charts + Analytics                   |
| 9      | `/profile`      | **ProfileScreen**     | ✅ Exists      | User info + BMI/TDEE                 |
| 10     | `/profile/edit` | **EditProfileScreen** | ✅ Exists      | Form chỉnh sửa profile               |

**+ Shell/Layout:**

- `HomeShell` - Bottom Navigation (tất cả screens 4-10 dùng)
- `AppBar` - Header tùy chỉnh theo màn hình
- `LoadingOverlay` - Loading indicator toàn cảnh
- `ErrorDisplay` - Error dialog/snackbar

---

## 🌈 DESIGN SYSTEM (CỐ ĐỊNH)

### Colors

```
🟢 Primary (Green - Healthy): #2E7D32
🟠 Accent (Orange - Energy): #FF6F00
⚪ Background: #F5F5F5
🤍 Surface: #FFFFFF
🔤 Text Primary: #212121
🔤 Text Secondary: #757575

Meal Colors:
- Breakfast 🌅: #FFB300 (vàng)
- Lunch 🍝: #1976D2 (xanh dương)
- Dinner 🍽️: #7B1FA2 (tím)
- Snack 🍪: #00897B (xanh ngọc)

Status:
✅ Success: #43A047
⚠️ Warning: #FFA000
❌ Error: #D32F2F
```

### Typography

```
Headline 1: 28px Bold (Page title)
Headline 2: 22px Bold (Section title)
Title: 18px SemiBold (Card title)
Body: 14px Regular (Content)
Caption: 12px Regular (Helper text)
Calorie Number: 36px Bold Green (Big numbers)
```

### Spacing & Radius

```
Padding: 16px (standard), 24px (large), 8px (small)
Radius: 12px (cards/buttons), 16px (images), 24px (large)
Border: 1px #E0E0E0 (subtle)
Shadow: elevation 2 (cards)
```

---

## 1️⃣ SPLASH SCREEN (`/`)

### Mục Đích

- Hiển thị logo/brand
- Kiểm tra auth state
- Auto-redirect sau 3s

### UI Layout

```
┌─────────────────────────┐
│                         │
│      🍜 FOOD LENS      │ ← Logo + text
│                         │
│   AI Nutrition Tracker  │ ← Tagline
│                         │
│   [●] Loading...        │ ← Progress indicator
│                         │
│                         │
└─────────────────────────┘
```

### Trạng Thái (States)

- **Loading**: Logo + spinner + "Đang khởi động..."
- **Redirect to Login**: Chưa login → 3s → auto go to `/login`
- **Redirect to Home**: Đã login → 3s → auto go to `/home`

### Variations

- Skip button ở góc trên phải (cho dev/testing)
- Animation fade-in logo
- Themed background (gradient green → light)

---

## 2️⃣ LOGIN SCREEN (`/login`)

### Mục Đích

- Email/Password login
- Link to register
- Forgot password (optional, v2)
- Social login (optional, v2)

### UI Layout

```
┌─────────────────────────┐
│                         │
│      🍜 FOOD LENS      │
│   AI Nutrition Tracker  │
│                         │
│  ┌───────────────────┐  │
│  │ Email             │  │ ← TextField
│  │ [user@email.com]  │  │
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │ Password          │  │ ← TextField (eye icon)
│  │ [●●●●●●●●]       │  │
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │  LOGIN            │  │ ← Button (primary)
│  └───────────────────┘  │
│                         │
│  Chưa có tài khoản?     │
│  Đăng ký ngay           │ ← Link (tappable)
│                         │
│                         │
└─────────────────────────┘
```

### Form Fields

| Field    | Type                 | Validation            |
| -------- | -------------------- | --------------------- |
| Email    | TextField            | required, valid email |
| Password | TextField (obscured) | required, min 6 chars |

### Buttons

- **Primary**: "Đăng nhập" (green, full width, 50px height)
- **Link**: "Không có tài khoản? Đăng ký" (text link to `/register`)
- **Forgot Password**: Optional for v2

### States

- **Idle**: Form ready
- **Loading**: Button shows spinner, fields disabled, "Đang đăng nhập..."
- **Error**: Red snackbar with error message + retry
- **Success**: Auto-redirect to `/home`

### Error Handling

```
❌ Invalid email: "Email không hợp lệ"
❌ Wrong password: "Email hoặc mật khẩu sai"
❌ Network error: "Lỗi kết nối. Thử lại?"
```

---

## 3️⃣ REGISTER SCREEN (`/register`)

### Mục Đích

- Create new account
- Email/Password/Name
- Link to login
- Auto-login after register

### UI Layout

```
┌─────────────────────────┐
│   < Back | Đăng ký     │
├─────────────────────────┤
│                         │
│  ┌───────────────────┐  │
│  │ Tên đầy đủ        │  │
│  │ [Nguyễn Văn A]    │  │
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │ Email             │  │
│  │ [user@email.com]  │  │
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │ Password          │  │
│  │ [●●●●●●●●] ✓      │  │ ← Show strength
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │ Xác nhận Password │  │
│  │ [●●●●●●●●]       │  │
│  └───────────────────┘  │
│                         │
│  ☑ Đồng ý Điều khoản    │ ← Checkbox
│                         │
│  ┌───────────────────┐  │
│  │  ĐĂNG KÝ          │  │
│  └───────────────────┘  │
│                         │
│  Đã có tài khoản?       │
│  Đăng nhập             │ ← Link to login
│                         │
└─────────────────────────┘
```

### Form Fields

| Field            | Type                 | Validation                                 |
| ---------------- | -------------------- | ------------------------------------------ |
| Name             | TextField            | required, min 3 chars                      |
| Email            | TextField            | required, valid email                      |
| Password         | TextField (obscured) | required, min 6 chars + strength indicator |
| Confirm Password | TextField (obscured) | required, match password                   |
| Terms            | Checkbox             | required (checked)                         |

### Password Strength Indicator

```
[●○○○○] Yếu
[●●○○○] Trung bình
[●●●○○] Khá
[●●●●●] Mạnh
```

### States

- Idle: Form ready
- Loading: Button spinner + fields disabled
- Success: Auto-login → redirect `/home`
- Error: Show error snackbar

### Error Handling

```
❌ Email already used: "Email đã tồn tại"
❌ Weak password: (shown inline with strength)
❌ Terms not accepted: "Bạn phải đồng ý điều khoản"
```

---

## 4️⃣ HOME SCREEN (`/home`)

### Mục Đích

- Dashboard chính
- Quick stats (calo hôm nay)
- Recent scans (5 scans gần nhất)
- Quick scan button
- Bottom navigation

### UI Layout

```
┌────────────────────────────┐
│ Hi, Nguyễn Văn A!     👤  │ AppBar
├────────────────────────────┤
│                            │
│ 📅 Hôm nay: 14/04/2026     │ ← Date
│                            │
│ ┌────────────────────────┐ │
│ │ 1850 / 2000 calo       │ │ ← Calorie progress card
│ │ ████████░░ 92%         │ │
│ │                        │ │
│ │ Protein: 75g           │ │
│ │ Carbs: 220g            │ │
│ │ Fat: 60g               │ │
│ └────────────────────────┘ │
│                            │
│ 📸 SCAN MÓN ĂN (Float btn) │ ← FAB (camera icon)
│                            │
│ Lịch sử gần đây:           │
│ ┌────────────────────────┐ │
│ │ 🍝 Phở bò      300cal  │ │ ← Recent scan 1
│ │ Lunch • 12:30 pm       │ │
│ └────────────────────────┘ │
│                            │
│ ┌────────────────────────┐ │
│ │ 🍚 Cơm tấm     450cal  │ │ ← Recent scan 2
│ │ Dinner • 7:00 pm      │ │
│ └────────────────────────┘ │
│                            │
│ [View history →]           │
│                            │
├────────────────────────────┤
│ 🏠 Home | 📸 Scan | ... │ ← Bottom Nav
└────────────────────────────┘
```

### Components

1. **Header**
   - Greeting: "Hi, [Name]!"
   - Avatar + settings icon (ng)
   - Date badge

2. **Calorie Summary Card**
   - Big number: "1850 / 2000 calo"
   - Progress bar (animated, color-coded)
   - Macros: Protein | Carbs | Fat
   - Color: Primary green background

3. **Recent Scans List**
   - 5 items max, swipeable
   - Each item shows:
     - Food icon/image
     - Food name (Vietnamese)
     - Calories + meal type
     - Time
     - Tap to view detail

4. **Floating Action Button**
   - Camera icon
   - On tap: Navigate to `/scan`
   - Tooltip: "Scan món ăn"

5. **Bottom Navigation**
   - 5 items: Home | Scan | History | Stats | Profile
   - Active color: Green
   - Icons: filled/outline based on active

### States

- **Loading**: Skeleton loaders for cards
- **Empty**: "Bạn chưa scan món ăn nào hôm nay"
- **Data**: Show stats + recent scans
- **Error**: Show retry button

---

## 5️⃣ SCAN SCREEN (`/scan`)

### Mục Đích

- Pick image from camera or gallery
- Show preview
- Upload + Analyze button
- Loading state

### UI Layout

```
┌────────────────────────────┐
│ < Back | Nhận diện        │ AppBar
├────────────────────────────┤
│                            │
│  ┌────────────────────┐   │
│  │                    │   │
│  │   📷 Restaurant    │   │ ← Image preview (rounded)
│  │                    │   │ (or empty placeholder)
│  │                    │   │
│  └────────────────────┘   │
│                            │
│  Chụp ảnh chất lượng cao   │
│  cho kết quả tốt nhất      │
│                            │
│                            │
│ ┌──────────────┬────────┐ │
│ │   📸 Chụp    │ 🖼️ Thư  │ │ ← Two buttons
│ │   Ảnh        │ viện    │ │
│ └──────────────┴────────┘ │
│                            │
│ (If image selected)        │
│ ┌────────────────────────┐ │
│ │  NHẬN DIỆN NGAY        │ │ ← Primary button
│ └────────────────────────┘ │
│                            │
│ (Loading state)            │
│ ⏳ Đang phân tích ảnh...  │
│    (spinner + countdown)   │
│                            │
└────────────────────────────┘
```

### Actions

| State          | Button         | Color           | Action              |
| -------------- | -------------- | --------------- | ------------------- |
| No Image       | 📸 Camera      | Secondary       | `pickFromCamera()`  |
| No Image       | 🖼️ Gallery     | Secondary       | `pickFromGallery()` |
| Image Selected | Nhận diện Ngay | Primary (Green) | `analyzeImage()`    |
| Analyzing      | [Spinner]      | Disabled        | —                   |

### Image Preview

- Rounded corners (16px radius)
- Fill container (300px height)
- Show file size + dimensions
- Can remove and select new

### Loading State

- Spinner animation
- Text: "Đang phân tích ảnh..." (3-5s)
- Estimated time: "~3-5 giây"
- (Optional) Progress: 0% → 100%

### Error State

```
❌ Không thể tải ảnh
"Vui lòng thử ảnh khác"
[Retry button]
```

---

## 6️⃣ SCAN RESULT SCREEN (`/scan/result`)

### Mục Đích

- Show AI recognition result
- Confidence score
- Nutrition info
- Top predictions
- Save or retake button

### UI Layout

```
┌────────────────────────────┐
│ < Back | Kết quả         │ AppBar
├────────────────────────────┤
│                            │
│  ┌────────────────────┐   │
│  │                    │   │
│  │   📷 Uploaded      │   │ ← Food image
│  │                    │   │
│  └────────────────────┘   │
│                            │
│ ✅ Phở Bò                 │ ← Food name + confidence
│ Khá chắc chắn (92%)        │ ← Confidence label
│                            │
│ ┌────────────────────────┐ │
│ │    300            4.5  │ │
│ │    CALO           PHẦN │ │ ← Main stats
│ │  (trên 100g)      (bát) │ │
│ └────────────────────────┘ │
│                            │
│ Dinh dưỡng (trên phần):    │ ← Nutrition breakdown
│ • Protein: 12g ◆◆◆◆       │
│ • Carbs: 45g ◆◆◆◆◆◆       │
│ • Fat: 5g ◆◆              │
│ • Fiber: 2g ◆             │
│                            │
│ Có thể là:                 │ ← Top predictions
│ • 🍝 Bún bò (5%)           │
│ • 🥡 Hủ tiếu (3%)          │
│ • 🍲 Bánh canh (2%)        │
│                            │
│ ┌─────────────┬──────────┐ │
│ │  Làm lại    │  Lưu     │ │ ← Action buttons
│ └─────────────┴──────────┘ │
│                            │
│           hoặc            │
│                            │
│ Không đúng? Giúp chúng tôi │ ← Feedback link
│                            │
└────────────────────────────┘
```

### Components

1. **Food Image**
   - Same as uploaded
   - Rounded corners
   - Fix aspect ratio

2. **Main Result**
   - Food name (large, 22px)
   - Confidence label + percentage
   - Color-coded confidence:
     - 🟢 Rất chắc chắn (90-100%)
     - 🟡 Khá chắc chắn (70-90%)
     - 🔴 Có thể (50-70%)
     - ⚫ Không chắc (<50%)

3. **Stats Card**
   - 4 columns: Calo | Protein | Carbs | Fat
   - Each shows number + unit
   - Green background

4. **Nutrition Breakdown**
   - 4 rows: Protein, Carbs, Fat, Fiber
   - Each has progress bar (green)
   - Percentage or grams

5. **Top Predictions**
   - 3-5 alternatives
   - Show confidence %
   - Smaller text
   - Collapsible (show/hide)

### Buttons

- **Làm Lại**: Retake → go back to `/scan`
- **Lưu**: Save to history → show success toast + navigate to `/history` or stay
- **Không đúng?**: Feedback form (v2)

### States

- **Success**: Show full result
- **Loading**: Skeleton while waiting
- **Error**: Retry button

---

## 7️⃣ HISTORY SCREEN (`/history`)

### Mục Đích

- List all scans
- Filter by date/meal type
- Tap item to view detail (readonly)
- Delete item (swipe)

### UI Layout

```
┌────────────────────────────┐
│                   ⚙️    📅 │ AppBar (search + sort)
│            LỊCH SỬ         │
│ (centered title)            │
├────────────────────────────┤
│                            │
│ Bộ lọc:                    │ ← Filter chips
│ [Tất cả] [Breakfast] [...]│
│ [7 ngày] [30 ngày] [...]  │
│                            │
│ 📅 Hôm nay (14/04)         │ ← Date header
│                            │
│ ┌────────────────────────┐ │
│ │ 🍝 Phở Bò      12:30 pm│ │ ← Scan item 1
│ │ 300 calo | Lunch       │ │
│ │                        │ │
│ └────────────────────────┘ │ (Swipe left: Delete)
│                            │
│ ┌────────────────────────┐ │
│ │ 🍚 Cơm tấm     07:00 pm│ │ ← Scan item 2
│ │ 450 calo | Dinner      │ │
│ └────────────────────────┘ │
│                            │
│ 📅 Hôm qua (13/04)         │ ← Date header
│                            │
│ ┌────────────────────────┐ │
│ │ 🥗 Salad       01:00 pm│ │ ← Scan item 3
│ │ 150 calo | Lunch       │ │
│ └────────────────────────┘ │
│                            │
│ [Load more...]             │ ← Pagination
│                            │
└────────────────────────────┘
```

### Components

1. **Search & Sort**
   - Search icon: Find by food name
   - Sort icon: Date (newest/oldest)
   - Date range picker

2. **Filter Chips**
   - Meal type: Breakfast, Lunch, Dinner, Snack
   - Date range: Today, 7 days, 30 days, All
   - Selectable (outlined border)

3. **Date Headers**
   - Group by date
   - Format: "Hôm nay (14/04)" or "14 Tháng 4"
   - Sticky headers (scroll)

4. **Scan Item Card**
   - Image thumbnail (60x60)
   - Food name (bold)
   - Calories + meal type
   - Time
   - Meal type icon (🌅 🍝 🍽️ 🍪)
   - Swipe left: Delete with confirmation
   - Tap: View detail (readonly)

5. **Empty State**
   ```
   🥗 Chưa có lịch sử
   Bạn chưa scan món ăn nào.
   Bắt đầu scan hôm nay!
   [Go to Scan →]
   ```

### Pagination

- Initially load 20 items
- Scroll to bottom → Load more
- Show loading indicator

### Delete Confirmation

```
❌ Xoá mục này?
"Bạn sẽ không thể hoàn tác"
[Cancel] [Delete]
```

---

## 8️⃣ STATS SCREEN (`/stats`)

### Mục Đích

- Show charts (7-day, 30-day)
- Calories trend
- Macro breakdown
- Compare vs goal

### UI Layout

```
┌────────────────────────────┐
│            THỐNG KÊ        │ AppBar (centered)
├────────────────────────────┤
│                            │
│ Período: [7 ngày] [30 ngày]│ ← Tab selector
│          [90 ngày] [Năm]   │
│                            │
│ ┌────────────────────────┐ │
│ │  CALO (7 ngày)         │ │ ← Chart title
│ │                        │ │
│ │  600┤    ╱╲             │ │
│ │  400┤   ╱  ╲    ╱╲      │ │ ← Bar/Line chart
│ │  200┤  ╱    ╲  ╱  ╲    │ │
│ │    0┼──────────────────│ │
│ │      Mn Th Wd Th Fn Sb Su│
│ │      (Mon-Sun)         │ │
│ │                        │ │
│ │ Trung bình: 1800 cal/ng│ │ ← Average
│ │ Tổng: 12.600 calo      │ │ ← Total
│ │                        │ │
│ └────────────────────────┘ │
│                            │
│ ┌────────────────────────┐ │
│ │ DINH DƯỠNG (7 ngày)    │ │ ← Macro pie chart
│ │                        │ │
│ │      🟢 Protein 20%    │ │
│ │      🟡 Carbs 50%      │ │
│ │      🔴 Fat 30%        │ │
│ │                        │ │
│ │ Avg: 520g Protein/tuần │ │
│ │                        │ │
│ └────────────────────────┘ │
│                            │
│ ┌────────────────────────┐ │
│ │ MỤC TIÊU vs TỰC TẾ     │ │ ← Goal comparison
│ │                        │ │
│ │ Mục tiêu: 2000 cal/ngày│ │
│ │ Thực tế: 1800 cal/ngày │ │
│ │ ✅ Trên đúng hướng      │ │
│ │                        │ │
│ └────────────────────────┘ │
│                            │
│ 📥 Export → Download CSV    │ ← Export button
│                            │
└────────────────────────────┘
```

### Charts

1. **Calorie Trend (Bar/Line)**
   - 7, 30, 90, 365 days options
   - Y-axis: Calories (0-3000)
   - X-axis: Dates/Days
   - Green bars (below goal), Red bars (above goal)
   - Interactive: Tap bar to see exact number
   - Show average line

2. **Macro Breakdown (Pie Chart)**
   - 3 colors: 🟢 Protein, 🟡 Carbs, 🔴 Fat
   - Percentages
   - Legend with grams

3. **Goal vs Actual (Progress)**
   - Target line (dotted)
   - Actual line (solid)
   - Colored indicator (green=on track, orange=off)
   - Message: "✅ Trên đúng hướng" or "⚠️ Vượt quá"

### Period Selector

- Chips: 7 ngày, 30 ngày, 90 ngày, Năm
- Active: Green background
- Default: 7 ngày

### States

- **Loading**: Skeleton loaders
- **No Data**: "Chưa có dữ liệu"
- **Data**: Show all charts

---

## 9️⃣ PROFILE SCREEN (`/profile`)

### Mục Đích

- Show user info
- Display BMI + TDEE
- Edit profile button
- Logout button

### UI Layout

```
┌────────────────────────────┐
│          HỒ SƠ             │ AppBar
├────────────────────────────┤
│                            │
│         👤 Avatar          │ ← Large avatar
│    (or user initials)      │
│                            │
│  Nguyễn Văn A              │ ← Name (large)
│  a@gmail.com               │ ← Email (gray)
│                            │
│ ┌────────────────────────┐ │
│ │ Thông tin cá nhân      │ │ ← Section
│ ├────────────────────────┤ │
│ │ Tuổi: 22               │ │
│ │ Giới tính: Nam         │ │
│ │ Chiều cao: 170 cm      │ │
│ │ Cân nặng: 65 kg        │ │
│ └────────────────────────┘ │
│                            │
│ ┌────────────────────────┐ │
│ │ CHỈNH CHỈ PHÍ THÂN      │ │ ← 3 metrics
│ ├────────────────────────┤ │
│ │ BMI: 22.5 (Bình thường)│ │
│ │ ████░░               │ │
│ │                        │ │
│ │ TDEE: 2.400 calo/ngày  │ │
│ │ (Hoạt động vừa phải)    │ │
│ │                        │ │
│ │ Mục tiêu: Giữ nguyên   │ │
│ └────────────────────────┘ │
│                            │
│ ┌────────────────────────┐ │
│ │ Cài đặt                │ │ ← Section
│ ├────────────────────────┤ │
│ │ ⚙️ Chỉnh sửa hồ sơ  →  │ │
│ │ 🔔 Thông báo          │ │
│ │ 🌙 Chế độ tối          │ │
│ │ 📧 Gửi email thống kê  │ │
│ └────────────────────────┘ │
│                            │
│ ┌────────────────────────┐ │
│ │  ĐĂNG XUẤT             │ │ ← Logout button (red)
│ └────────────────────────┘ │
│                            │
│ v1.0.0 • Build 42          │ ← App version (footer)
│                            │
└────────────────────────────┘
```

### Components

1. **Avatar Section**
   - Large circular avatar (100x100)
   - User initials if no avatar
   - Tap to upload new (optional v2)

2. **User Info**
   - Name (22px bold)
   - Email (14px gray)

3. **Personal Info Card**
   - Age, Gender, Height, Weight
   - Editable fields (go to edit)
   - 2 columns layout (Age | Gender, Height | Weight)

4. **Health Metrics Card**
   - **BMI**
     - Big number (22px)
     - Label + range (normal/overweight/underweight)
     - Color-coded background
     - Progress bar
   - **TDEE**
     - Formula used (show in tooltip)
     - Activity level example
   - **Goal**
     - Current: Lose / Maintain / Gain

5. **Settings** (optional v2)
   - Push notifications toggle
   - Dark mode toggle
   - Email reports checkbox
   - Privacy settings link

6. **Logout Button**
   - Full width
   - Red/error color
   - Confirmation dialog

### States

- **Loading**: Skeleton loaders
- **Data**: Show all info
- **Error**: Retry button

---

## 🔟 EDIT PROFILE SCREEN (`/profile/edit`)

### Mục Đích

- Update bio info
- Recalculate BMI/TDEE
- Save changes

### UI Layout

```
┌────────────────────────────┐
│ < Back | Chỉnh sửa hồ sơ  │ AppBar
├────────────────────────────┤
│                            │
│  ┌──────────────────────┐  │
│  │ Tên đầy đủ           │  │
│  │ [Nguyễn Văn A]       │  │
│  └──────────────────────┘  │
│                            │
│  ┌──────────────────────┐  │
│  │ Tuổi (năm sinh)      │  │
│  │ [22]                 │  │
│  └──────────────────────┘  │
│                            │
│  Giới tính:                │
│  ☉ Nam  ○ Nữ  ○ Khác      │
│                            │
│  ┌──────────────────────┐  │
│  │ Chiều cao (cm)       │  │
│  │ [170]                │  │
│  └──────────────────────┘  │
│                            │
│  ┌──────────────────────┐  │
│  │ Cân nặng (kg)        │  │
│  │ [65]                 │  │
│  └──────────────────────┘  │
│                            │
│  Mức hoạt động:            │ ← Dropdown/Radio
│  [Sedentary ▼]             │
│   • Ít hoạt động           │
│   • Hoạt động vừa phải     │
│   • Hoạt động nhiều        │
│   • Rất hoạt động          │
│                            │
│  Mục tiêu:                 │ ← Radio
│  ○ Giảm cân  ○ Giữ  ○ Tăng│
│                            │
│  ┌─────────────────────┐   │
│  │ BMI: 22.5           │   │ ← Calculated (readonly)
│  │     [Bình thường]   │   │
│  └─────────────────────┘   │
│                            │
│  ┌─────────────────────┐   │
│  │ TDEE: 2.400 cal/ngày│   │ ← Calculated (readonly)
│  └─────────────────────┘   │
│                            │
│  ┌──────────────┬────────┐ │
│  │   Huỷ        │  Lưu   │ │
│  └──────────────┴────────┘ │
│                            │
```

### Form Fields

| Field          | Type               | Validation           |
| -------------- | ------------------ | -------------------- |
| Name           | TextField          | required, 3-50 chars |
| Age            | TextField (number) | required, 13-100     |
| Gender         | Radio buttons      | required             |
| Height         | TextField (number) | required, 120-250cm  |
| Weight         | TextField (number) | required, 30-500kg   |
| Activity Level | Dropdown/Radio     | required             |
| Goal           | Radio buttons      | required             |

### Activity Level Options

```
🚫 Sedentary: Ngồi suốt ngày (TMDB x 1.2)
🚶 Light: Tập 1-3 ngày/tuần (TMRB x 1.375)
🧘 Moderate: Tập 3-5 ngày/tuần (TMRB x 1.55)
🏃 Active: Tập 6-7 ngày/tuần (TMRB x 1.725)
⚡ Very Active: Tập 2x/ngày hoặc chuyên gia (TMRB x 1.9)
```

### Goal Options

```
🔴 Lose: BMR x 0.85 (giảm 15%)
🟢 Maintain: BMR x Activity Level
🔵 Gain: BMR x 1.15 (tăng 15%)
```

### Calculated Fields (Read-Only)

- **BMI**: `weight / (height/100)²`
- **TDEE**: `BMR × Activity Level`
- Both show color-coded status

### Buttons

- **Huỷ**: Back without saving
- **Lưu**: Save → Show toast + navigate to `/profile`

### States

- **Idle**: Form ready
- **Loading**: Button spinner + fields disabled
- **Error**: Show error snackbar
- **Success**: Toast + redirect

---

## 🎯 SHARED COMPONENTS

### 1. BottomNavigationBar (HomeShell)

```dart
// Shows 5 tabs: Home | Scan | History | Stats | Profile
// Active = Green
// Icons + Labels
// Animated transition
```

### 2. Calorie Progress Bar

```dart
// Progress: 1850 / 2000
// Fill: 92.5%
// Color: Green (safe), Orange (warning), Red (exceeded)
// Animated fill
```

### 3. Loading States

```dart
// Spinner overlay (LoadingOverlay)
// Skeleton loaders for lists/cards
// Minimal loading (inline spinner)
```

### 4. Error Display

```dart
// SnackBar (bottom): "Lỗi: [message]"
// Dialog: "❌ Có lỗi xảy ra" + Retry button
// Inline error: Red text + icon
```

### 5. Empty States

```dart
// Large icon (64px)
// Message: "Không có dữ liệu"
// Sub-message: "Bạn chưa..."
// CTA button: "Bắt đầu ngay"
```

### 6. Cards

```dart
// Consistent styling: Rounded 12px, shadow 2px
// Padding: 16px
// Borders: 1px #E0E0E0 (optional)

Example:
┌─────────────────┐
│ Title           │
├─────────────────┤
│ Content         │
└─────────────────┘
```

### 7. Buttons

```dart
// Primary: Full width, 50px, green, white text
// Secondary: Outlined, green border, 50px
// Tertiary: Text button, green text
// Disabled: 50% opacity

States: normal, loading (spinner), disabled, success
```

---

## 📐 RESPONSIVE DESIGN

### Breakpoints

- **Mobile**: 360px - 600px (default)
- **Tablet**: 600px - 1200px (expand spacing)
- **Desktop**: 1200px+ (2-column layout)

### Adjustments

- Padding: 16px (mobile) → 24px (tablet)
- Font sizes: Fixed for mobile (Material spec)
- Columns: 1 (mobile) → 2 (tablet)

---

## 🎬 ANIMATIONS & MOTION

**📖 See comprehensive animation guide**: [docs/ANIMATION_GUIDE.md](ANIMATION_GUIDE.md)

### Quick Reference

#### Timing Standards

```
Page Enter:         200ms (slide from right + fade)
Page Exit:          150ms (slide to left + fade)
Button Press:       100ms (scale to 0.98 + shadow)
Progress Bar Fill:  800ms (ease-out)
Loading Spinner:    1.5s infinite (linear)
List Item Cascade:  300ms + 30ms stagger
Modal Pop:          250ms (scale 0.9→1.0 + fade)
Tab Switch:         200ms (cross-fade)
Snackbar Enter:     250ms (slide up + fade)
Snackbar Exit:      150ms (slide down + fade)
```

#### Easing Curves

```
Standard:           Cubic Bezier(0.0, 0.0, 0.2, 1.0)     → Balanced
Decelerate:         Cubic Bezier(0.0, 0.0, 0.2, 1.0)     → Screen entrance
Accelerate:         Cubic Bezier(0.3, 0.0, 1.0, 1.0)     → Screen exit
Linear:             Cubic Bezier(0.0, 0.0, 1.0, 1.0)     → Spinners
```

### Screen-Specific Animation Details

#### Splash to Home

- **Logo fade-in**: 0-300ms, scale 0 → 1 + opacity 0 → 1
- **Tagline scale-up**: 100-300ms, scale 0 → 1 + opacity 0 → 1
- **Screen fade-out**: 2800-3000ms, opacity 1 → 0
- **Next screen slide-in**: 3000-3200ms, slide from right + fade
- **Curve**: Decelerate (slow entrance), Standard (exit)

#### Navigation Transitions

- **Slide-in**: New screen slides from right (180dp) while fading in (200ms decelerate)
- **Slide-out**: Current screen slides to left while fading out (150ms accelerate)
- **Overlay dialogs**: Scale up 0.9 → 1.0 + fade (250ms standard)
- **Dismissed screens**: Slide down + fade out (150ms)

#### Loading Indicators

- **Spinning circle**: Material CircularProgressIndicator, 1.5s per rotation (linear easing)
- **Color**: Primary green (#2E7D32)
- **Overlay**: Fade in/out 150-200ms

#### List Cascade Animations

- **Item 1**: Appear at 0ms (slide up 40dp + fade, 300ms)
- **Item 2**: Appear at 30ms (slide up 40dp + fade, 300ms)
- **Item 3**: Appear at 60ms (slide up 40dp + fade, 300ms)
- **Stagger increment**: +30ms between items
- **Total effect**: Full list visible in ~430ms
- **Curve**: Decelerate (ease-out)
- Fade-in/out when states change
- Progress animation for progress bars

### Pull-to-Refresh

- Refresh icon rotates
- Auto-scroll top on success
- Toast: "Dữ liệu đã cập nhật"

---

## 🎨 ACCESSIBILITY

- **Contrast**: All text 4.5:1+ (WCAG AA)
- **Touch targets**: Min 48x48dp
- **Labels**: All icons have labels
- **Semantics**: Proper widget hierarchy
- **Localization**: All strings in I18n (en + vi)

---

## 📝 IMPLEMENTATION ORDER

**Phase 2-3 (Auth + Profile)**:

1. LoginScreen ← Focus
2. RegisterScreen
3. ProfileScreen
4. EditProfileScreen

**Phase 4 (Scan)**: 5. ScanScreen ← Core 6. ScanResultScreen

**Phase 6-8 (History + Stats)**: 7. HomeScreen ← Dashboard 8. HistoryScreen 9. StatsScreen 10. Bottom Navigation + HomeShell

---

## 💡 DESIGN TIPS

- Use Material Design 3 (Flutter default)
- Test on real devices (not just emulator)
- Use **Figma** to prototype before coding
- Follow Material colors + spacing
- Keep animations subtle (200-400ms)
- Test dark mode (prepare for v2)
- Use semantic colors (success/error/warning)
- Add loading + error states to ALL screens
- Handle empty states (no data)
- Make all text multilingual-ready (en + vi)

---

## 🚀 NEXT STEPS

1. **Phase 2 (Auth)**:
   - Design LoginScreen wireframe
   - Code LoginScreen UI
   - Code RegisterScreen UI
   - Test navigation

2. **Phase 4 (Scan)**:
   - Design ScanScreen mockup
   - Code camera integration
   - Code result screen

3. **Phase 8 (Dashboard)**:
   - Design HomeScreen dashboard
   - Code bottom navigation
   - Code stats charts
