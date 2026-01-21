using System.Collections.Generic;
using System.Globalization;

namespace GlobalUnityInstaller
{
    public static class Localization
    {
        private static Dictionary<string, string> _currentStrings = new();

        public static void Init()
        {
            var culture = CultureInfo.CurrentUICulture.Name; // e.g. "zh-CN", "en-US"
            
            // Simple detection: if starts with "zh", use Chinese, otherwise default to English
            if (culture.StartsWith("zh"))
            {
                _currentStrings = ChineseStrings;
            }
            else
            {
                _currentStrings = EnglishStrings;
            }
        }

        public static string Get(string key)
        {
            return _currentStrings.TryGetValue(key, out var val) ? val : key;
        }

        private static readonly Dictionary<string, string> EnglishStrings = new()
        {
            { "WindowTitle", "Global Unity Installer" },
            { "LabelUnityPath", "Unity Hub Location" },
            { "WatermarkUnityPath", "Auto detecting..." },
            { "HintManualSelect", "If not detected, please select manually" },
            { "LabelHttpPort", "HTTP Proxy Port" },
            { "WatermarkHttpPort", "Ex: 7890" },
            { "LabelSocksPort", "SOCKS5 Proxy Port" },
            { "WatermarkSocksPort", "Ex: 1080" },
            { "BtnBrowse", "..." },
            { "BtnLaunch", "Launch Unity Hub" },
            { "DialogTitleSelectFolder", "Select Unity Hub Folder" },
            { "StatusMissPath", "Unity Hub not detected, please select manually" },
            { "StatusInvalidPath", "Invalid Unity Hub path or file not found" },
            { "StatusNoPort", "Please enter at least one proxy port" },
            { "StatusHttpFail", "Cannot connect to HTTP Port {0}" },
            { "StatusSocksFail", "Cannot connect to SOCKS5 Port {0}" },
            { "StatusLaunchSuccess", "Unity Hub Launched Successfully!" },
            { "StatusLaunchFail", "Launch Failed: {0}" }
        };

        private static readonly Dictionary<string, string> ChineseStrings = new()
        {
            { "WindowTitle", "Global Unity Installer" },
            { "LabelUnityPath", "Unity Hub 位置" },
            { "WatermarkUnityPath", "自动检测中..." },
            { "HintManualSelect", "若未检测到，请手动选择安装路径" },
            { "LabelHttpPort", "HTTP 代理端口" },
            { "WatermarkHttpPort", "例如: 7890" },
            { "LabelSocksPort", "SOCKS5 代理端口" },
            { "WatermarkSocksPort", "例如: 1080" },
            { "BtnBrowse", "..." },
            { "BtnLaunch", "启动 Unity Hub" },
            { "DialogTitleSelectFolder", "选择 Unity Hub 文件夹" },
            { "StatusMissPath", "未检测到 Unity Hub，请点击“浏览”按钮手动选择路径" },
            { "StatusInvalidPath", "Unity Hub 路径无效或文件不存在" },
            { "StatusNoPort", "请至少填写一个代理端口" },
            { "StatusHttpFail", "HTTP 端口 {0} 无法连接" },
            { "StatusSocksFail", "SOCKS5 端口 {0} 无法连接" },
            { "StatusLaunchSuccess", "Unity Hub 启动成功！" },
            { "StatusLaunchFail", "启动失败: {0}" }
        };
    }
}
