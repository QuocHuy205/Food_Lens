# 🎨 DESIGN PROMPT — Food Lens AI

> Copy-paste prompt này cho designer hoặc AI design tools (Figma, Midjourney, etc.)

---

## DESIGN BRIEF — Food Lens AI Mobile App

### PROJECT OVERVIEW

**App Name**: Food Lens AI  
**Type**: Mobile app (iOS + Android with Flutter)  
**Purpose**: AI food recognition + calorie tracking + nutrition insights  
**Target Users**: Health-conscious people tracking daily diet  
**Platform**: Flutter (cross-platform UI)  
**Design System**: Material Design 3

---

### DESIGN SYSTEM (FIXED)

#### Colors

```
Primary (Green - Healthy):        #2E7D32
Primary Light:                    #60AD5E
Primary Dark:                     #005005

Accent (Orange - Energy):         #FF6F00

Neutral:
- Background:                     #F5F5F5
- Surface:                        #FFFFFF
- Text Primary:                   #212121
- Text Secondary:                 #757575

Meal Type Indicators:
- Breakfast 🌅:                   #FFB300
- Lunch 🍝:                       #1976D2
- Dinner 🍽️:                     #7B1FA2
- Snack 🍪:                       #00897B

Semantic:
- Success ✅:                     #43A047
- Warning ⚠️:                     #FFA000
- Error ❌:                       #D32F2F
```

#### Typography

```
Font Family: Roboto (Material standard)

Headline 1: 28px Bold           → Page titles
Headline 2: 22px Bold           → Section titles
Title: 18px SemiBold            → Card titles
Body: 14px Regular              → Content text
Caption: 12px Regular Gray      → Helper text
Calorie Number: 36px Bold Green → Large stats
```

#### Components Spacing

```
Padding: 16px (standard), 24px (large), 8px (small)
Border Radius: 12px (cards/buttons), 16px (images), 24px (large)
Shadow: elevation 2 (cards)
Border: 1px #E0E0E0 (subtle)
```

---

### 🎬 ANIMATIONS & MOTION DESIGN

#### Global Motion Principles

- **Duration**: Keep it smooth (150-500ms, never >300ms standard)
- **Easing**: Material curves (accelerate, decelerate, standard)
- **Purpose**: Guide attention, don't distract
- **Accessibility**: Respect `prefers-reduced-motion` (disable heavy animations)

#### Easing Curves

```
Standard:        Cubic Bezier(0.0, 0.0, 0.2, 1)     → Default smooth
Accelerate:      Cubic Bezier(0.3, 0.0, 1.0, 1.0)   → Fast exit
Decelerate:      Cubic Bezier(0.0, 0.0, 0.2, 1.0)   → Slow enter
Emphasis:        Cubic Bezier(0.2, 0.0, 0.0, 1.0)   → Bounce effect
```

#### Page Transition Animations

**1. ENTER SCREEN (Slide + Fade)**

- **Direction**: Slide from right (180dp)
- **Duration**: 200ms
- **Easing**: Decelerate / Standard
- **Fade**: 0% → 100% opacity
- **What it feels like**: Screen pushes in from right side, smooth entrance

```
X position:  Screen width → 0
Opacity:     0 → 1
Duration:    200ms
Curve:       decelerate
```

**2. EXIT SCREEN (Slide + Fade Out)**

- **Direction**: Slide to right (180dp)
- **Duration**: 150ms
- **Easing**: Accelerate
- **Fade**: 100% → 0% opacity (optional, faster)

```
X position:  0 → -Screen width
Opacity:     1 → 0 (optional)
Duration:    150ms
Curve:       accelerate
```

**3. REPLACE SCREEN (Cross Fade - No Slide)**

- **When**: Same tab, replacing content (not navigation)
- **Duration**: 300ms
- **Easing**: Standard
- **Effect**: Current screen fades out, new screen fades in

```
Current screen:  1.0 → 0.0 opacity (150ms)
New screen:      0.0 → 1.0 opacity (150ms, delay 100ms)
Total:           300ms
```

#### Component Animations

**1. BUTTON PRESS**

