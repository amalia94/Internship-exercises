#
# Copyright (c) 2020, 2021, 2022 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Documentation     DoIP keywords library
Library           rfw_services.canakin.CanakinLib    @{canakin_config_data}
Library           rfw_services.wicket.DiagnosticLib
Library           String
Library           OperatingSystem
Library           Collections
Library           DateTime

Resource          ../../IVI/filesystem.robot
Resource          ../../power_supply.robot
Resource          ../../SGW/sgw.robot
Variables         ${CURDIR}/doip_byte_configuration_ivi_android_12.yaml
Variables         ${CURDIR}/doip_byte_configuration_ivi_android_10.yaml

*** Variables ***
@{canakin_config_data}      MSRS    GTT    UDS_DID    UDS_ROUTINE
${hdmi_config_value}        00000000000000000000000000000000000000000000000000000000100000000000000000000000
&{diagnostic_ecu_name}      aivi2_core=NAV    aivi2=NAV    aivi2_full=NAV    aivi2_full_can=NAV    aivc2=TCU    aivi2_r_accessda=NAV    sgw=SGW    sgw2=SGW    aivi2_r_full_dom=NAV
&{ecu_eth_interface}        aivi2_core=eth_ivi    aivi2=eth_ivi    aivi2_full=eth_ivi    aivi2_full_can=eth_ivi    aivc2=eth_ivc    aivc2_std=eth_ivc_std    aivi2_r_accessda=eth_ivi    sgw=eth_sgw    sgw2=eth_sgw2    aivi2_r_full_dom=eth_ivi
${can_config_ccs2}          ${CURDIR}/../CAN/can_config_CCS2.json
${rdtci_ivi}                ${CURDIR}/rdtci_IVI.json
${rdiag_replies}            ${CURDIR}/remote_diagnose.json
${uds_timeout}              2
${tester_present_interval}  2
${payload}                  ${True}
${wait_before_doip}         4
${uds_did_config}           ${CURDIR}/dids_CCS2.json
${uds_routine_config}       ${CURDIR}/routines_CCS2.json

*** Keywords ***
LOAD DOIP CONFIGURATION
    ${verdict}    ${comment} =    Canakin Load Dictionary    2    ${uds_did_config}
    Should Be True    ${verdict}

    ${verdict}    ${comment} =    Canakin Load Dictionary    3    ${uds_routine_config}
    Should Be True    ${verdict}

DOIP PLUG OBD PROBE
    [Arguments]     ${time_before_doip}=${wait_before_doip}
    IF    '${sweet400_bench_type}' not in "'${tc_config}[bench_type]'"
        Return From Keyword
    END
    SET ACTIVATION LINE STATUS    status=12V
    Sleep    ${time_before_doip}
    SGW DOIP UNLOCK

DOIP UNPLUG OBD PROBE
    IF    '${sweet400_bench_type}' not in "'${tc_config}[bench_type]'"
        Return From Keyword
    END
    Canakin Close UDS Connection
    SET ACTIVATION LINE STATUS    status=probe

GET ECU DOIP INFO
    [Arguments]    ${platform_type}    ${timeout}=${uds_timeout}
    ${ecu_canakin_name} =    Set Variable    ${diagnostic_ecu_name['${platform_type}']}
    ${ecu_eth_name} =    Run Keyword If    '${ivc_bench_type}' in "'${tc_config}[bench_type]'" and "${ecu_canakin_name}" == "TCU"    Set Variable    ${ecu_eth_interface['aivc2_std']}
    ...    ELSE     Set Variable    ${ecu_eth_interface['${platform_type}']}
    [Return]    ${ecu_canakin_name}    ${ecu_eth_name}

DOIP READ DID
    [Documentation]     Rease DID over DoIP
    [Arguments]    ${platform_type}    ${identifier}    ${session}=None     ${timeout}=${uds_timeout}
    ${ecu_canakin_name}    ${ecu_eth_name} =    GET ECU DOIP INFO    ${platform_type}
    IF    "${session}" != "None"
        ${session_num} =    Set Variable If
        ...    "${session}" == "default"    1
        ...    "${session}" == "programming"    2
        ...    "${session}" == "extended"    3
        ${verdict}    ${comment} =    Canakin Change Diagnostic Session   ${ecu_canakin_name}   session=${session_num}    itf=${ecu_eth_name}    timeout=${timeout}
        ${auto_session} =    Set Variable    False
    ELSE
        ${auto_session} =    Set Variable    True
    END
    ${verdict}    ${comment} =    Canakin Read Data By Identifier    ${ecu_canakin_name}    ${identifier}    auto_session=${auto_session}    itf=${ecu_eth_name}    timeout=${timeout}
    Log    DoIP Read ${identifier}: ${verdict} - ${comment}
    IF    '${verdict}' == 'True'
        ${data}=    evaluate    json.loads('''${comment}''')    json
    END
    [Return]    ${verdict}    ${comment}    ${data}

DOIP WRITE DID
    [Documentation]     Write DID over DoIP
    [Arguments]    ${platform_type}    ${identifier}    ${value}    ${auto_session}=False    ${padding}=None    ${timeout}=${uds_timeout}
    ${ecu_canakin_name}    ${ecu_eth_name} =    GET ECU DOIP INFO    ${platform_type}
    ${verdict}    ${comment} =    Canakin Write Data By Identifier    ${ecu_canakin_name}    ${identifier}    ${value}    ${auto_session}    ${padding}    itf=${ecu_eth_name}    timeout=${timeout}
    Should be true    ${verdict}    ${comment}
    [Return]    ${verdict}    ${comment}

SEND VEHICLE DIAG START SESSION
    [Arguments]    ${platform_type}    ${session_type}    ${timeout}=${uds_timeout}
    [Documentation]      Open DoIP ${session_type} session
    ...    ${platform_type} :  Device under test (aivi2_full)
    ...    ${session_type}: Type of session (default, programming, extended)
    Log    Sending Vehicle Start Diag ${session_type} Session on ${platform_type}
    ${ecu_canakin_name}    ${ecu_eth_name} =    GET ECU DOIP INFO    ${platform_type}
    ${session_num} =    Set Variable If
    ...    "${session_type}" == "default"    1
    ...    "${session_type}" == "programming"    2
    ...    "${session_type}" == "extended"    3
    Log    ${ecu_canakin_name} ${session_num} ${ecu_eth_name} ${timeout}
    ${verdict}    ${comment} =    Canakin Change Diagnostic Session   ${ecu_canakin_name}   session=${session_num}    itf=${ecu_eth_name}    timeout=${timeout}
    Log    DoIP Open ${session_type} Session ${verdict} - ${comment}
    Should Be True    ${verdict}    Error message: ${comment}
    [Return]    ${verdict}    ${comment}

WAIT FOR VEHICLE DIAG START SESSION RESPONSE
    [Arguments]    ${platform_type}    ${expected_response_type}    ${start_session_verdict}    ${start_session_comment}
    [Documentation]      After sending a Vehicle Start Session Command, check the response sent by the ${dut_id}
    ...    which can be positive or negative
    ...    ${platform_type}:  Device under test (aivi2_full)
    ...    ${expected_response_type}: Can be positive or negative
    ...    ${start_session_verdict}: The verdict returned from the SEND VEHICLE DIAG START SESSION
    ...    ${start_session_comment}: The comment returned from the SEND VEHICLE DIAG START SESSION
    Log    Waiting for Vehicle Start Diag Session on ${platform_type} to be ${expected_response_type}
    #Should Be Equal    ${platform_type}    ${dut_id}    Wrong dut_id: ${dut_id}
    Run Keyword If    "${expected_response_type}" == "positive"    Should Be True    ${start_session_verdict}    Error Message: ${start_session_comment}
    ...    ELSE    Should Not Be True    ${start_session_verdict}    Error Message: ${start_session_comment}

SEND VEHICLE DIAG DID READ
    [Arguments]    ${platform_type}    ${element_id}    ${auto_session}=True    ${timeout}=${uds_timeout}
    [Documentation]     Sends DID read request over DoIP.
    ...    ${platform_type}:  Device under test: (aivi2_full).
    ...    ${element_id}: ID of the element that we want to read
    Log    Sending read ${element_id} request over DoIp on ${platform_type}
    # Should Be Equal    ${platform_type}    ${dut_id}    Wrong dut_id: ${dut_id}
    ${ecu_canakin_name}    ${ecu_eth_name} =    GET ECU DOIP INFO    ${platform_type}
    ${verdict}    ${comment} =    Canakin Read Data By Identifier    ${ecu_canakin_name}    ${element_id}    ${auto_session}    itf=${ecu_eth_name}    timeout=${timeout}
    [Return]    ${verdict}    ${comment}

