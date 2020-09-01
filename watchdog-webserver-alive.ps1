# to call this from cmd.exe :
# powershell -command "& { . .\test_send_mail.ps1; sendMail 'eric.derruine@gmail.com' 'this is a test 5' 'this is the body' }"
# to start from powershell
# PS> & 'C:\Users\derruer\mydata\projects\powershell\watchdog-webserver-alive.ps1'
#
# to check error file continuously :
# !!!!!!!! powershell get-content -tail 10 -wait \\192.168.0.2\d\temp\error-watchdog.log



if ($env:computername -eq "L194827317") {
    $File = "$env:userprofile\mydata\mytemp\b.txt"		
    $filenameAndPath = $File
    $outputFolder = "$env:userprofile\mydata\mytemp\" 
}

elseif ($env:computername -eq "HP2560") {
    $File = "d:\temp\a.txt"
    $filenameAndPath = "d:\temp\att.txt"
    $outputFolder = "d:\temp\" 
}
elseif ($env:computername -eq "MYPC3") {
    $File = "d:\temp\d.txt"
    $filenameAndPath = "d:\temp\att.txt"
    $outputFolder = "d:\temp\" 
}
else {
    $File = "d:\temp\a.txt"
    $filenameAndPath = "d:\temp\att.txt"
    $outputFolder = "d:\temp\" 
}	


function sendMail($emailTo, $subject, $body) {

    $mailerUser = "mailer240325@gmail.com"
    $mailerPw = "Mailer060502!h"

    $secpasswd = ConvertTo-SecureString $mailerPw -AsPlainText -Force
    $cred = New-Object -TypeName System.Management.Automation.PSCredential($mailerUser, $secpasswd)

    $EmailFrom = "mailer240325@gmail.com"
    $SMTPServer = "smtp.gmail.com" 
    $SMTPMessage = New-Object System.Net.Mail.MailMessage($emailFrom, $emailTo, $subject, $body)
    $attachment = New-Object System.Net.Mail.Attachment($filenameAndPath)
    $SMTPMessage.Attachments.Add($attachment)
    $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587) 
    $SMTPClient.EnableSsl = $true 
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential($cred.UserName, $cred.Password); 
    $SMTPClient.Send($SMTPMessage)
    $attachment.dispose()
}	



function logError($errorMsg) {
    $errorMsgfull = $datetime + " " + $errorMsg
    write-host $errorMsgfull
    $errorMsgfull | out-file -append -filepath $errorFile
}



#------------------------------------------------------------
# a REST server return properly formatted json result
function isRESTserverAlive($server) {
    $amIAlive = $false
    try {
        $url = "http://" + $server + "/monitor/isServerAlive.php"
        $res = Invoke-RestMethod -Uri $url

        #write-host "res = ->" $res.result "<-" -ForegroundColor red
        if ($res.result -eq "YES" ) {
            $amIAlive = $true 
        }
        else {
            # this should never happen !!!!
            $errorMsg = "$($datetime) - Server $server does seem to be alive, but it returned an exepected reply !?" 
            Write-host "----------" $errorMsg -ForegroundColor Red
        }
    }
    catch {
        $errorMsg = "$($datetime) - Server $server doesn't seem to be alive. More Info: $($_)" 
        Write-host "----------" $errorMsg -ForegroundColor Red
    }
    return $amIAlive
}

#------------------------------------------------------------
# a REST server doesn NOT returns properly formatted json result, just contents
function isWebServerAlive($webserver,$stringToCheck) {
    
    $amIAlive = $false
    try {
        $res = Invoke-webRequest -Uri $webserver

        #write-host $res.StatusCode
        #write-host $res.Content
        if ($res.content -like $stringToCheck) {     
            $amIAlive = $true 
        }
        else {
            # this should never happen !!!!
            $errorMsg = "$($datetime) - Server $webserver does seem to be alive, but it returned an exepected reply !?" 
            Write-host "----------" $errorMsg -ForegroundColor Red
        }
    }
    catch {
        $errorMsg = "$($datetime) - Server $webserver doesn't seem to be alive. More Info: $($_)" 
        Write-host "----------" $errorMsg -ForegroundColor Red
    }
    return $amIAlive
}

#------------------------------------------------------------
# a plain server is neither a REST server nor a webserver
function isServerAlive($server) {
    
    $amIAlive = $false
    $Ping = Test-Connection -ComputerName $server -ErrorAction SilentlyContinue
    if ($Ping.statuscode -eq 0) {
        $amIAlive = $true
    }
    return $amIAlive
}

# Main job  ------------------------------------------------------------------------

$datetime = get-date -format "yyyy-MM-dd-HH-mm-ss"
#$outputFolder = "d:\temp\" 
$errorFile = $outputFolder + "error-watchdog3.log"


$RESTserver = "192.168.0.147"
$desc = "NB250"
logError "checking now whether $desc is alive or not..." 
if (!(isRESTserverAlive($RESTserver))) {
    logError("webserver $RESTserver is NOT alive !") 
    logError("sending Mail to eric.derruine@gmail.com : Problem : webserver $RESTserver ($desc) is NOT alive !")
    sendMail "eric.derruine@gmail.com" "😬 😬 Problem : webserver $RESTserver ($desc) is NOT alive !" "this message is sent by task D:\projects\powershell\watchdog-webserver-alive.ps1 on mypc3"
} else {
    logError("webserver $RESTserver ($desc) is alive !")     
}

$webserver = "http://192.168.0.9"
$desc = "Alarm system Eurotec"
logError "checking now whether $desc is alive or not..." 
if (!(isWebServerAlive $webserver '*Up time*')) {
    logError("webserver $webserver is NOT alive !") 
    logError("sending Mail to eric.derruine@gmail.com : Problem : webserver $webserver ($desc) is NOT alive !")
    sendMail "eric.derruine@gmail.com" "😬 😬 Problem : webserver $webserver ($desc) is NOT alive !" "this message is sent by task D:\projects\powershell\watchdog-webserver-alive.ps1 on mypc3"
} else {
    logError("webserver $webserver ($desc) is alive !")     
}

$server = "192.168.0.98"
$desc = "Raspberry"
#if (!(isServerAlive $server)) {
#    logError("server $server is NOT alive !") 
#    logError("sending Mail to eric.derruine@gmail.com : Problem : server $server ($desc) is NOT alive !")
#    sendMail "eric.derruine@gmail.com" "😬 😬 Problem : server $server ($desc) is NOT alive !" "this message is sent by task D:\projects\powershell\watchdog-webserver-alive.ps1 on mypc3"
#} else {
#    logError("server $server ($desc) is alive !")     
#}

