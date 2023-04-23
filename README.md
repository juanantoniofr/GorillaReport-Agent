## About GorillaReport Agent

A set of PowerShell and Python scripts, which generates and sends computer status reports to the GorillaReport web utility. Its main objective is to parse the Gorilla log file, which is a plain text file, into JSON format and send it to the server. This way, we centralize the monitoring of installations made with Gorilla.

# SCRIPTS
  - init_gorillaReport_client.ps1
  - register_client
  - register_basic_info
  - register_gorilla_report
# SYNOPSIS: init_gorillaReport_client.ps1
    1 - Instala python y powershell 7
    2 - Crea los directorios de gorillaReport en el cliente.
    3 - Descarga el modulo GRmodule.psm1  y el parser en python del servidor de gorilla.
    4 - Hace disponible el módulo gorillaReport.psm1 para todos los scripts de powershell.
    5 - Descarga scripts para realizar reportes.

# DESCRIPTION
    1 - Instala python y powershell 7
        Instalar python3 y Powershell 7.4

    2 - Crea los directorios de gorillaReport en el cliente. 
        En el directorio home del usuario crea un directorio llamado gorillaReport, y los subdirectorios:
        - gorillaReport\scripts: directorio para los scripts de gorillaReport
        - gorillaReport\modules: directorio para los módulos de gorillaReport
        - gorillaReport\logs: directorio para los logs de gorillaReport
        - gorillaReport\reports: directorio para los informes de gorillaReport
        - gorillaReport\temp: directorio para los archivos temporales de gorillaReport

    3 - Descarga el modulo GRmodule.psm1 del servidor gorillaserver y lo guarda en la carpeta de modules del cliente.
        Si el modulo ya existe y no coincide el hash del fichero, lo sobreescribe.  
        Tambien descarga el script en python que parsea el fichero de logs de gorilla.      

    4 - Añade la ruta del módulo gorillaReport a la variable de entorno PSModulePath. Si la ruta ya está en la variable de entorno no hace nada.
        De esta forma, el módulo estará disponible de forma global y permanente para todos los scripts de powershell.
        Con esto conseguimos que los scripts de gorillaReport puedan importar el módulo de scripts de gorillaReport, teniendo acceso a variables y funciones definidas en él.
        Variables de entorno:
        - GR_SCRIPTS_PATH: ruta de los scripts de gorillaReport
        - GR_SCRIPTS_MODULE: directorio del módulo de scripts de gorillaReport

# NOTES
    Autores: Luis Vela Morilla, Juan Antonio Fernández Ruiz
    Fecha: 2023-03-03
    Versión: 1.0
    Email:  luivelmor@us.es | juanafr@us.es
    Licencia: GNU General Public License v3.0. https://www.gnu.org/licenses/gpl-3.0.html

