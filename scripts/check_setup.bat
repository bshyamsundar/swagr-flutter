@echo off
setlocal EnableDelayedExpansion

echo.
echo ============================================
echo   Financial Sentiment App - Setup Check
echo ============================================
echo.

where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Flutter is NOT installed or not on your PATH.
    echo.
    echo Please install Flutter first:
    echo   https://docs.flutter.dev/get-started/install/windows
    echo.
    echo After installing, add Flutter's bin folder to your PATH,
    echo then close and reopen this window.
    echo.
    pause
    exit /b 1
)

echo [OK] Flutter found:
flutter --version
echo.

echo Running Flutter health check...
echo (Yellow warnings are often fine. Red errors need attention.)
echo.
flutter doctor
echo.

echo Checking for a device to run the app...
flutter devices
echo.

echo ============================================
echo   Setup check complete
echo ============================================
echo.
echo If Flutter is installed and Chrome appears above,
echo you can run the app by double-clicking:
echo   scripts\run_app.bat
echo.
pause
