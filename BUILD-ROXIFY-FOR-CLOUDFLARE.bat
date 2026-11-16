@echo off
setlocal
cd /d "%~dp0"
title ROXIFY - Cloudflare Pages Builder

echo ==========================================
echo       ROXIFY CLOUDFLARE PAGES BUILDER
echo ==========================================
echo.

if not exist "package.json" (
  echo ERROR: package.json was not found.
  echo Keep this BAT file in the same folder as package.json.
  pause
  exit /b 1
)

where node >nul 2>nul
if errorlevel 1 (
  echo ERROR: Node.js is not installed or is not on PATH.
  echo Install the current Node.js LTS, restart Windows, and try again.
  pause
  exit /b 1
)

where npm >nul 2>nul
if errorlevel 1 (
  echo ERROR: npm was not found. Reinstall Node.js LTS and try again.
  pause
  exit /b 1
)

echo Project folder: %CD%
echo.
echo Node version:
node --version
echo npm version:
npm --version
echo.

echo [1/2] Installing the exact project dependencies...
npm ci --no-audit
if errorlevel 1 (
  echo.
  echo INSTALL FAILED. Check your internet connection and the error above.
  echo Make sure this folder is extracted and package.json is beside this BAT file.
  pause
  exit /b 1
)

echo.
echo [2/2] Building the production website...
npm run build
if errorlevel 1 (
  echo.
  echo BUILD FAILED. Take a screenshot of the error and send it for diagnosis.
  pause
  exit /b 1
)

if not exist "dist\index.html" (
  echo ERROR: Build finished but dist\index.html was not created.
  pause
  exit /b 1
)

echo.
echo ==========================================
echo SUCCESS! ROXIFY IS READY FOR CLOUDFLARE.
echo ==========================================
echo.
echo Upload the CONTENTS of this folder to Cloudflare Pages:
echo %CD%\dist
echo.
echo Do NOT upload src, node_modules, or the original source ZIP.
start "" explorer "%CD%\dist"
echo The dist folder has been opened for you.
pause
