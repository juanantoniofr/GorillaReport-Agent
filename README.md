## About GorillaReport Agent

Un conjunto de scripts de PowerShell y Python, que generan y envían informes de estado de un Pc gestionado con [Gorilla](https://github.com/1dustindavis/gorilla) a la utilidad web GorillaReport. Su objetivo principal es analizar el archivo de logs de [Gorilla](https://github.com/1dustindavis/gorilla), que es un archivo en texto plano, parsearlo a formato JSON y enviarlo a [gorillaReport](https://github.com/juanantoniofr/gorillareport). 

De esta manera, centralizamos la monitorización de las tareas realizadas con [Gorilla](https://github.com/1dustindavis/gorilla).

## Synopsis

    El conjunto de scripts gorillaReport-Agent realizan las siguientes tareas:
    
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

## Config
    Revisar y/o modificar EN ESTE ORDEN (IMPORTANTE):

    *************************************************************************************
    **********************************  PACKAGES   **************************************
    *************************************************************************************
    1 - Copiar la carpeta gorillaReport en /var/www/html/packages	

    2 - Adaptar las variables de este script a nuestro entorno:
      packages\gorillaReport\scripts\create_scheduled_task_gorilla_report.ps1
        - $gorillaserver = "http://gorillaserver"
        - $User = "user_name"
        - $Passwd = "user_pass"

    3 - Adaptar las variables de este script a nuestro entorno:
      packages\gorillaReport\scripts\create_scheduled_task_gorilla_report.ps1
        # puedes poner hasta el tercer octeto de la IP de tu rango de aulas o entorno de pruebas
        # para aulas: "10.1.21."
        # para multipass: "172."
        - $ip_pattern = "172." 

    4 - Adaptar las variables de este script a nuestro entorno:
      packages\gorillaReport\scripts\register_client.ps1
        - $gorillaserver = "http://gorillaserver"
          - $file = "https://github.com/PowerShell/PowerShell/releases/download/v7.3.4/PowerShell-7.3.4-win-x64.msi"
          - $outputFile = "$homedir\AppData\Local\Temp\PowerShell-7.3.4-win-x64.msi"
          - msiexec.exe /i "$homedir\AppData\Local\Temp\PowerShell-7.3.4-win-x64.msi" /qn

    5 - Adaptar las variables del script "parser" de python a nuestro entorno:
      packages\gorillaReport\modules\python_gorilla_parser\main.py
        - new_gorilla_report_output_directory = 'C:\gorilla'
        - new_gorilla_report_filename = 'CustomGorillaReport.json'


    *************************************************************************************
    ***********************************  CATALOG   **************************************
    *************************************************************************************

    6 - Anadir las tareas de gorillaReport/catalogs/catalog.yaml al catalogo de nuestro servidor:
      -> Tarea "Python3.11.2"
      -> Tarea "init_gorillaReport_client"
      -> Tarea "create_scheduled_task_gorilla_report"

    7 - Revisar que los hashes de las tareas de nuestro catalogo son correctos
      -> Tarea "Python3.11.2": comprobar que el hash es correcto
      -> Tarea "init_gorillaReport_client": comprobar que el hash es correcto
      -> Tarea "create_scheduled_task_gorilla_report": comprobar que el hash es correcto



    *************************************************************************************
    **********************************  MANIFEST   **************************************
    *************************************************************************************
    8 - Anadir las siguientes lineas al manifest/s que se despliegue en los clientes:
        ...
        ...
        managed_installs:
          - Python
          - init_gorillaReport_client
          - create_scheduled_task_gorilla_report
          ...
          ...


    *************************************************************************************
    ************************* DNS Clientes para gorillaReport: **************************
    *************************************************************************************
    9 - Obtener la IP de nuestro servidor de gorillaReport
      -> multipass list
      
    10 - Anadir a los clientes de Gorilla la siguiente linea en "C:\Windows\System32\drivers\etc\hosts":
      -> X.X.X.X gorillareport (donde X.X.X.X es la IP de gorillaReport)
      -> X.X.X.X gorillaserver (donde X.X.X.X es la IP de gorillaServer)


## Authors

- [Luis Vela](https://github.com/luivelmor)
- [Juan Antonio](https://github.com/juanantoniofr)

## Contact

- Email:  luisvela@us.es | juanafr@us.es

## Licence

- GNU General Public License v3.0. https://www.gnu.org/licenses/gpl-3.0.html

