<#Project Evergreen
Created by Thomas Dyre 
Email: thomas.dyre@mesacc.edu
Created on 04/16/2020
Script is to ensure registry settings have been set.
Copied from Google_Install.ps1
#>

Start-Sleep -Seconds 10
Write-Output "The Password Manager is disabled"
$PME = "HKLM:\Software\Policies\Google\Chrome"
$PMEName = "PasswordManagerEnabled"
$PMEvalue = "0x00000000"

IF(!(Test-Path $PME))

  {

    New-Item -Path $PME -Force | Out-Null

    New-ItemProperty -Path $PME -Name $PMEName -Value $PMEvalue -PropertyType DWORD -Force | Out-Null}

 ELSE {
    New-ItemProperty -Path $PME -Name $PMEname -Value $PMEvalue -PropertyType DWORD -Force | Out-Null
}
Start-Sleep -Seconds 10
 
 Write-Output "The Sync is disabled user and machine levels"
$CSdM = "HKLM:\Software\Policies\Google\Chrome"
$CSDU = "HKCU:\SOFTWARE\Policies\Google\Chrome"
$CSDName = "SyncDisabled"
$CSDvalue = "00000001"

IF(!(Test-Path $CSdM))

  {

    New-Item -Path $registryPath -Force | Out-Null

    New-ItemProperty -Path $CSdM -Name $CSdname -Value $CSdvalue -PropertyType DWORD -Force | Out-Null}

 ELSE {
    New-ItemProperty -Path $CSdM -Name $CSdname -Value $CSdvalue -PropertyType DWORD -Force | Out-Null
}
Start-Sleep -Seconds 10

IF(!(Test-Path $CSdM))

  {

    New-Item -Path $registryPath -Force | Out-Null

    New-ItemProperty -Path $CSDU -Name $CSdname -Value $CSdvalue -PropertyType DWORD -Force | Out-Null}

 ELSE {
    New-ItemProperty -Path $CSDU -Name $CSdname -Value $CSdvalue -PropertyType DWORD -Force | Out-Null
}
Start-Sleep -Seconds 10

$Usersname = (Get-ChildItem -Path $env:SystemDrive\users)

    foreach ($UN in $Usersname){

    $Gpath = ("$env:SystemDrive\users\$UN\AppData\Local\Google\Chrome\User Data\Default\Login Data")

        if ($Gpath -ne $null){

        Write-Output "$Gpath"

        Remove-Item -Path $Gpath -Force
       }}