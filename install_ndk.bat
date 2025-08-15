@echo off
echo Instalando Android NDK 27.0.12077973...

REM Buscar el SDK Manager en las ubicaciones comunes
set SDK_MANAGER=""

if exist "%LOCALAPPDATA%\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat" (
    set SDK_MANAGER="%LOCALAPPDATA%\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat"
) else if exist "%ANDROID_SDK_ROOT%\cmdline-tools\latest\bin\sdkmanager.bat" (
    set SDK_MANAGER="%ANDROID_SDK_ROOT%\cmdline-tools\latest\bin\sdkmanager.bat"
) else if exist "%ANDROID_HOME%\cmdline-tools\latest\bin\sdkmanager.bat" (
    set SDK_MANAGER="%ANDROID_HOME%\cmdline-tools\latest\bin\sdkmanager.bat"
) else (
    echo ERROR: No se pudo encontrar el SDK Manager
    echo Por favor, instala Android Command Line Tools desde Android Studio
    pause
    exit /b 1
)

echo Encontrado SDK Manager en: %SDK_MANAGER%
echo Instalando NDK 27.0.12077973...

%SDK_MANAGER% "ndk;27.0.12077973"

if %ERRORLEVEL% EQU 0 (
    echo ✅ NDK instalado correctamente
) else (
    echo ❌ Error al instalar NDK
)

pause
