<# Google_Chrome_Install
Created by Thomas Dyre
04132020
Modified by Thomas Dyre
04162020
#>
<#Release notes: add autodownload of current version
Scheduled task Nightly.
Remove old versions of Chrome and install the latest version. Copy Configuration and polices to correct locations
Change to unschedule task to first check for the task before running.
Change to check for OS and pull proper info for OS. I left static info in the script for winx64
#>

<# Function Get-ChromeVersion will pull information from Google JavaScript Object Notation file (Json) and format it 
to a Powershell object.#>
Function Get-ChromeVersion {
<# Parmeters for Version checking of Google Chrome#>
Param (
        [Parameter(Mandatory = $False)]
        [string] $Uri = "https://omahaproxy.appspot.com/all.json",

        [Parameter(Mandatory = $False)]
        [ValidateSet('win', 'win64', 'mac', 'linux', 'ios', 'cros', 'android', 'webview')]
        [string] $Platform = "win",

        [Parameter(Mandatory = $False)]
        [ValidateSet('stable', 'beta', 'dev', 'canary', 'canary_asan')]
        [string] $Channel = "stable"
    )
    <#Checks the assigned url for content and converts from JSON. #>
    $chromeVersions = (Invoke-WebRequest -uri $Uri).Content | ConvertFrom-Json

    <#Reads the PSCustomObject and pulls information about current version#>
    $output = (($chromeVersions | Where-Object { $_.os -eq $Platform }).versions |
            Where-Object { $_.channel -eq $Channel }).current_version
    
    Write-Output $output
}

<#Setting intial Varibles#>

    $StartDTMF = (Get-Date -UFormat "%d %b %Y")
    $StartDTM = (Get-Date)
    $Vendor = "Google"
    $Product = "Chrome Enterprise"
    $PackageName = "googlechromestandaloneenterprise64"
    $InstallerType = "msi"
    $LogPS = "${env:SystemRoot}" + "\Temp\$Vendor $Product $StartDTMF PS Wrapper.log"
    $LogApp = "${env:SystemRoot}" + "\Temp\$Product $PackageName.log"
    $Version = $(Get-ChromeVersion)

<#Starting Main Script#>

Start-Transcript $LogPS

Write-Verbose "Log File Varibles set prior to script Log Starting
    Software Vendor: $Vendor
    Software Title:  $Product
    Installer Name:  $PackageName
    Name of PS Log:  $LogPS
    Name of App Log: $LogApp
    " -Verbose
    

Write-Verbose "Setting initial Varibles" -Verbose

    #Varibles in use for downloading Chrome 

    $uri = "https://dl.google.com/tag/s/dl/chrome/install/googlechromestandaloneenterprise64.msi"
    $GCFolder = "$env:windir\temp\Chrome"
        new-item -Path $GCFolder -ItemType Directory -Force | Out-Null
    $Source = "$GCFolder\$PackageName" + "." + "$InstallerType"
  
      Write-Verbose "
      $uri
      $GCFolder
      " -Verbose      
     
   
<# REM Kill Chrome#>

    Write-Verbose "Stopping Processes for $Product" -Verbose

    foreach ($task in "iexplore.exe", "Chrome.exe"){

        taskkill /F /im $task /FI "STATUS eq RUNNING"

    }


<# Download Chrome#>

Write-Verbose "Downloading Latest Version of $Vendor $Product $Version" -Verbose

If (!(Test-Path -Path $Source)) {
    Invoke-WebRequest -Uri $uri -OutFile $Source
         }
        Else {
            Write-Verbose "File exists. Skipping Download." -Verbose
         }
    
   
<#Capture Version of Chrome and set parameters#>

    if (Test-Path -Path "C:\Program Files (x86)\Google\Chrome\Application"){
        $GCOV = (Get-Item -Path "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe").VersionInfo.FileVersion}
        else
        {$GCOV = 0.0}

    $UnattendedArgs = "/qn"
    $ProgressPreference = 'SilentlyContinue'
    

   
<#Start Installing Chrome #>

Write-Verbose "Checking for $Vendor $Product $Version" -Verbose
    if ($GCOV -notlike $Version){
 
        Write-Verbose "Starting Installation of $Vendor $Product $Version" -Verbose
        (Start-Process -FilePath "$Source" -ArgumentList $UnattendedArgs -Wait -Passthru).ExitCode

        Write-Verbose "Customization" -Verbose
        sc.exe config gupdate start= disabled
        sc.exe config gupdatem start= disabled
        if (Get-ScheduledTask -TaskName "GoogleUpdateTaskMachineCore"){
            Write-verbose "Removing GoogleUpdateTaskMachineCore" -Verbose
            Unregister-ScheduledTask -TaskName "GoogleUpdateTaskMachineCore" -Confirm:$false}
        if (Get-ScheduledTask -TaskName "GoogleUpdateTaskMachineUA"){
            Unregister-ScheduledTask -TaskName "GoogleUpdateTaskMachineUA" -Confirm:$false
        
    } else {
            Write-Verbose "No Scheduled Task to Remove" -Verbose
            }    
        }else {
        Write-Verbose "Software is upto date. Skipping install"
    }
        
       
<# Clean up and close out#>

Write-Verbose "Removing Install files and Closing Log File."

Remove-Item -Path $GCFolder -Recurse -Force -Verbose

Write-Verbose "Stop logging" -Verbose

$EndDTM = (Get-Date)

Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds" -Verbose
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose

Stop-Transcript
<#Cleans up all the varibles used in this script#>
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
Get-UserVariable|Remove-Variable