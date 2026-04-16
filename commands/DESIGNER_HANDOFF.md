# 📦 DESIGNER HANDOFF PACKAGE — Food Lens AI

> Tất cả tài liệu cần thiết để designer bắt đầu thiết kế ứng dụng Food Lens AI

---

## 🎯 CÓ 3 CÁCH SỬ DỤNG TÀI LIỆU NÀY

### ⏱️ **Cách 1: 5 PHÚT** (NHANH NHẤT)

Nếu bạn **chỉ muốn bắt đầu design ngay**, đọc:

1. **DESIGN_PROMPT.md** — Bản tóm tắt 1-2 phút
   - Tất cả 10 màn hình, layout, components
   - Color palette, typography, spacing

→ Sau đó mở Figma và thiết kế ngay!

---

### 📋 **Cách 2: 15 PHÚT** (ĐẦY ĐỦ)

Nếu bạn muốn **hiểu chi tiết trước khi start**:

**Thứ tự đọc**:

1. **CLAUDE.md** (1 phút) — Project overview
2. **UI_DESIGN_GUIDE.md** (5 phút) — 10 screens visually
3. **DESIGN_PROMPT.md** (5 phút) — Full brief
4. **ANIMATION_GUIDE.md** (5 phút) — Motion design

→ Bây giờ bạn hiểu toàn bộ project, design system, animations

---

### 🔧 **Cách 3: 30 PHÚT** (HOÀN TOÀN MASTER)

Nếu bạn muốn **setup Figma với animations ngay từ đầu**:

**Thứ tự đọc**:

1. **CLAUDE.md** (1 phút)
2. **UI_DESIGN_GUIDE.md** (5 phút)
3. **DESIGN_PROMPT.md** (5 phút)
4. **ANIMATION_GUIDE.md** (5 phút)
5. **FIGMA_ANIMATION_GUIDE.md** (15 phút) — Step-by-step setup

→ Bạn sẽ thiết kế với animations sẵn trong Figma prototypes

---

## 📂 FILE STRUCTURE — NÀY LÀ CÁC FILE CẦN

```
📦 DESIGNER HANDOFF FOLDER
│
├── 📄 CLAUDE.md (START HERE!)
│   └─ Project overview, tech stack, team info
│
├── 📄 UI_DESIGN_GUIDE.md ⭐
│   └─ 10 screens with ASCII mockups + design system
│   └─ Colors, typography, spacing, responsive rules
│   └─ States, interactions, accessibility
│
├── 📄 DESIGN_PROMPT.md ⭐⭐
│   └─ COMPLETE brief (3000+ words)
│   └─ Every screen detail, components, animations
│   └─ Copy-paste this to Figma or share with designer
│
├── 📄 ANIMATION_GUIDE.md ⭐⭐
│   └─ Motion design specifications
│   └─ 10+ animation types with Flutter code
│   └─ Timings, easing, accessibility
│
├── 📄 FIGMA_ANIMATION_GUIDE.md 🎬 (IF using Figma)
│   └─ Step-by-step: How to setup animations in Figma
│   └─ Screen-by-screen animation setup
│   └─ Recommended plugins
│   └─ Handoff checklist
│
└── 📄 DESIGN_PROMPTS_COLLECTION.md
    └─ 4 different prompts for different audiences
    └─ Short brief, long brief, AI tools, developer
```

---

## 👥 SEND TO DESIGNER

**Option A: Copy-paste from DESIGN_PROMPT.md**

```markdown
Hey [Designer name],

Here's the complete brief for Food Lens AI project:

[COPY ENTIRE CONTENT FROM DESIGN_PROMPT.md]

Key files for reference:

- UI_DESIGN_GUIDE.md — Visual reference with ASCII mockups
- ANIMATION_GUIDE.md — Motion design specifications
- FIGMA_ANIMATION_GUIDE.md — How to setup in Figma

Let me know if you have questions!
```

**Option B: Share files directly**

Send these 4 files:

