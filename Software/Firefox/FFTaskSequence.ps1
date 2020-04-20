# Create New Directory
if (!(test-path -Path "$env:windir\SCHTASK")) {
New-Item -Path "$env:windir\SCHTASK" -ItemType Directory -Force -Verbose
}

Copy-Item -Path "$PSScriptRoot\FFInstall.ps1" -Destination "$env:windir\SCHTASK" -Force -Verbose
Copy-Item -Path "$PSScriptRoot\policies.json" -Destination "$env:windir\SCHTASK" -Force -Verbose

#Set the Actions
$actions = @()
$actions += New-ScheduledTaskAction -execute powershell.exe -Argument '-executionpolicy bypass -file "C:\WINDOWS\SCHTASK\FFInstall.ps1"'
#$actions += New-ScheduledTaskAction -execute shutdown.exe -Argument "-r -t 0"
$user = "NT Authority\System"

#Set the FireFox Task Schedule
$trigger =@()
#$trigger += New-ScheduledTaskTrigger -Daily -At 5am
$trigger += New-ScheduledTaskTrigger -Daily -At 1am
$descript = "Checks the Version of Firefox Downloads and installs latest version at 0100"
$ltype = New-ScheduledTaskPrincipal -UserId "$user" -LogonType "ServiceAccount" -RunLevel Highest
$task = New-ScheduledTask -Action $actions -Trigger $trigger -Description $descript -Principal $ltype
Register-ScheduledTask -TaskName "FireFox Update Check" -InputObject $task