WAIT FOR VEHICLE DIAG DID READ
    [Arguments]    ${platform_type}    ${element_id}    ${expected_response_type}    ${expected_response}    ${send_read_verdict}    ${send_read_comment}
    [Documentation]     Reads DID over DoIP.
    ...    ${platform_type}:  Device under test: (aivi2_full).
    ...    ${element_id}: ID of the element that we want to read
    ...    ${expected_response_type}: Can be positive or negative
    ...    ${expected_response}: Mask containing the string of the response, where XX are not relevant (optional field)
    ...    ${send_read_verdict}: The verdict returned from the SEND VEHICLE DIAG DID READ
    ...    ${send_read_comment}: The comment returned from the SEND VEHICLE DIAG DID READ
    Log    Waiting for Vehicle Diag to read on ${platform_type} to be ${expected_response_type}
    # Should Be Equal    ${platform_type}    ${dut_id}    Wrong dut_id: ${dut_id}
    Run Keyword If    "${expected_response_type}" == "positive"    Should Be True    ${send_read_verdict}    Error Message: ${send_read_comment}
    ...    ELSE    Should Not Be True    ${send_read_verdict}    Error Message: ${send_read_comment}
    Run Keyword If    "${expected_response_type}" == "positive"    Should Contain    ${send_read_comment}    ${element_id}
    ...    ELSE    Should Not Contain    ${send_read_comment}    ${element_id}
    Return From Keyword If    "${expected_response_type}" == "positive" and "${expected_response}" == "${None}"    Ignoring the verification of the value that is read
    Run Keyword If    "${expected_response_type}" == "positive"    Should Contain    ${send_read_comment}    ${expected_response}[0]
    ...    ELSE    Should Not Contain    ${send_read_comment}    ${expected_response}[0]

SEND VEHICLE DIAG DID WRITE
    [Arguments]    ${platform_type}    ${element_id}    ${value}    ${timeout}=${uds_timeout}
    [Documentation]     Sends DID write request over DoIP.
    ...    ${platform_type}:  Device under test: (aivi2_full)
    ...    ${element_id}: ID of the element that we want to write
    ...    ${value}: Value that has to be written
    Log    Sending write ${element_id} request with ${value} over DoIp in ${platform_type}
    # Should Be Equal    ${platform_type}    ${dut_id}    Wrong dut_id: ${dut_id}
    ${ecu_canakin_name}    ${ecu_eth_name} =    GET ECU DOIP INFO    ${platform_type}
    ${verdict}    ${comment} =    Canakin Write Data By Identifier    ${ecu_canakin_name}    ${element_id}    ${value}    auto_session=False    padding=None    itf=${ecu_eth_name}    timeout=${timeout}
    [Return]    ${verdict}    ${comment}

WAIT FOR VEHICLE DIAG DID WRITE
    [Arguments]    ${platform_type}    ${expected_response_type}    ${send_write_verdict}    ${send_write_comment}
    [Documentation]     Verifies the previously writen DID over DoIP.
    ...    ${platform_type}:  Device under test: (aivi2_full).
    ...    ${expected_response_type}: Can be positive or negative
    ...    ${send_write_verdict}: Value that has to be verfied
    ...    ${send_write_comment}: Comment that has to be verfied
    Log    Waiting for the Vehicle Diag write request to be ${expected_response_type} on ${platform_type}
    # Should Be Equal    ${platform_type}    ${dut_id}    Wrong dut_id: ${dut_id}
    Run Keyword If    "${expected_response_type}" == "positive"    Should Be True    ${send_write_verdict}    Error Message: ${send_write_comment}
    ...    ELSE    Should Not Be True    ${send_write_verdict}    Error Message: ${send_write_comment}
    Run Keyword If    "${expected_response_type}" == "positive"    Should Contain    ${send_write_comment}    Received positive response
    ...    ELSE    Should Not Contain    ${send_write_comment}    Received positive response

DOIP ECU RESET
    [Arguments]    ${reset_type}    ${platform_type}    ${timeout}=${uds_timeout}    ${tp_management}=False
    [Documentation]     ECU Hard Reset (0x1101)/ECU Key On/Off Reset (0x1102)/ECU Soft Reset (0x1103)
    ...    ${reset_type}: can have values hard_reset/key_on_off/soft_reset
    Run Keyword And Ignore Error    CLOSE SSH SESSION
    ${ecu_canakin_name}    ${ecu_eth_name} =    GET ECU DOIP INFO    ${platform_type}
    Run Keyword If    "${tp_management}" == "True"    Canakin Stop Tester Present    ${ecu_canakin_name}
    IF    "${reset_type}" == "hard_reset"
        ${verdict}    ${comment} =    Canakin Ecu Reset   ${ecu_canakin_name}    1    itf=${ecu_eth_name}    timeout=${timeout}
        Should be true    ${verdict}    ${comment}
        ${verdict}    ${comment} =    Canakin Close UDS Connection    ${ecu_eth_name}
        Should be true    ${verdict}    ${comment}
        IF    "${tp_management}" == "True" and "ivi" in "${platform_type}"
            CHECK STATE EXPECTED    offline    60    ${ivi_adb_id}
            DO WAIT    3000
            CHECK IVI BOOT COMPLETED    booted    120
            DO WAIT    8000
        ELSE IF    "${tp_management}" == "True" and "ivc" in "${platform_type}"
            CHECK IVC DISCONNECTED    60
            DO WAIT    3000
            CHECK IVC BOOT COMPLETED    160    True
            DO WAIT    8000
        END
        Sleep    120
    ELSE IF    "${reset_type}" == "key_on_off"
        ${ecu_canakin_name}    ${ecu_eth_name} =    GET ECU DOIP INFO    ${platform_type}
        ${verdict}    ${comment} =    Canakin Ecu Reset   ${ecu_canakin_name}   2    itf=${ecu_eth_name}    timeout=${timeout}
        Should be true    ${verdict}    ${comment}
        ${verdict}    ${comment} =    Canakin Close UDS Connection    ${ecu_eth_name}
        Should be true    ${verdict}    ${comment}
        Sleep    120
    ELSE IF   "${reset_type}" == "soft_reset"
        ${ecu_canakin_name}    ${ecu_eth_name} =    GET ECU DOIP INFO    ${platform_type}
        ${verdict}    ${comment} =    Canakin Ecu Reset   ${ecu_canakin_name}   3    itf=${ecu_eth_name}    timeout=${timeout}
        Should be true    ${verdict}    ${comment}
        Canakin Close UDS Connection    ${ecu_eth_name}
        Sleep    120
    END
    ${verdict}    ${comment} =    Canakin Change Diagnostic Session   ${ecu_canakin_name}   3    itf=${ecu_eth_name}    timeout=${timeout}
    Should be true    ${verdict}    ${comment}
    IF    "${tp_management}" == "True"
          ${verdict}    ${comment} =    Canakin Start Tester Present    ${ecu_canakin_name}    ${tester_present_interval}    itf=${ecu_eth_name}
          Should be true    ${verdict}    ${comment}
    END
    [Return]    ${verdict}    ${comment}

WAIT FOR VEHICLE DIAG COMMAND
    [Arguments]    ${platform_type}    ${expected_response_type}    ${diag_cmd_verdict}    ${diag_cmd_comment}
    [Documentation]     This command will check the result of a DIAG command
    ...    ${platform_type}:  Device under test: (aivi2_full).
    ...    ${expected_response_type}: Can be positive or negative
    ...    ${diag_cmd_verdict}: The verdict returned from the execution a Diag cmd
    ...    ${diag_cmd_comment}: The comment returned from the execution a Diag cmd
    # Log    Check the result of a DIAG command
    # Should Be Equal    ${platform_type}    ${dut_id}    Wrong dut_id: ${dut_id}
    Run Keyword If    "${expected_response_type}" == "positive"    Should Be True    ${diag_cmd_verdict}    Error Message: ${diag_cmd_comment}
    ...    ELSE    Should Not Be True    ${diag_cmd_verdict}    Error Message: ${diag_cmd_comment}

