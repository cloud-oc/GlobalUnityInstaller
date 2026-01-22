#!/bin/bash
# 创建 Linux AppImage 包的脚本
# 使用方法: ./create-linux-appimage.sh

APP_NAME="GlobalUnityInstaller"
RUNTIME="linux-x64"
PUBLISH_PATH="src/bin/Release/net8.0/$RUNTIME/publish"
APP_DIR="$APP_NAME.AppDir"

echo "🚀 正在为 Linux x64 创建 AppImage 包..."

# 1. 发布应用
echo "📦 发布应用..."
dotnet publish src/GlobalUnityInstaller.csproj -c Release -r $RUNTIME --self-contained

# 2. 创建 AppDir 目录结构
echo "📁 创建 AppDir 结构..."
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/usr/bin"
mkdir -p "$APP_DIR/usr/lib"
mkdir -p "$APP_DIR/usr/share/applications"
mkdir -p "$APP_DIR/usr/share/icons/hicolor/256x256/apps"

# 3. 复制文件
echo "📋 复制文件..."
cp -R "$PUBLISH_PATH/"* "$APP_DIR/usr/bin/"
chmod +x "$APP_DIR/usr/bin/$APP_NAME"

# 3.5 复制 icon
if [ -f "assets/icon.png" ]; then
    cp "assets/icon.png" "$APP_DIR/usr/share/icons/hicolor/256x256/apps/globalunityinstaller.png"
    echo "📌 Icon 已复制"
fi

# 4. 创建桌面文件
echo "📝 创建桌面快捷方式..."
cat > "$APP_DIR/usr/share/applications/$APP_NAME.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Global Unity Installer
Comment=Launch Unity Hub with proxy settings
Exec=GlobalUnityInstaller
Icon=globalunityinstaller
Categories=Development;Utility;
Terminal=false
EOF

# 5. 创建 AppRun 启动脚本
cat > "$APP_DIR/AppRun" << 'EOF'
#!/bin/bash
SELF=$(readlink -f "$0")
HERE=${SELF%/*}
export PATH="${HERE}/usr/bin/:${PATH}"
export LD_LIBRARY_PATH="${HERE}/usr/lib/:${LD_LIBRARY_PATH}"
cd "${HERE}/usr/bin"
if [ -f "$APP_DIR/usr/share/icons/hicolor/256x256/apps/globalunityinstaller.png" ]; then
    ln -sf usr/share/icons/hicolor/256x256/apps/globalunityinstaller.png "$APP_DIR/globalunityinstaller.png"
    ln -sf usr/share/icons/hicolor/256x256/apps/globalunityinstaller.png "$APP_DIR/.DirIcon"
fi

# 6. 创建根目录的快捷方式和图标链接
ln -sf usr/share/applications/$APP_NAME.desktop "$APP_DIR/$APP_NAME.desktop"
# 如果有图标文件，可以添加:
# ln -sf usr/share/icons/hicolor/256x256/apps/globalunityinstaller.png "$APP_DIR/globalunityinstaller.png"
# ln -sf usr/share/icons/hicolor/256x256/apps/globalunityinstaller.png "$APP_DIR/.DirIcon"

echo "✅ AppDir 创建成功: $APP_DIR"
echo ""
echo "📦 创建 AppImage (需要 appimagetool):"
echo "   # 下载 appimagetool"
echo "   wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
echo "   chmod +x appimagetool-x86_64.AppImage"
echo "   # 构建 AppImage"
echo "   ./appimagetool-x86_64.AppImage $APP_DIR $APP_NAME-x86_64.AppImage"
echo ""
echo "📦 简单打包 (不使用 AppImage):"
echo "   tar czf $APP_NAME-linux-x64.tar.gz $APP_DIR"
echo "   # 用户解压后可直接运行: ./$APP_DIR/AppRun"
