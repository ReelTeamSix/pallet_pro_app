# Pallet Pro - Quick Checklist to MVP

**Current Status**: Phase 6 (Analytics) - 65% Complete  
**Target**: Production-Ready MVP  
**Estimated Time**: 4-6 weeks

---

## 🔥 **CRITICAL - Fix Now**

- [ ] **Fix router error**: "unknown route name: /reports"
  - File: `dashboard_screen.dart` line 628
  - Route not properly configured
  
- [ ] **Fix query builder error**: PostgrestTransformBuilder type issue
  - File: `supabase_item_repository.dart` line 569
  - Prevents analytics from loading

---

## 📊 **Phase 6: Complete Analytics (Current Sprint)**

### Repository & Data Layer
- [x] Analytics data models created
- [x] 6 analytics methods implemented in repository
- [ ] Create secure SQL functions for:
  - [ ] Profit calculations (with expenses)
  - [ ] Profit by tag/type
  - [ ] Stale item queries
  - [ ] Price suggestion logic
- [ ] Optimize queries for free tier

### UI Layer
- [x] Reports screen with time period selector
- [x] Financial metrics cards
- [x] Top performers section
- [x] Fun facts section
- [ ] **Add profit charts** (by source/type) using `fl_chart`
- [ ] **Add sales channel performance charts**
- [ ] **Add status-based inventory charts**
- [ ] **Add time series revenue/profit charts**

### Features
- [ ] **Goal Tracking**:
  - [ ] Create `GoalNotifier`
  - [ ] Goal setting UI (Daily/Weekly/Monthly/Yearly)
  - [ ] Progress calculation logic
  - [ ] Progress visualization
- [ ] **Expense Tracking**:
  - [ ] Create `ExpenseNotifier`
  - [ ] Add expense UI
  - [ ] Expense list view
  - [ ] Expense analytics integration
- [ ] **CSV Export**:
  - [ ] Customizable data selection
  - [ ] Date range filtering
  - [ ] Export button in Reports screen

### Testing
- [ ] Test all analytics with real data
- [ ] Test time period switching
- [ ] Test chart rendering
- [ ] Test CSV export
- [ ] Test goal tracking
- [ ] Test expense tracking

---

## ⚙️ **Phase 7: Complete Settings & Polish**

### Settings Screen
- [x] Theme preference (Light/Dark)
- [x] Biometric unlock toggle
- [ ] **Goal Settings**:
  - [ ] Daily goal input
  - [ ] Weekly goal input
  - [ ] Monthly goal input
  - [ ] Yearly goal input
- [ ] **Stale Threshold Settings**:
  - [ ] Days input
  - [ ] Visual indicator preview
- [ ] **Cost Allocation Settings**:
  - [ ] Equal/Weighted/Manual options
  - [ ] Explanation text

### UI/UX Final Polish
- [x] Theme consistency review
- [x] EmptyState widgets
- [x] ShimmerLoader usage
- [x] Subtle animations
- [ ] **Caching**:
  - [ ] Cache tags locally
  - [ ] Cache pallet types
  - [ ] Cache user settings
- [ ] **Sync Indicator**:
  - [ ] Global data sync status
  - [ ] Connection status indicator

### Accessibility
- [ ] Contrast ratio check (WCAG AA)
- [ ] Touch target sizes (min 48x48dp)
- [ ] Semantic labels
- [ ] Screen reader testing
- [ ] Keyboard navigation (web)

### Cross-Platform Testing
- [ ] Test all flows on Android
- [ ] Test all flows on iOS
- [ ] Test all flows on Web (Chrome, Firefox, Safari)
- [ ] Test responsive breakpoints
- [ ] Test Light/Dark modes

---

## 🧪 **Phase 8: Comprehensive Testing**

### Unit Tests
- [x] AuthController tests
- [x] Some repository tests
- [ ] **All Repository Tests**:
  - [ ] UserSettingsRepository
  - [ ] PalletRepository
  - [ ] ItemRepository (all methods)
  - [ ] StorageRepository
  - [ ] TagRepository
  - [ ] ExpenseRepository
  - [ ] ItemPhotoRepository
