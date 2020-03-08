# to call this from cmd.exe :
# powershell -command "& { . .\test_send_mail.ps1; sendMail 'eric.derruine@gmail.com' 'this is a test 5' 'this is the body' }"
# to start from powershell
# PS> & 'C:\Users\derruer\mydata\projects\powershell\watchdog-webserver-alive.ps1'
#
# to check error file continuously :
# !!!!!!!! powershell get-content -tail 10 -wait \\192.168.0.2\d\temp\error-watchdog.log



if ($env:computername -eq "L194827317") {
    $File = "C:\mydata\mytemp\b.txt"		
    $filenameAndPath = $File
}
elseif ($env:computername -eq "HP2560") {
    $File = "d:\temp\a.txt"
}
elseif ($env:computername -eq "MYPC3") {
    $File = "d:\temp\d.txt"
    $filenameAndPath = "d:\temp\att.txt"
}
else {
    $File = "d:\temp\a.txt"
    $filenameAndPath = "d:\temp\att.txt"
}	


function isServerAlive($webserver) {
    $amIAlive = $false
    try {
        $url = "http://" + $webserver + "/monitor/isServerAlive.php"
        $res = Invoke-RestMethod -Uri $url

        #write-host "res = ->" $res.result "<-" -ForegroundColor red
        if ($res.result -eq "YES" ) {
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

# Main job  ------------------------------------------------------------------------

$datetime = get-date -format "yyyy-MM-dd-HH-mm-ss"
$outputFolder = "d:\temp\" 
$errorFile = $outputFolder + "error-watchdog3.log"

$webserver = "192.168.0.147"

logError "checking now whether $webserver is alive or not..." 

if (!(isServerAlive($webserver))) {
    logError("webserver $webserver is NOT alive !") 
    logError("sending Mail to eric.derruine@gmail.com : Problem : webserver $webserver is NOT alive !")
    sendMail "eric.derruine@gmail.com" "Problem : webserver $webserver is NOT alive !" "this message is sent by task D:\projects\powershell\watchdog-webserver-alive.ps1 on mypc3"
} else {
    logError("webserver $webserver is alive !")     
}

