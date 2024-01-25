[CmdletBinding()]
Param (
    [Parameter(Mandatory=$false)]
    [string]$output="C:\Ruta\Donde\Guardar\Logs",
    [Parameter(Mandatory=$false)]
    $logTag = $env:ComputerName
)

# Obtener la fecha actual en el formato deseado
$CurrentDate = Get-Date -Format 'yyyy-MM-dd'

# Construir la carpeta para la fecha actual
$folderPath = Join-Path -Path $output -ChildPath $CurrentDate
New-Item -ItemType Directory -Force -Path $folderPath | Out-Null

# Construir el nombre completo del log
$LogFullName = "$logTag-ForwardedEvents"
$LogPath = Join-Path -Path $folderPath -ChildPath "$LogFullName-$CurrentDate.csv"

Try {
    # Obtener eventos Forwarded Events de la computadora local
    Get-WinEvent -LogName ForwardedEvents -ErrorAction Stop |
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
    Write-Verbose "No se pudieron encontrar registros en ForwardedEvents en la fecha $CurrentDate."
}
