<#
	this script call a php script to record an event in a mysql database
	call it with something like this : 
	powershell .\add_event.ps1 -type '7' -text 'toto ttttt'
	
	
#>
param (
    #    [string]$url = "http://52.26.69.146/loki/add_event.php",
    #[string]$url = "http://192.168.0.147/loki/add_event.php",
    [string]$url = "http://localhost/monitor/getLastEvent.php",
    #[Parameter(Mandatory = $true)][string]$type,
    [string]$type = '<no type supplied>',
    [string]$text = '<no text supplied>'
)


$now = get-date -format "yyyy-MM-dd HH:mm:ss"

#http://localhost/monitor/getLastEvent.php?eventFct=add&time="2018-01-16"&host=myHost&text="my text"&type="my type"


#$myParams = @{event_time=$now; event_host=$env:computername; event_type=$type;event_text=$text;add=1}
$myParams = @{eventFct = "add"; time = $now; host = $env:computername; type = $type; text = $text}
$result = Invoke-WebRequest -Uri $url -Method GET -Body $myParams
write-host "status code : " $result.statuscode
write-host "content : " $result.content
