// MIT License ~ Copyright (c) 2022 Anthony J. Raymond
// Modified "Unicode Support for the Console" from Console Class (https://docs.microsoft.com/en-us/dotnet/api/system.console).
// Implementation by Anthony Raymond intended for use with Microsoft PowerShell.

using System;
using System.Runtime.InteropServices;

namespace Console {
    public static class Font {
        [StructLayout(LayoutKind.Sequential)]
        private struct COORD {
            internal short X;
            internal short Y;
        }

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
        private struct CONSOLE_FONT_INFO_EX {
            internal int cbSize;
            internal uint nFont;
            internal COORD dwFontSize;
            internal int FontFamily;
            internal int FontWeight;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)]
            internal string FaceName;
        }

        public enum FontWeight {
            FW_DONTCARE = 0,
            FW_THIN = 100,
            FW_EXTRALIGHT = 200,
            FW_ULTRALIGHT = 200,
            FW_LIGHT = 300,
            FW_NORMAL = 400,
            FW_REGULAR = 400,
            FW_MEDIUM = 500,
            FW_SEMIBOLD = 600,
            FW_DEMIBOLD = 600,
            FW_BOLD = 700,
            FW_EXTRABOLD = 800,
            FW_ULTRABOLD = 800,
            FW_HEAVY = 900,
            FW_BLACK = 900
        }

        public enum FontFamily {
            TMPF_FIXED_PITCH = 1,
            TMPF_VECTOR = 2,
            TMPF_TRUETYPE = 4,
            TMPF_DEVICE = 8
        }

        private const int STD_OUTPUT_HANDLE = -11;
        private static readonly IntPtr INVALID_HANDLE_VALUE = new IntPtr(-1);

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern IntPtr GetStdHandle(int nStdHandle);

        [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        private static extern bool GetCurrentConsoleFontEx(IntPtr hConsoleOutput, bool maximumWindow, ref CONSOLE_FONT_INFO_EX cfe);

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool SetCurrentConsoleFontEx(IntPtr hConsoleOutput, bool maximumWindow, ref CONSOLE_FONT_INFO_EX cfe);

        public static void SetFont(string Font, short Size, FontWeight Weight = FontWeight.FW_REGULAR, FontFamily Family = FontFamily.TMPF_TRUETYPE) {
            IntPtr hConsoleOutput = GetStdHandle(STD_OUTPUT_HANDLE);
            CONSOLE_FONT_INFO_EX cfe = GetFontInfo(hConsoleOutput);

            cfe.FaceName = Font;
            cfe.dwFontSize.Y = Size;
            cfe.FontWeight = (int) Weight;
            cfe.FontFamily = (int) Family;

            SetFontInfo(hConsoleOutput, cfe);

            cfe = GetFontInfo(hConsoleOutput);

            if (cfe.FaceName != Font) {
                throw CreateException(160);
            }
        }

        private static CONSOLE_FONT_INFO_EX GetFontInfo(IntPtr hConsoleOutput) {
            CONSOLE_FONT_INFO_EX cfe = new CONSOLE_FONT_INFO_EX();
            cfe.cbSize = (int) Marshal.SizeOf(cfe);

            if (hConsoleOutput == INVALID_HANDLE_VALUE) {
                throw CreateException(Marshal.GetLastWin32Error());
            }

            bool bSuccess = GetCurrentConsoleFontEx(hConsoleOutput, false, ref cfe);

            if (!bSuccess) {
                throw CreateException(Marshal.GetLastWin32Error());
            }

            return cfe;
        }

        private static void SetFontInfo(IntPtr hConsoleOutput, CONSOLE_FONT_INFO_EX cfe) {
            bool bSuccess = SetCurrentConsoleFontEx(hConsoleOutput, false, ref cfe);

            if (!bSuccess) {
                throw CreateException(Marshal.GetLastWin32Error());
            }
        }

        private static Exception CreateException(int errorCode) {
            const int ERROR_FAILED_SUCCESSFULLY = 0;
            const int ERROR_INVALID_HANDLE = 6;
            const int ERROR_BAD_ARGUMENTS = 160;

            switch (errorCode) {
                case ERROR_FAILED_SUCCESSFULLY :
                    return new InvalidOperationException("ERROR_FAILED_SUCCESSFULLY");
                case ERROR_INVALID_HANDLE :
                    return new InvalidOperationException("ERROR_INVALID_HANDLE");
                case ERROR_BAD_ARGUMENTS :
                    return new ArgumentException("ERROR_INVALID_FONT");
                default :
                    return new InvalidOperationException(String.Format("ERROR_GENERIC ({0})", errorCode));
            }
        }
    }
}
