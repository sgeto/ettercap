# Config
$urlPath = "https://nmap.org/npcap/dist/latest-npcap-installer.exe"
$autoit = 'Run ("latest-npcap-installer.exe /disable_restore_point=yes /npf_startup=yes /loopback_support=yes /dlt_null=no /admin_only=no /dot11_support=yes /vlan_support=yes /winpcap_mode=yes")
WinWait ("Npcap", "License Agreement")
If Not WinActive ("Npcap", "License Agreement") Then WinActivate ("Npcap", "License Agreement")
WinWaitActive ("Npcap", "License Agreement")
Send ("!a")
Send ("!i")
WinWaitActive ("Npcap", "Installation Complete")
Send ("!n")
WinWaitActive ("Npcap")
WinKill ("Npcap")'

############

echo "Install AutoIT"
choco install -y -r --no-progress autoit.commandline > $null

echo "Generate InstallNpcap.au3"
$autoit | Out-File $PSScriptRoot"\InstallNpcap.au3"

echo "Download the latest Npcap installer"

# https://www.reddit.com/r/PowerShell/comments/3qndf4/not_sure_if_possible_want_to_check_if_file_from/
# https://github.com/ratchetnclank/NSClient-Checks/blob/master/check-screenconnectupdate.ps1
$LocalDirectory = $PSScriptRoot

$LocalFile = "latest-npcap-installer.exe"

$Variable = $urlPath

$Response = (Invoke-WebRequest -Uri $Variable -UseBasicParsing).Links

$Response.Href -Match 'exe' | ForEach-Object { If(($_ -Split '/')[3] -eq $LocalFile){ $NewFile = ($_).Split('/')[3] ; Invoke-WebRequest -Uri $_ -OutFile $LocalDirectory\$NewFile }}

$LocalFile = $NewFile

# wget $urlPath -UseBasicParsing -OutFile $PSScriptRoot"\latest-npcap-installer.exe"

############

echo "Generate InstallNpcap.exe from InstallNpcap.au3"
Start-Process -FilePath "Aut2exe.exe" -ArgumentList "/in InstallNpcap.au3 /out InstallNpcap.exe /nopack /comp 2 /Console" -NoNewWindow -Wait
# Invoke-Expression "cmd.exe /c Aut2exe.exe /in InstallNpcap.au3 /out InstallNpcap.exe /nopack /comp 2 /Console"

# Aut2exe.exe /in InstallNpcap.au3 /out InstallNpcap.exe /nopack /comp 2 /Console

echo "Run InstallNpcap.exe"
Start-Process -FilePath .\InstallNpcap.exe -NoNewWindow

# Success!
echo "Npcap installation completed"

# echo Cleanup
# Remove-Item *.exe, *.au3