CHECK VEHICLE DIAG LOGICAL ADDRESS
    [Arguments]    ${platform_type}    ${value}
    [Documentation]    Check if the Vehicle Diag Logical Address is right by opening a diagnostic session
    ...    ${platform_type}:  Device under test: (aivi2_full).
    ...    ${value}: Target Diag Logical Address.
    ${json} =    Evaluate    json.load(open("${can_config_ccs2}", "r"))    json
    ${target_ecu_address} =    Set Variable    ${json['eth_ivi']['protocols']['do_ip']['target_ecu_address']}
    Should Be Equal    ${value}    ${target_ecu_address}
    ${verdict}    ${comment} =    SEND VEHICLE DIAG START SESSION    ${platform_type}    default
    WAIT FOR VEHICLE DIAG START SESSION RESPONSE    ${platform_type}    positive    ${verdict}    ${comment}

DOIP READ SUPPORTED DTC
    [Arguments]    ${platform_type}    ${timeout}=${uds_timeout}
    [Documentation]     Read DTC Information
    ${ecu_canakin_name}    ${ecu_eth_name} =    GET ECU DOIP INFO    ${platform_type}
    ${verdict}    ${comment} =    Canakin Read Dtc Information    ecu_name=${ecu_canakin_name}    sub_function=SupportedDTC    itf=${ecu_eth_name}    timeout=${timeout}
    Log    READ DTC ${verdict} - ${comment}
    [Return]    ${verdict}    ${comment}

DOIP READ DTC BY STATUS MASK
    [Documentation]     Read DTC Information
    ...    ${dtc_value}: value for status mask
    ...    https://automotive.softing.com/fileadmin/sof-files/pdf/de/ae/poster/uds_info_poster_v2.pdf
    [Arguments]    ${platform_type}    ${dtc_value}    ${timeout}=${uds_timeout}
    ${ecu_canakin_name}    ${ecu_eth_name} =    GET ECU DOIP INFO    ${platform_type}
    ${verdict}    ${comment} =    Canakin Read Dtc Information    ecu_name=${ecu_canakin_name}    sub_function=DTCByStatusMask    status_mask=${dtc_value}    itf=${ecu_eth_name}    timeout=${timeout}
    Log    READ DTC ${verdict} - ${comment}
    [Return]    ${verdict}    ${comment}

DOIP ERASE ALL DTC
    [Documentation]     Erase all DTC
    ...    ${dtc_group}:  DTC mask ranging from 0 to 0xFFFFFF. 0xFFFFFF means all DTCs
    [Arguments]    ${platform_type}    ${dtc_group}    ${timeout}=${uds_timeout}
    ${ecu_canakin_name}    ${ecu_eth_name} =    GET ECU DOIP INFO    ${platform_type}
    ${verdict}    ${comment} =    Canakin Clear Diagnostic Information    ecu_name=${ecu_canakin_name}    group=${dtc_group}    itf=${ecu_eth_name}    timeout=${timeout}
    Log    ERASE DTC ${verdict} - ${comment}
    [Return]    ${verdict}    ${comment}

DOIP ROUTINE CONTROL
    [Documentation]     Routine Control for DoIP
    [Arguments]    ${platform_type}    ${routine_id}    ${control_type}    ${data}=0    ${timeout}=${uds_timeout}
    ${ecu_canakin_name}    ${ecu_eth_name} =    GET ECU DOIP INFO    ${platform_type}
    ${verdict}    ${comment} =    Canakin Routine Control    ${ecu_canakin_name}    ${routine_id}    ${control_type}    data=${data}    auto_session=True    itf=${ecu_eth_name}    timeout=${timeout}
    Log    Routine Control Output : ${verdict} - ${comment}
    [Return]    ${verdict}    ${comment}

DID PAYLOAD UPDATE BIT LEVEL
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

SEND VEHICLE DIAG HEX WRITE
    [Arguments]    ${platform_type}    ${element_id}    ${hex_value}    ${timeout}=${uds_timeout}
    [Documentation]     Sends DID write request over DoIP.
    ...    ${platform_type}:  Device under test: (aivi2_full)
    ...    ${element_id}: ID of the element that we want to write
    ...    ${hex_value}: Hex value that has to be written
    Log    Writing ${element_id} request with ${hex_value} over DoIp in ${platform_type}
    ${element_name} =    GET DIAG ELE NAME FROM ID    ${element_id}
    Return From Keyword If    "${element_name}" == "${None}"
    # Should Be Equal    ${platform_type}    ${dut_id}    Wrong dut_id: ${dut_id}
    ${ecu_canakin_name}    ${ecu_eth_name} =    GET ECU DOIP INFO    ${platform_type}
    ${verdict}    ${comment} =    Canakin Write Hex For Data Identifier    ${ecu_canakin_name}    ${element_name}    ${hex_value}    auto_session=False    itf=${ecu_eth_name}    timeout=${timeout}
    # Log    Comment: ${comment}    console=True
    [Return]    ${verdict}    ${comment}

WAIT FOR VEHICLE DIAG HEX WRITE
    [Arguments]    ${platform_type}    ${expected_response_type}    ${send_write_verdict}    ${send_write_comment}
    [Documentation]     Verifies the previously writen Diag Hex over DoIP.
    ...    ${platform_type} :  Device under test: (aivi2_full).
    ...    ${expected_response_type}: Can be positive or negative
    ...    ${send_write_verdict}: Value that has to be verfied
    ...    ${send_write_comment}: Comment that has to be verfied
    # Log    Waiting for the Vehicle Diag write request to be ${expected_response_type} on ${platform_type}
    # Should Be Equal    ${platform_type}    ${dut_id}    Wrong dut_id: ${dut_id}
    Run Keyword If    "${expected_response_type}" == "positive"    Should Be True    ${send_write_verdict}    Error Message: ${send_write_comment}
    ...    ELSE    Should Not Be True    ${send_write_verdict}    Error Message: ${send_write_comment}
    Run Keyword If    "${expected_response_type}" == "positive"    Should Contain    ${send_write_comment}    Received positive response
    ...    ELSE    Should Not Contain    ${send_write_comment}    Received positive response

GET DIAG ELE NAME FROM ID
    [Arguments]    ${element_id}
    [Documentation]    Get the element_name corresponding to Diag Ele ID: ${element_id}
    ...    ${elemet_id}    Diag element id
    # Log    Getting the Diag Element Name From the Element ID: ${element_id}
    ${element_name} =    Set Variable If
    ...        "${element_id}" == "2000"    SysInfo
    ...        "${element_id}" == "2001"    Driving
    ...        "${element_id}" == "2002"    MEX
    ...        "${element_id}" == "2003"    NAV
    ...        "${element_id}" == "2004"    HMI
    ...        "${element_id}" == "2005"    Connectivity
    ...        "${element_id}" == "2006"    Display
    ...        "${element_id}" == "2007"    RVC
    ...        "${element_id}" == "2008"    Multimedia
    ...        "${element_id}" == "2009"    LongPress
    ...        "${element_id}" == "2010"    VPA
    ...        "${element_id}" == "2012"    MultimediaRadioDAB
    ...        "${element_id}" == "2013"    MultimediaRadioAntenna
    ...        "${element_id}" == "2014"    MultimediaRadioFMAMTunner
    ...        "${element_id}" == "2015"    MultimediaRadioGenericTuner
    ...        "${element_id}" == "2017"    Nissan_Vehicle_information
    ...        "${element_id}" == "2018"    TimeZone
    ...        "${element_id}" == "2023"    DTCMUXConfig
    ...        "${element_id}" == "2024"    CustomAssetsPackage
    ...        "${element_id}" == "2025"    CustomAssetsConfig
    ...        "${element_id}" == "2026"    CustomAssetsDependency1
    ...        "${element_id}" == "2027"    CustomAssetsDependency2
    ...        "${element_id}" == "2028"    CustomAssetsDependency3
    ...        "${element_id}" == "2029"    CustomAssetsDependency4
    ...        "${element_id}" == "2058"    CustomAssetsPassword
    ...        "${element_id}" == "2059"    PartAuthentication
    ...        "${element_id}" == "2060"    Rvc_Part2
    ...        "${element_id}" == "F1A2"    ConfigRefData    ${None}
    [Return]    ${element_name}

