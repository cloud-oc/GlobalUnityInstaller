# 创建 macOS .app 包的脚本
# 使用方法: .\create-macos-app.ps1 -Arch arm64  或  .\create-macos-app.ps1 -Arch x64

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("arm64", "x64")]
    [string]$Arch
)

$AppName = "GlobalUnityInstaller"
$Runtime = "osx-$Arch"
$PublishPath = "src/bin/Release/net8.0/$Runtime/publish"
$AppBundle = "$AppName.app"

Write-Host "正在为 macOS ($Arch) 创建 .app 包..." -ForegroundColor Green

# 1. 创建 .app 目录结构
$Dirs = @(
    "$AppBundle/Contents",
    "$AppBundle/Contents/MacOS",
    "$AppBundle/Contents/Resources"
)

foreach ($Dir in $Dirs) {
    if (Test-Path $Dir) {
        Remove-Item -Path $Dir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $Dir -Force | Out-Null
}

# 2. 复制可执行文件和依赖项
Write-Host "复制文件..." -ForegroundColor Yellow
Copy-Item -Path "$PublishPath/*" -Destination "$AppBundle/Contents/MacOS/" -Recurse -Force

# 2.5 复制 icon
if (Test-Path "assets/icon.png") {
    Copy-Item -Path "assets/icon.png" -Destination "$AppBundle/Contents/Resources/icon.png" -Force
    Write-Host "复制 Icon..." -ForegroundColor Yellow
}

# 3. 创建 Info.plist
$InfoPlist = @"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$AppName</string>
    <key>CFBundleIdentifier</key>
    <string>com.globalunityinstaller.app</string>
    <key>CFBundleName</key>
    <string>$AppName</string>
    <key>CFBundleDisplayName</key>
    <string>Global Unity Installer</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>CFBundleIconFile</key>
    <string>icon</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.15</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
"@

$InfoPlist | Out-File -FilePath "$AppBundle/Contents/Info.plist" -Encoding UTF8 -NoNewline

Write-Host "✓ .app 包创建成功: $AppBundle" -ForegroundColor Green
Write-Host ""
Write-Host "后续步骤 (需要在 macOS 上执行):" -ForegroundColor Cyan
Write-Host "1. 将 $AppBundle 文件夹传输到 macOS" -ForegroundColor White
Write-Host "2. 在 macOS 终端中运行:" -ForegroundColor White
Write-Host "   chmod +x $AppBundle/Contents/MacOS/$AppName" -ForegroundColor Yellow
Write-Host "3. (可选) 添加图标并签名应用" -ForegroundColor White
Write-Host ""
Write-Host "打包为 DMG (在 macOS 上):" -ForegroundColor Cyan
Write-Host "   hdiutil create -volname '$AppName' -srcfolder $AppBundle -ov -format UDZO $AppName-$Arch.dmg" -ForegroundColor Yellow
