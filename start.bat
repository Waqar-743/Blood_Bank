@echo off
title Nutech Blood Bank Server
color 0C

echo.
echo  ==========================================
echo   NUTECH BLOOD BANK MANAGEMENT SYSTEM
echo   CS160 Database Systems PBL
echo  ==========================================
echo.

cd /d "%~dp0"

echo  [1/4] Checking Node.js...
node --version >nul 2>&1
if errorlevel 1 (
    echo  ERROR: Node.js not found. Please install from https://nodejs.org
    pause & exit /b 1
)
echo  Node.js OK

echo  [2/4] Installing dependencies (frontend + backend)...
call npm install --silent
if errorlevel 1 (
    echo  ERROR: npm install failed (root).
    pause & exit /b 1
)
pushd backend
call npm install --silent
if errorlevel 1 (
    echo  ERROR: npm install failed (backend).
    popd & pause & exit /b 1
)
popd
echo  Dependencies OK

echo  [3/4] Building Tailwind CSS...
if not exist "assets\tailwind.css" (
    call npm run build:css
) else (
    call npm run build:css
)
if errorlevel 1 (
    echo  ERROR: tailwind build failed.
    pause & exit /b 1
)
echo  CSS OK

cd /d "%~dp0backend"

echo  [4/4] Starting server...
echo.
echo  Admin Panel  -> http://localhost:3000/admin/index.html
echo  Admin Login  -> http://localhost:3000/admin/login.html
echo  API Base     -> http://localhost:3000/api
echo.
echo  Press Ctrl+C to stop the server
echo.
start "" "http://localhost:3000/admin/login.html"
node --experimental-sqlite server.js
pause
