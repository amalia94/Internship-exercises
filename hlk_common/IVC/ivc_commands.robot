#
# Copyright (c) 2020, 2021, 2022 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Library           rfw_services.wicket.AcsfLib
Library           rfw_services.wicket.ConnectivityLib
Library           rfw_services.wicket.DateLib
Library           rfw_services.wicket.DeviceLib
Library           rfw_services.wicket.LocationLib
Library           rfw_services.wicket.RadioAccessTechnologyLib
Library           rfw_services.wicket.SystemLib
Library           rfw_services.wicket.DiagnosticLib
Library           rfw_libraries.toolbox.CometLib.CometLib
Library           descmo_generation.py
Library           String
Library           OperatingSystem

*** Variables ***
${console_logs}    yes
${ivc_sn}    None
${ivi_sn}    None
${filename}    /tmp/COMET/technical_prod_data.json
${Set_DRX_Mode_Duration}    1
@{cmd_crash_log_strings}    'Receive request to change component state to'    'is no more alive, signal sent to application manager'
@{acsf_services}    rhl    rlu    rpc    rc    bci    res    ocm    rpu    ucd    wlan
@{technical_product_ids}    200729    20000000    200308    200362    200499    200820    2003233    2003453
    ...    200202    200299    200315    2003662    200021    200235    200323    200364    202021    2000123
    ...    200494    200809    200730    200018    200824    202042    200499    200027    200097
@{acsf_services}    rhl    rlu    rpc    rc    bci    res    ocm    rpu    ucd    wlan    lca    partAuthentication
${error_string}    Error
${descmo_artifactory_path}    matrix/artifacts/automation/
${descmo_file}    descmoData.xml
${destination_folder}    /ota/
${root_dir}       ./
@{ota_files}    fota.validator.descmo.check    commited.txt    current_state    fota.app.variant    descmoResult.xml    fota.app.result    fota.app.variant    fota.descmo.xml    fota.descmo.xml.sig    fota.sm.previous_state    fota.uds.last_request    fota.uds.request_info

*** Keywords ***
CHECK IVC BOOT COMPLETED
    [Arguments]    ${timeout}=180   ${set_log_level_none}=False
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    ${\n}CHECK IVC BOOT COMPLETED${\n}
    ${previous_log_level} =    Run keyword if    "${set_log_level_none}" == "True"    Set Log Level    NONE
    ${is_connected}   ${comment} =    rfw_services.wicket.DeviceLib.WAIT FOR DEVICE    ${timeout}
    Run keyword if    "${set_log_level_none}" == "True"    Set Log Level    ${previous_log_level}
    Run Keyword If    "${is_connected}" != "True"    Log To Console    ${\n}Fail to connect to IVC after ${timeout} seconds${\n}
    Should Be True    ${is_connected}    Fail to connect to IVC after ${timeout} seconds
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    ${\n}IVC BOOT COMPLETED${\n}

CHECK IVC DISCONNECTED
    [Arguments]    ${stop_time}=120
    ${stop_time} =    Evaluate    ${stop_time} * 1000
    DO WAIT    ${stop_time}
    # TODO: Need to detect more dynamically the way the IVC is in sleep mode

GET IVC INFO
    ${verdict}    ${ivc_build_id} =    GET IVC BUILD ID
    Set Suite Variable    ${ivc_build_id}
    Set Tags     [IVC] Build ID : ${ivc_build_id}

CHECK CERTIFICATE IS PRESENT ON
    [Arguments]    ${dut_id}
    Log    Keyword not mandatory since action is done manually for now

CHECKSET VNEXT URL CONFIG
    [Arguments]    ${dut_id}
    Log    Keyword not mandatory since action is done manually for now

SET VNEXT TIME AND DATE ON IVC
    Log    Keyword not mandatory since action is done manually for now

DO CONFIGURE IVC CIPHERKEY
    Log    Keyword not mandatory since action is done manually for now

CHECK PIN CODE STORED ON IVC
    [Arguments]    ${expected_result}
    Log    Keyword not mandatory since action is done manually for now

DO MONITOR IVC SRP STORE STRATEGY DURING
    [Arguments]    ${timeout}
    Log    Keyword not implemented

CHECKSET IVC LOCAL APN CONFIG
    [Arguments]    ${ivc_apn}     ${ivi_apn}
    [Documentation]    Check the IVC local APN config is set appropriatly to the config file
    ${verdict} =  SKIP IVC HLK IF IVI USER BUILD  0
    Return From Keyword If    "${verdict}" == "True"
    ${ivc_apn} =    Set Variable If    "${ivc_apn}" == "${None}"    rnm-ccs2-test.dcp.orange.com    ${ivc_apn}
    ${ivi_apn} =    Set Variable If    "${ivi_apn}" == "${None}"    test.dcp.orange.fr    ${ivi_apn}
    ${verdict}    ${ivc_output} =    CHECK DB DID    SIMProfile_APN1_Param
    ${verdict}    ${ivi_output} =    CHECK DB DID    SIMProfile_APN3_Param

    Return From Keyword If    "${ivc_apn}" in """${ivc_output}""" and "${ivi_apn}" in """${ivi_output}"""

    ${verdict}    ${output} =    SET OF STATE MANAGER    configurationparameter    value    ${ivi_apn}   parameterName    SIMProfile_APN3_Param
    Should Be True    ${verdict}    Failed SET OF STATE MANAGER: ${output}
    ${verdict}    ${output} =    SET OF STATE MANAGER    configurationparameter    value    ${ivc_apn}    parameterName    SIMProfile_APN1_Param
    Should Be True    ${verdict}    Failed SET OF STATE MANAGER: ${output}
    SET IVC LOCAL APN CONFIG    ${ivc_apn}
    Should Be True    ${verdict}    Failed to SET IVC LOCAL APN CONFIG: {comment}
    CLOSE SSH SESSION
    ${verdict}    ${ivc_output} =    CHECK DB DID    SIMProfile_APN1_Param
    Should Contain    ${ivc_output}    ${ivc_apn}
    ${verdict}    ${ivi_output} =    CHECK DB DID    SIMProfile_APN3_Param
    Should Contain    ${ivi_output}    ${ivi_apn}
    CHECK RMNET DATA0

DO REBOOT IVC
    [Arguments]    ${timeout}=100
    [Documentation]    Send reboot command to IVC
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    ${\n}DO REBOOT IVC, timeout ${timeout}s${\n}
    rfw_services.wicket.DeviceLib.REBOOT    ${timeout}
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    ${\n}IVC REBOOTED${\n}

CHECKSET POWER TYPE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...     Check on the IVC Platform that the power type is appropriately set
    ...    == Parameters: ==
    ...    _value_: ice, ev, hev, phev
    ${power_type} =    Set Variable If    "${value}" == "unavailable"    0    "${value}" == "ice"    1
    ...    "${value}" == "ev"    2    "${value}" == "hev"    3    "${value}" == "phev"    4
    ${returned_power_type} =    GET POWER TYPE
    Return From Keyword If    "${power_type}" in """${returned_power_type}"""
    ${verdict}    ${output} =    SET POWER TYPE    ${power_type}
    Should Be True    ${verdict}    Failed to CHECKSET POWER TYPE: ${output}

CHECK RMNET DATA0
    [Documentation]    Check ifconfig command on IVC to check is rmnet_data0 is up
    ${verdict}    ${output} =    CHECK NETWORK INTERFACE    rmnet_data0
    Should Be True    ${verdict}    rmnet_data0 is not up: ${output}

CHECK IVC MQTT CONNECTION STATUS
    [Arguments]    ${status}=success    ${loop}=16    ${sleep_between_retries}=5
    [Documentation]    on ivc platform, check if ivc is connected to MQTT
    ...    currently, the command used is adb shell netstat -n | grep -ni '8883.ESTABLISHED'
    ${verdict} =  SKIP IVC HLK IF IVI USER BUILD  90
    Return From Keyword If    "${verdict}" == "True"
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    CHECK IVC MQTT CONNECTION STATUS start
    CHECK IVC BOOT COMPLETED
    FOR    ${i}    IN RANGE    ${loop}
        ${verdict}    ${comment} =    rfw_services.wicket.ConnectivityLib.CHECK MQTT CONNECTION
        IF    "${status}" == "success" and "${verdict}" == "${TRUE}"
            Run Keyword if    "${console_logs}" == "yes"     Log To Console    Wait 10 seconds to confirm IVC MQTT CONNECTION
            Sleep    10
            ${verdict}    ${comment} =    rfw_services.wicket.ConnectivityLib.CHECK MQTT CONNECTION
        END
        Run Keyword if    "${status}" == "success"    EXIT FOR LOOP IF   "${verdict}" == "${TRUE}"
        Run Keyword if    "${status}" == "disabled"   EXIT FOR LOOP IF  "${verdict}" != "${TRUE}"
        Run Keyword if    "${console_logs}" == "yes"     Log To Console    CHECK IVC MQTT CONNECTION STATUS retrying in 5 seconds
        Sleep    ${sleep_between_retries}
    END
    Run Keyword If    "${i}"=="${loop}"    Log To Console    CHECK IVC MQTT CONNECTION STATUS failed after many tries
    Run Keyword If    "${status}"=="success"    Should Be True    ${verdict}    IVC is not connected to MQTT
    ...    ELSE    Should Be Equal    ${verdict}    ${FALSE}
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    CHECK IVC MQTT CONNECTION STATUS end with success

