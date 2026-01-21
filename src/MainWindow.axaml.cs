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
            Localization.Init();
            ApplyLocalization();
            AutoDetectUnityHubPath();

            BtnBrowse.Click += BtnBrowse_Click;
            BtnLaunch.Click += BtnLaunch_Click;
        }

        private void ApplyLocalization()
        {
            Title = Localization.Get("WindowTitle");
            LblUnityPath.Content = Localization.Get("LabelUnityPath");
            TxtUnityPath.Watermark = Localization.Get("WatermarkUnityPath");
            BtnBrowse.Content = Localization.Get("BtnBrowse");
            TxtManualHint.Text = Localization.Get("HintManualSelect");
            LblHttpPort.Content = Localization.Get("LabelHttpPort");
            TxtHttpPort.Watermark = Localization.Get("WatermarkHttpPort");
            LblSocksPort.Content = Localization.Get("LabelSocksPort");
            TxtSocksPort.Watermark = Localization.Get("WatermarkSocksPort");
            BtnLaunch.Content = Localization.Get("BtnLaunch");
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
                Title = Localization.Get("DialogTitleSelectFolder"),
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
            SetStatus("", 0); // clear

            string hubPath = TxtUnityPath.Text ?? "";
            string httpPortStr = TxtHttpPort.Text ?? "";
            string socksPortStr = TxtSocksPort.Text ?? "";

            if (string.IsNullOrWhiteSpace(hubPath))
            {
                 SetStatus(Localization.Get("StatusMissPath"), 1); // Warning
                 return;
            }

            if (!File.Exists(hubPath))
            {
                 SetStatus(Localization.Get("StatusInvalidPath"), 2); // Error
                 return;
            }

            if (string.IsNullOrWhiteSpace(httpPortStr) && string.IsNullOrWhiteSpace(socksPortStr))
            {
                SetStatus(Localization.Get("StatusNoPort"), 2);
                return;
            }

            // Port check logic
            if (int.TryParse(httpPortStr, out int httpPort))
            {
                if (!await CheckPortAsync(httpPort))
                {
                    SetStatus(string.Format(Localization.Get("StatusHttpFail"), httpPort), 2);
                    return;
                }
            }
            
            if (int.TryParse(socksPortStr, out int socksPort))
            {
                if (!await CheckPortAsync(socksPort))
                {
                     SetStatus(string.Format(Localization.Get("StatusSocksFail"), socksPort), 2);
                     return;
                }
            }

            try
            {
                if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
                {
                    // macOS: Use launchctl setenv + open command
                    // Crucial: Must wait for launchctl to finish setting env before launching app
                    if (int.TryParse(httpPortStr, out int hp))
                    {
                        Process.Start("launchctl", $"setenv HTTP_PROXY http://127.0.0.1:{hp}")?.WaitForExit();
                        Process.Start("launchctl", $"setenv HTTPS_PROXY http://127.0.0.1:{hp}")?.WaitForExit();
                    }
                    if (int.TryParse(socksPortStr, out int sp))
                    {
                        Process.Start("launchctl", $"setenv ALL_PROXY socks5://127.0.0.1:{sp}")?.WaitForExit();
                    }

                    // Try to resolve the .app path from the executable path
                    // e.g. /Applications/Unity Hub.app/Contents/MacOS/Unity Hub -> /Applications/Unity Hub.app
                    string appPath = hubPath;
                    if (hubPath.Contains(".app/Contents/MacOS"))
                    {
                        var index = hubPath.IndexOf(".app");
                        if (index != -1)
                        {
                            appPath = hubPath.Substring(0, index + 4);
                        }
                    }
                    
                    // Launch using 'open'
                    Process.Start("open", $"\"{appPath}\"");
                }
                else
                {
                    // Windows / Linux: Direct launch with environment variables
                    var psi = new ProcessStartInfo
                    {
                        FileName = hubPath,
                        UseShellExecute = false
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
                }

                SetStatus(Localization.Get("StatusLaunchSuccess"), 0);
            }
            catch (Exception ex)
            {
                SetStatus(string.Format(Localization.Get("StatusLaunchFail"), ex.Message), 2);
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

        // statusLevel: 0=Success, 1=Warning, 2=Error
        private void SetStatus(string msg, int statusLevel)
        {
            TxtStatus.Text = msg ?? "";
            
            if (string.IsNullOrEmpty(msg))
            {
                return;
            }

            if (statusLevel == 2) // Error
            {
                TxtStatus.Foreground = new SolidColorBrush(Color.Parse("#ef4444")); // Red-500
            }
            else if (statusLevel == 1) // Warning
            {
                TxtStatus.Foreground = new SolidColorBrush(Color.Parse("#eab308")); // Yellow-500
            }
            else // Success
            {
                TxtStatus.Foreground = new SolidColorBrush(Color.Parse("#22c55e")); // Green-500
            }
        }
    }
}
