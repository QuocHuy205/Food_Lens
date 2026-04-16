# 📝 DESIGN PROMPTS — Tóm Tắt & Tools

> 3 prompt khác nhau: Full (chi tiết), Short (nhanh), AI Tools (Figma/Midjourney)

---

## PROMPT 1️⃣ — FULL BRIEF (Chi Tiết — 3000 words)

📄 Xem file: `DESIGN_PROMPT.md`

**Dùng khi**: Share cho designer hoặc team
**Format**: Markdown (dài)
**Thời gian**: 30-60 phút để đọc hết

---

## PROMPT 2️⃣ — SHORT BRIEF (Tóm Tắt — 2 phút)

```
BRIEF: Food Lens AI — Calorie Tracking App

PROJECT TYPE: Mobile app (Flutter)
VIBE: Healthy, friendly, modern

DESIGN SYSTEM:
- Colors: Green (#2E7D32) + Orange (#FF6F00)
- Font: Roboto (Material Design 3)
- Spacing: 16px base unit
- Radius: 12px (cards), 16px (images)

SCREENS (10 total):
1. Splash — Logo + auto-redirect (3s)
2. Login — Email/password + link to register
3. Register — Name/email/password + terms
4. Home — Dashboard (calorie card + recent scans)
5. Scan — Image picker (camera/gallery)
6. ScanResult — AI result + nutrition breakdown
7. History — Filterable scan list (swipe to delete)
8. Stats — Charts (7/30/90-day calories + macros)
9. Profile — User info (age/gender/height/weight)
10. EditProfile — Form to update profile

COMPONENTS:
- Bottom Navigation (5 tabs)
- AppBar with title + actions
- Primary/Secondary buttons
- Text input fields
- Cards with shadow
- Loading spinners + error states
- Empty states

KEY INTERACTION:
- Splash auto-redirect to Login (if not authenticated) or Home (if authenticated)
- FAB button: scan food
- Bottom nav: navigate between 5 main screens
- Filters on History: by meal type, date range
- Charts on Stats: switch period (7/30/90/365 days)

ACCESSIBILITY:
- Contrast: 4.5:1+
- Touch targets: 48x48dp
- All icons labeled
- I18n ready (en + vi)

DELIVERABLES:
- High-fidelity designs (all 10 screens)
- Component library (20+ reusable)
- Design system (colors, type, spacing)
- Interactive prototypes
- Figma specs for developer

DESIGN TOOL: Figma preferred
TIMELINE: 1-2 weeks
```

**Copy to**: Designer chat / Email subject

---

## PROMPT 3️⃣ — AI DESIGN TOOLS (Figma AI, Midjourney, etc)

### For **Figma AI** or **design agency AI**:

