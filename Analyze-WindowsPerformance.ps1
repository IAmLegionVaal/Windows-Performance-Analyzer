<#
.SYNOPSIS
Collects a short Windows performance snapshot and report.
#>
[CmdletBinding()]
param(
    [ValidateRange(5,300)][int]$DurationSeconds=30,
    [ValidateRange(1,30)][int]$SampleInterval=2,
    [string]$OutputRoot="$env:PUBLIC\Documents\WindowsPerformanceReports"
)

Set-StrictMode -Version 2.0
$ErrorActionPreference='Stop'
$runPath=Join-Path $OutputRoot ("Performance_{0}_{1}" -f $env:COMPUTERNAME,(Get-Date -Format 'yyyyMMdd_HHmmss'))
$warnings=New-Object System.Collections.Generic.List[string]

try{
    if($env:OS -ne 'Windows_NT'){throw 'Windows is required.'}
    New-Item $runPath -ItemType Directory -Force|Out-Null

    Get-CimInstance Win32_OperatingSystem|
        Select-Object Caption,Version,LastBootUpTime,TotalVisibleMemorySize,FreePhysicalMemory|
        Export-Csv (Join-Path $runPath 'MemorySnapshot.csv') -NoTypeInformation
    Get-CimInstance Win32_Processor|
        Select-Object Name,NumberOfCores,NumberOfLogicalProcessors,LoadPercentage,CurrentClockSpeed|
        Export-Csv (Join-Path $runPath 'ProcessorSnapshot.csv') -NoTypeInformation
    Get-Volume -ErrorAction SilentlyContinue|
        Select-Object DriveLetter,FileSystemLabel,HealthStatus,Size,SizeRemaining|
        Export-Csv (Join-Path $runPath 'Volumes.csv') -NoTypeInformation

    Get-Process|Sort-Object CPU -Descending|Select-Object -First 25 Name,Id,CPU,WorkingSet,PrivateMemorySize,HandleCount,ThreadCount|
        Export-Csv (Join-Path $runPath 'TopProcessesByCPU.csv') -NoTypeInformation
    Get-Process|Sort-Object WorkingSet -Descending|Select-Object -First 25 Name,Id,CPU,WorkingSet,PrivateMemorySize,HandleCount,ThreadCount|
        Export-Csv (Join-Path $runPath 'TopProcessesByMemory.csv') -NoTypeInformation

    try{
        $samples=[math]::Max(1,[math]::Floor($DurationSeconds/$SampleInterval))
        Get-Counter -Counter '\Processor(_Total)\% Processor Time','\Memory\Available MBytes','\PhysicalDisk(_Total)\Avg. Disk Queue Length' `
            -SampleInterval $SampleInterval -MaxSamples $samples -ErrorAction Stop|
            Export-Counter -Path (Join-Path $runPath 'PerformanceSamples.csv') -FileFormat CSV -Force
    }catch{$warnings.Add("Performance counters: $($_.Exception.Message)")}

    try{
        Get-WinEvent -FilterHashtable @{LogName='System';Level=1,2,3;StartTime=(Get-Date).AddDays(-3)} -MaxEvents 200 -ErrorAction Stop|
            Select-Object TimeCreated,Id,LevelDisplayName,ProviderName,Message|
            Export-Csv (Join-Path $runPath 'RecentSystemEvents.csv') -NoTypeInformation
    }catch{$warnings.Add("System events: $($_.Exception.Message)")}

    $warnings|Out-File (Join-Path $runPath 'Warnings.txt')
    Write-Host "[OK] Performance report created: $runPath" -ForegroundColor Green
    if($warnings.Count -gt 0){exit 2}else{exit 0}
}catch{Write-Error $_.Exception.Message;exit 1}
