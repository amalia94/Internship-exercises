#
# Copyright (c) 2020, 2021, 2022 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Documentation     Logs related keywords library
# FDU Import to be removed once the EXEC LOCAL CMD is removed
Resource          ${CURDIR}/../Tools/bench_config.robot
Resource          ../../hlk_common/IVI/ivi.robot
Resource          ../../hlk_common/IVI/Connectivity/bluetooth.robot
Resource          ../../hlk_common/IVI/adb_command.robot
Resource          ../../hlk_common/Enabler/reliability.robot
Library           rfw_libraries.logmon.CandumpMonitor
Library           rfw_libraries.ivc.adbControl
Library           rfw_services.ivi.LogsLib    device=${ivi_adb_id}
Library           rfw_services.wicket.SystemLib
Library           rfw_services.wicket.LogsLib
Library           rfw_services.wicket.DebugToolsLib
Library           rfw_services.ivi.ReliabilityLib    device=${ivi_adb_id}
Library           Collections
Library           OperatingSystem
Library           DateTime
Library           rfw_libraries.logmon.DltMonitor
Library	          rfw_services.wicket.SystemLib
Library           rfw_services.wicket.DeviceLib
Library           rfw_libraries.toolbox.StatsLib
Library           rfw_libraries.logmon.LogCatMonitor
Library           rfw_libraries.logmon.PcapMonitor
Library           rfw_libraries.logmon.AplogMonitor
Library           rfw_libraries.logmon.BootloaderMonitor
Library           rfw_libraries.logmon.BugReportMonitor
Library           rfw_libraries.logmon.DmesgMonitor
Library           rfw_libraries.logmon.MicomMonitor
Library           rfw_libraries.dlt.DltControl.DltControl   ip=%{WICKET_HOSTNAME=172.17.0.1}
Library           String
Library           Process
Library           OperatingSystem
Resource          ${CURDIR}/artifactory.robot
Variables         ${CURDIR}/dlt_data.yaml

*** Variables ***
${console_logs}    yes
${logs_name}      ${None}
${logs_folder}    ${None}
${local_logs_folder}    debug_logs
${shared_volume_path}    /rhw
${dlt_ip}    127.0.0.1
${ivi_bugreport_logs}       False
${ivi_dmesg_logs}           False
${ivi_procrank_logs}        False
${ivi_logcat_logs}          False
${ivi_serial_logs}          False
${ivi_aplog_logs}           False
${ivi_micom_logs}           False
${ivi_bootloader_logs}      False
${ivi_pcap_logs}            False
${ivi_dlt_logs}             False
${ivi_dropbox_logs}         False
${ivi_hci_logs}             False
${ivi_ecs_logs}             False
${ivi_mem_info_logs}        False
${ivc_dlt_logs}             False
${ivc_pcap_logs}            False
${ivc_dmesg_logs}           False
${bench_pcap_logs}          False
${bench_can_logs}           False
${bench_docker_logs}        False
${sgw_ivc_mirroring_logs}    False
${sgw_ivi_mirroring_logs}    False
${cmd_extract_MQTT_req}     grep "<- PUBLISH"
${cmd_extract_MQTT_resp}    grep "> PUBLISH"
${mqtt_vnext_to_ivc}        MQTT Prot <- PUBLISH
${mqtt_ivc_to_vnext}        MQTT Prot -> PUBLISH
${file_path}                /tmp/logs.txt
${tcpdump_ivi_file}         ivi_tcpdump.pcap
${tcpdump_ivi_path}         /data/
${enable_logs}              no
${ivc_dlt_regex}            False
${save_logs_files}          True
${keep_logs_files}          False
${bluetooth_hci_snoop}      False

&{ivi_onboard_logs_config}         logcat=${ivi_logcat_logs}    dlt=${ivi_dlt_logs}    bugreport=${ivi_bugreport_logs}      dmesg=${ivi_dmesg_logs}    procrank=${ivi_procrank_logs}    serial=${ivi_serial_logs}    aplog=${ivi_aplog_logs}    micom=${ivi_micom_logs}    bootloader=${ivi_bootloader_logs}    pcap=${ivi_pcap_logs}    dropbox=${ivi_dropbox_logs}    hci=${ivi_hci_logs}    ecs=${ivi_ecs_logs}   mem_info=${ivi_mem_info_logs}
&{ivc_onboard_logs_config}         dmesg=${ivc_dmesg_logs}    pcap=${ivc_pcap_logs}    dlt=${ivc_dlt_logs}
&{sgw_mirroring_logs_config}       ivc=${sgw_ivc_mirroring_logs}    ivi=${sgw_ivi_mirroring_logs}

&{bench_logs_config}       pcap=${bench_pcap_logs}    can=${bench_can_logs}    docker=${bench_docker_logs}
${availability_call_back}    onAvailabilityCallback
${config_get_request}    ConfigurationGetRequest
${config_get_response}    onConfigurationGetResponse
${maintenance_info_request}    maintenanceInfoIndicationRequest

${dlt_conf_file}     dlt_logstorage.conf
${dlt_conf_path}     matrix/artifacts/reliability/DLT_conf/DEFAULT/
${restore_url_path}    matrix/artifacts/automation_rsl/DEFAULT/
${restore_dlt_conf_file}       dlt_logstorage.conf
${destination_folder}    /mnt/mmc/logs/
${root_dir}       ./
${TC_folder}    ${None}

*** Keywords ***
START LOGS TOOLS
    [Arguments]    ${setup_type}    ${enable_logs}=False    ${output_folder}=loop_001    ${setup_phase}=False    ${artifactory_logs_folder}=${None}
    ${tc_name} =    Replace String    ${SUITE NAME}    ${space}    _
    Set Suite Variable    ${logs_name}    ${current_timestamp}_${tc_name}_${hostname}

    ${shared_volume_status} =    Run Keyword And Return Status    Directory Should Exist    ${shared_volume_path}
    ${logs_folder} =    Set Variable If    "${shared_volume_status}" == "True"    ${shared_volume_path}/${local_logs_folder}/${logs_name}/${output_folder}    ${output_folder}/${logs_name}
    ${logs_top_folder} =    Set Variable If    "${shared_volume_status}" == "True"    ${shared_volume_path}/${local_logs_folder}/${logs_name}    ${output_folder}/${logs_name}
    Run Keyword And Ignore Error    Create Directory    ${logs_folder}

    Set Suite Variable    ${logs_folder}    ${logs_folder}
    Set Suite Variable    ${output_folder}    ${output_folder}
    Set Suite Variable    ${logs_top_folder}    ${logs_top_folder}

    Run Keyword if    "${enable_logs}" != "True"    Return From Keyword
    Log    **** START LOGS ****    console=${console_logs}
    ${local_folder} =    Set Variable If    "${shared_volume_status}" == "True"    /opt${logs_folder}    ${logs_folder}
    # Log    Logs will be available locally at ${local_folder}    console=${console_logs}
    Set Suite Variable    ${local_folder}    ${local_folder}
    Run Keyword And Ignore Error    START BENCH LOGS

    Run Keyword if     "${setup_phase}" == "False"    Return From Keyword
    IF    "${artifactory_logs_folder}" != '${None}'
        Run Keyword And Ignore Error    DISPLAY ARTIFACTORY LOGS PATH   ${artifactory_logs_folder}/${logs_name}
    ELSE
        Log    Logs local path: /opt${logs_top_folder}    WARN    console="yes"
    END
    # Run Keyword And Ignore Error    REMOVE DEBUG LOGS FOLDER

#TODO: This KW will be removed when all Reliability TCs will be reworked as Test Case Template
DISABLE CANDUMP MONITOR RELIABILITY
    [Arguments]
    [Documentation]    This kw is used until logging is enabled
    IF    "${enable_logs}" == "yes"
        Log To Console    Disable Candump Monitor
        ${verdict}    ${comment} =    STOP CANDUMP MONITOR
        Should be True    ${verdict}    ${comment}
        Move Directory    /rhw/logmon_logs/candump   /rhw/debug_logs/${current_tc_name}
    END

STOP LOGS TOOLS
    [Arguments]    ${setup_type}    ${enable_logs}=False    ${artifactory_logs_folder}=${None}    ${teardown_phase}=False

    Run Keyword if    "${enable_logs}" != "True"    Return From Keyword
    Log    **** STOP LOGS ****    console=${console_logs}
    #TODO: Next line to be removed when all Reliability TCs will be reworked as Test Case Template
    Run Keyword If    "${TC_folder}"=="RELIABILITY"    Run Keyword And Ignore Error    DISABLE CANDUMP MONITOR RELIABILITY
    Run Keyword And Ignore Error    STOP BENCH LOGS

    IF    "${artifactory_logs_folder}" != '${None}'
        OperatingSystem.Run    zip -jr ${logs_top_folder}/${output_folder}.zip ${logs_folder}
        IF    "${keep_logs_files}" == "False"
            Remove Directory    ${logs_folder}    recursive=True
        END
        Run Keyword And Ignore Error    PUSH FILES TO ARTIFACTORY    ${logs_top_folder}/${output_folder}.zip    ${artifactory_logs_folder}/${logs_name}/${output_folder}.zip
        IF    "${keep_logs_files}" == "False"
            OperatingSystem.Remove File     ${logs_top_folder}/${output_folder}.zip
            IF    "${teardown_phase}" == "True"
                Run Keyword And Return Status    OperatingSystem.Run And Return Rc And Output    zip -r ${logs_top_folder}.zip ${logs_top_folder}
                Run Keyword And Ignore Error    PUSH FILES TO ARTIFACTORY    ${logs_top_folder}.zip    ${artifactory_logs_folder}${logs_top_folder}.zip
                Remove Directory    ${logs_top_folder}    recursive=True
           END
        END
    END
    Log    Logs local path: ${local_folder}    console="yes"

START ONBOARD LOGS TOOLS
    [Arguments]    ${setup_type}    ${enable_logs}=False    ${setup_phase}=False
    Run Keyword if    "${enable_logs}" != "True" or ("${ivi_can}" == "False" and "${ivc_can}" == "False")    Return From Keyword
    Log    **** START ONBOARD LOGS ****    console=${console_logs}

    Run Keyword If    "${ivi_can}" == "True"    Run Keyword And Ignore Error    START IVI ONBOARD LOGS    ${setup_phase}
    Run Keyword If    "${ivc_can}" == "True"    Run Keyword And Ignore Error    START IVC ONBOARD LOGS    ${setup_phase}

