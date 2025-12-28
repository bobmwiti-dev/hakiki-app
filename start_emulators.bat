@echo off
echo ========================================
echo Firebase Emulators Setup for Hakiki App
echo ========================================

echo.
echo Starting Firebase emulators for local development...
echo.
echo Services that will be started:
echo - Authentication (port 9099)
echo - Firestore (port 8080)
echo - Storage (port 9199)
echo - Firebase UI (port 4000)
echo.

echo Starting emulators...
call firebase emulators:start

echo.
echo ========================================
echo Firebase emulators stopped
echo ========================================
pause