DOIP ENABLE TWT SERVICE
    [Documentation]     Enables/Disables TWT Service using DOIP
    [Arguments]    ${did}   ${value}
    SEND VEHICLE DIAG START SESSION    aivc2    default
    ${verdict}    ${comment}    ${data} =    DOIP READ DID    aivc2    ${did}
    Should Be True    ${verdict}    Error message: ${comment}
    ${contains}=    Run Keyword And Return Status    Should Contain    ${comment}    ${value}[0]
    Return From Keyword If     "${contains}" == "True"    TWT Service flag is already set to ${value}[0]
    SEND VEHICLE DIAG START SESSION    aivc2    extended
    DOIP WRITE DID    aivc2    ${did}    ${value}

SEND VEHICLE DIAG COMMAND
    [Arguments]     ${platform_type}    ${dtc_value}    ${timeout}=${uds_timeout}
    [Documentation]     Send a Diag command with the contents ${dtc_value} on the device under test ${dut_id}
    ...    ${platform_type}:  Device under test: (aivi2_full).
    ...    ${dtc_value}: value for status mask
    ...    https://automotive.softing.com/fileadmin/sof-files/pdf/de/ae/poster/uds_info_poster_v2.pdf
    Log To Console    Sending DIAG command ${dtc_value} request over DoIp on ${platform_type}
    # Should Be Equal    ${platform_type}    ${dut_id}    Wrong dut_id: ${dut_id}
    ${ecu_canakin_name}    ${ecu_eth_name} =    GET ECU DOIP INFO    ${platform_type}
    # Identfying the Service-id from the dtc_value provided
    ${service_id} =    Get Substring    ${dtc_value}    0    2
    # Identfying the Service-mneomonic from the service-id
    ${service_mnemonic} =    Set Variable If
    ...    "${service_id}"=="19"    RDTCI
    ...    "${service_id}"=="14"    CDTCI
    ...    Service-id ${service_id} not supported by matrix
    Should Not Be Equal    ${service_mnemonic}    Service-id ${service_id} not supported by matrix
    # CDTCI - Start
    ${group} =    Run Keyword If    "${service_mnemonic}"=="CDTCI"    Get Substring    ${dtc_value}    2
    ${verdict}    ${comment} =    Run Keyword If    "${service_mnemonic}"=="CDTCI"
    ...    CANAKIN CLEAR DIAGNOSTIC INFORMATION    ecu_name=${ecu_canakin_name}    group=${0x${group}}    itf=${ecu_eth_name}    timeout=${timeout}
    Return From Keyword If    "${service_mnemonic}"=="CDTCI"    ${verdict}    ${comment}
    # CDTCI - End
    # RDTCI - Start
    # Identifying the sub-function_hex from the dtc_value provided in case of RDTCI
    ${sub_func_hex} =    Run Keyword If    "${service_mnemonic}"=="RDTCI"    Get Substring    ${dtc_value}    2    4
    # Mapping the sub-function_hex wih the corresponding the sub-function_name in case of RDTCI
    ${sub_func_name} =    Run Keyword If    "${service_mnemonic}"=="RDTCI"    GET SUBFUNCTION FOR RDTCI    ${sub_func_hex}
    ${args_dict} =    GET ARGUMENTS FOR CANAKIN RDTCI    ${ecu_eth_name}    ${sub_func_name}    ${dtc_value}
    ${verdict}    ${comment} =    Run Keyword If
    ...    "${service_mnemonic}"=="RDTCI"
    ...    CANAKIN READ DTC INFORMATION    ${ecu_canakin_name}    ${sub_func_name}    &{args_dict}
    # Log    verdict: ${verdict}. comment: ${comment}
    # RDTCI - End
    [Return]    ${verdict}    ${comment}

GET SUBFUNCTION FOR RDTCI
    [Arguments]    ${sub_func_hex}
    [Documentation]     This is used to get the sub_func_name from the sub_func_hex only in case of read DTC information
    ...    ${sub_func_hex}:  Sub-Function hex value in case of a read DTC information. (01 to 15 in hexadecimal)
    Log    Getting the sub_func_name from the sub_func_hex: ${sub_func_hex}
    ${sub_func_name} =    Set Variable If
    ...    "${sub_func_hex}"=="01"    NumberOfDTCByStatusMask
    ...    "${sub_func_hex}"=="02"    DTCByStatusMask
    ...    "${sub_func_hex}"=="03"    DTCSnapshotIdentification
    ...    "${sub_func_hex}"=="04"    DTCSnapshotRecordByDTCNumber
    ...    "${sub_func_hex}"=="05"    DTCSnapshotRecordByRecordNumber
    ...    "${sub_func_hex}"=="06"    DTCExtendedDataRecordByDTCNumber
    ...    "${sub_func_hex}"=="07"    NumberOfDTCBySeverityMaskRecord
    ...    "${sub_func_hex}"=="08"    DTCBySeverityMaskRecord
    ...    "${sub_func_hex}"=="09"    SeverityInformationOfDTC
    ...    "${sub_func_hex}"=="0A"    SupportedDTC
    ...    "${sub_func_hex}"=="0B"    FirstTestFailedDTC
    ...    "${sub_func_hex}"=="0C"    FirstConfirmedDTC
    ...    "${sub_func_hex}"=="0D"    MostRecentTestFailedDTC
    ...    "${sub_func_hex}"=="0E"    MostRecentConfirmedDTC
    ...    "${sub_func_hex}"=="0F"    MirrorMemoryDTCByStatusMask
    ...    "${sub_func_hex}"=="10"    MirrorMemoryDTCExtendedDataRecordByDTCNumber
    ...    "${sub_func_hex}"=="11"    NumberOfMirrorMemoryDTCByStatusMask
    ...    "${sub_func_hex}"=="12"    NumberOfEmissionsRelatedOBDDTCByStatusMask
    ...    "${sub_func_hex}"=="13"    EmissionsRelatedOBDDTCByStatusMask
    ...    "${sub_func_hex}"=="14"    DTCFaultDetectionCounter
    ...    "${sub_func_hex}"=="15"    DTCWithPermanentStatus
    Should Not Be Equal    ${sub_func_name}    ${None}    Invalid sub_function_hex: ${sub_func_hex} provided for RDTCI
    Log    sub_func_name: ${sub_func_name}
    [Return]    ${sub_func_name}

