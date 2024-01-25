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
$folderPath = Join-Path -Path $output -ChildPath $logTag -ErrorAction SilentlyContinue
if (-not (Test-Path -Path $folderPath)) {
    New-Item -ItemType Directory -Force -Path $folderPath | Out-Null
}

$folderPath = Join-Path -Path $folderPath -ChildPath $CurrentDate
New-Item -ItemType Directory -Force -Path $folderPath | Out-Null

# Log ForwardedEvents
$LogFullName = "$logTag-ForwardedEvents"
$LogPath = Join-Path -Path $folderPath -ChildPath "$LogFullName-$CurrentDate.csv"

# Obtener eventos del log ForwardedEvents
Try {
    Get-WinEvent -LogName ForwardedEvents -ErrorAction Stop |
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
    Write-Verbose "No se pudieron encontrar registros en el log ForwardedEvents en la fecha $CurrentDate."
}

