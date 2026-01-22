#!/bin/bash
# 在 macOS 上直接创建和打包 .app 的脚本
# 使用方法: ./create-macos-app.sh arm64  或  ./create-macos-app.sh x64

if [ $# -eq 0 ]; then
    echo "使用方法: $0 [arm64|x64]"
    exit 1
fi

ARCH=$1
APP_NAME="GlobalUnityInstaller"
RUNTIME="osx-$ARCH"
PUBLISH_PATH="src/bin/Release/net8.0/$RUNTIME/publish"
APP_BUNDLE="$APP_NAME.app"

echo "🚀 正在为 macOS ($ARCH) 创建 .app 包..."

# 1. 发布应用
echo "📦 发布应用..."
dotnet publish src/GlobalUnityInstaller.csproj -c Release -r $RUNTIME --self-contained

# 2. 创建 .app 目录结构
echo "📁 创建 .app 结构..."
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# 3. 复制文件
echo "📋 复制文件..."
cp -R "$PUBLISH_PATH/"* "$APP_BUNDLE/Contents/MacOS/"

# 4. 设置可执行权限
chmod +x "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

# 5. 创建 Info.plist
echo "📝 创建 Info.plist..."
cat > "$APP_BUNDLE/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.globalunityinstaller.app</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
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
    <key>LSMinimumSystemVersion</key>
    <string>10.15</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
EOF

echo "✅ .app 包创建成功: $APP_BUNDLE"
echo ""
echo "🎁 打包为 DMG:"
echo "   hdiutil create -volname '$APP_NAME' -srcfolder $APP_BUNDLE -ov -format UDZO $APP_NAME-$ARCH.dmg"
echo ""
echo "🔐 代码签名 (可选):"
echo "   codesign --force --deep --sign - $APP_BUNDLE"