```
Design a mobile app interface system for a food AI recognition and calorie tracking app called "Food Lens AI"

VISUAL DIRECTION:
- Modern, clean, Material Design 3
- Health/wellness aesthetic
- Color palette: Green (#2E7D32) for healthy/primary, Orange (#FF6F00) for accents
- Background: Light gray (#F5F5F5)
- Typography: Roboto font family

SCREENS NEEDED (10 total):
1. Splash Screen (3s loading with logo)
2. Login Screen (email, password, register link)
3. Registration Screen (name, email, password, terms)
4. Home Dashboard (hello greeting, calorie summary card, recent scans list, FAB)
5. Scan Screen (image placeholder, camera button, gallery button)
6. Scan Result Screen (food image, food name, confidence score, calories, nutrition breakdown)
7. History Screen (filterable list of scans, grouped by date)
8. Stats Screen (7/30/90-day calorie trends, macro pie chart, goal comparison)
9. Profile Screen (user avatar, bio, BMI, TDEE, settings)
10. Edit Profile Screen (form with inputs, calculated fields)

SHARED COMPONENTS:
- Bottom Navigation Bar (5 tabs: home, scan, history, stats, profile)
- App Bar (green header)
- Buttons (primary green, secondary outlined, text links)
- Cards (rounded, shadow)
- Text input fields (with validation states)
- Loading spinners
- Error/empty state cards

STATES TO SHOW:
- Idle/default
- Loading (spinner)
- Error (red border, error text)
- Empty (no data)
- Success (green check)

ANIMATIONS & MOTION:
Page Transitions:
  - Enter: Slide 200ms from right + fade (decelerate easing)
  - Exit: Slide 150ms to right + fade (accelerate easing)
  - Replace: Cross-fade 300ms (standard easing)

Component Animations:
  - Button press: Scale 1.0 → 0.98 (100ms) with shadow elevation change
  - Spinner: 1.5s linear infinite rotation (primary green)
  - Progress bar: Fill 0% → target% (800ms ease-out)
  - List items: Cascade entrance (300ms + 30ms stagger per item)
  - Tab selection: Color 150ms standard easing
  - Card entrance: Slide up 40dp + fade (300ms decelerate)
  - Snackbar: Slide up 250ms enter, slide down 150ms exit
  - Modal: Scale 0.9 → 1.0 + fade (250ms standard + emphasis)
  - Tab switch: Current fades 0-150ms, new fades in 150-200ms

Micro-Interactions:
  - TextField focus: Border green 150ms, width 1px → 2px
  - Checkbox toggle: Mark draws 100ms + scale pulse 200ms
  - Hover effect: Elevation 2 → 4, scale 1.0 → 1.01 (150ms)
  - Pull-to-refresh: Rotate icon + fade on complete (360° rotation 500ms)
  - Empty state: Floating illustration 2s cycle (10dp vertical)

Easing Curves:
  - Standard: Cubic Bezier(0.0, 0.0, 0.2, 1)
  - Accelerate: Cubic Bezier(0.3, 0.0, 1.0, 1.0)
  - Decelerate: Cubic Bezier(0.0, 0.0, 0.2, 1.0)

Accessibility:
- High contrast (4.5:1+)
- Large touch targets (48x48dp)
- Clear labels
- No color-only info

TONE:
- Friendly, encouraging, supportive
- Modern but approachable
- Clear and actionable

Style Inspirations:
- Apple Health App (clean, colorful)
- MyFitnessPal (practical, data-focused)
- Notion (friendly, modern)

Create high-fidelity mockups ready for developer handoff.
Include component library and design system specs.
```

**Copy to**:

- Figma AI plugin
- Midjourney /describe
- Agency brief

---

## PROMPT 4️⃣ — FOR DEVELOPER HANDOFF

```
DESIGN SYSTEM SPECIFICATIONS

PROJECT: Food Lens AI (Flutter mobile app)
FRAMEWORK: Material Design 3
FIGMA LINK: [insert link]

COLOR PALETTE:
Primary Green:      #2E7D32
Primary Light:      #60AD5E
Primary Dark:       #005005
Accent Orange:      #FF6F00
Background:         #F5F5F5
Surface:            #FFFFFF
Text Primary:       #212121
Text Secondary:     #757575

Meal Type Colors:
Breakfast:          #FFB300
Lunch:              #1976D2
Dinner:             #7B1FA2
Snack:              #00897B

Semantic:
Success:            #43A047
Warning:            #FFA000
Error:              #D32F2F

TYPOGRAPHY:
Font: Roboto (Material default)

Headline 1:         28px, bold      (H1 text style)
Headline 2:         22px, bold      (H2 text style)
Title:              18px, semibold  (title text style)
Body:               14px, regular   (bodyMedium text style)
Caption:            12px, regular   (labelSmall text style)

SPACING:
Base unit:          16px
Small:              8px
Large:              24px
Extra large:        32px

RADIUS:
Cards/Buttons:      12px
Images:             16px
Large elements:     24px

SHADOWS:
Cards:              elevation 2 (Material default)

COMPONENTS:
- Buttons: See Material ElevatedButton, OutlinedButton, TextButton
- TextField: See Material TextFormField
- Cards: Card with shape: RoundedRectangleBorder
- AppBar: AppBar with primary green background
- FAB: FloatingActionButton with orange background
- BottomNav: NavigationBar with 5 destinations

RESPONSIVE:
Mobile (320px-600px): Default (all designs)
Tablet (600px+): Increase padding 24px, add 2-column layouts

FIGMA SPECS:
- Components: Auto-layout enabled
- Tokens: Define colors as variables
- Prototypes: Link all screens with proper interactions
- Specs: Export measurements, colors, typography

HANDOFF:
- Export as FigJam with specs
- Or use Figma Inspector for inline measurements
- Designer notes/comments on complex interactions
```