GET IVC TIME
    [Arguments]    ${attribute}
    [Documentation]    Get IVC time
    ${verdict}    ${ivc_time} =    GET DATE ON IVC
    Should Be True    ${verdict}    Failed to GET DATE ON IVC: ${ivc_time}
    ${ivc_time_stamp} =	Replace String	${ivc_time}    T    ${space}
    ${remove_empty} =    Remove String    ${ivc_time_stamp}    \n
    Run Keyword If    '${attribute}'=='tstart'    Set Global Variable    ${tstart}    ${remove_empty}
        ...    ELSE    Set Global Variable    ${tstop}    ${remove_empty}
    [Return]    ${remove_empty}

COMPARE IVC & VNEXT TIME
    [Documentation]    Compare the IVC and vNext time
    Log To Console    COMPARE IVC & VNEXT TIME
    ${vnext_time_stamp} =    RECORD VNEXT DATE & TIME    t0
    ${vnext_time_stamp} =    DateTime.Convert Date    ${vnext_time_stamp}    result_format=%d %b %Y %I:%M %p
    ${ivc_time_stamp} =    GET IVC TIME    t0
    ${ivc_time_delta_minus} =    DateTime.Subtract Time From Date    ${ivc_time_stamp}    00:02:00
    ${ivc_time_stamp_delta_minus} =    Fetch From Left    ${ivc_time_delta_minus}    .
    ${ivc_time_stamp_delta_minus} =    DateTime.Convert Date    ${ivc_time_stamp_delta_minus}    result_format=%d %b %Y %I:%M %p
    ${ivc_time_delta_plus} =    DateTime.Add Time To Date    ${ivc_time_stamp}    00:02:00
    ${ivc_time_stamp_delta_plus} =    Fetch From Left    ${ivc_time_delta_plus}    .
    ${ivc_time_stamp_delta_plus} =    DateTime.Convert Date    ${ivc_time_stamp_delta_plus}    result_format=%d %b %Y %I:%M %p
    Log To Console    Timestamps ivc_time_delta_minus:${ivc_time_delta_minus} vnext_time_stamp:${vnext_time_stamp} ivc_time_stamp_delta_plus:${ivc_time_stamp_delta_plus}
    ${verdict} =    Evaluate    '''${ivc_time_stamp_delta_minus}''' < '''${vnext_time_stamp}''' < '''${ivc_time_stamp_delta_plus}'''
    Should Be True    ${verdict}    IVC & vNext have different timestamps

DO GPS LOCATION
    ${verdict}    ${latitude} =    LOCATION GET LATITUDE
    Run Keyword If    "${verdict}" == "True"    Should Not Contain Any    ${latitude}    ERROR(5)    null
    ...    ELSE    Log To Console    Failed to get latitude value
    ${verdict}    ${longitude} =    LOCATION GET LONGITUDE
    Run Keyword If    "${verdict}" == "True"    Should Not Contain Any    ${longitude}    ERROR(5)    null
    ...    ELSE    Log To Console    Failed to get longitude value
    ${verdict}    ${source} =    LOCATION GET SOURCE
    Run Keyword If    "${verdict}" == "True"    Should Not Contain Any    ${source}    ERROR(5)    null
    ...    ELSE    Log To Console    Failed to get location source value
    ${verdict}    ${validity} =    LOCATION GET VALIDITY
    Run Keyword If    "${verdict}" == "True"    Should Not Contain Any    ${validity}    ERROR(5)    null
    ...    ELSE    Log To Console    Failed to get location validity value
    ${verdict}    ${header} =    LOCATION GET HEADER
    Run Keyword If    "${verdict}" == "True"    Should Not Contain Any    ${header}    ERROR(5)    null
    ...    ELSE    Log To Console    Failed to get location header value

CHECK ACTIVATION FLAG FOR
    [Arguments]    ${action}    ${timeout}=60    ${service}=ucdproperty    ${TC_folder}=${EMPTY}
    [Documentation]    == High Level Description: ==
    ...    Check the number of flags for activated services at IVC side
    ...    == Parameters: ==
    ...    - _action_: represents the SA action performed (example: activate, deactivate)
    ...    == Expected Results: ==
    ...    Passed if the flags number is successfully retrieved
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Remote Services Common    IVC CMD
    ${verdict}    ${comment} =    CHECK ACTIVATION FLAG    ${action}    ${service}    ${timeout}
    Run Keyword If    "${TC_folder}"=="RELIABILITY"    Run keyword And Continue On Failure    Should Be True    ${verdict}    Failed CHECK ACTIVATION FLAG: ${comment}
    ...    ELSE    Should Be True    ${verdict}

SEND EMAIL FOR VNEXT STATUS
    [Arguments]    ${target}    ${status}    ${TC_folder}=${EMPTY}
    [Documentation]    == High Level Description: ==
    ...    Send email to VNext team to store the credentials of {target} in Vnext.
    ...    == Parameters: ==
    ...    - _target_: IVC
    ...    - _status_: New, Burnt
    ...    == Expected Results: ==
    ...    - PASS if the status coresponds with new or burnt as introduced from the test cases.
    ...    - FAIL otherwise
    [Tags]    Automated    CREDENTIALS    STATUS    IVC CMD
    Run Keyword If    "${ivc_sn}" == "None" and "${ivi_sn}" == "None"   Fail    Please specify a valid serial number
    ${type_env} =    Set Variable If   "${env}" == "stg-emea"    STG    SIT
    ${serial_number} =     Run Keyword If   "${target}" == "IVC"    Set Variable    ${ivc_sn}
    ...    ELSE IF    "${target}" == "IVI"    Set Variable    ${ivi_sn}
    ...    ELSE    Fail    Target ${target} is not valid
    ${verdict}    ${comment} =    RUN PA SCRIPT    pa_pipeline.py    ${serial_number}    ${status}    certificate_status.txt    ${type_env}
    Run Keyword If    "${TC_folder}"=="RELIABILITY"    Run keyword And Continue On Failure    Should Be True    ${verdict}    Failed to reset the PA status
    ...    ELSE    Should Be True    ${verdict}    Failed to reset the PA status

CHECK VNEXT VIN CERTIFICATE STATUS
    [Arguments]    ${target}    ${status}    ${TC_folder}=${EMPTY}
    [Documentation]    == High Level Description: ==
    ...    Check on vnext the VIN's certificate status
    ...    == Parameters: ==
    ...    - _status_: New, Burnt
    ...    == Expected Results: ==
    ...    - PASS if the status coresponds with new or burnt as introduced from the test cases.
    ...    - FAIL otherwise
    [Tags]    Automated    VIN CERTIFICATE STATUS
    Run Keyword If    "${ivc_sn}" == "None" and "${ivi_sn}" == "None"   Fail    Please specify a valid serial number
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    CHECK VNEXT VIN CERTIFICATE STATUS ${target} ${status}
    ${type_env} =    Set Variable If   "${env}" == "stg-emea"    STG    SIT
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    ${\n}${type_env}${\n}
    ${serial_number} =     Run Keyword If   "${target}" == "IVC"    Set Variable    ${ivc_sn}
    ...    ELSE IF    "${target}" == "IVI"    Set Variable    ${ivi_sn}
    ...    ELSE    Fail    Target ${target} is not valid
    ${verdict}    ${comment} =    RUN PA SCRIPT    pa_pipeline.py    ${serial_number}    ${status}
    ...    certificate_status.txt    ${type_env}    True
    Run Keyword If    "${TC_folder}"=="RELIABILITY"    Run keyword And Continue On Failure     Should Be True    ${verdict}    Fail to read the PA status: ${comment}
    ...    ELSE     Should Be True    ${verdict}    Fail to read the PA status: ${comment}

DO RESET IVC PART AUTHENTICATION STATUS
    [Arguments]    ${TC_folder}=${EMPTY}
    [Documentation]    == High Level Description: ==
    ...    Reset the part authentication status on IVC in order to trig a new part authentication.
    ...    == Parameters: ==
    ...    - none
    ...    == Expected Results: ==
    ...    pass when output contains: Status 2 NO CERT
    ...    fails otherwise
    [Tags]    Automated    Remote Services Common    Connected Services Domain
    ${verdict}    ${comment} =    SET ENROL CERT STATUS    2
    Run Keyword If    "${TC_folder}"=="RELIABILITY"    Run keyword And Continue On Failure     Should Be True    ${verdict}    Fail to reset part authentication status: ${comment}
    ...    ELSE     Should Be True    ${verdict}    Fail to reset part authentification status
    IF    "${TC_folder}"!="RELIABILITY"
        DO REBOOT IVC
        CHECK IVC BOOT COMPLETED
    END

CHECK IVC PART AUTHENTICATION STATUS
    [Arguments]    ${ivc_status}=0    ${TC_folder}=${EMPTY}
    [Documentation]    == High Level Description: ==
    ...    Check the part authentication status on IVC
    ...    == Parameters: ==
    ...    - none
    ...    == Expected Results: ==
    ...    pass when output contains: 'CertificateEnrolmentStatus','0' or '2'
    ...    ivc status 0 is used for certificate burnt
    ...    ivc status 2 is used for certificate new
    ...    fails otherwise
    [Tags]    Automated    Remote Services Common    Connected Services Domain
    ${verdict}    ${comment} =    CHECK ENROL CERT STATUS    ${ivc_status}
    Run Keyword If    "${TC_folder}"=="RELIABILITY"    Run keyword And Continue On Failure    Should Be True    ${verdict}    Part Authentication is not in desired status: ${comment}
    ...    ELSE     Should Be True    ${verdict}    Part Authentication is not in desired status

