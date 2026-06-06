@echo off
cd /d "C:\Users\User\Ai Projects\meerkat\meerk40t"
REM Wake DLC32 Wi-Fi stack before TCP connect (see docs/meerk40t/17-meerkat-dlc32-workflow.md)
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Users\User\Ai Projects\meerkat\scripts\wake-mks-dlc32.ps1" 2>nul
call ".venv\Scripts\activate.bat"
python meerk40t.py %*
exit /b %ERRORLEVEL%
