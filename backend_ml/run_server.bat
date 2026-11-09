@echo off
title SmartCook Machine Learning Service
echo ===================================================
echo     Menjalankan Backend Machine Learning SmartCook
echo ===================================================
echo.
cd /d "%~dp0"

:: Cek apakah command python tersedia di PATH
where python >nul 2>nul
if %ERRORLEVEL% equ 0 (
    set "PY_CMD=python"
) else (
    :: Fallback ke instalasi lokal di laptop ini
    set "PY_CMD=C:\Users\Hype AMD\AppData\Local\Python\pythoncore-3.14-64\python.exe"
)

echo Menggunakan Python: %PY_CMD%
echo Server akan aktif di http://127.0.0.1:8000
echo Tekan CTRL + C di jendela ini untuk mematikan server.
echo.

"%PY_CMD%" -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
pause
