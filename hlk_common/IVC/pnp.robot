#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Documentation     Pnp test utility
Library           rfw_services.wicket.PnpCollectLib
Library           rfw_services.wicket.DeviceLib
Library           rfw_services.wicket.SystemLib
Library           Collections
Library           DateTime
Library           OperatingSystem
Library           Process

*** Variables ***
${metrics}    platinfo,cpu_gperf,ps=0.5,mem,io
${report_name}    ${EMPTY}

*** Keywords ***
GET CSV PNP COLLECT METRICS FROM IVC
    [Arguments]    ${file_name}    ${action}    ${modules}=${metrics}    ${sampling}=200    ${duration}=1000
    [Documentation]    A method to collect Linux OS basic information: platform, CPU usage, memory utilization
    ...    :param file_name: pnp_collect report name
    ...    :type file_name: string
    ...    :param action: | start_collect | retrieve_report |
    ...    :type action: string
    ...    :param modules: metrics monitored by the pnp_collect binary
    ...    :type modules: string
    ...    :param sampling: interval at which pnp_collect will retrieve data
    ...    :type sampling: string
    ...    :param duration: pnp_collect duration
    ...    :type duration: string
    Log To Console    GET CSV PNP COLLECT METRICS FROM IVC
    IF    '${action}' == 'start_collect'
        ${file_path_pnp} =    Set Variable    /tmp/PNP_COLLECT
        ${status_path} =    Run Keyword And Return Status    Directory Should Exist    ${file_path_pnp}
        Run Keyword If    "${status_path}" == "False"    Create Directory       ${file_path_pnp}
        DOWNLOAD PNP COLLECT
        ${CurrentDate} =    DateTime.Get Current Date    result_format=%Y-%m-%d-%Hh%Mm
        Run Keywords    Set Global Variable    ${start_time}    ${CurrentDate}
        ...    AND    Set Test Variable    ${bench_path}    /tmp/PNP_COLLECT/PnpViewer/pnp_collect
        ...    AND    SYSTEM SEND FILE TO DEVICE    ${bench_path}    /mnt/mmc/pnp_collect
        ...    AND    CLOSE SSH SESSION
        Set Test Variable    ${report_path}    /tmp/PNP_COLLECT/${file_name}
        Set Test Variable    ${report_name}    ${file_name}
        ${verdict}    ${comment} =    PNP COLLECT EXEC    output_file=/mnt/mmc/${report_name}    modules=${modules}    sampling_ms=${sampling}    duration_ms=${duration}
        Should Be True    ${verdict}    Failed to start PNP COLLECT EXEC: ${comment}
    ELSE IF    '${action}' == 'retrieve_report'
        SYSTEM GET FILE FROM DEVICE    /mnt/mmc/${report_name}    ${report_path}
        CLOSE SSH SESSION
        Set Test Variable    ${command_pnpviewer}    python3 /tmp/PNP_COLLECT/PnpViewer/pnp_viewer/pnpViewer.py --no-ui
        ${output_obj}=    Run Process   ${command_pnpviewer} ${report_path}    shell=True
        Should Be Equal    "${output_obj.rc}"    "0"    Failed to convert report file with pnpViewer.py
        ${file_path_pnp} =    Set Variable    /tmp/PNP_COLLECT
        Run Process    test -d ${file_path_pnp}/PnpViewer && rm -rf ${file_path_pnp}/PnpViewer    shell=True
    ELSE
        Fail     Incorrect action given: ${action}
    END
