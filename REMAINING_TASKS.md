# Hakiki App - Remaining Tasks

## 🔴 Critical (Must Complete)

### 1. **Route Integration Issue**
- **Problem**: `lib/app.dart` is using the old route generator from `presentation/shared/routes/`
- **Fix Needed**: Update `app.dart` to use `lib/core/routes/route_generator.dart`
- **Impact**: Navigation won't work properly

### 2. **Authentication Screens Integration**
- **Status**: Login/Signup screens exist in `lib/presentation/features/auth/views/` but not integrated
- **Missing**: 
  - Login screen route in new route generator
  - Signup screen route in new route generator
  - Phone auth screen route
- **Action**: Add auth routes to `lib/core/routes/route_generator.dart`

### 3. **Splash Screen Auth Check**
- **Current**: Always navigates to onboarding
- **Needed**: Check if user is authenticated and navigate accordingly
- **File**: `lib/views/splash/splash_screen.dart`

## 🟡 Important (Should Complete)

### 4. **Minor Screen Enhancements**
- **Home Dashboard**: Add recent activity list (currently placeholder)
- **QR Scanner**: Add manual entry dialog
- **Admin Dashboard**: User management screen

### 5. **Repository Method Implementations**
Some FirestoreService methods are not fully implemented (but have fallbacks):
- `getProductByBarcode()` - Has TODO
- `getVendorsByStatus()` - Has TODO
- `searchVendors()` - Has TODO
- `getUsersByRole()` - Has TODO

These are **non-critical** as the app works with existing methods.

## 🟢 Nice to Have (Enhancements)

### 6. **Additional Features**
- Profile screen implementation
- Settings screen
- Report history screen
- Vendor dashboard screen
- Product listing screen

### 7. **Testing**
- Unit tests for ViewModels
- Widget tests for screens
- Integration tests for flows

### 8. **Documentation**
- API documentation
- Deployment guide
- User guide

## 📋 Summary

**Critical**: 3 items (Route integration, Auth screens, Splash auth check)
**Important**: 2 items (Screen enhancements, Repository methods)
**Nice to Have**: 3 items (Additional features, Testing, Documentation)

**Total Remaining**: 8 items
**Blocking Issues**: 3 (all fixable quickly)

