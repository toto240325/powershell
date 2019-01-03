# to call this from cmd.exe :
# powershell -command "& { . .\test_send_mail.ps1; sendMail 'eric.derruine@gmail.com' 'this is a test 5' 'this is the body' }"
# 


if ($env:computername -eq "L02DI1453375DIT") {
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

#sendMail "eric.derruine@gmail.com" "this is a test 4" "this is the body"