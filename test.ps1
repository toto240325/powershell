$i = 1
while ($true) {
    write-host $i
    $i += 1
    Start-Sleep -s 1
    if ($i -eq 3) {
        invoke-expression -Command $MyInvocation.MyCommand.Path
        exit
    }
    


}