1. ✅ `DESIGN_PROMPT.md` — Full brief
2. ✅ `UI_DESIGN_GUIDE.md` — Visual specs
3. ✅ `ANIMATION_GUIDE.md` — Motion design
4. ✅ `FIGMA_ANIMATION_GUIDE.md` — Figma setup

**Option C: Use DESIGN_PROMPTS_COLLECTION.md**

Use **PROMPT 2** (Short Brief) for quick communication:

```markdown
[COPY FROM DESIGN_PROMPTS_COLLECTION.md - PROMPT 2]

Then attach:

- UI_DESIGN_GUIDE.md
- FIGMA_ANIMATION_GUIDE.md
```

---

## 🎯 WHAT DESIGNER NEEDS TO DELIVER

**Deliverables** (timeline depends on designer):

### Phase 1: High-Fidelity Designs ✅

- [ ] All 10 screens in Figma (high-fidelity)
- [ ] Design system components (library)
- [ ] Color palette established
- [ ] Typography applied
- [ ] Spacing & layout grid
- [ ] Interactive states (hover, active, error, loading)

### Phase 2: Animation Specifications ✅

- [ ] Page transitions setup in Figma prototypes
- [ ] Button interaction animations
- [ ] List cascade animations
- [ ] Chart animations
- [ ] Micro-interactions (text field focus, etc.)
- [ ] Motion Design Specifications frame in Figma

### Phase 3: Developer Handoff 📤

- [ ] Figma file shared with developer
- [ ] All layers properly named
- [ ] Components organized
- [ ] Design tokens exported (colors, spacing)
- [ ] Animation specs documented (MP4/GIF videos)
- [ ] Code-ready exports (if using Anima plugin)

---

## 📊 PROJECT OVERVIEW

**App Name**: Food Lens AI (Hệ thống AI nhận diện món ăn + ước tính calo)

**10 Screens to Design**:

1. 🎨 **Splash Screen** — Logo + tagline, auto-navigate
2. 🔐 **Login Screen** — Email/password + social login
3. 📝 **Register Screen** — Sign-up form
4. 🏠 **Home Screen** — Daily calorie progress + recent scans
5. 📷 **Scan Screen** — Camera/gallery selector
6. 🎯 **Scan Result Screen** — AI detected food + predictions
7. 📜 **History Screen** — Past scans list + filters
8. 📊 **Stats Screen** — Charts, nutrition breakdown
9. 👤 **Profile Screen** — User info, settings
10. ✏️ **Edit Profile Screen** — Update user details

**Design System**:

