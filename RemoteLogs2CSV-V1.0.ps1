[CmdletBinding()]
Param (
    [Parameter(Mandatory=$false)]
    [string]$output="C:\Users\Administrator\Documents\Recolector\Logs\Externos",
    [Parameter(Mandatory=$false)]
    $logTag = $env:ComputerName
)

Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser

##Creación de llaves para el encriptado
$key = "C:\Users\Administrator\Documents\Recolector\Keys\PublicPGP.asc"

# Obtener la fecha actual en el formato deseado
$CurrentDate = Get-Date -Format 'yyyy-MM-dd'
$startTime = Get-Date $CurrentDate
$endTime = $startTime.AddDays(1)

# Construir la carpeta para la fecha actual
$folderPath = Join-Path -Path $output -ChildPath $CurrentDate
New-Item -ItemType Directory -Force -Path $folderPath | Out-Null

# Construir el nombre completo del log
$LogFullName = "$logTag-ForwardedEvents"
$LogPath = Join-Path -Path $folderPath -ChildPath "$LogFullName-$CurrentDate.csv"

Try {
    # Obtener eventos Forwarded Events de la computadora local
    Get-WinEvent -LogName ForwardedEvents -FilterXPath ("<QueryList><Query Id='0' Path='ForwardedEvents'><Select Path='ForwardedEvents'>*[System[TimeCreated[@SystemTime&gt;='{0:yyyy-MM-ddTHH:mm:ss}' and @SystemTime&lt;'{1:yyyy-MM-ddTHH:mm:ss}']]]</Select></Query></QueryList>" -f $startTime, $endTime) -ErrorAction Stop |
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
            Remove-Item $folderPath\*.pgp
}
Catch {
    Write-Verbose "No se pudieron encontrar registros en ForwardedEvents en la fecha $CurrentDate."
}

Protect-PGP -FilePathPublic $key -FolderPath $folderPath -OutputFolderPath $folderPath
Remove-Item $folderPath\*.csv
