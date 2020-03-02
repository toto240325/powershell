<#
	this script call a php script to record an event in a mysql database
	call it with something like this : 
	powershell .\add_event.ps1 -type '7' -text 'toto ttttt'
	
	
#>

$now = get-date -format "yyyy-MM-dd HH:mm:ss"

function ConnectMySQL([string]$user, [string]$pass, [string]$MySQLHost, [string]$database) {
    # Load MySQL .NET Connector Objects
    [void][system.reflection.Assembly]::LoadWithPartialName("MySql.Data")

    # Open Connection
    $connStr = "server=" + $MySQLHost + ";port=3306;uid=" + $user + ";pwd=" + $pass + ";database=" + $database + ";Pooling=FALSE"
    $conn = New-Object MySql.Data.MySqlClient.MySqlConnection($connStr)

    $Error.Clear()
    #try {
    $conn.Open()
    #}
    #catch {
    #    write-warning ("Could not open a connection to Database $database on Host $MySQLHost. Error: " + $Error[0].ToString())
    #    Start-Sleep -s 5
    #}
    $cmd = New-Object MySql.Data.MySqlClient.MySqlCommand("USE $database", $conn)
    return $conn
}
#------------------------------------------------------------------------------------

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


#getting public and restricted parameters $user, $pass, $database, $mySqlhost, etc
. "$PSScriptRoot\params.ps1"
. "$PSScriptRoot\params_restricted.ps1"

# Connect to MySQL Database
write-host $user $pass $MySQLHost $database
$conn = ConnectMySQL $user $pass $MySQLHost $database
 

if (0) {

    $datetime = get-date -format "yyyy-MM-dd HH-mm-ss.fff"

    # $dateStr = $dateTime.ToString("yyyy-MM-dd HH:mm:ss.fff")
    if ($conn.state -eq "Open") {
        write-host "conn is open"
    }
    else {
        write-host "conn is not open"
        $conn = ConnectMySQL $user $pass $MySQLHost $database
    }

    #$iRowsInsert = myInsert2 $conn $datetime $hostStr $title $cpu $delay $titleBlacklisted
}
