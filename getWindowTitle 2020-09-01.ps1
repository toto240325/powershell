<#
!!!!!!!! powershell get-content -tail 10 -wait \\192.168.0.2\d\temp\error.log

to check : 
$VerbosePreference = “Continue”
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



$datetime = get-date -format "yyyy-MM-dd-HH-mm-ss"
$outfile = $outputFolder + "test-$datetime-$mainWindowHandle.csv"
write-host "$datetime starting..."

$global:wasCreated

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

if ($env:computername -eq "L02DI1453375DIT") {
    $File = "C:\mydata\mytemp\b.txt"		
    $filenameAndPath = $File
}
elseif ($env:computername -eq "HP2560") {
    $File = "d:\temp\a.txt"
}
elseif ($env:computername -eq "MYPC3") {
    $File = "d:\temp\d.txt"
    $filenameAndPath = "d:\temp\att.txt"
}
else {
    $File = "d:\temp\a.txt"
    $filenameAndPath = "d:\temp\att.txt"
}	
function sendMail($emailTo, $subject, $body) {

    $mailerUser = "mailer240325@gmail.com"
    $mailerPw = "Mailer060502!h"

    $secpasswd = ConvertTo-SecureString $mailerPw -AsPlainText -Force
    $cred = New-Object -TypeName System.Management.Automation.PSCredential($mailerUser, $secpasswd)

    $EmailFrom = "mailer240325@gmail.com"
    $SMTPServer = "smtp.gmail.com" 
    $SMTPMessage = New-Object System.Net.Mail.MailMessage($emailFrom, $emailTo, $subject, $body)
    $attachment = New-Object System.Net.Mail.Attachment($filenameAndPath)
    $SMTPMessage.Attachments.Add($attachment)
    $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587) 
    $SMTPClient.EnableSsl = $true 
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential($cred.UserName, $cred.Password); 
    $SMTPClient.Send($SMTPMessage)
    $attachment.dispose()
}	

#sendMail "eric.derruine@gmail.com" "this is a test 4" "this is the body"


#------------------------------------------------------------------------------------
function ConnectMySQL([string]$user, [string]$pass, [string]$MySQLHost, [string]$database) {
    # Load MySQL .NET Connector Objects
    [void][system.reflection.Assembly]::LoadWithPartialName("MySql.Data")

    # Open Connection
    $connStr = "server=" + $MySQLHost + ";port=3306;uid=" + $user + ";pwd=" + $pass + ";database=" + $database + ";Pooling=FALSE"
    $conn = New-Object MySql.Data.MySqlClient.MySqlConnection($connStr)

    $Error.Clear()
    try {
        $conn.Open()
    }
    catch {
        write-warning ("Could not open a connection to Database $database on Host $MySQLHost. Error: " + $Error[0].ToString())
        Start-Sleep -s 5
    }
    $cmd = New-Object MySql.Data.MySqlClient.MySqlCommand("USE $database", $conn)
    return $conn
}
#------------------------------------------------------------------------------------
function myQuery($conn) {

    # Get an instance of what all objects need for a SELECT query : the Command object
    $oMYSQLCommand = New-Object MySql.Data.MySqlClient.MySqlCommand
    # DataAdapter Object
    $oMYSQLDataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter
    # And the DataSet Object
    $oMYSQLDataSet = New-Object System.Data.DataSet
    # Assign the established MySQL connection
    $oMYSQLCommand.Connection = $conn
    # Define a SELECT query
    $oMYSQLCommand.CommandText = 'SELECT fgw_id,fgw_time,fgw_host,fgw_title,fgw_cpu from fgw order by fgw_id desc limit 10'
    $oMYSQLDataAdapter.SelectCommand = $oMYSQLCommand
    # Execute the query
    #$iNumberOfDataSets = $oMYSQLDataAdapter.Fill($oMYSQLDataSet, "data")
    $oMYSQLDataAdapter.Fill($oMYSQLDataSet, "data")

    foreach ($oDataSet in $oMYSQLDataSet.tables[0]) {
        write-host "ID:" $oDataSet.fgw_ID "time:" $oDataSet.fgw_time "host:" $oDataSet.fgw_host "Title:" $oDataSet.fgw_title "CPU:" $oDataSet.fgw_cpu
    }
}
#------------------------------------------------------------------------------------
function WriteMySQLQuery($conn, [string]$query) {

    $command = $conn.CreateCommand()
    $command.CommandText = $query
    $RowsInserted = $command.ExecuteNonQuery()
    $command.Dispose()
    if ($RowsInserted) {
        return $RowsInserted
    }
    else {
        return $false
    }
}
#------------------------------------------------------------------------------------
function myInsert_obsolete($conn, $dateStr, $hostStr, $title, $cpu, $duration) {
    $query = 'insert into fgw (fgw_time,fgw_host,fgw_title,fgw_cpu,fgw_duration) values ("' + $dateStr + '","' + $hostStr + '","' + $title + '",' + $cpu + ',' + $duration + ')'

    $command = $conn.CreateCommand()
    $command.CommandText = $query
    $RowsInserted = $command.ExecuteNonQuery()
    $command.Dispose()
    if ($RowsInserted) {
        return $RowsInserted
    }
    else {
        return $false
    }
}
#------------------------------------------------------------------------------------�
function myInsert2($conn, $dateStr, $hostStr, $title, $cpu, $duration, $isGame) {

    $oMYSQLCommand = New-Object MySql.Data.MySqlClient.MySqlCommand
    $oMYSQLCommand.Connection = $conn
    $oMYSQLCommand.CommandText = '
    INSERT into fgw (fgw_time,fgw_host,fgw_title,fgw_cpu,fgw_duration,fgw_isgame) values (@time,@host,@title,@cpu,@duration,@isGame)'
    $oMYSQLCommand.Prepare()
    $oMySqlCommand.Parameters.AddWithValue("@time", $dateStr)
    $oMySqlCommand.Parameters.AddWithValue("@host", $hostStr)
    $oMySqlCommand.Parameters.AddWithValue("@title", $title)
    $oMySqlCommand.Parameters.AddWithValue("@cpu", $cpu)
    $oMySqlCommand.Parameters.AddWithValue("@duration", $duration)
    $oMySqlCommand.Parameters.AddWithValue("@isGame", $isGame)
    $iRowsInsert = $oMySqlCommand.ExecuteNonQuery()
    return $iRowsInsert
}
#------------------------------------------------------------------------------------�
function myUpdate($conn, $dateStr, $hostStr, $title, $cpu) {

    $oMYSQLCommand = New-Object MySql.Data.MySqlClient.MySqlCommand
    $oMYSQLCommand.Connection = $conn
    $oMYSQLCommand.CommandText =
    'UPDATE fgw myFgw SET fgw_cpu = 100 where myFgw.fgw_ID = 1234 and myFgw.fgw_title = "test"'
    #$iRowsAffected = $oMYSQLCommand.executeNonQuery()
    $oMYSQLCommand.executeNonQuery()

}
#------------------------------------------------------------------------------------�
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

