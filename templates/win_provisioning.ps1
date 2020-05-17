<powershell>
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope MachinePolicy
$admin = [adsi]("WinNT://./${win_user}, user")
$admin.PSBase.Invoke("SetPassword", "${win_password}")
Rename-computer -force –computername "$env:COMPUTERNAME" –newname "${short_name}"
Invoke-Expression ((New-Object System.Net.Webclient).DownloadString('https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1'))
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5 -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
</powershell>