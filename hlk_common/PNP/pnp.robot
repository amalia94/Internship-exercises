#
# Copyright (c) 2022 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Documentation     Pnp test utility
Resource          ${CURDIR}/../Tools/artifactory.robot
Library           rfw_services.ivi.PnpLib    device=${ivi_adb_id}
Library           rfw_services.canakin.CanakinLib
Library           Collections
Library           String
Library           Process

*** Variables ***
${can_config}    can_config.json
&{load_bus}    0=can0
${report_name}    ${EMPTY}
${arti_res_path}    ${EMPTY}

*** Keywords ***
DOWNLOAD PNP COLLECT
    [Arguments]    ${artifactory_path}=/pnp_debug/releases/2022-06-16/    ${artifactory_filename}=artifact_pnp_debug_module-8143064_78885269.zip
    [Documentation]    Download pnp_collect from artifactory
    ...    :param artifactory_path: path to the artifactory folder
    ...    :type path: string
    ...    :param artifactory_filename: pnp_debug archive name
    ...    :type filename: string
    DOWNLOAD ARTIFACTORY FILE    ${artifactory_path}${artifactory_filename}
    ${path_pnp_viewer} =    Set Variable    /tmp/PNP_COLLECT/PnpViewer/
    OperatingSystem.Move File    ${artifactory_filename}    ${path_pnp_viewer}
    OperatingSystem.Run    test ! -d ${path_pnp_viewer}/pnp_viewer && unzip ${path_pnp_viewer}/${artifactory_filename} -d ${path_pnp_viewer}
    OperatingSystem.Run    test ! -f ${path_pnp_viewer}/pnp_collect && mv ${path_pnp_viewer}/pnp_viewer/collectors/arm/linux/static/pnp_collect /tmp/PNP_COLLECT/PnpViewer/pnp_collect

START PNP COLLECT
    [Arguments]    ${output_file}    ${modules}    ${sampling_ms}=200    ${duration_ms}=1000
    ${verdict} =    PNP COLLECT    output_file=${output_file}     modules=${modules}    sampling_ms=${sampling_ms}    duration_ms=${duration_ms}
    Should Be True    ${verdict}    Failed to start pnp_collect

TIME PHONE BOOK UPDATE
    [Arguments]    ${message}
    [Documentation]    Checks if given message has arrived in the logcat
    @{event_list}=    Split String    ${message}
    ${rc}    ${line} =    Run And Return Rc And Output    cat Logcat.log | grep '${event_list[0]}'
    @{lines}=    Split to lines    ${line}
    FOR    ${line}    IN    @{lines}
        ${verdict1} =    Run Keyword And Ignore Error    Should Contain    ${line}    ${message}
        ${verdict2} =    Run Keyword And Ignore Error    Should Not Contain    ${line}    ${message}0
        ${time_update} =    Run Keyword If    ('${verdict1}[0]' == 'PASS') and ('${verdict2}[0]' == 'PASS')    DateTime.Get Current Date
        Exit For Loop If    ('${verdict1}[0]' == 'PASS') and ('${verdict2}[0]' == 'PASS')
    END
    Run Keyword If    '${time_update}' == 'None'     Fail
    [Return]     ${time_update}

SET PLATFORM INFO
    [Arguments]    ${target_id}    ${out_file}
    [Documentation]    Generate and check the PNP Platform info file ${out_file} on ${target_id}
    START PNP COLLECT    ${out_file}    platinfo    200    1000
    ${output} =    OperatingSystem.Run    adb -s ${target_id} shell cat ${out_file} | grep _Global_info
    Should Contain    ${output}    _Global_info
    ${output} =    OperatingSystem.Run    adb -s ${target_id} shell cat ${out_file} | grep _CPU_
    Should Contain    ${output}    _CPU_

