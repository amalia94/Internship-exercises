"""
 2022 Developed by Renault SW Labs,
 an affiliate of RENAULT s.a.s. which holds all intellectual property rights.
 Use of this software is subject to a specific license granted by Renault s.a.s.
"""
# Standard Library
import fileinput
import logging
import os
import re
import sys
from shutil import copyfile


def generate_cfm_from_xml(input_path: str, output_path: str = '', action="ON"):
    """
    :goal: Generates a CFM file in Descmo format
    :param input_path: path to the folder or single xml file
    :type input_path: str
    :param output_path: path of the output folder
    :type output_path: str
    :param action: sets the activation status
    :type action: str
    :return: True if the file generation was successful, False otherwise
    :rtype: bool
    """
    # validate paths and create output_path formation
    output_path = validate_paths(input_path, output_path)

    # process a folder of files given as input
    path = []
    ipath = check_path(input_path)
    if ipath == 0:
        path = list(os.listdir(input_path)).copy()
    # process a single input file
    elif ipath == 1:
        path.append(input_path)
    # generate the cfm files based of input
    for _, file in enumerate(path):
        src = os.path.join(input_path, file)
        valid_xml_check = check_file_type_xml(src)
        if os.path.isfile(src) and valid_xml_check == 0:
            cfm_filename = 'cfm_' + os.path.basename(src)
            cfm_filename = cfm_filename.replace('.xml', '')

            cfm_dst = os.path.join(output_path, cfm_filename)
            copyfile(src, cfm_dst)
            os.chmod(cfm_dst, 0o777)

            # cfm file generation
            # ==========================================================================
            replace_str1 = "INSERT INTO ucdproperty (propertyName, activationStatus, " \
                           "configurationStatus) VALUES ("
            if action == "ON":
                replace_str2 = ",1,0);"
            else:
                replace_str2 = ",0,0);"

            for line in fileinput.input(cfm_dst, inplace=1):
                if not re.search(r'CustomSetting', line):
                    line = re.sub(r"<property Name=", replace_str1, line)
                    line = re.sub(r" Type(.*)", replace_str2, line)
                    line = line.lstrip()
                    sys.stdout.write(line)
            if check_statement_file_format(cfm_dst) != 0:
                return False
    return True


def check_path(path: str):
    """
    :goal: Checks whether the provided path exists and is a folder or directory
    :param path: path to the file/folder
    :type path: str
    :return: res
    :rtype: int
    """
    if os.path.exists(path):
        if os.path.isdir(path):
            res = 0
        elif os.path.isfile(path):
            res = 1
        else:
            logging.error(f"Unknown file type given: {path}")
            res = -2
    else:
        logging.info(f"Path does not exist: {path}")
        res = -1
    return res


def validate_paths(input_path: str, output_path: str):
    """
    :goal: Validate input and output paths
    :param input_path: path to the file/folder
    :type input_path: str
    :param output_path: path of the file/folder
    :type output_path: str
    :return: output_path
    :rtype: str
    """
    # validate the input path
    verdict_input = check_path(input_path)
    if verdict_input == -1:
        logging.error(f"Input path {input_path} does not exist. "
                      f"Please provide a correct input file/folder path")
    # validate the output path
    verdict_output = check_path(output_path)
    if verdict_output in (-1, 1):
        try:
            # if output_path is given, create the directory if it does not exist
            if output_path != '':
                os.makedirs(output_path, mode=0o777)
            else:
                # if the input path is a file, create the directory in the input path
                if verdict_input == 1:
                    input_path_dir = os.path.dirname(input_path)
                    input_path_dir_name = os.path.basename(os.path.normpath(input_path_dir))
                    output_path = os.path.join(input_path_dir, f"cfm_{input_path_dir_name}")
                # if the input path is a directory, create the directory in the input path
                elif verdict_input == 0:
                    input_path_dir_name = os.path.basename(os.path.normpath(input_path))
                    output_path = os.path.join(input_path, f"cfm_{input_path_dir_name}")
                os.mkdir(output_path, mode=0o777)
        except OSError as error:
            logging.warning(f"{error}")
    return output_path


def check_file_type_xml(input_file: str):
    """
    :goal: Checks whether the file provided is a valid XML file or not
    :param input_file:  path to the xml file
    :type input_file: str
    :return: int
    :rtype: int
    """
    # check the file extension
    filename, file_extension = os.path.splitext(input_file)
    filename = os.path.basename(filename)
    if file_extension != ".xml":
        logging.warning("{} with path {} is not a valid XML".format(filename, input_file))
        return -1

    with open(input_file, 'r') as xml_file:
        # Remove tabs, spaces, and new lines when reading
        data = re.sub(r'\s+', '', xml_file.read())
        if re.match(r'^<.+>$', data):
            return 0
        logging.warning("{} with path {} is not a valid XML".format(filename, input_file))
        return -1


def check_statement_file_format(input_file: str):
    """
    :goal: Checks whether the file has a valid final format
    :param input_file:  path to the file
    :type input_file: str
    :return: int
    :rtype: int
    """
    regex = re.compile(r"^INSERT INTO.*\(.*\) VALUES \(.*\);$")
    with open(input_file, 'r') as opened_file:
        for line in opened_file:
            if not bool(regex.search(line)):
                logging.error(f"Incorrect INSERT SQL query format in file {input_file}")
                return -1
    return 0
