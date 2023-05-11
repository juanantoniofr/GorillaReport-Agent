## About GorillaReport Agent

Un conjunto de scripts de PowerShell y Python, que generan y envían informes de estado de un Pc gestionado con [Gorilla](https://github.com/1dustindavis/gorilla) a la utilidad web GorillaReport. Su objetivo principal es analizar el archivo de logs de [Gorilla](https://github.com/1dustindavis/gorilla), que es un archivo en texto plano, parsearlo a formato JSON y enviarlo a [gorillaReport](https://github.com/juanantoniofr/gorillareport). 

De esta manera, centralizamos la monitorización de las tareas realizadas con [Gorilla](https://github.com/1dustindavis/gorilla).

# SCRIPTS

  - init_gorillaReport_client.ps1
  - register_client
  - register_basic_info
  - register_gorilla_report

# CONFIG


Para conectar gorillaReport-Agent con el servidor gorillarReport y con el servidor de Gorilla, tenemos que configurar las variables siguientes:

* $gorillaserver

Editar el fichero init_gorillaReport_client.ps1 para establecer la IP o hostname del Servidor gorilla. 

* $gr_server

Editar el fichero GRModule.psm1 para establecer la IP o hostname del Servidor gorillaReport. 

Ejemplos:

    $gorillaserver = "gorillaserver.lc:8080"
    $gorillaserver = "10.1.XX.XX"


    $gr_server = "gorillareport:4444"
    $gr_server = "10.1.XX.XX"

# SYNOPSIS: 

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

# AUTHORS

- [Luis Vela](https://github.com/luivelmor)
- [Juan Antonio](https://github.com/juanantoniofr)

# contact

- Email:  luisvela@us.es | juanafr@us.es

# Licence

- GNU General Public License v3.0. https://www.gnu.org/licenses/gpl-3.0.html

