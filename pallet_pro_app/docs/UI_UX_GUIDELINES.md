# Pallet Pro — UI/UX Design Guidelines

> **Source:** Extracted from the Gemini vs. Claude Design Debate.  
> **Philosophy:** "Hook them with emotion, keep them with utility."

---

## 1. Color System

### Primary Palette
| Token | Hex | Usage |
|-------|-----|-------|
| `money-green` | #2E7D32 | Primary actions (buttons, confirmations) |
| `profit-green` | #43A047 | Profit displays (large numbers, trend arrows) |
| `loss-red` | #D32F2F | Loss displays |
| `opportunity-gold` | #FFA000 | Actionable opportunities ("List this now") |
| `warning-orange` | #FF9800 | Stale items, pending actions |

### Status Edge Colors (Muted)
| Status | Hex | Width |
|--------|-----|-------|
| `in_stock` | #9E9E9E (Grey 500) | 2dp hairline |
| `sold` | #81C784 (Green 300) | 2dp hairline |
| `listed` | #64B5F6 (Blue 300) | 6dp border |
| `stale` | #FFB74D (Orange 300) | 6dp border |

### Background & Neutrals
| Token | Hex | Usage |
|-------|-----|-------|
| `surface-light` | #FAFAF8 | Primary background (warm tint) |
| `surface-dark` | #1A1A2E | Dark mode surface |
| `neutral-grey` | #F5F5F5 | Card backgrounds |

### Rules
- **Never rely on color alone.** Always pair with icons (↑/↓) and text labels for accessibility.
- **Gold = Opportunity only.** Never use for passive status or warnings.
- **Muted vs Vibrant:** Status edges use muted tones; action buttons use vibrant tones.

---

## 2. Card Design

### Pallet Card
```
┌─────────────────────────────────────┐
│ [Icon] Pallet Name          [STATUS]│
│         Amazon • $250 cost          │
├─────────────────────────────────────┤
│  ████████░░░░  12/20 items sold     │
├─────────────────────────────────────┤
│                          +$127      │
│                          PROFIT ↑   │
└─────────────────────────────────────┘
```

**Rules:**
1. **Hero Metric:** Profit is the largest, most prominent element (bottom-right).
2. **Visual Progress Bar:** Replace text percentages with filled bar.
3. **Compact Metadata:** Supplier + Cost on one line, de-emphasized.
4. **Status Chip:** Top-right, clearly indicates next action.

### Item Card
```
┌──┬────────────────────────────────┐
│▌▌│ [100px Photo]  Item Name      │
│▌▌│               Storage: Bin A2 │
│▌▌│               $45 listed      │
│▌▌│               +$12 profit ↑   │
└──┴────────────────────────────────┘
 ↑ Status Edge (2dp or 6dp)
```

**Rules:**
1. **Status Edge (Left):**
   - Standard states (`in_stock`, `sold`): 2dp hairline, muted color
   - Action states (`listed`, `stale`): 6dp border, vibrant color
   - When filtered by status, reduce edge to 3dp (redundant signal)
2. **Photo Priority:** 100px square, always visible.
3. **Stale Indicator:** Clock icon badge (no animation).

---

## 3. Dashboard

### Layout Hierarchy
1. **Hero Summary Card (Top 40%):**
   - Total Profit This Month: **+$X,XXX**
   - Sparkline or trend arrow showing direction
   - NO text praise ("Way to go!"). Data is the compliment.

2. **Action Strip (Horizontal Scroll):**
   - "Stale Items (3)" — Orange badge
   - "Ready to List (7)" — Gold badge
   - "New Pallet Added" — Green badge

3. **Recent Activity (Bottom):**
   - Last 5 sales with profit per item
   - Tappable to navigate to item detail

### Rules
- **Data-first.** No motivational micro-copy.
- **Action-oriented badges.** Colors match the status edge system.
- **Answer:** "How am I doing today?"

---

## 4. View Modes

| Mode | Description | Default For |
|------|-------------|-------------|
| **Comfort Mode** | Visual cards with photos, 100px items, progress bars | First-time users |
| **Compact Mode** | Dense list tiles, minimal photos, maximum data density | Toggle in Settings |

**Rules:**
- Default to Comfort Mode for new users.
- Power users can toggle to Compact Mode via Settings.
- Persist user preference across sessions.

---

## 5. Empty States & Onboarding

### First-Time Empty State
```
┌─────────────────────────────────────┐
│   [Illustration: Cash/Profit]       │
│                                     │
│   Add Your First Pallet             │
│                                     │
│   Track what you paid, what you     │
│   sold, and watch your profit       │
│   grow automatically.               │
│                                     │
│   [ + Add Pallet ]                  │
│                                     │
│   Example: 'Amazon Returns - $250'  │  ← Tappable (auto-fills form)
└─────────────────────────────────────┘
```

### Returning User Empty State
```
┌─────────────────────────────────────┐
│   No items here.                    │
│   [ + Add Item ]                    │
└─────────────────────────────────────┘
```

**Rules:**
- First-run: Rich, educational, with example data.
- Returning: Minimal, functional.
- Illustrations focus on **results** (cash, profit), not inputs (pallets).

---

## 6. Celebrations & Feedback

### First Sale Celebration
- **Trigger:** User records their very first sale.
- **Effect:** Brief confetti animation (1-2 seconds).
- **Frequency:** Once. Ever. Never again.

### Ongoing Feedback
- Sparklines and trend arrows for visual reinforcement.
- Green upward arrows for profit.
- NO text praise. NO "Way to go champ!"

---

## 7. Accessibility

### Color Blindness
- **Rule:** Never rely on color alone.
- **Implementation:** Always pair color with icons (↑/↓) and text labels.

### Touch Targets
- **Minimum:** 48x48dp for all tappable elements.

### Screen Readers
- **Semantics:** Wrap custom widgets in `Semantics` widgets.
- **Example:** "Pallet: Amazon Returns, Profit: $250" as a coherent sentence.

### Contrast
- **Minimum:** 4.5:1 ratio for text on backgrounds.
- **Verify:** Money Green (#2E7D32) against white text.

---

## 8. Error States

### Network Errors
- **Copy:** "Connection hiccup — tap to retry"
- **Action:** Always include a Retry button.

### Offline Behavior
- Queue actions offline.
- Show "Pending sync" indicator.

### Loading States
- Shimmer skeletons matching actual card layouts.

---

## 9. Implementation Priority

| Priority | Item | Impact | Effort |
|----------|------|--------|--------|
| P0 | Hero Profit on PalletCard | High | Low |
| P0 | Strict Color Diet (Muted vs Vibrant) | High | Low |
| P1 | Dashboard hierarchy (Data-first) | High | Medium |
| P1 | Status Edge System (2dp vs 6dp) | Medium | Low |
| P2 | View Mode Toggle (Comfort/Compact) | High | Medium |
| P2 | Enhanced First-Run Empty States | Medium | Medium |
| P2 | Accessibility / Touch Targets | High | Medium |
| P3 | First-Sale Celebration (One-time) | Low | Low |
| P4 | Custom Illustrations | Low | High |

---

**Last Updated:** 2026-01-04  
**Status:** Approved for implementation.
