<div align="center">

<img src="assets/icon.svg" width="128" height="128" alt="Global Unity Installer">

# Global Unity Installer

**简称 GUI** —— 一个简洁的跨平台工具，通过注入代理设置启动 Unity Hub

解决在中国大陆等地区无法验证许可证、下载编辑器或连接服务的问题

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

产物：`.AppImage` 单文件或 `GlobalUnityInstaller-linux-x64scripts/README.md](scripts/README.md) 获取完整的打包指南

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

<div align="right">

**[⬆ 回到顶部](#global-unity-installer)**

</div>
