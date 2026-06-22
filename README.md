# Windows Performance Analyzer

> **Testing note:** This was tested by me to be working. User experience may vary.

## One-click use

1. Download and extract the repository.
2. Double-click `Run-OneClick.bat`.
3. The default 30-second performance capture runs directly—there is no menu and no configuration is changed.
4. Review the exit code and reports under `C:\Users\Public\Documents\WindowsPerformanceReports`.

Included: `Analyze-WindowsPerformance.ps1`

## PowerShell usage

```powershell
.\Analyze-WindowsPerformance.ps1
.\Analyze-WindowsPerformance.ps1 -DurationSeconds 60 -SampleInterval 5
```

Creates read-only reports for CPU, memory, volumes, top processes, performance samples and recent system events.

Exit codes: `0` success, `1` fatal error, `2` warnings.

Counter names can vary on non-English Windows installations. MIT License.