STOP ONBOARD LOGS TOOLS
    [Arguments]    ${setup_type}    ${enable_logs}=False    ${teardown_phase}=False
    Run Keyword if    "${enable_logs}" != "True" or ("${ivi_can}" == "False" and "${ivc_can}" == "False")    Return From Keyword
    Log    **** STOP ONBOARD LOGS TOOLS ****    console=${console_logs}
    Run Keyword If    "${ivi_can}" == "True"    Run Keyword And Ignore Error    STOP IVI ONBOARD LOGS    ${teardown_phase}
    Run Keyword If    "${ivc_can}" == "True"    Run Keyword And Ignore Error    STOP IVC ONBOARD LOGS    ${teardown_phase}

START BENCH LOGS
    [Arguments]    ${logs_folder}=${logs_folder}
    [Documentation]    Launch the saving of logs on ${target_id}.
    ...             ${current_tc_name} is the name of the testcase, used in LLK
    @{bench_log_to_save} =    create list
    FOR    ${item}    IN    @{bench_logs_config.keys()}
        Run Keyword If    "${bench_logs_config}[${item}]" == "True"    Append to list    ${bench_log_to_save}    ${item}
    END

    Run Keyword if    "${console_logs}" == "yes"     Log    Bench Logs Enabled = ${bench_log_to_save}    console=yes

    Run Keyword If    "${bench_logs_config}[can]" == "True"    Run Keyword And Ignore Error    START CAN LOGS    ${logs_folder}
    Run Keyword If    "${bench_logs_config}[pcap]" == "True"    Run Keyword And Ignore Error    START PCAP MONITOR     interface=${bench_eth}    folder=${logs_folder}    file_name=bench_tcpdump.pcap    save_logs=${save_logs_files}

STOP BENCH LOGS
    Run Keyword If    "${bench_logs_config}[can]" == "True"    Run Keyword And Ignore Error    STOP CAN LOGS
    Run Keyword If    "${bench_logs_config}[pcap]" == "True"    Run Keyword And Ignore Error    STOP PCAP MONITOR

START IVI ONBOARD LOGS
    [Arguments]    ${setup_phase}=False
    [Documentation]    Launch the saving of logs on ${target_id}.
    ...             ${current_tc_name} is the name of the testcase, used in LLK

    @{ivi_onboard_log_to_save} =    create list    @{EMPTY}

    FOR    ${item}    IN    @{ivi_onboard_logs_config.keys()}
        Run Keyword If    "${ivi_onboard_logs_config}[${item}]" == "True"    Append to list    ${ivi_onboard_log_to_save}    ${item}
        Run Keyword If    "${item}" == "logcat" and "${ivi_onboard_logs_config}[${item}]" == "True"      Run Keyword And Ignore Error    START LOGCAT MONITOR    device=${ivi_adb_id}    folder=${logs_folder}    file_name=ivi_logcat    save_logs=${save_logs_files}
        Run Keyword If    "${item}" == "aplog" and "${ivi_onboard_logs_config}[${item}]" == "True"       Run Keywords     Run Keyword And Ignore Error    REMOVE IVI APLOG    ${ivi_adb_id}
        ...    AND    Run Keyword And Ignore Error    START APLOG MONITOR    device=${ivi_adb_id}    folder=${logs_folder}    file_name=ivi_aplog    save_logs=${save_logs_files}
        Run Keyword If    "${item}" == "dmesg" and "${ivi_onboard_logs_config}[${item}]" == "True"       Run Keyword And Ignore Error    START DMESG MONITOR    device=${ivi_adb_id}    folder=${logs_folder}    file_name=ivi_dmesg    save_logs=${save_logs_files}
        Run Keyword If    "${item}" == "micom" and "${ivi_onboard_logs_config}[${item}]" == "True"       Run Keyword And Ignore Error    START MICOM MONITOR    folder=${logs_folder}    file_name=ivi_micom    save_logs=${save_logs_files}
        Run Keyword If    "${item}" == "bootloader" and "${ivi_onboard_logs_config}[${item}]" == "True"       Run Keyword And Ignore Error    START BOOTLOADER MONITOR    folder=${logs_folder}    file_name=ivi_bootloader    save_logs=${save_logs_files}
        Run Keyword If    "${item}" == "pcap" and "${ivi_onboard_logs_config}[${item}]" == "True"        Run Keyword And Ignore Error    START TCPDUMP ON IVI
        Run Keyword If    "${item}" == "dropbox" and "${ivi_onboard_logs_config}[${item}]" == "True"     Run Keyword And Ignore Error    REMOVE IVI DROPBOX CRASHES    ${ivi_adb_id}
        IF    "${setup_phase}" == "True"
            Run Keyword If    "${item}" == "hci" and "${ivi_onboard_logs_config}[${item}]" == "True"     Run Keyword And Ignore Error    ENABLE BLUETOOTH HCI SNOOP LOG
            Run Keyword If    "${item}" == "bugreport" and "${ivi_onboard_logs_config}[${item}]" == "True"     Run Keywords    Run Keyword And Ignore Error    RESET IVI BUG REPORTS    ${ivi_adb_id}
            ...    AND    Run Keyword And Ignore Error    START BUGREPORT MONITOR    device=${ivi_adb_id}    folder=${logs_folder}    file_name=ivi_bugreport    save_logs=${save_logs_files}
        END
    END

    Run Keyword if    "${console_logs}" == "yes"     Log    IVI OnBoard Logs Enabled = ${ivi_onboard_log_to_save}    console=yes

STOP IVI ONBOARD LOGS
    [Arguments]    ${teardown_phase}=False
    [Documentation]    stop the logging & reinit gloabal var (testcase name)
    @{ivi_onboard_log_to_save} =    create list    @{EMPTY}
    FOR    ${item}    IN    @{ivi_onboard_logs_config.keys()}
        Run Keyword If    "${ivi_onboard_logs_config}[${item}]" == "True"    Append to list    ${ivi_onboard_log_to_save}    ${item}
        Run Keyword If    "${item}" == "logcat" and "${ivi_onboard_logs_config}[${item}]" == "True"    Run Keyword And Ignore Error    STOP LOGCAT MONITOR
        Run Keyword If    "${item}" == "aplog" and "${ivi_onboard_logs_config}[${item}]" == "True"       Run Keyword And Ignore Error    STOP APLOG MONITOR
        Run Keyword If    "${item}" == "dmesg" and "${ivi_onboard_logs_config}[${item}]" == "True"       Run Keyword And Ignore Error    STOP DMESG MONITOR
        Run Keyword If    "${item}" == "micom" and "${ivi_onboard_logs_config}[${item}]" == "True"       Run Keyword And Ignore Error    STOP MICOM MONITOR
        Run Keyword If    "${item}" == "bootloader" and "${ivi_onboard_logs_config}[${item}]" == "True"       Run Keyword And Ignore Error    STOP BOOTLOADER MONITOR
        Run Keyword If    "${item}" == "pcap" and "${ivi_onboard_logs_config}[${item}]" == "True"        Run Keyword And Ignore Error    STOP TCPDUMP ON IVI
        Run Keyword If    "${item}" == "mem_info" and "${ivi_onboard_logs_config}[${item}]" == "True"     Run Keyword And Ignore Error    RETRIEVE IVI MEMORY INFORMATION
        IF    "${teardown_phase}" == "True"
            Run Keyword If    "${item}" == "dropbox" and "${ivi_onboard_logs_config}[${item}]" == "True"     Run Keyword And Ignore Error    SAVE IVI DROPBOX CRASHES    ${ivi_adb_id}
            Run Keyword If    "${item}" == "ecs" and "${ivi_onboard_logs_config}[${item}]" == "True"     Run Keyword And Ignore Error    RETRIEVE IVI ECS LOGS
            Run Keyword If    "${item}" == "bugreport" and "${ivi_onboard_logs_config}[${item}]" == "True"     Run Keywords    Run Keyword And Ignore Error    EXTRACT ANDROID BUG REPORTS    ${ivi_adb_id}
            ...    AND     Run Keyword And Ignore Error    STOP BUGREPORT MONITOR
            Run Keyword If    "${item}" == "hci" and "${ivi_onboard_logs_config}[${item}]" == "True"     Run Keyword And Ignore Error    DISABLE BLUETOOTH HCI SNOOP LOG
        ELSE
            Run Keyword If    "${item}" == "hci" and "${ivi_onboard_logs_config}[${item}]" == "True"     Run Keyword And Ignore Error    RETRIEVE BLUETOOTH HCI SNOOP LOG
        END
    END

CONFIGURE DLT LOGS
    [Arguments]    ${artifactory_path}=${dlt_conf_path}    ${file_name}=${dlt_conf_file}
    # REMOVE DLT LOGS ON IVC
    DOWNLOAD ARTIFACTORY FILE    ${artifactory_path}${file_name}    ${FALSE}
    Sleep   2
    SYSTEM SEND FILE TO DEVICE        ./${file_name}    /mnt/mmc/logs/${file_name}
    DELETE DLT LOGS
    SET IVI IP TABLES FOR IVC DLT LOGGING

START IVC ONBOARD LOGS
    [Arguments]    ${setup_phase}=False    ${output_folder}=${logs_folder}
    @{ivc_onboard_log_to_save} =    create list    @{EMPTY}
    FOR    ${item}    IN    @{ivc_onboard_logs_config.keys()}
        Run Keyword If    "${ivc_onboard_logs_config}[${item}]" == "True"    Append to list    ${ivc_onboard_log_to_save}    ${item}
        IF    "${setup_phase}" == "True"
            Run Keyword If    "${item}" == "dlt" and "${ivc_onboard_logs_config}[${item}]" == "True"    CONFIGURE DLT LOGS
        END
        Run Keyword If    "${item}" == "dlt" and "${ivc_onboard_logs_config}[${item}]" == "True"    Run Keyword And Ignore Error    START DLT LOGGING    folder=${output_folder}    file_name=ivc_logs.dlt
        Run Keyword If    "${item}" == "pcap" and "${ivc_onboard_logs_config}[${item}]" == "True"     Run Keyword And Ignore Error    START TCPDUMP ON IVC
    END

    Run Keyword if    "${console_logs}" == "yes"     Log    IVC OnBoard Logs Enabled = ${ivc_onboard_log_to_save}    console=yes
    Run Keyword if    ${ivc_onboard_log_to_save} == @{EMPTY}    Return From Keyword

