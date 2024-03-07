#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#

*** Settings ***
Documentation    This file contains the OCTAV load configs and other KW implementations related to OCTAV
Resource          ${CURDIR}/../Tools/bench_config.robot
Library           rfw_services.octav.OctavLib    proxy_dict=${bench_proxy_config}
Library           OperatingSystem
Library           Collections
Library           String
Library           yaml

*** Variables ***
${octav_vehicle_type}    CAR1_MATRIX_IVC
&{ucd_version}     UCD_VERSION=2.02.10.01
@{octav_config}    octav.yaml    car.yaml    dcm.yaml    ${ucd_version}
${app_header_dcm}    app_header_dcm.json
${app_data_dcm}    app_data_dcm.json
${mdd_data}    mdd_data.json
${part_authent_config}    part_authent_config.yaml
${empty_trigger}
${device_type}    A-IVC
${timeout}    ${180}

*** Keywords ***
START OCTAV TOOL
    ${octav_config_path} =    Get Environment Variable    OCTAV_CONFIG_PATH
    ${verdict}    ${comment} =    OCTAV SET CONFIG FILES    ${octav_config_path}    @{octav_config}
    Should Be True    ${verdict}

    ${verdict} =    OCTAV SET VEHICLE TYPE    ${octav_vehicle_type}_${vehicle_id}
    Should Be True    ${verdict}

    ${verdict} =    OCTAV SET DEVICE TYPE    ${device_type}
    Should Be True    ${verdict}

    ${octav_config_path} =    Get Environment Variable    OCTAV_CONFIG_PATH
    ${app_header_dcm_path} =    Join Path    ${octav_config_path}    ${app_header_dcm}
    ${verdict}    ${comment} =    OCTAV LOAD DATA MODEL    ApplicationHeader    ${app_header_dcm_path}
    Should Be True    ${verdict}

    ${app_data_dcm_path} =    Join Path    ${octav_config_path}    ${app_data_dcm}
    ${verdict}    ${comment} =    OCTAV LOAD DATA MODEL    ApplicationData    ${app_data_dcm_path}
    Should Be True    ${verdict}

    ${mdd_data_path} =    Join Path    ${octav_config_path}    ${mdd_data}
    ${verdict}    ${comment} =    OCTAV LOAD DATA MODEL    MasterDataDict    ${mdd_data_path}
    Should Be True    ${verdict}

    ${verdict} =    OCTAV CONNECT MQTT
    Should Be True    ${verdict}

STOP OCTAV TOOL
    ${verdict} =    OCTAV DISCONNECT MQTT
    Should Be True    ${verdict}

CHECK SRP INIT MQTT WITH OCTAV
    [Arguments]    ${message_name}
    [Documentation]    Checks SRP MQTT messages. The dictionary created must have the same parameters as the request
    ...    dictionary
    ...    == Parameters: ==
    ...    - _message_name_: name of a message containing a specific message and configuration
    ...    == Expected Results: ==
    ...    output: passed/failed
    ${params} =    Run Keyword If    "${message_name}" == "init_pin_code"    Create Dictionary    SRP_Pincode_SRP_Verifier=${srp_verifier}
    ...    SRPLoginSRP_I=${username}    SRPLoginSRP_salt=${srp_client_salt}
    ${verdict}    ${global_id}    ${correlation_id} =    OCTAV CHECK MQTT MESSAGE    SRPRequest    SRP_PINCODE   ${empty_trigger}    ${timeout}    ${params}
    Should Be True    ${verdict}    Fail to CHECK SRP INIT MQTT WITH OCTAV

SEND SRP INIT MQTT MESSAGE WITH OCTAV
    [Arguments]    ${message_name}
    [Documentation]    Computes the MQTT message sent by OCTAV simulator to VNEXT.
    ...    == Parameters: ==
    ...    - _message_name_: name of a message containing a specific message and configuration
    ...    == Expected Results: ==
    ...    output: passed/failed
    ${message_type} =    Set Variable    SRPNotification
    ${target_id} =    Set Variable If    "${message_name}" == "init_pin_code_ack"    SRP_PincodeAck
    ...    "${message_name}" == "init_pin_code_status"    SRP_PincodeStatus
    ${params} =    Create Dictionary    SRPPINCODEStatus=OK
    ${verdict}    ${global_id}    ${correlation_id} =    OCTAV SEND MQTT MESSAGE    ${message_type}    ${target_id}    ${empty_trigger}    ${params}
    Should Be True    ${verdict}    Fail to SEND SRP INIT MQTT MESSAGE WITH OCTAV

