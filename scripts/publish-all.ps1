# 一键发布所有平台的脚本
# 使用方法: .\publish-all.ps1

param(
    [switch]$SkipClean,
    [switch]$CreatePackages
)

$AppName = "GlobalUnityInstaller"
$Version = "1.0.0"
$OutputDir = "releases"

Write-Host "🚀 开始发布 $AppName v$Version" -ForegroundColor Cyan
Write-Host ""

# 清理旧的发布文件
if (-not $SkipClean) {
    Write-Host "🧹 清理旧的发布文件..." -ForegroundColor Yellow
    Remove-Item -Path "src/bin/Release" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path $OutputDir -Recurse -Force -ErrorAction SilentlyContinue
}

# 创建输出目录
New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null

# 定义平台
$Platforms = @(
    @{Name="Windows x64"; Runtime="win-x64"; Extension=".exe"}
    @{Name="Windows ARM64"; Runtime="win-arm64"; Extension=".exe"}
    @{Name="macOS Apple Silicon"; Runtime="osx-arm64"; Extension=""}
    @{Name="macOS Intel"; Runtime="osx-x64"; Extension=""}
    @{Name="Linux x64"; Runtime="linux-x64"; Extension=""}
)

# 发布所有平台
foreach ($Platform in $Platforms) {
    Write-Host "📦 发布 $($Platform.Name)..." -ForegroundColor Green
    
    $PublishArgs = @(
        "publish",
        "src/GlobalUnityInstaller.csproj",
        "-c", "Release",
        "-r", $Platform.Runtime,
        "--self-contained",
        "/p:PublishSingleFile=true",
        "/p:DebugType=None",
        "/p:DebugSymbols=false"
    )
    
    & dotnet $PublishArgs
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ 发布 $($Platform.Name) 失败" -ForegroundColor Red
        continue
    }
    
    Write-Host "✅ $($Platform.Name) 发布完成" -ForegroundColor Green
    Write-Host ""
}

# 创建发布包
if ($CreatePackages) {
    Write-Host "📦 创建发布包..." -ForegroundColor Cyan
    Write-Host ""
    
    # Windows x64
    Write-Host "打包 Windows x64..." -ForegroundColor Yellow
    $WinPublish = "src/bin/Release/net8.0/win-x64/publish"
    if (Test-Path "$WinPublish/$AppName.exe") {
        Compress-Archive -Path "$WinPublish/$AppName.exe" -DestinationPath "$OutputDir/$AppName-win-x64.zip" -Force
        Write-Host "✅ Windows x64 包创建成功: $OutputDir/$AppName-win-x64.zip" -ForegroundColor Green
    }
    
    # Windows ARM64
    Write-Host "打包 Windows ARM64..." -ForegroundColor Yellow
    $WinARM64Publish = "src/bin/Release/net8.0/win-arm64/publish"
    if (Test-Path "$WinARM64Publish/$AppName.exe") {
        Compress-Archive -Path "$WinARM64Publish/$AppName.exe" -DestinationPath "$OutputDir/$AppName-win-arm64.zip" -Force
        Write-Host "✅ Windows ARM64 包创建成功: $OutputDir/$AppName-win-arm64.zip" -ForegroundColor Green
    }
    
    # macOS - 只复制文件，需要在 macOS 上完成 .app 打包
    Write-Host "复制 macOS 文件..." -ForegroundColor Yellow
    foreach ($Arch in @("arm64", "x64")) {
        $MacPublish = "src/bin/Release/net8.0/osx-$Arch/publish"
        if (Test-Path $MacPublish) {
            $MacDir = "$OutputDir/macos-$Arch"
            New-Item -ItemType Directory -Path $MacDir -Force | Out-Null
            Copy-Item -Path "$MacPublish/*" -Destination $MacDir -Recurse -Force
            Write-Host "✅ macOS ($Arch) 文件已复制到 $MacDir" -ForegroundColor Green
        }
    }
    
    # Linux
    Write-Host "打包 Linux..." -ForegroundColor Yellow
    $LinuxPublish = "src/bin/Release/net8.0/linux-x64/publish"
    if (Test-Path "$LinuxPublish/$AppName") {
        $LinuxDir = "$OutputDir/linux-x64-temp"
        New-Item -ItemType Directory -Path $LinuxDir -Force | Out-Null
        Copy-Item -Path "$LinuxPublish/*" -Destination $LinuxDir -Recurse -Force
        
        # 创建启动脚本
        $RunScript = @"
#!/bin/bash
SCRIPT_DIR=`$(cd "`$(dirname "`$0")" && pwd)
cd "`$SCRIPT_DIR"
exec "./GlobalUnityInstaller" "`$@"
"@
        $RunScript | Out-File -FilePath "$LinuxDir/run.sh" -Encoding UTF8 -NoNewline
        
        # 使用 tar 打包（如果有 tar 命令）
        if (Get-Command tar -ErrorAction SilentlyContinue) {
            tar -czf "$OutputDir/$AppName-linux-x64.tar.gz" -C $LinuxDir .
            Remove-Item -Path $LinuxDir -Recurse -Force
            Write-Host "✅ Linux 包创建成功: $OutputDir/$AppName-linux-x64.tar.gz" -ForegroundColor Green
        } else {
            Write-Host "⚠️  未找到 tar 命令，Linux 文件保存在 $LinuxDir" -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
}

Write-Host "🎉 所有平台发布完成！" -ForegroundColor Green
Write-Host ""
Write-Host "📁 发布文件位置:" -ForegroundColor Cyan
Write-Host "   Windows x64:   src/bin/Release/net8.0/win-x64/publish/" -ForegroundColor White
Write-Host "   Windows ARM64: src/bin/Release/net8.0/win-arm64/publish/" -ForegroundColor White
Write-Host "   macOS:         src/bin/Release/net8.0/osx-*/publish/" -ForegroundColor White
Write-Host "   Linux:         src/bin/Release/net8.0/linux-x64/publish/" -ForegroundColor White

if ($CreatePackages) {
    Write-Host ""
    Write-Host "📦 发布包位置: $OutputDir/" -ForegroundColor Cyan
    Write-Host "   📦 GlobalUnityInstaller-win-x64.zip" -ForegroundColor White
    Write-Host "   📦 GlobalUnityInstaller-win-arm64.zip" -ForegroundColor White
    Write-Host "   📦 GlobalUnityInstaller-linux-x64.tar.gz" -ForegroundColor White
    Write-Host ""
    Write-Host "⚠️  macOS 后续步骤:" -ForegroundColor Yellow
    Write-Host "   1. 将 $OutputDir/macos-* 目录传输到 macOS" -ForegroundColor White
    Write-Host "   2. 在 macOS 上运行命令打包为 DMG:" -ForegroundColor White
    Write-Host "      hdiutil create -volname 'GlobalUnityInstaller' -srcfolder GlobalUnityInstaller.app -ov -format UDZO GlobalUnityInstaller-mac-arm64.dmg" -ForegroundColor White
    Write-Host "      hdiutil create -volname 'GlobalUnityInstaller' -srcfolder GlobalUnityInstaller.app -ov -format UDZO GlobalUnityInstaller-mac-x64.dmg" -ForegroundColor White
}
