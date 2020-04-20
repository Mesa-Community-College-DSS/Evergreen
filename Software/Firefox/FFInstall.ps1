# Mozilla_FireFox_Install
# Created by Thomas Dyre
# 05/21/2019
# Modified by Thomas Dyre
# 04/10/2020

#Release notes: add autodownload of current version
#               Consider as a Scheduled task Nightly.
# Remove old versions of Firefox and install the latest version. Copy Configuration and polices to correct locations


    $StartDTMF = (Get-Date -UFormat "%d %b %Y")
    $StartDTM = (Get-Date)
    $Vendor = "Mozilla"
    $Product = "FireFox"
    $PackageName = "setup"
    $LogPS = "${env:SystemRoot}" + "\Temp\$Vendor $Product $StartDTMF PS Wrapper.log"
    $LogApp = "${env:SystemRoot}" + "\Temp\$Product $PackageName.log"

Start-Transcript $LogPS
            Write-Verbose "Log File Varibles set prior to script Log Starting
                $Vendor
                $Product
                $PackageName
                $LogPS
                $LogApp" -Verbose
    

Write-Verbose "Setting initial Varibles" -Verbose

    #Varibles in use for downloading firefox 

            $uri = "https://download.mozilla.org/?product=Firefox-latest&os=win64&lang=en-US"
            $FFFolder = "$env:windir\temp\Firefox"
                new-item -Path $FFFolder -ItemType Directory -Force | Out-Null
            
  
      Write-Verbose "$uri
       $FFFolder" -Verbose      
     
   
# REM Kill Firefox

    Write-Verbose "Stopping Processes for $Product" -Verbose

    foreach ($task in "iexplore.exe", "firefox.exe"){

        taskkill /F /im $task /FI "STATUS eq RUNNING"

    }


# Download Firefox

Write-Verbose "Downloading Latest Version of $Vendor $Product" -Verbose

$page  = Invoke-WebRequest -Uri $URI -MaximumRedirection 0 -ErrorAction SilentlyContinue -UseBasicParsing
 
    if ($page.StatusCode -eq 302) {
 
        $FileSource = $page.Headers.Location
        $FileName =  Split-Path ([uri]$page.Headers.Location).LocalPath -Leaf
 
        if (Test-Path -Path $FFFolder -PathType Container) {

            try {

                Invoke-WebRequest -Uri $FileSource -UseBasicParsing -OutFile (Join-Path -Path $FFFolder -ChildPath $FileName) -ErrorAction Stop

                Write-Verbose -Message "Successfully downloaded $($FileName)  from $($FileSource)"

                Get-Item (Join-Path -Path $FFFolder -ChildPath $FileName)

            } catch {

                Write-Warning -Message "Failed to download $($FileName) from $($FileSource) because $($_.Exception.Message)"
                break

            }
        } else {

            Write-Warning -Message "The target folder specified as parameter should be a folder"

        }

    } else {

        Write-Warning -Message "Failed to query $URI. Return code was $($page.StatusCode)"

    }
    
    #Capture Version of FireFox and set parameters

    Write-Verbose "Installation Setting Parametes" -Verbose
#    Start-Sleep -Seconds 20
    $Exe = Get-ChildItem -Path $FFFolder -name -Include "*.exe"
    $FFExe = "$FFFolder\$Exe"

    Start-Process -FilePath $FFExe -ArgumentList "/ExtractDir=$FFFolder" -NoNewWindow -Wait -Verbose

    $ffUV = (Get-Item -Path "$FFFolder\core\Firefox.exe").VersionInfo.FileVersion

    if (Test-Path -Path "$env:program files\Mozilla Firefox"){
        $FFOV = (Get-Item -Path "$env:ProgramFiles\Mozilla Firefox\Firefox.exe").VersionInfo.FileVersion}
        else
        {$FFOV = 00}

    $InstallerType = "exe"
    $Source = "$FFFolder\$PackageName" + "." + "$InstallerType"
    $UnattendedArgs = '/SILENT MaintenanceService=false'
    $ProgressPreference = 'SilentlyContinue'
    $Destination="C:\Program Files\Mozilla Firefox\distribution"

    Write-Verbose "$Exe
    $FFExe
    $ffUV
    $FFOV
    $InstallerType
    $Source
    $UnattendedArgs
    $ProgressPreference
    $Destination" -Verbose



#Start Installing FireFox 

Write-Verbose "Checking for $Vendor $Product $FFUV" -Verbose
        if ($FFOV -lt $ffuv){
 
        Write-Verbose "Starting Installation of $Vendor $Product $Version" -Verbose
        (Start-Process "$Source" -ArgumentList $UnattendedArgs -Wait -Passthru).ExitCode
 
        Write-Verbose "Customization" -Verbose
        sc.exe config MozillaMaintenance start= disabled -Verbose
                
        }
        
        if (!(Test-Path -Path "$Destination")) 

            {
                New-Item -Path "C:\Program Files\Mozilla Firefox" -Name "distribution" -ItemType "directory" -Verbose
                Copy-Item $env:windir\SCHTASK\* -Include *.JSON -Destination $Destination -Verbose
            } 

        else 

            {
        
            Copy-Item $env:windir\SCHTASK\* -Include *.JSON -Destination $Destination -Verbose     
        }
    Write-Verbose "Polices have been distributed" -Verbose



# Clean up and close out

Write-Verbose "Removing Install files and Closing Log File."

Remove-Item -Path $FFFolder -Recurse -Force -Verbose

Write-Verbose "Stop logging" -Verbose

$EndDTM = (Get-Date)

Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds" -Verbose
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose

Stop-Transcript
