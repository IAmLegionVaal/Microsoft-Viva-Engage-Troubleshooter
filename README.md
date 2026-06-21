# Microsoft Viva Engage Troubleshooter

PowerShell 5.1 diagnostics and guarded local repair tooling created by **Dewald Pretorius**.

`Troubleshooter.ps1` collects the original evidence. `Repair.ps1` adds `Diagnose`, `ResetCache`, and `FlushDns`. Cache repair requires Edge and Teams to be closed, moves existing caches to timestamped backup folders, recreates clean paths, logs the work, and verifies the result.

```powershell
.\Troubleshooter.ps1
.\Repair.ps1 -Action Diagnose
.\Repair.ps1 -Action ResetCache -DryRun
.\Repair.ps1 -Action ResetCache -Yes
```

Mutating actions require confirmation unless `-Yes` is supplied. Source-reviewed for Windows PowerShell 5.1; not runtime-tested against every tenant or client build.