GET ARGUMENTS FOR CANAKIN RDTCI
    [Arguments]    ${ecu_eth_name}    ${sub_func_name}    ${dtc_value}
    [Documentation]     This is used to get the additional arguments needed for Canakin to perform RDTCI
    # Sub-functions that need status_mask parameter
    ${sub_fun_with_sm_par} =    Create List    NumberOfDTCByStatusMask    DTCByStatusMask    MirrorMemoryDTCByStatusMask
    ...    NumberOfMirrorMemoryDTCByStatusMask    NumberOfEmissionsRelatedOBDDTCByStatusMask    EmissionsRelatedOBDDTCByStatusMask
    # Sub-functions that don't need any extra parameters
    ${sub_fun_with_no_par} =    Create List    DTCSnapshotIdentification    SupportedDTC    FirstTestFailedDTC    FirstConfirmedDTC
    ...    MostRecentTestFailedDTC    MostRecentConfirmedDTC    DTCFaultDetectionCounter    DTCWithPermanentStatus
    # Sub-functions that need dtc, snapshot_record_number parameters
    ${sub_fun_with_dtc_srn_par} =    Create List    DTCSnapshotRecordByDTCNumber    SeverityInformationOfDTC
    # Sub-functions that need snapshot_record_number parameter
    ${sub_fun_with_srn_par} =    Create List    DTCSnapshotRecordByRecordNumber
    # Sub-functions that need dtc, extended_data_record_number parameters
    ${sub_fun_with_dtc_edrn_par} =    Create List    DTCExtendedDataRecordByDTCNumber    MirrorMemoryDTCExtendedDataRecordByDTCNumber
    # Sub-functions that need status_mask, severity_mask parameters
    ${sub_fun_with_sm_svm_par} =    Create List    NumberOfDTCBySeverityMaskRecord    DTCBySeverityMaskRecord

    # For Sub-functions that need status_mask parameter
    ${args_dict} =    Create Dictionary
    ${status_mask} =    Run Keyword If
    ...    "${sub_func_name}" in "${sub_fun_with_sm_par}"
    ...    Get Substring    ${dtc_value}    4
    Run Keyword If    "${status_mask}" != "${None}"
    ...    Set To Dictionary    ${args_dict}    status_mask=0x${status_mask}
    # For Sub-functions that need dtc, snapshot_record_number parameters
    ${dtc} =    Run Keyword If
    ...    "${sub_func_name}" in "${sub_fun_with_dtc_srn_par}"
    ...    Get Substring    ${dtc_value}    4    10
    ${snapshot_record_number} =    Run Keyword If
    ...    "${sub_func_name}" in "${sub_fun_with_dtc_srn_par}"
    ...    Get Substring    ${dtc_value}    10    12
    Run Keyword If    "${dtc}" != "${None}"
    ...    Set To Dictionary    ${args_dict}    dtc=0x${dtc}
    Run Keyword If    "${snapshot_record_number}" != "${None}"
    ...    Set To Dictionary    ${args_dict}    snapshot_record_number=0x${snapshot_record_number}
    # For Sub-functions that need snapshot_record_number parameter
    ${snapshot_record_number} =    Run Keyword If
    ...    "${sub_func_name}" in "${sub_fun_with_srn_par}"
    ...    Get Substring    ${dtc_value}    4
    Run Keyword If    "${snapshot_record_number}" != "${None}"
    ...    Set To Dictionary    ${args_dict}    snapshot_record_number=0x${snapshot_record_number}
    # For Sub-functions that need dtc, extended_data_record_number parameters
    ${dtc} =    Run Keyword If
    ...    "${sub_func_name}" in "${sub_fun_with_dtc_edrn_par}"
    ...    Get Substring    ${dtc_value}    4    10
    ${extended_data_record_number} =    Run Keyword If
    ...    "${sub_func_name}" in "${sub_fun_with_dtc_edrn_par}"
    ...    Get Substring    ${dtc_value}    10    12
    Run Keyword If    "${dtc}" != "${None}"
    ...    Set To Dictionary    ${args_dict}    dtc=0x${dtc}
    Run Keyword If    "${extended_data_record_number}" != "${None}"
    ...    Set To Dictionary    ${args_dict}    extended_data_record_number=0x${extended_data_record_number}
    # For Sub-functions that need status_mask, severity_mask parameters
    ${status_mask} =    Run Keyword If
    ...    "${sub_func_name}" in "${sub_fun_with_sm_svm_par}"
    ...    Get Substring    ${dtc_value}    4    6
    ${severity_mask} =    Run Keyword If
    ...    "${sub_func_name}" in "${sub_fun_with_sm_svm_par}"
    ...    Get Substring    ${dtc_value}    6
    Run Keyword If    "${status_mask}" != "${None}"
    ...    Set To Dictionary    ${args_dict}    status_mask=0x${status_mask}
    Run Keyword If    "${severity_mask}" != "${None}"
    ...    Set To Dictionary    ${args_dict}    severity_mask=0x${severity_mask}
    Set To Dictionary    ${args_dict}    itf=${ecu_eth_name}
    [Return]    ${args_dict}

WAIT FOR VEHICLE DIAG COMMAND RESULT
    [Arguments]    ${platform_type}    ${expected_response}    ${dtc_cmd_verdict}    ${dtc_cmd_comment}
    [Documentation]     This command will check the result of a DTC command
    ...    ${platform_type}:  Device under test: (aivi2_full).
    ...    ${expected_response}: The expected response
    ...    ${dtc_cmd_verdict}: The verdict returned from the execution a DTC cmd
    ...    ${dtc_cmd_comment}: The comment returned from the execution a DTC cmd
    # Log    Check the result of a DTC command
    # Should Be Equal    ${platform_type}    ${dut_id}    Wrong dut_id: ${dut_id}
    ${expected_status} =    Get Substring    ${expected_response}    0    2
    Run Keyword If    "${expected_status}"=="54"    Should Be True    ${dtc_cmd_verdict}    Failed to receive positive response
    Return From Keyword If    "${expected_status}"=="54"
    Should Be Equal    ${expected_status}    59    Invalid expected_state: ${expected_status}
    Should Be True    ${dtc_cmd_verdict}    [Error] DTC Command Failed
    # sub_func_hex in case of RDTCI (59)
    ${sub_func_hex} =    Get Substring    ${expected_response}    2    4
    Return From Keyword If    "${sub_func_hex}"!="04"    DTC Command succeeded
    ${expected_status} =    Get Substring    ${expected_response}    -2
    ${masked_status_index} =    Evaluate    "${expected_status}".find("X")
    ${expected_status} =    Evaluate    "${expected_status}"[:${masked_status_index}] + "${expected_status}"[${masked_status_index}+1:]
    ${dtc_status_lines} =     Get Lines Containing String    ${dtc_cmd_comment}    "status":
    FOR    ${dtc_status_line}    IN    ${dtc_status_lines}
        ${dct_status} =    Strip String    ${dtc_status_line}    right    ",
        ${dtc_status} =    Fetch From Right    ${dct_status}    0x
        ${dtc_status} =    Evaluate    "${dtc_status}"[:${masked_status_index}] + "${dtc_status}"[${masked_status_index}+1:]
        Should Be Equal    ${dtc_status}    ${expected_status}
    END
    ${dtc_lines} =     Get Lines Containing String    ${dtc_cmd_comment}    "id":
    ${expexted_dtc} =    Get Substring    ${expected_response}    4    10
    FOR    ${dtc_line}    IN    ${dtc_lines}
        ${dtc_line} =    Strip String    ${dtc_line}    right    ",
        ${dtc} =    Fetch From Right    ${dtc_line}    0x
        Should Be Equal    ${dtc}    ${expexted_dtc}
    END

DIAG PUSH IVI VEHICLE CONFIG
    [Arguments]    ${platform_type}    ${vehicle_config_name}    ${vehicle_type}    ${hdmi_out}
    [Documentation]    Apply the vehicle config file on the target
    ...    ${platform_type}: name of platform
    ...    ${vehicle_config_name}: Name of configuration file
    ...    ${vehicle_type}: vechicle type like XCB
    ...    ${hdmi_out}: value of hdmi out
    @{coding_strings} =    GET CODING STRINGS FROM CONFIG XML    ${vehicle_config_name}    ${vehicle_type}
    Log List    ${coding_strings}
    ${verdict}    ${comment} =    SEND VEHICLE DIAG START SESSION    ${platform_type}    extended
    WAIT FOR VEHICLE DIAG START SESSION RESPONSE    ${platform_type}    positive    ${verdict}    ${comment}
    FOR    ${coding_string}    IN    @{coding_strings}
        ${coding_string} =    Get Substring    ${coding_string}    2
        ${element_id} =    Get Substring    ${coding_string}    0    4
        ${hex_value} =    Get Substring    ${coding_string}    4
        ${hex_value} =    Set Variable If    "${hdmi_out}"=="1" and "${element_id}"=="2006"    ${hdmi_config_value}    ${hex_value}
        ${verdict}    ${comment} =    SEND VEHICLE DIAG HEX WRITE    ${platform_type}    ${element_id}    ${hex_value}
        WAIT FOR VEHICLE DIAG HEX WRITE    ${platform_type}    positive    ${verdict}    ${comment}
        DO WAIT    1500
    END
    DOIP HARD RESET ECU AND WAIT BOOT    ${platform_type}    session=extended

SEND DTC CODE AND CHECK POSITIVE RESPONSE
    [Arguments]    ${dut_id}
    [Documentation]     Sending a mandatory DTC command to the ${dut_id}
    ...    ${dut_id}:  Device under test: (aivi2_full).
    ${rdtci_json} =    Evaluate    json.load(open("${rdtci_ivi}", "r"))    json
    ${rdtci_json} =    Set Variable    ${rdtci_json['RDTCI_codes']}
    ${rdtci_items} =    Get Dictionary Items    ${rdtci_json}
    ${rdtci_items_len} =    Get Length    ${rdtci_items}
    ${index} =    Set Variable    ${0}
    FOR    ${i}    IN RANGE    0    ${rdtci_items_len}/2
        ${rdtci_req} =    Get From List    ${rdtci_items}    ${index}
        ${index} =    Evaluate    ${index}+1
        ${rdtci_expected_res} =    Get From List    ${rdtci_items}    ${index}
        ${index} =    Evaluate    ${index}+1
        ${verdict}    ${comment} =    SEND VEHICLE DIAG COMMAND    ${dut_id}    ${rdtci_req}
        WAIT FOR VEHICLE DIAG COMMAND RESULT    ${dut_id}    ${rdtci_expected_res}    ${verdict}    ${comment}
    END