LOAD CAN TRACE AND RUN
    [Arguments]    ${can_trace}
    [Documentation]    Load can trace and play record
    ...    ${can_trace}:    blf file to be replayed
    ${verdict}    ${comment} =    Canakin Load Record    1    ${CURDIR}/${can_trace}
    SHOULD BE TRUE    ${verdict}    ${comment}
    ${verdict}    ${comment} =    Canakin Launch Play Record    ${load_bus}
    SHOULD BE TRUE    ${verdict}    ${comment}

STOP CAN TRACE
    [Documentation]    Stop the running can trace
    ${verdict}    ${comment} =    Canakin Abort Play Record
    SHOULD BE TRUE    ${verdict}    ${comment}

SAVE TEST EXECUTION DETAILS
    [Arguments]    ${test_history_csv}    ${test_data}
    [Documentation]    Save the details of the current test execution
    ${file_exist}=    Run Keyword And Return Status    File Should Exist    ${test_history_csv}
    Run Keyword If    '${file_exist}'=='True'    Append To File    ${test_history_csv}    ${test_data}[0],${test_data}[1],${test_data}[2],${test_data}[3],${test_data}[4],${test_data}[5],${test_data}[6]${\n}
    ...    ELSE
    ...    Run Keywords
    ...    Append To File    ${test_history_csv}    Test Name,UCD Config,CAN Trace,Trace exec start,Trace exec end,iperf_output,pnp_collect_output${\n}
    ...    AND
    ...    Append To File    ${test_history_csv}    ${test_data}[0],${test_data}[1],${test_data}[2],${test_data}[3],${test_data}[4],${test_data}[5],${test_data}[6]${\n}

GET CURRENT CONSUMPTION AVERAGE
    [Arguments]    ${storage_list}
    [Documentation]    Get the current consumption average in mA from the list of results.
    ${statistics} =     COMPUTE STATISTICS    ${storage_list}
    ${average_number} =   Convert To Number    ${statistics}[average]
    # Convert to mA
    ${average_number} =    Evaluate    ${average_number} * 1000
    Log To Console      Average current measured : ${average_number} mA
    Log      Average current measured : ${average_number} mA
    [Return]    ${average_number}