<#
%
%   This page describes the difference between these states:
%
%   <http://msdn.microsoft.com/library/en-us/winui/winui/windowsuserinterface/windowing/windows/windowreference/windowfunctions/showwindow.asp>
%
%   FORCEMINIMIZE Windows 2000/XP: Minimizes a window, even if the thread that
%   owns the window is hung. This flag should only be used when minimizing
%   windows from a different thread.
% 
%   HIDE Hides the window and activates another window.
% 
%   MAXIMIZE Maximizes the specified window.
% 
%   MINIMIZE Minimizes the specified window and activates the next top-level
%   window in the Z order.
% 
%   RESTORE Activates and displays the window. If the window is minimized or
%   maximized, the system restores it to its original size and position. An
%   application should specify this flag when restoring a minimized window.
% 
%   SHOW Activates the window and displays it in its current size and position. 
% 
%   SHOWDEFAULT Sets the show state based on the SW_ value specified in the
%   STARTUPINFO structure passed to the CreateProcess function by the program
%   that started the application. 
% 
%   SHOWMAXIMIZED Activates the window and displays it as a maximized window.
% 
%   SHOWMINIMIZED Activates the window and displays it as a minimized window.
% 
%   SHOWMINNOACTIVE Displays the window as a minimized window. This value is
%   similar to SW_SHOWMINIMIZED, except the window is not activated.
% 
%   SHOWNA Displays the window in its current size and position. This value is
%   similar to SW_SHOW, except the window is not activated.
% 
%   SHOWNOACTIVATE Displays a window in its most recent size and position. This
%   value is similar to SW_SHOWNORMAL, except the window is not actived.
% 
%   SHOWNORMAL Activates and displays a window. If the window is minimized or
%   maximized, the system restores it to its original size and position. An
%   application should specify this flag when displaying the window for the
%   first time.
%#>

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


function debug($msg) {
    if ($debug) { write-host $msg }
}

function logError($errorMsg) {
    $errorMsgfull = $datetime + " " + $errorMsg
    write-host $errorMsgfull
    $errorMsgfull | out-file -append -filepath $errorFile
}

