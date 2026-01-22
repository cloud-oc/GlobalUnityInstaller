# 发布脚本说明

本目录包含了为不同平台创建发布包的脚本。

## 📦 Windows

Windows 已配置单文件发布，自动使用 `assets/icon.ico` 作为应用图标。

**发布命令：**
```powershell
dotnet publish src/GlobalUnityInstaller.csproj -c Release -r win-x64 --self-contained
```

**产物位置：** `src/bin/Release/net8.0/win-x64/publish/GlobalUnityInstaller.exe`

**分发方式：**
- 直接分发 `.exe` 文件（推荐）
- 或打包为 `.zip`：
  ```powershell
  Compress-Archive -Path "src/bin/Release/net8.0/win-x64/publish/GlobalUnityInstaller.exe" -DestinationPath "GlobalUnityInstaller-win-x64.zip"
  ```

**Icon：** 已自动嵌入 exe 文件，用户可在文件管理器中看到应用图标

---

## 🍎 macOS

### 方式一：在 macOS 上打包（推荐）

```bash
chmod +x scripts/create-macos-app.sh
./scripts/create-macos-app.sh arm64  # Apple Silicon
./scripts/create-macos-app.sh x64    # Intel Mac
```

**功能：** 自动完成发布 + 创建 `.app` 包 + 设置权限

**打包为 DMG：**
```bash
hdiutil create -volname 'GlobalUnityInstaller' -srcfolder GlobalUnityInstaller.app -ov -format UDZO GlobalUnityInstaller-arm64.dmg
```

### 方式二：在 Windows 上创建 .app 结构

1. 先发布：
   ```powershell
   dotnet publish src/GlobalUnityInstaller.csproj -c Release -r osx-arm64 --self-contained
   ```

2. 创建 .app：
   ```powershell
   .\scripts\create-macos-app.ps1 -Arch arm64  # 或 x64
   ```

3. 将生成的 `GlobalUnityInstaller.app` 文件夹传输到 macOS

4. 在 macOS 上设置权限：
   ```bash
   chmod +x GlobalUnityInstaller.app/Contents/MacOS/GlobalUnityInstaller
   ```

---

## 🐧 Linux

### 方式一：创建 AppImage（推荐）

**在 Linux 上运行：**
```bash
chmod +x scripts/create-linux-appimage.sh
./scripts/create-linux-appimage.sh
```

**然后使用 appimagetool 构建：**
```bash
wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
chmod +x appimagetool-x86_64.AppImage
./appimagetool-x86_64.AppImage GlobalUnityInstaller.AppDir GlobalUnityInstaller-x86_64.AppImage
```

**产物：** 单个 `.AppImage` 文件，用户下载后赋予执行权限即可运行

### 方式二：简易打包（跨平台）

**在 Windows 上：**
```powershell
.\scripts\create-linux-package.ps1
```

**在 Linux 上：**
```bash
# 发布
dotnet publish src/GlobalUnityInstaller.csproj -c Release -r linux-x64 --self-contained

# 打包
tar czf GlobalUnityInstaller-linux-x64.tar.gz -C src/bin/Release/net8.0/linux-x64/publish .
```

**产物：** `.tar.gz` 压缩包，用户解压后需运行 `chmod +x GlobalUnityInstaller` 赋予执行权限

---

## 🎯 快速发布所有平台

```powershell
# Windows
dotnet publish src/GlobalUnityInstaller.csproj -c Release -r win-x64 --self-contained

# macOS (需要在各自平台上完成 .app 打包)
dotnet publish src/GlobalUnityInstaller.csproj -c Release -r osx-arm64 --self-contained
dotnet publish src/GlobalUnityInstaller.csproj -c Release -r osx-x64 --self-contained

# Linux
dotnet publish src/GlobalUnityInstaller.csproj -c Release -r linux-x64 --self-contained
```

---

## 📝 注意事项

1. **macOS .app 包：** 必须在 macOS 上设置正确的执行权限才能运行
2. **Linux 可执行文件：** 用户需要手动 `chmod +x` 赋予执行权限
3. **代码签名：** 正式发布建议对应用进行数字签名：
   - Windows: 使用 SignTool
   - macOS: 使用 `codesign` 和 Apple Developer ID
   - Linux: AppImage 可使用 `gpg` 签名
4. **移除调试符号：** 发布前删除 `.pdb` 文件以减小体积