- **Scale**: 100% → 98% (press down)
- **Duration**: 100ms on press
- **Release**: Scale back to 100% (100ms)
- **Overlay**: Slight opacity change (optional, 8% black overlay)
- **Feedback**: Instant, snappy feeling

```
On press:
  - Scale: 1.0 → 0.98
  - Shadow: elevation 2 → 4
  - Duration: 100ms

On release:
  - Scale: 0.98 → 1.0
  - Shadow: 4 → 2
  - Duration: 100ms
```

**2. LOADING SPINNER**

- **Style**: Material circular progress indicator
- **Rotation**: 360° infinite
- **Duration**: 1.5s per rotation
- **Easing**: Linear
- **Color**: Primary green (#2E7D32)

```
Rotation:  0° → 360°
Duration:  1.5s
Loop:      infinite
Easing:    linear
```

**3. PROGRESS BAR FILL (Animated)**

- **Type**: Bar fills from left to right
- **Target**: 1850/2000 = 92.5%
- **Duration**: 800ms
- **Easing**: Ease-out (decelerate)
- **Color**: Green (safe) → Orange (warning) → Red (exceeded)

```
Width:     0% → 92.5%
Duration:  800ms
Easing:    decelerate
Color:     Green (#2E7D32) if <goal, Orange if ~goal, Red if >goal
```

**4. CHIP/TAB SELECTION**

- **Active state**: Highlight with background color change
- **Duration**: 150ms
- **Easing**: Standard
- **Effect**: Smooth color transition, no scale

```
Background:  transparent → primary green
Text color:  gray → white
Duration:    150ms
Easing:      standard
```

**5. LIST ITEM ENTRANCE (Staggered)**

- **Individual item delay**: +30ms per item
- **Duration per item**: 300ms
- **Easing**: Decelerate
- **Effect**: Items slide up + fade in, cascade effect

```
Item 1: Delay 0ms,   Animate 300ms (slide up 40dp + fade)
Item 2: Delay 30ms,  Animate 300ms
Item 3: Delay 60ms,  Animate 300ms
...
```

**6. SNACKBAR/TOAST NOTIFICATION**

- **Enter**: Slide up from bottom (80dp) + fade in
- **Duration**: 250ms
- **Easing**: Decelerate
- **Exit**: Slide down + fade out
- **Duration**: 150ms
- **Easing**: Accelerate

```
Enter:
  Y: +80dp → 0
  Opacity: 0 → 1
  Duration: 250ms

Exit:
  Y: 0 → +80dp
  Opacity: 1 → 0
  Duration: 150ms
```

**7. MODAL/DIALOG APPEARANCE**

- **Background overlay**: Fade in (300ms)
- **Dialog box**: Scale from 90% → 100%
- **Duration**: 250ms
- **Easing**: Standard + bounce slight
- **Effect**: Pop-in animation, feels alive

```
Dialog:
  Scale:   0.90 → 1.0
  Opacity: 0 → 1
  Duration: 250ms
  Curve:   standard (with slight emphasis)

Overlay:
  Opacity: 0 → 0.4 (black)
  Duration: 250ms
```

**8. FAB (Floating Action Button) PULSE**

- **Idle**: Subtle pulse every 3s (optional)
- **Duration**: 600ms per pulse
- **Effect**: Shadow grows, then shrinks
- **Purpose**: Draw attention to primary action

```
Shadow:     elevation 2 → 6 → 2
Duration:   600ms
Easing:     ease-in-out
Loop:       every 3s (if needed)
```

#### Screen-Specific Animations

**🎬 SPLASH SCREEN**

```
Timeline:
  0ms:     Logo appears (scale 0 → 1, fade 0 → 1) - 300ms
  100ms:   Tagline appears (scale 0 → 1, fade 0 → 1) - 200ms
  2800ms:  Entire screen begins fade out
  3000ms:  Screen fully transparent (fade 1 → 0) - 200ms
  3200ms:  Navigate to next screen

Curves:
  - Logo entrance: ease-out/decelerate
  - Tagline entrance: ease-out/decelerate (delayed)
  - Final fade: standard
```

**🎬 LOGIN → HOME (Success)**

```
Timeline:
  0ms:     User taps "Đăng nhập"
  0-100ms: Button scale to 0.98
  100ms:   Spinner starts
  100-3000ms: Loading state (user waits)
  3000ms:  Success → screen fade out
  3000-3200ms: Current screen fades out (200ms)
  3200ms:  New screen (Home) fades in from 3000-3200ms

Effect:
  - Login screen slides left + fades out (200ms accelerate)
  - Home screen slides from right + fades in (200ms decelerate)
```

**🎬 HOME SCREEN - CALORIE CARD LOAD**

```
Timeline:
  0ms:     Card is visible but not filled
  500ms:   Progress bar animates to 92.5%
  800ms:   Numbers count from 0 → 1850 (optional, faster: 400ms)

Effect:
  - Card slides up + fades in (300ms on first load)
  - Progress bar fills smoothly (800ms ease-out)
  - Numbers optionally count-up (Tween animation)
```

**🎬 HISTORY LIST - SCAN ITEMS**

```
Timeline:
  0ms:     Header and first item appear

Items cascade:
  Item 1:  0ms delay, 300ms animate (slide up 40dp + fade)
  Item 2:  30ms delay, 300ms animate
  Item 3:  60ms delay, 300ms animate
  Item 4:  90ms delay, 300ms animate
  Item 5:  120ms delay, 300ms animate

Total effect: ~400ms for full list to appear

Interaction:
  - Swipe left: Item slides out + fades (200ms)
  - Delete confirmation: Dialog pops in (250ms)
```

**🎬 STATS SCREEN - CHARTS**

```
Timeline:
  0ms:     Chart container appears
  300ms:   Bars/lines animate from 0 to target height

Bar chart:
  Each bar grows from 0% → actual height
  Duration: 350ms per bar
  Stagger: +50ms between bars
  Easing: ease-out/decelerate

Line chart:
  Line draws from left to right
  Duration: 800ms
  Easing: standard

Values:
  Numbers count-up to final value (400ms)
```

**🎬 PROFILE SCREEN - METRICS CARDS**

```
Timeline:
  0ms:     Screen loads

Cards:
  Avatar: Fade in + slight zoom (250ms)
  Bio card: Slide up + fade (200ms, delay 100ms)
  Metrics cards: One by one (200ms each, +100ms delay)

BMI progress bar: Fill animation (600ms)
TDEE value: Count-up (400ms)
```

#### Transition Between Tabs (Bottom Nav)

**When user taps a bottom nav item:**

```
Current tab content:
  - Fade out + slide down (150ms)
  - Opacity: 1 → 0
  - Y: 0 → 20dp

New tab content:
  - Fade in + slide up (150ms)
  - Opacity: 0 → 1
  - Y: -20dp → 0
  - Delay: start immediately after current exits

Total visual effect: ~200ms smooth tab switch
```

#### Micro-Interactions

**1. TextField Focus**

```
Border color:      #E0E0E0 → Primary green (#2E7D32)
Border width:      1px → 2px
Shadow:            none → subtle (elevation 1)
Duration:          150ms
Easing:            standard
```

**2. Checkbox/Radio Toggle**

```
Circle/box:        scale 1.0 → 1.1 → 1.0
Check mark:        draws in (100ms)
Duration:          200ms total
Easing:            standard with emphasis
```

**3. Hover Effect (Desktop/Tablet)**

```
Card elevation:    2 → 4
Scale:             1.0 → 1.01 (subtle)
Shadow color:      slightly darker
Duration:          150ms
Easing:            decelerate
```

**4. Pull-to-Refresh Indicator**

```
Icon rotation:     0° → -180° as user pulls
Icon opacity:      0.5 → 1.0
Progress:          animated as data loads
After refresh:     Icon rotates 360° (500ms), then fades out
```

**5. Empty State Animation (Lottie-ready)**

```
Illustration:      Gentle floating animation (up/down 10dp)
Duration:          2s per cycle
Loop:              infinite
Easing:            ease-in-out
Purpose:           Keep empty state feeling alive
```

#### Accessibility Considerations

**Reduced Motion Settings:**

```
If user enables "Reduce Motion":
  - Disable all animations >150ms
  - Keep focus indicator animations
  - Instant transitions (0ms) instead of 200-300ms
  - Disable decorative animations (pulse, floating)

Implementation:
  Check `MediaQuery.of(context).disableAnimations`
  Or use `prefers-reduced-motion: reduce` (CSS)
```

**Color Animation Considerations:**

- Ensure animations don't rely solely on color changes
- Always include opacity or scale changes too
- High contrast maintained throughout

#### Performance Notes

```
DO:
✅ Use GPU-accelerated properties (transform, opacity)
✅ Keep animations 150-500ms
✅ Limit concurrent animations (max 3-4)
✅ Test on low-end devices (60fps target)

DON'T:
❌ Animate width/height frequently (expensive)
❌ Use blur/shadow in complex animations (performance hit)
❌ Chain too many animations (feels choppy)
❌ Forget to test on real devices
```

---

### 10 SCREENS TO DESIGN

#### 1. **SPLASH SCREEN** (`/`)

**Purpose**: Logo + auto-redirect on app startup

**Layout**:

- Centered logo (Food Lens icon)
- Brand name: "🍜 FOOD LENS"
- Tagline: "AI Nutrition Tracker"
- Loading spinner (Material circular)
- Optional skip button (top-right corner)

**States**:

- Loading: spinner rotating
- Redirect: fade-out animation

**Design Notes**:

- Gradient background: white → #F5F5F5
- Smooth fade-in animation (300ms logo, 200ms tagline)
- Auto-redirect after 3s

---

#### 2. **LOGIN SCREEN** (`/login`)

**Purpose**: Email/Password authentication

**Layout** (top to bottom):

- AppBar: "FOOD LENS" centered
- Logo (small, 60px)
- "Đăng nhập" headline
- Email TextField
  - Label: "Email"
  - Placeholder: "user@example.com"
  - Icon: envelope
  - Validation: red border on error
- Password TextField
  - Label: "Mật khẩu"
  - Placeholder: "••••••••"
  - Icon: lock + eye toggle
  - Validation: red border on error
- Error message (red text, below fields if needed)
- Button: "ĐĂNG NHẬP" (primary green, full width, 50px)
- Link: "Còn mới? Đăng ký ngay" (text, green)

**States**:

- Idle: all inputs ready
- Loading: button shows spinner + "Đang đăng nhập...", fields disabled
- Error: show error message below form
- Success: fade-out → navigate

**Interactions**:

- Focus on field: border turns green
- Password eye toggle: show/hide
- Button hover: slight color darken
- Keyboard enter: submit form

---

#### 3. **REGISTER SCREEN** (`/register`)

**Purpose**: Create new account

**Layout** (scrollable):

- AppBar: "< Back | Đăng ký"
- Headline: "Tạo tài khoản mới"
- Name TextField
  - Label: "Tên đầy đủ"
  - Validation: min 3 chars
- Email TextField
  - Label: "Email"
  - Validation: valid email format
- Password TextField
  - Label: "Mật khẩu"
  - Password strength indicator (4 bars):
    - Red (weak), Orange (medium), Green (strong), Dark Green (very strong)
  - Show requirements: "Min 6 ký tự"
- Confirm Password TextField
  - Label: "Xác nhận mật khẩu"
  - Validation: match password
- Terms Checkbox
  - "☑ Tôi đồng ý [Điều khoản & Điều kiện]"
  - Link underlined
- Button: "ĐĂNG KÝ" (primary, full width, 50px)
- Link: "Đã có tài khoản? Đăng nhập" (text)

**Password Strength Visualization**:

```
Weak:       [█░░░] Yếu
Medium:     [██░░] Trung bình
Good:       [███░] Khá
Strong:     [████] Mạnh
```

**States**:

- Idle: form ready
- Typing: strength indicator updates live
- Loading: button spinner
- Error: red inline error messages
- Success: fade-out → auto-login → home

---

#### 4. **HOME SCREEN** (`/home`)

**Purpose**: Dashboard + calorie tracking

**Layout** (scrollable):

- AppBar
  - Left: "Hi, [User Name]! 👋"
  - Right: Avatar (60px) + settings icon
- Date badge: "📅 Hôm nay: 14/04/2026"
- **Calorie Summary Card** (primary green background)
  - Large number: "1850 / 2000"
  - Subtitle: "calo hôm nay"
  - Progress bar (animated)
  - Macros row:
    - Protein: 75g | Carbs: 220g | Fat: 60g
  - Color-coded: green (safe), orange (warning), red (exceeded)
- Section break
- **Recent Scans Header**: "Lịch sử gần đây"
- List of 5 recent scan cards (swipeable):
  - Each card:
    - Image thumbnail (60x60)
    - Food name (bold)
    - Calories + portion
    - Meal type badge (🌅 🍝 🍽️ 🍪)
    - Time
    - Tap: view detail, swipe: quick delete
- Link: "[Xem toàn bộ lịch sử →]"
- **Floating Action Button** (FAB)
  - Position: bottom-right
  - Color: accent orange
  - Icon: camera
  - Tooltip: "Scan món ăn"
- **Bottom Navigation** (5 items):
  - 🏠 Home (active)
  - 📸 Scan
  - 📋 History
  - 📊 Stats
  - 👤 Profile

**States**:

- Loading: skeleton loaders for summary + scan list
- Empty: "Bạn chưa scan món ăn nào hôm nay"
- Data: show full dashboard

**Interactions**:

- FAB tap: navigate to `/scan`
- Recent scan tap: navigate to `/scan/result?id=...`
- Bottom nav tap: navigate to respective screen
- Pull-to-refresh: reload data

---

#### 5. **SCAN SCREEN** (`/scan`)

**Purpose**: Pick image + preview

**Layout**:

- AppBar: "< Back | Nhận diện"
- **Image Preview Area** (center)
  - If no image: placeholder card (250px height)
    - Icon: restaurant (gray, 64px)
    - Border: dashed gray
    - Text: "Chọn ảnh"
  - If image: rounded image (250px, border-radius 16px)
- Helper text: "Chụp ảnh chất lượng cao cho kết quả tốt nhất"
- **Action Buttons** (2 columns):
  - Button 1: "📸 CHỤP ẢNH" (secondary outlined on top)
  - Button 2: "🖼️ THƯ VIỆN" (secondary outlined)
- **If image selected**:
  - Button: "NHẬN DIỆN NGAY" (primary green, full width, 50px)
- **While analyzing**:
  - Spinner overlay
  - Text: "Đang phân tích ảnh..."
  - Progress: "Còn khoảng 3-5 giây"

**States**:

- Idle: empty placeholder
- Image selected: show preview + analyze button
- Analyzing: spinner + disable buttons
- Error: show error message + retry button

**Interactions**:

- Camera button: open camera
- Gallery button: open photo picker
- Analyze button: upload + analyze (3-5s)
- Auto-navigate to `/scan/result` when done

---

#### 6. **SCAN RESULT SCREEN** (`/scan/result`)

**Purpose**: Show AI recognition + nutrition

**Layout** (scrollable):

- AppBar: "< Back | Kết quả"
- **Food Image** (top, 250px, rounded)
- **Recognition Result**:
  - Headline (22px bold): "Phở Bò"
  - Confidence label: "✅ Khá chắc chắn (92%)"
  - Color-coded:
    - 🟢 90%+ = Rất chắc chắn
    - 🟡 70-90% = Khá chắc chắn
    - 🟠 50-70% = Có thể
    - 🔴 <50% = Không chắc
- **Stats Card** (4 columns, green background):
  - Column 1: "300" + "CALO"
  - Column 2: "4.5" + "PHẦN"
  - Column 3: "12g" + "PROTEIN"
  - Column 4: "45g" + "CARBS"
- **Nutrition Breakdown**:
  - 4 rows with inline progress bars:
    - Protein: 12g ████
    - Carbs: 45g ██████
    - Fat: 5g ██
    - Fiber: 2g █
- **Top Predictions** (collapsible):
  - "Có thể là:"
  - List: 🍝 Bún bò (5%), 🥡 Hủ tiếu (3%), 🍲 Bánh canh (2%)
- **Action Buttons** (2 col):
  - Button 1: "🔄 Làm lại" (secondary)
  - Button 2: "💾 LƯU" (primary green)
- **Feedback Link** (gray text):
  - "Không đúng? Giúp chúng tôi cải thiện"

**States**:

- Loading: skeleton
- Data: show full result
- Error: show retry button

**Interactions**:

- Retake: go back to `/scan`
- Save: show toast "Đã lưu ✓" + navigate to `/home` or stay
- Feedback link: open form

---

#### 7. **HISTORY SCREEN** (`/history`)

**Purpose**: List all scans with filters

**Layout** (scrollable):

- AppBar:
  - Title: "LỊCH SỬ"
  - Icons: search + sort (top-right)
- **Filter Chips** (horizontal scroll):
  - Meal type: [Tất cả] [Breakfast] [Lunch] [Dinner] [Snack]
  - Date range: [7 ngày] [30 ngày] [90 ngày] [Năm]
- **Scan Items** (grouped by date):
  - Date header: "📅 Hôm nay (14/04)" (sticky)
  - Item card:
    - Image (60x60)
    - Food name (bold)
    - Time (12:30 pm)
    - Calories + meal type
    - Tap: view detail
    - Swipe left: delete (with confirmation)
  - Date header: "📅 Hôm qua (13/04)"
  - Items...
- **Pagination**: "Tải thêm..." button at bottom

**Empty State**:

- Icon: 🥗
- Text: "Chưa có lịch sử"
- Sub: "Bạn chưa scan món ăn nào"
- Button: "🚀 Bắt đầu scan"

**States**:

- Loading: skeleton list
- Data: show filtered scans
- Empty: show empty state

**Interactions**:

- Filter chip: toggle active state (green background)
- Search: filter by food name
- Sort: oldest/newest date
- Tap item: navigate to `/scan/result?id=...` (readonly)
- Swipe delete: confirm dialog → delete

---

#### 8. **STATS SCREEN** (`/stats`)

**Purpose**: Analytics + charts

**Layout** (scrollable):

- AppBar: "THỐNG KÊ"
- **Period Tabs** (horizontal):
  - [7 ngày] [30 ngày] [90 ngày] [Năm]
  - Active = green background
  - Default: 7 ngày
- **Chart 1: Calorie Trend** (bar/line chart)
  - Title: "CALO (7 ngày)"
  - Y-axis: 0-3000 calo
  - X-axis: Mon-Sun (or dates)
  - Bars: green if <goal, red if >goal
  - Interactive: tap bar → tooltip
  - Average line: dotted
  - Text: "Trung bình: 1800 cal/ngày"
  - Text: "Tổng: 12.600 calo"
- **Chart 2: Macro Pie Chart**
  - Title: "DINH DƯỠNG (7 ngày)"
  - 3 colors: 🟢 Protein (20%), 🟡 Carbs (50%), 🔴 Fat (30%)
  - Legend + percentages
  - Text: "Avg: 520g Protein/tuần"
- **Chart 3: Goal Comparison**
  - Title: "MỤC TIÊU vs THỰC TẾ"
  - Target line: 2000 cal/day (dotted)
  - Actual line: 1800 cal/day (solid)
  - Status: ✅ "Trên đúng hướng" or ⚠️ "Vượt quá"
- **Export Button**: "📥 Tải xuống CSV"

**States**:

- Loading: skeleton charts
- Data: show all 3 charts
- No data: "Chưa có dữ liệu cho khoảng thời gian này"

**Interactions**:

- Period tab: switch chart data
- Tap chart element: show detail
- Export: download CSV file

---

#### 9. **PROFILE SCREEN** (`/profile`)

**Purpose**: User info + settings

**Layout** (scrollable):

- AppBar: "HỒ SƠ"
- **User Section**:
  - Avatar (100x100, circular)
  - Name (22px bold): "Nguyễn Văn A"
  - Email (14px gray): "a@gmail.com"
- **Personal Info Card**:
  - Title: "Thông tin cá nhân"
  - 4 rows (2 col):
    - Tuổi: 22 | Giới tính: Nam
    - Chiều cao: 170 cm | Cân nặng: 65 kg
- **Health Metrics Card**:
  - Title: "CHỈ CHỈ PHÍ THÂN"
  - **BMI**: 22.5 (Bình thường)
    - Progress bar
    - Color: green (normal), orange (overweight), red (underweight)
  - **TDEE**: 2.400 calo/ngày
    - Sub: "(Hoạt động vừa phải)"
  - **Goal**: "Giữ nguyên"
- **Settings Section**:
  - Title: "Cài đặt"
  - List items:
    - ⚙️ Chỉnh sửa hồ sơ [→]
    - 🔔 Thông báo [toggle]
    - 🌙 Chế độ tối [toggle]
    - 📧 Gửi email thống kê [toggle]
- **Logout Button**:
  - Full width, 50px
  - Background: red/error color
  - Text: "ĐĂNG XUẤT"
- **Footer**: "v1.0.0 • Build 42"

**States**:

- Loading: skeleton
- Data: show profile
- Error: retry button

**Interactions**:

- Avatar: (optional) upload new avatar
- Edit button: navigate to `/profile/edit`
- Settings toggle: save preference
- Logout: confirmation dialog → clear auth → splash → login

---

#### 10. **EDIT PROFILE SCREEN** (`/profile/edit`)

**Purpose**: Update user info

**Layout** (scrollable, form):

- AppBar: "< Back | Chỉnh sửa hồ sơ"
- **Form Fields**:
  - Name: TextInput (required)
  - Age: NumberInput (required, 13-100)
  - Gender: Radio buttons [Nam] [Nữ] [Khác]
  - Height (cm): NumberInput (required, 120-250)
  - Weight (kg): NumberInput (required, 30-500)
  - Activity Level: Dropdown
    - Sedentary
    - Light
    - Moderate (default)
    - Active
    - Very Active
  - Goal: Radio buttons [Giảm] [Giữ] [Tăng]
- **Read-Only Calculated Fields**:
  - BMI: 22.5 (Bình thường)
    - Color-coded
  - TDEE: 2.400 calo/ngày
- **Buttons** (2 col):
  - Cancel: secondary
  - Save: primary green, full width

**Validations**:

- All required fields marked with \*
- Inline validation on blur
- Error messages red text below field

**States**:

- Idle: form ready
- Dirty: save button active (green) or disable if no changes
- Loading: button spinner
- Error: show error message
- Success: toast "✓ Cập nhật thành công" + navigate to `/profile`

---

### SHARED COMPONENTS / UI PATTERNS

#### 1. **Bottom Navigation Bar**

- 5 items: Home | Scan | History | Stats | Profile
- Icons + labels
- Active item: green background + filled icon
- Inactive: gray + outline icon
- Animation: fade + slight scale

#### 2. **AppBar**

- Title: center-aligned or left-aligned
- Left action: back button (if needed)
- Right actions: icon buttons (search, settings, etc)
- Background: green primary
- Text: white

#### 3. **Buttons**

- **Primary**: Full width, 50px, green bg, white text
  - Hover: slightly darker green
  - Pressed: scale 0.98
  - Disabled: 50% opacity
  - Loading: spinner inside
- **Secondary (Outlined)**: Full width, 50px, white bg, green border, green text
  - Similar hover/disabled states
- **Tertiary (Text)**: No bg, green text
  - Underline on hover

#### 4. **Cards**

- Rounded corners: 12px
- Shadow: elevation 2
- Padding: 16px
- Border: optional 1px #E0E0E0
- Content inside: proper hierarchy

#### 5. **TextFields**

- Border: 1px gray (unfocused), 2px green (focused)
- Corner radius: 8px
- Padding: 12px
- Label: above field, 12px gray
- Helper text: below field, 12px gray
- Error: red border + red label + red helper text
- Icon: left or right side

#### 6. **Loading States**

- Global spinner overlay (LoadingOverlay)
- Skeleton loaders for lists/cards
- Minimal inline spinners

#### 7. **Error States**

- SnackBar (bottom): "❌ Error: [message]" (red bg, white text)
- Dialog: "❌ Có lỗi xảy ra" + Retry button
- Inline: red text + icon

#### 8. **Empty States**

- Large icon (64px)
- Headline: "Không có dữ liệu"
- Subtitle: "Bạn chưa..."
- CTA button

---

### ANIMATIONS & INTERACTIONS

#### Page Transitions

- **Push**: Slide-in from right (200ms)
- **Pop**: Slide-out to right (200ms)
- **Replace**: Cross-fade (300ms)

#### Component Animations

- **Buttons**: Scale on press (0.98)
- **Loading spinner**: Smooth rotation (infinite)
- **Progress bars**: Animated fill (300ms)
- **Chips**: Toggle active state (100ms)

#### Splash > Home

- Logo fade-in: 300ms
- Tagline scale-up: 200ms (delay 100ms)
- Entire screen fade-out: 200ms (delay 2.8s)

---

### ACCESSIBILITY

- **Color Contrast**: All text > 4.5:1 (WCAG AA)
- **Touch Targets**: Min 48x48dp
- **Labels**: All icons have labels/tooltips
- **Semantics**: Proper widget hierarchy
- **I18n Ready**: All strings in translation files (en + vi)

---

### TONE OF VOICE

- Friendly, encouraging, supportive
- Use emojis sparingly (only meal types)
- Clear, actionable CTAs
- Celebrate user progress
- Simple language (not technical)

**Example Phrases**:

- ✅ "Cập nhật thành công"
- ✅ "Trên đúng hướng!"
- ✅ "Bạn vừa lưu 1 bữa ăn"
- ❌ Avoid: "Lỗi 500"

---

### SUCCESS CRITERIA

- [ ] All 10 screens designed with high fidelity
- [ ] Component library created (reusable)
- [ ] Color palette consistent across all screens
- [ ] Navigation flow tested
- [ ] Responsive on mobile (320px-600px)
- [ ] Accessibility check passed
- [ ] All UI states documented (loading, error, empty)
- [ ] Ready for hand-off to developer

---

### DESIGN FILES

- **Figma Project**: [Link to Figma]
- **Component Library**: Shared components in Figma
- **Prototypes**: Interactive prototypes of main flows
- **Developer Handoff**: Specs + measurements + color codes

---

### DELIVERABLES

1. **10 Screen High-Fidelity Designs**
2. **Component Library** (20+ components)
3. **Design System Guide** (colors, typography, spacing)
4. **Interaction Specifications** (animations, transitions)
5. **Responsive Breakpoints** (mobile, tablet, desktop)
6. **Accessibility Audit**
7. **Prototype for user testing**
8. **Developer Handoff (Figma Specs)**

---

## QUICK REFERENCE — Ask Designer

**"Can you design the following UI system for a Flutter app?"**

### System Features:

- Food AI recognition bot
- Calorie tracking dashboard
- Nutrition analytics (charts)
- User profile management
- Authentication (login/signup)

### Design Constraints:

- Material Design 3
- Mobile-first (flutter apps)
- Green + Orange color scheme
- Vietnamese + English support
- Dark mode ready (future)

### Quick Summary (10 Screens):

1. Splash Screen — Logo + auto-redirect
2. Login — Email/password form
3. Register — Signup form + password strength
4. Home Dashboard — Calorie summary + recent scans
5. Scan — Camera + image picker
6. Scan Result — AI result + nutrition breakdown
7. History — Filterable scan list
8. Stats — Charts (7-day, 30-day, etc)
9. Profile — User info + health metrics
10. Edit Profile — Form for updating user data

### Key Requirements:

- ✅ All form validations visible
- ✅ Loading + error states for every screen
- ✅ Bottom navigation (5 main tabs)
- ✅ Accessible (touch targets 48x48dp, contrast >4.5:1)
- ✅ Ready for Flutter implementation
- ✅ Component library (reusable UI kit)

---

## DESIGN HANDOFF CHECKLIST

Before sharing with developer:

- [ ] All 10 screens completed
- [ ] Component library extracted
- [ ] Color palette finalized (#hex codes)
- [ ] Typography specs clear (font, size, weight)
- [ ] Spacing/padding documented
- [ ] Icons sourced (Material Icons or custom)
- [ ] Button states (normal, hover, active, disabled)
- [ ] Form validation patterns shown
- [ ] Loading states designed
- [ ] Error states designed
- [ ] Empty states designed
- [ ] Responsive behavior documented
- [ ] Prototypes interactive
- [ ] All strings collected (I18n ready)
- [ ] Figma links for developer
- [ ] Design specs exported (measurements, etc)
