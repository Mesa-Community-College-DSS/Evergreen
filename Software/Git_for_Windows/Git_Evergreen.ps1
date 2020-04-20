<# 

Created by Thomas Dyre
Created on 04/15/2020
Using various internet resources

Get version and download latest Git for Windows release via GitHub API

#>

<#Get Version info from web#>
<#GitHub API to query repository#>

$repository = "git-for-windows/git"
$appDL = "https://api.github.com/repos/git-for-windows/git/releases/latest"

<#Set the security protocol to Transport Layer Security 1.2
Request from web information about program
Parse the info, gather and set parameters#>

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$r = Invoke-WebRequest -Uri $appDL -UseBasicParsing
$latestRelease = ($r.Content | ConvertFrom-Json | Where-Object { $_.prerelease -eq $False })[0]
$latestVersion = $latestRelease.tag_name

<# Select release for x64#>
$appDL = $latestRelease.assets | Where-Object { $_.name -like "Git*64-bit*exe" } | Select-Object name, browser_download_url

<#Installation Settings#>
Write-Verbose "Setting Arguments" -Verbose
$StartDTM = (Get-Date)
$Vendor = "Misc"
$Product = "Git for Windows"
$PackageName = "Git-Stable"
$Version = $latestversion.trim("v") -replace '.windows.1'
$InstallerType = "exe"
$Source = "$PackageName" + "." + "$InstallerType"
$LogPS = "${env:SystemRoot}" + "\Temp\$Vendor $Product $Version PS Wrapper.log"
$LogApp = "${env:SystemRoot}" + "\Temp\$PackageName.log"
$Destination = "${env:windir}" + "\Temp\$Vendor\$Product\$Version\$packageName.$installerType"
$uri = $appDL.browser_download_url | Select-Object -First 1
$UnattendedArgs = '/SP- /VERYSILENT'
$GitFF = "$env:windir\Temp\$Vendor\$Product\$Version"

Start-Transcript $LogPS | Out-Null
Write-verbose "
    $Vendor $Product $Version
    Repsitory: $repository
    App: $appDL
    Source Location: $GitFF
    Source installer: $source
    Log File name: $LogPS
    App Log$LogApp
    Url for download: $uri
    Aurguments for Silent install: $UnattendedArgs

" -Verbose

Write-Verbose "Checking for Source Location" -Verbose
Write-Verbose "" -Verbose

if(!(Test-Path -Path $GitFF ))
{
    New-Item -ItemType directory -Path $GitFF -Verbose| Out-Null
} else {
    Write-Verbose "File exist" -Verbose
    }

Write-Verbose "" -Verbose
Write-Verbose "Downloading $Vendor $Product $Version" -Verbose
Write-Verbose "" -Verbose

If (!(Test-Path -Path $GitFF\$Source)) {
    Invoke-WebRequest -Uri $uri -OutFile $GitFF\$Source -Verbose
         }
        Else {
            Write-Verbose "File exists. Skipping Download." -Verbose
         }

Write-Verbose "" -Verbose
Write-Verbose "Starting Installation of $Vendor $Product $Version" -Verbose
Write-Verbose "" -Verbose

(Start-Process "$GitFF\$Source" -ArgumentList $UnattendedArgs -Wait -Verbose -Passthru).ExitCode
Write-Verbose "" -Verbose

Write-Verbose "Customization" -Verbose
Write-Verbose "" -Verbose

Write-Verbose "Removing Varibles"-Verbose
Write-Verbose "" -Verbose
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

Write-Verbose "Stop logging" -Verbose
Write-Verbose "" -Verbose

$EndDTM = (Get-Date)
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds" -Verbose
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose
Stop-Transcript | Out-Null
Get-UserVariable | Remove-Variable