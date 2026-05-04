@echo off
setlocal enabledelayedexpansion

echo === BASELINE BACKEND SMOKE CHECK ===
echo.

REM Step 1: Show versions
echo Step 1: Node and npm versions
node -v
npm -v
echo.

REM Step 2: Install dependencies
echo Step 2: Running npm ci in backend
cd /d "d:\dell\Downloads\Nutech_BloodBank\backend"
call npm ci
echo.

REM Step 3: Start server in background
echo Step 3: Starting backend server...
start "BloodBank Backend" /B node --experimental-sqlite server.js
timeout /t 3 /nobreak
echo Backend started (PID check via tasklist)
echo.

REM Step 4: Test endpoints
echo Step 4: Testing endpoints...
echo Testing /api/stats
curl -s http://localhost:3000/api/stats | findstr /R ".*"
echo.
echo Testing /api/blood-groups
curl -s http://localhost:3000/api/blood-groups | findstr /R ".*"
echo.

REM Step 5: Stop the process
echo Step 5: Stopping backend...
taskkill /FI "WINDOWTITLE eq BloodBank Backend" /T /F
timeout /t 1 /nobreak
echo Process terminated
echo.
echo === SMOKE CHECK COMPLETE ===