DOIP READ CONFIG
    [Arguments]    ${platform_type}    ${did_name}    ${session}=default
    [Documentation]     Reading configuration for DID: ${did_name}
    ${length} =  Get Length  ${did_name}
    ${length}    Evaluate    11 + ${length}
    ${verdict}    ${comment} =    SEND VEHICLE DIAG START SESSION    ${platform_type}    ${session}
    WAIT FOR VEHICLE DIAG START SESSION RESPONSE    ${platform_type}    positive    ${verdict}    ${comment}
    ${verdict}    ${comment} =    SEND VEHICLE DIAG DID READ    ${platform_type}    ${did_name}
    WAIT FOR VEHICLE DIAG DID READ    ${platform_type}    ${did_name}    positive    ${None}    ${verdict}    ${comment}
    ${old_payload} =    Get Substring    ${comment}    ${length}        -3
    [Return]    ${old_payload}

DOIP UPDATE CONFIG
    [Arguments]    ${platform_type}    ${did_value}    ${original_config}    ${byte_position}    ${bit_position}    ${new_value}    ${session}=extended
    [Documentation]     Update configuration for DID: ${did_value} at byte ${byte_position} - bit ${bit_position} with value : ${new_value}
    Log    Update configuration for DID: ${did_value} at byte ${byte_position} - bit ${bit_position} with value : ${new_value}
    ${new_payload} =    PAYLOAD UPDATE BIT LEVEL    ${original_config}    ${byte_position}    ${bit_position}    ${new_value}
    Log To Console    new payload: [${new_payload}]
    ${verdict}    ${comment} =    SEND VEHICLE DIAG START SESSION    ${platform_type}    ${session}
    WAIT FOR VEHICLE DIAG START SESSION RESPONSE    ${platform_type}    positive    ${verdict}    ${comment}
    ${verdict}    ${comment} =    SEND VEHICLE DIAG HEX WRITE    ${platform_type}    ${did_value}    ${new_payload}
    WAIT FOR VEHICLE DIAG HEX WRITE    ${platform_type}    positive    ${verdict}    ${comment}
    [Return]    ${new_payload}

DOIP SET CONFIG
    [Arguments]    ${platform_type}    ${did}    ${payload}    ${session}=extended
    [Documentation]     Writing configuration for DID: ${did}
    ${verdict}    ${comment} =    SEND VEHICLE DIAG START SESSION    ${platform_type}    ${session}
    WAIT FOR VEHICLE DIAG START SESSION RESPONSE    ${platform_type}    positive    ${verdict}    ${comment}
    ${verdict}    ${comment} =    SEND VEHICLE DIAG HEX WRITE    ${platform_type}    ${did}    ${payload}
    WAIT FOR VEHICLE DIAG HEX WRITE    ${platform_type}    positive    ${verdict}    ${comment}

DOIP HARD RESET ECU AND WAIT BOOT
    [Arguments]    ${platform_type}    ${session}=extended
    [Documentation]     Perform ECU reset and wait for booted completed
    Run Keyword If    '${ivi_hmi_action}' == 'True'    REMOVE APPIUM DRIVER    ${ivi_capabilities}
    ${verdict}    ${comment} =    SEND VEHICLE DIAG START SESSION    ${platform_type}    ${session}
    WAIT FOR VEHICLE DIAG START SESSION RESPONSE    ${platform_type}    positive    ${verdict}    ${comment}
    ${verdict}    ${comment} =    DOIP ECU RESET    hard_reset    ${platform_type}    tp_management=${True}
    Should Be True    ${verdict}
    Run Keyword If    '${ivi_hmi_action}' == 'True'    CREATE APPIUM DRIVER

DOIP UPDATE BYTE CONFIG
    [Arguments]    ${platform_type}    ${did_value}    ${original_config}    ${byte_position}    ${new_value}    ${session}=extended
    [Documentation]     Update configuration for DID: ${did_value} at byte ${byte_position} with value : ${new_value}
    Log    Update configuration for DID: ${did_value} at byte ${byte_position} with value : ${new_value}
    ${new_payload} =    PAYLOAD UPDATE BYTE LEVEL    ${original_config}    ${byte_position}    ${new_value}
    Log To Console    new payload: [${new_payload}]
    ${verdict}    ${comment} =    SEND VEHICLE DIAG START SESSION    ${platform_type}    ${session}
    WAIT FOR VEHICLE DIAG START SESSION RESPONSE    ${platform_type}    positive    ${verdict}    ${comment}
    ${verdict}    ${comment} =    SEND VEHICLE DIAG HEX WRITE    ${platform_type}    ${did_value}    ${new_payload}
    WAIT FOR VEHICLE DIAG HEX WRITE    ${platform_type}    positive    ${verdict}    ${comment}
    [Return]    ${new_payload}

DID PAYLOAD UPDATE BYTE LEVEL
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

DOIP ENABLE ECALL
    [Arguments]    ${did}    ${value}
    [Documentation]    Apply the vehicle config file on the target
    ...    ${did}: DID id
    ...    ${value}: DID value
    SEND VEHICLE DIAG START SESSION    aivc2    default
    ${verdict}    ${comment}    ${data} =    DOIP READ DID    aivc2    ${did}
    Should Be True    ${verdict}    Error message: ${comment}
    Return From Keyword If     "${value}" in ${comment}    Failed!
    SEND VEHICLE DIAG START SESSION    aivc2    extended
    DOIP WRITE DID    aivc2    ${did}    ${value}

DOIP SET PHONE NUMBER
    [Documentation]     Enables set pphone number Service using DOIP
    [Arguments]    ${did}    ${value}
    SEND VEHICLE DIAG START SESSION    aivc2    default
    ${verdict}    ${comment}    ${data} =    DOIP READ DID    aivc2    ${did}
    Should Be True    ${verdict}    Error message: ${comment}
    SEND VEHICLE DIAG START SESSION    aivc2    extended
    ${verdict}    ${comment} =    DOIP WRITE DID    aivc2    ${did}    ${value}
    Should Be True    ${verdict}    Error message: ${comment}sssss

CHECK TWT SERVICE ACTIVATED
    [Documentation]    Checks ON-Board using SQLite commands if the TWT service is activated or not
    ${verdict}    ${comment} =    rfw_services.wicket.SystemLib.CHECK TWT ACTIVATION FLAG
    Should Be True    ${verdict}    Error message: TWTFlag is not activated

ENERGY BUDGET VALUE FOR EPMC
    [Arguments]    ${platform_type}    ${action}    ${value}    ${parameter}=EPMC_InitEPMCBudget
    [Documentation]    Apply the vehicle config file on the target
    ...    ${platform_type}: the platform type
    ...    ${action}: possible values are SET/CHECK/RESTORE
    SEND VEHICLE DIAG START SESSION    ${platform_type}    extended
    IF    "${action}" == "SET"
        @{value_ff} =    Create List    ${value}
        ${verdict}    ${comment} =    DOIP WRITE DID   ${platform_type}    ${parameter}    ${value_ff}
    ELSE IF    "${action}" == "CHECK"
        ${verdict}    ${comment}    ${data} =    DOIP READ DID    ${platform_type}    ${parameter}
        Should Contain    ${comment}    "InitEPMCBudget": ${value}
    ELSE IF   "${action}" == "RESTORE"
        @{value_xx} =    Create List    ${value}
        ${verdict}    ${comment} =    DOIP WRITE DID    ${platform_type}    ${parameter}    ${value_xx}
        Should Be True    ${verdict}    Error message: ${comment}
        Sleep    2
        SEND VEHICLE DIAG START SESSION    ${platform_type}    default
        ${verdict}    ${comment}    ${data} =    DOIP READ DID    ${platform_type}    ${parameter}
    END
    Should Be True    ${verdict}    Error message: ${comment}

