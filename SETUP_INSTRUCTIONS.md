# Hakiki App Setup Instructions

## 🚀 Quick Start Guide

### 1. GitHub Repository Setup
Your code is ready to be pushed to GitHub. Follow these steps:

1. Go to [GitHub.com](https://github.com) and create a new repository
2. Repository name: `hakiki_app`
3. Keep it public or private (your choice)
4. **DO NOT** initialize with README, .gitignore, or license
5. Copy the repository URL
6. Run these commands in your terminal:

```bash
git remote add origin https://github.com/YOUR_USERNAME/hakiki_app.git
git branch -M main
git push -u origin main
```

### 2. Firebase Console Setup

#### Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Project name: `hakiki-fraud-prevention`
4. Enable Google Analytics (recommended)

#### Step 2: Add Flutter Apps
**Android App:**
- Package name: `com.example.hakiki_app`
- Download `google-services.json` → place in `android/app/`

**iOS App:**
- Bundle ID: `com.example.hakikiApp`
- Download `GoogleService-Info.plist` → place in `ios/Runner/`

**Web App:**
- Copy the config and update `lib/firebase_options.dart`

#### Step 3: Enable Authentication
1. Go to Authentication → Sign-in method
2. Enable:
   - ✅ Email/Password
   - ✅ Phone (requires SMS setup)
   - ✅ Google (download OAuth config)

#### Step 4: Create Firestore Database
1. Go to Firestore Database → Create database
2. Start in **test mode**
3. Choose location closest to your users

#### Step 5: Set up Storage
1. Go to Storage → Get started
2. Start in **test mode**
3. Same location as Firestore

### 3. Deploy Firebase Rules

Install Firebase CLI and deploy the security rules:

```bash
npm install -g firebase-tools
firebase login
firebase init
# Select: Firestore, Storage
# Choose existing project: hakiki-fraud-prevention
# Use existing files (firestore.rules, storage.rules)
firebase deploy --only firestore:rules,storage
```

### 4. Update Firebase Configuration

After creating your Firebase project, update `lib/firebase_options.dart` with your actual Firebase configuration values.

### 5. Test the Setup

Run your app to test Firebase integration:

```bash
flutter clean
flutter pub get
flutter run
```

## 📱 App Features Ready

Your Hakiki app now includes:

### ✅ Authentication System
- Email/Password sign-in
- Google Sign-in
- Phone number verification
- User role management (user/vendor/admin)

### ✅ Database Structure
- **Users**: Profile, trust scores, roles
- **Vendors**: Business registration, document verification
- **Products**: QR/barcode scanning, verification status
- **Reports**: Fraud reporting with evidence upload
- **Notifications**: Real-time fraud alerts

### ✅ Security Rules
- Role-based access control
- Data validation
- Secure file uploads

### ✅ Services Ready
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Cloud Messaging
- Analytics tracking

## 🔧 Development Workflow

### Making Changes
1. Make your code changes
2. Test locally: `flutter run`
3. Commit changes: `git add . && git commit -m "Your message"`
4. Push to GitHub: `git push`

### Deploying Firebase Rules
When you update `firestore.rules` or `storage.rules`:
```bash
firebase deploy --only firestore:rules,storage
```

### Adding New Features
1. Create feature branch: `git checkout -b feature/new-feature`
2. Implement feature
3. Test thoroughly
4. Commit and push: `git push origin feature/new-feature`
5. Create Pull Request on GitHub

## 🛡️ Security Considerations

### Production Checklist
- [ ] Update Firebase rules from test mode to production
- [ ] Set up proper API key restrictions
- [ ] Configure authorized domains
- [ ] Set up monitoring and alerts
- [ ] Enable App Check for additional security
- [ ] Configure backup strategies

### Environment Variables
For sensitive data, use environment variables or Firebase Remote Config:
- API keys
- Third-party service credentials
- Feature flags

## 📊 Monitoring & Analytics

Your app includes:
- Firebase Analytics for user behavior
- Crashlytics for error tracking
- Performance monitoring
- Custom events for fraud detection

## 🚨 Next Steps

1. **Complete Firebase Console setup** following the guide above
2. **Create GitHub repository** and push your code
3. **Test authentication flows** with real Firebase project
4. **Deploy security rules** using Firebase CLI
5. **Start building your UI components** for the fraud prevention features

## 📞 Support

If you encounter issues:
1. Check Firebase Console for errors
2. Review Flutter logs: `flutter logs`
3. Verify Firebase configuration files
4. Ensure all dependencies are installed: `flutter pub get`

Your Hakiki fraud prevention app is now ready for development! 🎉
