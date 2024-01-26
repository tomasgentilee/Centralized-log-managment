##Exportador de logs de System, Security y Application a formato CSV.
##Se genera la carpeta correspondiente de la fecha de los logs, con el $folderPath
##Se filtran los logs, unicamente obteniendo los del día en cuestión, para ellos se utiliza el -FilterXPath con los QueryList
#Nuevo filtro para evitar algunos proveedores que no queremos registrar, utilizando el Where-Object

[CmdletBinding()]
Param (
    [Parameter(Mandatory=$false)]
    [string]$output="C:\Users\Segadmin\Documents\EVTVW",
    [Parameter(Mandatory=$false)]
    $logTag = $env:ComputerName
)

# Obtener la fecha actual en el formato deseado
$CurrentDate = Get-Date -Format 'yyyy-MM-dd'

# Crear una carpeta para el día actual
$folderPath = Join-Path -Path $output -ChildPath $CurrentDate
New-Item -ItemType Directory -Force -Path $folderPath | Out-Null

# Lista de logs a exportar
$logsToExport = @("Security", "Application", "System", "Setup")

foreach ($logName in $logsToExport) {
    $LogFullName = "$logTag-$logName"
    $LogPath = Join-Path -Path $folderPath -ChildPath "$LogFullName-$CurrentDate.csv"

    $startTime = Get-Date $CurrentDate
    $endTime = $startTime.AddDays(1)

    Try {
        Get-WinEvent -LogName $logName -FilterXPath ("<QueryList><Query Id='0' Path='$logName'><Select Path='$logName'>*[System[TimeCreated[@SystemTime&gt;='{0:yyyy-MM-ddTHH:mm:ss}' and @SystemTime&lt;'{1:yyyy-MM-ddTHH:mm:ss}']]]</Select></Query></QueryList>" -f $startTime, $endTime) -ErrorAction Stop |
            ##Filtra por el providerName
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
        Write-Verbose "No se pudieron encontrar registros en el log $logName en la fecha $CurrentDate."
    }
}
