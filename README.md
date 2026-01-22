<div align="center">

<img src="assets/icon.svg" width="128" height="128" alt="Global Unity Installer">

# Global Unity Installer

**简称 GUI** —— 一个简洁的跨平台工具，通过注入代理设置启动 Unity Hub

解决在中国大陆等地区无法验证许可证、下载编辑器或连接服务的问题

[快速开始](#-如何使用) • [功能特性](#-主要功能) • [下载](#-发布) • [文档](scripts/README.md)

</div>

## ✨ 主要功能

- **🔗 一键代理启动** - 支持 HTTP 和 SOCKS5 代理，让 Unity Hub 正常联网
- **🔍 自动路径检测** - 自动寻找 Unity Hub 安装位置，无需手动配置  
- **🖥️ 跨平台支持** - Windows、macOS 和 Linux 均可使用
- **🌍 多语言支持** - 界面根据系统语言自动切换

> **注意** - 本工具仅提供 64 位版本，不支持 32 位系统

## 🔗 下载 Unity Hub 国际版

[📥 https://www.nounitycn.top/unityhub](https://www.nounitycn.top/unityhub)

> 特别感谢 **NoUnityCN** 提供下载服务  
> ⚠️ NoUnityCN 无法再在中国大陆 IP 环境下下载编辑器

## 📦 如何使用

> **⚠️ 重要提示**：在使用本工具启动 Unity Hub 之前，请确保**彻底关闭**现有的 Unity Hub 进程（包括系统托盘图标），否则代理注入可能不会生效

### 方式一：下载可执行文件（推荐）

1. 前往 [Releases](../../releases) 页面下载对应系统的压缩包
2. 解压后直接运行 `GlobalUnityInstaller`（Windows 为 `.exe`）

### 方式二：直接运行源码

1. 确保已安装 [.NET SDK 8.0](https://dotnet.microsoft.com/download) 或更高版本
2. 在项目根目录运行：
   ```bash
   dotnet run --project src/GlobalUnityInstaller.csproj
   ```
3. 输入本地代理端口（如 `7890`），点击启动即可

### 方式三：自行编译

**快速发布所有平台：**
```powershell
.\scripts\publish-all.ps1 -CreatePackages
```

**各平台单独编译：**

<details>
<summary>Windows</summary>

```bash
dotnet publish src/GlobalUnityInstaller.csproj -c Release -r win-x64 --self-contained
```
产物：`src/bin/Release/net8.0/win-x64/publish/GlobalUnityInstaller.exe`（单文件可执行）

</details>

<details>
<summary>macOS</summary>

**在 macOS 上（推荐）：**
```bash
# Apple Silicon
chmod +x scripts/create-macos-app.sh
./scripts/create-macos-app.sh arm64

# Intel Mac
./scripts/create-macos-app.sh x64
```

**在 Windows/Linux 上：**
```bash
# 1. 发布
dotnet publish src/GlobalUnityInstaller.csproj -c Release -r osx-arm64 --self-contained

# 2. 创建 .app（Windows）
.\scripts\create-macos-app.ps1 -Arch arm64

# 3. 传输到 macOS 并设置权限
chmod +x GlobalUnityInstaller.app/Contents/MacOS/GlobalUnityInstaller
```

产物：`GlobalUnityInstaller.app` 应用包，可进一步打包为 DMG：
```bash
hdiutil create -volname 'GlobalUnityInstaller' -srcfolder GlobalUnityInstaller.app -ov -format UDZO GlobalUnityInstaller.dmg
```

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
```bash
# 发布
dotnet publish src/GlobalUnityInstaller.csproj -c Release -r linux-x64 --self-contained

# 在 Windows 上创建包
.\scripts\create-linux-package.ps1

# 或在 Linux 上打包
tar czf GlobalUnityInstaller-linux-x64.tar.gz -C src/bin/Release/net8.0/linux-x64/publish .
```

产物：`.AppImage` 单文件或 `.tar.gz` 压缩包

</details>

> 📖 **详细打包说明**：请参阅 [scripts/README.md](scripts/README.md) 获取完整的打包指南

---

## 📁 项目结构

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

<div align="center">

**[⬆ 回到顶部](#global-unity-installer)**

</div>
