$ErrorActionPreference = 'Stop'

$packageName = 'toolsmonk'
$url64       = 'https://github.com/vksingh5995/toolsmonk-releases/releases/download/v1.1.33/ToolsMonk-Setup-1.1.33.exe'
$checksum64  = 'C86A9D4F77B2805BA8E5E222F300A432C77F1374E8ECE9F0C95588AF7B55D4A7'

# The upstream NSIS installer is per-user by default (electron-builder
# `perMachine: false`). Chocolatey runs elevated and users expect a machine-wide
# install, so `/allusers` is passed: the assisted installer parses that switch and
# switches to per-machine mode. `/S` is the NSIS silent switch.
$packageArgs = @{
  packageName    = $packageName
  fileType       = 'exe'
  url64bit       = $url64
  checksum64     = $checksum64
  checksumType64 = 'sha256'
  silentArgs     = '/S /allusers'
  validExitCodes = @(0)
  softwareName   = 'ToolsMonk*'
}

Install-ChocolateyPackage @packageArgs
