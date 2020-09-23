$keywords = ("petridi","io game","vlc")
$errorFile = "d:\temp\error.log"

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class UserWindows {
[DllImport("user32.dll")]
public static extern IntPtr GetForegroundWindow();
}
"@


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



function logError($errorMsg) {
    $datetime = get-date -format "yyyy-MM-dd-HH-mm-ss"
    $errorMsgfull = $datetime + " " + $errorMsg
    write-host $errorMsgfull
#    $errorMsgfull | out-file -append -filepath $errorFile
}

function Show-Process($processrocess, [Switch]$Maximize)
{
  $sig = '
    [DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern int SetForegroundWindow(IntPtr hwnd);
  '
  
  if ($Maximize) { $Mode = 3 } else { $Mode = 5 }
  $type = Add-Type -MemberDefinition $sig -Name WindowAPI -PassThru
  $hwnd = $processrocess.MainWindowHandle
  $null = $type::ShowWindowAsync($hwnd, $Mode)
  $null = $type::SetForegroundWindow($hwnd) 
}


function Get-ChildWindow{
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true, ValueFromPipelinebyPropertyName = $true)]
        [ValidateNotNullorEmpty()]
        [System.IntPtr]$MainWindowHandle
    )
    
    BEGIN{
        function Get-WindowName($hwnd) {
            $len = [apifuncs]::GetWindowTextLength($hwnd)
            if($len -gt 0){
                $sb = New-Object text.stringbuilder -ArgumentList ($len + 1)
                $rtnlen = [apifuncs]::GetWindowText($hwnd,$sb,$sb.Capacity)
                $sb.tostring()
            }
        }
    
        if (("APIFuncs" -as [type]) -eq $null){
            Add-Type  @"
            using System;
            using System.Runtime.InteropServices;
            using System.Collections.Generic;
            using System.Text;
            public class APIFuncs
              {
                [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
                public static extern int GetWindowText(IntPtr hwnd,StringBuilder lpString, int cch);
    
                [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)]
                public static extern IntPtr GetForegroundWindow();
    
                [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)]
                public static extern Int32 GetWindowThreadProcessId(IntPtr hWnd,out Int32 lpdwProcessId);
    
                [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)]
                public static extern Int32 GetWindowTextLength(IntPtr hWnd);
    
                [DllImport("user32")]
                [return: MarshalAs(UnmanagedType.Bool)]
                public static extern bool EnumChildWindows(IntPtr window, EnumWindowProc callback, IntPtr i);
                public static List<IntPtr> GetChildWindows(IntPtr parent)
                {
                   List<IntPtr> result = new List<IntPtr>();
                   GCHandle listHandle = GCHandle.Alloc(result);
                   try
                   {
                       EnumWindowProc childProc = new EnumWindowProc(EnumWindow);
                       EnumChildWindows(parent, childProc,GCHandle.ToIntPtr(listHandle));
                   }
                   finally
                   {
                       if (listHandle.IsAllocated)
                           listHandle.Free();
                   }
                   return result;
               }
                private static bool EnumWindow(IntPtr handle, IntPtr pointer)
               {
                   GCHandle gch = GCHandle.FromIntPtr(pointer);
                   List<IntPtr> list = gch.Target as List<IntPtr>;
                   if (list == null)
                   {
                       throw new InvalidCastException("GCHandle Target could not be cast as List<IntPtr>");
                   }
                   list.Add(handle);
                   //  You can modify this to check to see if you want to cancel the operation, then return a null here
                   return true;
               }
                public delegate bool EnumWindowProc(IntPtr hWnd, IntPtr parameter);
               }
"@
            }
    }
    
    PROCESS{
        foreach ($child in ([apifuncs]::GetChildWindows($MainWindowHandle))){
            Write-Output (,([PSCustomObject] @{
                MainWindowHandle = $MainWindowHandle
                ChildId = $child
                ChildTitle = (Get-WindowName($child))
            }))
        }
    }
    }