UPLOAD PNP RESULTS TO ARTIFACTORY
    [Arguments]    ${results}    ${net_type}=default    ${dut_type}=${tc_config}[bench_type]   &{final_results}
    [Documentation]   Upload results to artifactory
    Return From Keyword If    ${results} == @{EMPTY}
    ${rat_type} =   Set Variable If   "${net_type}" == "default"    default
        ...   """${net_type}""" == """lte"""    4G
        ...   """${net_type}""" == """wcdma"""    3G
        ...   """${net_type}""" == """gsm_only"""    2G

    ${date} =	 DateTime.Get Current Date    result_format=datetime    exclude_millis=True
    ${hostname} =    RUN PROCESS    hostname
    ${hostname} =    Set Variable    ${hostname.stdout}
    ${directory_path} =   Set Variable If    '${ivc_bench_type}' in "'${dut_type}'" or '${ccs2_bench_type}' in "'${dut_type}'"     Results/${TEST_NAME}/${ivc_build_id}      Results/${TEST_NAME}/${ivi_build_id}
    ${file_path} =   Set Variable If    '${ivc_bench_type}' in "'${dut_type}'" or '${ccs2_bench_type}' in "'${dut_type}'"    ${directory_path}/${date}_${hostname}_${ivc_build_id}_${rat_type}.json      ${directory_path}/${date}_${hostname}_${ivi_build_id}.json
    CREATE DIRECTORY    ${directory_path}
    ${target_min}    ${target_max} =     GET TEST TARGET    ${net_type}
    ${lines} =    Create List
    Append To List    ${lines}    {\n
    ${results} =    Catenate    SEPARATOR=,    @{results}
    Append To List    ${lines}    "Runs": [${results}],\n
    FOR    ${key}    IN    @{final_results.keys()}
        ${line} =    SET VARIABLE    "${key}": ${final_results}[${key}],\n
        Append To List    ${lines}    ${line}
    END
    Append To List    ${lines}    "VIN": "${vehicle_id}",\n
    Append To List    ${lines}    "TC": "${TEST_NAME}",\n
    Append To List    ${lines}    "Host": "${hostname}",\n
    Append To List    ${lines}    "target_min": ${target_min},\n
    Append To List    ${lines}    "target_max": ${target_max},\n
    Run Keyword If    '${ivc_bench_type}' in "'${tc_config}[bench_type]'" or '${ccs2_bench_type}' in "'${tc_config}[bench_type]'"    Run Keywords    Append To List    ${lines}    "IVC_Build": ${ivc_build_id},\n
    ...    AND    Append To List    ${lines}    "IVC_Serial_Number": "${ivc_sn}",\n
    ...    AND    Append To List    ${lines}    "GW_SignalStrength": "${SignalStrength}[1]",\n
    ...    AND    Append To List    ${lines}    "LTE_SignalStrength_rsrp_rsrq_rssnr_cqi": "${SignalStrength}[3]",\n
    ...    AND    Append To List    ${lines}    "IVC_my_feature_id": "${ivc_my_feature_id}",\n
    ...    AND    Append To List    ${lines}    "rat_type": "${rat_type}",\n
    Run Keyword If    '${ivi_bench_type}' in "'${tc_config}[bench_type]'" or '${ccs2_bench_type}' in "'${tc_config}[bench_type]'"      Run Keywords    Append To List    ${lines}    "Platform_Type": "${ivi_platform_type}",\n
    ...    AND    Append To List    ${lines}    "Build_ID": "${ivi_build_id}",\n
    ...    AND    Append To List    ${lines}    "Build_Type": "${ivi_build_type}",\n
    ...    AND    Append To List    ${lines}    "Board_Type": "${board_type}",\n
    ...    AND    Append To List    ${lines}    "IVI_Serial_Number": "${ivi_sn}",\n
    ...    AND    Append To List    ${lines}    "Android_Software_Version": "${platform_version}",\n
    ...    AND    Append To List    ${lines}    "IVI_my_feature_id": "${ivi_my_feature_id}",\n
    Append To List    ${lines}    "Synchronization_time_with_Vnext_KMR": "${current_timestamp}"\n
    Append To List    ${lines}    }\n
    FOR    ${line}    IN    @{lines}
        APPEND TO FILE    ${file_path}    ${line}
    END
    IF    "${arti_res_path}" != "${EMPTY}"
        Log to console      Artifactory path: ${arti_res_path}
        PUSH FOLDER TO ARTIFACTORY    Results    ${arti_res_path}
        Move Directory    Results    ccs2/Results_Uploaded/${date}
    ELSE
        Log To Console    Warning: Results not uploaded to Artifactory (arti_res_path not defined by the user)
        Log   Results not uploaded to Artifactory (arti_res_path not defined by the user)    WARN
    END

GET TEST TARGET
    [Documentation]   Retrieve an expected target 'value' (or 'range') and the associated
    ...               'operande' from a pnp file storage
    [Arguments]    ${type_net}=default
    LOAD TARGET FILE    ${target_file}
    ${my_feature_id} =    Run Keyword If    "AIVC" in "${target_file}"    Set variable    ${ivc_my_feature_id}
    ...    ELSE IF  "AIVI" in "${target_file}"    Set variable     ${ivi_my_feature_id}

    ${verdict}    ${target_min}    ${target_max} =   GET TARGET FROM FILE   ${TEST_NAME}    ${my_feature_id}    ${type_net}
    Should Be True    ${verdict}
    [Return]    ${target_min}    ${target_max}

