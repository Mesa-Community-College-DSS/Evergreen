<#Project EverGreen
Created By Thomas Dyre
Email thomas.dyre@mesacc.edu
Created on 04/15/2020
Created to remove a task schedule to run the specified program.
Modified By Thomas Dyre
Email: thomas.dyre@mesacc.edu
Modified 04/16/2020
Include removal of GC_Evergreen.ps1 the detection method.
#>

if (Get-ScheduledTask -TaskName "Google Chrome Update Check"){
    Write-verbose "Removing ScheduledTask" -Verbose
    Unregister-ScheduledTask -TaskName Google Chrome Update Check -Confirm:$false
    } else {
    Write-Verbose "No Scheduled Task to Remove" -Verbose}

Remove-Item -Path "C:\Windows\SCHTASK\GC\GC_Evergreen.ps1" -Force -Recurse