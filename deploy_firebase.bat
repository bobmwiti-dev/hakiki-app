@echo off
echo ========================================
echo Firebase Deployment Script for Hakiki App
echo ========================================

echo.
echo Step 1: Building Flutter web app...
call flutter build web --release

if %ERRORLEVEL% neq 0 (
    echo ERROR: Flutter build failed!
    pause
    exit /b 1
)

echo.
echo Step 2: Deploying Firestore security rules...
call firebase deploy --only firestore:rules

if %ERRORLEVEL% neq 0 (
    echo ERROR: Firestore rules deployment failed!
    pause
    exit /b 1
)

echo.
echo Step 3: Deploying Firebase Storage rules...
call firebase deploy --only storage

if %ERRORLEVEL% neq 0 (
    echo ERROR: Storage rules deployment failed!
    pause
    exit /b 1
)

echo.
echo Step 4: Deploying web app to Firebase Hosting...
call firebase deploy --only hosting

if %ERRORLEVEL% neq 0 (
    echo ERROR: Hosting deployment failed!
    pause
    exit /b 1
)

echo.
echo ========================================
echo ✅ Deployment completed successfully!
echo ========================================
echo.
echo Your Hakiki app is now live at:
call firebase hosting:channel:list
echo.
pause