STOP IVC ONBOARD LOGS
    [Arguments]    ${teardown_phase}=False
    [Documentation]    stop the logging & reinit gloabal var (testcase name)
    FOR    ${item}    IN    @{ivc_onboard_logs_config.keys()}
        Run Keyword If    "${item}" == "dmesg" and "${ivc_onboard_logs_config}[${item}]" == "True"    Run Keyword And Ignore Error    RETRIEVE IVC DMESG
        Run Keyword If    "${item}" == "dlt" and "${ivc_onboard_logs_config}[${item}]" == "True"    Run Keywords    Run Keyword And Ignore Error    STOP DLT LOGGING
        ...    AND    Run Keyword And Ignore Error    DELETE DLT LOGS
        # IF    "${teardown_phase}" == "True"
        #     Run Keyword If    "${item}" == "dlt" and "${ivc_onboard_logs_config}[${item}]" == "True"    Run Keyword And Ignore Error    RESTORE DLT LOGSTORAGE DEFAULT CONFIGURATION
        # END
        Run Keyword If    "${item}" == "pcap" and "${ivc_onboard_logs_config}[${item}]" == "True"     Run Keyword And Ignore Error    STOP TCPDUMP ON IVC
    END

START SGW ONBOARD LOGS
    [Documentation]    Start Port mirroring on SGW for IVI or IVC links
    [Arguments]    ${enable_logs}=False    ${output_folder}=${logs_folder}
    Run Keyword if    "${enable_logs}" != "True"    Return From Keyword
    @{sgw_onboard_log_to_save} =    create list    @{EMPTY}

    ${sgw_mirroring_count} =    Set variable    ${0}
    FOR    ${item}    IN    @{sgw_mirroring_logs_config.keys()}
        IF    "${sgw_mirroring_logs_config}[${item}]" == "True"
            ${sgw_mirroring_count} =    Evaluate    ${sgw_mirroring_count}+${1}
        END
        IF    ${sgw_mirroring_count} > ${1}
            Log    Both IVI and IVC port mirroring requested on SGW... only 1 is allowed. Will launch IVC port mirroring only !!!     WARN    console="yes"
        END
    END

    IF    ${sgw_mirroring_count} == ${0}
        Return From Keyword
    END
    Log    **** START SGW PORT MIRRORING ****    console=${console_logs}

    FOR    ${item}    IN    @{sgw_mirroring_logs_config.keys()}
        Run Keyword If    "${sgw_mirroring_logs_config}[${item}]" == "True"    Append to list    ${sgw_onboard_log_to_save}    ${item}
        Run Keyword If    "${item}" == "ivc" and "${sgw_mirroring_logs_config}[${item}]" == "True"    Run Keyword And Ignore Error    SGW PORT MIRRORING START    capture_port=ETH1_IVC     sniffer_port=ETH3_ADAS
        IF    ${sgw_mirroring_count} == ${1}
            Run Keyword If    "${item}" == "ivi" and "${sgw_mirroring_logs_config}[${item}]" == "True"    Run Keyword And Ignore Error    SGW PORT MIRRORING START    capture_port=ETH5_IVI     sniffer_port=ETH3_ADAS
        END
    END

    IF    '${sgw_mirroring_bench_eth}' == '${None}'
        Log    No Eth Interface to collect SGW port mirroring. Please use sgw_mirroring_bench_eth:<IF_NAME>     WARN    console="yes"
    END
    Run Keyword And Ignore Error    START PCAP MONITOR     interface=${sgw_mirroring_bench_eth}    folder=${output_folder}    file_name=sgw_mirroring_bench_tcpdump.pcap    save_logs=${save_logs_files}

    Log    SGW Port Mirroring Enabled = ${sgw_onboard_log_to_save}    console=${console_logs}
    Run Keyword if    ${sgw_onboard_log_to_save} == @{EMPTY}    Return From Keyword

STOP SGW ONBOARD LOGS
    [Documentation]    stop the logging & reinit gloabal var (testcase name)
    Log    **** STOP SGW PORT MIRRORING ****    console=${console_logs}
    FOR    ${item}    IN    @{sgw_mirroring_logs_config.keys()}
        Run Keyword If    ("${item}" == "ivc" or "${item}" == "ivi") and "${sgw_mirroring_logs_config}[${item}]" == "True"    Run Keyword And Ignore Error    SGW PORT MIRRORING STOP
    END
   Run Keyword And Ignore Error    STOP PCAP MONITOR

MAKE ZIP LOG ARCHIVE
    [Documentation]    compression as zip archive all logs files created
    Final Zip Directory And Delete

STOP & ZIP
    [Documentation]    stop the logs & create a zip archive
    [Arguments]    ${target_id}
    Log To Console    ABD Root KW
    SET ROOT
    Log To Console    Stop Logs KW
    STOP IVI ONBOARD LOGS
    Sleep     1
    Log To Console    Make ZIP log archive KW
    MAKE ZIP LOG ARCHIVE

ENABLE IVI DEBUG LOGS
    [Arguments]    ${target_id}    ${current_tc_name}    ${micom_port}    ${bootloader_port}    ${log_to_save}
    [Documentation]    Will provide debug logs on the ${target_id} during testcase ${current_tc_name} with serial port set to
    ...         ${micom_port} for MICOM logs
    ...         ${bootloader_port} for bootloader logs
    ${enable_logs} =    Convert To Lowercase    ${enable_logs}
    OperatingSystem.Run    pkill -9 kermit
    Run Keyword if    "${enable_logs}" == "yes" or "${enable_logs}" == "${EMPTY}"   run keywords    Run Keyword if    "${console_logs}" == "yes"     Log To Console    Debug logs enabled    AND
    ...         Launch Logging    ${current_tc_name}    ${log_to_save}    ${target_id}    ${micom_port}    ${bootloader_port}
    ...         ELSE    Run Keyword if    "${console_logs}" == "yes"     Log To Console    Debug logs disabled
    DO REBOOT AND CHECK BOOT UI

RETRIEVE IVI APLOG
    [Arguments]    ${loop_folder}
    [Documentation]    Retrieve the aplog from ${ivi_adb_id}
    ...             ${loop_folder} is the name of the folder where logs are saved in reliability testcases
    SET ROOT
    ${output}   ${error}    PULL    data/misc/logd/     ${loop_folder}
    Should be empty    ${error}    Failed to pull LOGCAT logs
    Sleep     5
    ${path_content} =    List Directory    ${loop_folder}/logd
    ${logcat_list} =    Get Matches    ${path_content}    logcat.*   True    True
    FOR    ${logcat_file}    IN    @{logcat_list}[::-1]
        OperatingSystem.Run    cat ${loop_folder}/logd/${logcat_file} >> ${loop_folder}/logd/merged_logcats.txt
    END
    OperatingSystem.Run    rm -rf ${loop_folder}/logd/logcat.*
    DELETE FOLDER OR FILE    data/misc/logd/logcat.*
    Sleep     5
    OperatingSystem.Run    adb -s ${ivi_adb_id} logcat -c