function Set-WindowStyle {

    <#
    .LINK
    https://gist.github.com/jakeballard/11240204
    #>

    [CmdletBinding(DefaultParameterSetName = 'InputObject')]
    param(
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelinebyPropertyName = $True)]
        [Object[]] $InputObject,
        [Parameter(Position = 1)]
        [ValidateSet('FORCEMINIMIZE', 'HIDE', 'MAXIMIZE', 'MINIMIZE', 'RESTORE', 'SHOW', 'SHOWDEFAULT', 'SHOWMAXIMIZED', 'SHOWMINIMIZED', 'SHOWMINNOACTIVE', 'SHOWNA', 'SHOWNOACTIVATE', 'SHOWNORMAL')]
        [string] $Style = 'SHOW'
    )

    BEGIN {
        $WindowStates = @{
            'FORCEMINIMIZE'   = 11
            'HIDE'            = 0
            'MAXIMIZE'        = 3
            'MINIMIZE'        = 6
            'RESTORE'         = 9
            'SHOW'            = 5
            'SHOWDEFAULT'     = 10
            'SHOWMAXIMIZED'   = 3
            'SHOWMINIMIZED'   = 2
            'SHOWMINNOACTIVE' = 7
            'SHOWNA'          = 8
            'SHOWNOACTIVATE'  = 4
            'SHOWNORMAL'      = 1
        }

        $Win32ShowWindowAsync = Add-Type -MemberDefinition @'
[DllImport("user32.dll")]
public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
'@ -Name "Win32ShowWindowAsync" -Namespace Win32Functions -PassThru

    }

    PROCESS {
        foreach ($processrocess in $InputObject) {
            write-host "test 33 : " $processrocess.MainWindowTitle
            
            $Win32ShowWindowAsync::ShowWindowAsync($processrocess.MainWindowHandle, $WindowStates[$Style]) # | Out-Null
            Write-Verbose ("Set Window Style '{1}' on '{0}'" -f $MainWindowHandle, $Style)
        }
    }
}

Start-Sleep -s 4

#Get-Process | Where-Object {$_.ProcessName -eq 'chrome'} | Get-ChildWindow
#Write-Host "start"
#Get-Process | Where-Object {$_.id -eq 34924}| Get-ChildWindow | ? { $_.ChildTitle -ne "" } | select $_.ChildTitle
#? { $_.ChildTitle.contains('rome')  }

#Get-ChildWindow 34924
#Write-Host "end"

#$process = Get-Process | Where-Object {$_.ProcessName -eq "chrome" -and $_.MainWindowTitle -ne ""}
#Set-WindowStyle $process 'SHOWNA'

while ($true) {
#while ($false) {
    
    # get the activeHandle (handle of the active window)
    $ActiveHandle = [userWindows]::GetForegroundWindow()
    $process = Get-Process | Where-Object { $_.MainWindowHandle -eq $activeHandle }
    # else if the context menu has been activated in the active window (by clicking the right button of the mouse)
    #write-host "processname : $($process.processname)|mainwindowTitle:$($process.MainWindowTitle)|activeHandle:$ActiveHandle), pid:$($process.id)"

    #$HWND = [Win32Api]::FindWindow( "OpusApp", $caption )
    #$HWND = $activeHandle
    # print pid

    # at this point $process is a process that might be the one owning the active window, or it could be something
    # so let's find the real process owner of the whole thread
    $myPid = [IntPtr]::Zero
    [Win32Api]::GetWindowThreadProcessId( $ActiveHandle, [ref] $myPid ) | out-null
    #"test 1 : p.processName : " + $process.processName + "     p.ID " +  $process.id | write-host
    #"PID=" + $myPid | write-host 

    $process = Get-Process | Where-Object { $_.id -eq $myPid }
    write-host "processname : $($process.processname)|mainwindowTitle:$($process.MainWindowTitle)|activeHandle:$ActiveHandle), pid:$($process.id)"
    #"test 2 : p.processName : " + $process.processName + "     p.ID " +  $process.id | write-host
    write-host "-------------------"
    # at this point, we have the right process and we can ask it to reactive it's main window (and to let the 
    # context menu disappear)
    show-process $process 'SHOW'
    #Set-WindowStyle $process 'MINIMIZE'

    Start-Sleep -s 4


}