CHECK SRP SALT MQTT WITH OCTAV
    [Arguments]    ${user}=${username}
    [Documentation]    == High Level Description: ==
    ...    Checks SRP MQTT messages. The dictionary created must have the same parameters as the request dictionary
    ...    == Parameters: ==
    ...    - _username_: username asociated with the VIN
    ...    == Expected Results: ==
    ...    output: passed/failed
    ${params} =    Create Dictionary    SRPLoginSRP_I=${username}    SRPLoginSRP_A=${srp_value_A}
    ${verdict}    ${global_id}    ${correlation_id} =    OCTAV CHECK MQTT MESSAGE    SRPRequest    SRP_LOGIN    ${empty_trigger}    ${timeout}    ${params}
    Should Be True    ${verdict}    Failed to CHECK SRP SALT MQTT WITH OCTAV

SEND SRP SALT MQTT MESSAGE WITH OCTAV
    [Documentation]    == High Level Description: ==
    ...    Computes the MQTT message sent by OCTAV simulator to VNEXT.
    ...    == Parameters: ==
    ...    - _None_
    ...    == Expected Results: ==
    ...    output: passed/failed
    DO SRP GENERATE s and B
    ${params} =    Create Dictionary    SRPLoginSRP_B=${SRP_B}    SRPLoginSRP_s=${SRP_s}    SRP_LoginStatus=OK
    ${verdict}    ${global_id}    ${correlation_id} =    OCTAV SEND MQTT MESSAGE    SRPNotification    SRP_LOGIN    ${empty_trigger}    ${params}
    Should Be True    ${verdict}    Fail to CHECK IVC TO VNEXT MESSAGE SRP

CHECK RLU MQTT WITH OCTAV
    [Arguments]    ${action}    ${rlu_option}=NA
    [Documentation]    Checks RLU MQTT messages. The dictionary created must have the same parameters as the request dictionary
    ...    == Parameters: ==
    ...    - _action_: requested remote action
    ...    - _rlu_option_: requested remote option
    ...    == Expected Results: ==
    ...    output: passed/failed
    ${RLU_REQ_DICT} =    Create Dictionary    RLUAction=Lock    RLU_Option=AllDoors    RLU_Option1=${rlu_option}    SRP_PROOF=${srp_proof}
    ${verdict}    ${global_id}    ${correlation_id} =    OCTAV CHECK MQTT MESSAGE    RemoteOrder    RLU    ${empty_trigger}    ${timeout}    ${RLU_REQ_DICT}
    Should Be True    ${verdict}    Failed to CHECK RLU MQTT WITH OCTAV

SEND RLU ACK MESSAGE WITH OCTAV
    [Documentation]    Computes the MQTT message sent by OCTAV simulator to VNEXT.
    ...    == Parameters: ==
    ...    - _None_
    ...    == Expected Results: ==
    ...    output: passed/failed
    ${ACKNOWLEDGE_DICT} =    Create Dictionary    RLUStatus=0
    ${OCTAV_RLU_RESPONSE} =    Create List    RemoteAIVCAcknowledgement    RLU    ${empty_trigger}    ${ACKNOWLEDGE_DICT}
    ${verdict}    ${global_id}    ${correlation_id} =    OCTAV SEND MQTT MESSAGE    @{OCTAV_RLU_RESPONSE}
    Should Be True    ${verdict}    Fail to SEND RLU ACK MESSAGE WITH OCTAV

CHECK RLU UCD MQTT WITH OCTAV
    [Documentation]    Checks UCD MQTT messages. The dictionary created must have the same parameters as the request dictionary
    ...    == Parameters: ==
    ...    - _None_
    ...    == Expected Results: ==
    ...    output: passed/failed
    ${RLU_DataList} =    Create List    StatusDoorOutsideLockedState  StatusDoorFrontLeft  StatusDoorFrontRight  StatusDoorRearLeft  StatusDoorRearRight  StatusDoorEngineHood  StatusDoorTailGate  StatusDoorDriver  StatusDoorPassenger
    ${RLU_DICT} =    Create Dictionary    DataList=@{RLU_DataList}
    ${OCTAV_RLU_CHECK} =    Create List    RemoteUploadRequest    UCD_REQ    ${empty_trigger}    ${timeout}    ${RLU_DICT}    ${FALSE}
    ${verdict}    ${global_id}    ${correlation_id} =    OCTAV CHECK MQTT MESSAGE    @{OCTAV_RLU_CHECK}
    Should Be True    ${verdict}    Failed to CHECK RLU UCD MQTT WITH OCTAV

