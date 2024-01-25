[CmdletBinding()]
Param (
    [Parameter(Mandatory=$false)]
    [string]$output="C:\Users\Segadmin\Documents\EVTVW",
    [Parameter(Mandatory=$false)]
    $logTag = $env:ComputerName
)

# Obtener la fecha actual en el formato deseado
$CurrentDate = Get-Date -Format 'yyyy-MM-dd'

# Crear una carpeta para la máquina actual
$machineFolderPath = Join-Path -Path $output -ChildPath $logTag -ErrorAction SilentlyContinue
if (-not (Test-Path -Path $machineFolderPath)) {
    New-Item -ItemType Directory -Force -Path $machineFolderPath | Out-Null
}

# Log ForwardedEvents
$LogFullName = "$logTag-ForwardedEvents"
$forwardedEventsFolderPath = Join-Path -Path $machineFolderPath -ChildPath $CurrentDate
New-Item -ItemType Directory -Force -Path $forwardedEventsFolderPath | Out-Null

# Obtener eventos del log ForwardedEvents y separarlos por tipo (Security, System, Application)
Try {
    $forwardedEvents = Get-WinEvent -LogName ForwardedEvents -ErrorAction Stop

    $securityEvents = $forwardedEvents | Where-Object { $_.Id -eq 4624 -or $_.Id -eq 4625 } # Puedes ajustar los ID según tus necesidades
    $systemEvents = $forwardedEvents | Where-Object { $_.Id -eq 1074 -or $_.Id -eq 6005 } # Puedes ajustar los ID según tus necesidades
    $applicationEvents = $forwardedEvents | Where-Object { $_.Id -eq 1001 -or $_.Id -eq 1002 } # Puedes ajustar los ID según tus necesidades

    $securityLogPath = Join-Path -Path $forwardedEventsFolderPath -ChildPath "$LogFullName-Security-$CurrentDate.csv"
    $systemLogPath = Join-Path -Path $forwardedEventsFolderPath -ChildPath "$LogFullName-System-$CurrentDate.csv"
    $applicationLogPath = Join-Path -Path $forwardedEventsFolderPath -ChildPath "$LogFullName-Application-$CurrentDate.csv"

    $securityEvents | Export-Csv -NoTypeInformation -Path $securityLogPath
    $systemEvents | Export-Csv -NoTypeInformation -Path $systemLogPath
    $applicationEvents | Export-Csv -NoTypeInformation -Path $applicationLogPath
}
Catch {
    Write-Verbose "No se pudieron encontrar registros en el log ForwardedEvents en la fecha $CurrentDate."
}