CHECKSET CERT ENROLL STATUS
    [Arguments]    ${ivc_status}=0
    [Documentation]    == High Level Description: ==
    ...    Check the part authentication status on IVC
    ...    == Parameters: ==
    ...    - IVC_certicate_enrillment_status
    ...    == Expected Results: ==
    ...    Check if the Certificate is in Expected State else Set the Certificate to expected state
    [Tags]    Automated    Remote Services Common    Connected Services Domain
    ${verdict}    ${comment} =    CHECK ENROL CERT STATUS    ${ivc_status}
    IF    ${verdict} == False
        SET ENROL CERT STATUS    ${ivc_status}
        DO REBOOT IVC
        CHECK IVC BOOT COMPLETED
    END

SET DRX STATE
    [Arguments]     ${Drx_state}
    [Documentation]    Enable/disable DRX mode
    ...    1 : enable DRX
    ...    0 : disable DRX
    # set Drxstate
    ${verdict}    ${output} =    SET OF STATE MANAGER    configurationproperty    activationState    ${Drx_state}    propertyName    DRXActivationStatus
    Should Be True    ${verdict}    Failed SET OF STATE MANAGER: ${output}
    Should Not Contain    ${output}    ${error_string}

SET DRX DURATION
    [Arguments]     ${Drx_Duration}
    [Documentation]    Change Drx duraton to different value
    # set Drx_ModeDuration
    ${verdict}    ${output} =    SET OF STATE MANAGER    configurationparameter    value    ${Drx_Duration}    parameterName    IVCBS_DRX_ModeDuration
    Should Be True    ${verdict}    Failed SET OF STATE MANAGER: ${output}
    Should Not Contain    ${output}    ${error_string}

SET MQTT SESSION TYPE
    [Arguments]     ${Mqtt_Session_Type}
    [Documentation]    Change MQTT session type
    ...    1 : On Demand
    ...    0 : Always Connected
    # set MQTT Session Type
    ${verdict}    ${output} =    SET OF STATE MANAGER    configurationparameter    value    ${MQTT_Session_Type}    parameterName    IVCBS_MQTTsessType
    Should Be True    ${verdict}    Failed SET OF STATE MANAGER: ${output}
    Should Not Contain    ${output}    ${error_string}

SET MQTT AON DURATION
    [Arguments]     ${Mqtt_aon_Duration}
    [Documentation]    Change MQTT AON duration to different value
    # set MQTT AON Duration
    ${verdict}    ${output} =    SET OF STATE MANAGER    configurationparameter    value    ${Mqtt_aon_Duration}    parameterName    IVCBS_StOffDataMaxT2
    Should Be True    ${verdict}    Failed SET OF STATE MANAGER: ${output}
    Should Not Contain    ${output}    ${error_string}

SET MQTT KEEP ALIVE DURATION
    [Arguments]     ${Mqtt_keepalive_Duration}
    [Documentation]    Change MQTT Keep Alive duration to different value
    # set MQTT Keep Alive Duration
    ${verdict}    ${output} =    SET OF STATE MANAGER    configurationparameter    value    ${Mqtt_keepalive_Duration}    parameterName    IVCBS_MQTTTkeepAlive
    Should Be True    ${verdict}    Failed SET OF STATE MANAGER: ${output}
    Should Not Contain    ${output}    ${error_string}

CHECKSET IVC STDRX CONFIGURATION
    [Arguments]    ${IVCBS_DRX_ModeDuration}=2D00
    [Documentation]    Checks the IVC configuration is in Stdrx state. If not it will put the IVC in that state.
    ${ivc_state_parameters}    Create Dictionary    DRXActivationStatus=1    IVCBS_DRXstatus=1    IVCBS_DRX_ModeDuration=${IVCBS_DRX_ModeDuration}    IVCBS_StOffDataMaxT2=0
    ${output} =    READ IVC DRX PARAMETERS    ${ivc_state_parameters}
    ${verdict} =    Evaluate    ${output} == ${ivc_state_parameters}
    Run Keyword If    "${verdict}" == "False"    WRITE IVC DRX PARAMETERS    True    &{ivc_state_parameters}
    ...     ELSE    Log    Signals are already set for stdrx configuration"

CHECKSET IVC STOFF CONFIGURATION
    [Documentation]    Checks the IVC configuration is in Stoff state. If not it will put the IVC in that state.
    ${ivc_state_parameters}    Create Dictionary    DRXActivationStatus=0    IVCBS_DRXstatus=0    IVCBS_DRX_ModeDuration=0    IVCBS_StOffDataMaxT2=0
    ${output} =    READ IVC DRX PARAMETERS    ${ivc_state_parameters}
    ${verdict} =    Evaluate    ${output} == ${ivc_state_parameters}
    Run Keyword If    "${verdict}" == "False"    WRITE IVC DRX PARAMETERS    True    &{ivc_state_parameters}
    ...     ELSE    Log    Signals are already set for stoff configuration"

CHECKSET IVC STOFFDATA CONFIGURATION
    [Documentation]    Checks the IVC configuration is in Stoffdata state. If not it will put the IVC in that state.
    ${ivc_state_parameters}    Create Dictionary    DRXActivationStatus=1    IVCBS_DRXstatus=1    IVCBS_DRX_ModeDuration=2D00
    ...    IVCBS_StOffDataMaxT2=1680    IVCBS_MQTTTkeepAlive=04B0    IVCBS_TWTflag=0
    ${output} =    READ IVC DRX PARAMETERS    ${ivc_state_parameters}
    ${verdict} =    Evaluate    ${output} == ${ivc_state_parameters}
    Run Keyword If    "${verdict}" == "False"    WRITE IVC DRX PARAMETERS    True    &{ivc_state_parameters}
    ...     ELSE    Log    Signals are already set for stoffdata configuration"

READ IVC DRX PARAMETERS
    [Documentation]    Retrieves the actual values for all the parameters which influences the transition to StDRX state
    ...    == Expected Results: ==
    ...    output: it returns a dictionary containing the initial values set on the IVC platform
    [Tags]    Automated    Remote Services Common    IVC CMD
    [Arguments]    ${IVC_expected_config}
    &{DRX_config}    Create Dictionary
    FOR    ${parameter}    IN    @{IVC_expected_config.keys()}
        ${initial_value} =    READ DRX PARAMETER    ${parameter}
        ${extract_value} =     Get From List    ${initial_value}    1
        ${value} =    Fetch From Left    ${extract_value}    \r\
        ${value} =    Fetch From Left    ${value}    \n
        Should Not Contain    ${initial_value}    Error    Failed to read the value for ${parameter} parameter
        Set To Dictionary    ${DRX_config}    ${parameter}=${value}
    END
    Set Test Variable    ${IVC_initial_config}    &{DRX_config}
    [Return]    ${IVC_initial_config}

SET IP TABLE
    [Documentation]    This keyword is used to set IP table on IVC.
    SET IVC IP TABLE RULE

RESTORE IP TABLE
    [Documentation]    This keywrod is used to restore IP table on IVC.
    RESTORE IVC IP TABLE RULE

WRITE IVC DRX PARAMETERS
    [Documentation]    Writes new values for the parameters which influences the transition to StDRX state
    ...    == Parameters: ==
    ...    _can_flag_: based on this flag the CAN signal emission can be started
    ...    _drx_parameters_: represents an dictionary that contains the expected tuples (parameter:value) needed
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    Remote Services Common    IVC CMD
    [Arguments]    ${can_flag}=True    &{drx_parameters}
    Run Keyword If    "${can_flag}" != "True"    Run Keywords
    ...    CONFIGURE VEHICLE STUB PROFILE    only_keep_ivc_on
    ...    AND    Sleep    60
    ${items}    Get Dictionary Items    ${drx_parameters}
    FOR    ${parameter}    ${value}    IN    @{items}
        ${output} =    WRITE DRX PARAMETER    ${parameter}    ${value}
        ${check_output} =    Get From List    ${output}    1
        Should Be Empty    ${check_output}    Failed to set ${parameter} parameter due to: ${output}
    END
    Run Keyword And Ignore Error    CLOSE SSH SESSION
    DO REBOOT IVC

CHECK IVC DAL
    [Arguments]    ${date_time}=None    ${expected_verdict}=True
    [Documentation]    Compares the navigation date time with the given date time.
    ${status}    ${navigation_date_time} =    GET_NAVIGATION_DATE_TIME
    Should Be True    ${status}    The navigation date time could not be retrieved!
    Log    Navigation date time: ${navigation_date_time}.

    ${date_time} =    Set Variable If    "${date_time}" == "None"    ${tstart}    ${date_time}
    Log    Date time: ${date_time}.

    ${verdict} =    Evaluate    '''${navigation_date_time}''' > '''${date_time}'''
    Run Keyword If    "${expected_verdict}" == "True"    Should Be True    ${verdict}    The navigation date time is not greater than the provided date time!
    ...    ELSE    Should Not Be True    ${verdict}

RILSHELL IVC COMMAND CHECK DUAL APN
    [Arguments]    ${expected_verdict}=True
    [Documentation]    Checks if rmnet_data0 and rmnet_data1 interfaces have the expected apn.
    ${verdict}    ${output} =    CHECK DUAL APN
    Run Keyword If    "${expected_verdict}" == "True"    Should Be True    ${verdict}    Failed to CHECK DUAL APN: ${output}
    ...    ELSE    Should Not Be True    ${verdict}

CHECK IVC VSS SIGNAL
    [Arguments]    ${signal_name}    ${expected_value}
    [Documentation]    Check on VSS component what is the value of the signal_name
    Log To Console    CHECK IVC VSS SIGNAL:- Check on VSS component value:${expected_value} of the signal_name:${signal_name}
    ${verdict}    ${output} =    GET VSS SIGNAL    ${signal_name}
    Should Contain    ${output}    ${expected_value}

