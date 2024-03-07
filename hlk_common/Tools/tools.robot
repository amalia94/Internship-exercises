#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Resource          ../../hlk_common/IVI/adb_command.robot

*** Variables ***
${ivc_can_only}    False
${write_ivi_iptables_for_ssh}    False
${write_ivi_iptables_for_dlt}    False

*** Keywords ***
DO WAIT
    [Arguments]    ${time}
    [Documentation]    DO WAIT
    ...    arguments: ${time}
    ...    Wait for ${time} milliseconds
    Sleep    ${time} milliseconds

PAYLOAD UPDATE BIT LEVEL
    [Arguments]    ${payload}    ${byte_position}    ${bit_position}    ${bit_value}
    [Documentation]    Modify the payload: ${payload} at byte_position: ${byte_position} and  bit_position: ${bit_position} with bit_value: ${bit_value}
    ${byte_start_index} =    Evaluate    ${byte_position} * ${2}
    ${byte_end_index} =    Evaluate    ${byte_start_index} + ${2}
    ${byte} =    Get Substring     ${payload}    ${byte_start_index}    ${byte_end_index}
    ${bits} =    Convert To Binary    ${byte}    base=16    length=8
    ${bits} =    Convert To List    ${bits}
    ${new_bits} =    Create List
    FOR    ${index}    IN RANGE    0    8
        Run Keyword If    "${index}" == "${bit_position}"    Append To List    ${new_bits}    ${bit_value}
        ...    ELSE    Append To List    ${new_bits}    ${bits}[${index}]
    END
    ${new_bits} =    Get Slice From List    ${new_bits}    0
    ${new_bits} =    Evaluate    "".join(${new_bits})
    ${new_byte} =    Convert To Hex    ${new_bits}    base=2    length=2
    ${new_payload} =    Get Substring    ${payload}    0    ${byte_start_index}
    ${new_payload} =    Evaluate    "${new_payload}" + "${new_byte}"
    ${temp} =    Get Substring    ${payload}    ${byte_end_index}
    ${new_payload} =    Evaluate    "${new_payload}" + "${temp}"
    [Return]    ${new_payload}

PAYLOAD UPDATE BYTE LEVEL
    [Arguments]    ${payload}    ${byte_position}    ${byte_value}
    [Documentation]    Modify the payload: ${payload} at byte_position: ${byte_position} with byte_value: ${byte_value}
    Log To Console    Modify the payload: ${payload} at byte_position: ${byte_position} with byte_value: ${byte_value}
    ${byte_start_index} =    Evaluate    ${byte_position} * ${2}
    ${byte_end_index} =    Evaluate    ${byte_start_index} + ${2}
    ${new_payload} =    Get Substring    ${payload}    0    ${byte_start_index}
    ${new_payload} =    Evaluate    "${new_payload}" + "${byte_value}"
    ${temp} =    Get Substring    ${payload}    ${byte_end_index}
    ${new_payload} =    Evaluate    "${new_payload}" + "${temp}"
    [Return]    ${new_payload}

Convert To Dictionary
    [Arguments]    ${str}
    [Documentation]    == High Level Description: ==
    ...    Convert string to JSON
    ...    == Arguments: ==
    ...    - str: Arrays of bytes representing unicode character
    ...    == Expected Results: ==
    ...    output: JSON (JavaScript Object Notation) is a lightweight data-interchange format.
    ${result} =    EVALUATE    json.loads(r'''${str}''')    json
    [Return]    ${result}

#Todo: To be removed from all libraries if the Kw is not needed for any type of setup / MyFx
SET IVI IP TABLES FOR IVC SSH CONNECTION
    [Documentation]    == High Level Description: ==
    ...    Set IP forward rules on AIVI2 for IVC SSH connection
    Return From Keyword If    '${ivc_bench_type}' in "'${bench_type}'" or "${ivc_can_only}" == "True" or "${write_ivi_iptables_for_ssh}" == "False"
    ADB_SET_ROOT
    OperatingSystem.Run    adb -s ${ivi_adb_id} shell echo 1 > /proc/sys/net/ipv4/ip_forward
    OperatingSystem.Run    adb -s ${ivi_adb_id} shell iptables -t nat -A PREROUTING -p tcp --dport 22 -i usb0 -j DNAT --to-destination 192.168.13.3
    OperatingSystem.Run    adb -s ${ivi_adb_id} shell iptables -t nat -A POSTROUTING -p tcp -o oem0_130 --dport 22 -j SNAT --to 192.168.13.1
    OperatingSystem.Run    adb -s ${ivi_adb_id} shell iptables -I FORWARD -p tcp -i usb0 -o oem0_130 --dport 22 -j ACCEPT
    OperatingSystem.Run    adb -s ${ivi_adb_id} shell iptables -I FORWARD -p tcp -i oem0_130 -o usb0 --sport 22 -j ACCEPT

