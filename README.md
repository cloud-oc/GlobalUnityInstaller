<div align="center">

<img src="assets/icon.svg" width="128" height="128" alt="Global Unity Installer">

# Global Unity Installer

**简称 GUI** —— 一个简洁的跨平台工具，通过注入代理设置启动 Unity Hub

解决在中国大陆等地区无法验证许可证、下载编辑器或连接服务的问题

![Downloads](https://img.shields.io/github/downloads/cloud-oc/globalunityinstaller/total.svg)
</div>

## ✨ 主要功能

- **🔗 一键代理启动** - 支持 HTTP 和 SOCKS5 代理，让 Unity Hub 正常联网
- **🔍 自动路径检测** - 自动寻找 Unity Hub 安装位置，无需手动配置  
- **🖥️ 跨平台支持** - Windows、macOS 和 Linux 均可使用
- **🌍 多语言支持** - 界面根据系统语言自动切换

> **注意** - 本工具仅提供 64 位版本，不支持 32 位系统

## 🔗 下载 Unity Hub 国际版

[📥 下载入口](https://www.nounitycn.top/unityhub)

> 特别感谢 **NoUnityCN** 提供下载服务  
> ⚠️ NoUnityCN 无法再在中国大陆 IP 环境下下载编辑器

## 📦 如何使用

[🎞️ 视频教程](https://www.bilibili.com/video/BV13SztBcE5f)

> **⚠️ 重要提示**：在使用本工具启动 Unity Hub 之前，请确保**彻底关闭**现有的 Unity Hub 进程（包括系统托盘图标），否则代理注入可能不会生效

### 🔧 代理配置说明

本工具需要配合代理软件使用，这里推荐使用 [Sparkle](https://github.com/xishang0128/sparkle)，如果你使用的是其他类型的代理工具（如 Clash、V2rayN等），思路同理。

**获取代理地址：**
1. 打开 Sparkle 客户端
2. 点击 **内核设置** > **端口设置**
3. 查看代理端口：
   - **HTTP 端口**（推荐）：默认为 `7890`，地址格式：`http://127.0.0.1:7890`
   - **SOCKS5 端口**：默认为 `1080`，地址格式：`socks5://127.0.0.1:1080`

> **协议说明**：
> - 本工具支持 HTTP 和 SOCKS5 两种代理协议，推荐优先使用 **HTTP 协议**（兼容性更好）
> - 如果你的代理工具提供**混合端口**（Mixed Port，同时支持HTTP和SOCKS5），只需填写HTTP端口即可

**使用步骤：**
1. 确保 Sparkle 在规则模式下正常运行，并已开启系统代理
2. 完全关闭 Unity Hub（包括系统托盘图标）
3. 启动 `GlobalUnityInstaller`，填入代理地址（如：`http://127.0.0.1:7890`）
4. 点击启动按钮，Unity Hub 将通过代理运行

> 💡 **提示**：代理设置是临时注入的，每次启动 Unity Hub 都需要通过本工具



---

### 方式一：下载可执行文件（推荐）

1. 前往 [Releases](../../releases) 页面下载对应系统的压缩包
2. 解压后直接运行 `GlobalUnityInstaller`（Windows 为 `.exe`）

### 方式二：直接运行源码

1. 确保已安装 [.NET SDK 8.0](https://dotnet.microsoft.com/download) 或更高版本
2. 在项目根目录运行：
   ```bash
   dotnet run --project src/GlobalUnityInstaller.csproj
   ```

### 方式三：自行编译

**快速编译到所有平台：**
```powershell
.\scripts\publish-all.ps1 -CreatePackages
```

**各平台单独编译：**

<details>
<summary>Windows</summary>

**Windows x64：**
```bash
dotnet publish src/GlobalUnityInstaller.csproj -c Release -r win-x64 --self-contained
```
产物：`src/bin/Release/net8.0/win-x64/publish/GlobalUnityInstaller.exe`

**Windows ARM64：**
```bash
dotnet publish src/GlobalUnityInstaller.csproj -c Release -r win-arm64 --self-contained
```
产物：`src/bin/Release/net8.0/win-arm64/publish/GlobalUnityInstaller.exe`

打包为 ZIP：
```powershell
# x64
Compress-Archive -Path "src/bin/Release/net8.0/win-x64/publish/GlobalUnityInstaller.exe" -DestinationPath "GlobalUnityInstaller-win-x64.zip" -Force

# ARM64
Compress-Archive -Path "src/bin/Release/net8.0/win-arm64/publish/GlobalUnityInstaller.exe" -DestinationPath "GlobalUnityInstaller-win-arm64.zip" -Force
```

</details>

<details>
<summary>macOS</summary>

**Apple Silicon (ARM64)：**
```bash
chmod +x scripts/create-macos-app.sh
./scripts/create-macos-app.sh arm64
```

**Intel (x64)：**
```bash
chmod +x scripts/create-macos-app.sh
./scripts/create-macos-app.sh x64
```

打包为 DMG：
```bash
# ARM64
hdiutil create -volname 'GlobalUnityInstaller' -srcfolder GlobalUnityInstaller.app -ov -format UDZO GlobalUnityInstaller-mac-arm64.dmg

# x64
hdiutil create -volname 'GlobalUnityInstaller' -srcfolder GlobalUnityInstaller.app -ov -format UDZO GlobalUnityInstaller-mac-x64.dmg
```

> **在 Windows 上交叉编译 macOS 应用：** 见 [scripts/README.md](scripts/README.md)

</details>

<details>
<summary>Linux</summary>

**方式一：AppImage（推荐）**
```bash
# 在 Linux 上运行
chmod +x scripts/create-linux-appimage.sh
./scripts/create-linux-appimage.sh

# 下载并使用 appimagetool
wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
chmod +x appimagetool-x86_64.AppImage
./appimagetool-x86_64.AppImage GlobalUnityInstaller.AppDir GlobalUnityInstaller-x86_64.AppImage
```

**方式二：简易打包**
```bashlinux-x64.AppImage
```

**方式二：简易打包（TAR.GZ）**
```bash
# 发布
dotnet publish src/GlobalUnityInstaller.csproj -c Release -r linux-x64 --self-contained

# 在 Windows 上创建包
.\scripts\create-linux-package.ps1

# 或在 Linux 上打包
tar czf GlobalUnityInstaller-linux-x64.tar.gz -C src/bin/Release/net8.0/linux-x64/publish .
```

产物：`.AppImage` 单文件或 `GlobalUnityInstaller-linux-x64.tar.gz`

> 详见 [scripts/README.md](scripts/README.md) 获取完整的打包指南

---
</details>

---

## ⚙️ 实现原理

### 为什么需要 GUI？

在中国大陆地区使用 **Unity Hub 国际版**时，容易遇到以下问题：
- **登录状态丢失**：无法同步 Unity 账号信息。
- **资源下载失败**：下载编辑器时进度条不动，或报“验证失败”。

**为什么 Hub 现在很难搞定代理？（Unity Hub 3.x 的变化）**
1. **显式设置被移除**：在 Unity Hub 3.x 及更新版本中，官方移除了原有的显式代理配置菜单，转而依赖“系统自动检测”。这使得用户在复杂的网络环境下（如需要特定的 HTTP/SOCKS 转发）几乎处于“黑盒”状态。
2. **检测逻辑滞后**：即便系统设置了代理，Hub 的 Node.js 底层模块在启动初期（特别是许可证验证阶段）往往无法及时捕获到这些系统级变更，导致“起步即失败”。
3. **底层环境隔离**：Unity Hub 是基于 **Electron** 开发的，包含多个独立的子进程。即便主界面看起来连接正常，负责下载和授权的底层进程可能依然无法正确通过你的代理。
   
### GUI 的核心逻辑：底层环境变量注入

GUI（Global Unity Installer）通过在 **进程启动的最前端** 注入环境变量，强制让 Unity Hub 及其所有子进程遵循指定的网络链路。

#### 1. 代理注入机制
在启动 Unity Hub 之前，GUI 会先在当前进程环境中声明以下变量：
- `HTTP_PROXY` / `HTTPS_PROXY`：Electron/Node.js 底层网络模块识别的标准环境变量。
- `ALL_PROXY`：强制让所有流量（包括某些 SOCKS5 握手）通过代理。

这种方式的优势在于：**它是非侵入式的**。它不需要修改 Unity Hub 的任何二进制文件，而是利用了操作系统的进程遗传特性。由 GUI 启动的子进程会完美继承并强制执行这些设置。

#### 2. 跨平台实现
- **Windows / Linux (Direct Injection)**: 
  - 使用 `ProcessStartInfo` 创建 Hub 进程。
  - 直接将代理配置写入该进程的 `EnvironmentVariables` 集合。
  - **结果**：只有通过 GUI 启动的这个 Hub 实例会有代理，不会影响你电脑上其他软件的运行（例如：不影响 Chrome 正常上网）。
- **macOS (Environment Hooking)**:
  - macOS 的 `.app` 启动机制较为封闭，传统方式难以传递环境变量。
  - GUI 调用 `launchctl setenv` 为当前用户会话注册临时变量。
  - 调用 `open` 命令启动 Hub，确保内核加载环境变量后再执行应用。

#### 3. 连通性测试
为了防止用户因为代理软件忘记开而产生的无效操作，GUI 在启动前会执行 **TCP 端口连通性测试**：
- 如果 `127.0.0.1:端口` 无法建立连接，GUI 会立即拦截启动并报错。
- 这确保了一旦你看到“启动成功”，Hub 就能在一个“网络通畅”的环境下跑起来。

---

## 📂 项目结构

```
GlobalUnityInstaller/
├── assets/              # 应用资源
│   ├── icon.svg        # SVG icon
│   └── icon.ico        # Windows icon
├── scripts/            # 打包脚本
│   ├── create-macos-app.ps1       # Windows 上创建 macOS .app
│   ├── create-macos-app.sh        # macOS 上发布和打包 .app
│   ├── create-linux-appimage.sh   # Linux 上创建 AppImage
│   ├── create-linux-package.ps1   # Linux 简易打包脚本
│   ├── publish-all.ps1            # 一键发布所有平台
│   └── README.md                  # 详细打包指南
├── src/               # 源代码
├── GlobalUnityInstaller.sln
└── README.md         # 项目文档
```

## 📝 许可证

[MIT License](LICENSE)

<div align="right">

**[⬆ 回到顶部](#global-unity-installer)**

</div>
