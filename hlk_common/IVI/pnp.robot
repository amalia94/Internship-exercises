#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Documentation     Pnp test utility
Library           rfw_services.ivi.PnpLib    device=${ivi_adb_id}
Library           rfw_services.ivi.LogsLib    device=${ivi_adb_id}
Library           rfw_services.ivi.AndroidBluetoothLib    device=${ivi_adb_id}
Library           rfw_services.ivi.AndroidWiFiLib    device=${ivi_adb_id}
Library           rfw_services.ivi.ReliabilityCommonLib    device=${ivi_adb_id}
Library           rfw_services.power_supply.PowerSupplyLib
Library           Collections
Library           Process

*** Variables ***


*** Keywords ***

CHECK IVI CURRENT MEASUREMENT
    [Arguments]    ${periodicity}    ${time_out}    ${pw_config1}
    [Documentation]    Checking Current MEASUREMENT every ${periodicity} seconds for a total of ${time_out} seconds
    ...    ${periodicity}: Measure current with a interval
    ...    ${time_out}: Measure current for the total duration
    ...    ${pw_config1}: power supply config name
    Log To Console    Checking Current MEASUREMENT every ${periodicity} seconds for a total of ${time_out} seconds
    ${current_list} =    Create List
    ${limit} =    Evaluate    int(${time_out}/${periodicity})
    POWER SUPPLY CONFIG     ${pw_config1}
    FOR    ${var}    IN RANGE    ${limit}
        ${verdict}    ${current_result}    ${model} =    POWER SUPPLY MEASURE CURRENT    ${pw_config1}
        Should Be True    ${verdict}
        Log    Current is: ${current_result}     console=True
        ${current_result}=    Convert To Number    ${current_result}
        Append To List    ${current_list}    ${current_result}
        BuiltIn.Sleep    ${periodicity}
    END
    [Return]    ${current_list}

UPLOAD PNP COLLECT TO IVI
    [Arguments]    ${path}=/data
    [Documentation]   Upload pnp_collect binary to ivi and make it executable
    PUSH    pnp_collect    ${path}/pnp_collect
    OperatingSystem.Run    adb -s ${ivi_adb_id} shell chmod +x ${path}/pnp_collect    shell=${False}

GET PNP RESULTS FROM IVI
    [Arguments]    ${time_out}    ${source_file}=/data/pnp_panel_metrics.csv    ${destination_file}=/tmp/pnp_panel_metrics.csv
    [Documentation]   Download pnp_collect results from ivi to a destination on bench
    ...    ${time_out}: Time in milliseconds to check the keyword succeeds
    ...    ${source_file}: Path to the pnp_collect report on IVI
    ...    ${destination_file}: Download path to the pnp_collect report on localhost
    WAIT UNTIL KEYWORD SUCCEEDS    ${time_out}ms    2000ms     CHECK PROCESS RUNNING    ivi    pnp_collect    not_running
    PULL    ${source_file}    ${destination_file}
    Run Process    python3  /tmp/PNP_COLLECT/PnpViewer/pnp_viewer/pnpViewer.py  ${destination_file}  --no-ui

GET RHVS AND RCSS TIMESTAMP REQUEST RESPONSE
    [Arguments]    ${response}
    [Documentation]   Get the timestamp from Vnext response (RHVSS/RCSS)
    ...    ${response}: Response from CHECK VNEXT REQUEST RESPONSE
    ${response} =    Convert to string    ${response}
    @{time_response} =    Split String    ${response}
    ${time_response} =    Remove String    ${time_response}[-1]    }    '    ${EMPTY}
    ${words} =    Split String    ${time_response}    T
    ${date_response} =    Set Variable    ${words}[0]
    ${words} =    Split String    ${words}[1]    .
    ${time_response} =    Set Variable    ${words}[0]
    ${date_response} =    Set Variable    ${date_response}${time_response}
    ${time_response} =    Convert Date    ${date_response}    date_format=%Y-%m-%d%H:%M:%S    result_format=%Y-%m-%d %H:%M:%S
    Log To Console    Time request_response ${time_response}
    [Return]    ${time_response}

