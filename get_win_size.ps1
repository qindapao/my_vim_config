Add-Type -TypeDefinition @"
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

public class WinSize {
    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

    [StructLayout(LayoutKind.Sequential)]
    public struct RECT {
        public int Left;
        public int Top;
        public int Right;
        public int Bottom;
    }

    public static string GetGvimWindowSize() {
        foreach (Process proc in Process.GetProcessesByName("gvim")) {
            if (!proc.MainWindowHandle.Equals(IntPtr.Zero)) {
                RECT rect;
                if (GetWindowRect(proc.MainWindowHandle, out rect)) {
                    int width = rect.Right - rect.Left;
                    int height = rect.Bottom - rect.Top;
                    return String.Format("Width: {0}, Height: {1}", width, height);
                }
            }
        }
        return "GVim window not found.";
    }
}
"@ -Language CSharp

[WinSize]::GetGvimWindowSize()