TRIGGER ANALYSIS
    [Documentation]    Analyze trigger related to erpm
    [Arguments]    ${trig_config_file}     ${mode}
    Set Log Level    TRACE
    File Should Exist    ${trig_config_file}
    ${TC_Description} =      Set Variable      Custom items for latency configuraiton
    IF    '${mode}' == 'ucd'
        ${signal} =    Set Variable    erpm
        @{trigger_list} =    Create List
        ${config_ucd} =    Parse XML     ${trig_config_file}
        ${all_items} =    Get Element    ${config_ucd}    Trigger_ContextElement
        @{all_items} =    Get Elements    ${all_items}    TC_item
        Log To Console    Processing: ${trig_config_file}
        FOR    ${item}    IN    @{all_items}
            ${name} =    Get Element Text    ${item}    TC_Name
            ${trigger_definition} =    Get Element Text    ${item}    Trg_Definition
            ${t0} =    Get Element Text    ${item}    PeriodicTrg_T0
            ${ctx_start} =    Get Element Text    ${item}    Ctx_Start
            ${ctx_stop} =    Get Element Text    ${item}    Ctx_End
            IF    ('${signal}' in '${trigger_definition}') or ('${signal}' in '${t0}') or ('${signal}' in '${ctx_start}') or ('${signal}' in '${ctx_stop}')
                Append To List    ${trigger_list}    ${name.strip()}
            END
        END
        Set Test Variable    @{trigger_list}
    ELSE IF    '${mode}' == 'plum'
        &{dict1} =    Create Dictionary    TC_Name=UCD/Sent/Trigger/every_50_changes_on_estpwt    TC_Type=Trigger    TC_Description=${TC_Description}
        ...       Trg_Definition=((estpwt) % "100" == "0")    PeriodicTrg_T0=-    PeriodicTrg_Period=-
        ...       Ctx_Start=-    Ctx_End=-

        ${config_ucd} =    Parse XML    ${trig_config_file}
        ${new_node1} =    Add Element    ${config_ucd}    <TC_itemdict1></TC_itemdict1>    xpath=Trigger_ContextElement    index=1

        FOR    ${key}    ${value}    IN    &{dict1}
            ${node_1} =    Add Element    ${new_node1}    <${key}>${value}</${key}>    xpath=Trigger_ContextElement/TC_itemdict1    index=1
        END
        ${set_node1} =    Set Element Tag    ${new_node1}    TC_item    Trigger_ContextElement/TC_itemdict1
        Save XML    ${new_node1}    ${trig_config_file}
    ELSE
        FAIL    The mode argument is wrong: ${mode}

    END

