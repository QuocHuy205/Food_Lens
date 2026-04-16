# 🎬 ANIMATION GUIDE — Food Lens AI

> Hướng dẫn chi tiết animation cho designer + developer (Flutter code examples)

---

## 📋 QUICK REFERENCE — Animation Timings

| Component             | Duration | Easing      | Effect                      |
| --------------------- | -------- | ----------- | --------------------------- |
| **Button Press**      | 100ms    | standard    | Scale 1.0 → 0.98            |
| **Loading Spinner**   | 1.5s     | linear      | 360° rotation infinite      |
| **Page Enter**        | 200ms    | decelerate  | Slide +180dp, fade 0→1      |
| **Page Exit**         | 150ms    | accelerate  | Slide -180dp, fade 1→0      |
| **Progress Bar**      | 800ms    | ease-out    | Width 0% → target%          |
| **List Item**         | 300ms    | decelerate  | Slide up 40dp + fade        |
| **Stagger Delay**     | +30ms    | —           | Between items               |
| **Tab Focus**         | 150ms    | standard    | Border → green, width 1→2px |
| **Snackbar Enter**    | 250ms    | decelerate  | Slide up 80dp + fade        |
| **Snackbar Exit**     | 150ms    | accelerate  | Slide down 80dp + fade      |
| **Modal Pop**         | 250ms    | standard    | Scale 0.9 → 1.0 + fade      |
| **Chip Toggle**       | 150ms    | standard    | BG color change             |
| **Tab Switch**        | 200ms    | standard    | Cross-fade                  |
| **FAB Pulse**         | 600ms    | ease-in-out | Shadow elevation pulse      |
| **Empty State Float** | 2s       | ease-in-out | Y ±10dp infinite            |

---

## 🎨 EASING CURVES

### Material Design 3 Standard Curves

```
STANDARD (Default)
┌─ Cubic Bezier(0.0, 0.0, 0.2, 1.0)
│  Use: Most animations, balanced accelerate + decelerate
│  Duration: 150-300ms
│  Feeling: Natural, not too fast or slow

DECELERATE (Emphasis on Entry)
┌─ Cubic Bezier(0.0, 0.0, 0.2, 1.0)
│  Use: Screen entrance, items entering, modal open
│  Duration: 200-300ms
│  Feeling: Fast start, slows down at end (eases in)

ACCELERATE (Emphasis on Exit)
┌─ Cubic Bezier(0.3, 0.0, 1.0, 1.0)
│  Use: Screen exit, dismissing content, leaving focus
│  Duration: 150-200ms
│  Feeling: Slow start, speeds up at end (eases out)

LINEAR (No Easing)
┌─ Cubic Bezier(0.0, 0.0, 1.0, 1.0)
│  Use: Spinners, progress indicators, continuous rotation
│  Duration: 1.5-3s
│  Feeling: Constant speed, mechanical
```

**Visual Representation**:

```
Standard       ┌──────┐
               │     /
              /│    /
             / │___/
    ────────┴──

Decelerate     ┌─────────
               │        /
              /│       /
             / │______/
    ────────┴──

Accelerate          ───
                   /   \
                  /     \
                 /       └───
    ────────────┴───

Linear         ───────────/
               /
              /
             /
    ────────┴──────────
```

---

## 🎯 PAGE TRANSITIONS

### 1. Screen Enter (From Right)

**Scenario**: User navigates to new screen

**Animation**:

```
Position X:   Screen Width → 0
Opacity:      0 → 1
Duration:     200ms
Easing:       Decelerate
Shadow:       Light shadow follows

Visual:
Screen slides in from right side smoothly
Starts quick, slows down at end
```

**Flutter Code**:

```dart
// Slide + Fade Animation
Transition(
  duration: Duration(milliseconds: 200),
  transitionsBuilder: (context, anim, secondaryAnim, child) {
    const begin = Offset(1.0, 0.0); // Start right
    const end = Offset.zero;         // End center
    const curve = Curves.easeOut;    // Decelerate

    var tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );

    return SlideTransition(
      position: anim.drive(tween),
      child: FadeTransition(
        opacity: anim,
        child: child,
      ),
    );
  },
  pageBuilder: (context, anim, secondaryAnim) => NewScreen(),
)
```

### 2. Screen Exit (To Right)

