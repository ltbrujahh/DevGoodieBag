# Functions --------------------------------------------------------------
function Log ($comment) {
    Write-Host "LOG: $comment" -ForegroundColor "Yellow"
}
# ------------------------------------------------------------------------

Log "Installing Boxstarter"
. { Invoke-WebRequest -useb http://boxstarter.org/bootstrapper.ps1 } | Invoke-Expression; get-boxstarter -Force

# Run Chocolatey script
$gist = "https://gist.githubusercontent.com/ltbrujahh/a32e5225e1b7e79c6bb159092f639e66/raw/84cfae59d3c59299185fd395599320f9f5f5c01d/attache-dev-machine.ps1"
$credentials = Get-Credential $env:USERNAME

Log "Requesting credentials..."
Install-BoxstarterPackage -PackageName $gist -Credential $credentials -DisableReboots

# Run Direct Installer script