import json

# Texto plano
text = """
=== create_scheduled_task_set_default_printer ===
==> check
Script via: PowerShell
Stdout: 
Name                               Value                                                                                                                                                                                                                                               
----                               -----                                                                                                                                                                                                                                               
TaskPath                           \Microsoft\Windows\Printing\Set Default Printers                                                                                                                                                                                                
TaskName                           Set Default Printers                                                                                                                                                                                                                               
...

==> installing_ps1
Command executed: 
Download URL: 
Command output: 
Hash error: 
Download error: 
"""

# Inicializar diccionario JSON
json_output = {
    "task_name": "",
    "check_block": {
        "via": "",
        "stdout": []
    },
    "installing_ps1_block": {
        "command": [],
        "command_output": [],
        "hash_error": [],
        "download_error": []
    }
}

# Separar el texto por líneas
lines = text.strip().split('\n')

# Obtener nombre de tarea
json_output['task_name'] = lines[0].strip('=').strip()

# Obtener información de bloque "check"
check_block = json_output['check_block']
check_block['via'] = lines[2].split(':')[1].strip()
check_block['stdout'] = [l.strip() for l in lines[4:] if l.strip() != '']

# Obtener información de bloque "installing_ps1"
installing_ps1_block = json_output['installing_ps1_block']
for line in lines:
    if 'Command executed:' in line:
        installing_ps1_block['command'].append(line.split(':')[1].strip())
    elif 'Download URL:' in line:
        installing_ps1_block['command_output'].append(line.split(':')[1].strip())
    elif 'Command output:' in line:
        installing_ps1_block['hash_error'].append(line.split(':')[1].strip())
    elif 'Download error:' in line:
        installing_ps1_block['download_error'].append(line.split(':')[1].strip())

# Convertir diccionario a JSON
json_str = json.dumps(json_output, indent=2)

# Imprimir salida JSON
print(json_str)
