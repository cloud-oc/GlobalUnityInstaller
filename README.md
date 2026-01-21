# Global Unity Installer

一个简洁的跨平台工具，通过注入代理设置启动 Unity Hub，解决在中国大陆等地区无法验证许可证、下载编辑器或连接服务的问题。

## ✨ 主要功能

- **一键代理启动**：支持 HTTP 和 SOCKS5 代理，让 Unity Hub 正常联网。
- **自动路径检测**：自动寻找 Unity Hub 安装位置，无需手动配置（也支持手动选择）。
- **跨平台支持**：Windows、macOS 和 Linux 均可使用。
- **多语言支持**：界面根据系统语言自动切换。

## 📦 如何使用

### 方式一：直接运行源码

1. 确保已安装 [.NET SDK 8.0](https://dotnet.microsoft.com/download) 或更高版本。
2. 在项目根目录 `src` 下运行：
   ```bash
   dotnet run
   ```
3. 输入本地代理端口（如 `7890`），点击启动即可。

### 方式二：编译发布

**Windows:**
```bash
dotnet publish src/GlobalUnityInstaller.csproj -c Release -r win-x64 --self-contained -p:PublishSingleFile=true
```

**macOS (Apple Silicon):**
```bash
dotnet publish src/GlobalUnityInstaller.csproj -c Release -r osx-arm64 --self-contained
```

**macOS (Intel):**
```bash
dotnet publish src/GlobalUnityInstaller.csproj -c Release -r osx-x64 --self-contained
```
