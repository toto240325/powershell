<#
!!!!!!!! powershell get-content -tail 10 -wait d:\temp\error.log
test   .

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
    $iNumberOfDataSets = $oMYSQLDataAdapter.Fill($oMYSQLDataSet, "data")

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
    $iRowsAffected = $oMYSQLCommand.executeNonQuery()

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

function log_error($errorMsg) {
    $errorMsg | out-file -append -filepath $errorFile
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
    
    $wshell = New-Object -ComObject Wscript.Shell
    
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
    $iterationNb = -1;
    while ($true) {
        write-host "-----------------------------------------"
        #write-host "$($datetime) - start iteration"
        $iterationNb += 1;
        $iterationNb %= $refreshParamsRate;

        <# obsolete - replaced by keywords in DB
        #re-read the params file every refreshParamsRate iteration
        if ($iterationNb -eq 0) {
            $myMsg = "$($datetime) - reading params file !!!!" 
            #$myMsg | out-file -append -filepath $errorFile
            write-host $myMsg
            . "$PSScriptRoot\params.ps1"
            write-host "titlesToCheck from params : " $titlesToCheck
            $titlesToCheck
        }
        #>
        
        try {

            # getting the keywords to check in the titles 
            if ($iterationNb -eq 0) {
                $url = "http://" + $webserver + "/monitor/getKeywords.php"
                #$myMsg = "$($datetime) - calling $url" 
                #$myMsg | out-file -append -filepath $errorFile
                write-host $myMsg
                $res = Invoke-RestMethod -Uri $url
                $keywords = $res.keywords
                $errMsg = $res.errMsg
                #$myMsg = "$($datetime) - keywords found in DB : " + $keywords + " errMsg : " + $errMsg 
                #$myMsg | out-file -append -filepath $errorFile
                debug $myMsg
            }

            # checking homw much time has already been played today
            if ($iterationNb -eq 0) {
                $duration = 0
                $url = "http://" + $webserver + "/monitor/getTimePlayedToday.php"
                #$myMsg = "$($datetime) - calling $url" 
                #$myMsg | out-file -append -filepath $errorFile
                write-host $myMsg
                $res = Invoke-RestMethod -Uri $url
                #write-host "time played today "
                debug "res : $res"
                #write-host "time played today " $res.timePlayedToday
                $timePlayedToday = $res.timePlayedToday
                #$myMsg = "$($datetime) - time already played today : $timePlayedToday" 
                #$myMsg | out-file -append -filepath $errorFile
                debug $myMsg
            }


            # checking how much time could exceptionally be played today
            if ($iterationNb -eq 0) {
                $duration = 0
                $url = "http://" + $webserver + "/monitor/getGameTimeExceptionallyAllowedToday.php"
                if ($debug) { $myMsg = "$($datetime) - calling $url" }
                #$myMsg | out-file -append -filepath $errorFile
                write-host $myMsg
                $res = Invoke-RestMethod -Uri $url
                $gameTimeExceptionallyAllowedToday = [int]$res.gameTimeExceptionallyAllowedToday
                $gameTimeAllowedDaily = [int]$res.gameTimeAllowedDaily
                #$myMsg = "$($datetime) - time exceptionally allowed today : $gameTimeExceptionallyAllowedToday   gameTimeAllowedDaily : $gameTimeAllowedDaily" 
                #$myMsg | out-file -append -filepath $errorFile
                #write-host $myMsg
            }

            debug "get info process"

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
                $cpu = $Process.TotalProcessorTime.TotalSeconds
                #write-host "cpu : " + $cpu
                # let's reset the CPU counter if the title of main windows changed
                if ($title -ne $prevTitle) { $prevCpu = $cpu } 
                $deltaCpu = $cpu - $prevCpu
                #$Process | Select ProcessName, @{Name="AppTitle";Expression= {($_.MainWindowTitle)}}
                #write-host "test1.2"
                #$Process | select ProcessName
                #$Process | Select @{Name="AppTitle";Expression= {($_.MainWindowTitle)}}
                #write-host "test1.3"
            } 
            else {
                #write-host "title is empty"
                $title = ""
                $cpu = 0
                $deltaCpu = 0
            }      
            
            $prevTitle = $title
            $prevCpu = $cpu
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
        
        # getting window title and storing it in a CSV file
        try {
            $line = ""
            $line = $line + "{0}" -f $dateTime
            $line = $line + "`t{0,10}" -f $cpu.tostring("0.000") 
            $line = $line + "`t{0}" -f $deltaCpu.tostring("0.00")
            $line = $line + "`t{0,-25}" -f ($title.padright($maxlen + 1)).remove($maxlen)
            $line = $line + "`t{0,5}" -f $delay
            $line | Out-File $outfile -Append
            write-host $line
            #write-host "test2"
        } 
        catch {
            $errorMsg = "$($datetime) - Error when formatting. More Info: $($_)" 
            $errorMsg | out-file -append -filepath $errorFile
            Write-host $errorMsg
        } 

        #$isChrome = ($title -match "Google Chrome")

        #write-host "titlesToCheck : " $titlesToCheck

        $titleFound = 0
       
        # foreach ($t in $titlesToCheck) {
        foreach ($kw in $keywords) {
            
            $result = $false
            try {
                $result = ($title -match $kw)
            }
            catch {
                write-host "error when evaluating expression"
            }

            #write-host "result of test for $kw : " $result
            
            if ($result) { 
                $titleFound = 1 
                $titleTxt = $title
                $errorMsg = "$($datetime) - titleFound $title with kw $kw" 
                $errorMsg | out-file -append -filepath $errorFile
                Write-host $errorMsg
            }
        }

        # storing window title in database
        try {
            $dateStr = $dateTime.ToString("yyyy-MM-dd HH:mm:ss.fff")
            if ($conn.state -eq "Open") {
                #write-host "conn is open"
            }
            else {
                #write-host "conn is not open"
                $conn = ConnectMySQL $user $pass $MySQLHost $database
            }
            $iRowsInsert = myInsert2 $conn $dateStr $hostStr $title $cpu $delay $titleFound
        }
        catch {
            $errorMsg = "$($datetime) - Error when storing in database. More Info: $($_)" 
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
        if ($titleFound -and ($remainingTimeToPlay -le 5)) {
            $nbBeeps = 3 - $remainingTimeToPlay
            for ($i=1; $i -le $nbBeeps; $i++) {
                [console]::beep(2000,500)
                }
        }
        
        <#
        write-host "remaining to play : $remainingTimeToPlay"
        write-host "titleFound : "($titleFound) 
        write-host "magicFileFound : "($magicFileFound) 
        write-host "remainingTimeToPlay -le 0 : " ($remainingTimeToPlay -le 0)
        write-host "stillInForbiddenPeriod: "($stillInForbiddenPeriod) 
        write-host "forbiddenFileFound: "($forbiddenFileFound) 
        write-host "timePlayedToday : "($timePlayedToday) 
        write-host "gameTimeExceptionallyAllowedToday: "($gameTimeExceptionallyAllowedToday) 
        write-host "gameTimeAllowedDaily: "($gameTimeAllowedDaily) 
        write-host "total allowed : " ($gameTimeAllowedDaily + $gameTimeExceptionallyAllowedToday) 
        write-host "remaining to play : $remainingTimeToPlay"
        write-host "timePlayedToday -gt gameTimeExceptionallyAllowedToday: " ($timePlayedToday -gt $gameTimeExceptionallyAllowedToday)
    	#>
	
      
        #$myCondition = ($titleFound -and !($magicFileFound) -and ($remainingTimeToPlay -le 0) -and (($stillInForbiddenPeriod -or $forbiddenFileFound)) )
        $myCondition = (!($magicFileFound) -and ($remainingTimeToPlay -le 0) -and (($stillInForbiddenPeriod -or $forbiddenFileFound)) )
        
        #write-host "myCondition : $myCondition"
        

        # if gaming is not allowed at this very moment...
        if ($myCondition) { 

            # if the top window contains the name of a game, pop-up the warning message and minimize the window
            if ($titleFound) {

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
                $text = $text + "played : $timePlayedToday`n"
                $text = $text + "exceptionally allowed today : $timeAllowedToday`n"
                $text = $text + $titleTxt + "`n"
                $text = $text + "++++++++++++++++++++++++++++++++++++++++++++++`n" 
                

                Set-WindowStyle $Process 'MINIMIZE'
                
                #[System.Reflection.Assembly]::LoadWithPartialName(System.Windows.Forms)
                #[Windows.Forms.MessageBox]::Show($text, "ALERTE AU FILOU !!!!!", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
                
                $nSecs = 3
                #write-host "before popup"
                $temp = $wshell.Popup($text, $nSecs, "ALERTE AU FILOU !!!!!", 0x30)
                #write-host "after popup"

                log_error($errorMsg = "$($datetime) - Alerte filou !!!! $titleTxt" )
                #$errorMsg = "$($datetime) - Alerte filou !!!!" 
                #$errorMsg | out-file -append -filepath $errorFile

                $a = Get-Random -Minimum 2 -Maximum 6
                For ($i = 1; $i -le $a; $i++) {
                    Set-WindowStyle $Process 'MINIMIZE'
                    Start-Sleep -s 2
                }
            }
            # in any case (if we are in a period where it cannot be gamed, then minimize all the windows which contain in their title the name of a game, 
            # to avoid having the top windows just overlapping a little bit with a game/video window just behind ;-) )

            # for all the processes having a visible window, if the title contains a game keyword and gaming is not allowed, minimize the window
            $visibleProceses = Get-Process | Where-Object {$_.MainWindowHandle -ne $activeHandle -and  $_.MainWindowHandle -ne 0 }
            foreach ($p in $visibleProceses) {
                $title = $p.MainWindowTitle.trim() 
                #write-host "*****************", $p.ProcessName, $title
                $titleFound = 0
                # foreach ($t in $titlesToCheck) {
                foreach ($kw in $keywords) {
                    $result = $false
                    try {
                        $result = ($title -match $kw)
                    }
                    catch {
                        write-host "error when evaluating expression"
                    }
                    if ($result) { 
                        #write-host "test : $title matching $kw ????? -> $result " 
                        Set-WindowStyle $p 'MINIMIZE'
                    }
                    #write-host "result of test for $kw : " $result
                    if ($title -match $kw) { 
                        $titleFound = 1 
                        $titleTxt = $title
                        debug "titleFound $title !"
                    }
                }
            }
        }

        #else {
            # maximize window if 
            #if ($isChrome) {
            #    Set-WindowStyle $Process 'MINIMIZE'
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
$forbiddenFile = "(none)"
#getting public and restricted parameters $user, $pass, $database, $mySqlhost, etc
. "$PSScriptRoot\params.ps1"
. "$PSScriptRoot\params_restricted.ps1"

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
    [bool]$wasCreated = $false;
    $mutant = New-Object System.Threading.Mutex($true, "MyMutexGetWindowTitle7", [ref] $wasCreated);        
    if ($wasCreated) {            
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
    if ($wasCreated) {
        $mutant.ReleaseMutex(); 
        $mutant.Dispose();
    }

    $datetime = get-date -format "yyyy-MM-dd-HH-mm-ss"
    $errorMsg = "$($datetime) - excuting the 'finally' in initial code. More Info: $($_)" 
    $errorMsg | out-file -append -filepath $errorFile
}