GET IVI TO VNEXT TIMESTAMP RCSS AND RHVS
    [Arguments]    ${vnext_response}
    [Documentation]   Get the timestamp from IVI to Vnext response (RHVSS/RCSS)
    ...    ${response}: Response from CHECK IVI TO VNEXT MESSAGE RCSS
    ${response} =    Convert to string    ${vnext_response}
    ${response} =    Remove String    ${response}    A compatible message
    @{time_final_sync} =    Split String    ${response}
    ${time_final_sync} =    Remove String    ${time_final_sync}[4]    }    '    ${EMPTY}
    ${words} =    Split String    ${time_final_sync}    T
    ${time_sync_converted} =    Remove String    ${words}[0]    "
    ${date_response} =    Set Variable    ${time_sync_converted}
    ${words} =    Split String    ${words}[1]    .
    ${time_final_sync} =    Set Variable    ${words}[0]
    ${date_response} =    Set Variable    ${date_response}${time_final_sync}
    ${response} =    Remove String    ${date_response}     Z
    ${time_final_sync} =    Convert Date    ${date_response}    date_format=%Y-%m-%d%H:%M:%S    result_format=%Y-%m-%d %H:%M:%S
    Log To Console    Time final_sync: ${time_final_sync}
    [Return]    ${time_final_sync}

START IPERF ON IVI
    [Arguments]    ${host}    ${port}    ${duration}=10    ${throughput}=10m    ${interval}=1    ${direction}=-R    ${protocol}=UDP    ${logfile}=iperf3.1_output    ${background}=False
    [Documentation]    Run the iperf on IVI2 as client connecting to host for a specific duration given in seconds
    # configure iptables on both IVC and IVI in order to allow iperf to connect to public internet
    Run Process    ssh root@${device_hostname} iptables -I FORWARD -j ACCEPT    shell=True
    Run Process    adb -s ${ivi_adb_id} shell iptables -I FORWARD -j ACCEPT    shell=True
    Run Process    adb -s ${ivi_adb_id} shell iptables -I INPUT -j ACCEPT    shell=True
    Run Process    adb -s ${ivi_adb_id} shell iptables -I OUTPUT -j ACCEPT    shell=True
    IF    '${background}'=='True'
        ${process} =    Start Process   adb -s ${ivi_adb_id} shell iperf -c ${host} -b ${throughput} -p ${port} -t ${duration} ${direction} ${protocol} -V --logfile /tmp/${logfile}.txt    alias=iperf_proc    shell=True
        Sleep    ${duration}s
        ${output_copy_obj} =    Run Process    adb -s ${ivi_adb_id} pull /tmp/${logfile}.txt ccs2/    shell=True
    ELSE
        ${output_iperf_obj} =    Run Process   adb -s ${ivi_adb_id} shell iperf -c ${host} -b ${throughput} -p ${port} -t ${duration} ${direction} ${protocol} -V --logfile /data/user/${logfile}.txt    shell=True
        ${output_copy_obj} =    Run Process    adb -s ${ivi_adb_id} pull /data/user/${logfile}.txt ccs2/    shell=True
    END
    Should Be Equal    "${output_copy_obj.rc}"    "0"    Failed to retrieve iperf log file from IVI

CHECK APP ON DEVICE
    [Arguments]    ${app_name}    ${device_id}
    [Documentation]    Run adb command on device to check app
    ${status}    ${package_and_activity} =    Run Keyword And Warn On Failure    GET PACKAGE AND ACTIVITY NAME FROM APP    ${app_name}
    ${ui_package} =    Set Variable If    '${status}' == 'PASS'    ${package_and_activity}[0]    ${app_name}
    ${output} =    Run    adb -s ${device_id} shell dumpsys window | grep mFocusedWindow
    Log    ${output}
    ${ret_ui_checked} =  Evaluate   "${ui_package}" in """${output}"""
    Should Be True    ${ret_ui_checked}
    [Return]    ${ret_ui_checked}
