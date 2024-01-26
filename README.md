	Proyecto de Automatización de Recopilación y Análisis de Logs
Descripción del Proyecto
El objetivo de este proyecto es desarrollar un sistema que permita la recolección y análisis automatizado de logs del sistema operativo Windows. Para lograr esto, se utilizarán scripts de PowerShell para la exportación de logs a formato CSV, y una aplicación Java para procesar y analizar estos registros.

	Índice
 
1.1 Introducción

1.2 Configuración del entorno

2.1 Recolector de logs locales

2.2 Recolector de logs externos

3 Aplicacion Java


	1.1 : Introducción

El proyecto utiliza un servidor como colector de eventos los cuales se envian a traves del Windows Event Forwarding (WEF) hacia el Windows Event Collector (WEC) server. Desde nuestro colector creamos una suscripción para que todos los logs que deseemos se reciban en este servidor.
Luego los scripts se encargan de descargar a CSV los logs correspondientes y separarlos en la ubicación que elegimos. Guarda por separado los eventos de nuestro WEC, genearando una carpeta con la fecha correspondiente y un CSV para cada log seleccionado, y los Forwarded event.

	1.2 : Configuración del entorno

Antes de ejecutar los scripts de PowerShell, debemos asegurarnos de configurar correctamente el WEC y los WEF:

Para configurar el WEF primero debemos habilitar el remote managment en cada uno de nuestros equipos que deseemos que envien eventos. Podemos hacerlo con el comando winrm quickconfig en la terminal. Puede verse mas detallado en:

https://learn.microsoft.com/es-es/windows/win32/winrm/installation-and-configuration-for-windows-remote-management

Luego debemos establecerle el rol correspondientes como lector del registro de eventos a nuestro WEC. Pueden ver el paso a paso de como agregar a un grupo local en:

https://dronesenlasaulas.es/tutoriales/usuarios-y-grupos-locales-de-windows-10/

Por ultimo debemos configurar nuestro WEC. Desde el event viewer en la pestaña suscripciones podemos crear la suscripcion que querramos. Allí estableceremos el nombre, el registro destino (Forwarded event), los equipos de los cuales deseamos recopilar sus logs, los eventos a recolectar, etc.


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

Adjunto el link del repositorio: https://github.com/tomasgentilee/openSiem/tree/main

