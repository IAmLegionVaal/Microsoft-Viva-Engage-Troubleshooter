#requires -Version 5.1
<# Created by Dewald Pretorius #>
param([string]$OutputPath)
if(-not $OutputPath){$OutputPath="$([Environment]::GetFolderPath('Desktop'))\Viva_Engage_Reports"};New-Item $OutputPath -ItemType Directory -Force|Out-Null
$targets='engage.cloud.microsoft','login.microsoftonline.com','graph.microsoft.com';$net=foreach($t in $targets){[pscustomobject]@{Target=$t;HTTPS443=(Test-NetConnection $t -Port 443 -InformationLevel Quiet -WarningAction SilentlyContinue)}}
@('MICROSOFT VIVA ENGAGE TROUBLESHOOTER','Created by Dewald Pretorius',"Generated: $(Get-Date)",($net|Format-Table -AutoSize|Out-String -Width 220),'Guidance: verify licence, network membership, community permissions, notification settings, Teams embedding, browser storage, and Microsoft 365 service health.')|Set-Content (Join-Path $OutputPath 'Report.txt') -Encoding UTF8