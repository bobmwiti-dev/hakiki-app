# Firebase Setup Guide for Hakiki App

## Prerequisites
✅ Firebase CLI installed and authenticated
✅ FlutterFire CLI installed
✅ Firebase project created in Firebase Console

## Step-by-Step Firebase Configuration

### 1. Firebase Console Setup

#### A. Enable Authentication
1. Go to Firebase Console → Authentication → Sign-in method
2. Enable the following sign-in providers:
   - **Email/Password** (for basic auth)
   - **Google** (for social login)
   - **Phone** (for phone number verification)

#### B. Create Firestore Database
1. Go to Firebase Console → Firestore Database
2. Click "Create database"
3. Choose "Start in test mode" (we'll configure security rules later)
4. Select your preferred location (closest to your users)

#### C. Set up Firebase Storage
1. Go to Firebase Console → Storage
2. Click "Get started"
3. Choose "Start in test mode"
4. Select the same location as your Firestore database

#### D. Enable Firebase Analytics
1. Go to Firebase Console → Analytics
2. Enable Google Analytics for your project

#### E. Set up Cloud Messaging
1. Go to Firebase Console → Cloud Messaging
2. No additional setup needed - it's enabled by default

### 2. Get Firebase Configuration

#### A. Web Configuration
1. Go to Firebase Console → Project Settings → General tab
2. Scroll down to "Your apps" section
3. Click on the Web app (</>) icon or select existing web app
4. Copy the configuration values:
   ```javascript
   const firebaseConfig = {
     apiKey: "your-api-key",
     authDomain: "your-project.firebaseapp.com",
     projectId: "your-project-id",
     storageBucket: "your-project.appspot.com",
     messagingSenderId: "123456789",
     appId: "your-app-id",
     measurementId: "G-XXXXXXXXXX"
   };
   ```

#### B. Android Configuration
1. In Firebase Console → Project Settings → General tab
2. Click "Add app" → Android
3. Enter package name: `com.hakiki.app`
4. Download `google-services.json`
5. Place it in `android/app/` directory

#### C. iOS Configuration
1. In Firebase Console → Project Settings → General tab
2. Click "Add app" → iOS
3. Enter bundle ID: `com.hakiki.app`
4. Download `GoogleService-Info.plist`
5. Place it in `ios/Runner/` directory

### 3. Update Firebase Options

Replace the placeholder values in `lib/firebase_options.dart` with your actual configuration:

```dart
// Replace YOUR_PROJECT_ID with your actual project ID
// Replace YOUR_API_KEY with your actual API keys
// Replace YOUR_APP_ID with your actual app IDs
```

### 4. Configure Platform-Specific Files

#### A. Android Configuration
1. Update `android/app/build.gradle`:
   ```gradle
   android {
       compileSdkVersion 34
       defaultConfig {
           minSdkVersion 21  // Required for Firebase
           targetSdkVersion 34
           multiDexEnabled true  // Required for Firebase
       }
   }
   
   dependencies {
       implementation 'com.google.firebase:firebase-analytics'
       implementation 'androidx.multidex:multidex:2.0.1'
   }
   ```

2. Update `android/build.gradle`:
   ```gradle
   dependencies {
       classpath 'com.google.gms:google-services:4.4.0'
   }
   ```

3. Add to `android/app/build.gradle` (bottom):
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

#### B. iOS Configuration
1. Update `ios/Runner/Info.plist`:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleURLName</key>
           <string>REVERSED_CLIENT_ID</string>
           <key>CFBundleURLSchemes</key>
           <array>
               <string>YOUR_REVERSED_CLIENT_ID</string>
           </array>
       </dict>
   </array>
   ```

#### C. Web Configuration
1. Update `web/index.html`:
   ```html
   <script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js"></script>
   <script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore-compat.js"></script>
   <script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-auth-compat.js"></script>
   <script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-storage-compat.js"></script>
   ```

### 5. Firestore Security Rules

Update Firestore security rules in Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Products are readable by all, writable by vendors
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null && 
        (resource == null || resource.data.vendorId == request.auth.uid);
    }
    
    // Vendors are readable by all, writable by owner
    match /vendors/{vendorId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == vendorId;
    }
    
    // Fraud reports are readable by admins, writable by authenticated users
    match /fraud_reports/{reportId} {
      allow read: if request.auth != null && 
        (request.auth.uid == resource.data.reporterId || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Admin-only collections
    match /admin/{document=**} {
      allow read, write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

### 6. Firebase Storage Rules

Update Storage security rules:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // User profile images
    match /users/{userId}/profile/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Product images
    match /products/{productId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Vendor documents
    match /vendors/{vendorId}/documents/{allPaths=**} {
      allow read: if request.auth != null && 
        (request.auth.uid == vendorId || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
      allow write: if request.auth != null && request.auth.uid == vendorId;
    }
    
    // Fraud report evidence
    match /fraud_reports/{reportId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

### 7. Test Firebase Connection

Run the following commands to test your setup:

```bash
# Get dependencies
flutter pub get

# Run build runner for JSON serialization
dart run build_runner build

# Test on web
flutter run -d chrome

# Test on Android (if emulator is running)
flutter run -d android

# Test on iOS (if simulator is running)
flutter run -d ios
```

### 8. Environment Variables (Optional)

For better security, consider using environment variables:

1. Create `.env` file in project root:
   ```
   FIREBASE_PROJECT_ID=your-project-id
   FIREBASE_API_KEY=your-api-key
   FIREBASE_APP_ID=your-app-id
   ```

2. Add to `.gitignore`:
   ```
   .env
   ```

3. Use flutter_dotenv package to load environment variables

## Troubleshooting

### Common Issues:

1. **"Firebase not initialized"**
   - Ensure Firebase.initializeApp() is called before runApp()
   - Check firebase_options.dart has correct configuration

2. **"Permission denied" in Firestore**
   - Update Firestore security rules
   - Ensure user is authenticated

3. **Web compilation errors**
   - Check dependency_overrides in pubspec.yaml
   - Ensure Firebase web scripts are loaded in index.html

4. **Android build errors**
   - Check minSdkVersion is 21 or higher
   - Ensure google-services.json is in android/app/
   - Add multidex support

5. **iOS build errors**
   - Ensure GoogleService-Info.plist is in ios/Runner/
   - Update Info.plist with URL schemes
   - Check bundle ID matches Firebase configuration

## Next Steps

After completing this setup:

1. ✅ Test authentication flow
2. ✅ Test Firestore read/write operations
3. ✅ Test file upload to Firebase Storage
4. ✅ Test push notifications
5. ✅ Deploy to production with proper security rules

## Support

If you encounter issues:
1. Check Firebase Console logs
2. Check Flutter console for error messages
3. Verify all configuration files are properly placed
4. Ensure all dependencies are up to date
