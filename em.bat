echo off
rename \\192.168.0.2\d\temp\magic33_.txt magic33.txt
rem dir \\192.168.0.2\d\temp\magic33*.txt
echo enabling magic33 on %date% %time% >> \\192.168.0.2\d\projects\powershell\misc\log.txt
powershell -command "& { . d:\projects\powershell\test_send_mail.ps1; sendMail 'eric.derruine@gmail.com' 'magic33 activated on mypc3 !' 'this is the body' }"
rem pause