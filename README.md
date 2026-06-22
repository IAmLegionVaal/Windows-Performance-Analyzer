# Windows Performance Analyzer

> **Testing note:** This was tested by me to be working. User experience may vary.

Included: `Analyze-WindowsPerformance.ps1`

```powershell
.\Analyze-WindowsPerformance.ps1
.\Analyze-WindowsPerformance.ps1 -DurationSeconds 60 -SampleInterval 5
```

Creates read-only reports for CPU, memory, volumes, top processes, performance samples and recent system events.

Reports: `C:\Users\Public\Documents\WindowsPerformanceReports`

Exit codes: `0` success, `1` fatal error, `2` warnings.

Counter names can vary on non-English Windows installations. MIT License.
