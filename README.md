## About GorillaReport Agent

Un conjunto de scripts de PowerShell y Python, que generan y envían informes de estado de un Pc gestionado con [Gorilla](https://github.com/1dustindavis/gorilla) a la utilidad web GorillaReport. Su objetivo principal es analizar el archivo de logs de [Gorilla](https://github.com/1dustindavis/gorilla), que es un archivo en texto plano, parsearlo a formato JSON y enviarlo a [gorillaReport](https://github.com/juanantoniofr/gorillareport). 

De esta manera, centralizamos la monitorización de las tareas realizadas con [Gorilla](https://github.com/1dustindavis/gorilla).


## Config
El fichero "configuraciones_despliegue.txt" contiene la descripción de las variables a configurar en cada uno de los scripts contenidos en la carpeta "packages/gorillaReport/scripts" para que el entorno funcione correctamente


## Synopsis

    El conjunto de script gorillaReport-Agent realizan las siguientes tareas:
    
      1 - Instala python y powershell 7.
      2 - Crea los directorios de gorillaReport en el cliente.
      3 - Descarga el modulo GRmodule.psm1  y el parser en python del servidor de gorilla.
      4 - Hace disponible el módulo gorillaReport.psm1 para todos los scripts de powershell.
      5 - Descarga scripts para realizar reportes.
      6 - Hace uso de la API definida en gorillaReport para:
          6.1 - Registar el equipo.
          6.2 - Enviar información básica del equipo: sistema (SO, Build, Hostname..) y dispositivo (CPU, RAM,...).
          6.3 - Parsea fichero de log de gorilla a formato JSON.
          6.4 - Envía fichero de log de gorilla parseado.

## Authors

- [Luis Vela](https://github.com/luivelmor)
- [Juan Antonio](https://github.com/juanantoniofr)

## Contact

- Email:  luisvela@us.es | juanafr@us.es

## Licence

- GNU General Public License v3.0. https://www.gnu.org/licenses/gpl-3.0.html