function isServerAlive($webserver) {
    $amIAlive = $false
    try {
        $url = "http://" + $webserver + "/monitor/isServerAlive.php"
        $res = Invoke-RestMethod -Uri $url

        #write-host "res = ->" $res.result "<-" -ForegroundColor red
        if ($res.result -eq "YES" ) {
            $amIAlive = $true 
        }
        else {
            # this should never happen !!!!
            $errorMsg = "$($datetime) - Server $webserver does seem to be alive, but it returned an exepected reply !?" 
            $errorMsg | out-file -append -filepath $errorFile
            Write-host "----------" $errorMsg -ForegroundColor Red
        }
    }
    catch {
        $errorMsg = "$($datetime) - Server $webserver doesn't seem to be alive. More Info: $($_)" 
        $errorMsg | out-file -append -filepath $errorFile
        Write-host "----------" $errorMsg -ForegroundColor Red
    }
            
    return $amIAlive
}


function isBlacklisted($title) {

    $atLeastOneTitleBlacklisted = $false
    foreach ($kw in $keywords) {
        try {
            $blackListed = ($title -match $kw)
        }
        catch {
            write-host "error when evaluating expression (blacklist)"
        }

        #write-host "result of blacklisted check for $kw : $blackListed"

        # then white list (if a blacklilsted keyword has been found) :
        if ($blackListed) {

            $whitelistKWfound = $false
            foreach ($kwWL in $keywordsWL) {
                
                $resultWL = $false
                try {
                    $resultWL = ($title -match $kwWL)
                }
                catch {
                    write-host "error when evaluating expression"
                }
                if ($resultWL) {
                    $whitelistKWfound = $true
                }
                #write-host "whitelist checking result : $resultWL"
            }
            # if a WhiteList kw was found, then we consider we haven't found a suspect window title
            if ($whitelistKWfound) {
                $blackListed = $false
                #$whitelistKW = $kwWL
                #write-host "whitelistKW found : $whitelistKW"
            }
        }
        #write-host "results after blacklist and whitelist : $blackListed"

        #write-host "result of test for $kw : " $blackListed
        
        if ($blackListed) { 
            $atLeastOneTitleBlacklisted = $true
            #$titleTxt = $title
            $errorMsg1 = "$($datetime) - Title Found : "
            $errorMsg2 = "$title"
            $errorMsg3 = " with kw : "
            $errorMsg4 = "$kw" 
            $errorMsg1 + $errorMsg2 + $errorMsg3 + $errorMsg4 | out-file -append -filepath $errorFile
            Write-host $errorMsg1 -NoNewline
            Write-host $errorMsg2 -NoNewline -ForegroundColor Red
            Write-host $errorMsg3 -NoNewline
            Write-host $errorMsg4 -ForegroundColor Red
        }
    }
    return $atLeastOneTitleBlacklisted
}

