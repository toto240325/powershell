$a = (New-Object -comObject Shell.Application).Windows() |
 ? { $_.FullName -ne $null} 

#$a.LocationName, $a.fullname

 $a | % {  write-host $_.fullname }