**Scenario**: User goes back / navigates away

**Animation**:

```
Position X:   0 → -Screen Width
Opacity:      1 → 0 (optional)
Duration:     150ms
Easing:       Accelerate
```

**Flutter Code**:

```dart
Transition(
  duration: Duration(milliseconds: 150),
  transitionsBuilder: (context, anim, secondaryAnim, child) {
    const begin = Offset.zero;
    const end = Offset(-1.0, 0.0); // Exit left
    const curve = Curves.easeIn;   // Accelerate

    var tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );

    return SlideTransition(
      position: anim.drive(tween),
      child: child,
    );
  },
  pageBuilder: (context, anim, secondaryAnim) => PrevScreen(),
)
```

### 3. Cross-Fade (Replace Content)

**Scenario**: Same tab, data updates

**Animation**:

```
Current:      Fade 1 → 0 (150ms)
New:          Fade 0 → 1 (150ms, delay 100ms)
Total:        300ms
Easing:       Standard
```

**Flutter Code**:

```dart
AnimatedSwitcher(
  duration: Duration(milliseconds: 300),
  transitionBuilder: (child, animation) {
    return FadeTransition(opacity: animation, child: child);
  },
  // On data change, widget rebuilds with new child
  child: NewContentWidget(key: ValueKey(data)),
)
```

---

## 🔘 BUTTON ANIMATIONS

### Button Press (Scale + Shadow)

**Scenario**: User taps a button

**Animation**:

```
Press Down (100ms):
  - Scale:   1.0 → 0.98
  - Shadow:  elevation 2 → 4
  - Overlay: slight dark overlay

Release (100ms):
  - Scale:   0.98 → 1.0
  - Shadow:  4 → 2
  - Overlay: fade out
```

**Flutter Code**:

