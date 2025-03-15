# Define an array of exclusion paths
$exclusionPaths = @(
    "%TEMP%\*\*.VHD",
    "%TEMP%\*\*.VHDX",
    "%Windir%\TEMP\*\*.VHD",
    "%Windir%\TEMP\*\*.VHDX",
    "\\stctsavdfslgx02.file.core.usgovcloudapi.net\fslogix\*\*.VHD",
    "\\stctsavdfslgx02.file.core.usgovcloudapi.net\fslogix\*\*.VHD.lock",
    "\\stctsavdfslgx02.file.core.usgovcloudapi.net\fslogix\*\*.VHD.meta",
    "\\stctsavdfslgx02.file.core.usgovcloudapi.net\fslogix\*\*.VHD.metadata",
    "\\stctsavdfslgx02.file.core.usgovcloudapi.net\fslogix\*\*.VHDX",
    "\\stctsavdfslgx02.file.core.usgovcloudapi.net\fslogix\*\*.VHDX.lock",
    "\\stctsavdfslgx02.file.core.usgovcloudapi.net\fslogix\*\*.VHDX.meta",
    "\\stctsavdfslgx02.file.core.usgovcloudapi.net\fslogix\*\*.VHDX.metadata"
)

# Add exclusions to Microsoft Defender
foreach ($path in $exclusionPaths) {
    Add-MpPreference -ExclusionPath $path
}