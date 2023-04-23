# This script parse a gorilla.log file to obtain a GorillaReport.json file"
# Creator: Luis Vela Morilla
# Email: luisvela@us.es
# Facultad de Comunicación, Universidad de Sevilla

import my_functions
from pathlib import Path
import os
import glob
import json

# variables
gorilla_report_file = 'C:\ProgramData\gorilla\GorillaReport.json'
gorilla_log_file = 'C:\gorilla\cache\gorilla.log'

# split gorilla.log in smaller files: gorilla_execution_1.log, gorilla_execution_2.log, etc
my_functions.get_all_executions_gorilla_log(gorilla_log_file)

##################################################
# Iterate over gorilla_executions in gorilla.log #
##################################################

# iterate over files in that directory
directory = os.getcwd()
files = Path(directory).glob('gorilla_execution_*')
managed_install_items = []

last_execution_file = max(files, key=lambda x: int(x.stem.split('_')[-1]))

managed_install_items.append(my_functions.parse_log_file(last_execution_file))

# remove generated files
for f in glob.glob("gorilla_execution_*"):
    os.remove(f)

# build final object
final_object = {
    'global_info': my_functions.get_last_data_execution_gorilla_report_json(gorilla_report_file),
    'managed_installs': managed_install_items[0]
}

# save final_object to a json file
with open(os.path.join('C:\gorilla', 'CustomGorillaReport.json'), 'w') as fp:
    json.dump(final_object, fp)
exit()
