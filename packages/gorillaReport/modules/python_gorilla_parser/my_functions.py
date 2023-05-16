# Creator: Luis Vela Morilla
# Email: luisvela@us.es
# Facultad de Comunicación, Universidad de Sevilla

import json
import re
import glob
import os


def do_nothing():
    return


def get_task_name(line):
    pre_task_name1 = re.split('Checking status via ', line)[-1]
    pre_task_name2 = re.split(' ', pre_task_name1)[-1]
    task_name = pre_task_name2.replace("\n", "")
    return task_name


def get_check_status_via(line):
    pre_check_type1 = re.split('Checking status via ', line)[-1]
    pre_check_type2 = re.split(':', pre_check_type1)[-2]
    check_type = pre_check_type2.replace("\n", "")
    return check_type


def get_check_status_script_name(line):
    pre_script_name = re.split('Checking status via script: ', line)[-1]
    script_name = pre_script_name.replace("\n", "")
    return script_name


def get_ps1_installer_file_path(line):
    pre_ps1_file_path1 = re.split('ExecutionPolicy Bypass -File ', line)[-1]
    pre_ps1_file_path2 = pre_ps1_file_path1.replace("\n", "")
    ps1_file_path = pre_ps1_file_path2.replace("]", "")
    return ps1_file_path


def get_stdout_text(line):
    parts = line.split("stdout:")
    if len(parts) == 1:
        return ""
    return parts[1].strip()


def get_stderr_text(line):
    parts = line.split("stderr:")
    if len(parts) == 1:
        return ""
    return parts[1].strip()


def get_last_data_execution_gorilla_report_json(file):
    my_gorilla_report_json = {}
    with open(file) as json_file:
        gorilla_report_json = json.load(json_file)

        my_gorilla_report_json = {
            'HostName': gorilla_report_json['HostName'],
            'CurrentUser': gorilla_report_json['CurrentUser'],
            'Catalog': gorilla_report_json['Catalog'],
            'Manifest': gorilla_report_json['Manifest'],
            'LastExecution_StartTime': gorilla_report_json['StartTime'],
            'LastExecution_EndTime': gorilla_report_json['EndTime']
        }

    return my_gorilla_report_json


def get_all_executions_gorilla_log(file):
    gorilla_executions = []
    gorilla_execution = {'endTime': [], 'executionTextBlock': []}
    execution_counts = 0
    execution_block = ''

    # delete old files
    for i in glob.glob('gorilla_execution_*'):
        os.remove(i)

    with open(file) as json_file:
        for line in json_file:
            execution_block += line
            if ' Done!' in line:
                execution_counts += 1
                gorilla_execution['executionTextBlock'].append(execution_block)
                with open('gorilla_execution_' + str(execution_counts) + '.log', 'w') as f:
                    f.write(execution_block)
                    execution_block = ''
                f.close()

                gorilla_execution['endTime'] = line.split(
                    ' ')[1] + " - " + line.split(' ')[2].split('.')[0]
                gorilla_executions.append(gorilla_execution)
                gorilla_execution = {'endTime': [], 'executionTextBlock': []}

        print('\nNumber of executions found in gorilla.log:', execution_counts)

    return gorilla_executions