SEND DTC CODE AND CHECK FOR POSITIVE RESPONSE
    [Arguments]    ${dtc_code}    ${fault_type}
    [Documentation]     Sending a mandatory DTC command to the ${dut_id} and waiting for the response
    ...    ${dut_id} :  Device under test: (aivi2_full).
    ...    ${dtc_code} :  DTC code to be checked
    ...    ${fault_type} : Type of fault of ${dtc_code}
    ${dtc_code_req} =    Catenate    SEPARATOR=    ${dtc_read_req}    ${dtc_code}    ${fault_type}    FF
    ${verdict}    ${comment} =    SEND VEHICLE DIAG COMMAND    ${ivi_platform_type}    ${dtc_code_req}
    WAIT FOR VEHICLE DIAG COMMAND RESULT    ${ivi_platform_type}    54    ${verdict}    ${comment}

CHECK IVI TIME FORMAT
    [Arguments]    ${did_byte_position}    ${did_value}    ${signal_name}    ${signal_value}
    [Documentation]     Checking Current Time Format on ${dut_id}
    ...    ${did_byte_position} :  Byte position if config name
    ...    ${did_value} :  Bit position of ${did_byte_position} of config name
    ...    ${signal_name} :  Name of the can signal to be sent
    ...    ${signal_value} :  Value of ${signal_name} name
    ...    ${dut_id} :  Device under test: (aivi2_full).
    ${read_payload} =    DOIP READ CONFIG    ${ivi_platform_type}    HMI    extended
    DO WAIT    2000
    DOIP UPDATE BYTE CONFIG    ${ivi_platform_type}    2004    ${read_payload}    ${did_byte_position}    ${did_value}    extended
    CHECKSET DELETE FILE    ivi    ${clock_preferences}
    DOIP HARD RESET ECU AND WAIT BOOT    ${ivi_platform_type}
    CHECK VEHICLE SIGNAL    ${signal_name}    ${signal_value}

DO READ VEHICLE CONFIG
    [Documentation]    Read all did's which are in xml file.
    @{coding_strings} =    GET CODING STRINGS FROM CONFIG XML    ${vehicle_config_name}    ${vehicle_type}
    Log List    ${coding_strings}
    ${MyDictionary} =    Create Dictionary
    FOR    ${coding_string}    IN    @{coding_strings}
        ${coding_string} =    Get Substring    ${coding_string}    2
        ${element_id} =    Get Substring    ${coding_string}    0    4
        ${element_name} =    GET DIAG ELE NAME FROM ID    ${element_id}
        ${read_payload} =    DOIP READ CONFIG    ${ivi_platform_type}    ${element_name}    extended
        Set To Dictionary    ${MyDictionary}    ${element_id}    ${read_payload}
        DO WAIT    1500
    END
    Set Test Variable    ${MyDictionary}
    log to console    ${MyDictionary}

SET VEHICLE CONFIG
    [Documentation]    Restore old configuration in respective bench
    FOR    ${key}    IN    @{MyDictionary.keys()}
        DOIP SET CONFIG    ${ivi_platform_type}    ${key}    ${MyDictionary}[${key}]    extended
        DO WAIT    2000
    END
    DOIP HARD RESET ECU AND WAIT BOOT    ${ivi_platform_type}

GET CONFIGURATION DETAILS FROM CONFIG NAME
    [Arguments]    ${config_name}    ${device_type}=ivi    ${platform_version}=${platform_version}
    [Documentation]    Read required configuration details based config name
    ${did_variable} =    Catenate    SEPARATOR=    doip_byte_configuration_    ${device_type}    _android_    ${platform_version}    ['${config_name}']    ['did']
    ${did_name_variable} =    Catenate    SEPARATOR=    doip_byte_configuration_    ${device_type}    _android_    ${platform_version}    ['${config_name}']    ['did_name']
    ${byte_position_variable} =    Catenate    SEPARATOR=    doip_byte_configuration_    ${device_type}    _android_    ${platform_version}    ['${config_name}']    ['byte_position']
    ${values_variable} =    Catenate    SEPARATOR=    doip_byte_configuration_    ${device_type}    _android_    ${platform_version}    ['${config_name}']    ['values']
    [Return]    ${${did_variable}}    ${${did_name_variable}}    ${${byte_position_variable}}    ${${values_variable}}

SET CONFIGURATION PARAMETER
    [Arguments]    ${did}    ${did_name}    ${byte_position}    ${byte_value}
    [Documentation]    Set doip configuration using given arguments.
    ${read_payload} =    DOIP READ CONFIG    ${ivi_platform_type}    ${did_name}    default
    IF    "${payload}" == "${True}"
        Set Test Variable    ${original_payload}    ${read_payload}
        Set Test Variable    ${payload}    ${False}
    END
    DO WAIT    2000
    DOIP UPDATE BYTE CONFIG    ${ivi_platform_type}    ${did}    ${read_payload}    ${byte_position}    ${byte_value}    extended

CHECKSET CONFIGURATION
    [Arguments]    ${config_name}    ${device_type}=ivi    ${reset_type}=hard_reset
    [Documentation]    Apply doip configuration based on config name
    ${did}    ${did_name}    ${byte_position}    ${values} =    GET CONFIGURATION DETAILS FROM CONFIG NAME    ${config_name}    ${device_type}
    ${count} =    Get length    ${byte_position}
    FOR    ${index}    IN RANGE   0    ${count}
        doip.SET CONFIGURATION PARAMETER    ${did}    ${did_name}    ${byte_position}[${index}]    ${values}[${index}]
    END
    Run Keyword If    "${reset_type}" != "hard_reset"    DOIP ECU RESET    ${reset_type}    ${ivi_platform_type}    tp_management=${True}
    ...    ELSE    DOIP HARD RESET ECU AND WAIT BOOT    ${ivi_platform_type}
    Run Keyword If    '${ivi_hmi_action}' == 'True'    Run Keywords    REMOVE APPIUM DRIVER
    ...    AND    CREATE APPIUM DRIVER

DO RESTORE CONFIGURATION
    [Arguments]    ${config_name}    ${device_type}=ivi
    [Documentation]    Restore existing vehicle configuration
    ${did}    ${did_name}    ${byte_position}    ${values} =    GET CONFIGURATION DETAILS FROM CONFIG NAME    ${config_name}    ${device_type}
    DOIP SET CONFIG    ${ivi_platform_type}    ${did}    ${original_payload}
    DOIP HARD RESET ECU AND WAIT BOOT    ${ivi_platform_type}
    Run Keyword If    '${ivi_hmi_action}' == 'True'    CREATE APPIUM DRIVER

GET DEFAULT PAYLOAD
    [Arguments]    ${dut_id}
    [Documentation]    Get HMI doip configuration of ${dut_id}
    ...    ${dut_id} :  Device under test: (aivi2_full).
    ${default_payload} =    DOIP READ CONFIG    ${ivi_platform_type}    HMI    extended
    Set Suite Variable    ${default_payload}    ${default_payload}

