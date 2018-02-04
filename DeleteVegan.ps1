$username = Read-Host "what is the name of the user you want to remove?"
Remove-WebVirtualDirectory -Name . -Site VEGAN -Application $username
Remove-Item -Path "C:\inetpub\ftproot\LocalUser\$username" -Recurse
Remove-LocalUser -Name $username
