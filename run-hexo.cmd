@echo off
set "ROOT=%~dp0"
set "NODE_ROOT=%ROOT%.tools\node-v24.16.0-win-x64"
set "NPM_PREFIX=%ROOT%.tools\npm-global"

if exist "%NPM_PREFIX%\hexo.cmd" (
  set "PATH=%NODE_ROOT%;%NPM_PREFIX%;%ROOT%node_modules\.bin;%PATH%"
  "%NPM_PREFIX%\hexo.cmd" %*
  exit /b %ERRORLEVEL%
)

where hexo >nul 2>nul
if %ERRORLEVEL%==0 (
  hexo %*
  exit /b %ERRORLEVEL%
)

echo Hexo CLI was not found. Install Node.js LTS, then run: npm install -g hexo-cli
exit /b 1