UPDATE DID CONFIG
    [Arguments]    ${dut_id}
    [Documentation]    Set Configuration for DTC Codes of ${dut_id}
    ...    ${dut_id} :  Device under test: (aivi2_full).
    Log To Console    Updating HMI Configuration for Vehicle Type[HHN]
    ${original_hmi_payload} =    DOIP READ CONFIG    ${ivi_platform_type}    HMI
    Set Suite Variable    ${original_hmi_payload}    ${original_hmi_payload}
    DOIP UPDATE BYTE CONFIG    ${ivi_platform_type}    2004    ${original_hmi_payload}    0    00    extended
    DOIP HARD RESET ECU AND WAIT BOOT    ${ivi_platform_type}
    DO WAIT    2000

    Log To Console    Updating Multimedia configuration for AUDIO OUTPUT INFORMATION[Internal AMP (6channels)]
    ${original_multimedia_payload_1} =    DOIP READ CONFIG    ${ivi_platform_type}    Multimedia
    Set Suite Variable    ${original_multimedia_payload_1}    ${original_multimedia_payload_1}
    DOIP UPDATE BYTE CONFIG    ${ivi_platform_type}    2008    ${original_multimedia_payload_1}    0    00    extended
    DOIP HARD RESET ECU AND WAIT BOOT    ${ivi_platform_type}
    DO WAIT    2000

    Log To Console    Updating Multimedia configuration for DAB[Enabled]
    ${original_multimedia_payload_2} =    DOIP READ CONFIG    ${ivi_platform_type}    Multimedia
    Set Suite Variable    ${original_multimedia_payload_2}    ${original_multimedia_payload_2}
    DOIP UPDATE CONFIG    ${ivi_platform_type}    2008    ${original_multimedia_payload_2}    31    0    1    extended
    DOIP HARD RESET ECU AND WAIT BOOT    ${ivi_platform_type}
    DO WAIT    2000

    Log To Console    Updating Multimedia configuration for RADIO PHASE DIVERSITY[Enabled]
    ${original_multimedia_payload_3} =    DOIP READ CONFIG    ${ivi_platform_type}    Multimedia
    Set Suite Variable    ${original_multimedia_payload_3}    ${original_multimedia_payload_3}
    DOIP UPDATE CONFIG    ${ivi_platform_type}    2008    ${original_multimedia_payload_3}    31    1    1    extended
    DOIP HARD RESET ECU AND WAIT BOOT    ${ivi_platform_type}
    DO WAIT    2000

    Log To Console    Updating SysInfo Configuration for AR NAV CAMERA[Activated]
    ${original_sys_config_payload} =    DOIP READ CONFIG    ${ivi_platform_type}    SysInfo
    Set Suite Variable    ${original_sys_config_payload}    ${original_sys_config_payload}
    DOIP UPDATE CONFIG    ${ivi_platform_type}    2000    ${original_sys_config_payload}    18    4    1    extended
    DOIP HARD RESET ECU AND WAIT BOOT    ${ivi_platform_type}
    DO WAIT    2000

    Log To Console    Updating RVC Configuration for Analog RVC[RVC_Gen1]
    ${original_rvc_payload} =    DOIP READ CONFIG    ${ivi_platform_type}    RVC
    Set Suite Variable    ${original_rvc_payload}    ${original_rvc_payload}
    DOIP UPDATE BYTE CONFIG    ${ivi_platform_type}    2007    ${original_rvc_payload}    2    30    extended
    DOIP HARD RESET ECU AND WAIT BOOT    ${ivi_platform_type}
    DO WAIT    2000

RESTORE ORIGINAL DID CONFIG
    [Arguments]    ${dut_id}
    [Documentation]    Restore Configuration for DTC Codes of ${dut_id}
    ...    ${dut_id} :  Device under test: (aivi2_full).
    DOIP SET CONFIG    ${ivi_platform_type}    2004    ${original_hmi_payload}
    DOIP SET CONFIG    ${ivi_platform_type}    2008    ${original_multimedia_payload_1}
    DOIP SET CONFIG    ${ivi_platform_type}    2008    ${original_multimedia_payload_2}
    DOIP SET CONFIG    ${ivi_platform_type}    2008    ${original_multimedia_payload_3}
    DOIP SET CONFIG    ${ivi_platform_type}    2000    ${original_sys_config_payload}
    DOIP SET CONFIG    ${ivi_platform_type}    2007    ${original_rvc_payload}

    BuiltIn.Sleep    5
    DOIP HARD RESET ECU AND WAIT BOOT    ${ivi_platform_type}

READ DDT2000 ECU IDENTIFICATION
    [Documentation]    == High Level Description: ==
    ...    Read ECU identifiers with DDT2000
    ...    == Parameters: ==
    ...    == Expected Results: ==
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automation    Remote Services Common    IVC CMD
    Log    Keyword not mandatory since action is done manually for now

READ AND CHECK DOIP DID
    [Documentation]     Read operational reference using DOIP
    [Arguments]    ${did}   ${value}
    SEND VEHICLE DIAG START SESSION    aivc2    default
    ${verdict}    ${comment}    ${data} =    DOIP READ DID    aivc2    ${did}
    Should Be True    ${verdict}    Error message: ${comment}
    Should Contain    ${comment}    ${value}

SEND VEHICLE DIAG START ROUTINE
    [Arguments]    ${ivc_platform_type}    ${routine_id}    ${control_type}    ${data}
    [Documentation]    == High Level Description: ==
    ...    Check the ETHERNET setup
    ...    == Parameters: ==
    ...    - _ivc_platform_type_:  type of platform
    ...    - _routine_id_:  id routine control
    ...    - _routine_write_:  type of routine control
    ...    - _data_:  the data to be sent
    ...    == Expected Results: ==
    ...    Passed if the data is sent
    [Tags]    Automated    Remote DOIP    Routine CMD
    ${verdict}    ${comment} =    DOIP ROUTINE CONTROL    ${ivc_platform_type}    ${routine_id}    ${control_type}    ${data}
    Should Be True    ${verdict}    Error message: ${comment}
    Log To Console    Routine Write Output: ${comment}

CHECK CAN PAIRING BETWEEN SGW AND HFM
    [Documentation]     Check CAN pairing between SGW and HFM is performed with success
    [Arguments]    ${value}
    ${verdict}    ${comment}    ${json} =    DOIP READ DID    sgw    Pairing_Status    session=default
    Should be True    ${verdict}
    Should Be True    "${json}[Pairing_Status]" == "${value}"    Error message: ${comment}
    Should Contain    ${comment}    ${value}

DOIP UNLOCK ECU
    [Arguments]    ${platform_type}
    ${ecu_canakin_name}    ${ecu_eth_name} =    GET ECU DOIP INFO    ${platform_type}
    ${verdict}    ${comment} =    Canakin Unlock Ecu    ecu_name=${ecu_canakin_name}    itf=${ecu_eth_name}
    SHOULD BE TRUE      ${verdict}    ${comment}
    [Return]    ${verdict}    ${comment}

RECORD ENERGY BUDGET VALUE
    [Arguments]    ${platform_type}    ${parameter}=EPMC_InitEPMCBudget
    [Documentation]    Check the value of the energy budget and retrieve the result
    ...    ${platform_type}: the platform type
    ...    ${action}: possible values are SET/CHECK/RESTORE
    SEND VEHICLE DIAG START SESSION    ${platform_type}    extended
    ${verdict}    ${comment}    ${data} =    DOIP READ DID    ${platform_type}    ${parameter}
    Should Be True    ${verdict}    Error message: ${comment}
    ${returned_value} =    Evaluate    $data.get("InitEPMCBudget")
    Set Test Variable    ${ret_val_epmc}    ${returned_value}

CHECK ANTIREPLAY COUNTER ONBOARD
    [Documentation]     Check CAN pairing between SGW and HFM is performed with success
    ${verdict}    ${comment}    ${json} =    DOIP READ DID    sgw    Data_monitor_CCS    session=default
    Should be True    ${verdict}
    ${anti_replay_counter_cipher} =    Get From Dictionary   ${json}    Anti_replay_counter_for_Cipher_Channel
    ${verdict} =    Evaluate    ${anti_replay_counter_cipher} == ${res_counter} + 1

CHECKSET AUTOMATIC ECALL MEMORIZATION STATE
    [Arguments]    ${value}
    [Documentation]    Check automatic Ecall memorization state is different from 'violent crash has been done'.
    ...    ${value}: the value that should not be present in response
    SEND VEHICLE DIAG START SESSION    aivc2    default
    ${verdict}    ${comment}    ${data} =    DOIP READ DID    aivc2    Ecall_Memorization
    Should Be True    ${verdict}    Error message: ${comment}
    Return From Keyword If     "${value}" not in ${comment}    Failed!
    SEND VEHICLE DIAG START SESSION    aivc2    extended
    DOIP WRITE DID    aivc2    Clear_Diag_Ecall    1
    SEND VEHICLE DIAG START SESSION    aivc2    extended
    DOIP ECU RESET    hard_reset    aivc2    tp_management=${True}
    BuiltIn.Sleep    60000ms
    CHECK IVC BOOT COMPLETED

DOIP SET ECALL CALLBACK TIMEOUT
    [Arguments]    ${did}    ${value}
    [Documentation]    Set the ecall  Stcallback timeout expiration specified value on the target
    ...    ${did}: DID id
    ...    ${value}: DID value
    SEND VEHICLE DIAG START SESSION    aivc2    default
    ${verdict}    ${comment}    ${data} =    DOIP READ DID    aivc2    ${did}
    Should Be True    ${verdict}    Error message: ${comment}
    Return From Keyword If     "${value}" in ${comment}    Failed!
    SEND VEHICLE DIAG START SESSION    aivc2    extended
    DOIP WRITE DID    aivc2    ${did}    ${value}