RETRIEVE IVI ECS LOGS
    [Documentation]    Retrieve the ecs logs from ${ivi_adb_id}:/data/vendor/ecs
    SET ROOT
    ${output}   ${error}    PULL    data/vendor/ecs/     ${logs_top_folder}
    Should be empty    ${error}    Failed to pull ECS logs
    Sleep     5
    DELETE FOLDER OR FILE    data/vendor/ecs/*

RETRIEVE IVI APLOG LOGS
    [Documentation]    Retrieve the aplog from ${ivi_adb_id}
    ...             ${loop} is the name of the loop used in reliability testcases
    PULL    data/misc/logd/    ${logs_folder}/logd
    Sleep     5
    DELETE FOLDER OR FILE    data/misc/logd/logcat.*
    Sleep     5

STOP DEBUG LOGS
    [Arguments]    ${target_id}
    [Documentation]    Will stop the debug logs on the ${target_id}
    ${enable_logs} =    Convert To Lowercase    ${enable_logs}
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    STOP & ZIP KW
    Run Keyword if    "${enable_logs}" == "yes" or "${enable_logs}" == "${EMPTY}"    STOP & ZIP    ${target_id}
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    Elliminated at the end of stop debug logs

PUSH DLT LOGS CONF TO IVC
    [Arguments]    ${src_folder}    ${destination}
    [Documentation]    Push the dlt conf file to /mnt/mmc on the device
    ...             ${src_folder} source folder
    ...             ${destination} destination folder
    SYSTEM SEND FILE TO DEVICE    ${src_folder}    ${destination}

REMOVE DLT CONF ON IVC
    DELETE FILES ON IVC     /mnt/mmc/logs    dlt_logstorage.conf
    Sleep    2

RETRIEVE IVI DMESG
    [Arguments]    ${ivi_adb_id}    ${loop}=1
    [Documentation]    RETRIEVE IVI DMESG log from the device ${ivi_adb_id}
    DELETE FOLDER OR FILE    data/dmesg_*
    EXPORT DMESG TO FILE    ${loop}
    Sleep     2
    ${loop_folder} =    Set variable    ${local_logs_folder}/${current_tc_name}/loop_${loop}
    PULL    data/dmesg_${loop}.log    ${loop_folder}
    Sleep     2

RETRIEVE IVI DMESG LOGS
    [Documentation]    RETRIEVE IVI DMESG log from the device ${ivi_adb_id}
    ${output} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell dmesg
    Sleep     2
    OperatingSystem.Create File    ${logs_folder}/ivi_dmesg.txt    ${output}

RETRIEVE IVC DMESG
    [Arguments]    ${loop}=1
    [Documentation]    Retrieve the IVC dmesg log from the device
    ${verdict}    ${comment} =    PULL DMESG    ${logs_folder}
    # Should Be True    ${verdict}    Failed to PULL DMESG: ${comment}
    Sleep     2
    OperatingSystem.Move File    ${logs_folder}/dmesg.txt    ${logs_folder}/ivc_dmesg.txt

REMOVE DEBUG LOGS FOLDER
    [Arguments]    ${name_of_testcase}=${None}
    [Documentation]    Remove the folder if TC already run
    ${shared_volume_status} =    Run Keyword And Return Status    Directory Should Exist    ${shared_volume_path}
    ${logs_folder_to_rm} =    Set Variable If    "${shared_volume_status}" == "True"    ${shared_volume_path}/${local_logs_folder}    ${local_logs_folder}
    Run Keyword if    "${name_of_testcase}" != "${None}"    OperatingSystem.Run    rm -rf ${logs_folder_to_rm}/${name_of_testcase}/
    ...         ELSE    OperatingSystem.Run    rm -rf ${logs_folder_to_rm}

SET PROP APLOG
    [Documentation]  Enable the aplog on the device
    [Arguments]    ${ivi_adb_id}
    ENABLE APLOG

CHECK KERNEL PANIC
    [Documentation]  Check that current boot reason is not set to kernel_panic
    [Arguments]    ${current_testcase}   ${loop}    ${target_id}
    ADB_SET_ROOT
    ${status} =    kernel panic logging    ${current_testcase}    ${loop}    ${target_id}
    [return]    ${status}

GET DLT LOGS SAVE
    [Documentation]    Save the DLT logs to the path specified
    [Arguments]    ${save_to_path}
    OperatingSystem.Run    rm -rf ${save_to_path}/logs.dlt
    OperatingSystem.Run    cp -rf ./logs.dlt ${save_to_path}
    Log To Console    DLT logs saved to: ${save_to_path}

START DLT LOGGING
    [Documentation]   Start dlt receive thread, setting up string to search from unsorted/dlt_data.yaml
    ...               Variable definition: ivc_dlt_app => The name of the entry in dlt_data.yaml
    [Arguments]       ${ivc_dlt_app}=${None}    ${folder}=${NONE}    ${file_name}=logs.dlt    ${ocurrence}=1    ${regex_value}=${ivc_dlt_regex}

    START DLT MONITOR    folder=${folder}    file_name=${file_name}    regex=${regex_value}

    Run Keyword if    "${ivc_dlt_app}" == "${None}"    Return From Keyword

    @{test_configuration} =   Create List
    Set Suite Variable   @{test_configuration}

    FOR  ${item}   IN    @{dlt_receive["${ivc_dlt_app}"]}
         @{element} =   Create List
         ${trigger} =   Replace Variables    ${item[0]}
         APPEND TO LIST   ${element}    ${trigger}    ${item[1]}
         APPEND TO LIST   ${test_configuration}   ${element}
         SET DLT TRIGGER    ${trigger}    ${ocurrence}
    END
    START ANALYZING DLT DATA

WAIT DLT MESSAGE
    [Documentation]   Wait until messages previously setted have been triggered
    [Arguments]     ${timeout}=120

    ${currentDate} =   DateTime.Get Current Date    result_format=%s    exclude_millis=True
    ${endDate} =    Evaluate  ${currentDate}+${timeout}

    ${computed_verdict} =   Set Variable    ${True}
    ${remaining_timeout} =  Set Variable    ${timeout}
    FOR  ${trigger}   IN    @{test_configuration}
        ${currentDate} =   DateTime.Get Current Date    result_format=%s    exclude_millis=True
        ${remaining_timeout} =   Evaluate    ${endDate}-${currentDate}
        ${remaining_timeout} =   Set Variable If   ${remaining_timeout}<=${0}    ${1}    ${remaining_timeout}

        ${v}    ${comment} =    rfw_libraries.logmon.DltMonitor.WAIT FOR DLT TRIGGER    ${trigger[0]}    timeout=${remaining_timeout}

        Run Keyword If    ${v} != ${trigger[1]}    Log   Failed to get ${trigger[0]} in ${timeout}s
        ${computed_verdict} =   Set Variable If   ${v} != ${trigger[1]}   ${False}    ${computed_verdict}
    END

    Should Be True   ${computed_verdict}

STOP DLT LOGGING
    [Documentation]   Clean up DLT settings
    STOP ANALYZING DLT DATA
    STOP DLT MONITOR

GET ASCII LOGS FROM IVC
    [Documentation]    Pull ascii logs from IVC
    ...    string: local_path: local path for file
    ...    string: ivc_log_path: ivc path for ASCII file
    [Arguments]    ${ivc_log_path}=/home/root/logs.txt    ${local_path}=/tmp/logs.txt
    Sleep    15
    ${verdict}    ${comment} =    CONVERT DLT TO ASCII
    Should Be True    ${verdict}    Failed to CONVERT DLT TO ASCII: ${comment}
    SYSTEM GET FILE FROM DEVICE    ${ivc_log_path}    ${local_path}

CONFIGURE DLT LOGGING
    [Arguments]    ${artifactory_path}=matrix/artifacts/pnp/DLT_conf/DEFAULT/
    [Documentation]    Configure dlt_logstorage.conf with the desired config
    ...    string: artifactory_path: path to the desired config
    ${dlt_conf_file}=     Set Variable       dlt_logstorage.conf
    DOWNLOAD ARTIFACTORY FILE    ${artifactory_path}${dlt_conf_file}    ${FALSE}
    SYSTEM SEND FILE TO DEVICE    ${dlt_conf_file}    ${destination_folder}${dlt_conf_file}
    Sleep    15

GET TIMESTAMP FROM MESSAGE
    [Arguments]    ${event_to_search}    ${filepath}=/tmp/logs.txt
    [Documentation]   Returns timestamp for an event in ASCII logs
    ...   string: event_to_search: string to search for in a given file
    ...   string: filepath: path to local ASCII log
    ${message_line}=    GET LINE FROM ASCII LOG    ${event_to_search}    ${filepath}
    ${time}=    GET TIMESTAMP FROM LINE    ${message_line}
    [Return]    ${time}

CALCULATE TIMING BETWEEN EVENTS
    [Arguments]    ${event1}    ${event2}    ${event1_type}=msg    ${event2_type}=msg    ${type1}=req    ${type2}=resp    ${offset}=0    ${file_path}=/tmp/logs.txt
    [Documentation]    Return the time difference between the timestamps of two events from a log file
    ...                ${event1} and ${event2} are the strings to be searched for in the log file
    ...                ${event1_type} and ${event2_type} are the type of events that will be considered (msg: normal log message, mqtt: MQTT message)
    ...                ${type1} and ${type2} indicate the direction of MQTT message (req: request, resp: response)
    ...                ${offset} is used to alter the result by adding/subtracting  the given value
    ...                ${file_path} indicates the path and the name of the log file
    GET ASCII LOGS FROM IVC
    ${timestamp1}=    Run Keyword If    '${event1_type}' == 'msg'    GET TIMESTAMP FROM MESSAGE    ${event1}    ${file_path}
    ...    ELSE IF    '${event1_type}' == 'mqtt'    GET TIMESTAMP FROM MQTT    ${event1}    ${type1}    ${file_path}
    ...    ELSE    Return from keyword    Wrong event1 type!
    ${timestamp2}=    Run Keyword If    '${event2_type}' == 'msg'    GET TIMESTAMP FROM MESSAGE    ${event2}    ${file_path}
    ...    ELSE IF    '${event2_type}' == 'mqtt'    GET TIMESTAMP FROM MQTT    ${event2}    ${type2}    ${file_path}
    ...    ELSE    Return from keyword    Wrong event2 type!
    ${result}=    Evaluate    ${timestamp2} - ${timestamp1} + ${offset}
    [Return]    ${result}

GET LINE FROM ASCII LOG
    [Documentation]    Returns the line containg the message from a log, based on a given event (strings)
    ...    string: event: String to serch for
    ...    string: path: path to the file
    [Arguments]    ${event}    ${path}=/tmp/logs.txt
    ${matched_line}=    Set Variable    ${None}
    @{event_list}=    Split String    ${event}
    ${rc}    ${line} =    Run And Return Rc And Output    cat ${path} | grep '${event_list[0]}'
    @{lines}=    Split to lines    ${line}
    FOR    ${line}    IN    @{lines}
        ${verdict}=    LIST IN STRING    ${line}    ${event}
        ${matched_line}=    Run Keyword If    ${verdict} == True    Remove String    ${line}    "    '
        Exit For Loop If   ${verdict} == True
    END
    [Return]    ${matched_line}

GET ALL MATCHED LINES FROM ASCII LOG
    [Documentation]    Returns all mached lines containg the message from a log, based on a given event (strings)
    ...    string: event: String to serch for
    ...    string: path: path to the file
    [Arguments]    ${event}    ${path}=/tmp/logs.txt
    @{event_list}=    Split String    ${event}
    @{matched_lines} =    Create List
    ${rc}    ${line} =    Run And Return Rc And Output    cat ${path} | grep '${event_list[0]}'
    @{lines}=    Split to lines    ${line}
    FOR    ${line}    IN    @{lines}
        ${verdict}=    LIST IN STRING    ${line}    ${event}
        ${matched_line}=    Set Variable If   ${verdict} == True    ${line}
        Run Keyword If    '${matched_line}' != '${None}'    Append To List    ${matched_lines}   ${matched_line}
    END
    [Return]    ${matched_lines}

GET TIMESTAMP FROM LINE
    [Documentation]    Return the timestamp for a given message
    ...    string: message: line of text from an ascii log
    [Arguments]    ${message}
    @{string_to_list}=    Split String    ${message}
    ${timestamp} =    Get From List    ${string_to_list}    3
    [Return]    ${timestamp}

GET DISPLAYED TIME FROM LINE
    [Documentation]    Retrieve an application displayed time from a log and convert it into a computable number
    ...    ${log}: logcat log
    ...    ${appActivity}: main activity of the searched application
    [Arguments]    ${log}    ${appActivity}
    ${line}=    GET LINE FROM ASCII LOG    Displayed ${appActivity}    ${log}
    ${displayed_time}=    Fetch from right    ${line}    ${appActivity}
    ${displayed_time}=    Replace String    ${displayed_time}    :    ${EMPTY}
    ${displayed_time}=    Replace String    ${displayed_time}    +    ${EMPTY}
    ${displayed_time}=    Replace String    ${displayed_time}    '    ${EMPTY}
    ${displayed_time}=    DateTime.Convert Time    ${displayed_time}
    [Return]    ${displayed_time}

GET TIME FROM LINE
    [Documentation]    Return the time for a given message
    ...    string: message: line of text from an ascii log
    [Arguments]    ${message}   ${column}=1
    @{string_to_list}=    Split String    ${message}
    ${time} =    Get From List    ${string_to_list}    ${column}
    [Return]    ${time}

LIST IN STRING
    [Documentation]    Search in string for multipe strings
    ...    string: message: line of text from ascii log
    ...    string: list: strings to search for in message
    [Arguments]    ${message}    ${list}
    ${message}=    Remove String    ${message}    "    '
    @{lst}=    Split String    ${list}
    FOR    ${elem}    IN    @{lst}
        ${verdict}=    Set Variable If     """${elem}""" in """${message}"""    True    False
        Exit For Loop If    """${elem}""" not in """${message}"""
    END
    [Return]    ${verdict}

GET TIMESTAMP FROM MQTT
    [Documentation]   Return the timestamp of the MQTT message attached to a given message
    ...    string: event: string to search for
    ...    string: type: mqtt type request | response. Supported input: req | resp
    ...    string: file_path: indicates the path and the name of the log file
    [Arguments]    ${event}    ${type}    ${file_path}
    ${message_line}=    GET LINE FROM ASCII LOG    ${event}    ${file_path}
    ${message_timestamp}=    GET TIMESTAMP FROM LINE    ${message_line}
    ${mqtt_string}=    Set Variable If    '${type}'=='req'    strings ${file_path} | ${cmd_extract_MQTT_req}
    ...    '${type}'=='resp'    strings ${file_path} | ${cmd_extract_MQTT_resp}
    ${mqtt_words_list}=    Set Variable If    '${type}'=='req'    ${mqtt_vnext_to_ivc}
    ...    '${type}'=='resp'    ${mqtt_ivc_to_vnext}
    ${rc}    ${contents}=    Run And Return Rc And Output    ${mqtt_string}
    @{contents_lines}=    Split to lines    ${contents}
    @{mqtt_list}=    Create List
    FOR    ${line}    IN    @{contents_lines}
        ${verdict}=    LIST IN STRING   ${line}    ${mqtt_words_list}
        Continue For Loop If    '${verdict}'=='False'
        ${line_timestamp}=    GET TIMESTAMP FROM LINE    ${line}
        Run Keyword If    '${type}' == 'req' and ${line_timestamp} < ${message_timestamp}   Append To List    ${mqtt_list}    ${line}
        ...    ELSE IF    '${type}' == 'resp' and ${line_timestamp} > ${message_timestamp}   Append To List    ${mqtt_list}    ${line}
        ...    ELSE    Log    MQTT associated with timestamp ${line_timestamp} does not meet the requirements.    level=INFO
    END
    ${mqtt_selector}=    Set Variable If    "${type}" == "req"    -1    0
    ${mqtt_timestamp}=    Run Keyword Unless    len(${mqtt_list}) == 0    GET TIMESTAMP FROM LINE    ${mqtt_list}[${mqtt_selector}]
    [Return]    ${mqtt_timestamp}

COMPUTE STATISTICS
    [Arguments]       ${value_list}
    [Documentation]   Compute the median, the average, the max, the min,
    ...               and the standard deviation values of a value list.
    ${median} =    GET MEDIAN VALUE    ${value_list}
    ${average} =   GET AVERAGE VALUE   ${value_list}
    ${stdev} =     GET STDDEV VALUE    ${value_list}
    ${max} =       GET MAX VALUE       ${value_list}
    ${min} =       GET MIN VALUE       ${value_list}
    &{retval} =    Create Dictionary   median=${median}
    ...                                average=${average}
    ...                                stdev=${stdev}
    ...                                max=${max}
    ...                                min=${min}
    [Return]    ${retval}

COMPARE TARGET
    [Arguments]    ${target_file}     ${value}    ${net_type}=${None}
    [Documentation]   Retrieve an expected target 'value' (or 'range') and the associated
    ...               'operande' from a pnp file storage and compare it with the Parameter
    ...               {value}.

    ${file} =  Get File    ${target_file}
    ${dict} =  Convert to Dictionary   ${file}

    ${my_feature_id} =    Run Keyword If    "AIVC" in "${target_file}"    Set variable    ${ivc_my_feature_id}
    ...    ELSE IF    "AIVI" in "${target_file}"    Set variable     ${ivi_my_feature_id}
    ...    ELSE    FAIL    The ${target_file} is wrong. Check the path or file name.

    FOR    ${item}    IN    @{dict}[kpis]
        IF    "${item}[ID]" == "${TEST_NAME}"
            IF   "${my_feature_id}" in ${item}[data]
                ${target_obj} =   Set Variable   ${item}[data][${my_feature_id}]
                Exit For Loop
            ELSE IF    "any_MyFx" in ${item}[data]
                ${target_obj} =   Set Variable   ${item}[data][any_MyFx]
                Exit For Loop
            ELSE
                Log To Console    No target found for ${item}[ID]
                Return From Keyword    False
            END
        END
    END
    IF    "${net_type}" != "${None}"
        ${tc_target} =    Set Variable    ${target_obj}[target_${net_type}]
    ELSE
        ${tc_target} =    Set Variable    ${target_obj}[target]
    END

    ${tc_tol} =    Set Variable     ${target_obj}[tolerance]
    ${tc_toltype} =    Set Variable     ${target_obj}[tolerance_type]
    ${tc_type} =    Set Variable    ${target_obj}[type]

    IF    "${tc_toltype}" == "%"
        ${target_min} =     Evaluate    ${tc_target} * (1 - ${tc_tol} / 100)
        ${target_max} =     Evaluate    ${tc_target} * (1 + ${tc_tol} / 100)
    ELSE
        Log To Console    Tolerance type ${tc_toltype} not implemented
        Return From Keyword    False
    END

    IF    "${tc_type}" == "at_most"
        ${target_min} =    Set Variable    0
    ELSE IF    "${tc_type}" != ""
        Log To Console    Tolerance ${tc_type} not implemented
        Return From Keyword    False
    END

    ${verdict} =    Set Variable If    ${target_min} <= ${value} <= ${target_max}    True    False
    Set Suite Variable    ${compare_target_max}    ${target_max}
    Should be True    ${verdict}    Target for ${value} not reached: not in [${target_min}, ${target_max}]

CLEAR LOGCAT
    Sleep    1

DO ANALYZE SOMEIP LOGCAT
    [Documentation]    To analyze some-ip traces in the logcat
    Log To Console    DO ANALYZE SOMEIP LOGCAT
    WAIT FOR LOGCAT TRIGGER    message=${availability_call_back}    timeout=${1}
    WAIT FOR LOGCAT TRIGGER    message=${config_get_request}    timeout=${1}
    WAIT FOR LOGCAT TRIGGER    message=${config_get_response}    timeout=${1}
    WAIT FOR LOGCAT TRIGGER    message=${maintenance_info_request}    timeout=${1}

DO ANALYSE LOGCAT
    [Arguments]    ${searchstring}    ${to_delete}
    [Documentation]    To check for string in Logcat log
    ${ret_value} =    CHECK FOR TEXT LOGCAT    ${searchstring}    ${to_delete}
    Should Be True    ${ret_value}    Not able to find the string from logcat log

DO ANALYZE IDLE LOGCATSTAT
    [Arguments]    ${idle_logcat}    ${duration}
    [Documentation]    Analyze idle state logcat
    ...    ${idle_logcat} The output of logcat-stat.py script
    ...    ${duration} The duraton for which the logcat is captured
    Log To Console    Analyze idle state logcat
    ${status} =    Set Variable    True
    Log    ${idle_logcat}${\n}${\n}    console=True
    Should Contain    ${idle_logcat}    Main contributors    Failed to generate logcat
    Should Contain    ${idle_logcat}    | Total    Throughput not calulated
    @{lines} =    Split To Lines    ${idle_logcat}
    # Throughput verification
    FOR    ${line}    IN    @{lines}
        Continue For Loop If    "| Total" not in "${line}"
        @{total_values} =    Split String    ${line}    |
        ${throughput} =    Get From List    ${total_values}    2
        ${throughput} =    Convert To Number    ${throughput}
        ${throughput_res} =    Evaluate    ${throughput} < ${20.0}
        ${status} =    Set Variable If    "${throughput_res}" == "${False}"    False    ${status}
        Exit For Loop
    END
    # Logmarker verification
    &{logmarker_failures} =    Create Dictionary
    @{main_contributors} =    Split String    ${idle_logcat}    Occurences
    ${main_contributors} =    Get From List    ${main_contributors}    1
    @{main_contributors} =    Split To Lines    ${main_contributors}
    @{main_contributors} =    Get Slice From List    ${main_contributors}    1
    FOR    ${main_contributor}    IN    @{main_contributors}
        @{main_contributor_list} =    Split String    ${main_contributor}    |
        ${log_marker} =    Get From List    ${main_contributor_list}    1
        ${occurences} =    Get From List    ${main_contributor_list}    2
        ${occurences} =    Convert To Number    ${occurences}
        ${occs_per_sec_per_cont} =    Evaluate    ${occurences} / ${duration}
        ${occs_per_sec_per_cont} =    Convert To Number    ${occs_per_sec_per_cont}
        ${good_occs_per_sec_per_cont} =    Evaluate    ${occs_per_sec_per_cont} < 5.0
        ${status} =    Set Variable If    "${good_occs_per_sec_per_cont}" == "${False}"    False    ${status}
        Run Keyword If    "${good_occs_per_sec_per_cont}" == "False"    Set To Dictionary    ${logmarker_failures}    ${log_marker}    ${occs_per_sec_per_cont}
    END
    [Return]    ${status}    ${${throughput}}    ${logmarker_failures}

DO ANALYZE BTN LATENCY
    [Arguments]    ${csv_file}
    [Documentation]    Analyze the Btn Latency from csv file
    ...    ${csv_file} The csv file name with path
    ${status} =    Set Variable    True
	${contents}=    Get File    ${csv_file}
	Log    ${contents}
    @{lines} =    Split to lines    ${contents}
    @{lines} =    Get Slice From List    ${lines}    1
    @{btn_latencies} =    Create List
    FOR    ${line}    IN    @{lines}
        Exit For Loop If    "${line}"==""
        Append To List    ${btn_latencies}    ${line}
    END
    Log List    ${btn_latencies}
    @{btn_latencies_exceeded} =    Create List
    FOR    ${btn_latency}    IN    @{btn_latencies}
        @{latency_line} =    Split String    ${btn_latency}    separator=,
        ${btn} =     Get From List    ${latency_line}    0
        ${latency} =     Get From List    ${latency_line}    1
        ${success_rate} =     Get From List    ${latency_line}    -1
        @{success_rate} =    Split String    ${success_rate}    /
        ${success_rate} =     Get From List    ${success_rate}    0
        ${success_rate} =    Convert To Number    ${success_rate}
        ${success_rate} =    Evaluate    ${success_rate} != ${0}
        ${latency_value} =    Run Keyword If    "${latency}" != " ?"    Convert To Number    ${latency}
        ${latency_status} =    Run Keyword If    "${latency}" != " ?"    Evaluate    ${latency_value} <= ${100}
        ${status} =    Set Variable If    ${latency_status} == False or ${latency_status} == ${None}    False    ${status}
        ${status} =    Set Variable If    ${success_rate} == False    False    ${status}
        Run Keyword If    ${latency_status} == False or ${latency_status} == ${None} or ${success_rate} == False    Append To List    ${btn_latencies_exceeded}    ${btn_latency}
    END
    [Return]    ${status}    ${btn_latencies_exceeded}

ADB SET LOG LEVEL
    [Arguments]    ${log_level}    ${log_tag}=${EMPTY}
    [Documentation]    Set the logcat log level for an adb device
    ...    ${log_level}: FATAL | ERROR | WARN | INFO | DEBUG | VERBOSE
    ...    ${log_tag}: logcat tag name
    Log To Console    ADB SET LOG LEVEL
    Run Keyword If    "${log_tag}"!="${EMPTY}"    SET PROP    log.tag.${log_tag}    ${log_level}
    ...    ELSE    SET PROP    log.tag    ${log_level}

LOG MEASUREMENT
    [Arguments]       ${value_list}
    [Documentation]    Log the measurement values list that is passed as argument
    ${rlog_file} =    LOG MEASUREMENTS    ${TEST_NAME}    ${value_list}
    [Return]    ${rlog_file}

START TCPDUMP ON IVI
    [Documentation]  Start tcpdump on ecu and send pcap packets to file
    [Arguments]     ${file_path}=${tcpdump_ivi_path}${tcpdump_ivi_file}     ${interface}=any
    rfw_services.ivi.SystemLib.START TCPDUMP    ${interface}     ${file_path}

STOP TCPDUMP ON IVI
    [Documentation]  Stop tcpdump logging on ecu
    [Arguments]    ${file_path}=${tcpdump_ivi_path}    ${file_name}=${tcpdump_ivi_file}
    rfw_services.ivi.SystemLib.KILL TCPDUMP
    PULL    ${file_path}${file_name}    ${logs_folder}/${tcpdump_ivi_file}
    ${output} =    SET DELETE FILE    ${file_path}    ${file_name}

START DLT CONVERSION
    [Documentation]    Uses dlt convert to search for triggers, setting up string to search from unsorted/dlt_data.yaml
    ...               Variable definition: conf => The name of the entry in dlt_data.yaml
    [Arguments]       ${conf}=${None}    ${ocurrence}=1    ${timeout}=${300}

    Run Keyword if    "${conf}" == "${None}"    Return From Keyword

    @{test_configuration_dlt_convert} =   Create List
    Set Suite Variable   @{test_configuration_dlt_convert}

    FOR  ${item}   IN    @{dlt_receive["${conf}"]}
         @{element} =   Create List
         ${trigger} =   Replace Variables    ${item[0]}
         APPEND TO LIST   ${element}    ${trigger}    ${item[1]}
         APPEND TO LIST   ${test_configuration_dlt_convert}   ${element}
         SET DLT TRIGGER    ${trigger}    ${ocurrence}
    END
    # retrieve offline logs from IVC in the offline logs directory
    ${offline_logs_folder} =    Set variable    offline_dlt_logs/
    Remove Directory    ${offline_logs_folder}/logs	    recursive=True
    Create Directory    ${offline_logs_folder}
    Run Keyword If    "${TC_folder}"!="RELIABILITY"    SYSTEM GET FILE FROM DEVICE    /mnt/mmc/logs/    ${offline_logs_folder}
    Run Keyword If    "${TC_folder}"=="RELIABILITY"    SYSTEM GET FILE FROM DEVICE    /mnt/mmc/logs/    ${loop_folder}
    START ANALYZING DLT DATA
    Run Keyword If    "${TC_folder}"!="RELIABILITY"     LOAD DLT DIRECTORY    ${offline_logs_folder}/logs
    Run Keyword If    "${TC_folder}"=="RELIABILITY"     LOAD DLT DIRECTORY    ${loop_folder}/logs
    ${computed_verdict} =   Set Variable    ${True}
    ${remaining_timeout} =  Set Variable    ${timeout}
    FOR  ${trigger}   IN    @{test_configuration_dlt_convert}
        ${v}    ${c} =    rfw_libraries.logmon.DltMonitor.WAIT FOR DLT TRIGGER    ${trigger[0]}    timeout=${remaining_timeout}
        Run Keyword If    ${v} != ${trigger[1]}    Log   Failed to get ${trigger[0]} in ${remaining_timeout}
        ${computed_verdict} =   Set Variable If   ${v} != ${trigger[1]}   ${False}    ${computed_verdict}
    END
    Run Keyword If    "${TC_folder}"!="RELIABILITY"    Should Be True   ${computed_verdict}    ${c}
    [Return]    ${v}    ${c}

START TCPDUMP ON IVC
    [Documentation]    This KW initializes the TCP dump logging on the IVC. It retrieves the
    ...               tcpdump.init file from artifactory
    [Arguments]       ${tcp_init_url_path}=matrix/artifacts/reliability
    IF    '${ivc_build_type}' == 'user'
        Return From Keyword
    END

    ${tcpdump_file} =    Set Variable If    '${sweet400_bench_type}' in "'${tc_config}[bench_type]'"    tcpdump_sweet400.init    tcpdump.init

    DOWNLOAD FILE FROM ARTIFACTORY    ${tcp_init_url_path}/${tcpdump_file}
    Sleep   2
    SYSTEM SEND FILE TO DEVICE        ./${tcpdump_file}    /mnt/mmc/tcpdump.init

    rfw_services.wicket.DebugToolsLib.INIT TCP DUMP
    rfw_services.wicket.DebugToolsLib.REMOVE PCAP FILES
    ${verdict}    ${output} =    rfw_services.wicket.DebugToolsLib.START TCP DUMP
    # Should Be True    ${verdict}    Failed to START TCP DUMP ON IVC: ${output}

STOP TCPDUMP ON IVC
    [Documentation]    Stop the tcpdump by removing the symbolic link, revoke the rights for
    ...                tcpdump.init file and delete the pcap files
    ${verdict}    ${output} =    rfw_services.wicket.DebugToolsLib.STOP TCP DUMP
    # Should Be True    ${verdict}    Failed to STOP TCP DUMP: ${output}
    SYSTEM GET FILE FROM DEVICE    /mnt/mmc/logs/tcp_traffic_all.pcap    ${logs_folder}/ivc_tcpdump.pcap
    IF    '${sweet400_bench_type}' in "'${tc_config}[bench_type]'"
        SYSTEM GET FILE FROM DEVICE    /mnt/mmc/logs/tcp_traffic_remotes.pcap    ${logs_folder}/ivc_tcpdump_remotes.pcap
    END
    rfw_services.wicket.DebugToolsLib.REMOVE PCAP FILES

REMOVE PCAP FILES ON IVC
    [Documentation]    remove the TCP dump files from the ivc (tcap files)
    ${verdict}    ${output} =    rfw_services.wicket.DebugToolsLib.REMOVE PCAP FILES
    Should Be True    ${verdict}    Failed to REMOVE PCAP FILES: ${output}

REMOVE IVI DROPBOX CRASHES
    [Arguments]    ${ivi_adb_id}
    [Documentation]    Remove the dropbox crashes from ${ivi_adb_id}
    SET ROOT
    Sleep    3
    DELETE FOLDER OR FILE    data/system/dropbox/*
    Sleep   5

SAVE IVI DROPBOX CRASHES
    [Arguments]    ${ivi_adb_id}
    [Documentation]    Save the dropbox crashes from ${ivi_adb_id}
    SET ROOT
    Sleep    3
    ${loop_folder} =    Set variable    ${logs_top_folder}/dropbox_crashes
    PULL    data/system/dropbox/     ${loop_folder}

CHECK IVI LOGCAT PROP
    [Arguments]    ${search_text}
    [Documentation]    Check string ${search_text} in logcat
    ${output} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell logcat -t 10000000 -d getprop | grep -i ${search_text} | head -1
    Run Keyword If    ${output} == b''    Fail    No message found in logcat of ${search_text}
    ...    ELSE    Should Not Be Empty    ${output}    No message found in logcat of ${search_text}

START LOGCAT MONITOR
    [Documentation]    Starts a LogCat Monitor thread ("LOGCAT_RECEIVE") and begins piping logcat messages to the queue
    ...                If save_logs=False, no logs will be saved.
    ...                Otherwise a log file containing the logcat datastream will be saved to the
    ...                'logmonitor_logs' folder by default.
    ...                The filename is auto-generated based on the logmon name and timestamp
    ...                For example:  '/logmonitor_logs/LOGCAT_RECEIVE_20210312_113023.log'
    ...                Configure ${folder} and/or ${file_name} to choose a custom file path.
    [Arguments]        ${device}    ${save_logs}=${True}    ${regex}=${False}    ${folder}=${None}   ${file_name}=${None}
    &{options} =    Create Dictionary    -b=events,main,system
    ${verdict}    ${output} =    rfw_libraries.logmon.LogCatMonitor.START LOGCAT MONITOR   device=${device}    folder=${folder}    file_name=${file_name}    save_logs=${save_logs}    regex=${regex}    options=${options}
    Should Be True    ${verdict}    Failed to start LogCat Monitor: ${output}

WAIT FOR PCAP TRIGGER
    [Documentation]   Wait for a triggered pcap message
    [Arguments]     ${message}    ${timeout}=${30}
    ${verdict}    ${output} =    rfw_libraries.logmon.PcapMonitor.WAIT FOR PCAP TRIGGER    ${message}     ${timeout}
    Should Be True    ${verdict}    Message ${message} not found!

WAIT FOR LOGCAT TRIGGER
    [Documentation]   Wait for a triggered message in real time
    [Arguments]    ${message}    ${timeout}=${60}
    ${verdict}    ${output} =   rfw_libraries.logmon.LogCatMonitor.WAIT FOR LOGCAT TRIGGER    ${message}    ${timeout}
    [Return]    ${verdict}    ${output}
    Should Be True    ${verdict}    Message ${message} not found!

INJECT LOGCAT MESSAGE
    [Documentation]   Inject a tagged message into the logcat
    [Arguments]    ${tag}    ${message_to_inject}
    rfw_services.ivi.LogsLib.INJECT LOGCAT MESSAGE    ${tag}    ${message_to_inject}
    Log to console    Message ${message_to_inject} was injected!

SET LOGCAT TRIGGER
    [Documentation]   Set a trigger message
    [Arguments]    ${message}
    ${verdict}    ${comment} =   rfw_libraries.logmon.LogCatMonitor.SET LOGCAT TRIGGER    ${message}
    Should Be True    ${verdict}    ${comment}

START ANALYZING LOGCAT DATA
    [Documentation]   Start queueing and analyzing the data, monitoring for specified triggers
    ${verdict}    ${comment} =   rfw_libraries.logmon.LogCatMonitor.START ANALYZING LOGCAT DATA
    Should Be True    ${verdict}    ${comment}

STOP ANALYZING LOGCAT DATA
    [Documentation]   Stops logcat data analysis, triggers are automatically removed
    ${verdict}    ${comment} =   rfw_libraries.logmon.LogCatMonitor.STOP ANALYZING LOGCAT DATA
    Should Be True    ${verdict}    ${comment}

EXTRACT TIMESTAMP FROM LOGMON
    [Documentation]    Return the timestamp extracted from a logmon return message
    [Arguments]    ${message}
    ${msg} =    Convert To String    ${message}
    @{datetime_msg_raw} =    Split String    ${msg}    [
    ${datetime_msg} =    Remove String    ${datetime_msg_raw}[-1]    '    ]
    ${datetime_msg} =    Get Substring    ${datetime_msg}    0    23
    [Return]    ${datetime_msg}

INJECT DLT MESSAGE
    [Documentation]   Inject a tagged message into the dlt log
    [Arguments]    ${AppID}    ${ConextID}    ${ServiceID}    ${message_to_inject}
    ${verdict} =    rfw_libraries.dlt.DltControl.DltControl.SEND INJECT MSG    ${AppID}    ${ConextID}    ${ServiceID}    ${message_to_inject}
    Log to console    Message ${message_to_inject} injected with verdict ${verdict}!

DO START LOGCAT LOG
    [Documentation]    To start the logcat logs
    ${ret_value} =    START LOGCAT LOG
    Should Be True    ${ret_value}    Not able to start the logcat log

DO KILL LOGCAT PROCESS
    [Arguments]  ${process_name}
    [Documentation]    To stop the logcat logs
    ...    ${process_name}: the process to kill
    KILL PROCESS    ${process_name}

SAVE CANDUMP LOGS
    [Documentation]    Save candump logs using logmon
    [Arguments]    ${logmon_folder}    ${var}
    ${verdict}    ${comment} =    SWITCH CANDUMP LOG    ${logmon_folder}    candump_loop_${var}
    Should be True    ${verdict}    ${comment}

START CAN LOGS
    [Arguments]    ${logs_folder}=${logs_folder}
    [Documentation]    This kw is used until logging is enabled
    @{ifaces} =    create list
    IF    '${sweet400_bench_type}' in "'${tc_config}[bench_type]'"
        Append to list    ${ifaces}    can0    can1    can2    can3    can4    can5
    ELSE
        Append to list    ${ifaces}    slcan0
        IF    '${ivi_bench_type}' in "'${tc_config}[bench_type]'" or '${ccs2_bench_type}' in "'${tc_config}[bench_type]'"
            Append to list    ${ifaces}    slcan1
        END
    END
    # Log To Console    Enable Candump Monitor
    SET CANDUMP CONFIG   ${ifaces}
    ${verdict}    ${comment} =    START CANDUMP MONITOR    folder=${logs_folder}    file_name=bench_candump    save_logs=${save_logs_files}
    Should be True    ${verdict}    ${comment}

STOP CAN LOGS
    [Documentation]    This kw is used until logging is enabled
    # Log To Console    Disable Candump Monitor
    ${verdict}    ${comment} =    STOP CANDUMP MONITOR
    Should be True    ${verdict}    ${comment}

START LOGCAT LOGGING
    [Documentation]   Start logcat receive thread, setting up string to search
    ...               Variable definition: locat_trigger => A list with the strings to search in ivi logs
    [Arguments]       @{logcat_triggers}    ${device}=${ivi_adb_id}    ${regex_value}=${FALSE}
    START LOGCAT MONITOR    device=${device}    regex=${regex_value}
    FOR    ${trigger}    IN    @{logcat_triggers}
        SET LOGCAT TRIGGER    ${trigger}
    END
    START ANALYZING LOGCAT DATA

START PCAP MONITOR
    [Arguments]       ${interface}=${None}    ${pcap_filter}=${None}    ${folder}=${None}    ${file_name}=${None}    ${save_logs}=${TRUE}    ${regex}=${FALSE}
    [Documentation]   Setup the client logger, start monitoring specified interface and start sending packets to
    ...    logmon server
    ${verdict}    ${comment} =    rfw_libraries.logmon.PcapMonitor.START PCAP MONITOR    ${interface}    ${pcap_filter}    ${folder}    ${file_name}    ${save_logs}    ${regex}
    Should be True    ${verdict}    ${comment}

SET PCAP TRIGGER
    [Arguments]       ${trigger_dict}    ${occurrences}=${1}
    [Documentation]   Setup the pcap trigger to be searched
    ${verdict}    ${comment} =    rfw_libraries.logmon.PcapMonitor.SET PCAP TRIGGER    ${trigger_dict}    ${occurrences}
    Should be True    ${verdict}    ${comment}

START ANALYZING PCAP DATA
    [Documentation]   Start analyzing pcap data
    ${verdict}    ${comment} =    rfw_libraries.logmon.PcapMonitor.START ANALYZING PCAP DATA
    Should be True    ${verdict}    ${comment}

START DLT MONITOR
    [Arguments]       ${ip}=%{WICKET_HOSTNAME=192.168.33.3}    ${verbose}=${0}    ${timeout}=${120}    ${folder}=${None}    ${file_name}=${None}    ${save_logs}=${TRUE}    ${regex}=${FALSE}
    [Documentation]   Setup the client logger, start monitoring specified interface and start sending packets to
    ...    logmon server
    Run keyword if    "172.17.0.1" in """${ip}"""    SET IVI IP TABLES FOR IVC DLT LOGGING

    ${verdict}    ${comment} =  rfw_libraries.logmon.DltMonitor.START DLT MONITOR    ${ip}    ${verbose}    ${timeout}    ${folder}    ${file_name}    ${save_logs}     ${regex}
    Should Be True    ${verdict}    Failed to start DLT Monitor: ${comment}

SET DLT TRIGGER
    [Arguments]       ${message}    ${occurrences}=${1}
    [Documentation]   Setup the pcap trigger to be searched
    ${verdict}    ${comment} =    rfw_libraries.logmon.DltMonitor.SET DLT TRIGGER    ${message}    ${occurrences}
    Should be True    ${verdict}    ${comment}

START ANALYZING DLT DATA
    [Documentation]   Start analyzing dlt data
    ${verdict}    ${comment} =    rfw_libraries.logmon.DltMonitor.START ANALYZING DLT DATA
    Should be True    ${verdict}    ${comment}

WAIT FOR DLT TRIGGER
    [Arguments]       ${message}    ${timeout}=${60}
    [Documentation]   Wait for a triggered dlt message
    ${verdict}        ${comment} =    rfw_libraries.logmon.DltMonitor.WAIT FOR DLT TRIGGER    ${message}     ${timeout}
    Should Be True    ${verdict}    Message ${message} not found, with ${comment}

ENABLE BLUETOOTH HCI SNOOP LOG
    [Documentation]    == High Level Description: ==
    ...     Enable developer options and bluetooth HCI snoop log on ivi
    SET ROOT
    OperatingSystem.Run    adb -s ${ivi_adb_id} disable-verity
    DO REBOOT    ${target_id}    command line
    CHECK IVI BOOT COMPLETED    booted    120
    Run Keyword If    "${ivi_build_type}" != "userdebug"    SET ROOT
    OperatingSystem.Run    adb -s ${ivi_adb_id} remount
    OperatingSystem.Run    adb -s ${ivi_adb_id} shell rm system/etc/bluetooth/bt_stack.conf
    Sleep    1
    DELETE FOLDER OR FILE    opt/rfw/bt_stack.conf
    DOWNLOAD ARTIFACTORY FILE     matrix/artifacts/bt_stack.conf    ${FALSE}
    CHECKSET FILE PRESENT    bench    bt_stack.conf
    OperatingSystem.Run    adb -s ${ivi_adb_id} shell settings put global development_settings_enabled 1
    Sleep    2
    PUSH     bt_stack.conf    /system/etc/bluetooth/.
    DO REBOOT    ${target_id}    command line
    CHECK IVI BOOT COMPLETED    booted    120
    CREATE APPIUM DRIVER
    LAUNCH APP APPIUM    Settings
    ${result} =  APPIUM_WAIT_FOR_XPATH    //*[@text='System']    retries=10    direction=down    scroll_tries=20
    Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    //*[@text='System']
    ${result} =  APPIUM_WAIT_FOR_XPATH    //*[@text='Developer options']    retries=10    direction=down    scroll_tries=20
    Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    //*[@text='Developer options']
    Sleep    2
    ${result} =  APPIUM_WAIT_FOR_XPATH    //*[@text='Enable Bluetooth HCI snoop log']    retries=10    direction=down    scroll_tries=20
    Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    //*[@text='Enable Bluetooth HCI snoop log']
    ${result} =  APPIUM_WAIT_FOR_XPATH    //*[@text='Enabled']    retries=10
    Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    //*[@text='Enabled']
    Sleep    2
    Repeat Keyword    2 times    APPIUM_PRESS_KEYCODE   ${KEYCODE_BACK}
    Sleep    2
    SCROLL TO EXACT ELEMENT     element_id_or_xpath=//*[@text='Bluetooth']     direction=up
    APPIUM_PRESS_KEYCODE   ${KEYCODE_HOME}
    Sleep    3
    CONNECT AND DISCONNECT BLUETOOTH
    REMOVE APPIUM DRIVER

DISABLE BLUETOOTH HCI SNOOP LOG
    [Documentation]    == High Level Description: ==
    ...     Disable developer options and bluetooth HCI snoop log on ivi
    SET ROOT
    OperatingSystem.Run    adb -s ${ivi_adb_id} disable-verity
    DO REBOOT    ${target_id}    command line
    CHECK IVI BOOT COMPLETED    booted    120
    Run Keyword If    "${ivi_build_type}" != "userdebug"    SET ROOT
    OperatingSystem.Run    adb -s ${ivi_adb_id} remount
    DOWNLOAD ARTIFACTORY FILE     matrix/artifacts/reliability/bt_stack.conf    ${FALSE}
    CHECKSET FILE PRESENT    bench    bt_stack.conf
    Sleep    2
    PUSH     bt_stack.conf    /system/etc/bluetooth/.
    DELETE FOLDER OR FILE    opt/rfw/bt_stack.conf
    CREATE APPIUM DRIVER
    LAUNCH APP APPIUM    Settings
    ${result} =  APPIUM_WAIT_FOR_XPATH    //*[@text='System']    retries=10    direction=down    scroll_tries=20
    Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    //*[@text='System']
    ${result} =  APPIUM_WAIT_FOR_XPATH    //*[@text='Developer options']    retries=10    direction=down    scroll_tries=20
    Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    //*[@text='Developer options']
    Sleep    2
    ${result} =  APPIUM_WAIT_FOR_XPATH    //*[@text='Enable Bluetooth HCI snoop log']    retries=10    direction=down    scroll_tries=20
    Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    //*[@text='Enable Bluetooth HCI snoop log']
    ${result} =  APPIUM_WAIT_FOR_XPATH    //*[@text='Disabled']    retries=10
    Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    //*[@text='Disabled']
    Sleep    2
    Repeat Keyword    2 times    APPIUM_PRESS_KEYCODE   ${KEYCODE_BACK}
    Sleep     2
    APPIUM_PRESS_KEYCODE   ${KEYCODE_HOME}
    OperatingSystem.Run    adb -s ${ivi_adb_id} shell settings put global development_settings_enabled 0

RETRIEVE BLUETOOTH HCI SNOOP LOG
    [Arguments]    ${output_folder}=${logs_folder}
    [Documentation]    == High Level Description: ==
    ...     Retrieve bluetooth HCI snoop logs
    SET ROOT
    Sleep    2
    ${output_folder_status} =    Run Keyword And Return Status    Directory Should Exist    ${output_folder}
    IF    "${output_folder_status}" != "True"
        Create Directory    ${output_folder}
    END
    ${result} =    PULL    /data/misc/bluetooth/logs    ${output_folder}
    Sleep     2
    OperatingSystem.Run    adb -s ${ivi_adb_id} shell rm data/misc/bluetooth/logs/*

RESTORE DLT LOGSTORAGE DEFAULT CONFIGURATION
    [Documentation]    == High Level Description: ==
    ...     Restore DLT Offline Logstorage default configuration
    ${verdict}   ${comment} =    rfw_services.wicket.DeviceLib.WAIT FOR DEVICE    120
    Run Keyword If    "${verdict}" != "True"    Run keywords
    ...    CONFIGURE VEHICLE STUB PROFILE    only_keep_ivc_on
    ...    AND    CHECK IVC BOOT COMPLETED
    DOWNLOAD ARTIFACTORY FILE    ${restore_url_path}${restore_dlt_conf_file}    ${FALSE}
    Sleep   2
    # push dlt config file (with default level)
    SYSTEM SEND FILE TO DEVICE        ${root_dir}${restore_dlt_conf_file}    ${destination_folder}/${dlt_conf_file}

START AUDIO DUMP RAW FILES
    [Documentation]    == High Level Description: ==
    ...     Enable the generation of raw *.pcm audio files
    SET ROOT
    Sleep    2s
    OperatingSystem.Run    adb -s ${ivi_adb_id} shell setprop persist.vendor.audio.hal_dump true

RETRIEVE AND STOP AUDIO DUMP RAW FILES
    [Arguments]    ${loop}=1    ${name_of_audio_dump}=usb_audio
    [Documentation]    == High Level Description: ==
    ...     Retrieve raw *.pcm audio files
    ...     ${name_of_audio_dump}: name of the folder where the *.pcm files will be saved
    ${loop_folder} =    Set variable    ${local_logs_folder}/${current_tc_name}/loop_${loop}/${name_of_audio_dump}_pcm_files
    Create Directory    ${loop_folder}
    OperatingSystem.Run    adb -s ${ivi_adb_id} shell setprop persist.vendor.audio.hal_dump false
    Sleep    1s
    ${result} =    PULL    /data/vendor/audio/    ${loop_folder}
    Sleep    2s
    OperatingSystem.Run    adb -s ${ivi_adb_id} shell rm /data/vendor/audio/*.pcm

RESET IVI BUG REPORTS
    [Arguments]    ${ivi_adb_id}
    ${return2} =    OperatingSystem.Run    adb -s ${ivi_adb_id} logcat -b all -c
    Run Keyword If    "${return2}" == "True"    Log To Console    logcat buffers reset have been made...

DO MAKE KERNEL PANIC
    [Documentation]    == High Level Description: ==
    ...     Trigger the kernal panic using adb command
    SET ROOT
    RUN COMMAND AND CHECK RESULT    "su 0 echo c > /proc/sysrq-trigger"    ${EMPTY}

CHECK PSTORE FILE
    [Documentation]    == High Level Description: ==
    ...     Check pstore file using ADB command
    SET ROOT
    ${output} =    listing_contents    /sys/fs/pstore
    ${output} =    Convert To String    ${output}
    Should Contain    ${output}    console-ramoops-0
    Should Contain    ${output}    dmesg-ramoops-0

CHECK DROPBOX LOG FILE
    [Documentation]    == High Level Description: ==
    ...     Check dropbox file using ADB command
    SET ROOT
    ${output} =    listing_contents    /data/system/dropbox/ALLIANCE*
    ${output} =    Convert To String    ${output}
    Should Contain    ${output}    ALLIANCE_BOOT_REASON@    Log files are not found in dropbox
    Should Contain    ${output}    ALLIANCE_VUC@    Log files are not found in dropbox
    ${output} =    listing_contents    /data/system/dropbox/SYSTEM_LAST_KMSG*
    ${output} =    Convert To String    ${output}
    Should Contain    ${output}    SYSTEM_LAST_KMSG@    Log files are not found in dropbox

DELETE MEX DATABASE DATA
    [Documentation]    == High Level Description: ==
    ...     This will delete MEX database data using commands
    SET ROOT
    OperatingSystem.Run    "adb -s ${ivi_adb_id} shell rm /data/user_de/0/com.alliance.car/databases/mex"
    Run Keyword If    "${ivi_hmi_action}"=="True"    REMOVE APPIUM DRIVER
    ADB REBOOT
    Run Keyword If    "${ivi_hmi_action}"=="True"    CREATE APPIUM DRIVER

RETRIEVE IVI MEMORY INFORMATION
    [Arguments]    ${output_folder}=${logs_folder}
    [Documentation]    == High Level Description: ==
    ...     Retrieve ivi appliocations memory information
    SET ROOT
    Sleep    2s
    OperatingSystem.Run    adb -s ${ivi_adb_id} exec-out dumpsys meminfo > ${output_folder}/mem_info.txt
    Sleep    10s

RETRIEVE LOGS FROM SETUP
    [Arguments]    ${out_path}=${loop_folder}
    [Documentation]    Retrieve logs from setup in case the TC is failing in setup
    SEND CAN FRAME    OFF_STATE_TO_MMI_OFF_STATE_transition_a
    SEND CAN FRAME    MMI_OFF_STATE_TO_CHECK_WELCOME_transition_c
    SEND CAN FRAME    CHECK_WELCOME_TO_MMI_ON_Full_User_Hmi_transition_g
    ${loop_folder} =    Set variable    /rhw/debug_logs/${current_tc_name}teardown
    Create Directory    ${loop_folder}
    Set Global Variable   ${loop_folder}
    Run Keyword And Warn On Failure    CHECK IVI BOOT COMPLETED    booted    120
    Run Keyword And Warn On Failure    RETRIEVE IVI APLOG    ${loop_folder}
    Run Keyword And Warn On Failure    RETRIEVE IVI ECS LOGS
    Run Keyword And Warn On Failure    SAVE IVI DROPBOX CRASHES    ${ivi_adb_id}
    Run Keyword And Warn On Failure    EXTRACT ANDROID BUG REPORTS    ${ivi_adb_id}
    Run Keyword if    "${bluetooth_hci_snoop}" == "yes"    Run keyword And Continue On Failure    DISABLE BLUETOOTH HCI SNOOP LOG
    Run Keyword And Ignore Error    RETRIEVE IVI MEMORY INFORMATION
    Run Keyword And Warn On Failure    RETRIEVE IVI DMESG    ${ivi_adb_id}
    Run Keyword If    '${ccs2_bench_type}' in "'${bench_type}'" or '${sweet400_bench_type}' in "'${bench_type}'"    Run Keywords    Run Keyword And Warn On Failure    CHECK IVC BOOT COMPLETED
    ...     AND    Run Keyword And Warn On Failure    SYSTEM GET FILE FROM DEVICE   /mnt/mmc/logs/    ${loop_folder}
    Move Directory    ${logs_top_folder}    ${loop_folder}

ZIP FOLDER
    [Arguments]    ${folder}    ${delete_folder}=True
    OperatingSystem.Run    zip -jr ${folder}.zip ${folder}
    Run Keyword if     '${delete_folder}' == 'False'    Return From Keyword
    Remove Directory    ${folder}    recursive=True

DO INJECT SECURITY LOGS IVI
    [Documentation]   Inject a tagged message into the logcat
    [Arguments]    ${tag}    ${message_to_inject}    ${loop}=${1}     ${number_of_loops}=${101}
    FOR   ${loop}    IN RANGE	${number_of_loops}
        INJECT LOGCAT MESSAGE    ${tag}    ${message_to_inject}
    END