SEND RLU UCD MQTT MESSAGE WITH OCTAV
    [Arguments]    ${action}
    [Documentation]    Computes the MQTT message sent by OCTAV simulator to VNEXT.
    ...    == Parameters: ==
    ...    - _action_: lock/unlock doors
    ...    == Expected Results: ==
    ...    output: passed/failed
    ${RLU_RESPONSE_DICT} =    Run Keyword If    "${action}" == "lock"    Create Dictionary    StatusDoorDriver=0
    ...    StatusDoorEngineHood=2    StatusDoorOutsideLockedState=1    StatusDoorPassenger=1    StatusDoorRearLeft=1
    ...    StatusDoorRearRight=1    StatusDoorTailGate=1
    ...    ELSE IF    "${action}" == "unlock"    Create Dictionary    StatusDoorDriver=1    StatusDoorEngineHood=2
    ...    StatusDoorOutsideLockedState=0    StatusDoorPassenger=1    StatusDoorRearLeft=1    StatusDoorRearRight=1
    ...    StatusDoorTailGate=0
    ${OCTAV_RLU_RESPONSE} =    Create List    UCD_Snapshot    Notification    UCD/Sent/Trigger/Trg_On_request    ${RLU_RESPONSE_DICT}
    ${verdict}    ${global_id}    ${correlation_id} =    OCTAV SEND MQTT MESSAGE    @{OCTAV_RLU_RESPONSE}
    Should Be True    ${verdict}    Fail to SEND SRP MQTT MESSAGE WITH OCTAV

SEND RHL ACK MESSAGE WITH OCTAV
    [Documentation]    Computes the MQTT message sent by OCTAV simulator to VNEXT.
    ...    == Parameters: ==
    ...    - _None_
    ...    == Expected Results: ==
    ...    output: passed/failed
    ${RHL_dict} =    Create Dictionary   RHLStatus=0
    ${verdict}    ${global_id}    ${correlation_id} =    Run Keyword    OCTAV SEND MQTT MESSAGE    RemoteAIVCAcknowledgement    RHL    ${empty_trigger}    ${RHL_dict}
    Should Be True    ${verdict}    Fail to SEND RHL ACK MESSAGE WITH OCTAV

CHECK RHL MQTT MESSAGE WITH OCTAV
    [Arguments]    ${message_name}
    [Documentation]    Checks RHL MQTT messages. The dictionary created must have the same parameters as the request dictionary
    ...    == Parameters: ==
    ...    - _message_name_: - _message_name_: name of a message containing a specific message and configuration
    ...    == Expected Results: ==
    ...    output: passed/failed
    ${RHL_dict} =    Run Keyword If    "${message_name}" == "start_horn_lights"     Create Dictionary    RHL_Option=HornLight    RHLAction=Start    SRP_PROOF=${srp_proof}
    ...    ELSE IF    "${message_name}" == "stop_horn_lights"   Create Dictionary    RHL_Option=HornLight    RHLAction=Stop    SRP_PROOF=${srp_proof}
    ${verdict}    ${global_id}    ${correlation_id} =    Run Keyword    OCTAV CHECK MQTT MESSAGE    RemoteOrder    RHL    ${empty_trigger}    ${timeout}    ${RHL_dict}
    Should Be True    ${verdict}    Fail to SEND RHL MQTT MESSAGE WITH OCTAV