#Todo: To be removed from all libraries if the Kw is not needed for any type of setup / MyFx
SET IVI IP TABLES FOR IVC DLT LOGGING
    [Documentation]    == High Level Description: ==
    ...    Set IP forward rules on AIVI2 for IVC dlt logging
    Return From Keyword If    '${ivc_bench_type}' in "'${bench_type}'" or "${ivc_can_only}" == "True" or "${write_ivi_iptables_for_dlt}" == "False"
    ADB_SET_ROOT
    OperatingSystem.Run    adb -s ${ivi_adb_id} shell iptables -t nat -A PREROUTING -p tcp --dport 3490 -i usb0 -j DNAT --to-destination 192.168.13.3
    OperatingSystem.Run    adb -s ${ivi_adb_id} shell iptables -t nat -A POSTROUTING -p tcp -o oem0_130 --dport 3490 -j SNAT --to 192.168.13.1
    OperatingSystem.Run    adb -s ${ivi_adb_id} shell iptables -I FORWARD -p tcp -i usb0 -o oem0_130 --dport 3490 -j ACCEPT
    OperatingSystem.Run    adb -s ${ivi_adb_id} shell iptables -I FORWARD -p tcp -i oem0_130 -o usb0 --sport 3490 -j ACCEPT

CHECK IVI INVENTORY
    [Documentation]    == High Level Description: ==
    ...    Checks  if the TCU is present in the IVI
    ADB_SET_ROOT
    ${output} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell cat /fota/inventory/fota_ecu_inv.json | grep TCU
    ${status} =    Run Keyword And Return Status    Should Contain    ${output}    TCU
    [Return]    ${status}

SET IVI INVENTORY
    [Arguments]    ${TC_folder}=${EMPTY}
    [Documentation]    == High Level Description: ==
    ...    Reset trigger for inventory sequence
    DELETE FOLDER OR FILE    /fota/inventory/*.*
    OperatingSystem.Run    adb -s ${ivi_adb_id} shell cmd DiagAdb Routine start 02A4
    OperatingSystem.Run    adb -s ${ivi_adb_id} shell cmd DiagAdb hardReset
    Sleep    180
    ADB_SET_ROOT
    ${output} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell cat /fota/inventory/fota_ecu_inv.json | grep TCU
    ${status} =    Run Keyword And Return Status    Should Contain    ${output}    TCU
    Run Keyword If    "${TC_folder}"=="RELIABILITY"    Run keyword And Continue On Failure    Should Be True    ${status}
    ...    ELSE    Should Be True    ${status}
    [Return]    ${status}

CHECKSET IVI INVENTORY
    [Documentation]    == High Level Description: ==
    ...  Checks  if the TCU is present in the IVI, if not trigger the inventory sequence and check again.
    ${check} =    Run Keyword And Return Status     CHECK IVI INVENTORY
    ${status}=    Run Keyword If    '${check}'=='False'    SET IVI INVENTORY    ${TC_folder}
    ${result}=    Set Variable If    '${check}' =='True'     ${check}    ${status}
    [Return]    ${result}

INSTALL APPLICATION
    [Arguments]    ${app}
    [Documentation]    == High Level Description: ==
    ...    Install app on bench
    ...    == Arguments: ==
    ...    - _app_: Application that will be installed on the bench
    OperatingSystem.Run    apt-get -y install ${app}

CHECK CAN INTERFACE
    [Arguments]    ${can_interface}
    [Documentation]    == High Level Description: ==
    ...    Check if the desired CAN interface is up
    ...    == Arguments: ==
    ...    - _can_interface_: name of the CAN interface
    ${ret_ifconfig} =    OperatingSystem.Run    ifconfig ${can_interface}
    Should Not Be True     "error fetching interface information" in """${ret_ifconfig}"""
    Should Be True    "UP,RUNNING,NOARP" in """${ret_ifconfig}"""    CAN interface is NOT UP and RUNNING, UP RUNNING NOARP message not found with ifconfig ${can_interface}

DO FOTA DIAG RESET
    [Arguments]    ${device_id}
    [Documentation]    == High Level Description: ==
    ...    Through debug bridge, execute the following commands to reset FOTA routine
    ...    == Parameters: ==
    ...    == Expected Results: ==
    ...    Passed if FOTA routine has been reset.
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    FOTA STATUS    IVC CMD
    SET IVI INVENTORY
    ${output}    ${error} =    shellCmd    adb -s ${device_id} cat /fota/inventory/fota_ecu_inv.json | grep RDO
    ${status} =    Run Keyword And Return Status    Should Contain    ${output}    RDO
    Should Be True    ${status}

COLLECT NETSTAT LOG
    [Arguments]       ${file_directory}
    [Documentation]  Collect netstat logs
    Import Library    rfw_libraries.tools.ziplogfile.ZIPLog    ${file_name_of_zip}    ${file_netstat_log}    ${file_acsf_config_log}    ${file_candump_slcan_log}
    ${verdict}    ${file_path} =    rfw_services.wicket.ConnectivityLib.COLLECT NETSTAT LOG     file_directory=${EXECDIR}
    Should Be True    ${verdict}    Failed to COLLECT NETSTAT LOG: ${file_path}

ZIP ALL FILES
    [Documentation]  Zip files
    Import Library    rfw_libraries.tools.ziplogfile.ZIPLog    ${file_name_of_zip}    ${file_netstat_log}    ${file_acsf_config_log}    ${file_candump_slcan_log}
    rfw_libraries.tools.ziplogfile.ZIPLog.run zip log files    is_txt=${True}

MEMORIZE IN LIST
    [Arguments]       ${storage_list}   ${value}
    [Documentation]   Add value in list.
    IF    ${storage_list} == ${None}
        ${storage_list} =    Create list
    END
    Append To List    ${storage_list}    ${value}
    [Return]    ${storage_list}
