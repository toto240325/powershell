function ConnectMySQL([string]$user,[string]$pass,[string]$MySQLHost,[string]$database) {
 
  # Load MySQL .NET Connector Objects
  [void][system.reflection.Assembly]::LoadWithPartialName("MySql.Data")
 
  # Open Connection
  $connStr = "server=" + $MySQLHost + ";port=3306;uid=" + $user + ";pwd=" + $pass + ";database="+$database+";Pooling=FALSE"
  $conn = New-Object MySql.Data.MySqlClient.MySqlConnection($connStr)
  $conn.Open()
  $cmd = New-Object MySql.Data.MySqlClient.MySqlCommand("USE $database", $conn)
  return $conn
 
}
 
function WriteMySQLQuery($conn, [string]$query) {
 
  $command = $conn.CreateCommand()
  $command.CommandText = $query
  $RowsInserted = $command.ExecuteNonQuery()
  $command.Dispose()
  if ($RowsInserted) {
    return $RowsInserted
  } else {
    return $false
  }
}
 
# setup vars
$user = 'root'
$pass = 'Toto!'
$database = 'loki'
$MySQLHost = 'localhost'
 
# Connect to MySQL Database
$conn = ConnectMySQL $user $pass $MySQLHost $database
 
# Read all the records from table



$query = 'INSERT INTO temp (temp_temp,temp_time) VALUES (97,"2016-08-01 00:00:06")'
$Rows = WriteMySQLQuery $conn $query
Write-Host $Rows " inserted into database"