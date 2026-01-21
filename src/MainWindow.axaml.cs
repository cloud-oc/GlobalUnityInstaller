using Avalonia;
using Avalonia.Controls;
using Avalonia.Interactivity;
using Avalonia.Media;
using Avalonia.Platform.Storage;
using System;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Net.Sockets;
using System.Runtime.InteropServices;
using System.Threading.Tasks;

namespace GlobalUnityInstaller
{
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
            AutoDetectUnityHubPath();

            BtnBrowse.Click += BtnBrowse_Click;
            BtnLaunch.Click += BtnLaunch_Click;
        }

        private void AutoDetectUnityHubPath()
        {
            string? foundPath = null;
            if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
            {
                var candidates = new[]
                {
                    @"C:\Program Files\Unity Hub\Unity Hub.exe",
                    Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), @"Unity Hub\Unity Hub.exe")
                };
                foundPath = candidates.FirstOrDefault(File.Exists);
            }
            else if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
            {
                var candidates = new[]
                {
                    "/Applications/Unity Hub.app/Contents/MacOS/Unity Hub",
                    Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), "Applications/Unity Hub.app/Contents/MacOS/Unity Hub")
                };
                foundPath = candidates.FirstOrDefault(File.Exists);
            }

            if (foundPath != null)
            {
                TxtUnityPath.Text = foundPath;
            }
        }

        private async void BtnBrowse_Click(object? sender, RoutedEventArgs e)
        {
            // Use StorageProvider (modern Avalonia API)
            var folders = await StorageProvider.OpenFolderPickerAsync(new FolderPickerOpenOptions
            {
                Title = "选择 Unity Hub 文件夹",
                AllowMultiple = false
            });

            if (folders.Count == 0) return;

            var folderPath = folders[0].Path.LocalPath; // Use LocalPath for string path

            // Try to find the exe inside
            string? validatedPath = null;

            if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
            {
                var check = Path.Combine(folderPath, "Unity Hub.exe");
                if (File.Exists(check)) validatedPath = check;
                else if (File.Exists(folderPath) && folderPath.EndsWith(".exe")) validatedPath = folderPath;
                else validatedPath = folderPath; // Just trust user if we can't find it directly, or warn?
            }
            else if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
            {
                // Mac: Path might be the .app folder
                var check = Path.Combine(folderPath, "Contents/MacOS/Unity Hub");
                 if (File.Exists(check)) validatedPath = check;
                 else
                 {
                     // Maybe they picked the folder containing .app
                     var checkApp = Path.Combine(folderPath, "Unity Hub.app/Contents/MacOS/Unity Hub");
                     if(File.Exists(checkApp)) validatedPath = checkApp;
                     else validatedPath = folderPath;
                 }
            }
            
            TxtUnityPath.Text = validatedPath ?? folderPath;
        }

        private async void BtnLaunch_Click(object? sender, RoutedEventArgs e)
        {
            SetStatus("", false); // clear

            string hubPath = TxtUnityPath.Text;
            string httpPortStr = TxtHttpPort.Text;
            string socksPortStr = TxtSocksPort.Text;

            if (string.IsNullOrWhiteSpace(hubPath) || !File.Exists(hubPath))
            {
                 // On mac, 'hubPath' might be the .app bundle path if user selected manually and logic above failed to drill down
                 // But for simplicity let's assume valid path or fail
                 // Actually, process start needs executable path
                 SetStatus("Unity Hub 路径无效或文件不存在", true);
                 return;
            }

            if (string.IsNullOrWhiteSpace(httpPortStr) && string.IsNullOrWhiteSpace(socksPortStr))
            {
                SetStatus("请至少填写一个代理端口", true);
                return;
            }

            // Port check logic
            if (int.TryParse(httpPortStr, out int httpPort))
            {
                if (!await CheckPortAsync(httpPort))
                {
                    SetStatus($"HTTP 端口 {httpPort} 无法连接", true);
                    return;
                }
            }
            
            if (int.TryParse(socksPortStr, out int socksPort))
            {
                if (!await CheckPortAsync(socksPort))
                {
                     SetStatus($"SOCKS5 端口 {socksPort} 无法连接", true);
                     return;
                }
            }

            try
            {
                var psi = new ProcessStartInfo
                {
                    FileName = hubPath,
                    UseShellExecute = false // Required to set env vars
                };

                if (int.TryParse(httpPortStr, out int hp))
                {
                    psi.EnvironmentVariables["HTTP_PROXY"] = $"http://127.0.0.1:{hp}";
                    psi.EnvironmentVariables["HTTPS_PROXY"] = $"http://127.0.0.1:{hp}";
                }
                if (int.TryParse(socksPortStr, out int sp))
                {
                    psi.EnvironmentVariables["ALL_PROXY"] = $"socks5://127.0.0.1:{sp}";
                }

                Process.Start(psi);
                SetStatus("Unity Hub 启动成功！", false);
            }
            catch (Exception ex)
            {
                SetStatus($"启动失败: {ex.Message}", true);
            }
        }

        private async Task<bool> CheckPortAsync(int port)
        {
             return await Task.Run(() => {
                 try
                 {
                     using var client = new TcpClient();
                     var result = client.BeginConnect("127.0.0.1", port, null, null);
                     var success = result.AsyncWaitHandle.WaitOne(TimeSpan.FromMilliseconds(500));
                     if (!success) return false;
                     client.EndConnect(result);
                     return true;
                 }
                 catch
                 {
                     return false;
                 }
             });
        }

        private void SetStatus(string msg, bool isError)
        {
            if (string.IsNullOrEmpty(msg))
            {
                BorderStatus.IsVisible = false;
                return;
            }

            BorderStatus.IsVisible = true;
            TxtStatus.Text = msg;
            
            if (isError)
            {
                BorderStatus.Background = new SolidColorBrush(Color.Parse("#450a0a")); // Dark Red
                BorderStatus.BorderBrush = new SolidColorBrush(Color.Parse("#ef4444")); // Red-500
                BorderStatus.BorderThickness = new Thickness(1);
                TxtStatus.Foreground = new SolidColorBrush(Color.Parse("#fca5a5")); // Red-300
            }
            else
            {
                BorderStatus.Background = new SolidColorBrush(Color.Parse("#052e16")); // Dark Green
                BorderStatus.BorderBrush = new SolidColorBrush(Color.Parse("#22c55e")); // Green-500
                BorderStatus.BorderThickness = new Thickness(1);
                TxtStatus.Foreground = new SolidColorBrush(Color.Parse("#86efac")); // Green-300
            }
        }
    }
}