COPY CERTIFICATES AND MODIFY OCTAV CONFIG
    # verify that the device .pem certificate has been generated by cirrus PA execution
    File Should Exist    ${cirrus_folder}${part_params_dict["serial_number"]}.pem
    # copy the certificate obtained from vnext for the particular device
    Copy Files     ${cirrus_folder}${part_params_dict["serial_number"]}.pem    ${octav_folder}
    File Should Exist     ${octav_folder}${part_params_dict["serial_number"]}.pem
    File Should Exist    ${cirrus_folder}${part_params_dict["serial_number"]}.key
    # copy the device key to the octav folder
    Copy Files     ${cirrus_folder}${part_params_dict["serial_number"]}.key    ${octav_folder}
    File Should Exist     ${octav_folder}${part_params_dict["serial_number"]}.key

    # load the existing config file from octav "octav.yaml" and replace the link,device.pem and device.key
    File Should Exist    ${octav_folder}octav.yaml
    ${OCTAV_YAML_CONFIG} =    Get File    ${octav_folder}octav.yaml
    ${octav_config_changes} =    yaml.Safe Load    ${OCTAV_YAML_CONFIG}
    Set To Dictionary  ${octav_config_changes}[protocolgateway]    apiUrl=${octav_publishing_link}
    Set To Dictionary  ${octav_config_changes}[protocolgateway][TLS]    octavCertificate=${part_params_dict["serial_number"]}.pem    octavPrivKey=${part_params_dict["serial_number"]}.key
    ${SAVE_OCTAV_YAML} =  yaml.Dump   ${octav_config_changes}
    OperatingSystem.Create File  ${CURDIR}/octav.yaml  ${SAVE_OCTAV_YAML}

    # delete the old config file octav.yaml and
    # copy the octav config file created in the local execution folder to the octav folder of rfw_services
    File Should Exist    ${octav_folder}octav.yaml
    Remove File    ${octav_folder}octav.yaml
    File Should Not Exist    ${octav_folder}octav.yaml
    Log    ${octav_folder} yyyy
    Log    ${CURDIR} zzzz
    Copy Files    ${CURDIR}/octav.yaml    ${octav_folder}
    File Should Exist    ${octav_folder}octav.yaml

RUN PART AUTHENTICATION WITH OCTAV
    # Create working folders and part/device specific dictionary to be used with Cirrus lib
    ${cirrus_folder} =    Set Variable    ${CURDIR}../../../../rfw_services/cirrus/
    ${octav_folder} =     Set Variable    ${CURDIR}../../../../rfw_services/octav/
    Set Test Variable    ${cirrus_folder}
    Set Test Variable    ${octav_folder}
    ${part_params_dict} =    Run Keyword If    "${device_type}"=="A-IVC"    Create Dictionary    vin=${vehicle_id}    serial_number=${ivc_sn}    part_number=${ivc_pn}
    ...    ELSE    Create Dictionary    vin=${vehicle_id}    serial_number=${ivi_sn}    part_number=${ivi_pn}
    ${vnext_env} =    Fetch From Left    ${env}    -
    Set To Dictionary    ${part_params_dict}    env=${vnext_env}
    Set Test Variable    ${part_params_dict}
    CIRRUS SET CONFIG    ${part_authent_config}
    CIRRUS SET PA CERTIFICATE    vnext.pem    ${part_params_dict["serial_number"]}.key
    ${octav_publishing_link} =    RUN PART AUTHENTICATION    ${part_params_dict}
    Set Test Variable    ${octav_publishing_link}

CONFIGURE OCTAV FOR PART AUTHENT
    COPY CERTIFICATES AND MODIFY OCTAV CONFIG
    START OCTAV TOOL
    Sleep    30

SEND OCTAV IVC MQTT CERTIFICATE BURNT
    ${verdict}    ${global_id}    ${correlation_id} =    OCTAV SEND MQTT MESSAGE    RemoteNotification    CertificateInstalled    ${empty_trigger}
    Should Be True    ${verdict}    Fail to CHECK IVC/IVI TO VNEXT MESSAGE CERT INSTALLED

PREPARE PA SETUP
    ${part_params_dict} =    Run Keyword If    "${device_type}"=="A-IVC"    Create Dictionary    vin=${vehicle_id}    serial_number=${ivc_sn}    part_number=${ivc_pn}
    ...    ELSE    Create Dictionary    vin=${vehicle_id}    serial_number=${ivi_sn}    part_number=${ivi_pn}
    ${vnext_env} =    Fetch From Left    ${env}    -
    Set To Dictionary    ${part_params_dict}    env=${vnext_env}
    Set Test Variable    ${part_params_dict}
    CIRRUS SET CONFIG    ${part_authent_config}
    CIRRUS SET PA CERTIFICATE    vnext.pem    ${part_params_dict["serial_number"]}.key
