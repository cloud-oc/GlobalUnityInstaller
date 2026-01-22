# 创建 Linux 简易打包的脚本（PowerShell）
# 使用方法: .\create-linux-package.ps1

$AppName = "GlobalUnityInstaller"
$Runtime = "linux-x64"
$PublishPath = "src/bin/Release/net8.0/$Runtime/publish"
$PackageDir = "$AppName-linux-x64"

Write-Host "🚀 正在为 Linux x64 创建发布包..." -ForegroundColor Green

# 1. 创建发布目录
if (Test-Path $PackageDir) {
    Remove-Item -Path $PackageDir -Recurse -Force
}
New-Item -ItemType Directory -Path $PackageDir -Force | Out-Null

# 2. 复制文件
Write-Host "📋 复制文件..." -ForegroundColor Yellow
Copy-Item -Path "$PublishPath/*" -Destination "$PackageDir/" -Recurse -Force
Remove-Item -Path "$PackageDir/*.pdb" -Force -ErrorAction SilentlyContinue

# 3. 创建启动脚本
$LaunchScript = @"
#!/bin/bash
# Global Unity Installer 启动脚本
SCRIPT_DIR=`$(cd "`$(dirname "`$0")" && pwd)
cd "`$SCRIPT_DIR"
exec "./GlobalUnityInstaller" "`$@"
"@

$LaunchScript | Out-File -FilePath "$PackageDir/run.sh" -Encoding UTF8 -NoNewline

# 4. 创建 README
$ReadmeContent = @"
# Global Unity Installer for Linux

## 安装说明

1. 解压此文件包
2. 进入解压后的目录
3. 赋予执行权限:
   chmod +x GlobalUnityInstaller
   chmod +x run.sh
4. 运行应用:
   ./run.sh
   或直接运行:
   ./GlobalUnityInstaller

## 系统要求

- Linux x64 (64位)
- 无需安装 .NET Runtime (已包含)

## 可选：创建桌面快捷方式

创建 ~/.local/share/applications/globalunityinstaller.desktop 文件:

[Desktop Entry]
Type=Application
Name=Global Unity Installer
Exec=/path/to/$AppName/GlobalUnityInstaller
Icon=unity
Categories=Development;Utility;
Terminal=false

将 /path/to/$AppName 替换为实际安装路径。
"@

$ReadmeContent | Out-File -FilePath "$PackageDir/README.txt" -Encoding UTF8

Write-Host "✅ Linux 发布包创建成功: $PackageDir" -ForegroundColor Green
Write-Host ""
Write-Host "📦 打包为 tar.gz:" -ForegroundColor Cyan
Write-Host "   tar czf $AppName-linux-x64.tar.gz $PackageDir" -ForegroundColor Yellow
Write-Host ""
Write-Host "💡 提示: 用户解压后需要运行 'chmod +x' 赋予执行权限" -ForegroundColor White
