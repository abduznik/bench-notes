@echo off
cd /d "%~dp0"
git add -A
git commit -m "update %date:~10,4%-%date:~4,2%-%date:~7,2%_%time:~0,2%-%time:~3,2%-%time:~6,2%"
git push
