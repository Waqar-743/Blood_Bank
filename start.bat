@echo off
title Nutech Blood Bank Server
color 0C

echo.
echo  ==========================================
echo   NUTECH BLOOD BANK MANAGEMENT SYSTEM
echo   CS160 Database Systems PBL
echo  ==========================================
echo.

cd /d "%~dp0backend"

echo  [1/3] Checking Node.js...
node --version >nul 2>&1
if errorlevel 1 (
    echo  ERROR: Node.js not found. Please install from https://nodejs.org
    pause & exit /b 1
)
echo  Node.js OK

echo  [2/3] Installing dependencies...
call npm install --silent
if errorlevel 1 (
    echo  ERROR: npm install failed.
    pause & exit /b 1
)
echo  Dependencies OK

echo  [3/3] Starting server...
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
