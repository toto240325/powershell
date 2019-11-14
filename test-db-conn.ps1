[string]$sMySQLUserName = 'toto'
[string]$sMySQLPW = 'Toto!'
[string]$sMySQLDB = 'mydatabase'
[string]$sMySQLHost = '192.168.0.147'
[string]$sConnectionString = "server="+$sMySQLHost+";port=3306;uid=" + $sMySQLUserName + ";pwd=" + $sMySQLPW + ";database="+$sMySQLDB

$oConnection = New-Object MySql.Data.MySqlClient.MySqlConnection($sConnectionString)
$Error.Clear()
try
{
    $oConnection.Open()
}
catch
{
    write-warning ("Could not open a connection to Database $sMySQLDB on Host $sMySQLHost. Error: "+$Error[0].ToString())
}