```dart
class AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void _onButtonPress() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ElevatedButton(
          onPressed: _onButtonPress,
          child: Text(widget.label),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

---

## 🔄 LOADING SPINNER

### Material Circular Progress

**Animation**:

```
Rotation:     0° → 360° infinite
Duration:     1.5s per cycle
Easing:       Linear (no easing)
Color:        Primary Green (#2E7D32)
Size:         48x48 dp
```

**Flutter Code**:

```dart
// Built-in Material spinner
CircularProgressIndicator(
  color: AppColors.primary,
  strokeWidth: 4.0,
)

// Or custom (Lottie recommended for complex)
Lottie.asset('assets/spinner.json', repeat: true)
```

---

## 📊 PROGRESS BAR FILL

### Animated Bar (Calories Example)

**Animation**:

```
Width:        0% → 92.5%
Duration:     800ms
Easing:       ease-out (decelerate)
Color:        Green (#2E7D32) adjusts based on value
              - Safe (<goal): Green
              - Warning (~goal): Orange
              - Exceeded (>goal): Red
```

**Flutter Code**:

```dart
class AnimatedProgressBar extends StatefulWidget {
  final double current;
  final double max;

  @override
  _AnimatedProgressBarState createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    final percentage = widget.current / widget.max;
    _animation = Tween<double>(begin: 0, end: percentage).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  Color _getColor(double percentage) {
    if (percentage <= 0.85) return Colors.green; // Safe
    if (percentage <= 1.0) return Colors.orange;  // Warning
    return Colors.red;                            // Exceeded
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final percent = _animation.value;
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 12,
            color: Colors.grey[300],
            child: FractionallySizedBox(
              widthFactor: percent,
              child: Container(
                color: _getColor(percent),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

---

## 📜 LIST ITEM CASCADE (Staggered Entrance)

### Items Appear One by One

**Animation**:

```
Item 1:       Delay 0ms,   Animate 300ms (slide up 40dp + fade)
Item 2:       Delay 30ms,  Animate 300ms
Item 3:       Delay 60ms,  Animate 300ms
Item 4:       Delay 90ms,  Animate 300ms
Item 5:       Delay 120ms, Animate 300ms

Total effect: ~430ms for 5 items to fully appear
```

**Flutter Code**:

```dart
class CascadeListView extends StatelessWidget {
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _CascadeItem(
          item: items[index],
          delay: Duration(milliseconds: 30 * index),
        );
      },
    );
  }
}

class _CascadeItem extends StatefulWidget {
  final String item;
  final Duration delay;

  @override
  _CascadeItemState createState() => _CascadeItemState();
}

class _CascadeItemState extends State<_CascadeItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5), // Start 40dp down
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Card(child: Text(widget.item)),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

---

## 🔔 SNACKBAR NOTIFICATION

### Slide Up + Fade In

**Animation**:

```
Enter:
  Y Offset:   +80dp → 0
  Opacity:    0 → 1
  Duration:   250ms
  Easing:     Decelerate

Exit:
  Y Offset:   0 → +80dp
  Opacity:    1 → 0
  Duration:   150ms
  Easing:     Accelerate
```

**Flutter Code**:

```dart
void showAnimatedSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
      // Material automatically animates snackbar
      // Customize with animation in theme if needed
    ),
  );
}

// Or custom animated snackbar:
class AnimatedSnackBar {
  static void show(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    final animation = AnimationController(
      duration: Duration(milliseconds: 250),
      vsync: Scaffold.of(context),
    );

    entry = OverlayEntry(
      builder: (context) => SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: FadeTransition(
          opacity: animation,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(message, style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ),
    );

    overlay?.insert(entry);
    animation.forward();

    Future.delayed(Duration(seconds: 3), () {
      animation.reverse().then((_) => entry.remove());
    });
  }
}
```

---

## 🎪 MODAL/DIALOG POP-IN

### Scale + Fade

**Animation**:

```
Dialog:
  Scale:      0.90 → 1.0
  Opacity:    0 → 1
  Duration:   250ms
  Easing:     Standard (with emphasis)

Overlay:
  Opacity:    0 → 0.4 (black)
  Duration:   250ms
  Easing:     Standard
```

**Flutter Code**:

```dart
void showAnimatedDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.4),
    barrierLabel: 'Dialog',
    transitionDuration: Duration(milliseconds: 250),
    pageBuilder: (context, anim1, anim2) {
      return Dialog(
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Delete this scan?'),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
                  ElevatedButton(onPressed: () => Navigator.pop(context), child: Text('Delete')),
                ],
              ),
            ],
          ),
        ),
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0.9, end: 1.0).animate(
          CurvedAnimation(parent: anim1, curve: Curves.easeOut),
        ),
        child: FadeTransition(
          opacity: anim1,
          child: child,
        ),
      );
    },
  );
}
```

---

## 🏷️ TEXTFIELD FOCUS

### Border Color + Width Change

**Animation**:

```
Border Color:     #E0E0E0 → Primary Green (#2E7D32)
Border Width:     1px → 2px
Shadow:           none → subtle (elevation 1)
Duration:         150ms
Easing:           Standard
```

**Flutter Code**:

```dart
class AnimatedTextField extends StatefulWidget {
  final String label;