CHECK IVC CONNECTIVITY ON
    [Arguments]    ${timeout}=180
    ${verdict} =  SKIP IVC HLK IF IVI USER BUILD  90
    Return From Keyword If    "${verdict}" == "True"
    ${verdict}    ${output} =    CHECK PING RESULT    1    1    8.8.8.8
    Run Keyword If    ${verdict} == False    CHECK IVC INTERNET CONNECTION    ${timeout}
    ...    ELSE      Should Be True    ${verdict}    IVC is not connected

CHECK IVC INTERNET CONNECTION
    [Arguments]    ${timeout}=180    ${TC_folder}=${EMPTY}    ${expected_status}=on
    [Documentation]    Check if the IVC connectivity is ON
    ${now} =    Get Time    epoch
    ${end_time} =    Evaluate    ${now} + ${timeout}
    FOR    ${i}    IN RANGE    ${0}    ${100}
        ${verdict}    ${comment} =    CHECK NSLOOKUP RESULT    www.google.com
        Exit For Loop If    "${verdict}" == "${TRUE}"
        Sleep    10
        ${current_time} =    Get Time    epoch
        Exit For Loop If     ${current_time} > ${end_time}
    END

    Run Keyword If    "${expected_status}"=="off"    Should Not Be True    ${verdict}    IVC connectivity is on
    Return From Keyword If    "${expected_status}"=="off"

    Run Keyword If    "${TC_folder}"=="RELIABILITY"    Run keyword And Continue On Failure    Should Be True    ${verdict}    IVC connectivity is off
    ...    ELSE    Should Be True    ${verdict}    IVC connectivity is off

SET IVC PROBE PERMIT
    [Arguments]    ${state}
    [Documentation]    on ivc platform, set the data probe permit to On or OFF
    ...    currently, the work around to use is adb shell vs-svp set prups ${state}
    ${verdict}    ${output} =    SYSTEM SET PROBE PERMIT    ${state}
    Should Be True    ${verdict}    Failed SYSTEM SET PROBE PERMIT: ${output}

CHECK ACSF SERVICES STATUS
    [Arguments]    ${target_id}    ${status}
    [Documentation]    Check on IVC Platform that all the services are running fine
    ${verdict} =    CHECK ACSF SERVICE STATUS    ${acsf_services}
    Should Be True    ${verdict}

DO_READ_WRITE_PARAMETER_IN_CONFIG_FILE
    [Documentation]    Read config parameter, change config parameter to different value and check if value is changed.
    ...    then write back config parameter to the actual value.
    ${verdict}    ${output} =    CHECK DB DID    IVCBS_DRX_ModeDuration
    Should Be True    ${verdict}    Failed to CHECK DB DID: ${output}
    ${DRX_Mode_Duration} =    Strip String     ${output}
    ${verdict}    ${output} =    UPDATE DB DID    IVCBS_DRX_ModeDuration    ${Set_DRX_Mode_Duration}
    Should Be True    ${verdict}    Failed to UPDATE DB DID: ${output}
    ${verdict}    ${output} =    CHECK DB DID    IVCBS_DRX_ModeDuration
    Should Be True    ${verdict}    Failed to CHECK DB DID: ${output}
    Should Contain    ${output}    ${Set_DRX_Mode_Duration}
    ${verdict}    ${output} =    UPDATE DB DID    IVCBS_DRX_ModeDuration    ${DRX_Mode_Duration}
    Should Be True    ${verdict}    Failed to UPDATE DB DID: ${output}
    ${verdict}    ${output} =    CHECK DB DID    IVCBS_DRX_ModeDuration
    Should Be True    ${verdict}    Failed to CHECK DB DID: ${output}
    Should Contain    ${output}    ${DRX_Mode_Duration}

SET PREFERRED NETWORK
    [Arguments]    ${network_type}
    [Documentation]   On IVC, sets the preferred network type
    ${verdict}    ${output} =    SET MODEM NETWORK TYPE    ${network_type}
    Run Keyword If    "${network_type}" == "lte"    Should Contain    ${output}    radio  technology changed to LTE    Modem registration failed
    ...    ELSE IF    "${network_type}" == "wcdma"    Should Contain    ${output}    radio  technology changed to UMTS    Modem registration failed
     ...    ELSE IF    "${network_type}" == "gsm_only"    Should Contain    ${output}    radio  technology changed to EDGE    Modem registration failed
    ...    ELSE    Run Keyword if    "${console_logs}" == "yes"     Log To Console    Invalid network type: ${network_type}

CHECK MODEM REGISTRATION STATUS
    [Arguments]    ${status}    ${network_type}
    [Documentation]   On IVC, checks the Modem registration status
    Log To Console    CHECK MODEM REGISTRATION STATUS
    ${verdict}    ${output} =    READ MODEM NETWORK TYPE
    Run Keyword If    "${network_type}" == "lte" and "${status}" == "success"    Should Contain    ${output}    LTE    Modem registration failed
    ...    ELSE IF    "${network_type}" == "wcdma" and "${status}" == "success"    Should Contain    ${output}    WCDMA    Modem registration failed
    ...    ELSE IF    "${network_type}" == "gsm_only" and "${status}" == "success"    Should Contain    ${output}    GSM    Modem registration failed
    ...    ELSE    Log To Console    Invalid network type/status: ${network_type}/${status}

SET MODEM POWER
    [Arguments]    ${power_mode}
    [Documentation]   On IVC, sets the modem power mode
    ...    on : Power on
    ...    off : Power off
    Log To Console    SET MODEM POWER
    ${verdict}    ${output} =    SET MODEM POWER MODE    ${power_mode}
    Should Be True    ${verdict}
    Run Keyword If    "${power_mode}" == "on"    DO REBOOT IVC

CHECK IVC REBOOT STATUS
    [Documentation]    Check IVC Reboot Status
    ${verdict}    ${output} =    SYSTEM GET VIN NUMBER
    Should Be True    ${verdict}    Failed SYSTEM GET VIN NUMBER: ${output}

SET IVC DATA PRIVACY
    [Arguments]    ${state}
    [Documentation]    On ivc platform, set the data privacy to ON or OFF
    ...    off : Privacy mode off
    ...    on : Privacy mode on
    ${verdict} =  SKIP IVC HLK IF IVI USER BUILD  5
    Return From Keyword If    "${verdict}" == "True" or "${ivc_my_feature_id}" == "MyF3"
    ${data_privacy_parameter} =    Set Variable If    "${state}" == "off"    1    0
    ${verdict}    ${output} =    SYSTEM SET DATA PRIVACY    ${data_privacy_parameter}
    Should Be True    ${verdict}    Failed to SYSTEM SET DATA PRIVACY: ${output}

CHECK IVC DATA PRIVACY
    [Arguments]    ${state}
    [Documentation]    To check if privacy mode is set to the expected state
    Return From Keyword If    "${ivc_my_feature_id}" == "MyF3"
    ${verdict}    ${output} =    GET DATA PRIVACY
    Run Keyword If    "${state}"=="off"    Should Be Equal As Integers    ${output}    1    IVC Data Privacy is not in expected state:${state}
    ...    ELSE IF    "${state}"=="on"    Should Be Equal As Integers    ${output}    0    IVC Data Privacy is not in expected state:${state}
    ...    ELSE    Log To Console    Invalid data privacy state:${state}

DO CHECK IVC STATE
    [Documentation]   check IVC state of the Device
    ${verdict}    ${output} =    CHECK IVC STATE
    Should Be True    ${verdict}    Failed CHECK IVC STATE: ${output}
    [Return]    ${output}

DO RESET IVC PART AUTHENTICATION STATUS PA DONE
    [Documentation]    == High Level Description: ==
    ...    Reset the part authentication status on IVC in order to trig a new part authentication.
    ...    == Parameters: ==
    ...    - none
    ...    == Expected Results: ==
    ...    pass when output contains: Status 0 OK
    ...    fails otherwise
    [Tags]    Automated    Remote Services Common    Connected Services Domain
    Log To Console    DO RESET IVC PART AUTHENTICATION STATUS PA DONE
    ${verdict}    ${comment} =    SET ENROL CERT STATUS    0
    Should Be True    ${verdict}    Fail to reset part authentication status: ${comment}
    DO REBOOT IVC
    CHECK IVC BOOT COMPLETED

DO CRASH IVC
    [Documentation]    == High Level Description: ==
    ...    Generates a crash on IVC
    ${verdict}    ${comment} =    GENERATE IVC CRASH
    Should Be True    ${verdict}    Failed GENERATE IVC CRASH: ${comment}

CHECKSET IVC CIPHER KEY STORAGE STATUS
    [Arguments]    ${status}
    [Documentation]    == High Level Description: ==
    ...     Check on the IVC Platform cipher key storage status
    ...    == Parameters: ==
    ...    _status_: request_pending, stored
    ${state} =    Set Variable If    "${status}" == "request_pending"    0    "${status}" == "requested"    1
    ...    "${status}" == "stored"    2
    ...    ELSE    Fail    Invalid data cipher key storage status:${status}
    ${verdict}    ${output} =    CIPHER KEY STORAGE STATUS    ${state}
    Should Be True    ${verdict}    Failed to CHECKSET IVC CIPHER KEY STORAGE STATUS: ${output}

DO RESET UCD QUEUE
    [Documentation]   Empty the UCD message queue
    ${verdict}    ${output} =    RESET UCD QUEUE
    Should Be True    ${verdict}    Failed RESET UCD QUEUE: ${output}
    [Return]    ${output}