- **Colors**: Green (#2E7D32) primary, Orange (#FF6F00) accent, Gray neutral
- **Typography**: Roboto, 4 sizes (Headline → Caption)
- **Spacing**: 16px base, 12px radius cards, 16px radius images
- **Icons**: Material Icons 24dp + 20dp
- **Shadows**: Card elevation 2dp, button on press 4dp

---

## ⏰ TIMING GUIDELINES

**Animation Durations** (all in milliseconds):

- Page enter: **200ms** (Decelerate slide + fade)
- Page exit: **150ms** (Accelerate slide + fade)
- Button press: **100ms** (Scale + shadow)
- List cascade: **300ms** base + **30ms** stagger
- Chart bars: **350ms** per bar, **50ms** stagger
- Spinner: **1500ms** infinite (linear)
- Modal enter: **250ms** (Scale + fade, Standard)
- Tab switch: **200ms** (Cross-fade)

---

## 🚀 NEXT STEPS FOR DESIGNER

### Step 1: Read Documentation

- [ ] Read this file (you are here ✓)
- [ ] Skim DESIGN_PROMPT.md
- [ ] Refer to UI_DESIGN_GUIDE.md as needed
- [ ] Review ANIMATION_GUIDE.md
- [ ] If using Figma: Read FIGMA_ANIMATION_GUIDE.md

### Step 2: Set Up Design File

- [ ] Create Figma project for Food Lens AI
- [ ] Create design system (colors, typography, components)
- [ ] Import these specs into Figma
- [ ] Start designing screens following UI_DESIGN_GUIDE.md

### Step 3: Create High-Fidelity Designs

- [ ] Design all 10 screens
- [ ] Apply design system consistently
- [ ] Create interactive states
- [ ] Test responsive breakpoints

### Step 4: Add Animations

- [ ] Follow FIGMA_ANIMATION_GUIDE.md
- [ ] Set up Figma prototypes
- [ ] Connect animations end-to-end
- [ ] Create "Motion Design Specifications" frame
- [ ] Test prototypes (use Figma Play button)

### Step 5: Handoff to Developer

- [ ] Export design system tokens
- [ ] Share Figma file with developer
- [ ] Provide animation spec videos (MP4/GIF)
- [ ] Answer questions, clarify interactions
- [ ] Iterate based on developer feedback

---

## 💬 COMMUNICATION TIPS

**When Designer has Questions**:

1. **"How should X component look?"**
   → Refer to UI_DESIGN_GUIDE.md [Screen Name] → Components section

2. **"What's the timing for this animation?"**
   → Check ANIMATION_GUIDE.md quick reference table
   → Also see FIGMA_ANIMATION_GUIDE.md for Figma-specific setup

3. **"What colors should I use?"**
   → DESIGN_PROMPT.md → Design System → Colors section
   → Primary: #2E7D32, Secondary: #FF6F00, Neutral: #F5F5F5

4. **"Should I design for dark mode?"**
   → Currently: Light mode only (future phase)
   → Focus on light theme implementation

5. **"How do I export to developer?"**
   → Share Figma link directly
   → Export components as PNG/SVG for assets
   → Use Anima plugin for code generation (optional)

---

## ✅ FINAL CHECKLIST

Before sending to designer:

- [ ] README.md explains project
- [ ] CLAUDE.md has team info & stack
- [ ] UI_DESIGN_GUIDE.md has all screen visuals
- [ ] DESIGN_PROMPT.md has complete brief (copy-paste ready)
- [ ] ANIMATION_GUIDE.md has motion specs
- [ ] FIGMA_ANIMATION_GUIDE.md has Figma instructions
- [ ] DESIGN_PROMPTS_COLLECTION.md has 4 template options
- [ ] All files in GitHub (or Figma folder)
- [ ] Designer has access to:
  - GitHub repo (read-only)
  - Figma project (edit access)
  - This handoff package
- [ ] Designer knows next steps & timeline

---

## 📌 QUICK LINKS (For Reference)

**Project files**:

- Code: `d:\CaloriesAI\food_lens\lib\` (Flutter)
- Assets: `d:\CaloriesAI\food_lens\assets\` (images, icons)
- Docs: `d:\CaloriesAI\food_lens\docs\`

**References**:

- Flutter Docs: https://flutter.dev/docs
- Material Design 3: https://m3.material.io/
- Firebase UI: https://firebase.google.com/docs/auth/flutter/start
- Figma Docs: https://help.figma.com/

**Design Tools**:

- Figma: https://figma.com/
- Penpot (Free): https://penpot.app/ (alternative to Figma)
- Adobe XD: https://www.adobe.com/products/xd.html (alternative)

---

## 🎉 DESIGNER READY!

Everything is prepared. Designer can now:

1. ✅ Understand the project completely
2. ✅ Know all screens to design (10 screens)
3. ✅ Follow design system (colors, typography, spacing)
4. ✅ Implement animations (timings + easing)
5. ✅ Set up Figma prototypes
6. ✅ Hand off to developer with clarity

**Timeline Estimate**:

- Design system setup: 1-2 hours
- High-fidelity designs (10 screens): 2-3 days
- Animation setup in Figma: 1-2 days
- Developer handoff & revisions: 1 day

**Total: 3-5 days for complete design handoff**

---

**Questions?** Check the relevant file above or create an issue in GitHub!

Happy designing! 🎨✨