INSERT UCD ITEMS
    [Documentation]    Addition of item linked to ramp into tmp file
    [Arguments]    ${out_ucd_file}    ${mode}
    IF    '${mode}' == 'ucd'
        &{dict1} =    Create Dictionary    ID=10000    Data_Dictionary_name=Vehicle/Received/Engine/EstimatedPowerTrainWheelTorque
        ...    MessageType=UCD_Snapshot    CM_Context=-    CM_Operation=2    CM_Operation_Parameters=-
        ...    Computation_Condition=UCD/Sent/Trigger/every_100_changes_on_estpwt
        ...    Trigger_Condition=UCD/Sent/Trigger/every_100_changes_on_estpwt    Priority=Non_Urgent
        ...    TargetID=Telemetry    Activation_flag=1    Short_Label=estpwt    Data_Type=Float    Default_Value=null

        &{dict2} =    Create Dictionary    ID=10001    Data_Dictionary_name=Vehicle/Received/Engine/RPM    MessageType=UCD_Snapshot
        ...    CM_Context=-    CM_Operation=2     CM_Operation_Parameters=-    Computation_Condition=UCD/Sent/Trigger/every_100_changes_on_estpwt
        ...    Trigger_Condition=UCD/Sent/Trigger/every_100_changes_on_estpwt    Priority=Non_Urgent
        ...    TargetID=Telemetry    Activation_flag=1    Short_Label=erpm    Data_Type=Float    Default_Value=null

        ${config_ucd} =    Parse XML    ${out_ucd_file}
        ${new_node1} =    Add Element    ${config_ucd}    <UCD_CF_item_dict1></UCD_CF_item_dict1>    xpath=UCDData    index=1
        ${new_node2} =    Add Element    ${config_ucd}    <UCD_CF_item_dict2></UCD_CF_item_dict2>    xpath=UCDData    index=1

        FOR    ${key}    ${value}    IN    &{dict1}
            ${node_1} =    Add Element    ${new_node1}    <${key}>${value}</${key}>    xpath=UCDData/UCD_CF_item_dict1    index=1
        END
        ${set_node1} =    Set Element Tag    ${new_node1}    UCD_CF_item    UCDData/UCD_CF_item_dict1
        Save XML    ${new_node1}    ${out_ucd_file}

        FOR    ${key}    ${value}    IN    &{dict2}
            ${node_2} =    Add Element    ${new_node2}    <${key}>${value}</${key}>    xpath=UCDData/UCD_CF_item_dict2    index=1
        END
        ${set_node2} =    Set Element Tag    ${new_node1}    UCD_CF_item    UCDData/UCD_CF_item_dict2
        Save XML    ${new_node2}    ${out_ucd_file}
    ELSE IF    '${mode}' == 'plum'
        &{dict1} =    Create Dictionary    ID=20000    ReportDataName=estpwt    ReportEventName=UCD/Sent/Trigger/every_50_changes_on_estpwt
        ...       CMOperation=2    CMOperationParameters=-    ComputationCondition=-

        &{dict2} =    Create Dictionary    ID=20001    ReportDataName=erpm    ReportEventName=UCD/Sent/Trigger/every_50_changes_on_estpwt
        ...       CMOperation=2    CMOperationParameters=-    ComputationCondition=-
        ${config_ucd} =    Parse XML    ${out_ucd_file}
        ${new_node1} =    Add Element    ${config_ucd}    <UCD_CF_item_dict1></UCD_CF_item_dict1>    xpath=UCDData    index=1
        ${new_node2} =    Add Element    ${config_ucd}    <UCD_CF_item_dict2></UCD_CF_item_dict2>    xpath=UCDData    index=1

        FOR    ${key}    ${value}    IN    &{dict1}
            ${node_1} =    Add Element    ${new_node1}    <${key}>${value}</${key}>    xpath=UCDData/UCD_CF_item_dict1    index=1
        END
        ${set_node1} =    Set Element Tag    ${new_node1}    UCD_CF_item    UCDData/UCD_CF_item_dict1
        Save XML    ${new_node1}    ${out_ucd_file}

        FOR    ${key}    ${value}    IN    &{dict2}
            ${node_2} =    Add Element    ${new_node2}    <${key}>${value}</${key}>    xpath=UCDData/UCD_CF_item_dict2    index=1
        END
        ${set_node2} =    Set Element Tag    ${new_node1}    UCD_CF_item    UCDData/UCD_CF_item_dict2
        Save XML    ${new_node2}    ${out_ucd_file}
    ELSE
        FAIL    The mode argument is wrong: ${mode}
    END

