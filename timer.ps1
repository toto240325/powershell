<#
!!!!!!!! powershell get-content -tail 10 -wait d:\temp\error.log
this app allows a given application to run for some time and then forces it to minimize its window

#>


[CmdletBinding()]
Param(
)
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class UserWindows {
[DllImport("user32.dll")]
public static extern IntPtr GetForegroundWindow();
}
"@

$datetime = get-date -format "yyyy-MM-dd-HH-mm-ss"
$outfile = $outputFolder + "test-$datetime-$mainWindowHandle.csv"
write-host "$datetime starting..."



<#
    [void][system.reflection.Assembly]::LoadWithPartialName("MySql.Data")
    $ConnStr = server=localhost;uid=root;password=Toto!;database=mysql;Port=3306
    $ObjMysql = New-Object MySql.Data.MySqlClient.MySqlConnection($ConnStr)
    $ObjMysql | Get-Member
    $ObjMysql
    $ObjMysql.Open()
    $req = "SELECT * FROM user"
    $SQLCommand = New-Object MySql.Data.MySqlClient.MySqlCommand($req,$ObjMysql)
    $MySQLDataAdaptater = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($SQLCommand)
    $MySQLDataSet = New-Object System.Data.DataSet 
    $RecordCount = $MySQLDataAdaptater.Fill($MySQLDataSet)
    $RecordCount
    $MySQLDataSet.Tables
    $MySQLDataSet.Tables.user
    $ObjMysql.close()
    
    
    
    CREATE TABLE `fgw` (
    `fgw_id` int(11) NOT NULL AUTO_INCREMENT,
    `fgw_time` datetime DEFAULT NULL,
    `fgw_host` varchar(20) DEFAULT NULL,
    `fgw_title` varchar(255) DEFAULT NULL,
    `fgw_cpu` float DEFAULT NULL,
    `fgw_duration` int DEFAULT NULL,
    PRIMARY KEY (`fgw_id`)
    ) ENGINE=InnoDB AUTO_INCREMENT=0;
    
    
#>
#------------------------------------------------------------------------------------
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
        foreach ($process in $InputObject) {
            write-host "test 33 : " $process.MainWindowTitle
            $Win32ShowWindowAsync::ShowWindowAsync($process.MainWindowHandle, $WindowStates[$Style]) | Out-Null
            #Write-Verbose ("Set Window Style '{1}' on '{0}'" -f $MainWindowHandle, $Style)
        }
    }
}

function log_error($errorMsg) {
    $errorMsg | out-file -append -filepath $errorFile
}


function minimizeCurrentWindow {
    $text = ""
    $text = $text + "++++++++++++++++++++++++++++++++++++++++++++++`n" 
    $text = $text + "`n"
    $text = $text + "`n"
    $text = $text + "`n"
    $text = $text + "`n"
    $text = $text + "`n"
    $text = $text + "`n"
    $text = $text + "`n"
    $text = $text + "`n"
    $text = $text + "`n"
    $text = $text + "`n"
    $text = $text + "`n"
    $text = $text + "`n"
    $text = $text + "`n"
    $text = $text + "`n"
    $text = $text + "`n"
    $text = $text + "`n"
    $text = $text + "            Bien essay" + [convert]::ToChar(233) + " !`n"
    $text = $text + "            Je te conseille de fermer`n"
    $text = $text + "            cet cran rapidos !! ;-)`n"
    $text = $text + "`n"
    $text = $text + "`n"
    $text = $text + "`n"
    $text = $text + "`n"
    $text = $text + "`n"
    $text = $text + "`n"
    $text = $text + "`n"
    $text = $text + "`n"
    $text = $text + "`n"
    $text = $text + "`n"
    $text = $text + "`n"
    $text = $text + "`n"
    $text = $text + "`n"
    $text = $text + "`n"
    $text = $text + "`n"
    $text = $text + "`n"
    $text = $text + "`n"
    $text = $text + "++++++++++++++++++++++++++++++++++++++++++++++`n" 
         

    Set-WindowStyle $Process 'MINIMIZE'
        
    #[System.Reflection.Assembly]::LoadWithPartialName(System.Windows.Forms)
    #[Windows.Forms.MessageBox]::Show($text, "ALERTE AU FILOU !!!!!", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
        
    $nSecs = 2
    $wshell.Popup($text, $nSecs, "ALERTE AU FILOU !!!!!", 0x30)
        
    log_error($errorMsg = "$($datetime) - Alerte filou !!!!" )
    #$errorMsg = "$($datetime) - Alerte filou !!!!" 
    #$errorMsg | out-file -append -filepath $errorFile
        
    $a = Get-Random -Minimum 2 -Maximum 6
    For ($i = 1; $i -le $a; $i++) {
        Set-WindowStyle $Process 'MINIMIZE'
        Start-Sleep -s 2
    }    
}


