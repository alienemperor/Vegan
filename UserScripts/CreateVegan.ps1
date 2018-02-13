#function taken from "The Scripting Guys"
#https://blogs.technet.microsoft.com/heyscriptingguy/2013/06/03/generating-a-new-password-with-windows-powershell/
Function GET-Temppassword() {

Param(

[int]$length=10,

[string[]]$sourcedata

)

 

For ($loop=1; $loop –le $length; $loop++) {

            $TempPassword+=($sourcedata | GET-RANDOM)

            }

return $TempPassword

}

$ascii=$NULL;For ($a=33;$a –le 126;$a++) {$ascii+=,[char][byte]$a }






$firstname = Read-Host "what is the user's first name?"
$lastname = Read-Host "What is the user's last name?"
$email = Read-Host "What is the user's email address?"
$passPT = GET-Temppassword –length 8 –sourcedata $ascii
$pass = ConvertTo-SecureString($passPT) -AsPlainText -Force
$username = $firstname+"."+$lastname
$dir = "C:\inetpub\ftproot\LocalUser\$username"

New-LocalUser -FullName "$Firstname $Lastname" -Description $email -Name $username -Password $pass -AccountNeverExpires

mkdir $dir
$Acl = Get-Acl $dir
$Ar = New-Object  system.security.accesscontrol.filesystemaccessrule("$username","FullControl","Allow")
$Acl.SetAccessRule($Ar)
Set-Acl $dir $Acl

New-WebVirtualDirectory -Site VEGAN -PhysicalPath $dir -Name $username


#send email
$EmailFrom = "veganwebhosting@gmail.com"
$EmailTo = $email 
$Subject = "Your new Vegan account is ready!" 
$Body = "Congratulations on taking your first step to becoming a Vegan!
Here at Vegan Web Hosting we are dedicated to helping you along your new path.
Here are your new credentials for getting in to your new web hosting server:
    Username: $username
    Password: $passPT

You can access your new site by going to http://vegan.infotech.pri/$user/ in your favourite web browser.
You can transfer files to your site via ftp by following the instuctions on our support page vegan/faq.html
Any questions or concerns can be expressed by sending an email to veganwebhosting@gmail.com

Thank you for choosing Vegan Web Hosting!" 
$SMTPServer = "smtp.gmail.com" 
$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587) 
$SMTPClient.EnableSsl = $true 
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential("email", "password"); 
$SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)
