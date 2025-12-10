@echo off
REM iTasks - Setup Script for Windows
REM This script sets up the development environment

echo.
echo ================================
echo iTasks - Setup Script
echo ================================
echo.

REM Check if Flutter is installed
where flutter >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Flutter is not installed!
    echo [INFO] Install Flutter: https://flutter.dev/docs/get-started/install
    exit /b 1
)

echo [OK] Flutter found
flutter --version
echo.

REM Check if Firebase CLI is installed
where firebase >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [WARNING] Firebase CLI not found
    echo [INFO] Install with: npm install -g firebase-tools
    echo.
)

REM Install Flutter dependencies
echo [INFO] Installing Flutter dependencies...
call flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to install dependencies
    exit /b 1
)
echo [OK] Dependencies installed
echo.

REM Check for Firebase configuration
echo [INFO] Checking Firebase configuration...
echo.

if not exist "lib\firebase_options.dart" (
    echo [WARNING] firebase_options.dart not found
    echo.
    echo Choose an option:
    echo 1^) Use FlutterFire CLI ^(Recommended^)
    echo 2^) Configure manually
    set /p option="Option (1 or 2): "
    
    if "!option!"=="1" (
        echo.
        echo [INFO] Configuring with FlutterFire CLI...
        
        where flutterfire >nul 2>&1
        if %ERRORLEVEL% NEQ 0 (
            echo [INFO] Installing FlutterFire CLI...
            call dart pub global activate flutterfire_cli
        )
        
        echo [INFO] Run now: flutterfire configure
        echo        Follow the instructions to connect to your Firebase project
        
    ) else if "!option!"=="2" (
        echo.
        echo [INFO] Manual configuration:
        echo 1. Copy: copy lib\firebase_options.example.dart lib\firebase_options.dart
        echo 2. Edit lib\firebase_options.dart with your Firebase credentials
        echo 3. Download google-services.json from Firebase Console
        echo 4. Copy to: android\app\google-services.json
        echo 5. For iOS, download GoogleService-Info.plist
        echo 6. Copy to: ios\Runner\GoogleService-Info.plist
    )
) else (
    echo [OK] firebase_options.dart found
)
echo.

REM Check for google-services.json
if not exist "android\app\google-services.json" (
    echo [WARNING] android\app\google-services.json not found
    echo           Download from Firebase Console for Android support
) else (
    echo [OK] google-services.json found
)
echo.

REM Check for .firebaserc
if not exist ".firebaserc" (
    echo [WARNING] .firebaserc not found
    if exist ".firebaserc.example" (
        echo [INFO] Creating .firebaserc...
        copy .firebaserc.example .firebaserc >nul
        echo        Edit .firebaserc with your Firebase Project ID
    )
) else (
    echo [OK] .firebaserc found
)
echo.

REM Run Flutter doctor
echo [INFO] Checking Flutter environment...
call flutter doctor
echo.

echo ================================
echo Setup completed!
echo ================================
echo.
echo Next steps:
echo 1. Complete Firebase configuration ^(if needed^)
echo 2. Run: flutter run
echo 3. Choose your desired device/emulator
echo.
echo Documentation: README.md
echo Security: SECURITY.md
echo.
echo Happy coding! :^)
echo.

pause
