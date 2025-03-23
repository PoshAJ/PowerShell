// MIT License ~ Copyright (c) 2022 Anthony J. Raymond
// Implementation by Anthony Raymond intended for use with Microsoft PowerShell.

using System;
using System.Runtime.InteropServices;

namespace Console {
    public static class Window {
        public enum CmdShow {
            SW_HIDE = 0,
            SW_SHOWNORMAL = 1,
            SW_NORMAL = 1,
            SW_SHOWMINIMIZED = 2,
            SW_SHOWMAXIMIZED = 3,
            SW_MAXIMIZE = 3,
            SW_SHOWNOACTIVATE = 4,
            SW_SHOW = 5,
            SW_MINIMIZE = 6,
            SW_SHOWMINNOACTIVE = 7,
            SW_SHOWNA = 8,
            SW_RESTORE = 9,
            SW_SHOWDEFAULT = 10,
            SW_FORCEMINIMIZE = 11
        }

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern IntPtr GetConsoleWindow();

        [DllImport("user32.dll")]
        private static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

        public static void SetWindow(CmdShow nCmdShow) {
            IntPtr hWnd = GetConsoleWindow();

            if (hWnd == null) {
                throw CreateException(Marshal.GetLastWin32Error());
            }

            ShowWindow(hWnd, (int) nCmdShow);
        }

        private static Exception CreateException(int errorCode) {
            const int ERROR_FAILED_SUCCESSFULLY = 0;
            const int ERROR_INVALID_HANDLE = 6;

            switch (errorCode) {
                case ERROR_FAILED_SUCCESSFULLY :
                    return new InvalidOperationException("ERROR_FAILED_SUCCESSFULLY");
                case ERROR_INVALID_HANDLE :
                    return new InvalidOperationException("ERROR_INVALID_HANDLE");
                default :
                    return new InvalidOperationException(String.Format("ERROR_GENERIC ({0})", errorCode));
            }
        }
    }
}