echo off
rename \\192.168.0.2\d\temp\magic33.txt magic33_.txt
rem dir \\192.168.0.2\d\temp\magic2*.txt
echo disabling magic on %date% %time% >> \\192.168.0.2\d\projects\powershell\misc\log.txt
rem pause