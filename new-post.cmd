@echo off
cd /d F:\website

if "%~1"=="" (
  echo Usage: new-post.cmd "文章标题"
  pause
  exit /b 1
)

call run-hexo.cmd new "%~1"
pause
