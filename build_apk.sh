#!/bin/bash
# ═══════════════════════════════════════════════
#  进销存管理系统 - APK 自动构建脚本 (Linux/Mac)
# ═══════════════════════════════════════════════
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================"
echo "  进销存管理系统 APK 构建"
echo "========================================"
echo ""

# ── 1. 检查环境 ──
MISSING=""

echo ">>> 检查运行环境..."

if ! command -v node &>/dev/null; then
    echo -e "${RED}  ✗ 未找到 Node.js${NC}"
    MISSING="$MISSING node"
else
    echo -e "${GREEN}  ✓ Node.js $(node -v)${NC}"
fi

if ! command -v npm &>/dev/null; then
    echo -e "${RED}  ✗ 未找到 npm${NC}"
    MISSING="$MISSING npm"
fi

if ! command -v java &>/dev/null; then
    echo -e "${RED}  ✗ 未找到 Java JDK${NC}"
    MISSING="$MISSING jdk"
else
    echo -e "${GREEN}  ✓ Java $(java -version 2>&1 | head -1)${NC}"
fi

if [ -z "$ANDROID_HOME" ] && [ -z "$ANDROID_SDK_ROOT" ]; then
    echo -e "${YELLOW}  ⚠ 未设置 ANDROID_HOME 环境变量${NC}"
    echo "    如果没有 Android Studio，请先安装："
    echo "    https://developer.android.com/studio"
    echo "    或安装命令行工具："
    echo "    https://developer.android.com/studio#command-line-tools-only"
    MISSING="$MISSING android_sdk"
else
    SDK="${ANDROID_HOME:-$ANDROID_SDK_ROOT}"
    echo -e "${GREEN}  ✓ Android SDK: $SDK${NC}"
fi

if [ -n "$MISSING" ]; then
    echo ""
    echo -e "${RED}缺少必要组件: $MISSING${NC}"
    echo ""
    echo "请先安装缺失的组件再运行此脚本。"
    echo ""
    echo "快速安装指引:"
    echo "  Node.js:  https://nodejs.org (下载 LTS 版本)"
    echo "  JDK 17:   https://adoptium.net (下载 Temurin 17)"
    echo "  Android SDK: 安装 Android Studio 后自动配置"
    exit 1
fi

echo ""
echo ">>> 环境检查通过！"

# ── 2. 安装 Cordova ──
echo ""
echo ">>> 安装 Cordova..."
npm install -g cordova 2>&1 | tail -1
echo -e "${GREEN}  ✓ Cordova 安装完成${NC}"

# ── 3. 创建临时项目目录 ──
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/.build_apk"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

echo ""
echo ">>> 创建 Cordova 项目..."
cordova create inventory-app com.inventory.manager "进销存管理" --template blank 2>&1 | tail -1
cd inventory-app

# ── 4. 复制文件 ──
echo ">>> 复制应用文件..."
cp "$SCRIPT_DIR/index.html" www/
cp "$SCRIPT_DIR/manifest.json" www/
cp "$SCRIPT_DIR/sw.js" www/
cp "$SCRIPT_DIR/config.xml" ./

# 复制图标
mkdir -p res/icon
cp "$SCRIPT_DIR/res/icon/"*.png res/icon/ 2>/dev/null

echo -e "${GREEN}  ✓ 文件复制完成${NC}"

# ── 5. 添加 Android 平台 ──
echo ""
echo ">>> 添加 Android 平台（首次需下载，约 1-2 分钟）..."
cordova platform add android 2>&1 | tail -1
echo -e "${GREEN}  ✓ Android 平台就绪${NC}"

# ── 6. 构建 APK ──
echo ""
echo ">>> 开始构建 APK..."
cordova build android --debug 2>&1 | tail -5

# ── 7. 输出 ──
APK_PATH=$(find platforms/android/app/build/outputs/apk/debug -name "*.apk" 2>/dev/null | head -1)

if [ -z "$APK_PATH" ]; then
    # Cordova 新版本路径可能不同
    APK_PATH=$(find platforms/android -name "app-debug.apk" 2>/dev/null | head -1)
fi

if [ -n "$APK_PATH" ]; then
    cp "$APK_PATH" "$SCRIPT_DIR/进销存管理系统.apk"
    echo ""
    echo "========================================"
    echo -e "${GREEN}  构建成功！${NC}"
    echo "========================================"
    echo ""
    echo "  APK 文件: $SCRIPT_DIR/进销存管理系统.apk"
    echo "  文件大小: $(du -h "$SCRIPT_DIR/进销存管理系统.apk" | cut -f1)"
    echo ""
    echo "  将 APK 传到手机安装即可。"
else
    echo ""
    echo -e "${RED}  ✗ APK 未找到，构建可能失败${NC}"
    echo "  请检查上面的错误信息"
    exit 1
fi
