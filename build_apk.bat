@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ========================================
echo   进销存管理系统 APK 构建 (Windows)
echo ========================================
echo.

:: ── 1. 检查环境 ──
set MISSING=

echo ^>^>^> 检查运行环境...

where node >nul 2>&1
if %errorlevel% neq 0 (
    echo   [X] 未找到 Node.js
    set MISSING=!MISSING! node
) else (
    for /f "tokens=*" %%i in ('node -v') do echo   [√] Node.js %%i
)

where npm >nul 2>&1
if %errorlevel% neq 0 (
    echo   [X] 未找到 npm
    set MISSING=!MISSING! npm
)

where java >nul 2>&1
if %errorlevel% neq 0 (
    echo   [X] 未找到 Java JDK
    set MISSING=!MISSING! jdk
) else (
    for /f "tokens=*" %%i in ('java -version 2^>^&1 ^| findstr version') do echo   [√] %%i
)

if "%ANDROID_HOME%"=="" if "%ANDROID_SDK_ROOT%"=="" (
    echo   [!] 未设置 ANDROID_HOME 环境变量
    echo       请安装 Android Studio 或 Android SDK 命令行工具
    set MISSING=!MISSING! android_sdk
) else (
    echo   [√] Android SDK 已配置
)

if not "!MISSING!"=="" (
    echo.
    echo [错误] 缺少必要组件: !MISSING!
    echo.
    echo 请先安装缺失的组件:
    echo   Node.js:  https://nodejs.org (下载 LTS 版本)
    echo   JDK 17:   https://adoptium.net (下载 Temurin 17)
    echo   Android SDK: 安装 Android Studio 后自动配置
    echo.
    pause
    exit /b 1
)

echo.
echo ^>^>^> 环境检查通过！

:: ── 2. 安装 Cordova ──
echo.
echo ^>^>^> 安装 Cordova...
call npm install -g cordova >nul 2>&1
echo   [√] Cordova 安装完成

:: ── 3. 创建临时项目 ──
set SCRIPT_DIR=%~dp0
set BUILD_DIR=%SCRIPT_DIR%.build_apk
if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
mkdir "%BUILD_DIR%"
cd /d "%BUILD_DIR%"

echo.
echo ^>^>^> 创建 Cordova 项目...
call cordova create inventory-app com.inventory.manager "进销存管理" --template blank >nul 2>&1
cd inventory-app

:: ── 4. 复制文件 ──
echo ^>^>^> 复制应用文件...
copy "%SCRIPT_DIR%index.html" www\ >nul
copy "%SCRIPT_DIR%manifest.json" www\ >nul
copy "%SCRIPT_DIR%sw.js" www\ >nul
copy "%SCRIPT_DIR%config.xml" .\ >nul

mkdir res\icon 2>nul
xcopy "%SCRIPT_DIR%res\icon\*.png" res\icon\ /y /q >nul 2>&1

echo   [√] 文件复制完成

:: ── 5. 添加 Android 平台 ──
echo.
echo ^>^>^> 添加 Android 平台（首次需下载，约1-2分钟）...
call cordova platform add android >nul 2>&1
echo   [√] Android 平台就绪

:: ── 6. 构建 ──
echo.
echo ^>^>^> 开始构建 APK...
call cordova build android --debug

:: ── 7. 输出 ──
for /r "platforms\android\app\build\outputs\apk\debug" %%f in (*.apk) do set APK_PATH=%%f
if "%APK_PATH%"=="" (
    for /r "platforms\android" %%f in (app-debug.apk) do set APK_PATH=%%f
)

if not "%APK_PATH%"=="" (
    copy "%APK_PATH%" "%SCRIPT_DIR%进销存管理系统.apk" >nul
    echo.
    echo ========================================
    echo   构建成功！
    echo ========================================
    echo.
    echo   APK 文件在脚本同目录: 进销存管理系统.apk
    echo.
    echo   将 APK 传到手机安装即可。
) else (
    echo.
    echo   [X] APK 未找到，请检查上面的错误信息
)

echo.
pause