def parse_log_file(gorilla_log_file):
    checking_status_found = False
    managed_uninstalls_found = False

    # all items
    managed_install_items = []
    managed_install_items_count = 0

    # single item
    managed_install_item = {}
    processing_managed_install_item = False
    # script block
    check_script_command_error_found = False
    check_script_stdout_found = False
    check_script_stderr_found = False
    check_script_block = {'command_error': [], 'stdout': [], 'stderr': []}
    check_script_exit_1 = False
    # installing ps1 block
    installing_ps1_found = False
    installing_ps1_command_found = False
    installing_ps1_command_output_found = False
    installing_ps1_hash_error = False
    installing_ps1_download_error = False
    installing_ps1_block = {'command': [], 'command_output': [
    ], 'hash_error': [], 'download_error': []}

    with open(gorilla_log_file) as file:
        for line in file:
            ######################################
            # managed installs/check status via #
            ######################################
            if 'Checking status via' in line:
                managed_install_items_count += 1
                processing_managed_install_item = True
                check_script_exit_1 = False

                if checking_status_found or check_script_exit_1:  # implies new managed_install_item
                    # restore all variables associated to a single managed_install_item
                    managed_install_item = {}
                    # check
                    check_script_command_error_found = False
                    check_script_stdout_found = False
                    check_script_stderr_found = False
                    check_script_block = {
                        'command_error': [], 'stdout': [], 'stderr': []}
                    # installing ps1
                    installing_ps1_command_found = False
                    installing_ps1_command_output_found = False
                    installing_ps1_hash_error = False
                    installing_ps1_download_error = False
                    installing_ps1_block = {'command': [], 'command_output': [
                    ], 'hash_error': [], 'download_error': []}

                # new managed_install_item
                managed_install_item['task_name'] = get_task_name(line)
                managed_install_item['check_block'] = {}
                managed_install_item['check_block']['via'] = get_check_status_via(
                    line)
                managed_install_item['check_block']['script'] = check_script_block
                managed_install_item['installing_ps1_block'] = {}

                managed_install_items.append(managed_install_item)
                checking_status_found = True

            if 'Installing ps1 for' in line:
                installing_ps1_found = True

            if 'Processing managed uninstalls...' in line:
                installing_ps1_found = False
                managed_uninstalls_found = True
                processing_managed_install_item = False

            ###############################################
            # managed installs/check status: command_error, stdout, stderr #
            ###############################################
            if processing_managed_install_item and not managed_uninstalls_found:
                if managed_install_item['check_block']['via'] == 'script':

                    if 'Command Error: ' in line:
                        check_script_command_error_found = True
                    if 'stdout: ' in line:
                        check_script_stdout_found = True
                    if 'stderr: ' in line:
                        check_script_stderr_found = True
                        check_script_block['stderr'].append(
                            get_stderr_text(line))
                    if 'Command Error: exit status 1' in line:
                        check_script_exit_1 = True

                    if installing_ps1_found:
                        managed_install_item['check_block']['script'] = check_script_block

                    if not check_script_stdout_found:
                        check_script_block['command_error'].append(line)
                    if check_script_stdout_found and not check_script_stderr_found:
                        check_script_block['stdout'].append(
                            get_stdout_text(line))

            ###########################################
            # managed installs/installing ps1: command, command_output #
            ###########################################
            if processing_managed_install_item and installing_ps1_found and not managed_uninstalls_found:
                if 'command: C:' in line:
                    installing_ps1_command_found = True
                if 'Command Output:' in line:
                    installing_ps1_command_output_found = True
                if 'File hash does not match expected value:' in line:
                    installing_ps1_hash_error = True
                if 'Unable to download valid file:' in line:
                    installing_ps1_download_error = True

                if installing_ps1_found:
                    managed_install_item['installing_ps1_block'] = installing_ps1_block
                if installing_ps1_command_found and not installing_ps1_command_output_found:
                    installing_ps1_block['command'].append(line)
                if installing_ps1_command_output_found and not installing_ps1_hash_error:
                    if "SUCCESSFUL" in line:
                        installing_ps1_block['command_output'].append(line)
                    if "FAILED" in line:
                        installing_ps1_block['command_output'].append(line)
                    # elif:
                        # do nothing
                if installing_ps1_hash_error and not installing_ps1_download_error:
                    installing_ps1_block['hash_error'].append(line)
                if installing_ps1_download_error:
                    installing_ps1_block['download_error'].append(line)

    #####################################
    # print results: only for debugging #
    #####################################
    """
    for item in managed_install_items:
       print('- task_name: ', item['task_name'])
       print('- check_via: ', item['check_block']['via'])
       if item['check_block']['via'] == 'Script':
           print('  - command_error: ', item['check_block']['script']['command_error'])
           print('  - stdout: ', item['check_block']['script']['stdout'])
           print('  - stderr: ', item['check_block']['script']['stderr'])
       print('- installing ps1: ', item['installing_ps1_block'])
       print('  - command: ', item['installing_ps1_block']['command'])
       print('  - command_output: ', item['installing_ps1_block']['command_output'])
       print('  - hash_error: ', item['installing_ps1_block']['hash_error'])
       print('  - download_error: ', item['installing_ps1_block']['download_error'])
       print()
    """

    return managed_install_items