function Show-Process($process, [Switch]$Maximize)
{

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


    $sig = '
    [DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern int SetForegroundWindow(IntPtr hwnd);
  '
  
  if ($Maximize) { $Mode = 3 } else { $Mode = 5 }
  $type = Add-Type -MemberDefinition $sig -Name WindowAPI -PassThru
  $hwnd = $process.MainWindowHandle
  $null = $type::ShowWindowAsync($hwnd, $Mode)
  $null = $type::SetForegroundWindow($hwnd) 
}


function minimizeAllVisibleNotAllowedWindows{
    $visibleProceses = Get-Process | Where-Object { $_.MainWindowHandle -ne 0 }
    logError("starting to check for visible windows to be minimized * * * * * * * * * * * * * * * * * *")
    foreach ($p in $visibleProceses) {
        $title = $p.MainWindowTitle.trim() 
        #write-host "*****************", $p.ProcessName, $title, $p.id
        if (isBlacklisted($title,$p.id)) {
            logError("minimizing visible window: $title")
            Set-WindowStyle $p 'MINIMIZE'
        }

    }
}


function mainJob() {

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

    <#
    if ($env:computername -eq "L02DI1453375DIT") {
        #[native.win]::ShowWindow($mainWindowHandle,0)
    }
    elseif ($env:computername -eq "H171412649") {
        #[native.win]::ShowWindow($mainWindowHandle,0)
    }
    elseif ($env:computername -eq "MYPC3") {
        #$tmp=[native.win]::ShowWindow($mainWindowHandle,5) # 5: display window 
        $tmp = [native.win]::ShowWindow($mainWindowHandle, 0) # 0: hide window
    }
#>
    
    #to make the script window visible again
    #   powershell_ise
    #   Add-Type -Name win -MemberDefinition '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);' -Namespace native
    #   #get the mainWindowHandle in the Excel filename !
    #   [native.win]::ShowWindow(464782,5)

    $datetime = get-date -format "yyyy-MM-dd-HH-mm-ss"
    $outfile = $outputFolder + "test-$datetime-$mainWindowHandle.csv"
    $hostStr = $env:computername;
    #write-host "outfile : " $outfile
    
    #$wshell = New-Object -ComObject Wscript.Shell
    
    # Connect to MySQL Database
    $conn = ConnectMySQL $user $pass $MySQLHost $database
    
    #$query = 'insert into fgw (fgw_time,fgw_title,fgw_cpu) values ("2016-08-01 00:00:05","window title", 1000)'
    #$Rows = WriteMySQLQuery $conn $query
    #Write-Host $Rows " inserted into database"
    
    #myQuery($conn)
    
    $i = 0
    $allWindowsTitles = @()
    
    "dateTime`tcpu`ttitle`tdelay" > $outfile
    $prevTitle = $null
    #while($i -ne 10000)
    
    # reading the params file for the first time
    $myMsg2 = "$($datetime) - reading params file !!!! iterationNb = $iterationNb" 
    logError($myMsg2)
    . "$PSScriptRoot\params.ps1"

    
    #checking if the webserver is alive
    $msg = isServerAlive($webserver)
    write-host "is the server $webserver alive : " $msg  -Foregroundcolor red 
    
    $iterationNb = -1;
    while ($true) {
        $iterationNb += 1;
        $iterationNb %= $refreshParamsRate;
        write-host ""
        write-host ""
        write-host ""
        write-host "-----------------------------------------" $iterationNb
        #write-host "$($datetime) - start iteration"
 
        #re-read the params file every refreshParamsRate iteration
        if ($iterationNb -eq 0) {
            $myMsg2 = "$($datetime) - reading params file !!!! iterationNb = $iterationNb" 
            . "$PSScriptRoot\params.ps1"
            #Start-Sleep -s 1
            logError($myMsg2)
            #write-host $myMsg            
            # also reading the file indicating whether the code of this script has been changed and must be reloaded
            # (it's in another file than the main params file in order to be able to reset it easily)
            . "$PSScriptRoot\params reload.ps1"
            # if I find a request to reload in the param file, I call myself (whose code probably has been updated in the meantime) and exit
            write-host "reload from params : " $reload
            if ($reload) {
                #reinitialise the $reload param to $false to avoid a perpetual reloading
                $dollar = '$'
                $myline = $dollar + "reload = " + $dollar + "false"
                #write-host "myline : $myline"
                $myline | out-file -filepath "$PSScriptRoot\params reload.ps1"
                #write-host "params reload reinitialised"
                
                # need to disable the mutex before being able to relaunch another instance
                if ($global:wasCreated) {
                    $mutant.ReleaseMutex(); 
                    $mutant.Dispose();
                    #write-host "mutex released"
                }
                #write-host "command : " $PSCommandPath
                invoke-expression -Command $PSCommandPath
                Start-Sleep -s 1
                exit 
            }
        }

        #>
        
        # note that some params have just been reloaded from the params file and will be 
        # overwritten with the values found on the server (if the server is up)

        try {

            # determining if we are in a grace period, i.e. if isMagicEnabled is true 
            if ($iterationNb -eq 0) {
                $url = "http://" + $webserver + "/monitor/magic.php?isMagicEnabled"
                #$myMsg = "$($datetime) - calling $url" 
                #$myMsg | out-file -append -filepath $errorFile
                #write-host $myMsg
                $res = Invoke-RestMethod -Uri $url
                if ($res.isMagicEnabled -eq 1 ) {
                    $isMagicEnabled = $true 
                }
                else {
                    $isMagicEnabled = $false
                }

                $errMsg = $res.errMsg
                #$myMsg = "$($datetime) - keywords found in DB : " + $keywords + " errMsg : " + $errMsg 
                #$myMsg | out-file -append -filepath $errorFile
                #debug $myMsg
            }

            # getting the keywords to check in the titles 
            if ($iterationNb -eq 0) {
                $url = "http://" + $webserver + "/monitor/getKeywords.php"
                $myMsg = "$($datetime) - calling $url" 
                $myMsg | out-file -append -filepath $errorFile
                #write-host $myMsg
                $res = Invoke-RestMethod -Uri $url
                $keywords = $res.keywords
                $errMsg = $res.errMsg
                $myMsg = "$($datetime) - keywords found in DB : " + $keywords + " errMsg : " + $errMsg 
                $myMsg | out-file -append -filepath $errorFile
                #debug $myMsg
            }

            # getting the keywords for the whilelist
            if ($iterationNb -eq 0) {
                $url = "http://" + $webserver + "/monitor/getKeywordsWL.php"
                $myMsg = "$($datetime) - calling $url" 
                $myMsg | out-file -append -filepath $errorFile
                #write-host $myMsg
                $res = Invoke-RestMethod -Uri $url
                $keywordsWL = $res.keywords
                $errMsg = $res.errMsg
                $myMsg = "$($datetime) - keywords found in DB : " + $keywords + " errMsg : " + $errMsg 
                $myMsg | out-file -append -filepath $errorFile
                #debug $myMsg
            }

            # checking homw much time has already been played today
            if ($iterationNb -eq 0) {
                $duration = 0
                $url = "http://" + $webserver + "/monitor/getTimePlayedToday.php"
                $myMsg = "$($datetime) - calling $url" 
                $myMsg | out-file -append -filepath $errorFile
                #write-host $myMsg
                $res = Invoke-RestMethod -Uri $url
                #write-host "time played today "
                debug "res : $res"
                #write-host "time played today " $res.timePlayedToday
                $timePlayedToday = $res.timePlayedToday
                $myMsg = "$($datetime) - time already played today : $timePlayedToday" 
                $myMsg | out-file -append -filepath $errorFile
                debug $myMsg
            }


            # checking how much time could exceptionally be played today
            if ($iterationNb -eq 0) {
                $duration = 0
                $url = "http://" + $webserver + "/monitor/getGameTimeExceptionallyAllowedToday.php"
                if ($debug) { $myMsg = "$($datetime) - calling $url" }
                $myMsg | out-file -append -filepath $errorFile
                #write-host $myMsg
                $res = Invoke-RestMethod -Uri $url
                $gameTimeExceptionallyAllowedToday = [int]$res.gameTimeExceptionallyAllowedToday
                $gameTimeAllowedDaily = [int]$res.gameTimeAllowedDaily
                $myMsg = "$($datetime) - time exceptionally allowed today : $gameTimeExceptionallyAllowedToday   gameTimeAllowedDaily : $gameTimeAllowedDaily" 
                $myMsg | out-file -append -filepath $errorFile
                #write-host $myMsg
            }

            debug "get info process"
            write-host "-----------------------" -ForegroundColor red

            # get info on process currently executing the foreground window
            $ActiveHandle = [userWindows]::GetForegroundWindow()
            #$process = Get-Process | Where-Object { $_.MainWindowHandle -eq $activeHandle }
            # at this point $process is a process that might be the one owning the active window, or it could be something
            # so let's find the real process owner of the whole thread

            #write-host $process.processname,$process.MainWindowTitle
            #$HWND = [Win32Api]::FindWindow( "OpusApp", $caption )
            #$HWND = $activeHandle
        
            $myPid = [IntPtr]::Zero
            [Win32Api]::GetWindowThreadProcessId( $activeHandle, [ref] $myPid ) | out-null
            #"test 1 : process.processName : " + $process.processName + "     process.ID " +  $process.id | write-host
            #"PID=" + $myPid | write-host 
        
            $process = Get-Process | Where-Object { $_.id -eq $myPid }
            #"test 2 : process.processName : " + $process.processName + "     process.ID " +  $process.id | write-host
            write-host "------------------"
            # at this point, we have the right process and we can ask it to reactive it's main window (and to let the 
            # context menu disappear)
            show-process $process 'SHOW'

            $ActiveHandle = [userWindows]::GetForegroundWindow()
            $process = Get-Process | Where-Object { $_.MainWindowHandle -eq $activeHandle }
        
            #check if this is a real process or a system (?) process
            $title = ""
            if ($process) { 
                $title = $process.MainWindowTitle.trim() 
            }
                
            if ($title -ne "") {
                logError("current window title : ---" + $title + "+++")
                $cpu = $process.TotalProcessorTime.TotalSeconds
                $proc_id = $process.id
                #write-host "cpu : " + $cpu + " proc_id : " + $proc_id
                # let's reset the CPU counter if the title of main windows changed
                if ($title -ne $prevTitle) { $prevCpu = $cpu } 
                $deltaCpu = $cpu - $prevCpu
                #$process | Select ProcessName, @{Name="AppTitle";Expression= {($_.MainWindowTitle)}}
                #$process | select ProcessName
                #$process | Select @{Name="AppTitle";Expression= {($_.MainWindowTitle)}}
            } 
            else {
                write-host "title is empty"
                $title = ""
                $cpu = 0
                $deltaCpu = 0

                <#
                logError("current window title is empty, so make sure all chrome processes are make invisible")
                
                #make sure all chrome process are visible (i.e. the context menu is sent away if it had been activated)
                
                $myp = Get-Process | Where-Object { $_.processName -like "chrome*" }
                foreach ($p in $myp) {
                    $title = $p.MainWindowTitle.trim() 
                    $procName = $p.processName
                    write-host "*****************", $procName, $title, $p.id, $p.ProcessName, $p.MainWindowHandle, $p.MainWindowTitle
                    Show-Process -Process $p
                }

                #now that the context menu has been sent away, the normal minimize window should work
                $myp = Get-Process | Where-Object { $_.processName -like "chrome*" }
                foreach ($p in $myp) {
                    $title = $p.MainWindowTitle.trim() 
                    $procName = $p.processName
                    write-host "*****************", $procName, $title, $p.id, $p.ProcessName, $p.MainWindowHandle, $p.MainWindowTitle
                    Set-WindowStyle $p 'MINIMIZE'
                }
                   
                #>
                
            }      
            
            $prevTitle = $title
            $prevCpu = $cpu
        }
        catch {

            $errorMsg = "$($datetime) - test Failed xxx to get active Window details. More Info: $($_)" 
            $errorMsg | out-file -append -filepath $errorFile
            Write-host "----------" $errorMsg -ForegroundColor Red

            # why was this ever coded ??
            # Start-Sleep -s 5
        }
                

<#
seems this functionality has been implemented better in another part of the code.  I had forgotten about that...

        # check if there are processes that we want to run either in the foreground or minimized (to avoid cheating by 
        # by having VLC or chrome running normally but slightly overlapped by another window (in the foreground) 
        # in order to not be monitored by the this script)

        $VLCprocess = Get-Process | Where {$_.ProcessName -Like "vlc*"}
        if ($VLCprocess) {
            #$vlctitle = $process.MainWindowTitle.trim() 
            $VLChandle = $process.MainWindowHandle 
        
            #write-host "foreground win : " $ActiveHandle "($fgtitle)"
            #write-host "VLC window :     " $VLChandle    "($vlctitle)"  
            if ($ActiveHandle -ne $VLChandle) {
                #write-host "minimizing VLC window"
                #Set-WindowStyle $VLCprocess 'MAXIMIZE'
                #Set-WindowStyle $VLCprocess 'MINIMIZE'
            } else {
                #write-host "no action because VLC in foreground"
            }
        }   
#>  

        #logError("keywords : " + $keywords)
        #logError("keywordsWL : " + $keywordsWL)
        

        #$allWindowsTitles +=$title
        $datetime = get-date -format "yyyy-MM-dd HH-mm-ss"
        
        #$process | select ProcessName
        $maxlen = 30
        
        # getting window title and storing it in a CSV file
        try {
            $line = ""
            $line = $line + " {0}" -f $dateTime
            $line = $line + "`t {0, 10}" -f $cpu.tostring("0.000") 
            $line = $line + "`t {0}" -f $deltaCpu.tostring("0.00")
            $line = $line + "`t {0, -25}" -f ($title.padright($maxlen + 1)).remove($maxlen)
            $line = $line + "`t {0, 5}" -f $delay
            $line | Out-File $outfile -Append
            write-host $line
        } 
        catch {
            $errorMsg = "$($datetime) - Error when formatting. More Info: $($_)" 
            $errorMsg | out-file -append -filepath $errorFile
            Write-host $errorMsg
        } 

        #$isChrome = ($title -match "Google Chrome")

        #write-host "titlesToCheck : " $titlesToCheck

        $titleFound = $false
       
        #$keywordsWL = ("one", "two", "ISE")

        #write-host $keywords
        #write-host $keywordsWL

        $titleBlacklisted = isBlacklisted($title,$pid) 
        write-host "title is blacklisted : " $titleBlacklisted "  pid : " $pid
 
        # storing window title in database
        try {
            $datetime = get-date -format "yyyy-MM-dd HH-mm-ss.fff"

            # $dateStr = $dateTime.ToString("yyyy-MM-dd HH:mm:ss.fff")
            if ($conn.state -eq "Open") {
                #write-host "conn is open"
            }
            else {
                #write-host "conn is not open"
                $conn = ConnectMySQL $user $pass $MySQLHost $database
            }
            $iRowsInsert = myInsert2 $conn $datetime $hostStr $title $cpu $delay $titleBlacklisted
        }
        catch {
            $errorMsg = "$($datetime) - 101 Error when storing in database. More Info: $($_)" 
            $errorMsg | out-file -append -filepath $errorFile
            Write-host $errorMsg
        } 

        #if (($title -eq $titlesToCheck) -and ((get-date).date -le ($forbiddenUntilAndIncluded).date)) {
        #if ($titleFound) {
        #$forbiddenUntilAndIncluded = "12/12/2016"
        #write-host (get-date).Date
        #write-host $forbiddenUntilAndIncluded
        #write-host ($forbiddenUntilAndIncluded).Date
        #write-host "cond 1 : " ((get-date).Date -le (get-date $forbiddenUntilAndIncluded).Date)
        
        $stillInForbiddenPeriod = ((get-date).Date -le (get-date $forbiddenUntilAndIncluded).Date)
        $forbiddenFileFound = (Test-Path $forbiddenFile)
        $magicFileFound = (Test-Path $magicFile)
        $remainingTimeToPlay = $gameTimeExceptionallyAllowedToday + $gameTimeAllowedDaily - $timePlayedToday + 1
        if (!($magicFileFound) -and $titleFound -and ($remainingTimeToPlay -le 5) -and (!($remainingTimeToPlay -le 0))) {
            $nbBeeps = 3 - $remainingTimeToPlay
            for ($i = 1; $i -le $nbBeeps; $i++) {
                [console]::beep(2000, 500)
            }
        }
        
        <#
        logError("titleFound : $titleFound") 
        logError("isMagicEnabled : $isMagicEnabled")
        logError("magicFileFound : $magicFileFound")
        logError("remainingTimeToPlay -le 0 : " + ($remainingTimeToPlay -le 0))
        logError("stillInForbiddenPeriod: " + ($stillInForbiddenPeriod))
        logError("forbiddenFileFound: " + ($forbiddenFileFound))
        logError("timePlayedToday : $timePlayedToday")
        logError("gameTimeExceptionallyAllowedToday: $gameTimeExceptionallyAllowedToday")
        logError("gameTimeAllowedDaily: $gameTimeAllowedDaily")
        logError("total allowed : " + ($gameTimeAllowedDaily + $gameTimeExceptionallyAllowedToday))
        logError("remaining to play : $remainingTimeToPlay")
        logError("timePlayedToday -gt gameTimeExceptionallyAllowedToday: " + ($timePlayedToday -gt $gameTimeExceptionallyAllowedToday))
        #>
	
      
        #$isGamingForbidden = ($titleBlacklisted -and !($magicFileFound) -and ($remainingTimeToPlay -le 0) -and (($stillInForbiddenPeriod -or $forbiddenFileFound)) )
        #$isGamingForbidden = (!($magicFileFound) -and ($remainingTimeToPlay -le 0) -and (($stillInForbiddenPeriod -or $forbiddenFileFound)) )
        $isGamingForbidden = (!($isMagicEnabled) -and ($remainingTimeToPlay -le 0) -and (($stillInForbiddenPeriod -or $forbiddenFileFound)) )
        
        write-host "isGamingForbidden : $isGamingForbidden"
        
        if ($titleBlacklisted) {

            $errorMsg = "$($datetime) - "
            $errorMsg = $errorMsg + " stillInForbiddenPeriod : $stillInForbiddenPeriod `r`n"
            $errorMsg = $errorMsg + " forbiddenFileFound : $forbiddenFileFound `r`n"
            $errorMsg = $errorMsg + " magicFileFound : $magicFileFound `r`n"
            $errorMsg = $errorMsg + " remainingTimeToPlay : $remainingTimeToPlay `r`n"            
            $errorMsg = $errorMsg + " isGamingForbidden : $isGamingForbidden `r`n"
            $errorMsg | out-file -append -filepath $errorFile
            write-host $errorMsg
        }


        # if gaming is not allowed at this very moment...
        if ($isGamingForbidden) {
            $atLeastOneTitleFound = $false
            # if the top window contains the name of a game, pop-up the warning message and minimize the window
            if ($titleBlacklisted) {

                write-host "test after cond4"                     
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
                $text = $text + "            cet cran rapidos !! ; - )`n"
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
                $text = $text + "played : $timePlayedToday`n"
                $text = $text + "exceptionally allowed today : $timeAllowedToday`n"
                $text = $text + $titleTxt + "`n"
                $text = $text + "++++++++++++++++++++++++++++++++++++++++++++++`n" 
                

                Set-WindowStyle $process 'MINIMIZE'
                $atLeastOneTitleFound = $true
                        
                #[System.Reflection.Assembly]::LoadWithPartialName(System.Windows.Forms)
                #[Windows.Forms.MessageBox]::Show($text, "ALERTE AU FILOU !!!!!", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
                
                $nSecs = 3
                ##write-host "before popup"
                #$temp = $wshell.Popup($text, $nSecs, "ALERTE AU FILOU !!!!!", 0x30)
                ##write-host "after popup"

                logError("$($datetime) - Alerte filou !!!! $titleTxt" )
                #logError("$($datetime) - Alerte filou !!!!")
                #$errorMsg | out-file -append -filepath $errorFile

                <#
                $a = Get-Random -Minimum 1 -Maximum 2
                For ($i = 1; $i -le $a; $i++) {
                    Set-WindowStyle $process 'MINIMIZE'
                    Start-Sleep -s 2
                }
                #>
                #stop-process -force -id $proc_id 
            }
            # in any case (if we are in a period where it cannot be gamed, then minimize all the windows which contain in their title the name of a game, 
            # to avoid having the top windows just overlapping a little bit with a game/video window just behind ;-) )

            # for all the processes having a visible window, if the title contains a game keyword and gaming is not allowed, minimize the window
            #$visibleProceses = Get-Process | Where-Object {$_.MainWindowHandle -ne $activeHandle -and $_.MainWindowHandle -ne 0 }
            minimizeAllVisibleNotAllowedWindows

            write-host "atLeastOneTitleFound : $atLeastOneTitleFound"
            if ($atLeastOneTitleFound) {
                if ($delay -ge 2) { $delay -= 2 }
            }
            else {
                if ($delay -lt $maxDelay) { $delay += 1 }
            }
        }

        #else {
        # maximize window if 
        #if ($isChrome) {
        #    Set-WindowStyle $process 'MINIMIZE'
        #}
        Start-Sleep -s $delay
        #}
        $i ++
    }
}

#--------------------------------------------------------------------
#------------- START ------------------------------------------------
#--------------------------------------------------------------------

write-host "current host : " $env:computername
$titlesToCheck = "(none)"
$titlesToCheck = $titlesToCheck

$forbiddenFile = "(none)"
#getting public and restricted parameters $user, $pass, $database, $mySqlhost, etc
. "$PSScriptRoot\params.ps1"
. "$PSScriptRoot\params_restricted.ps1"

$delay = $maxDelay
#checking if I am the only occurence of this script running at this time

<#
if ($env:computername -eq "L02DI1453375DIT") {
    $titlesToCheck = @("Untitled - Notepad", "-------New Tab - Google Chrome")
    $outputFolder = "c:\users\derruer\mydata\mytemp\" 
    $forbiddenUntilAndIncluded = "10/01/2018"
    $forbiddenFile = "c:\users\derruer\mydata\mytemp\no_agario.txt"
    $delay = 10
}
elseif ($env:computername -eq "MYPC3") {
    $titlesToCheck = @("you-NO-tube", "agar", "Agar.io - Google Chrome", "slither.io - Google Chrome", "diep.io - Google Chrome", "space1.io - Google Chrome")
    $forbiddenUntilAndIncluded = "16/01/2018"
    $forbiddenFile = "d:\temp\no_agario.txt"
    $outputFolder = "d:\temp\" 
    $delay = 10
}
else {
    $outputFolder = "d:\temp\" 
    $delay = 10
}
#>

$dateTime = Get-Date
$errorFile = $outputFolder + "error.log"
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
    [bool]$global:wasCreated = $false;
    $mutant = New-Object System.Threading.Mutex($true, "MyMutexGetWindowTitle8", [ref] $global:wasCreated);        
    if ($global:wasCreated) {     
        sendMail "toto240325@gmail.com" "getWindowTitle starting at $dateTime" "this is the body"       
        mainJob;
    }
    else {
        write-host "test3"
        #just exit if there is already a script running
        write-host "Script is already running, so I exit"
        Start-Sleep -s 5
        # or wait for the mutex to be released :
        #$mutant.WaitOne();
    }
}
catch {
    write-host "!!!! catch"
    $datetime = get-date -format "yyyy-MM-dd-HH-mm-ss"
    $errorMsg = "$($datetime) - Error during execution. More Info: $($_)" 
    $errorMsg | out-file -append -filepath $errorFile
    Write-host $errorMsg
} 
finally {       
    write-host "!!!! Finally"
    if ($global:wasCreated) {
        $mutant.ReleaseMutex(); 
        $mutant.Dispose();
        write-host "mutex released"
    }

    $datetime = get-date -format "yyyy-MM-dd-HH-mm-ss"
    $errorMsg = "$($datetime) - excuting the 'finally' in initial code. More Info: $($_)" 
    $errorMsg | out-file -append -filepath $errorFile
}

