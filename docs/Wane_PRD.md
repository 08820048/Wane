# Wane — Product Requirements Document

**Version** 1.1  
**Date** 2025-06-15  
**Author** xuyi  
**Status** Draft

---

## 1. Overview

### 1.1 Product Summary

Wane is a native macOS menubar app that renders ultra-thin progress bars along the screen edges, visualizing how much of the current day, week, month, and year has elapsed. It is ambient by design — always visible, never intrusive, requiring zero interaction in day-to-day use.

### 1.2 Design Philosophy

- **Ambient, not alarming.** Wane shows time passing without creating anxiety. No notifications, no alerts, no countdowns.
- **Native and small.** Pure AppKit, zero dependencies, ships under 2 MB. Feels like part of the OS.
- **Invisible until needed.** The bars are thin enough to ignore; hover reveals detail only when the user chooses to look.

### 1.3 Target Users

Independent developers, designers, and knowledge workers who use Mac as their primary machine and value calm, aesthetic tools that respect their attention.

---

## 2. Core Features

### 2.1 Time Dimensions

Wane tracks four time dimensions simultaneously. Each is represented by one progress bar.

| Dimension | Range | Color |
|-----------|-------|-------|
| Today | Work start → Work end (user-defined) | Pink |
| This week | Monday 00:00 → Sunday 23:59 | Amber |
| This month | 1st 00:00 → Last day 23:59 | Teal |
| This year | Jan 1 00:00 → Dec 31 23:59 | Purple |

Each dimension can be independently enabled or disabled in Preferences.

### 2.2 Progress Bar Rendering

**Position options** (user selects one per display):

- Bottom edge (default)
- Top edge (below the menubar)
- Left edge
- Right edge

**Visual spec:**

- Default height/width: 2px
- On hover: expands to 5px with a smooth 150ms ease transition
- Background track: `rgba(255,255,255,0.06)` on dark wallpapers, auto-adapts
- Each dimension occupies its own bar slot, stacked from the selected edge inward
- Bars are rendered bottom-to-top (or outer-to-inner for side positions): Day → Week → Month → Year

**Rendering engine:** `NSView` with `draw(_:)` override, redraws triggered by a per-minute `Timer`.

### 2.3 Hover Interaction

When the cursor enters the bar area:

- All bars expand to 5px height
- A floating tooltip appears near the cursor showing:
  - Dimension label (e.g. "This week")
  - Percentage complete (e.g. "34%")
  - Human-readable detail (e.g. "Day 3 of 7" / "Day 166 of 365" / "14:23 — 59% of workday")
- Mouse events are re-enabled during hover via `NSTrackingArea`; restored to pass-through on exit

No click interaction is required in v1.0.

### 2.4 Multi-Display Support

Wane creates one `EdgeWindow` instance per connected display (`NSScreen.screens`). Each display can have independent position settings. Display connect/disconnect events are handled via `NSApplicationDidChangeScreenParametersNotification`.

### 2.5 Preferences

Accessible via the menubar icon → "Preferences…" or `⌘,`.

**General tab:**

| Setting | Type | Default |
|---------|------|---------|
| Launch at login | Toggle | On |
| Show menubar icon | Toggle | On |

**Progress bars tab:**

| Setting | Type | Default |
|---------|------|---------|
| Today — enabled | Toggle | On |
| Today — work start | Time picker | 09:00 |
| Today — work end | Time picker | 18:00 |
| This week — enabled | Toggle | On |
| This month — enabled | Toggle | On |
| This year — enabled | Toggle | On |
| Bar position | Segment control (Bottom / Top / Left / Right) | Bottom |
| Bar thickness | Slider 1–4px | 2px |

**Appearance tab:**

| Setting | Type | Default |
|---------|------|---------|
| Today color | Color well | Pink |
| This week color | Color well | Amber |
| This month color | Color well | Teal |
| This year color | Color well | Purple |
| Bar opacity | Slider 20–100% | 70% |

All settings stored in `UserDefaults` and observed via `@AppStorage` in the SwiftUI Settings view.

---

## 3. Technical Architecture

### 3.1 Tech Stack

| Layer | Technology |
|-------|-----------|
| Language | Swift 5.9+ |
| UI — bars | AppKit (`NSWindow`, `NSView`) |
| UI — settings | SwiftUI (`Settings` scene) |
| Persistence | `UserDefaults` |
| Dependencies | None |
| Minimum macOS | 13.0 Ventura |

### 3.2 Window Layer

```swift
window.level = NSWindow.Level.desktopIcon  // sits above wallpaper, below all app windows
window.backgroundColor = .clear
window.isOpaque = false
window.hasShadow = false
window.ignoresMouseEvents = true           // default: fully pass-through
window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
```

`canJoinAllSpaces` ensures bars persist across all Spaces and full-screen transitions.

### 3.3 Project Structure

```
Wane/
├── App/
│   ├── WaneApp.swift              // Entry point, AppDelegate
│   └── AppDelegate.swift          // Menubar icon, lifecycle
├── Window/
│   ├── EdgeWindow.swift           // NSWindow subclass
│   ├── EdgeWindowController.swift // Per-screen controller
│   └── ProgressBarView.swift      // NSView, core rendering
├── Core/
│   ├── TimeProgress.swift         // Progress calculations (day/week/month/year)
│   └── ScreenManager.swift        // Multi-display management
└── Settings/
    └── SettingsView.swift         // SwiftUI Preferences window
```