function mainJob() {
    
    <#
    #making the script window invisible
    Add-Type -Name win -MemberDefinition '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);' -Namespace native
    
    
    $p = [System.Diagnostics.Process]::GetCurrentProcess() | Get-Process
    $mainWindowHandle = $p.MainWindowHandle
    #write-host "mainWindowHandle : " $mainWindowHandle
    #Start-Sleep -s 3
    
    if ($start_invisible) {
        [native.win]::ShowWindow($mainWindowHandle, 0) # 0 : hide window 
    }
    else {
        [native.win]::ShowWindow($mainWindowHandle, 5) # 5: display window        
    }

    #>

    $datetime = get-date -format "yyyy-MM-dd-HH-mm-ss"
    $outfile = $outputFolder + "test-$datetime-$mainWindowHandle.csv"
    $hostStr = $env:computername;
    #write-host "outfile : " $outfile
    
    $wshell = New-Object -ComObject Wscript.Shell
    
    
    $i = 0
    $allWindowsTitles = @()
    
    "dateTime`tcpu`ttitle`tdelay" > $outfile
    $prevTitle = $null
    #while($i -ne 10000)
    $iterationNb = 0;

        
    # in case the old renamed file exist, delete it (otherwise, problems later when rename another file to it)
    Remove-Item -FilePath '$forbiddenFile'

    $extraTime = 5
    $nbSecAllowed = 20 # 60 * 5
    $nbSecElapsed = 0
    while ($nbSecElapsed -lt ($nbSecAllowed + $extraTime)) {

        #re-read the params file every refreshParamsRate iteration
        $iterationNb += 1;
        $iterationNb %= $refreshParamsRate;
        if ($iterationNb -eq 0) {
            . "$PSScriptRoot\params.ps1"
            $myMsg = "$($datetime) - reading params file !!!!" 
            #$myMsg | out-file -append -filepath $errorFile
            write-host $myMsg
        }
        
        try {
            # get info on process currently executing the foreground window
            $ActiveHandle = [userWindows]::GetForegroundWindow()
            $Process = Get-Process | Where-Object {$_.MainWindowHandle -eq $activeHandle}
            
            #check if this is a real process or a system (?) process
            $title = ""
            if ($Process) { 
                $title = $Process.MainWindowTitle.trim() 
            }
            if ($title -ne "") {
                #write-host "test : ---"      $title     "+++"
                #$cpu = $Process.TotalProcessorTime.TotalSeconds
                #write-host "cpu : " + $cpu
                # let's reset the CPU counter if the title of main windows changed
                #if ($title -ne $prevTitle) { $prevCpu = $cpu } 
                #$deltaCpu = $cpu - $prevCpu
                #$Process | Select ProcessName, @{Name="AppTitle";Expression= {($_.MainWindowTitle)}}
                #write-host "test1.2"
                #$Process | select ProcessName
                #$Process | Select @{Name="AppTitle";Expression= {($_.MainWindowTitle)}}
                #write-host "test1.3"
            } 
            else {
                #write-host "title is empty"
                #$title = ""
                #$cpu = 0
                #$deltaCpu = 0
            }      
            
            $prevTitle = $title
            #$prevCpu = $cpu
        }
        catch {
            $errorMsg = "$($datetime) - test Failed xxx to get active Window details. More Info: $($_)" 
            $errorMsg | out-file -append -filepath $errorFile
            Write-host $errorMsg
            Start-Sleep -s 5
        }
        
        
        #$allWindowsTitles +=$title
        $dateTime = Get-Date
        
        #$Process | select ProcessName
        $maxlen = 30
        


        $titleFound = 0
        foreach ($t in $titlesToCheck) {
            #write-host "result of test for $t : " ($t -match $title)
            if ($title -match $t) { 
                $titleFound = 1 
                write-host "titleFound title !"
            }
        }

        
        #if (($title -eq $titlesToCheck) -and ((get-date).date -le ($forbiddenUntilAndIncluded).date)) {
        #if ($titleFound) {
        #$forbiddenUntilAndIncluded = "12/12/2016"
        #write-host (get-date).Date
        #write-host $forbiddenUntilAndIncluded
        #write-host ($forbiddenUntilAndIncluded).Date
        #write-host "cond 1 : " ((get-date).Date -le (get-date $forbiddenUntilAndIncluded).Date)
        
        #$stillInForbiddenPeriod = ((get-date).Date -le (get-date $forbiddenUntilAndIncluded).Date)
        #$forbiddenFileFound = (Test-Path $forbiddenFile)
        
        #write-host "cond 2 : " ($stillInForbiddenPeriod -or $forbiddenFileFound)
        #write-host "cond 3 : "($titleFound) 
		
        #if ($titleFound) -and ($stillInForbiddenPeriod -or $forbiddenFileFound)) {
        
        <#
        if ($titleFound) {                                    
            $nbSecElapsed = $i * $delay
            if ($nbSecElapsed -ge $nbSecAllowed) {
                if ($nbSecElapsed -ge ($nbSecAllowed + $extra_time)) {
                    minimizeCurrentWindow
                }
                else {
                    [console]::beep(500, 300)
                }   
            }
        }
        #>

                    
        Start-Sleep -s $delay
        $i++   
        $nbSecElapsed += $delay
    }
    # prevent further use of the forbidden app until further notice
    Out-File -FilePath '$forbiddenFile'
    
}

