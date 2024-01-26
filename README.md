	Proyecto de Automatización de Recopilación y Análisis de Logs
Descripción del Proyecto
El objetivo de este proyecto es desarrollar un sistema que permita la recolección y análisis automatizado de logs del sistema operativo Windows. Para lograr esto, se utilizarán scripts de PowerShell para la exportación de logs a formato CSV, y una aplicación Java para procesar y analizar estos registros.

	Índice
 
1.1 Configuraciones Iniciales

2.1 Recolector de logs locales

2.2 Recolector de logs externos

3 Aplicacion Java


	1. Configuraciones Iniciales
 
Antes de ejecutar los scripts de PowerShell y la aplicación Java, asegúrese de realizar las siguientes configuraciones iniciales:

Configuración del Entorno:

Asegúrese de que PowerShell está habilitado en su sistema.
Configure las políticas de ejecución de scripts en PowerShell si es necesario (Set-ExecutionPolicy).
Verifique la configuración de seguridad y permisos para acceder a los logs del sistema.
Especifique la ruta del directorio de salida ($output) en los scripts de PowerShell.

	2. Scripts de PowerShell

2.1 Exportador de Logs de System, Security y Application a Formato CSV
Este script de PowerShell se encarga de exportar logs de los eventos de System, Security y Application del día actual a archivos CSV. Además, crea una carpeta correspondiente a la fecha y aplica filtros para excluir eventos no deseados.

2.2 Segundo Script de PowerShell
Este espacio está reservado para la descripción del segundo script de PowerShell que se implementará en el proyecto. Incluya detalles sobre su función y configuración.

	3. Aplicación Java
 
La aplicación Java se encargará de procesar y analizar los archivos CSV generados por los scripts de PowerShell. Desarrolle la aplicación Java para realizar las siguientes tareas:

Leer y cargar archivos CSV generados por los scripts de PowerShell.
Implementar lógica de análisis y procesamiento de logs según los requisitos del proyecto.
Generar informes, estadísticas o cualquier otra salida necesaria.

Adjunto el link del repositorio: 

