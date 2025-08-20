@echo off
cls
echo.
echo ========================================
echo    INICIANDO PETMATCH BACKEND SERVER
echo ========================================
echo.
echo 🚀 Iniciando servidor en puerto 3002...
echo 📱 Accesible desde cualquier dispositivo en la red
echo 🌐 IP Principal: 192.168.1.24:3002
echo.
cd /d "%~dp0"
node src/index.js
pause
