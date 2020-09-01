Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public static class Win32Api
{
[System.Runtime.InteropServices.DllImportAttribute( "User32.dll", EntryPoint =  "GetWindowThreadProcessId" )]
public static extern int GetWindowThreadProcessId ( [System.Runtime.InteropServices.InAttribute()] System.IntPtr hWnd, out int lpdwProcessId );

[DllImport("User32.dll", CharSet = CharSet.Auto)]
public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
}
"@


$application = new-object -ComObject "word.application"

# word does not expose its HWND, so get it this way
$caption = [guid]::NewGuid()
$application.Caption = $caption
$HWND = [Win32Api]::FindWindow( "OpusApp", $caption )



# print pid
$myPid = [IntPtr]::Zero
[Win32Api]::GetWindowThreadProcessId( $HWND, [ref] $myPid );
"PID=" + $myPid | write-host


