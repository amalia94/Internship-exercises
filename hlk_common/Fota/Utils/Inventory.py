"""
 2022 Developed by Renault SW Labs,
 an affiliate of RENAULT s.a.s. which holds all intellectual property rights.
 Use of this software is subject to a specific license granted by Renault s.a.s.
 Library for Inventory methods
"""
# Standard Library
import json
import logging
logger = logging.getLogger("MatrixCore")


class Inventory(object):
    def check_inventory_file(self, filename, ecu, attribute_list):
        """
        goal: checks that IVC and IVI reports proper date during inventory
        :param filename: represents the fota_ecu_inv.json file generated during inventory
        :type filename: string
        :param ecu: either RDO(IVI) or TCU(IVC)
        :type ecu: string
        :param attribute_list: list of attributes that must be retrieved
        :type attribute_list: list

        :return: verdict, comment and software value reported for each ECU
        :rtype: bool, str, list
        """
        list_values = []
        logger.info(f"FOTA inventory file: {filename}")
        with open(filename, 'r') as f:
            try:
                dictionary = json.load(f)
            except ValueError as e:
                logger.error(e)
                return False, f"Invalid file {filename}", None
        for item in dictionary['FOTA - ECU_INV_CONF']['ecu_list']:
            if item['ecu_type'] == ecu:
                property_list = item['property_list']
                for attribute in attribute_list:
                    attrib_dict = \
                        ([i for i in property_list if i['prop_object'] == attribute] or [None])[0]
                    if attrib_dict is not None:
                        attrib_value = attrib_dict['prop_value']
                        list_values.append(attrib_value)
                    else:
                        return False, "One property was not reported properly", None
                return True, "FOTA file loaded successfully", list_values
        return False, f"{ecu} data not found in the file", None
