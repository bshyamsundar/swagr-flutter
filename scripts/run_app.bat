@echo off
setlocal

cd /d "%~dp0\.."

echo.
echo ============================================
echo   Financial Sentiment App - Starting...
echo ============================================
echo.

where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Flutter is not installed.
    echo Run scripts\check_setup.bat first, or see README.md
    echo.
    pause
    exit /b 1
)

echo Installing app dependencies...
call flutter pub get
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install dependencies.
    pause
    exit /b 1
)

echo.
echo Launching app in Chrome...
echo (First launch may take several minutes.)
echo Press Q in this window to quit the app when done.
echo.

call flutter run -d chrome
if %errorlevel% neq 0 (
    echo.
    echo Chrome not available. Trying Windows desktop instead...
    call flutter run -d windows
)

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Could not start the app.
    echo Run scripts\check_setup.bat and see README.md - Troubleshooting
    pause
    exit /b 1
)

pause
