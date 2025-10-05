# Comprehensive UI/UX Redesign - Pallet Pro App

## Design Philosophy

**Target User**: Individual resellers purchasing liquidation pallets from third-party suppliers (Walmart, Amazon, Target returns/overstock)

**Core Workflow**: Pallet Purchase → Item Cataloging → Listing → Sale

**Design Principles**:
1. **Pallet-Centric**: Pallets are the primary unit of inventory
2. **Action-Oriented**: Quick actions for common tasks
3. **Visual Hierarchy**: Most important info first
4. **Progressive Disclosure**: Details revealed on demand
5. **Responsive**: Works on mobile, tablet, and web
6. **Consistent**: Same look & feel throughout

---

## Design System

### Color Palette
- **Status Colors**:
  - In Stock: Blue (#2196F3)
  - Listed: Orange (#FF9800)
  - Sold: Green (#4CAF50)
  - In Progress (Pallet): Amber (#FFB300)
  - Processed (Pallet): Light Green (#66BB6A)
  - Archived: Grey (#9E9E9E)

- **Condition Colors**:
  - New: Green
  - Open Box: Light Green
  - Used Good: Blue
  - Used Fair: Orange
  - Damaged: Red
  - For Parts: Grey

### Spacing System (8dp grid)
- XS: 4dp
- S: 8dp
- M: 16dp
- L: 24dp
- XL: 32dp
- XXL: 48dp

### Typography
- Headline: 24-28dp, Bold
- Title: 18-20dp, Bold
- Subtitle: 16-18dp, Medium
- Body: 14-16dp, Regular
- Caption: 12-14dp, Regular

### Components
- **Cards**: Elevated, rounded corners (12dp), padding 16dp
- **Buttons**: Primary (filled), Secondary (outlined)
- **Status Badges**: Colored background, border, rounded
- **Info Chips**: Icon + text, small, colored
- **Empty States**: Icon (80dp), title, message, action

---

## Screen Redesigns

### ✅ 1. Dashboard Screen (COMPLETED)
**Purpose**: Command center with overview and quick actions

**Layout**:
- Gradient app bar with "Pallet Pro" branding
- Welcome message with time-based greeting
- Quick Action cards (4 grid):
  - New Pallet
  - View Pallets
  - List Items
  - Analytics
- Stats Overview (6 grid):
  - Active Pallets
  - Processed Pallets
  - Items In Stock
  - Items Listed
  - Items Sold
  - Total Items
- Recent Pallets list (5 most recent)

**Features**:
- Responsive grid layout
- Click-through to relevant screens
- Real-time stats from providers
- Empty state for first-time users

---

### ✅ 2. Pallet List Screen (COMPLETED)
**Purpose**: View and manage all pallets

**Layout**:
- Floating search bar in app bar
- Filter chips (All, In Progress, Processed, Archived)
- Pallet cards in grid/list based on screen size
- FAB for "New Pallet"

**Card Design**:
- Icon with status color
- Status badge
- Pallet name (bold, 2 lines max)
- Supplier name (if available)
- Cost (bold, colored)
- Purchase date (relative: "2d ago", "1w ago")

**Features**:
- Pull-to-refresh
- Search by name/supplier
- Filter by status
- Responsive grid (mobile: 1 col, tablet: 3 col, desktop: 4 col)
- Empty state with "Add Pallet" CTA

---

### 3. Pallet Detail Screen (TO DO)
**Purpose**: View pallet details and manage items

**Layout**:
- Hero section (no image for pallets):
  - Large pallet icon with status color
  - Pallet name (headline)
  - Status badge
  - Cost display
- Quick stats bar:
  - Total Items
  - In Stock
  - Listed
  - Sold
- Items list/grid with status filtering
- Action buttons:
  - Add Item
  - Process Pallet (if in_progress)
  - Archive (if processed)

**Details Section (Expandable)**:
- Supplier
- Type
- Source
- Purchase Date
- Notes

**Features**:
- Swipeable stats
- Filter items by status
- Quick add item
- Process workflow with confirmation
- Cost allocation summary

---

### 4. Add/Edit Pallet Screen (TO DO)
**Purpose**: Create or edit pallet records

**Layout**: **Step-by-Step Wizard**

**Step 1: Basic Info**
- Pallet Name (auto-generated option: "Pallet - [Date]")
- Supplier (dropdown with recent + new)
- Source (dropdown: "Walmart", "Amazon", "Target", etc.)
- Type (dropdown with presets)

**Step 2: Purchase Details**
- Cost (prominent, large input)
- Purchase Date (date picker, default: today)
- Additional Expenses (optional expandable)

**Step 3: Notes (Optional)**
- Description field
- Photos (future feature)

**Step 4: Review & Create**
- Summary of all info
- Edit buttons for each section
- "Create Pallet" button

**Features**:
- Progress indicator
- Previous/Next navigation
- Skip optional steps
- Validation per step
- Unsaved changes warning

---

### 5. Item List Screen (Inventory) (TO DO)
**Purpose**: View all items across pallets

**Layout**:
- Similar to Pallet List but for items
- Filter by:
  - Status (All, In Stock, Listed, Sold)
  - Pallet
  - Condition
- Sort by:
  - Date Added
  - Price
  - Status

**Card Design**:
- Primary photo (if available)
- Item name
- Condition chip
- Status badge
- Price info (contextual based on status)
- Parent pallet badge

**Features**:
- Bulk actions (list multiple, archive)
- Quick status change
- Photo thumbnail view
- Responsive grid

---

### ✅ 6. Item Detail Screen (COMPLETED)
**Purpose**: View item details and manage lifecycle

**Layout**:
- Hero image with photo gallery
- Item name + condition/quantity chips
- Status card with action buttons
- Pricing card (contextual)
- Additional details (expandable)
- FAB for photo management

**Status Actions**:
- In Stock → List for Sale
- Listed → Mark Sold / Unlist
- Sold → Revert to Listed

---

### 7. Add/Edit Item Screen (TO DO)
**Purpose**: Add item to pallet

**Layout**: **Simplified Form with Sections**

**Photo Section**:
- Large photo upload area (3 max)
- Camera/Gallery buttons
- Photo preview grid

**Basic Info**:
- Item Name
- Description (optional, expandable)
- Condition (prominent radio buttons with icons)
- Quantity (stepper)

**Storage**:
- Storage Location (text with suggestions)

**Cost** (Auto-calculated or Manual):
- Purchase Price (calculated from pallet)
- Override option

**Features**:
- Photo-first workflow
- Condition presets with icons
- Auto-save draft
- Quick add another

---

### 8. Settings Screen (TO DO)
**Purpose**: App configuration and preferences

**Layout**: **Grouped Settings**

**Account Section**:
- User profile
- Email
- Change password

**Business Settings**:
- Default cost allocation method
- Stale item threshold
- Currency/locale

**Display Settings**:
- Theme (light/dark)
- Compact view
- Show internal prices

**Data Management**:
- Export data
- Import data
- Clear cache

**About**:
- App version
- Terms & Privacy
- Help & Support

---

## Shared Patterns

### Navigation
- **Bottom Navigation** (Mobile):
  - Dashboard (Home)
  - Pallets
  - Items
  - Settings
- **Side Rail** (Tablet/Web):
  - Same items + expanded labels
  - Profile at top

### Empty States
- Large icon (80dp)
- Headline text
- Descriptive message
- Primary action button

### Loading States
- Shimmer loaders for lists
- Circular progress for actions
- Skeleton screens for details

### Error States
- Error icon
- User-friendly message
- Retry button
- Help link

### Success Feedback
- SnackBar for actions
- Success icon with animation
- Confetti for major milestones (first sale)

---

## Responsive Breakpoints

- **Mobile**: < 600dp (1 column, bottom nav)
- **Tablet**: 600-1200dp (2-3 columns, side rail)
- **Desktop/Web**: > 1200dp (3-4 columns, max width container)

### Responsive Adaptations
1. **Grid Columns**: Auto-adjust based on screen width
2. **Navigation**: Bottom nav → Side rail
3. **Dialogs**: Full-screen → centered modal
4. **Forms**: Stacked → side-by-side
5. **Cards**: List view → grid view

---

## Accessibility

- **Touch Targets**: Minimum 48dp
- **Contrast**: WCAG AA compliant
- **Text Scaling**: Support up to 200%
- **Screen Readers**: Semantic labels
- **Keyboard Navigation**: Full support on web

---

## Performance

- **Images**: Lazy loading, cached, compressed
- **Lists**: Virtual scrolling for 100+ items
- **Data**: Optimistic updates, background sync
- **Animations**: 60fps, GPU-accelerated
- **Bundle Size**: Code splitting for web

---

## Implementation Priority

### Phase 1 (Completed) ✅
- [x] Design system components
- [x] Dashboard screen
- [x] Pallet list screen
- [x] Item detail screen

### Phase 2 (Current)
- [ ] Pallet detail screen
- [ ] Add/Edit pallet screen
- [ ] Item list screen
- [ ] Add/Edit item screen

### Phase 3 (Future)
- [ ] Settings screen
- [ ] Analytics screen
- [ ] Search/Filter improvements
- [ ] Bulk actions

---

## Testing Checklist

### Visual Testing
- [ ] All screens in light/dark mode
- [ ] Mobile, tablet, desktop viewports
- [ ] Empty states
- [ ] Error states
- [ ] Loading states

### Functional Testing
- [ ] Navigation flows
- [ ] Form validation
- [ ] Photo upload
- [ ] Status transitions
- [ ] Data refresh

### Performance Testing
- [ ] Load 100+ pallets
- [ ] Load 1000+ items
- [ ] Photo gallery performance
- [ ] Navigation speed

---

## Design Resources

- **Figma**: [Link to design files]
- **Icons**: Material Icons
- **Illustrations**: Custom/undraw.co
- **Fonts**: System fonts (San Francisco, Roboto)
- **Color Tool**: Material Design Color Tool

---

## Notes for Developers

1. Use the design system (`lib/src/global/widgets/design_system.dart`)
2. Follow the responsive patterns
3. Test on multiple screen sizes
4. Optimize images before upload
5. Use semantic HTML on web
6. Follow accessibility guidelines
7. Add loading/error states
8. Implement pull-to-refresh
9. Add empty states
10. Use consistent spacing

