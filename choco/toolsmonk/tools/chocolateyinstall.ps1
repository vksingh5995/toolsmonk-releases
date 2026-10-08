$ErrorActionPreference = 'Stop'

$packageName = 'toolsmonk'
$url64       = 'https://github.com/vksingh5995/toolsmonk-releases/releases/download/v1.1.24/ToolsMonk-Setup-1.1.24.exe'
$checksum64  = '25177377B347A9974DC46E3A29B715D4310E97140C30162CE691FAC1C2EE2239'

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