- [ ] **All Notifier Tests**:
  - [ ] PalletListNotifier
  - [ ] PalletDetailNotifier
  - [ ] ItemListNotifier
  - [ ] ItemDetailNotifier
  - [ ] UserSettingsNotifier
  - [ ] AnalyticsNotifier (future)
  - [ ] GoalNotifier
  - [ ] ExpenseNotifier
- [ ] **Service Tests**:
  - [ ] ItemStatusManager
  - [ ] PalletStatusManager
  - [ ] PhotoManagementService

### Widget Tests
- [x] Some reusable widgets
- [ ] **All Reusable Widgets**:
  - [ ] StatusBadge
  - [ ] InfoChip
  - [ ] EmptyState
  - [ ] SectionHeader
  - [ ] PriceDisplay
  - [ ] StatCard
  - [ ] PalletCard
  - [ ] InventoryItemCard
  - [ ] ImagePickerGrid
  - [ ] StatusChip
  - [ ] SalesChannelDropdown
- [ ] **Screen Components**:
  - [ ] Login/Signup forms
  - [ ] Pallet list/detail
  - [ ] Item list/detail
  - [ ] Dashboard cards
  - [ ] Reports screen sections
  - [ ] Settings forms

### Integration Tests
- [ ] **Auth Flow**:
  - [ ] Sign up
  - [ ] Login
  - [ ] Logout
  - [ ] Biometric unlock (mock)
  - [ ] Session persistence
- [ ] **Pallet Workflow**:
  - [ ] Create pallet
  - [ ] Add items to pallet
  - [ ] Change pallet status (in_progress → processed)
  - [ ] Verify cost allocation
- [ ] **Item Workflow**:
  - [ ] Add item
  - [ ] Upload photos
  - [ ] Change status (in_stock → listed → sold)
  - [ ] Verify profit calculation
- [ ] **Settings**:
  - [ ] Change theme
  - [ ] Toggle biometric
  - [ ] Update goals
  - [ ] Verify persistence
- [ ] **Analytics**:
  - [ ] Load dashboard
  - [ ] Switch time periods
  - [ ] View charts
  - [ ] Export CSV

### Test Coverage
- [ ] Run `flutter test --coverage`
- [ ] Achieve 70%+ overall coverage
- [ ] 80%+ for critical business logic

---

## 🔒 **Phase 9: Security & Final Checks**

### Security Audit
- [ ] **RLS Policies**:
  - [ ] Verify all tables have RLS enabled
  - [ ] Test user can only access their own data
  - [ ] Test unauthenticated access is blocked
- [ ] **Storage Policies**:
  - [ ] Verify photo bucket is private
  - [ ] Test user can only access their photos
  - [ ] Test signed URLs expire correctly
- [ ] **Input Validation**:
  - [ ] Review all form inputs
  - [ ] Verify server-side validation
  - [ ] Test SQL injection prevention
  - [ ] Test XSS prevention
- [ ] **Secure Keys**:
  - [ ] Verify `--dart-define` usage
  - [ ] No hardcoded credentials
  - [ ] Supabase keys not in git
- [ ] **Dependencies**:
  - [ ] Run `flutter pub outdated`
  - [ ] Update to latest stable
  - [ ] Check for security advisories
- [ ] **Auth Sessions**:
  - [ ] Verify JWT expiry
  - [ ] Verify refresh token rotation
  - [ ] Test session timeout

### Monitoring Setup
- [ ] Set up Supabase dashboard monitoring
- [ ] Configure Audit logs
- [ ] Set up error tracking (Sentry/Firebase Crashlytics)
- [ ] Set up analytics (Firebase Analytics/Mixpanel)
- [ ] Set up usage alerts (free tier limits)

### Code Quality
- [ ] Run `flutter analyze` (zero issues)
- [ ] Remove dead code
- [ ] Refactor complex methods
- [ ] Add documentation comments
- [ ] Format code (`dart format .`)
- [ ] Optimize imports

### Edge Case Testing
- [ ] **Offline Behavior**:
  - [ ] Test app without internet
  - [ ] Test graceful error messages
  - [ ] Test sync when back online
- [ ] **Invalid Data**:
  - [ ] Test with corrupted data
  - [ ] Test with missing required fields
  - [ ] Test with extreme values
- [ ] **Permissions**:
  - [ ] Test camera permission denied
  - [ ] Test photo library permission denied
  - [ ] Test biometric permission denied
