[CmdletBinding()]
Param (
    [Parameter(Mandatory=$false)]
    [string]$output="C:\Users\Segadmin\Documents\EVTVW",
    [Parameter(Mandatory=$false)]
    $logTag = $env:ComputerName,
    [Parameter(Mandatory=$false)]
    $remoteServers = @("Server1", "Server2")  # Lista de servidores remotos
)

# Obtener la fecha actual en el formato deseado
$CurrentDate = Get-Date -Format 'yyyy-MM-dd'

foreach ($remoteServer in $remoteServers) {
    # Crear una carpeta para el día actual en el servidor remoto
    $folderPath = "\\$remoteServer\$output\$CurrentDate"
    New-Item -ItemType Directory -Force -Path $folderPath | Out-Null

    # Lista de logs a exportar
    $logsToExport = @("Security", "Application", "System")

    foreach ($logName in $logsToExport) {
        $LogFullName = "$logTag-$logName"
        $LogPath = Join-Path -Path $folderPath -ChildPath "$LogFullName-$CurrentDate.csv"

        $startTime = Get-Date $CurrentDate
        $endTime = $startTime.AddDays(1)

        Try {
            Get-WinEvent -ComputerName $remoteServer -LogName ForwardedEvents -FilterXPath ("<QueryList><Query Id='0' Path='ForwardedEvents'><Select Path='ForwardedEvents'>*[System[TimeCreated[@SystemTime&gt;='{0:yyyy-MM-ddTHH:mm:ss}' and @SystemTime&lt;'{1:yyyy-MM-ddTHH:mm:ss}'] and EventRecordID= '{2}']]</Select></Query></QueryList>" -f $startTime, $endTime, $logName) -ErrorAction Stop |
                ## Filtra por el providerName
                Where-Object { ($_.ProviderName -ne 'SynTPEnhService') } |
                Select-Object @{Name="containerLog";Expression={$LogFullName}},
                    @{Name="id";Expression={$_.Id}},
                    @{Name="levelDisplayName";Expression={$_.LevelDisplayName}},
                    MachineName,
                    @{Name="LogName";Expression={$LogFullName}},
                    ProcessId,
                    @{Name="UserId";Expression={$_.Properties[8].Value}},
                    @{Name="ProviderName";Expression={$_.ProviderName}},
                    @{Name="TimeCreated";Expression={$_.TimeCreated.ToUniversalTime().ToString('yyyy-MM-dd HH:mm:ssZ')}},
                    @{Name="Message";Expression={$_.Message -replace "\r\n"," | " -replace "\n", " | " -replace "The local computer may not have the necessary registry information or message DLL files to display the message, or you may not have permission to access them.",""}} | 
                    Export-Csv -NoTypeInformation -Path $LogPath
        }
        Catch {
            Write-Verbose "No se pudieron encontrar registros en el log ForwardedEvents en el servidor $remoteServer para el log $logName en la fecha $CurrentDate."
        }
    }
}
