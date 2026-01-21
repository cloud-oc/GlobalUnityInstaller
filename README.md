# GlobalUnityInstaller (.NET Avalonia Edition)

一个基于 **.NET 8.0 + Avalonia UI** 开发的跨平台工具，用于通过代理服务器启动 Unity Hub，解决在中国大陆地区访问 Unity 服务器慢或无法连接的问题。

## 功能特点

- 💻 **原生体验**：基于 Avalonia UI，Windows 和 macOS 完美适配。
- 🌍 **代理支持**：支持 HTTP 和 SOCKS5 代理。
- 🔍 **智能检测**：自动检测 Unity Hub 安装路径。
- 🎨 **现代界面**：简洁美观的暗色主题 UI。

## 系统要求

- **Windows**: Windows 10 或更高版本
- **macOS**: macOS 10.15 或更高版本
- 运行环境: [**.NET Desktop Runtime 8.0**](https://dotnet.microsoft.com/en-us/download/dotnet/8.0)

## 开发者指南

如果您想自己编译修改代码：

1.  安装 [**.NET SDK 8.0**](https://dotnet.microsoft.com/en-us/download/dotnet/8.0)。
2.  进入项目根目录。
3.  运行项目：
    ```bash
    dotnet run --project src/GlobalUnityInstaller.csproj
    ```
4.  构建发布:
    ```bash
    # Windows
    dotnet publish src/GlobalUnityInstaller.csproj -c Release -r win-x64 --self-contained -p:PublishSingleFile=true

    # macOS (Intel)
    dotnet publish src/GlobalUnityInstaller.csproj -c Release -r osx-x64 --self-contained

    # macOS (Apple Silicon)
    dotnet publish src/GlobalUnityInstaller.csproj -c Release -r osx-arm64 --self-contained

    # Linux
    dotnet publish src/GlobalUnityInstaller.csproj -c Release -r linux-x64 --self-contained
    ```
    > 构建产物默认位于 `src/bin/Release/net8.0/<RID>/publish/` 目录下。
    > 你也可以通过 `-o <OutputDirectory>` 参数指定输出目录。

## 使用方法

1.  启动程序。
2.  程序会自动查找 Unity Hub 路径，如果未找到，请点击 **"选择文件夹"** 手动指定。
3.  输入您的代理端口 (例如: `7897`)。
4.  点击 **"启动 Unity Hub"**。