CHECKSET EPMC ON IVC
    [Arguments]    ${state}
    [Documentation]    Check the state of the EPMC feature if it is activated (01) or not (00)
    ...    Activate the EPMC feature if it is not activated.
    ${verdict_check}    ${comment_check} =    CHECK EPMC STATE ON IVC
    ${verdict_set} =    Run Keyword If     ${verdict_check}==${FALSE}    SET EPMC STATE ON IVC
    ...    ELSE    Return From Keyword
    Run Keyword If     ${verdict_check}==${FALSE}    Should Be True    ${verdict_set}    Failed to set EPMC STATE ON IVC due to error
    ${verdict_check}    ${comment_check} =    Run Keyword If     ${verdict_check}==${FALSE}    CHECK EPMC STATE ON IVC
    Should Be True    ${verdict_check}    Failed to CHECKSET EPMC STATE ON IVC due to error:${comment_check}

CHECK FLAG STATE FOR IVC
    [Arguments]    ${state}    ${name_of_service_from_commet}
    [Documentation]    == High Level Description: ==
    ...    Check on the IVC platform ${name_of_service_from_commet} with value ${state}
    ...    == Parameters: ==
    ...    - _name_of_service_from_commet_: Name of the parameter, could be: RemCh_ActivationStatus
    ...    - _state_: represents the SA action performed (example: activate, deactivate)
    ...    == Expected Results: ==
    ...    Passed if the flags number is successfully retrieved
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Check Flag    IVC CMD
    ${status} =    Set Variable If    "${state}" == "activate"    1    "${state}" == "deactivate"    0
    ...    ELSE    Log To Console    Invalid data flag storage status:${status}
    ${verdict}    ${comment} =    rfw_services.wicket.SystemLib.CHECK ACTIVATION STATE    ${status}    ${name_of_service_from_commet}
    Should be true    ${verdict}    Failed CHECK ACTIVATION STATE: ${comment}
    [Return]    ${verdict}    ${comment}

UCD UPDATE
    [Arguments]    ${cfm_dir}    ${ucd_config}    ${local_db_path}    ${db_path}=/var/persistent/data/gac/cfm.db
    [Documentation]    == High Level Description: ==
    ...    Backup the cfm.db from IVC2 then modify the database with the provided input files (cfm_dir)
    ...    and perform a hash recalculate in the end
    ...    == Parameters: ==
    ...    - _cfm_dir_: local directory containing new ucd config
    ...    - _ucd_config_: remote directory containing new ucd config
    ...    - _local_db_path_: local cfm database path
    ...    - _db_path_: remote cfm database path
    ...    == Expected Results: ==
    ...    Passed if ucd update is successful
    ${verdict}=    SYSTEM GET FILE FROM DEVICE    ${db_path}    ${local_db_path}
    Run Keyword If    "${verdict}"=="True"    Set Test Variable    ${backup_status}    True
    ...    ELSE     Fail    Failed to download backup ucd config
    ${verdict}=    SYSTEM SEND FILE TO DEVICE    ${cfm_dir}    /mnt/mmc/UCD/
    Should Be True    ${verdict}    Failed to upload new ucd config
    ${verdict}    ${comment} =    INSERT NEW UCD CONFIG    /mnt/mmc/UCD/cfm_${ucd_config}
    Should Be True    ${verdict}    Failed to insert new ucd config: ${comment}
    ${verdict}    ${comment} =    RECALCULATE CFM HASH
    Should Be True    ${verdict}    Failed to recalculate cfm hash: ${comment}

CFM RESTORE
    [Arguments]    ${local_db_path}    ${db_path}=/var/persistent/data/gac/cfm.db
    [Documentation]    == High Level Description: ==
    ...    Replace the actual cfm.db from IVC2 with the backup version.
    ...    == Parameters: ==
    ...    - _local_db_path_: local cfm database path
    ...    - _db_path_: remote cfm database path
    ...    == Expected Results: ==
    ...    Passed if ucd restore is successful
    ${verdict}=    SYSTEM SEND FILE TO DEVICE    ${local_db_path}    ${db_path}
    Should Be True    ${verdict}    Failed to upload backup ucd config. Manual upload is needed!
    ${verdict}    ${comment} =    RECALCULATE CFM HASH
    Should Be True    ${verdict}    Failed to recalculate cfm hash: ${comment}

CHECKSET SLEEP CONFIGURATION
    [Arguments]    ${state}
    [Documentation]    Change sleep configuration of the ivc
    ...    Stdrx : configure ivc sleep configuration for stdrx state
    ...    Stoffdata : configure ivc sleep configuration for stoffdata state
    ...    Stoff : configure ivc sleep configuration for stoff state
    IF   "${state}" == "Stdrx"
        CHECKSET IVC STDRX CONFIGURATION
    ELSE IF    "${state}" == "Stoff"
        CHECKSET IVC STOFF CONFIGURATION
    ELSE IF    "${state}" == "Stoffdata"
        CHECKSET IVC STOFFDATA CONFIGURATION
    ELSE
        Fail    Invalid data for IVC state:${state}
    END


CHECK AND STORE THE TECHNICAL DETAILS FROM COMET
    [Arguments]    ${technical_product_id}
    [Documentation]    == High Level Description: ==
    ...    Retrieve the technical product ids from commet
    ...    == Parameters: ==
    ...    - _state_: technical_product_id - the product of service.
    ...    == Expected Results: ==
    ...    Passed if the value is successfully retrieved
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | |
    ${verdict}    ${technical_data} =    Get Technical Data    ${technical_product_id}
    SHOULD BE TRUE    ${verdict}    FAILED TO GET TECHNICAL DATA FOR PRODUCT ID: ${technical_product_id}
    [Return]    ${technical_data}

RETRIEVE TECHNICAL DETAILS FROM COMET
    [Documentation]    == High Level Description: ==
    ...    Retrieve the technical product ids from commet
    ...    == Parameters: ==
    ...    == Expected Results: ==
    ...    Passed if the value is successfully retrieved
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | |
    ${verdict}    ${comment} =    Run Keyword and Ignore Error    File Should Exist    ${filename}
    ${file_size} =    Run Keyword If    "${verdict}"=="PASS"    GET FILE SIZE    ${filename}    ELSE    Set Variable    None
    ${file_modified_time} =    Run Keyword If    "${verdict}"=="PASS"        GET MODIFIED TIME    ${filename}    ELSE    Set Variable    None
    IF    ${file_size} != None
        ${current_time} =    DateTime.GET CURRENT DATE
        ${time_difference} =    DateTime.SUBTRACT DATE FROM DATE   ${current_time}    ${file_modified_time}    timedelta
        IF    ${time_difference.days} > 3
            ${verdict}    ${comment} =    RETRIEVE TECHNICAL DATA FROM COMET    ${technical_product_ids}
            Log to console    ${verdict}: ${comment}
            ${verdict}    ${comment} =    EXPORT Technical Data    ${filename}
            Log to console    ${verdict}: ${comment}
        ELSE IF    ${file_size} > 22
            ${verdict}    ${comment} =    Load Technical Data    ${filename}
            Log to console    ${verdict}: ${comment}
        ELSE
        ${verdict}    ${comment} =    RETRIEVE TECHNICAL DATA FROM COMET    ${technical_product_ids}
        Log to console    ${verdict}: ${comment}
        ${verdict}    ${comment} =    EXPORT Technical Data    ${filename}
        Log to console    ${verdict}: ${comment}
        END
    ELSE
        ${verdict}    ${comment} =    RETRIEVE TECHNICAL DATA FROM COMET    ${technical_product_ids}
        Log to console    ${verdict}: ${comment}
        ${verdict}    ${comment} =    EXPORT Technical Data    ${filename}
        Log to console    ${verdict}: ${comment}
    END

CHECK FLAG STATE FOR DEVICES
    [Arguments]    ${name_of_service_from_commet}    ${device}    ${state}
    [Documentation]    == High Level Description: ==
    ...    Check the value from commet is the same on devices.
    ...    == Parameters: ==
    ...    - _state_: represents the SA action performed (example: activate, deactivate)
    ...    - _name_of_service_from_commet_: represents the name of service (example:RemCh_ActivationStatus)
    ...    - _device_: represents the device (example: IVC, IVI)
    ...    == Expected Results: ==
    ...    Passed if the flags number is successfully retrieved
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    ${device} =    Convert To Upper Case    ${device}
    ${verdict} =     Run Keyword If    "${device}" == "IVC"    CHECK FLAG STATE FOR IVC    ${state}    ${name_of_service_from_commet}
    ...    ELSE IF    "${device}" == "IVI"    CHECK FLAG STATE FOR IVI    ${state}    ${name_of_service_from_commet}
    ...    ELSE    FAIL    Profile "${device}" doesn't exist
    [Return]    ${verdict}

CHECK FLAG STATE FOR
    [Arguments]    ${retrieve}    ${state}
    [Documentation]    == High Level Description: ==
    ...    Check the number of flags for activated services at device side
    ...    == Parameters: ==
    ...    - _state_: represents the SA action performed (example: activate, deactivate)
    ...    == Expected Results: ==
    ...    Passed if the flags number is successfully retrieved
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | |
    ${size} =    Get Length    ${retrieve['components']}
    FOR    ${index}    IN RANGE    ${size}
        ${device} =    Set Variable    ${retrieve['components'][${index}]['device']}
        ${name_of_service_from_commet} =    Set Variable    ${retrieve['components'][${index}]['settings'][0]['method']}
        ${ucd_obj}=    Run Keyword And Return Status    Should Contain    ${name_of_service_from_commet}    UCD    ignore_case=True
        Continue For Loop If  ${ucd_obj}==True
        ${verdict} =     CHECK FLAG STATE FOR DEVICES     ${name_of_service_from_commet}    ${device}    ${state}
        Should be true    ${verdict}
    END

