# Unity Hub 代理启动器 (.NET Avalonia Edition)

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
2.  进入 `UnityProxyLauncher` 目录。
3.  运行项目：
    ```bash
    dotnet run
    ```
4.  发布独立运行包 (无需用户安装 .NET 环境):
    ```bash
    # Windows
    dotnet publish -c Release -r win-x64 --self-contained

    # macOS
    dotnet publish -c Release -r osx-x64 --self-contained
    ```

## 使用方法

1.  启动程序。
2.  程序会自动查找 Unity Hub 路径，如果未找到，请点击 **"选择文件夹"** 手动指定。
3.  输入您的代理端口 (例如: `7890`)。
4.  点击 **"启动 Unity Hub"**。