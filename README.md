	Proyecto de Automatización de Recopilación y Análisis de Logs
Descripción del Proyecto
El objetivo de este proyecto es desarrollar un sistema que permita la recolección y análisis automatizado de logs del sistema operativo Windows. Para lograr esto, se utilizarán scripts de PowerShell para la exportación de logs a formato CSV, y una aplicación Java para procesar y analizar estos registros.

	Índice
 
1.1 Introducción

1.2 Configuración del entorno

2.1 Recolector de logs locales

2.2 Recolector de logs externos

3 Aplicacion Java

4 Recomendacione

5 Redes sociales

	1.1 : Introducción

El proyecto utiliza un servidor como colector de eventos los cuales se envian a traves del Windows Event Forwarding (WEF) hacia el Windows Event Collector (WEC) server. Desde nuestro colector creamos una suscripción para que todos los logs que deseemos se reciban en este servidor.
Luego los scripts se encargan de descargar a CSV los logs correspondientes y separarlos en la ubicación que elegimos. Guarda por separado los eventos de nuestro WEC, genearando una carpeta con la fecha correspondiente y un CSV para cada log seleccionado, y los Forwarded event.

	1.2 : Configuración del entorno

Antes de ejecutar los scripts de PowerShell, debemos asegurarnos de configurar correctamente el WEC y los WEF:

Para configurar el WEF primero debemos habilitar el remote managment en cada uno de nuestros equipos que deseemos que envien eventos. Podemos hacerlo con el comando winrm quickconfig en la terminal. Puede verse mas detallado en:

https://learn.microsoft.com/es-es/windows/win32/winrm/installation-and-configuration-for-windows-remote-management

Luego debemos establecerle el rol correspondientes como lector del registro de eventos a nuestro WEC. Pueden ver el paso a paso de como agregar a un grupo local en:

https://dronesenlasaulas.es/tutoriales/usuarios-y-grupos-locales-de-windows-10/

A continuación debemos configurar nuestro WEC. Desde el event viewer en la pestaña suscripciones podemos crear la suscripcion que querramos. Allí estableceremos el nombre, el registro destino (Forwarded event), los equipos de los cuales deseamos recopilar sus logs, los eventos a recolectar, etc.

Todos los archivos se guardaran encriptados. Para ello utilizamos el modulo PSPGP el cual nos brinda los algunos scripts utiles para el encriptado PGP. En el siguiente link podrán ver como importar el modulo, crear las llaves, etc:

https://github.com/EvotecIT/PSPGP

	2. Scripts de PowerShell

Ya configurado nuestro entorno comenzaremos a recibir en el Forwarded event todos los logs correspondientes de cada ordenador, por lo que ahora implementaremos ambos scripts.
Algunas de las ventajas que tiene cada uno de ellos es que son muy customizables; cuentan con diversos filtros para que solo se obtengan los logs de la fecha en cuestion (con el -FilterXPath), otros para excluir algun log no deseado (mediante el Where-Object), entre otros.

	2.1 Exportador de Logs locales a Formato CSV
 
Este script de PowerShell se encarga de exportar logs de los eventos de System, Security, Setup y Application del día actual a archivos CSV. Además, crea una carpeta correspondiente a la fecha y aplica filtros para excluir eventos no deseados.

En la variable $output tendremos la ruta donde se guardara el registro, $logsToExport son los registros a exportar, $logTag es el nombre del ordenador y $logName el nombre del log.

El Script cuenta con dos filtros, el -FilterXPath el cual filtra por la fecha pero puede ser editado para filtrar por lo que uno desee, y el Where-Object el cual nos permite hacer una capa extra para el filtrado de registros que no sean importantes para nosotros. 

Luego arma nuestro registro con el Select-Object y lo exporta con el Export-Csv al $LogPath. Al finalizar de exportar todos los csv el script los encripta y elimina los archivos csv duplicados dejando unicamente los encriptados en formato PGP.

	2.2 Exportador de Forwarded event
 
Este script de PowerShell se encarga unicamenten de exportar logs de los eventos recibidos en el WEC, los cuales se encuentran en el Forwarded event. Al igual que el anterior los filtra por el día correspondiente, excluyendo los eveentos no deseados, y los exporta a una carpeta.

Este script esta separado del anterior para poder darle la frecuencia que deseemos a la recoleccion de los registros que obtenemos en nuestro WEC.

	3. Aplicación Java
 
La aplicación Java se encargará de procesar y analizar los archivos CSV generados por los scripts de PowerShell. Desarrolle la aplicación Java para realizar las siguientes tareas:

Leer y cargar archivos CSV generados por los scripts de PowerShell.
Implementar lógica de análisis y procesamiento de logs según los requisitos del proyecto.
Generar informes, estadísticas o cualquier otra salida necesaria.

Adjunto el link del repositorio: 

https://github.com/tomasgentilee/openSiem/tree/main

	4. Recomendaciones

Una recomendación para que la recolección se realice de manera automatica es crear la tarea para la ejecución del script desde el programador de tareas de Windows. De esta manera le podremos dar la frecuencia que querramos a la descarga de los registros. Puede ver como crear la tarea en el siguiente video: 

https://www.youtube.com/watch?v=CJw_JEt_L6I&ab_channel=RicardoAniceto

	5. Redes sociales

Brindo mi linkedin para cualquier recomendación que deseen realizarme. También allí ire publicando cosas del proyecto:

https://www.linkedin.com/in/tom%C3%A1s-gentile/