DO CONFIGURE RADMOON VLAN
    [Documentation]    == High Level Description: ==
    ...    Check the VLAN setup
    ...    == Parameters: ==
    ...    == Expected Results: ==
    ...    Passed if set VLAN interface
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Manual    Remote Services Common    IVC CMD
    Log    Keyword not mandatory since action is done manually for now

CHECK IVC DATE
    [Arguments]    ${v_date}
    [Documentation]    == High Level Description: ==
    ...    Fetches current IVC date and compares it with user input(day, month and year)
    ...    == Parameters: ==
    ...    - _v_date_:  date set on IVC to be compared
    ...    == Expected Results: ==
    ...    Pass if executed
    [Tags]    Automated    Compare IVC Date    IVC CMD
    ${output} =    GET IVC TIME    tstart
    Should Contain    ${output}    ${v_date}    FAILED... The date that was set is incorrect

CHECK DATE AND TIME ON IVC
    [Documentation]    == High Level Description: ==
    ...    Check the date and time on IVC is updated
    ...    == Parameters: ==
    ...    == Expected Results: ==
    ...    Passed if date and time on IVC is update
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Check IVC Date    IVC CMD
    GET IVC TIME    tstart
    RECORD VNEXT DATE & TIME    t0
    COMPARE IVC & VNEXT TIME

CHECK IVC PROBE UPLOAD PERMIT
    [Arguments]    ${state}
    [Documentation]    To check if Probe Upload Permit is set to the expected state
    ${verdict}    ${output} =    GET PROBE UPLOAD PERMIT
    Run Keyword If    "${state}"=="on"    Should Be Equal As Integers    ${output}    1    IVC Probe Upload Permit is not in expected state:${state}
    ...    ELSE IF    "${state}"=="off"    Should Be Equal As Integers    ${output}    0    IVC Probe Upload Permit is not in expected state:${state}
    ...    ELSE    Log To Console    Invalid Probe Upload Permit state:${state}

CHECK IVC DRIVER INFO UPLOAD PERMIT
    [Arguments]    ${state}
    [Documentation]    To check if Driver Info Upload Permit is set to the expected state
    ${verdict}    ${output} =    GET DRIVER INFO UPLOAD PERMIT
    Run Keyword If    "${state}"=="on"    Should Be Equal As Integers    ${output}    1    IVC Driver Info Upload Permit is not in expected state:${state}
    ...    ELSE IF    "${state}"=="off"    Should Be Equal As Integers    ${output}    0    IVC Driver Info Upload Permit is not in expected state:${state}
    ...    ELSE    Log To Console    Invalid Driver Info Upload Permit state:${state}

CHECK IVC PROBE INFO DELETE
    [Arguments]    ${state}
    [Documentation]    To check if Probe Info Delete is set to the expected state
    ${verdict}    ${output} =    GET PROBE INFO DELETE
    Run Keyword If    "${state}"=="on"    Should Be Equal As Integers    ${output}    1    IVC Probe Info Delete is not in expected state:${state}
    ...    ELSE IF    "${state}"=="off"    Should Be Equal As Integers    ${output}    0    IVC Probe Info Delete is not in expected state:${state}
    ...    ELSE    Log To Console    Invalid Probe Info Delete state:${state}

SET RESET SERVICE FLAG ON IVC
    [Arguments]    ${service}    ${action}
    [Documentation]    == High Level Description: ==
    ...    Set or reset the flag on IVC for specific service
    ...    == Parameters: ==
    ...    - _service_: The service for which you want to set or reset the flag
    ...    - _action_: The action for the service flag, could be SET/RESET
    ...    == Expected Results: ==
    ...    Passed if service flag is set properly
    ${value} =    Set Variable If    "${action.lower()}" == "set"    1    0
    ${flag} =    Set Variable If    "${service.lower()}" == "rhl"    RemoteHornAndLightActivationStatus
    Run Keyword If    "${flag}" != "${None}"
    ...    SET OF STATE MANAGER    configurationproperty    activationState    ${value}    propertyName    ${flag}
    ...    ELSE    Fail    Service is not available
    DO REBOOT IVC

DO IVC PART AUTHENTICATION
    [Documentation]    == High Level Description: ==
    ...    Do the part authentication status on IVC
    ...    == Parameters: ==
    ...    - none
    ...    == Expected Results: ==
    ...    pass when output contains: CertificateInstalled
    ...    fails otherwise
    DO RESET IVC PART AUTHENTICATION STATUS
    DO REBOOT IVC
    CHECK IVC CONNECTIVITY ON
    CHECK IVC TO VNEXT MESSAGE VA    certificateInstalled
    CHECK VNEXT VIN CERTIFICATE STATUS    IVC    Burnt
    CHECK IVC PART AUTHENTICATION STATUS

GET IVC MY FEATURE ID
    [Documentation]    Used to extract ivc sw version and based on that check ivc type(myf1, myf2)
    ${verdict}    ${ivc_build_id} =    GET IVC BUILD ID
    Should Be True    ${verdict}
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    IVC build ID : ${ivc_build_id}
    @{build_id_list} =    Split String    ${ivc_build_id}    .
    ${build_series} =    Get From List    ${build_id_list}    0
    ${ivc_feature_id} =    Set Variable If
    ...  ${build_series} < ${400}  MyF1
    ...  ${build_series} > ${400} and ${build_series} < ${600}  MyF2
    ...  ${build_series} > ${600}  MyF3
    [return]    ${ivc_feature_id}

SET EPMC CONFIGURATION
    [Documentation]    == High Level Description: ==
    ...    Check ivc current consumption set configuration
    ...    == Parameters: ==
    ...    == Expected Results: ==
    ...    Passed if current consumption is correct
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Remote Services Common    IVC CMD
    ${verdict}    ${output} =    SET OF STATE MANAGER    configurationparameter    value    FF    parameterName    PowServ_PwMQTT
    Should Be True    ${verdict}    Failed SET OF STATE MANAGER: ${output}
    Should Not Contain    ${output}    ${error_string}
    ${verdict}    ${output} =    SET OF STATE MANAGER    configurationparameter    value    0F    parameterName    PowServ_PwDRX
    Should Be True    ${verdict}    Failed SET OF STATE MANAGER: ${output}
    Should Not Contain    ${output}    ${error_string}
    ${verdict}    ${output} =    SET OF STATE MANAGER    configurationparameter    value    1E    parameterName    IVCBS_StOffDataMaxT2
    Should Be True    ${verdict}    Failed SET OF STATE MANAGER: ${output}
    Should Not Contain    ${output}    ${error_string}
    ${verdict}    ${output} =    SET OF STATE MANAGER    configurationparameter    value    0A    parameterName    PowServ_DrxMinTime
    Should Be True    ${verdict}    Failed SET OF STATE MANAGER: ${output}
    Should Not Contain    ${output}    ${error_string}
    ${verdict}    ${output} =    SET OF STATE MANAGER    configurationparameter    value    01    parameterName    PowServ_ThresholdLimit
    Should Be True    ${verdict}    Failed SET OF STATE MANAGER: ${output}
    Should Not Contain    ${output}    ${error_string}
    ${verdict}    ${output} =    SET OF STATE MANAGER    configurationparameter    value    01    parameterName    PowServ_ThresholdMQTT
    Should Be True    ${verdict}    Failed SET OF STATE MANAGER: ${output}
    Should Not Contain    ${output}    ${error_string}
    ${verdict}    ${output} =    SET OF STATE MANAGER    configurationparameter    value    01    parameterName    PowServ_ThresholdWarningUser
    Should Be True    ${verdict}    Failed SET OF STATE MANAGER: ${output}
    Should Not Contain    ${output}    ${error_string}
    ${verdict}    ${output} =    SET OF STATE MANAGER    configurationparameter    value    78    parameterName    IVCBS_DRX_NotificationTime
    Should Be True    ${verdict}    Failed SET OF STATE MANAGER: ${output}
    Should Not Contain    ${output}    ${error_string}
    ${verdict}    ${output} =    SET OF STATE MANAGER    configurationparameter    value    02    parameterName    PowServ_InitEPMC_Budget
    Should Be True    ${verdict}    Failed SET OF STATE MANAGER: ${output}
    Should Not Contain    ${output}    ${error_string}
    DO REBOOT IVC
    CHECK IVC BOOT COMPLETED

CHECK IVC CURRENT CONSUMPTION DURING MQTTAO STATE
    [Documentation]    == High Level Description: ==
    ...    Check ivc current consumption during mqttao state
    ...    == Parameters: ==
    ...    == Expected Results: ==
    ...    Passed if current consumption is correct
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Manual    Remote Services Common    IVC CMD
    Log    Keyword not mandatory since action is done manually for now

CHECK IVC CURRENT CONSUMPTION DURING STOFF STATE
    [Documentation]    == High Level Description: ==
    ...    Check ivc current consumption during mqttao state
    ...    == Parameters: ==
    ...    == Expected Results: ==
    ...    Passed if current consumption is correct
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Manual    Remote Services Common    IVC CMD
    Log    Keyword not mandatory since action is done manually for now

CHECK IVC TRANSITION TO STATE
    [Documentation]    == High Level Description: ==
    ...    To check if IVC is the expected one StOff_EPMCTrigger
    ...    == Parameters: ==
    ...    == Expected Results: ==
    ...    Passed if service flag is set as expected value
    START DLT MONITOR
    Sleep    180
    KEEP IVC ON
    Sleep    120
    START DLT CONVERSION    StOff

