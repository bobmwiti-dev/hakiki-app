@echo off
echo ========================================
echo Firebase Configuration Validation
echo ========================================

echo.
echo Checking Firebase CLI installation...
firebase --version
if %ERRORLEVEL% neq 0 (
    echo ERROR: Firebase CLI not installed or not in PATH
    echo Please install with: npm install -g firebase-tools
    pause
    exit /b 1
)

echo.
echo Checking Firebase login status...
firebase projects:list
if %ERRORLEVEL% neq 0 (
    echo ERROR: Not logged in to Firebase
    echo Please run: firebase login
    pause
    exit /b 1
)

echo.
echo Checking Flutter installation...
flutter --version
if %ERRORLEVEL% neq 0 (
    echo ERROR: Flutter not installed or not in PATH
    pause
    exit /b 1
)

echo.
echo Checking FlutterFire CLI installation...
flutterfire --version
if %ERRORLEVEL% neq 0 (
    echo ERROR: FlutterFire CLI not installed
    echo Please install with: dart pub global activate flutterfire_cli
    pause
    exit /b 1
)

echo.
echo Validating Firebase configuration files...

if not exist "lib\firebase_options.dart" (
    echo ERROR: firebase_options.dart not found
    echo Please run: flutterfire configure
    pause
    exit /b 1
)

if not exist "firebase.json" (
    echo ERROR: firebase.json not found
    echo Please run: firebase init
    pause
    exit /b 1
)

if not exist "firestore.rules" (
    echo WARNING: firestore.rules not found
    echo Firestore security rules should be configured
)

if not exist "storage.rules" (
    echo WARNING: storage.rules not found
    echo Storage security rules should be configured
)

echo.
echo Checking pubspec.yaml for Firebase dependencies...
findstr /C:"firebase_core" pubspec.yaml >nul
if %ERRORLEVEL% neq 0 (
    echo ERROR: firebase_core dependency not found in pubspec.yaml
    pause
    exit /b 1
)

findstr /C:"firebase_auth" pubspec.yaml >nul
if %ERRORLEVEL% neq 0 (
    echo ERROR: firebase_auth dependency not found in pubspec.yaml
    pause
    exit /b 1
)

findstr /C:"cloud_firestore" pubspec.yaml >nul
if %ERRORLEVEL% neq 0 (
    echo ERROR: cloud_firestore dependency not found in pubspec.yaml
    pause
    exit /b 1
)

echo.
echo ========================================
echo ✅ Firebase configuration validation passed!
echo ========================================
echo.
echo Next steps:
echo 1. Update firebase_options.dart with your actual project configuration
echo 2. Run: flutter pub get
echo 3. Run: dart run build_runner build
echo 4. Test with: flutter run -d chrome
echo.
pause