UNSET COMF
    [Documentation]    Deactivation of item linked to erpm => tmp file is produced
    [Arguments]    ${out_ucd_file}
    @{nb_deactivated} =    Create List
    ${config_ucd} =    Parse XML    ${out_ucd_file}
    ${all_items} =    Get Element    ${config_ucd}    UCDData
    @{all_items} =    Get Elements    ${all_items}    UCD_CF_item
    FOR    ${item}     IN    @{all_items}
        ${id} =    Get Element Text    ${item}    ID
        ${name} =    Get Element Text    ${item}    Data_Dictionary_name
        ${operation} =    Get Element Text    ${item}    CM_Operation_Parameters
        ${computation_cond} =    Get Element Text    ${item}    Computation_Condition
        ${trig_cond} =    Get Element Text    ${item}    Trigger_Condition
        ${short_l} =    Get Element Text    ${item}    Short_Label
        ${activation_flag} =    Get Element Text    ${item}    Activation_flag
        IF    ${activation_flag} == ${1} and ${id} != ${10001}
            ${status_cond} =    Check The Trigger In List   ${computation_cond}    ${trig_cond}
            IF    ('erpm' in '${short_l}') or ('erpm' in '${operation}') or (${status_cond} == ${True})
                Log    Item to deactivate: ${name} (id: ${id})    console=Yes
                ${act_flag} =    Get Element Text    ${item}    Activation_flag
                ${act_flag} =    Set Element Text    ${item}    0    xpath=Activation_flag
                ${act_flag} =    Get Element Text    ${item}    Activation_flag
                Append To List    ${nb_deactivated}    ${id}
            END
        END
    END
    ${len_deactivated} =    Get Length    ${nb_deactivated}
    Log    Number of item deactivated: ${len_deactivated}      console=Yes
    Save XML    ${config_ucd}    ${out_ucd_file}

CHECK THE TRIGGER IN LIST
    [Documentation]    Check the trigger is present in XML file
    [Arguments]    ${cmp_cond}    ${trig_cond}
    FOR    ${trigger}    IN    @{trigger_list}
        Return From Keyword If    ('${cmp_cond.strip()}' in '${trigger}') or ('${trig_cond.strip()}' in '${trigger}')    ${True}
    END
    Return From Keyword    ${False}

SET LATENCY CONFIGURATION
    [Documentation]   Deactivates items related to erpm and adds special items related to ramp
    ...    xml configuration file is expected as argumente
    [Arguments]    ${ucd_conf_file}=${NONE}    ${trig_file}=${NONE}    ${cfg_dir}=${NONE}   ${ucd_cfg_out}=${NONE}    ${g_generate}=${NONE}    ${mode}=ucd
    Set Log Level    TRACE
    File Should Exist    ${EXECDIR}/${ucd_conf_file}
    File Should Exist    ${EXECDIR}/${trig_file}
    Directory Should Exist    ${EXECDIR}/${cfg_dir}
    OperatingSystem.Copy File    ${EXECDIR}/${ucd_conf_file}   ${EXECDIR}/${ucd_conf_file}_bkp
    File Should Exist    ${EXECDIR}/${ucd_conf_file}_bkp
    CHECKSET CUSTOM SETTINGS    ${EXECDIR}/${ucd_conf_file}    ${EXECDIR}/${cfg_dir}    ${EXECDIR}/${ucd_cfg_out}
    File Should Exist    ${EXECDIR}/${ucd_cfg_out}
    TRIGGER ANALYSIS    ${EXECDIR}/${trig_file}    ${mode}
    Run Keyword If      '${mode}' == 'ucd'    UNSET COMF    ${EXECDIR}/${ucd_cfg_out}
    INSERT UCD ITEMS    ${EXECDIR}/${ucd_cfg_out}    ${mode}
    Run    chmod 777 ${EXECDIR}/${ucd_cfg_out}
    Run    chmod 777 ${EXECDIR}/${trig_file}
    ${output} =    Run    ls -al
    Log    Existing files:${output}

