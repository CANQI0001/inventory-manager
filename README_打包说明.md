---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: 3bcd872c2004db123de50c7121731435_10cad7be720a11f1986d525400d9a7a1
    ReservedCode1: GlxYA7Y5RkZL9UmECbb/ZM6wBnWC17fsEAhRLMC0l4GHX0oeb8s4afGIs6764LMbfWUpqrDQYsivaiwjSCUXut1CCjc70PnVOWtYGGRIwssnbjLJ7yJZPK/R9ddgLq/RcPWfGgYlWSS6dRxbeRJXv8gFILtSiaMJxxXPCwfztme/BJlh0Blp+vtYqEQ=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: 3bcd872c2004db123de50c7121731435_10cad7be720a11f1986d525400d9a7a1
    ReservedCode2: GlxYA7Y5RkZL9UmECbb/ZM6wBnWC17fsEAhRLMC0l4GHX0oeb8s4afGIs6764LMbfWUpqrDQYsivaiwjSCUXut1CCjc70PnVOWtYGGRIwssnbjLJ7yJZPK/R9ddgLq/RcPWfGgYlWSS6dRxbeRJXv8gFILtSiaMJxxXPCwfztme/BJlh0Blp+vtYqEQ=
---

# 进销存管理系统 - APK 打包指南

## 一、方案说明

将已有的 Web 应用通过 **Cordova** 包装成 Android APK。本质是用一个 WebView 容器加载你的进销存系统，效果和原生 App 一样。

## 二、你需要准备的环境

打包 APK 需要 3 样东西，缺一不可：

| 组件 | 用途 | 下载地址 |
|------|------|---------|
| **Node.js** (LTS) | 运行 Cordova | https://nodejs.org |
| **JDK 17** | Java 编译环境 | https://adoptium.net (选 Temurin 17) |
| **Android SDK** | APK 构建工具链 | 安装 Android Studio 即可 |

> Android Studio 下载：https://developer.android.com/studio  
> 安装后打开一次，让它自动下载 SDK，**不需要创建项目**。

## 三、安装后验证

打开终端（Mac 用终端.app，Windows 用 CMD），依次执行：

```bash
node -v        # 应显示 v18+ 或 v20+
java -version  # 应显示 17.x
```

Android Studio 装好后，确保环境变量已设。Mac/Linux 通常在 `~/.bash_profile` 或 `~/.zshrc` 加入：

```bash
export ANDROID_HOME=$HOME/Library/Android/sdk   # Mac
export ANDROID_HOME=$HOME/Android/Sdk           # Linux
```

Windows 在"系统属性 → 环境变量"添加 `ANDROID_HOME`，值如 `C:\Users\你的用户名\AppData\Local\Android\Sdk`。

## 四、打包步骤（不超过 5 步）

### Mac / Linux

```bash
# 1. 进入 output 目录
cd 你下载的output目录

# 2. 运行一键构建脚本
bash build_apk.sh

# 3. 等待 2-5 分钟（首次需下载依赖）
# 4. 构建完成后，同目录下出现：进销存管理系统.apk
```

### Windows

```
1. 双击 build_apk.bat
2. 等待构建完成
3. 同目录下出现：进销存管理系统.apk
```

## 五、安装到手机

把 APK 文件传到安卓手机，点击安装即可。

首次安装需要开启"允许安装未知来源应用"（安装时会自动提示）。

## 六、常见问题

**Q: 提示 "No Android SDK found"**
→ 检查 ANDROID_HOME 环境变量是否设置正确

**Q: 提示 Java 版本不对**
→ Cordova 需要 JDK 17，下载 Temurin 17 版本

**Q: cordova platform add android 失败**
→ 网络问题，多试几次或开代理

**Q: 我想改应用名/包名**
→ 编辑 config.xml 中的 `<name>` 和 `widget id` 字段

---

## 文件清单

| 文件 | 说明 |
|------|------|
| index.html | 应用主体（单文件，含全部功能） |
| config.xml | Cordova 项目配置 |
| manifest.json | PWA 配置文件 |
| sw.js | 离线缓存服务 |
| res/icon/ | App 图标（多种尺寸） |
| build_apk.sh | Mac/Linux 一键构建 |
| build_apk.bat | Windows 一键构建 |
*（内容由AI生成，仅供参考）*
