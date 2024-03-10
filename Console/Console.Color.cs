// MIT License ~ Copyright (c) 2015 Tom Akita
// Modified ColorMapper.cs from Colorful.Console (https://github.com/tomakita/Colorful.Console).
// Based on code that was originally written by Alex Shvedov, and that was then modified by MercuryP.
// Implementation by Anthony Raymond intended for use with Microsoft PowerShell.

using System;
using System.Linq;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;

namespace Console {
    public static class Color {
        [StructLayout(LayoutKind.Sequential)]
        private struct COORD {
            internal short X;
            internal short Y;
        }

        [StructLayout(LayoutKind.Sequential)]
        private struct SMALL_RECT {
            internal short Left;
            internal short Top;
            internal short Right;
            internal short Bottom;
        }

        [StructLayout(LayoutKind.Sequential)]
        private struct COLORREF {
            internal uint DWORD;
            internal COLORREF(string Input) {
                Input = Input.TrimStart('#');
                uint R = Convert.ToUInt32(Input.Substring(0,2), 16);
                uint G = Convert.ToUInt32(Input.Substring(2,2), 16);
                uint B = Convert.ToUInt32(Input.Substring(4,2), 16);

                this.DWORD = R + (G << 8) + (B << 16);
            }
        }

        [StructLayout(LayoutKind.Sequential)]
        private struct CONSOLE_SCREEN_BUFFER_INFO_EX {
            internal int cbSize;
            internal COORD dwSize;
            internal COORD dwCursorPosition;
            internal ushort wAttributes;
            internal SMALL_RECT srWindow;
            internal COORD dwMaximumWindowSize;
            internal ushort wPopupAttributes;
            internal bool bFullscreenSupported;
            internal COLORREF black;
            internal COLORREF darkBlue;
            internal COLORREF darkGreen;
            internal COLORREF darkCyan;
            internal COLORREF darkRed;
            internal COLORREF darkMagenta;
            internal COLORREF darkYellow;
            internal COLORREF gray;
            internal COLORREF darkGray;
            internal COLORREF blue;
            internal COLORREF green;
            internal COLORREF cyan;
            internal COLORREF red;
            internal COLORREF magenta;
            internal COLORREF yellow;
            internal COLORREF white;
        }

        private const int STD_OUTPUT_HANDLE = -11;
        private static readonly IntPtr INVALID_HANDLE_VALUE = new IntPtr(-1);

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern IntPtr GetStdHandle(int nStdHandle);

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool GetConsoleScreenBufferInfoEx(IntPtr hConsoleOutput, ref CONSOLE_SCREEN_BUFFER_INFO_EX csbe);

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool SetConsoleScreenBufferInfoEx(IntPtr hConsoleOutput, ref CONSOLE_SCREEN_BUFFER_INFO_EX csbe);

        public static Dictionary<K,V> ToDictionary<K,V> (this Hashtable table) {
            return table
                .Cast<DictionaryEntry> ()
                .ToDictionary (kvp => (K) kvp.Key, kvp => (V) kvp.Value);
        }

        public static void SetColors(Hashtable hColors) {
            SetColors(hColors.ToDictionary<string, string>());
        }

        public static void SetColors(Dictionary<string, string> Colors) {
            IntPtr hConsoleOutput = GetStdHandle(STD_OUTPUT_HANDLE);
            CONSOLE_SCREEN_BUFFER_INFO_EX csbe = GetBufferInfo(hConsoleOutput);

            foreach (KeyValuePair<string, string> Color in Colors) {
                try {
                    bool bSuccess = SetColorInfo(Color, ref csbe);

                    if (!bSuccess) {
                        throw CreateException(160);
                    }
                } catch (FormatException) {
                    throw CreateException(160);
                }
            }

            SetBufferInfo(hConsoleOutput, csbe);
        }

        private static CONSOLE_SCREEN_BUFFER_INFO_EX GetBufferInfo(IntPtr hConsoleOutput) {
            CONSOLE_SCREEN_BUFFER_INFO_EX csbe = new CONSOLE_SCREEN_BUFFER_INFO_EX();
            csbe.cbSize = (int) Marshal.SizeOf(csbe);

            if (hConsoleOutput == INVALID_HANDLE_VALUE) {
                throw CreateException(Marshal.GetLastWin32Error());
            }

            bool bSuccess = GetConsoleScreenBufferInfoEx(hConsoleOutput, ref csbe);

            if (!bSuccess) {
                throw CreateException(Marshal.GetLastWin32Error());
            }

            return csbe;
        }

        private static bool SetColorInfo(KeyValuePair<string, string> kvp, ref CONSOLE_SCREEN_BUFFER_INFO_EX csbe) {
            switch (kvp.Key.ToUpper()) {
                case "BLACK" :
                    csbe.black = new COLORREF(kvp.Value);
                    return true;
                case "DARKBLUE" :
                    csbe.darkBlue = new COLORREF(kvp.Value);
                    return true;
                case "DARKGREEN" :
                    csbe.darkGreen = new COLORREF(kvp.Value);
                    return true;
                case "DARKCYAN" :
                    csbe.darkCyan = new COLORREF(kvp.Value);
                    return true;
                case "DARKRED" :
                    csbe.darkRed = new COLORREF(kvp.Value);
                    return true;
                case "DARKMAGENTA" :
                    csbe.darkMagenta = new COLORREF(kvp.Value);
                    return true;
                case "DARKYELLOW" :
                    csbe.darkYellow = new COLORREF(kvp.Value);
                    return true;
                case "GRAY" :
                    csbe.gray = new COLORREF(kvp.Value);
                    return true;
                case "DARKGRAY" :
                    csbe.darkGray = new COLORREF(kvp.Value);
                    return true;
                case "BLUE" :
                    csbe.blue = new COLORREF(kvp.Value);
                    return true;
                case "GREEN" :
                    csbe.green = new COLORREF(kvp.Value);
                    return true;
                case "CYAN" :
                    csbe.cyan = new COLORREF(kvp.Value);
                    return true;
                case "RED" :
                    csbe.red = new COLORREF(kvp.Value);
                    return true;
                case "MAGENTA" :
                    csbe.magenta = new COLORREF(kvp.Value);
                    return true;
                case "YELLOW" :
                    csbe.yellow = new COLORREF(kvp.Value);
                    return true;
                case "WHITE" :
                    csbe.white = new COLORREF(kvp.Value);
                    return true;
                default :
                    return false;
            }
        }

        private static void SetBufferInfo(IntPtr hConsoleOutput, CONSOLE_SCREEN_BUFFER_INFO_EX csbe) {
            csbe.srWindow.Bottom++;
            csbe.srWindow.Right++;

            bool bSuccess = SetConsoleScreenBufferInfoEx(hConsoleOutput, ref csbe);

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
                    return new ArgumentException("ERROR_INVALID_COLOR");
                default :
                    return new InvalidOperationException(String.Format("ERROR_GENERIC ({0})", errorCode));
            }
        }
    }
}
