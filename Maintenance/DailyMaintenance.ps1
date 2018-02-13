$goodRun = $true

Get-EventLog -LogName DailyMaint -ErrorAction SilentlyContinue -ErrorVariable eventLogErr | out-null
if($eventLogErr){
    
    New-EventLog -Source "DailyMaintenanceScript" -LogName "DailyMaint" 
}

#check disk utilization
$diskc = get-wmiobject win32_logicaldisk -Filter "DeviceID='C:'" | select Size,Freespace
$percentC = ($diskc.Freespace/$diskc.Size)*100

if($percentC -lt 10){
    Write-EventLog -LogName DailyMaint -Source DailyMaintenanceScript -Message "Drive C is at less than 10% capacity" -EventId 0 -EntryType Error 
    $goodRun = $false
}elseif($percentC -gt 10 -and $percentC -lt 15){
    Write-EventLog -LogName DailyMaint -Source DailyMaintenanceScript -Message "Drive C is at less than 15% capacity" -EventId 0 -EntryType Warning
    $goodRun = $false
}

#CPU utilization percentage
$CPU = Get-CimInstance win32_processor | Measure-Object -property LoadPercentage -Average | Select -ExpandProperty Average

if($cpu -gt 90){
    Write-EventLog -LogName DailyMaint -Source DailyMaintenanceScript -Message "CPU utilization above 90%" -EventId 2 -EntryType Error
    $goodRun = $false
}elseif($CPU -gt 80 -and $CPU -lt 90){
    Write-EventLog -LogName DailyMaint -Source DailyMaintenanceScript -Message "CPU utilization above 80%" -EventId 2 -EntryType Warning
    $goodRun = $false
}

#RAM utilization
$OS = Get-CimInstance Win32_OperatingSystem 
$memory = (($OS.TotalVisibleMemorySize - $OS.FreePhysicalMemory)/$OS.TotalVisibleMemorySize)*100

if($memory -gt 90){
    Write-EventLog -LogName DailyMaint -Source DailyMaintenanceScript -Message "Ram usage is above 90%" -EventId 3 -EntryType Error
    $goodRun = $false
}

#check failed logins
$securityLogs = GET-EVENTLOG -Logname Security | where { $_.EntryType -eq 'FailureAudit'} 
$secLogCount = $securityLogs | Group-Object -Property source -NoElement | Sort-Object -Property count -Descending | select -ExpandProperty "Count"
if($secLogCount -gt 30){
    Write-EventLog -LogName DailyMaint -Source DailyMaintenanceScript -Message "There are over 30 Failed logins in the Security event log!" -EventID 1 -EntryType Error
    $goodRun = $false
}elseif($secLogCount-gt 20 -and $secLogCount -lt 30){
    Write-EventLog -LogName DailyMaint -Source DailyMaintenanceScript -Message "There are over 20 Failed logins in the Security event log!" -EventID 1 -EntryType Warning
    $goodRun = $false

}


#Check error events
$systemLogs = GET-EVENTLOG -Logname System | where { $_.EntryType -eq 'Error' }
$sysLogCount = $systemLogs | Group-Object -Property source -NoElement | Sort-Object -Property count -Descending | select -ExpandProperty "Count"
if($sysLogCount -gt 50){
    Write-EventLog -LogName DailyMaint -Source DailyMaintenanceScript -Message "There are over 50 Errors in the System event log!" -EventID 3 -EntryType Error
    $goodRun = $false
}elseif($sysLogCount-gt 30 -and $sysLogCount -lt 50){
    Write-EventLog -LogName DailyMaint -Source DailyMaintenanceScript -Message "There are over 30 Errors in the System event log!" -EventID 3 -EntryType Warning
    $goodRun = $false
}

#get backup summary
$LastSucBack = Get-WBSummary | select -ExpandProperty LastSuccessfulBackupTime
$LastBack = Get-WBSummary | select -ExpandProperty LastBackupTime
if($LastSucBack -ne $LastBack){
        Write-EventLog -LogName DailyMaint -Source DailyMaintenanceScript -Message "The system missed the previous backup" -EventID 4 -EntryType Warning
        $goodRun = $false
}

#if everything passes
if($goodRun -eq $true){
        Write-EventLog -LogName DailyMaint -Source DailyMaintenanceScript -Message "Today's tests all passed" -EventID 5 -EntryType Information
}else{
    #possibly email support that an error occured
}