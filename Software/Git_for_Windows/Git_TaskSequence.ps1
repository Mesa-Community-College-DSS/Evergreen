<#
Created By Thomas Dyre
Created on 04/15/2020
Created to set a task schedule to run the specified program.
It will also set Internet Explorer to Disable first run. 
The script will remove all user defiend varibles at the end of the execution.
#>

<# Set IE to disable firsttime run #>

$registryPath = "HKLM:\Software\Policies\Microsoft\Internet Explorer\Main"
$Name = "DisableFirstRunCustomize"
$value = "2"

IF(!(Test-Path $registryPath))
  {

    New-Item -Path $registryPath -Force | Out-Null

    New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | Out-Null}

 ELSE {

    New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | Out-Null}

<#The function will gather all the user defined varibles with the script and remove them.#>

function Get-UserVariable ($Name = '*')
{
  # these variables may exist in certain environments (like ISE, or after use of foreach)
  $special = 'ps','psise','psunsupportedconsoleapplications', 'foreach', 'profile'

  $ps = [PowerShell]::Create()
  $null = $ps.AddScript('$null=$host;Get-Variable') 
  $reserved = $ps.Invoke() | 
    Select-Object -ExpandProperty Name
  $ps.Runspace.Close()
  $ps.Dispose()
  Get-Variable -Scope Global | 
    Where-Object Name -like $Name |
    Where-Object { $reserved -notcontains $_.Name } |
    Where-Object { $special -notcontains $_.Name } |
    Where-Object Name -Verbose
}

<# Create New Directory#>
if (!(test-path -Path "$env:windir\SCHTASK\Git4Win")) {
New-Item -Path "$env:windir\SCHTASK\Git4Win" -ItemType Directory -Force -Verbose
}

Copy-Item -Path "$PSScriptRoot\Git_Evergreen.ps1" -Destination "$env:windir\SCHTASK\Git4Win" -Force -Verbose

<#Set the Actions#>
$actions = @()
$actions += New-ScheduledTaskAction -execute powershell.exe -Argument '-executionpolicy bypass -file "C:\WINDOWS\SCHTASK\Git4Win\Git_Evergreen.ps1"'
#$actions += New-ScheduledTaskAction -execute shutdown.exe -Argument "-r -t 0"
$user = "NT Authority\System"

<#Set the GitHub for Windows Task Schedule#>
$trigger =@()
#$trigger += New-ScheduledTaskTrigger -Daily -At 5am
$trigger += New-ScheduledTaskTrigger -Daily -At 1:30am
$descript = "Checks the Version of GitHub for Windows Downloads and installs latest version at 0130"
$ltype = New-ScheduledTaskPrincipal -UserId "$user" -LogonType "ServiceAccount" -RunLevel Highest
$task = New-ScheduledTask -Action $actions -Trigger $trigger -Description $descript -Principal $ltype
Register-ScheduledTask -TaskName "GitHub for Windows Update Check" -InputObject $task

<#Remove all Varibles used in script#>
Get-UserVariable|Remove-Variable