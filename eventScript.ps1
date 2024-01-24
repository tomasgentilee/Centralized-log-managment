$ScriptStartTime = (Get-Date).Date.AddDays(-1)
$ScriptEndTime = (Get-Date).Date

$LogOutputDirectory = 'C:\Users\Segadmin\Documents\EVTVW Export'

$EventTypesToExport = @('Application', 'Security', 'Setup', 'System')

foreach ($EventType in $EventTypesToExport)
{
        $LogOutputTopic = "$EventType Log"
        $CurrentTimeUTC = Get-Date
        $LogOutputFileName = "$CurrentTimeUTC - $LogOutputTopic"
        $LogOutputCSVFilePath = "$LogOutputDirectory\$LogOutputFileName.csv"

        Get-WinEvent -FilterHashtable @{logname="$EventType";StartTime="$ScriptStartTime"} |  Export-CSV -Path "$LogOutputCSVFilePath"
}