### 3.4 Time Calculation Logic

```
Day progress   = (now - workStart) / (workEnd - workStart)
Week progress  = (weekdayIndex * 86400 + secondsToday) / 604800
Month progress = (dayOfMonth - 1 + fractionOfDay) / daysInMonth
Year progress  = dayOfYear / daysInYear
```

All values clamped to [0.0, 1.0]. Timer fires every 60 seconds and calls `setNeedsDisplay()` on all `ProgressBarView` instances.

---

## 4. User Interface

### 4.1 Menubar Icon

- Icon: a minimal horizontal line with a small filled segment (representing progress)
- Clicking the icon shows a compact popover with live percentage readouts for all four dimensions
- Popover also contains quick links to Preferences and Quit

### 4.2 Preferences Window

Standard macOS Settings window with three tabs: General, Progress Bars, Appearance. Implemented as a SwiftUI `Settings` scene.

### 4.3 Onboarding

On first launch, a single native alert:

> "Wane adds subtle progress bars to your screen edge. You can configure them anytime from the menubar icon."

One button: "Get Started". No further onboarding.

---

## 5. Distribution

### 5.1 Open Source

Wane is fully open source. The complete source code is hosted on GitHub at `github.com/xuyi/wane`.

**License: Apache 2.0 + Commons Clause**

The Commons Clause addendum is appended to the Apache 2.0 license. This means:

| Permission | Allowed |
|-----------|---------|
| View and study source code | ✅ |
| Fork and modify for personal use | ✅ |
| Submit pull requests and contribute | ✅ |
| Redistribute with attribution | ✅ |
| Sell the software or a derivative | ❌ |
| Wrap as a paid SaaS or hosted service | ❌ |
| Repackage and submit to App Store for profit | ❌ |

The original author (xuyi) retains full rights to commercialize the software, including App Store distribution. Contributors agree that their contributions are licensed under the same terms via a standard CLA comment in the PR template.

**LICENSE file (root of repository):**

```
Apache License 2.0 with Commons Clause

Commons Clause License Condition v1.0

The Software is provided to you by the Licensor under the License,
as defined below, subject to the following condition.

Without limiting other conditions in the License, the grant of rights
under the License will not include, and the License does not grant to
you, the right to Sell the Software.

For purposes of the foregoing, "Sell" means practicing any or all of
the rights granted to you under the License to provide to third parties,
for a fee or other consideration (including without limitation fees for
hosting or use of the Software as a service), a product or service
whose value derives, entirely or substantially, from the functionality
of the Software.

"Licensor" means xuyi / 慕予科技.
"Software" means Wane.
"License" means the Apache License 2.0.
```

### 5.2 App Store

Primary paid distribution channel. Wane requires no sensitive entitlements (no file access, no screen recording, no contacts). Sandbox-compatible with no special review risk.

One-time purchase, **$4.99**. No subscription, no freemium. Rationale: the tool is small and complete; a single low price matches the "small but beautiful" positioning and lowers the purchase decision threshold.

### 5.3 Direct Download (v1.1)

Notarized `.dmg` distributed via the Wane website (`wane.app`) for users who prefer not to use the App Store. Same binary, different provisioning profile. Free download — users who want to support the project are directed to the App Store version or a GitHub Sponsors link.

### 5.4 GitHub Repository Structure

```
wane/
├── LICENSE               // Apache 2.0 + Commons Clause
├── README.md             // Product intro, screenshots, build instructions
├── CONTRIBUTING.md       // How to file issues and submit PRs
├── Wane.xcodeproj
└── Wane/                 // Source code
```

`README.md` prominently links to the App Store for users who want a one-click install, and includes a "Build from source" section for developers.

---

## 6. Scope

### v1.0 — MVP

- Four time dimensions with independent enable/disable
- Bottom edge position (single display)
- Hover tooltip
- Preferences: work hours, color, opacity, launch at login
- App Store submission

### v1.1

- Multi-display support with per-display settings
- Left / Right / Top edge positions
- Direct distribution `.dmg`

### v1.2 (if demand exists)

- Custom dimensions (e.g. project deadline, a specific date countdown)
- Menu bar popover with richer stats
- iCloud sync for Preferences across Macs

### Out of scope (permanently)

- iOS / iPadOS version
- Notifications or alerts of any kind
- Widgets (Notification Center)
- Any network requests

---

## 7. Success Metrics

| Metric | 30-day target |
|--------|--------------|
| App Store downloads | 500 |
| Rating | ≥ 4.5 stars |
| Refund rate | < 5% |
| ProductHunt upvotes | 200 |

---

## 8. Risks

| Risk | Likelihood | Mitigation |
|------|-----------|-----------|
| macOS version changes window level behavior | Low | Test each major macOS release; `desktopIcon` level is stable since macOS 10.x |
| Full-screen apps hide bars entirely | Expected | Acceptable; document in App Store description |
| Bars conflict visually with light wallpapers | Medium | Auto-detect average wallpaper brightness; adjust bar opacity accordingly (v1.1) |
| App Store rejection for window level usage | Low | This technique is used by established apps (e.g. Übersicht); no sensitive entitlements needed |