  @override
  _AnimatedTextFieldState createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _focusController;
  late Animation<Color?> _borderColorAnimation;
  late Animation<double> _borderWidthAnimation;

  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );

    _borderColorAnimation = ColorTween(
      begin: Colors.grey[300],
      end: AppColors.primary,
    ).animate(CurvedAnimation(parent: _focusController, curve: Curves.easeOut));

    _borderWidthAnimation = Tween<double>(begin: 1, end: 2).animate(
      CurvedAnimation(parent: _focusController, curve: Curves.easeOut),
    );

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _focusController.forward();
      } else {
        _focusController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _focusController,
      builder: (context, child) {
        return TextField(
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: widget.label,
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: _borderColorAnimation.value ?? Colors.grey[300]!,
                width: _borderWidthAnimation.value,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _focusController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
```

---

## 🎚️ TAB SELECTION ANIMATION

### Chip / Tab Toggle

**Animation**:

```
Background:     Transparent → Primary Green
Text Color:     Gray → White
Duration:       150ms
Easing:         Standard
Scale:          1.0 (no scale, pure color)
```

**Flutter Code**:

```dart
class AnimatedChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  _AnimatedChipState createState() => _AnimatedChipState();
}

class _AnimatedChipState extends State<AnimatedChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _bgColorAnimation;
  late Animation<Color?> _textColorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );

    if (widget.isSelected) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _bgColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: AppColors.primary,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _textColorAnimation = ColorTween(
      begin: Colors.grey,
      end: Colors.white,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _bgColorAnimation.value,
            border: Border.all(color: AppColors.primary),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.label,
            style: TextStyle(color: _textColorAnimation.value),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

---

## ✨ EMPTY STATE FLOATING ANIMATION

### Gentle Up/Down Float

**Animation**:

```
Y Position:     -10dp → 0 → -10dp (cycle)
Duration:       2s per cycle
Easing:         ease-in-out
Loop:           Infinite
Purpose:        Keep empty state feeling alive
```

**Flutter Code**:

```dart
class FloatingEmptyState extends StatefulWidget {
  @override
  _FloatingEmptyStateState createState() => _FloatingEmptyStateState();
}

class _FloatingEmptyStateState extends State<FloatingEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<Offset>(
      begin: Offset(0, -10),
      end: Offset(0, 10),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SlideTransition(
            position: _floatAnimation,
            child: Icon(Icons.restaurant, size: 64, color: Colors.grey),
          ),
          SizedBox(height: 24),
          Text('Không có lịch sử', style: TextStyle(fontSize: 18)),
          Text('Bạn chưa scan món ăn nào',style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

---

## 🔊 ACCESSIBILITY — prefers-reduced-motion

**Implementation**:

```dart
bool isReducedMotion(BuildContext context) {
  return MediaQuery.of(context).disableAnimations;
}

// In your animation widget:
Duration getDuration(BuildContext context) {
  if (isReducedMotion(context)) {
    return Duration(milliseconds: 0); // Instant
  }
  return Duration(milliseconds: 300);
}

// Usage:
AnimatedBuilder(
  animation: _controller,
  builder: (context, child) {
    return Transform.scale(
      scale: isReducedMotion(context) ? 1.0 : _animation.value,
      child: child,
    );
  },
)
```

---

## ⚡ PERFORMANCE TIPS

### DO ✅

```
✓ Use GPU-accelerated properties (transform, opacity)
✓ Keep animations 150-500ms
✓ Limit concurrent animations (max 3-4)
✓ Test on low-end devices (60fps target)
✓ Use `RepaintBoundary` for complex widgets
✓ AnimatedBuilder instead of setState loop
✓ Dispose controllers properly
✓ Use `SingleTickerProviderStateMixin` (single animation)
✓ Use `TickerProviderStateMixin` (multiple animations)
```

### DON'T ❌

```
✗ Animate width/height (use scale transform instead)
✗ Blur/shadow in complex animations (performance hit)
✗ Chain too many animations (feels choppy)
✗ Skip prefers-reduced-motion check
✗ Leave AnimationControllers undisposed
✗ Use setState in animation callback
✗ Animate more than 4 properties simultaneously
```

---

## 🎭 TESTING ANIMATIONS

### Slow Motion (Developer Mode)

```
Flutter devtools → Inspector → slow animation (2x)
Or: `flutter run --slow-animations`
```

### Test Devices

```
- Real device (measure actual 60fps)
- Low-end simulator (e.g., iPhone SE, Pixel 3a)
- High-end simulator (e.g., iPhone 14, Pixel 7 Pro)
```

### Metrics

```
- Target: 60fps (16.67ms per frame)
- Acceptable: No jank/stuttering
- Skip frames: Use profiler to detect
```

---

## 🎬 ANIMATION CHECKLIST

Before shipping:

- [ ] All page transitions 150-300ms
- [ ] Button press feels snappy (100ms)
- [ ] List items cascade smoothly (30ms stagger)
- [ ] Loading spinners are smooth (no jank)
- [ ] Prefers-reduced-motion respected
- [ ] All AnimationControllers disposed
- [ ] Tested on real device (60fps)
- [ ] No concurrent animations >4
- [ ] Icons feel responsive
- [ ] Empty states feel alive
- [ ] Modals pop smoothly
- [ ] All transitions GPU-accelerated
- [ ] No color-only animations (accessibility)

---

## 🔗 REFERENCES

- **Material Design Motion**: https://material.io/design/motion/understanding-motion.html
- **Flutter Animation Docs**: https://flutter.dev/docs/development/ui/animations
- **Cubic Bezier Visualizer**: https://cubic-bezier.com/
- **Android Motion Guidelines**: https://developer.android.com/design/motion#fast-building-the-framework
