# 发布脚本说明

本项目支持跨平台发布。不同平台需要在相应的系统上编译。

---

## 🚀 推荐：一键发布所有平台

### 在 Windows 上运行（推荐方式）

```powershell
# 一键发布所有平台并自动打包
.\publish-all.ps1 -CreatePackages
```

此命令会为以下平台生成发布包：
- ✅ `releases/GlobalUnityInstaller-win-x64.zip` (Windows x64)
- ✅ `releases/GlobalUnityInstaller-win-arm64.zip` (Windows ARM64)
- ✅ `releases/GlobalUnityInstaller-linux-x64.tar.gz` (Linux x64)
- ✅ macOS 版本需要在 Mac 上单独编译

---

### 🪟 Windows 系统上运行

在 **Windows 计算机** 上执行以下命令。Windows 已配置单文件发布，自动使用 `assets/icon.ico` 作为应用图标。

#### Windows x64（64位）

```powershell
# 发布
dotnet publish src/GlobalUnityInstaller.csproj -c Release -r win-x64 --self-contained

# 打包为 ZIP（可选）
Compress-Archive -Path "src/bin/Release/net8.0/win-x64/publish/GlobalUnityInstaller.exe" `
  -DestinationPath "GlobalUnityInstaller-win-x64.zip" -Force
```

**产物位置：** `src/bin/Release/net8.0/win-x64/publish/GlobalUnityInstaller.exe`

#### Windows ARM64（ARM 64位）

```powershell
# 发布
dotnet publish src/GlobalUnityInstaller.csproj -c Release -r win-arm64 --self-contained

# 打包为 ZIP（可选）
Compress-Archive -Path "src/bin/Release/net8.0/win-arm64/publish/GlobalUnityInstaller.exe" `
  -DestinationPath "GlobalUnityInstaller-win-arm64.zip" -Force
```

**产物位置：** `src/bin/Release/net8.0/win-arm64/publish/GlobalUnityInstaller.exe`

---

### 🍎 macOS 系统上运行

在 **Mac 计算机** 上执行以下命令。

#### Apple Silicon (ARM64)

```bash
# 发布
dotnet publish src/GlobalUnityInstaller.csproj -c Release -r osx-arm64 --self-contained

# 打包为 ZIP（可选）
cd src/bin/Release/net8.0/osx-arm64/publish
zip -r GlobalUnityInstaller-mac-arm64.zip GlobalUnityInstaller
```

**产物位置：** `src/bin/Release/net8.0/osx-arm64/publish/GlobalUnityInstaller`

#### Intel x64

```bash
# 发布
dotnet publish src/GlobalUnityInstaller.csproj -c Release -r osx-x64 --self-contained

# 打包为 ZIP（可选）
cd src/bin/Release/net8.0/osx-x64/publish
zip -r GlobalUnityInstaller-mac-x64.zip GlobalUnityInstaller
```

**产物位置：** `src/bin/Release/net8.0/osx-x64/publish/GlobalUnityInstaller`

---

### 🐧 Linux 系统上运行

在 **Linux 计算机** 上执行以下命令。

#### Linux x64 - 方式一：创建 AppImage（推荐）

```bash
# 使脚本可执行
chmod +x scripts/create-linux-appimage.sh

# 运行脚本创建 AppImage
./scripts/create-linux-appimage.sh

# 使用 appimagetool 打包（需要下载工具）
wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
chmod +x appimagetool-x86_64.AppImage
./appimagetool-x86_64.AppImage GlobalUnityInstaller.AppDir GlobalUnityInstaller-x86_64.AppImage
```

**优点：** 单个 `.AppImage` 文件，用户下载后赋予执行权限即可直接运行，无需安装依赖

#### Linux x64 - 方式二：简易打包

```bash
# 发布
dotnet publish src/GlobalUnityInstaller.csproj -c Release -r linux-x64 --self-contained

# 打包为 tar.gz
tar czf GlobalUnityInstaller-linux-x64.tar.gz -C src/bin/Release/net8.0/linux-x64/publish .

# 用户使用时需赋予执行权限
chmod +x GlobalUnityInstaller
./GlobalUnityInstaller
```

**产物位置：** `src/bin/Release/net8.0/linux-x64/publish/GlobalUnityInstaller`

---

## 📋 标准发布包命名规范

| 平台          | 文件名                                  | 格式   |
| ------------- | --------------------------------------- | ------ |
| Windows x64   | `GlobalUnityInstaller-win-x64.zip`      | ZIP    |
| Windows ARM64 | `GlobalUnityInstaller-win-arm64.zip`    | ZIP    |
| macOS ARM64   | `GlobalUnityInstaller-mac-arm64.dmg`    | DMG    |
| macOS x64     | `GlobalUnityInstaller-mac-x64.dmg`      | DMG    |
| Linux x64     | `GlobalUnityInstaller-linux-x64.tar.gz` | TAR.GZ |

---

## 📝 注意事项

1. **macOS .app 包：** 必须在 macOS 上设置正确的执行权限才能运行
2. **Linux 可执行文件：** 用户需要手动 `chmod +x` 赋予执行权限
3. **代码签名：** 正式发布建议对应用进行数字签名：
   - Windows: 使用 SignTool
   - macOS: 使用 `codesign` 和 Apple Developer ID
   - Linux: AppImage 可使用 `gpg` 签名
4. **移除调试符号：** 发布前删除 `.pdb` 文件以减小体积