- [ ] **Network Errors**:
  - [ ] Test timeout handling
  - [ ] Test 4xx errors
  - [ ] Test 5xx errors

---

## 🚀 **Phase 10: Deployment**

### Platform Configuration
- [ ] **Android**:
  - [ ] Set version number
  - [ ] Configure signing keys
  - [ ] Set permissions in manifest
  - [ ] Verify icons
  - [ ] Configure splash screen
  - [ ] Build release `.aab`
- [ ] **iOS**:
  - [ ] Set version number
  - [ ] Configure signing certificates
  - [ ] Set permissions in Info.plist
  - [ ] Verify icons
  - [ ] Configure splash screen
  - [ ] Build release `.ipa`
- [ ] **Web**:
  - [ ] Set version number
  - [ ] Choose renderer (html/canvaskit)
  - [ ] Configure hosting
  - [ ] Set meta tags
  - [ ] Build release web

### CI/CD Pipeline
- [ ] **Setup GitHub Actions / Codemagic**:
  - [ ] Flutter version matrix
  - [ ] Run `flutter analyze`
  - [ ] Run `flutter test`
  - [ ] Build for all platforms
  - [ ] Use `--dart-define` for secrets
  - [ ] Upload artifacts
- [ ] **Deployment**:
  - [ ] Deploy to Google Play Internal Testing
  - [ ] Deploy to TestFlight
  - [ ] Deploy to Firebase Hosting / Netlify
  - [ ] Set up beta tester groups

### Internal Testing
- [ ] Deploy to internal tracks
- [ ] Create test accounts
- [ ] Perform smoke tests:
  - [ ] Sign up new user
  - [ ] Create pallet
  - [ ] Add items
  - [ ] Upload photos
  - [ ] Mark items as sold
  - [ ] View analytics
  - [ ] Change settings
  - [ ] Verify data syncs

### Beta Testing
- [ ] Recruit 5-10 beta testers
- [ ] Collect feedback
- [ ] Fix critical issues
- [ ] Iterate on UX improvements

---

## ✅ **Definition of Done - MVP Ready**

### Functionality
- [x] ✅ User registration/login
- [x] ✅ Pallet CRUD
- [x] ✅ Item CRUD
- [x] ✅ Photo management (3 per item)
- [x] ✅ Cost tracking
- [x] ✅ Sales tracking
- [x] ✅ Basic analytics
- [ ] ⏳ Goal tracking
- [ ] ⏳ Expense tracking
- [ ] ⏳ Detailed charts
- [x] ✅ Settings management
- [x] ✅ Multi-platform support

### Quality
- [x] ✅ Zero linter errors
- [ ] ⏳ 70%+ test coverage
- [ ] ⏳ All tests passing
- [ ] ⏳ Security audit complete
- [ ] ⏳ Accessibility audit complete
- [ ] ⏳ Performance acceptable
- [ ] ⏳ Zero critical bugs
- [ ] ⏳ Cross-platform tested

### Deployment
- [ ] ⏳ CI/CD configured
- [ ] ⏳ Release builds successful
- [ ] ⏳ Internal testing complete
- [ ] ⏳ Beta testing complete
- [ ] ⏳ Documentation complete

---

## 📅 **Timeline Estimate**

### Week 1: Analytics Completion
- Days 1-2: Fix critical bugs
- Days 3-5: Complete analytics features

### Week 2: Charts & Goals
- Days 6-7: Implement charts
- Days 8-10: Goal tracking & expenses

### Week 3: Settings & Accessibility
- Days 11-13: Complete settings
- Days 14-15: Accessibility audit

### Week 4: Testing Sprint
- Days 16-20: Write all tests

### Week 5: Security & Polish
- Days 21-23: Security audit
- Days 24-25: Final polish

### Week 6: Deployment
- Days 26-28: Configure CI/CD
- Days 29-30: Internal/Beta testing

**Target MVP Date**: Mid-November 2025

---

## 🎯 **Today's Priority**

1. ✅ ~~Fix router configuration~~ (if not done)
2. ✅ ~~Fix query builder error~~ (if not done)
3. ⏳ Implement SQL functions
4. ⏳ Add charts to Reports screen
5. ⏳ Test analytics with real data

---

**Last Updated**: October 5, 2025  
**Progress**: 65% Complete

