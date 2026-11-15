[CmdletBinding()]
param(
    [string]$QtRoot = 'C:\Qt\6.12.0\mingw_64',
    [string]$MinGWRoot = 'C:\Qt\Tools\mingw1310_64',
    [string]$CMake = 'C:\Qt\Tools\CMake_64\bin\cmake.exe',
    [string]$Ninja = 'C:\Qt\Tools\Ninja\ninja.exe',
    [string]$NsisCompiler = '',
    [string]$ReleaseRoot = '',
    [string]$BuildRoot = '',
    [switch]$SkipBuild
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
if (!$BuildRoot) { $BuildRoot = Join-Path $projectRoot 'build-release-1.0' }
if (!$ReleaseRoot) { $ReleaseRoot = Join-Path $projectRoot 'releases' }
$ReleaseRoot = [IO.Path]::GetFullPath($ReleaseRoot)
$stage = Join-Path $ReleaseRoot 'LunarNavigator-1.0-Windows-x64'
$env:PATH = "$MinGWRoot\bin;$QtRoot\bin;" + $env:PATH
function Assert-NativeSuccess([string]$operation) {
    if ($LASTEXITCODE -ne 0) { throw "$operation failed with exit code $LASTEXITCODE" }
}
if (!$SkipBuild) {
    & $CMake -S $projectRoot -B $buildRoot -G Ninja '-DCMAKE_BUILD_TYPE=Release' "-DCMAKE_PREFIX_PATH=$QtRoot" "-DCMAKE_CXX_COMPILER=$MinGWRoot/bin/g++.exe" "-DCMAKE_MAKE_PROGRAM=$Ninja"
    Assert-NativeSuccess 'CMake configure'
    & $CMake --build $buildRoot --parallel 4
    Assert-NativeSuccess 'CMake build'
}
# A staging folder contains generated files only. Verify its exact parent before cleaning.
if ([IO.Path]::GetDirectoryName([IO.Path]::GetFullPath($stage)) -ne $ReleaseRoot) {
    throw 'Staging folder escaped the release directory'
}
if (Test-Path -LiteralPath $stage) { Remove-Item -LiteralPath $stage -Recurse -Force }
New-Item -ItemType Directory -Path $stage -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $buildRoot 'HackathonApp.exe') -Destination (Join-Path $stage 'LunarNavigator.exe')
& "$QtRoot\bin\windeployqt.exe" --release --compiler-runtime --no-translations --qmldir (Join-Path $projectRoot 'HackathonContent') --dir $stage (Join-Path $stage 'LunarNavigator.exe')
Assert-NativeSuccess 'Qt deployment'
@'
[Paths]
Prefix=.
Plugins=.
QmlImports=qml
'@ | Set-Content -LiteralPath (Join-Path $stage 'qt.conf') -Encoding ascii
Copy-Item -LiteralPath (Join-Path $projectRoot 'packaging/PORTABLE-README.txt') -Destination (Join-Path $stage 'README.txt')
Copy-Item -LiteralPath (Join-Path $projectRoot 'packaging/THIRD_PARTY_NOTICES.md') -Destination $stage
Copy-Item -LiteralPath (Join-Path $projectRoot 'packaging/licenses') -Destination $stage -Recurse

$uninstall = @('; Generated from the exact portable payload.')
foreach ($file in Get-ChildItem -LiteralPath $stage -File -Recurse) {
    $relative = $file.FullName.Substring($stage.Length + 1).Replace('$', '$$')
    $uninstall += 'Delete "$INSTDIR\' + $relative + '"'
}
foreach ($directory in Get-ChildItem -LiteralPath $stage -Directory -Recurse | Sort-Object { $_.FullName.Length } -Descending) {
    $relative = $directory.FullName.Substring($stage.Length + 1).Replace('$', '$$')
    $uninstall += 'RMDir "$INSTDIR\' + $relative + '"'
}
$uninstall | Set-Content -LiteralPath (Join-Path $ReleaseRoot 'uninstall-files.nsh') -Encoding utf8

$zip = Join-Path $ReleaseRoot 'LunarNavigator-1.0-Windows-x64.zip'
Compress-Archive -LiteralPath $stage -DestinationPath $zip -CompressionLevel Optimal -Force
if ($NsisCompiler) {
    $setup = Join-Path $ReleaseRoot 'LunarNavigator-1.0-Setup.exe'
    & $NsisCompiler /V2 "/DPAYLOAD=$stage" "/DOUTPUT=$setup" (Join-Path $projectRoot 'packaging/windows-installer.nsi')
    Assert-NativeSuccess 'NSIS installer'
}
Get-ChildItem -LiteralPath $ReleaseRoot -File | Where-Object { $_.Extension -in '.exe', '.zip' } |
    Get-FileHash -Algorithm SHA256 | ForEach-Object { $_.Hash + '  ' + [IO.Path]::GetFileName($_.Path) } |
    Set-Content -LiteralPath (Join-Path $ReleaseRoot 'SHA256SUMS.txt') -Encoding ascii
Write-Host "Windows packages: $ReleaseRoot"
