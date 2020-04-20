<#Project EverGreen
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
<#Check for and remove Old Task#>

if (Get-ScheduledTask -TaskName "Google Chrome Update Check"){
    Write-verbose "Removing ScheduledTask" -Verbose
    Unregister-ScheduledTask -TaskName Google Chrome Update Check -Confirm:$false
    } else {
    Write-Verbose "No Scheduled Task to Remove" -Verbose}

Start-Sleep -Seconds 5

<# Create New Directory#>

if (!(test-path -Path "$env:windir\SCHTASK\GC")) {

New-Item -Path "$env:windir\SCHTASK\GC" -ItemType Directory -Force -Verbose

}

Copy-Item -Path "$PSScriptRoot\GC_Evergreen.ps1" -Destination "$env:windir\SCHTASK\GC" -Force -Verbose
Copy-Item -Path "$PSScriptRoot\GC_Registry_Evergreen.ps1" -Destination "$env:windir\SCHTASK\GC" -Force -Verbose

<#Set the Actions#>

$actions = @()
$actions += New-ScheduledTaskAction -execute powershell.exe -Argument '-executionpolicy bypass -file "C:\WINDOWS\SCHTASK\GC\GC_Evergreen.ps1"'
$actions += New-ScheduledTaskAction -execute powershell.exe -Argument '-executionpolicy bypass -file "C:\WINDOWS\SCHTASK\GC\GC_Registry_Evergreen.ps1"'
$user = "NT Authority\System"

<#Set the GitHub for Windows Task Schedule#>

$trigger =@()
#$trigger += New-ScheduledTaskTrigger -Daily -At 5am
$trigger += New-ScheduledTaskTrigger -Daily -At 2am
$descript = "Checks the Version of Chrome, Downloads and installs latest version at 0200"
$ltype = New-ScheduledTaskPrincipal -UserId "$user" -LogonType "ServiceAccount" -RunLevel Highest
$task = New-ScheduledTask -Action $actions -Trigger $trigger -Description $descript -Principal $ltype
Register-ScheduledTask -TaskName "Google Chrome Update Check" -InputObject $task

<#Remove all Varibles used in script#>

Get-UserVariable|Remove-Variable