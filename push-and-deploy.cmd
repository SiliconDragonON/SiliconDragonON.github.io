@echo off
cd /d F:\website

echo ==== 1. Build site ====
call run-hexo.cmd clean
if errorlevel 1 goto fail
call run-hexo.cmd generate
if errorlevel 1 goto fail

echo ==== 2. Commit source branch ====
git add .
git diff --cached --quiet
if errorlevel 1 (
  git commit -m "Update blog"
  if errorlevel 1 goto fail
  git push origin source
  if errorlevel 1 (
    echo Source push failed. Retrying with HTTP/1.1...
    git -c http.version=HTTP/1.1 push origin source
    if errorlevel 1 goto fail
  )
) else (
  echo No source changes to commit.
)

echo ==== 3. Deploy generated site to main ====
call run-hexo.cmd deploy
if errorlevel 1 (
  echo Deploy failed. Trying to push the generated deploy repository directly...
  cd /d F:\website\.deploy_git
  git -c http.version=HTTP/1.1 push --force https://github.com/SiliconDragonON/SiliconDragonON.github.io.git HEAD:main
  if errorlevel 1 goto fail
  cd /d F:\website
)

echo ==== Done ====
echo Visit: https://SiliconDragonON.github.io
pause
exit /b 0

:fail
echo ==== Failed ====
echo Check the error output above. If it is a GitHub network error, rerun this script.
pause
exit /b 1