---

## HOW TO USE THESE PROMPTS

### 📌 Scenario 1: Share with Designer (First Time)

1. Send **PROMPT 2** (SHORT) in initial chat
2. Let designer review → ask questions
3. Send **PROMPT 1** (FULL) with Figma link after kick-off

### 📌 Scenario 2: Communicate via Email/Chat

- Use **PROMPT 2** (SHORT) in subject line
- Copy-paste in body or email
- Include color palette hex codes

### 📌 Scenario 3: Share with AI Design Tool

- Use **PROMPT 3** (AI TOOLS)
- Copy to Figma AI, [design tool], or prompt ChatGPT with images

### 📌 Scenario 4: Code Phase / Developer Review

- Use **PROMPT 4** (DEVELOPER)
- Attach Figma link
- Share design specs + components

### 📌 Scenario 5: Quick Sync / Standup

- Show **screen comparison table** from PROMPT 1
- "Status: Screens 1-5 done, 6-10 in progress"
- Ask designer specific questions per screen

---

## QUICK CHECKLIST — Before Sending Prompt

- [ ] Color palette confirmed (#hex codes)
- [ ] All 10 screen scopes clear?
- [ ] Design timeline agreed? (1-2 weeks? 2-4 weeks?)
- [ ] Designer has access to Figma?
- [ ] Any additional requirements (dark mode, tablet responsive)?
- [ ] Mockup expectations defined? (Wireframe? High-fidelity? Interactive?)
- [ ] I18n languages confirmed? (English + Vietnamese)
- [ ] Figma workspace shared with designer?

---

## TEMPLATE — Send to Designer

**Subject**: Design Brief — Food Lens AI (10 Mobile Screens)

**Body**:

```
Hi [Designer Name],

We're launching a new mobile app called "Food Lens AI" — a calorie tracking app with AI food recognition.

Please review the attached design brief and let me know your availability.

KEY INFO:
- Type: Flutter mobile app (iOS + Android)
- Screens: 10 total
- Design System: Material Design 3, Green + Orange
- Timeline: [2 weeks / 4 weeks]?
- Figma: [link] (invite sent)

QUICK OVERVIEW:
1. Splash & Auth (3 screens) → 2. Dashboard (1) → 3. Core feature (2) → 4. Analytics & Profile (4)

DELIVERABLES:
- High-fidelity designs (all 10 screens)
- Component library (reusable)
- Design system specs
- Interactive prototypes
- Developer handoff (Figma specs)

Full brief attached. Let me know if you have questions!

[Link to DESIGN_PROMPT.md]
[Figma Workspace Link]

Cheers,
[Your Name]
```

---

## COMMON QUESTIONS FOR DESIGNER

**Q: Should we design for dark mode?**  
A: Not now (Phase 1). Plan for it in Phase 2+.

**Q: Tablet/Desktop responsive?**  
A: Mobile-first (320px-600px). Tablet (600px+) can expand with same components.

**Q: What about animations?**  
A: Basic Flutter Material animations (200-300ms transitions). No heavy 3D.

**Q: How many components in library?**  
A: Target 20-30 (buttons, cards, inputs, etc). App bar, tabs, modals.

**Q: Do we need a style guide after?**  
A: Yes, embed in Figma. Developer can reference any screen/component.

**Q: What if design changes later?**  
A: Update Figma → Notify developer. Version control in Figma history.