#--------------------------------------------------------------------
#------------- START ------------------------------------------------
#--------------------------------------------------------------------

write-host "current host : " $env:computername
$titlesToCheck = "(none)"
$forbiddenFile = "(none)"
#getting public and restricted parameters $user, $pass, $database, $mySqlhost, etc
. "$PSScriptRoot\params.ps1"


$dateTime = Get-Date
$errorFile = $outputFolder + "error_timer.log"
write-host "error file : " + $errorFile
$errorMsg = "host : $($env:computername)" 
$errorMsg | out-file -append -filepath $errorFile
$errorMsg = "$($datetime) - just checking that the error file is properly collecting errors..." 
$errorMsg | out-file -append -filepath $errorFile
#write-host "the error file is " $errorFile
#write-host $errorMsg

# Obtain a system mutex that prevents more than one deployment taking place at the same time.
[System.Threading.Mutex]$mutant;
try {
    [bool]$wasCreated = $false;
    $mutant = New-Object System.Threading.Mutex($true, "MyMutexGetTimer", [ref] $wasCreated);        
    if ($wasCreated) {            
        mainJob;
    }
    else {
        write-host "MyMutxGetTimer already requested"
        #just exit if there is already a script running
        write-host "Script is already running, so I exit"
        Start-Sleep -s 5
        # or wait for the mutex to be released :
        #$mutant.WaitOne();
    }
}
catch {
    $datetime = get-date -format "yyyy-MM-dd-HH-mm-ss"
    $errorMsg = "$($datetime) - Error during initial code. More Info: $($_)" 
    $errorMsg | out-file -append -filepath $errorFile
    Write-host $errorMsg
} 
finally {       
    if ($wasCreated) {
        $mutant.ReleaseMutex(); 
        $mutant.Dispose();
    }

    $datetime = get-date -format "yyyy-MM-dd-HH-mm-ss"
    $errorMsg = "$($datetime) - excuting the 'finally' in initial code. More Info: $($_)" 
    $errorMsg | out-file -append -filepath $errorFile
}