RESTORE CONFIGURATION PARAMETERS
    [Documentation]    == High Level Description: ==
    ...    Check ivc current consumption restore configuration
    ...    == Parameters: ==
    ...    == Expected Results: ==
    ...    Passed if current consumption is correct
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Remote Services Common    IVC CMD
    ${verdict}    ${output} =    SET OF STATE MANAGER    configurationparameter    value    1B    parameterName    PowServ_InitEPMC_Budget
    Should Be True    ${verdict}    Failed SET OF STATE MANAGER: ${output}
    Should Not Contain    ${output}    ${error_string}
    ${verdict}    ${output} =    SET OF STATE MANAGER    configurationparameter    value    0C    parameterName    PowServ_PwRemote
    Should Be True    ${verdict}    Failed SET OF STATE MANAGER: ${output}
    Should Not Contain    ${output}    ${error_string}
    ${verdict}    ${output} =    SET OF STATE MANAGER    configurationparameter    value    09    parameterName    PowServ_PwMQTT
    Should Be True    ${verdict}    Failed SET OF STATE MANAGER: ${output}
    Should Not Contain    ${output}    ${error_string}
    ${verdict}    ${output} =    SET OF STATE MANAGER    configurationparameter    value    01    parameterName    PowServ_ThresholdMQTT
    Should Be True    ${verdict}    Failed SET OF STATE MANAGER: ${output}
    Should Not Contain    ${output}    ${error_string}
    ${verdict}    ${output} =    SET OF STATE MANAGER    configurationparameter    value    01    parameterName    PowServ_ThresholdLimit
    Should Be True    ${verdict}    Failed SET OF STATE MANAGER: ${output}
    Should Not Contain    ${output}    ${error_string}
    ${verdict}    ${output} =    SET OF STATE MANAGER    configurationparameter    value    08    parameterName    PowServ_PwDRX
    Should Be True    ${verdict}    Failed SET OF STATE MANAGER: ${output}
    Should Not Contain    ${output}    ${error_string}
    ${verdict}    ${output} =    SET OF STATE MANAGER    configurationparameter    value    08    parameterName    PowServ_PwDRX
    Should Be True    ${verdict}    Failed SET OF STATE MANAGER: ${output}
    Should Not Contain    ${output}    ${error_string}
    ${verdict}    ${output} =    SET OF STATE MANAGER    configurationparameter    value    06    parameterName    PowServ_ThresholdWarningUser
    Should Be True    ${verdict}    Failed SET OF STATE MANAGER: ${output}
    Should Not Contain    ${output}    ${error_string}
    ${verdict}    ${output} =    SET OF STATE MANAGER    configurationparameter    value    01    parameterName    IVCBS_StOffDataMaxT2
    Should Be True    ${verdict}    Failed SET OF STATE MANAGER: ${output}
    Should Not Contain    ${output}    ${error_string}
    DO REBOOT IVC
    CHECK IVC BOOT COMPLETED

SET ENERGY BUDGET VALUE FOR
    [Arguments]    ${value}    ${name_service}
    [Documentation]    == High Level Description: ==
    ...    Check ivc current consumption configuration
    ...    == Parameters: ==
    ...    == Expected Results: ==
    ...    Passed if current consumption is correct
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Remote Services Common    IVC CMD
    ${verdict}    ${output} =    SET OF STATE MANAGER    configurationparameter    value    ${value}    parameterName    ${name_service}
    Should Be True    ${verdict}    Failed SET OF STATE MANAGER: ${output}
    Should Not Contain    ${output}    ${error_string}

CHECK IVC CURRENT CONSUMPTION DURING STDRX STATE
    [Documentation]    == High Level Description: ==
    ...    Check ivc current consumption during stdrx state
    ...    == Parameters: ==
    ...    == Expected Results: ==
    ...    Passed if current consumption is correct
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Manual    Remote Services Common    IVC CMD
    Log    Keyword not mandatory since action is done manually for now

RILSHELL IVC COMMAND CHECK SIGNAL STRENGTH
    [Documentation]    == High Level Description: ==
    ...    Check ivc Signal Strength
    ...    == Parameters: ==
    ...    == Expected Results: ==
    ...    Passed if signal strength is received
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Remote Services Common    IVC CMD
    ${verdict}    ${list_value} =    CHECK SIGNAL STRENGTH
    Should Be True    ${verdict}
    Set Test Variable    ${SignalStrength}     ${list_value}

CHECK IVC FILE
    [Arguments]    ${file}
    [Documentation]    == High Level Description: ==
    ...     Checks if file is present on IVC
    ...     == Paramaters: ==
    ...     :${file} path and filename to search
    ...     == Expected Results: ==
    ...     == Passed if the given file is present on IVC
    ...    ${file} path and file name to search
    ${verdict} =    rfw_services.wicket.SystemLib.Is File On Target    ${file}
    should be true    ${verdict}    File is not present.

RETRY FOR CHECK ACTIVATION FLAG FOR
    [Arguments]    ${action}
    [Documentation]    == High Level Description: ==
    ...    Check the number of flags for activated services at IVC side
    ...    == Parameters: ==
    ...    - _action_: represents the SA action performed (example: activate, deactivate)
    ...    == Expected Results: ==
    ...    Passed if the flags number is successfully retrieved
    Wait Until Keyword Succeeds    300s    30s    CHECK ACTIVATION FLAG FOR    ${action}

DO EMULATE MALICIOUS ACTIVITY
    [Documentation]    == High Level Description: ==
    ...    Do emulate malicious activity
    ...    == Parameters: ==
    ...    == Expected Results: ==
    ...    Passed if emulate malicios activity is done
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Remote Services Common    IVC CMD
    CHECKSET FILE PRESENT ON IVC    /ota/descmoData.xml    descmoData.xml    matrix/artifacts/automation/
    FOR    ${item}    IN    @{ota_files}
        DELETE FILES ON IVC    /ota    ${item}
    END
    ${hash_env} =    Set Variable If   "${env}" == "stg-emea"    BA8685E3B4E717F867A51A1E2FDD5014B14A4106D1CD76891EED0F4FB5960F2F
    ...    "${env}" == "sit-emea"    AE289EB42F2EB3705E6D4F0C0FF62C71D5351808DD36AB24A2A60723801E2563
    Run Keyword if    "${hash_env}" == "None"    Fail    Env variable should not be empty, please update the test variables
    INJECT DLT MESSAGE     FOTA    MAIN    5520    settpkg;descmoData.xml;${hash_env};/ota/descmoData.xml
    INJECT DLT MESSAGE     FOTA    MAIN    5200   empty
    INJECT DLT MESSAGE     FOTA    MAIN    5214   settpkg;descmoData.xml

SET OBFCM IVC STATE
    [Arguments]    ${parameter}    ${state}
    [Documentation]    == High Level Description: ==
    ...    Set OBFCM state
    ...    == Parameters: ==
    ...    - _state_: Deactivate/Activate onboard the OBFCM feature
    ...    == Expected Results: ==
    ...    Passed if state is set
    [Tags]    Automated   IVC CMD
    ${activation_state} =    Set Variable If    "${state}" == "on"    1    0
    ${verdict}    ${output} =    SET OF STATE MANAGER    configurationproperty    activationstate    ${activation_state}    parameterName    ${parameter}
    Should Be True    ${verdict}    Failed SET OFCM IVC STATE: ${output}
    Should Not Contain    ${output}    ${error_string}
    DO REBOOT IVC

DO REMOVE PART AUTHENTICATION STATUS
    [Arguments]    ${ivc_type}="userdebug"    ${TC_folder}=${EMPTY}
    [Documentation]    == High Level Description: ==
    ...    Remove the part authentication status on IVC in order to trigger a new part authentication.
    ...    == Parameters: ==
    ...    - none
    ...    == Expected Results: ==
    ...    pass when the remove was done
    ...    fails otherwise
    [Tags]    Automated    Remote Services Common    Connected Services Domain
    Run Keyword If    "${ivc_type}" == "userdebug"    DELETE PART AUTHENTICATION
    ...     ELSE IF    "${ivc_type}" == "user"    DELETE FILES ON IVC     /var/persistent/data/gac/ssm     51.crypt-user

SET IVC VSS SIGNAL
    [Arguments]    ${signal_name}    ${value}
    [Documentation]    Set on VSS component what is the value of the signal_name
    Log To Console    SET IVC VSS SIGNAL:- Set on VSS component value:${value} of the signal_name:${signal_name}
    ${verdict}    ${output} =    SET VSS SIGNAL    ${signal_name}    ${value}
    Should Contain    ${output}    ${value}
    Should Be True    ${verdict}

SEND VEHICLE ECO SCORE DATA
    [Documentation]    == High Level Description: ==
    ...    Set signals on vss
    SET IVC VSS SIGNAL    ecosts    120
    SET IVC VSS SIGNAL    ecoec    130
    SET IVC VSS SIGNAL    ecocs    140
    SET IVC VSS SIGNAL    ecosls    145

SEND VEHICLE HV BATTERY DATA BUMI
    [Documentation]    == High Level Description: ==
    ...    Set signals on vss for bumi TC
    SET IVC VSS SIGNAL    bin    1234567890123456789012345
    SET IVC VSS SIGNAL    bsgkp    20
    SET IVC VSS SIGNAL    bsmil    50

SEND VEHICLE HV BATTERY DATA
    [Documentation]    == High Level Description: ==
    ...    Set signals on vss
    SET IVC VSS SIGNAL    bhpar    12345ABCD
    SET IVC VSS SIGNAL    bhdri    12345ABCD
    SET IVC VSS SIGNAL    bsgkv    1.2
    SET IVC VSS SIGNAL    bsgkp    1.3
    SET IVC VSS SIGNAL    hvbatp    2
    SET IVC VSS SIGNAL    bsmil    3
    SET IVC VSS SIGNAL    bschco    4
    SET IVC VSS SIGNAL    bschpa    5
    SET IVC VSS SIGNAL    hvbap    1.5
    SET IVC VSS SIGNAL    hvbgp    1.7
    SET IVC VSS SIGNAL    bin    1234567890123456789012345

