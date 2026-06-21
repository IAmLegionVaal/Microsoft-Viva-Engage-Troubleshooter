#requires -Version 5.1
<# Created by Dewald Pretorius. #>
[CmdletBinding()]
param(
  [ValidateSet('Diagnose','ResetCache','FlushDns')][string]$Action='Diagnose',
  [switch]$DryRun,
  [switch]$Yes,
  [string]$OutputPath=(Join-Path ([Environment]::GetFolderPath('Desktop')) 'Viva_Engage_Repair')
)
$ErrorActionPreference='Stop'
$cachePaths=@("$env:APPDATA\Microsoft\Teams\Cache","$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache")
$endpoints=@('engage.cloud.microsoft','login.microsoftonline.com','graph.microsoft.com')
New-Item -ItemType Directory -Path $OutputPath -Force|Out-Null
$stamp=Get-Date -Format 'yyyyMMdd_HHmmss'
$logPath=Join-Path $OutputPath "Repair_$stamp.log"
function Write-RepairLog([string]$Message){$line='{0:u} {1}' -f (Get-Date),$Message;Write-Host $line;Add-Content -LiteralPath $logPath -Value $line}
$evidence=[ordered]@{Action=$Action;Caches=@($cachePaths|ForEach-Object{[pscustomobject]@{Path=$_;Exists=(Test-Path -LiteralPath $_)}});Endpoints=@($endpoints|ForEach-Object{[pscustomobject]@{Host=$_;DNS=[bool](Resolve-DnsName $_ -ErrorAction SilentlyContinue);HTTPS443=(Test-NetConnection $_ -Port 443 -InformationLevel Quiet -WarningAction SilentlyContinue)}})}
$evidence|ConvertTo-Json -Depth 6|Set-Content -LiteralPath (Join-Path $OutputPath "PreRepair_$stamp.json") -Encoding UTF8
if($Action -eq 'Diagnose'){Write-RepairLog '[COMPLETE] Read-only diagnostic snapshot saved.';exit 0}
if($DryRun){Write-RepairLog "[DRY-RUN] Would perform $Action.";exit 0}
if(-not $Yes -and (Read-Host "Perform $Action for Viva Engage? [y/N]") -notmatch '^(?i)y(es)?$'){Write-RepairLog '[CANCELLED] No changes were made.';exit 4}
try{
  if($Action -eq 'ResetCache'){
    if(Get-Process -Name 'msedge','ms-teams' -ErrorAction SilentlyContinue){throw 'Close Microsoft Edge and Teams before resetting their caches.'}
    foreach($path in $cachePaths){if(Test-Path -LiteralPath $path){$backup="$path.backup-$stamp";Move-Item -LiteralPath $path -Destination $backup -Force;New-Item -ItemType Directory -Path $path -Force|Out-Null;Write-RepairLog "[BACKUP] $backup"}}
  } else {Clear-DnsClientCache}
}catch{Write-RepairLog "[FAILED] $($_.Exception.Message)";exit 5}
if($Action -eq 'ResetCache' -and @($cachePaths|Where-Object{-not(Test-Path -LiteralPath $_)}).Count -gt 0){Write-RepairLog '[VERIFY-FAILED] Cache recreation failed.';exit 6}
Write-RepairLog '[COMPLETE] Repair and verification completed.'
exit 0