CREATE PLUM QUERY
    [Documentation]   Parses all the xml CS files provided in directory and builds query file to populate cfm.db table
    [Arguments]    ${path_plum_dir}    ${dir_sql_path}    ${cfm_path}    ${ucd_files}
    Run process    chmod 777 /tmp   shell=True
    Run process    > /etc/apt/apt.conf    shell=True
    Run process    apt update    shell=True
    Run process    apt install sqlite3    shell=True
    ${output} =    Run process    sqlite3 -cmd '.timeout 1000' ${cfm_path} 'SELECT COUNT(*) FROM ucdproperty;'    shell=True
    Log    ${output.stdout}
    FOR    ${dir_name}    IN    @{ucd_files}
        ${verdict_dir} =  Run Keyword And Warn On Failure    Directory Should Exist    ${path_plum_dir}/${dir_name}
        Run Keyword If    '${verdict_dir}[0]'!='PASS'    Continue For Loop
        @{xml_files} =    List Files In Directory    ${path_plum_dir}/${dir_name}
        FOR    ${ucd_xml_file}    IN    @{xml_files}
            ${xml_file_path}    ${xml_file_ext} =    OperatingSystem.Split Extension    ${ucd_xml_file}
            OperatingSystem.Create file    ${dir_sql_path}/${xml_file_path}.sql
            ${config_ucd} =    Parse XML    ${path_plum_dir}/${dir_name}/${ucd_xml_file}
            @{list_ucd} =    Get Elements    ${config_ucd}    property
            ${nb} =    GET LENGTH    ${list_ucd}
            Log    ${\n} Found ${nb} properties in ${ucd_xml_file}    console=Yes
            Log    ${\n} Store to${dir_sql_path}/${xml_file_path}.sql    console=Yes
            FOR    ${element}    IN    @{list_ucd}
                ${name} =    Get Element Attribute    ${element}    Name
                ${type} =    Get Element Attribute    ${element}    Type
                ${value} =    Get Element Attribute    ${element}    value
                ${sql_inject} =    Format String    INSERT INTO ucdproperty VALUES(NULL, "${name}", 1, 0);${\n}
                @{list_name_ucd} =    Split String    ${sql_inject}    ;
                ${len_name} =    GET LENGTH    ${list_name_ucd}
                IF    ${list_name_ucd} != ${2}
                      OperatingSystem.Append to file    ${dir_sql_path}/${xml_file_path}.sql    ${sql_inject}
                      ${output} =    Run    sqlite3 -cmd '.timeout 1000' ${cfm_path} '${sql_inject}'
                END
            END
        END
    END

    ${custom_inject_1} =    Format String    INSERT INTO ucdproperty VALUES(NULL, "erpm;UCD/Sent/Trigger/every_50_changes_on_estpwt;CUSTOM;5;60;0", 1, 0);${\n}
    ${custom_inject_2} =    Format String    INSERT INTO ucdproperty VALUES(NULL, "estpwt;UCD/Sent/Trigger/every_50_changes_on_estpwt;CUSTOM;5;60;0", 1, 0);${\n}
    ${output} =    Run    sqlite3 -cmd '.timeout 1000' ${cfm_path} '${custom_inject_1}'
    ${output} =    Run    sqlite3 -cmd '.timeout 1000' ${cfm_path} '${custom_inject_2}'
    ${output} =    Run process    sqlite3 -cmd '.timeout 1000' ${cfm_path} 'SELECT COUNT(*) FROM ucdproperty;'    shell=True
    Log    ${output.stdout}

DOWNLOAD UCD AND PLUM CONFIGURATION FROM ARTIFACTORY
    [Documentation]   Download from artifactory/git for ucd and plum configuration files
    [Arguments]      ${based_path}      ${artifactory_path}
    ${is_path} =    Evaluate    "/" in """${based_path}"""
    ${download_from} =    Evaluate    "gitlabee.dt" in """${based_path}"""
    IF    ${download_from}==True
        Log to console    Using GIT path: ${based_path}
        ${output} =    Run Process    wget ${based_path}    shell=True
        Should Be Equal As Integers	    ${output.rc}    0    Failed to download from GIT
    ELSE
        IF    ${is_path}==True
            Log To Console    Using artifactory custom path: ${based_path}
            DOWNLOAD ARTIFACTORY FILE    ${based_path}
        ELSE
            Log To Console    Using artifactory default path: ${artifactory_path}
            DOWNLOAD ARTIFACTORY FILE    ${artifactory_path}
        END
    END
