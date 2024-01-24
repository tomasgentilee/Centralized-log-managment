[CmdletBinding()]
Param (
    [Parameter(Mandatory=$false)]
    [string]$output="C:\Users\Segadmin\Documents\EVTVW",
    [Parameter(Mandatory=$false)]
    $excludeEvtxFiles = ((get-eventlog -list) | foreach-object{$_.log}),
    [Parameter(Mandatory=$false)]
    $logTag = $env:ComputerName,
    [Parameter(Mandatory=$false)]
    $CurrentDate = "-" + (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')   
)

if ($excludeEvtxFiles) {
    $excludeEvtxFiles | ForEach-Object {
        $LogName = "$LogTag-" + $_
        Try {
            Get-EventLog $_ -ErrorAction Stop |
                select @{name="containerLog";expression={$LogName}},
                    @{name="id";expression={$_.EventID}},
                    @{name="levelDisplayName";expression={$_.EntryType}},
                    MachineName,
                    @{name="LogName";expression={$LogName}},
                    ProcessId,
                    @{name="UserId";expression={$_.UserName}},
                    @{name="ProviderName";expression={$_.source}},
                    @{Name="TimeCreated";expression={(($_.TimeGenerated).ToUniversalTime()).ToString('yyyy-MM-dd HH:mm:ssZ')}},
                    @{Name="Message";expression={$_.message -replace "\r\n"," | " -replace "\n", " | " -replace "The local computer may not have the necessary registry information or message DLL files to display the message, or you may not have permission to access them.",""}} | 
               Export-Csv -NoTypeInformation ($output + "\" + "$LogTag-" + $_ + ".csv")
        }
        Catch {
            Write-Verbose "Previous Log doesn't have any records. No output will be produced"
        }
        
    }
}