CHECKSET INTERNET ACCESS IN IVC
    [Arguments]    ${action}    ${timeout}
    [Documentation]    == High Level Description: ==
    ...    Checks the internet activation in IVC. When the activation status
    ...    is not as expected, activates or deactivates it.
    ...     == Parameters: ==
    ...    - _action_: represents the SA action performed (example: activation, deactivation)
    ...    - _timeout_:timeout provided for the device connection
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    Remote Services Common    VNEXT APIM
    ${value} =    Set Variable if    "${action}".lower() == "activation"    1    0
    ${verdict}    ${comment} =    CHECK ACTIVATION FLAG    ${action}    InternetAccessActivationStatus    ${timeout}
    IF   "${verdict}" == "False" and "${comment}" == "Service flag does not match expected value."
        ${verdict}    ${comment} =    SET OF STATE MANAGER    configurationproperty    activationState    ${value}    propertyName    InternetAccessActivationStatus
        Should be True    ${verdict}    Failed to set the Status:${Comment}
        ${verdict}    ${comment} =    CHECK ACTIVATION FLAG    ${action}    InternetAccessActivationStatus    ${timeout}
        Should be True    ${verdict}    ${Comment}
    ELSE IF    "${verdict}" == "False" and "${comment}" != "Service flag does not match expected values."
        FAIL    ${comment}
    END
    ${verdict}    ${comment} =    CHECK STATUS FLAG    ${value}    IVCBS_InternetAccessActivationStatus
    IF   "${verdict}" == "False" and "Failed, the status flag on IVC is not valid" in "${comment}"
        ${verdict}    ${comment} =   SET STATUS FLAG    ${value}    IVCBS_InternetAccessActivationStatus    ${timeout}
        Should be True    ${verdict}    Failed to set the Status:${Comment}
        ${verdict}    ${comment} =   CHECK STATUS FLAG    ${value}    IVCBS_InternetAccessActivationStatus
        Should be True    ${verdict}    ${Comment}
    ELSE IF    "${verdict}" == "False" and "Failed, the status flag on IVC is not valid" not in "${comment}"
        FAIL    ${comment}
    END

CHECKSET CUSTOMER PRESENCE CONFIG
    [Arguments]    ${status_customer_presence}=false
    [Documentation]    Ensures that the IVC configuration is set properly to allow Customer Presence Feedback state
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    Remote Services Common    IVC CMD
    ${value} =    Wait Until Keyword Succeeds    2m    10s    READ DIAG PARAMETER VALUE FROM IVC     DIAG_Conf_Customer_Presence_need
    Set Test Variable    ${initial_customer_presence}    ${value}
    Run Keyword If    "${status_customer_presence}".lower() == "true"    WRITE IVC DIAG PARAMETER VALUE    DIAG_Conf_Customer_Presence_need     FFFFFFFF
    ...    ELSE    WRITE IVC DIAG PARAMETER VALUE    DIAG_Conf_Customer_Presence_need     00000000

READ DIAG PARAMETER VALUE FROM IVC
    [Documentation]    Retrieves the initial values for the customer presence need parameter
    ...    == Expected Results: ==
    ...    output: it returns the initial value set on the IVC platform
    [Tags]    Automated    Remote Services Common    IVC CMD
    [Arguments]    ${diag_parameter}
    ${status}    ${initial_value} =    CHECK_DB_DID     ${diag_parameter}
    Should Be True    ${status}    Failed to check Customer Presence parameter due to: ${initial_value}
    Should Not Contain    ${initial_value}    Error    Failed to read the value for customer presence config
    Set Test Variable     ${initial_diag_value}    ${initial_value}
    [Return]     ${initial_value}

WRITE IVC DIAG PARAMETER VALUE
    [Documentation]    Writes new values for the customer presence need parameter
    ...    == Parameters: ==
    ...    _customer_presence_value_: represents value for customer presence need
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    Remote Services Common    IVC CMD
    [Arguments]    ${diag_parameter}    ${diag_value}
    ${output}    ${error}=    UPDATE_DB_DID    ${diag_parameter}    ${diag_value}
    Should Be True    ${output}    Failed to set Customer Presence parameter due to: ${error}
    Run Keyword And Ignore Error    CLOSE SSH SESSION
    DO REBOOT IVC
    Sleep    60
    CHECK IVC BOOT COMPLETED

CHECKSET REMOTE INHIBITED ONBOARD
    [Arguments]    ${status_inhibition_onboard}=false
    [Documentation]    Ensures that the IVC configuration is set properly to allow remote inhibition onboard
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    Remote Services Common    IVC CMD
    ${value} =    Wait Until Keyword Succeeds    2m    10s    READ DIAG PARAMETER VALUE FROM IVC     DIAG_Conf_Remote_fn_inhibited_onboard
    Set Test Variable    ${initial_remote_inhibition}    ${value}
    Run Keyword If    "${status_inhibition_onboard}".lower() == "true"    WRITE IVC DIAG PARAMETER VALUE    DIAG_Conf_Remote_fn_inhibited_onboard     FFFFFFFF
    ...    ELSE    WRITE IVC DIAG PARAMETER VALUE    DIAG_Conf_Remote_fn_inhibited_onboard     00000000

CHECK IVC DIAG PARAMETER VALUE FOR
    [Arguments]    ${service}    ${param_value}
    [Documentation]    == High Level Description: ==
    ...    To check if IVC diag parameter value is the expected one
    ...    == Parameters: ==
    ...    - _service_: The service for which you want to check flag value
    ...    - _param_value_: The value to be expected to be set on the parameter
    ...    == Expected Results: ==
    ...    Passed if service flag is set as expected value
    ${value} =     READ DIAG PARAMETER VALUE FROM IVC     ${service}
    Should be Equal    ${value}    ${param_value}   Diag parameter value is different from Expected value    strip_spaces=True

CHECK INTERNET ACCESS IN IVC
    [Arguments]    ${action}    ${timeout}
    [Documentation]    == High Level Description: ==
    ...    Checks the internet activation in IVC.
    ...     == Parameters: ==
    ...    - _action_: represents the SA action performed (example: activation, deactivation)
    ...    - _timeout_:timeout provided for the device connection
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    Remote Services Common    VNEXT APIM
    ${value} =    Set Variable if    "${action}".lower() == "activation"    1    0
    ${verdict}    ${comment} =    CHECK ACTIVATION FLAG    ${action}    InternetAccessActivationStatus    ${timeout}
    Should be True    ${verdict}    ${Comment}
    ${verdict}    ${comment} =    CHECK STATUS FLAG    ${value}    IVCBS_InternetAccessActivationStatus
    Should be True    ${verdict}    ${Comment}

CREATE FILE ON IVC
    [Arguments]    ${file}
    [Documentation]    Create file on ivc
    ...    ${file} path and file name to create
    ${verdict}    ${comment} =    rfw_services.wicket.SystemLib.Create File    ${file}
    Should Be True    ${verdict}    ${comment}

DELETE FILES ON IVC
    [Arguments]    ${path}    ${file}
    [Documentation]    Delete file/files on ivc
    ...    ${file} file to be deleted
    ...    ${path} path of the file
    @{files} =    Create List    ${path}/${file}
    ${verdict}    ${comment} =    rfw_services.wicket.SystemLib.Delete Files    ${files}
    Should Be True    ${verdict}    ${comment}


CHECKSET FACTORY MODE PRESENT ON IVC
    [Arguments]    ${file}
    [Documentation]    Check file presence on ivc delete it and create again blank
    ...    ${file} path and file name to search
    ${verdict}    ${comment} =    rfw_services.wicket.SystemLib.Is File On Target    ${file}
    IF    "${verdict}"=="True"
        Run Process    sshpass -f %{WICKET_PASSWORD=None} ssh root@%{WICKET_HOSTNAME=172.17.0.1} & chmod o+w ${file}    shell=True
        Run keyword if    "factory_mode_on" in "${file}"    DELETE FILES ON IVC    /data/etc    factory_mode_on
    END
    CREATE FILE ON IVC    ${file}
    CHECK FILE PRESENT ON IVC    ${file}
    Run Process    sshpass -f %{WICKET_PASSWORD=None} ssh root@%{WICKET_HOSTNAME=172.17.0.1} & chmod o+x ${file}    shell=True

CHECKSET FILE PRESENT ON IVC
    [Arguments]    ${file}    ${name_of_file}    ${download_artifact_path}
    [Documentation]    Check file presence on ivc if not download it
    ...    ${file} path and file name to search
    ...    ${name_of_file} name of the file to be downloaded
    ...    ${download_artifact_path} path of the file from artifactory

    ${verdict}    ${comment} =    rfw_services.wicket.SystemLib.Is File On Target    ${file}
    IF    "${verdict}"=="False"
        DOWNLOAD ARTIFACTORY FILE    ${download_artifact_path}${name_of_file}    ${FALSE}
        SYSTEM SEND FILE TO DEVICE    ${name_of_file}    ${file}
    END
    CHECK FILE PRESENT ON IVC    ${file}

DO RESET IVC UNAVAILABLE STATE
    [Arguments]    ${timeout}=180
    [Documentation]    Send reboot command to IVC if Fota state it's stuck in 1F
    ${ivc_fota_state}=    Run Keyword And Return Status      CHECK VEHICLE SIGNAL    IVC_FOTA_Status_v2    0x1F    timeout=${timeout}
    IF    '${ivc_fota_state}'=='True'
        DO REBOOT IVC
        CHECK IVC BOOT COMPLETED
    END
