## About GorillaReport Agent

A set of PowerShell and Python scripts, which generates and sends computer status reports to the GorillaReport web utility. Its main objective is to parse the Gorilla log file, which is a plain text file, into JSON format and send it to the server. This way, we centralize the monitoring of installations made with Gorilla.

# SCRIPTS

  - init_gorillaReport_client.ps1
  - register_client
  - register_basic_info
  - register_gorilla_report

# CONFIG

Variables a cconfigurar:
* fichero init_gorillaReport_client.ps1

**$gorillaserver:** Set nameserver or IP of gorilla server

Examples:
1. $gorillaserver = "gorillaserver.lc:8080"
2. $gorillaserver = "10.1.XX.XX"


* fichero GRModule.psm1
**$gr_server:** Set Nameserver or IP gorillaReport server

Examples:
1. $gr_server = "gorillareport:4444"
2. $gr_server = "10.1.XX.XX"


# SYNOPSIS: 
    1 - Instala python y powershell 7
    2 - Crea los directorios de gorillaReport en el cliente.
    3 - Descarga el modulo GRmodule.psm1  y el parser en python del servidor de gorilla.
    4 - Hace disponible el módulo gorillaReport.psm1 para todos los scripts de powershell.
    5 - Descarga scripts para realizar reportes.
    6 - Registra el equipo
    7 - Envía información básica: sistema (SO, Build, Hostname..) y dispositivo (CPU, RAM,...)
    8 - Parsea fichero de log de gorilla a formato JSON
    9 - Envía fichero de log de gorilla parseado

# AUTHORS
    @Luis Vela Morilla - @Juan Antonio Fernández Ruiz
    Versión: 1.0
    Email:  luivelmor@us.es | juanafr@us.es
    Licencia: GNU General Public License v3.0. https://www.gnu.org/licenses/gpl-3.0.html

