@echo off
cd /d F:\website

echo ==== 提交源码到 source 分支 ====
git add .
git diff --cached --quiet
if %errorlevel%==0 (
    echo 没有新的源码改动需要提交。
) else (
    git commit -m "Update blog"
    git push origin source
)

echo ==== 生成并部署网站到 main 分支 ====
call run-hexo.cmd clean
call run-hexo.cmd generate
call run-hexo.cmd deploy

echo ==== 完成 ====
pause
