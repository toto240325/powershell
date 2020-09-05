$a = (New-Object -comObject Shell.Application).Windows() |
 ? { $_.FullName -ne $null} 

 $a | % {  write-host $_.fullname, $_.locationName }

