<#
!!!!!!!! powershell get-content -tail 10 -wait d:\temp\error.log
test
test2
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



<#
	[void][system.reflection.Assembly]::LoadWithPartialName("MySql.Data")
	$ConnStr = �server=localhost;uid=root;password=Toto!;database=mysql;Port=3306�
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
	`fgw_title` varchar(255) DEFAULT NULL,
	`fgw_cpu` float DEFAULT NULL,
	`fgw_duration` int DEFAULT NULL,
	PRIMARY KEY (`fgw_id`)
	) ENGINE=InnoDB AUTO_INCREMENT=0;
	
	
#>
#------------------------------------------------------------------------------------�
function ConnectMySQL([string]$user,[string]$pass,[string]$MySQLHost,[string]$database) {
	�
	��# Load MySQL .NET Connector Objects
	��[void][system.reflection.Assembly]::LoadWithPartialName("MySql.Data")
	�
	��# Open Connection
	��$connStr = "server=" + $MySQLHost + ";port=3306;uid=" + $user + ";pwd=" + $pass + ";database="+$database+";Pooling=FALSE"
	��$conn = New-Object MySql.Data.MySqlClient.MySqlConnection($connStr)
	
    $Error.Clear()
    try
    {
        $conn.Open()
	}
    catch
    {
        write-warning ("Could not open a connection to Database $database on Host $MySQLHost. Error: "+$Error[0].ToString())
		Start-Sleep -s 5
}
	��$cmd = New-Object MySql.Data.MySqlClient.MySqlCommand("USE $database", $conn)
	��return $conn
	�
}
#------------------------------------------------------------------------------------�
function myQuery($conn) {
	
    # Get an instance of what all objects need for a SELECT query : the Command object
    $oMYSQLCommand = New-Object MySql.Data.MySqlClient.MySqlCommand
    # DataAdapter Object
    $oMYSQLDataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter
    # And the DataSet Object 
    $oMYSQLDataSet = New-Object System.Data.DataSet	
    # Assign the established MySQL connection
    $oMYSQLCommand.Connection=$conn
    # Define a SELECT query
    $oMYSQLCommand.CommandText='SELECT fgw_id,fgw_time,fgw_title,fgw_cpu from fgw order by fgw_id desc limit 10'
    $oMYSQLDataAdapter.SelectCommand=$oMYSQLCommand
    # Execute the query
    $iNumberOfDataSets=$oMYSQLDataAdapter.Fill($oMYSQLDataSet, "data")
	
    foreach($oDataSet in $oMYSQLDataSet.tables[0])
    {
		write-host "ID:" $oDataSet.fgw_ID "time:" $oDataSet.fgw_time "Title:" $oDataSet.fgw_title "CPU:" $oDataSet.fgw_cpu
	}
}
#------------------------------------------------------------------------------------�
function WriteMySQLQuery($conn, [string]$query) {
	�
	��$command = $conn.CreateCommand()
	��$command.CommandText = $query
	��$RowsInserted = $command.ExecuteNonQuery()
	��$command.Dispose()
	��if ($RowsInserted) {
		����return $RowsInserted
		��} else {
		����return $false
	��}
}
#------------------------------------------------------------------------------------�
function myInsert($conn,$dateStr,$dateStr,$title,$cpu,$duration) {
    $query = 'insert into fgw (fgw_time,fgw_title,fgw_cpu,fgw_duration) values ("'+$dateStr+'","'+$title+'",' + $cpu + ','+$duration+')'
	
	��$command = $conn.CreateCommand()
	��$command.CommandText = $query
	��$RowsInserted = $command.ExecuteNonQuery()
	��$command.Dispose()
	��if ($RowsInserted) {
		����return $RowsInserted
		��} else {
		����return $false
	��}
}
#------------------------------------------------------------------------------------�
function myInsert2($conn,$dateStr,$title,$cpu,$duration) {
	
    $oMYSQLCommand = New-Object MySql.Data.MySqlClient.MySqlCommand
<<<<<<< HEAD
    $oMYSQLCommand.Connection = $conn
    $oMYSQLCommand.CommandText = '
    INSERT into fgw (fgw_time,fgw_host,fgw_title,fgw_cpu,fgw_duration) values (@time,@host,@title,@cpu,@duration)'
=======
    $oMYSQLCommand.Connection=$conn
    $oMYSQLCommand.CommandText='
    INSERT into fgw (fgw_time,fgw_title,fgw_cpu,fgw_duration) values (@time,@title,@cpu,@duration)'
>>>>>>> c0bc28c041f12fc62848acd837de978323af38a2
    $oMYSQLCommand.Prepare()
    $oMySqlCommand.Parameters.AddWithValue("@time", $dateStr)
    $oMySqlCommand.Parameters.AddWithValue("@title", $title)
    $oMySqlCommand.Parameters.AddWithValue("@cpu", $cpu)
    $oMySqlCommand.Parameters.AddWithValue("@duration", $duration)
    $iRowsInsert=$oMySqlCommand.ExecuteNonQuery()
    return $iRowsInsert
}
#------------------------------------------------------------------------------------�
function myUpdate($conn,$dateStr,$title,$cpu) {
	
    $oMYSQLCommand = New-Object MySql.Data.MySqlClient.MySqlCommand
    $oMYSQLCommand.Connection=$conn
    $oMYSQLCommand.CommandText=
    'UPDATE fgw myFgw SET fgw_cpu = 100 where myFgw.fgw_ID = 1234 and myFgw.fgw_title = "test"'
    $iRowsAffected=$oMYSQLCommand.executeNonQuery()
	
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


function log_error($errorMsg){
	$errorMsg | out-file -append -filepath $errorFile
}


function mainJob() {
<<<<<<< HEAD
    
    
    #making the script window invisible
    Add-Type -Name win -MemberDefinition '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);' -Namespace native
    $p = [System.Diagnostics.Process]::GetCurrentProcess() | Get-Process
    $mainWindowHandle = $p.MainWindowHandle
    #write-host "mainWindowHandle : " $mainWindowHandle
    #Start-Sleep -s 3
    
    if ($env:computername -eq "L02DI1453375DIT") {
        #[native.win]::ShowWindow($mainWindowHandle,0)
    }
    elseif ($env:computername -eq "H171412649") {
        #[native.win]::ShowWindow($mainWindowHandle,0)
    }
    elseif ($env:computername -eq "MYPC3") {
        $tmp=[native.win]::ShowWindow($mainWindowHandle,5) # 5: display window 
        #$tmp = [native.win]::ShowWindow($mainWindowHandle, 0) # 0: hide window
    }
=======
	
	
	#making the script window invisible
	Add-Type -Name win -MemberDefinition '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);' -Namespace native
	$p = [System.Diagnostics.Process]::GetCurrentProcess() | Get-Process
	$mainWindowHandle = $p.MainWindowHandle
	#write-host "mainWindowHandle : " $mainWindowHandle
	#Start-Sleep -s 3
	
	if ($env:computername -eq "L02DI1453375DIT") {
	#[native.win]::ShowWindow($mainWindowHandle,0)
	} elseif ($env:computername -eq "H171412649") {
	#[native.win]::ShowWindow($mainWindowHandle,0)
	} elseif ($env:computername -eq "MYPC3") {
	#$tmp=[native.win]::ShowWindow($mainWindowHandle,5) # 5: display window 
	$tmp=[native.win]::ShowWindow($mainWindowHandle,0) # 0: hide window
	}
>>>>>>> c0bc28c041f12fc62848acd837de978323af38a2

	
	
	
	#to make the script window visible again
	#   powershell_ise
	#   Add-Type -Name win -MemberDefinition '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);' -Namespace native
	#   #get the mainWindowHandle in the Excel filename !
	#   [native.win]::ShowWindow(464782,5)
	
	
	
	$datetime = get-date -format "yyyy-MM-dd-HH-mm-ss"
	$outfile = $outputFolder + "test-$datetime-$mainWindowHandle.csv"
	#write-host "outfile : " $outfile
	
	$wshell = New-Object -ComObject Wscript.Shell
	
	# setup vars (get $user, $pass, $database, $mySqlhost)
	#. '.\params.ps1'
	. "$PSScriptRoot\params.ps1"
	�
	# Connect to MySQL Database
	$conn = ConnectMySQL $user $pass $MySQLHost $database
	�
	#$query = 'insert into fgw (fgw_time,fgw_title,fgw_cpu) values ("2016-08-01 00:00:05","window title", 1000)'
	#$Rows = WriteMySQLQuery $conn $query
	#Write-Host $Rows " inserted into database"
	
	#myQuery($conn)
	
	$i=0
	$allWindowsTitles = @()
	
	"dateTime`tcpu`ttitle`tdelay" > $outfile
	$prevTitle = $null
	#while($i -ne 10000)
	while($true)
	{
		try {
			$ActiveHandle = [userWindows]::GetForegroundWindow()
			$Process = Get-Process | ? {$_.MainWindowHandle -eq $activeHandle}
			
			#check if this is a real process or a system (?) process
			$title = ""
			if ($Process) { 
				$title  = $Process.MainWindowTitle.trim() 
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
			else
			{
				#write-host "title is empty"
				$title = ""
				$cpu = 0
				$deltaCpu = 0
			}      
			
			$prevTitle = $title
			$prevCpu = $cpu
		
		
		} catch {
			$errorMsg = "$($datetime) - test Failed xxx to get active Window details. More Info: $($_)" 
			$errorMsg | out-file -append -filepath $errorFile
			Write-host $errorMsg
			Start-Sleep -s 5

		}
		#write-host "test1"
		#$allWindowsTitles +=$title
		$dateTime = Get-Date
		
		#$Process | select ProcessName
		$maxlen = 30
		
		try {
			$line = ""
			$line = $line + "{0}"       -f $dateTime
			$line = $line + "`t{0,10}"  -f $cpu.tostring("0.000") 
			$line = $line + "`t{0}"     -f $deltaCpu.tostring("0.00")
			$line = $line + "`t{0,-25}" -f ($title.padright($maxlen+1)).remove($maxlen)
			$line = $line + "`t{0,5}"   -f $delay
			$line | Out-File $outfile -Append
			write-host $line
			#write-host "test2"
		} 
		catch {
			$errorMsg = "$($datetime) - Error when formatting. More Info: $($_)" 
			$errorMsg | out-file -append -filepath $errorFile
			Write-host $errorMsg
		} 
		
		$dateStr = $dateTime.ToString("yyyy-MM-dd HH:mm:ss.fff")
		
		
		if ($conn.state -eq "Open") {
			#write-host "conn is open"
			} else {
			#write-host "conn is not open"
			$conn = ConnectMySQL $user $pass $MySQLHost $database
		}
		
		$iRowsInsert = myInsert2 $conn $dateStr $title $cpu $delay

		
		$titleFound = 0
	    foreach($t in $titlesToCheck) {
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
		#write-host ((get-date).Date -le (get-date $forbiddenUntilAndIncluded).Date)
		
		$stillInForbiddenPeriod = ((get-date).Date -le (get-date $forbiddenUntilAndIncluded).Date)
		$forbiddenFileFound = (Test-Path $forbiddenFile)
		
		if ($titleFound -and ($stillInForbiddenPeriod -or $forbiddenFileFound)) {
									
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
			$text = $text + "            Bien essay� !`n"
			$text = $text + "            Je te conseille de fermer`n"
			$text = $text + "            cet �cran rapidos !! ;-)`n"
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
			
			
			
			#[System.Reflection.Assembly]::LoadWithPartialName(�System.Windows.Forms�)
			#[Windows.Forms.MessageBox]::Show($text, "ALERTE AU FILOU !!!!!", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
			
			$nSecs = 5
			$wshell.Popup($text,$nSecs,"ALERTE AU FILOU !!!!!",0x30)
			
			log_error($errorMsg = "$($datetime) - Alerte filou !!!!" )
			#$errorMsg = "$($datetime) - Alerte filou !!!!" 
			#$errorMsg | out-file -append -filepath $errorFile
			sleep -s 3
			} else {
			
			sleep -s $delay
		}
		$i ++
	}
}

#--------------------------------------------------------------------
#------------- START ------------------------------------------------
#--------------------------------------------------------------------
#checking if I am the only occurence of this script running at this time

write-host "current host : " $env:computername
$titlesToCheck = "(none)"
$forbiddenFile = "(none)"
if ($env:computername -eq "L02DI1453375DIT") {
	$titlesToCheck = @("Untitled - Notepad","-------New Tab - Google Chrome")
	$outputFolder = "c:\mydata\mytemp\" 
	$forbiddenUntilAndIncluded = "14/10/2016"
	$forbiddenFile = "c:\mydata\mytemp\no_agario.txt"
	$delay = 10
} elseif ($env:computername -eq "MYPC3") {
	$titlesToCheck = @("you-NO-tube","agar", "Agar.io - Google Chrome","slither.io - Google Chrome","diep.io - Google Chrome","space1.io - Google Chrome")
	$forbiddenUntilAndIncluded = "16/10/2016"
	$forbiddenFile = "d:\temp\no_agario.txt"
	$outputFolder = "d:\temp\" 
	$delay = 10
} else {
	$outputFolder = "d:\temp\" 
	$delay = 10
}

$dateTime = Get-Date
$errorFile = $outputFolder + "error.log"
$errorMsg = "host : $($env:computername)" 
$errorMsg | out-file -append -filepath $errorFile
$errorMsg = "$($datetime) - just checking that the error file is properly collecting errors..." 
$errorMsg | out-file -append -filepath $errorFile
#write-host "the error file is " $errorFile
#write-host $errorMsg

[System.Threading.Mutex]$mutant;
try
{
	# Obtain a system mutex that prevents more than one deployment taking place at the same time.
	[bool]$wasCreated = $false;
	$mutant = New-Object System.Threading.Mutex($true, "MyMutexGetWindowTitle3", [ref] $wasCreated);        
	if ($wasCreated)
	{            
		mainJob;
	} else {
		#just exit if there is already a script running
		write-host "Script is already running, so I exit"

		Start-Sleep -s 5

		# or wait for the mutex to be released :
		#$mutant.WaitOne();
	}
}
catch {
	$errorMsg = "$($datetime) - Error during main job ? More Info: $($_)" 
	$errorMsg | out-file -append -filepath $errorFile
	Write-host $errorMsg
} 
finally
{       
	
	if ($wasCreated) {
		$mutant.ReleaseMutex(); 
		$mutant.Dispose();
	}
	
	$errorMsg = "$($datetime) - excuting the 'finally' step. More Info: $($_)" 
	$errorMsg | out-file -append -filepath $errorFile
	
	
}

