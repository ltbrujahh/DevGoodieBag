# Boxstarter script tinkered from http://blog.zerosharp.com/provisioning-a-new-development-machine-with-boxstarter/

# Test-PendingReboot is throwing false negatives
# cinst     - choco install

# Variables
$windowsSettingsMutex = Join-Path $env:TEMP "win10DesktopSettings.att"
$devLiteToolsMutex = Join-Path $env:TEMP "devLiteTools.att"
$isFinalRestartMutex = Join-Path $env:TEMP "isFinalRestart.att"

$devLiteTools = @("7zip", "notepad2", "notepadplusplus")

$mutexes = @($windowsSettingsMutex, $devLiteToolsMutex, $isFinalRestartMutex)

# Functions --------------------------------------------------------------
function Invoke-Log ($comment) {
    # Write-Host "Invoke-Log: $comment" -ForegroundColor "Yellow"
    "LOG: $comment"
}

function Invoke-Error ($comment) {
    Write-Host "ERR: $comment" -ForegroundColor "Red"
}

function Invoke-LogExist ($comment) {
    Invoke-Log "$comment already exists. Skipping step."
}

function Invoke-Cleanup {
    Invoke-Log "Cleaning up temp files..."

    foreach ($mutex in $mutexes) {
        Remove-File $mutex
    }
}

function Invoke-RestartComputer ($mutex) {
    if (Test-Path $mutex) {
        Invoke-Log "Completed restart!"
    }
    else {
        Invoke-Log "Attempting to restart computer..."

        if (Test-PendingReboot) { 
            Invoke-Log "Requires restart!"
        }
        else {
            Invoke-Log "Does not require restart, restarting anyway!"
        }
    
        $input = Read-Host -Prompt "Press ENTER for restart..."
    
        if ($input) { 
            Invoke-Log "Cancelled restart." 
        } 
        else { 
            Set-FlagCompleted $mutex
            Invoke-Reboot 
        }
    }
}

function Set-FlagCompleted ($flag) {
    $filename = Split-Path $flag -Leaf
    Invoke-Log "Setting flag '$filename'"

    New-Item $flag -ItemType file
}

function Remove-File ($path) {
    Remove-Item $path

    if (Test-Path $path) { Invoke-Error "Error removing $path" }    
    else { Invoke-Log "Removed $path" }
}
# ------------------------------------------------------------------------

Invoke-Log "Flags for auto login on reboot..."
$Boxstarter.RebootOk = $true
$Boxstarter.NoPassword = $false
$Boxstarter.AutoLogin = $true

# Setup PowerShell environment
Invoke-Log "Release Restriction Level 0..."
Update-ExecutionPolicy Unrestricted

# Workstation settings
if (Test-Path $windowsSettingsMutex) {
    Invoke-LogExist $windowsSettingsMutex
}
else {
    Invoke-Log "Setting up Windows 10 settings..."

    Set-ExplorerOptions -showHidenFilesFoldersDrives -showProtectedOSFiles -showFileExtensions
    Enable-RemoteDesktop
    Disable-InternetExplorerESC
    Disable-UAC
    Disable-BingSearch
    # Set-TaskbarSmall

    Set-FlagCompleted $windowsSettingsMutex

    if (Test-PendingReboot) { Invoke-Reboot }
}

# Update Windows and reboot if necessary
# Install-WindowsUpdate -AcceptEula
# if (Test-PendingReboot) { Invoke-Reboot }

# dev IDEs
# cinst VisualStudioCode
# cinst VisualStudio2017Professional

# dev tools
if (Test-Path $devLiteToolsMutex) {
    Invoke-LogExist $devLiteToolsMutex
}
else {
    Invoke-Log "Installing lite Dev tools"
    
    foreach ($tool in $devLiteTools) {
        cinst $tool
    }

    Set-FlagCompleted $devLiteToolsMutex

    if (Test-PendingReboot) { Invoke-Reboot }
}

Invoke-RestartComputer $isFinalRestartMutex
Invoke-Cleanup

# if (Test-PendingReboot) { Invoke-Reboot }

####

# # Install Visual Studio 2013 Professional 
# cinstm VisualStudio2013Professional -InstallArguments WebTools
# if (Test-PendingReboot) { Invoke-Reboot }

# # Visual Studio SDK required for PoshTools extension
# cinstm VS2013SDK
# if (Test-PendingReboot) { Invoke-Reboot }

# # cinstm DotNet3.5 # Not automatically installed with VS 2013. Includes .NET 2.0. Uses Windows Features to install.
# if (Test-PendingReboot) { Invoke-Reboot }

# # VS extensions
# # Install-ChocolateyVsixPackage PowerShellTools http://visualstudiogallery.msdn.microsoft.com/c9eb3ba8-0c59-4944-9a62-6eee37294597/file/112013/6/PowerShellTools.vsix
# # Install-ChocolateyVsixPackage WebEssentials2013 http://visualstudiogallery.msdn.microsoft.com/56633663-6799-41d7-9df7-0f2a504ca361/file/105627/31/WebEssentials2013.vsix
# # Install-ChocolateyVsixPackage T4Toolbox http://visualstudiogallery.msdn.microsoft.com/791817a4-eb9a-4000-9c85-972cc60fd5aa/file/116854/1/T4Toolbox.12.vsix
# # Install-ChocolateyVsixPackage StopOnFirstBuildError http://visualstudiogallery.msdn.microsoft.com/91aaa139-5d3c-43a7-b39f-369196a84fa5/file/44205/3/StopOnFirstBuildError.vsix

# # AWS Toolkit is now an MSI available here http://sdk-for-net.amazonwebservices.com/latest/AWSToolsAndSDKForNet.msi (no chocolatey package as of FEB 2014)
# # Install-ChocolateyVsixPackage AwsToolkit http://visualstudiogallery.msdn.microsoft.com/175787af-a563-4306-957b-686b4ee9b497

# #Other dev tools
# # cinstm NugetPackageExplorer
# cinstm ncrunch2.vs2017
# #cinstm mssqlserver2012express

# #Browsers
# cinstm googlechrome
# # cinstm firefox



# #cinst Microsoft-Hyper-V-All -source windowsFeatures
# # install .net frameworks 3.5 / 4.6
# cinst IIS-WebServerRole -source windowsfeatures
# cinst IIS-HttpCompressionDynamic -source windowsfeatures
# cinst IIS-ManagementScriptingTools -source windowsfeatures
# cinst IIS-WindowsAuthentication -source windowsfeatures

# Install-ChocolateyPinnedTaskBarItem "$($Boxstarter.programFiles86)\Google\Chrome\Application\chrome.exe"
# Install-ChocolateyPinnedTaskBarItem "$($Boxstarter.programFiles86)\Microsoft Visual Studio 12.0\Common7\IDE\devenv.exe"

####