[CmdletBinding()]
Param (
    [Parameter(Mandatory=$false)]
    [string]$output="C:\Users\Segadmin\Documents\EVTVW"
)

# Obtener la fecha actual en el formato deseado
$CurrentDate = Get-Date -Format 'yyyy-MM-dd'

# Lista de logs a exportar
$logsToExport = @("Security", "Application", "System")

foreach ($logName in $logsToExport) {
    $LogPath = Join-Path -Path $output -ChildPath $logName
    New-Item -ItemType Directory -Force -Path $LogPath | Out-Null

    Try {
        Get-WinEvent -LogName ForwardedEvents -FilterXPath ("<QueryList><Query Id='0' Path='ForwardedEvents'><Select Path='ForwardedEvents'>*[System[TimeCreated[@SystemTime&gt;='{0:yyyy-MM-ddTHH:mm:ss}' and @SystemTime&lt;'{1:yyyy-MM-ddTHH:mm:ss}']]]</Select></Query></QueryList>" -f $startTime, $endTime) -ErrorAction Stop |
            ## Filtra por el providerName
            Where-Object { ($_.ProviderName -ne 'SynTPEnhService') } |
            Group-Object -Property MachineName |
            ForEach-Object {
                $machineName = $_.Name
                $MachineFolderPath = Join-Path -Path $LogPath -ChildPath $machineName
                New-Item -ItemType Directory -Force -Path $MachineFolderPath | Out-Null

                $events = $_.Group
                $events |
                Select-Object @{Name="containerLog";Expression={$logName}},
                    @{Name="id";Expression={$_.Id}},
                    @{Name="levelDisplayName";Expression={$_.LevelDisplayName}},
                    MachineName,
                    @{Name="LogName";Expression={$logName}},
                    ProcessId,
                    @{Name="UserId";Expression={$_.Properties[8].Value}},
                    @{Name="ProviderName";Expression={$_.ProviderName}},
                    @{Name="TimeCreated";Expression={$_.TimeCreated.ToUniversalTime().ToString('yyyy-MM-dd HH:mm:ssZ')}},
                    @{Name="Message";Expression={$_.Message -replace "\r\n"," | " -replace "\n", " | " -replace "The local computer may not have the necessary registry information or message DLL files to display the message, or you may not have permission to access them.",""}} | 
                    Export-Csv -NoTypeInformation -Path (Join-Path -Path $MachineFolderPath -ChildPath "$logName-$CurrentDate.csv")
            }
    }
    Catch {
        Write-Verbose "No se pudieron encontrar registros en el log ForwardedEvents en la fecha $CurrentDate."
    }
}
