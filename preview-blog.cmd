@echo off
cd /d F:\website

call run-hexo.cmd clean
call run-hexo.cmd generate
call run-hexo.cmd server

pause
