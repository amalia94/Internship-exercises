#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Documentation     Launching B2B Part Authentication testcase
...               This test will unburn the PA certificate for IVC and IVI at Vnext level in loop.
...               Then, PA the internal PA status will be reset and the procdedure for burn the PA certificate will be trigger.
...               Some checks are made inside DLT logs to follow the messages exchanged between Vnext and IVC/IVI
...               Usage: pipenv run robot -v env:XXX -v vehicle_id:XXX -v ivc_adb_id:XXX -v ivi_adb_id:XXX -v ivc_sn:XXX
...               -v ivi_sn:XXX -v loop_ccs2_pa001:XXX -v kpi_ccs2_pa001:XXX CCS2/RELIABILITY/TC_SWQUAL_CCS2_RELIABILITY_B2B_PA_001.robot
...               Variable definition: loop_ccs2_pa001 => number of campaign iterations
...               Variable definition: kpi_ccs2_pa001 => expected passrate
...               Variable definition: vehicle_id => VIN used for testing
...               Variable definition: enable_logs => ENABLE IVI DEBUG LOGS (default value : yes) or not on the device
...               Variable definition: ivc_adb_id => ID for IVC
...               Variable definition: ivi_adb_id => ID for IVI
...               Variable definition: ivc_sn => serial number of IVC
...               Variable definition: ivi_sn => serial number of IVI

Test Setup        SETUP_TC_SWQUAL_CCS2_RELIABILITY_B2B_PA_001
Test Teardown     TEARDOWN_TC_SWQUAL_CCS2_RELIABILITY_B2B_PA_001

Resource          ../hlk_common/IVI/hmi.robot
Resource          ../hlk_common/IVI/filesystem.robot
Resource          ../hlk_common/IVI/Connectivity/wifi.robot
Resource          ../hlk_common/Tools/logs.robot
Resource          ../hlk_common/Vehicle/DOIP/doip.robot
Resource          ../hlk_common/system.robot
Resource          ../hlk_common/Vehicle/MQTT/mqtt_remote_services.robot
Resource          ../hlk_common/IVI/new_hmi.robot
Resource          ../hlk_common/Enabler/reliability.robot
Resource          ../hlk_common/power_supply.robot
Resource          ../hlk_common/IVC/ivc_commands.robot
Resource          ../hlk_common/Vehicle/CAN/can_remote_services.robot

*** Variables ***
${loop_ccs2_pa001}    30
${kpi_ccs2_pa001}            85
@{list_iterations_verdict_status}
@{list_iterations_no_verdict_status}
${debug}    True
${bench_can_logs}      True
${url_path}    matrix/artifacts/reliability/DLT_conf/PA/
${can_config}     ${CURDIR}/../hlk_common/Vehicle/CAN/can_config_CCS2.json
# Possible values for {log_to_save} : bug_report    dmesg    procrank    logcat    serial    aplog    micom    bootloader
@{log_to_save}    bootloader    micom
${artifactory_destination}    ccs2_connected_platform/SWL/Reliability/
${ivi_pn}    None
@{iterations_time}
${TC_folder}    RELIABILITY
${setup_fail}    True
@{trigmsg_logcat_pa}    HTTP request handler - Send request: https://cert.stg.master.avnext.renault.com/cert?&VIN=${vehicle_id}&SN=${ivi_sn}&PN=${ivi_pn}    HTTP response data: {\"sn\":\"${ivi_sn}\",\"certificate\":\"
...    HTTP request handler - Send request: https://bootstm.stg.master.avnext.renault.com/region?&VIN=${vehicle_id}&SN=${ivi_sn}&PN=${ivi_pn}    HTTP response data: {\"sn\":\"${ivi_sn}\",\"region\":\"emea\"}
...    HTTP request handler - Send request: https://bootstr.stg.emea.avnext.renault.com/partition?&VIN=${vehicle_id}&SN=${ivi_sn}&PN=${ivi_pn}   HTTP response data: {\"sn\":\"${ivi_sn}\",\"partition\":\"001\"}

*** Keywords ***
SETUP_TC_SWQUAL_CCS2_RELIABILITY_B2B_PA_001
    START TEST CASE    ${tc_required_variables}
    SAVE CANDUMP LOGS    /rhw/logmon_logs/candump/setup    setup
    START LOGCAT MONITOR    ${ivi_adb_id}    regex=${FALSE}
    START DLT MONITOR
    CHECK VIN AND PART ASSOCIATION    ivc_id
    CHECK VIN CONFIG ON    ivc
    SET VNEXT TIME AND DATE ON IVC
    SET PROP APLOG    ${ivi_adb_id}
    Run Keyword And Ignore Error     ENABLE IVI DEBUG LOGS      ${ivi_adb_id}    ${current_tc_name}    ${micom_port}    ${bootloader_port}    ${log_to_save}
    Run Keyword And Ignore Error     REMOVE IVI APLOG    ${ivi_adb_id}
    Run Keyword And Ignore Error    REMOVE IVI DROPBOX CRASHES    ${ivi_adb_id}
    Sleep    5s

TEARDOWN_TC_SWQUAL_CCS2_RELIABILITY_B2B_PA_001
    Run Keyword If   "${setup_fail}"=="True"    Run Keyword And Warn On Failure    RETRIEVE LOGS FROM SETUP
    STOP ANALYZING LOGCAT DATA
    STOP LOGCAT MONITOR
    Run Keyword And Ignore Error    STOP DLT MONITOR
    Run Keyword And Ignore Error    STOP CAN LOGS
    ${week_id} =    GET CURRENT WEEK
    Run Keyword And Ignore Error    STOP TEST CASE
    ZIP DLT    ${current_tc_name}
    Run Keyword If    "${push_artifactory}" == "yes"    Run Keyword And Continue On Failure    PUSH FILES TO ARTIFACTORY    /rhw/debug_logs/${current_tc_name}.zip    ${artifactory_destination}WW${week_id}_IVI_${ivi_build_id}_IVC_${ivc_build_id}/


*** Test Cases ***
TC_SWQUAL_CCS2_RELIABILITY_B2B_PA_001
    ${number_of_iterations} =    Evaluate    ${loop_ccs2_pa001} + 1
    FOR    ${var}    IN RANGE    1    ${number_of_iterations}
        START RELIABILITY LOOP    ${status_list_verdict}    ${status_list_no_verdict}    ${var}
        SAVE CANDUMP LOGS    /rhw/logmon_logs/candump/loop_${var}    ${var}
        ######## IVI PA ##########
        CHECK KEYWORD STATUS    SEND EMAIL FOR VNEXT STATUS    verdict    ${status_list_verdict}    ${var}    IVI    New    ${TC_folder}
        CHECK KEYWORD STATUS    CHECK VNEXT VIN CERTIFICATE STATUS    verdict    ${status_list_verdict}    ${var}    IVI    New    ${TC_folder}
        CHECK KEYWORD STATUS    CONFIGURE VEHICLE STUB PROFILE    verdict    ${status_list_verdict}    ${var}    keep_ivc_and_ivi_on_vehicle_running
        CHECK KEYWORD STATUS    CHECK IVI BOOT COMPLETED    verdict    ${status_list_verdict}    ${var}    booted    120    ${TC_folder}
        CHECK KEYWORD STATUS    CHECK IVC BOOT COMPLETED     verdict    ${status_list_verdict}    ${var}    180    True
        CHECK KEYWORD STATUS    CHECK IVC MQTT CONNECTION STATUS    verdict    ${status_list_verdict}    ${var}
        CHECK KEYWORD STATUS    CHECK IVI DATE AND TIME    verdict    ${status_list_verdict}    ${var}
        RECORD VNEXT DATE & TIME    tstart
        CHECK KEYWORD STATUS    DO RESET IVI PART AUTHENTICATION STATUS    verdict    ${status_list_verdict}    ${var}
        IF    "${ivi_my_feature_id}"=="MyF1"
            CHECK KEYWORD STATUS    DO BCM STANDBY    no_verdict    ${status_list_no_verdict}    ${var}
            CHECK KEYWORD STATUS    CONFIGURE VEHICLE STUB PROFILE    verdict    ${status_list_verdict}    ${var}    keep_ivc_and_ivi_on_vehicle_running
            CHECK KEYWORD STATUS    CHECK IVC BOOT COMPLETED     verdict    ${status_list_verdict}    ${var}    180    True
        END
        CHECK KEYWORD STATUS    CHECK IVI BOOT COMPLETED    verdict    ${status_list_verdict}    ${var}    booted    120    ${TC_folder}
        CHECK KEYWORD STATUS    CHECK IVC MQTT CONNECTION STATUS   verdict    ${status_list_verdict}    ${var}
        CHECK KEYWORD STATUS    CHECK IVI TO VNEXT MESSAGE VA    verdict    ${status_list_verdict}    ${var}    certificateInstalled    ${TC_folder}
        CHECK KEYWORD STATUS    CHECK VNEXT VIN CERTIFICATE STATUS    verdict    ${status_list_verdict}    ${var}    IVI    Burnt    ${TC_folder}
        CHECK KEYWORD STATUS    ADB DIAG READ BINARY DID    verdict    ${status_list_verdict}    ${var}    0334
        ######### IVC PA ##########
        CHECK KEYWORD STATUS    CHECK IVI DATE AND TIME    verdict    ${status_list_verdict}    ${var}
        RECORD VNEXT DATE & TIME    tstart
        CHECK KEYWORD STATUS    SEND EMAIL FOR VNEXT STATUS    verdict    ${status_list_verdict}    ${var}    IVC    New    ${TC_folder}
        CHECK KEYWORD STATUS    CHECK VNEXT VIN CERTIFICATE STATUS    verdict    ${status_list_verdict}    ${var}    IVC    New    ${TC_folder}
        CHECK KEYWORD STATUS    DO REMOVE PART AUTHENTICATION STATUS    verdict    ${status_list_verdict}    ${var}    ${ivc_type}    ${TC_folder}
        CHECK KEYWORD STATUS    DO RESET IVC PART AUTHENTICATION STATUS    verdict    ${status_list_verdict}    ${var}    ${TC_folder}
        CHECK KEYWORD STATUS    CHECK IVC PART AUTHENTICATION STATUS    verdict    ${status_list_verdict}    ${var}    2    ${TC_folder}
        DOIP PLUG OBD PROBE
        CHECK KEYWORD STATUS    doip.SEND VEHICLE DIAG START SESSION    verdict    ${status_list_verdict}    ${var}    aivc2    extended
        CHECK KEYWORD STATUS    doip.DOIP ECU RESET    verdict    ${status_list_verdict}    ${var}    hard_reset    aivc2    5    True
        CHECK KEYWORD STATUS    CONFIGURE VEHICLE STUB PROFILE    no_verdict    ${status_list_no_verdict}    ${var}    only_keep_ivc_on
        Sleep    60s
        CHECK KEYWORD STATUS    CHECK IVC MQTT CONNECTION STATUS    verdict    ${status_list_verdict}    ${var}
        CHECK KEYWORD STATUS    CHECK IVC TO VNEXT MESSAGE VA    verdict    ${status_list_verdict}    ${var}    certificateInstalled    ${TC_folder}
        CHECK KEYWORD STATUS    CHECK VNEXT VIN CERTIFICATE STATUS    verdict    ${status_list_verdict}    ${var}    IVC    Burnt    ${TC_folder}
        CHECK KEYWORD STATUS    CHECK IVC PART AUTHENTICATION STATUS    verdict    ${status_list_verdict}    ${var}    0    ${TC_folder}
        CHECK KEYWORD STATUS   DIAG READ DID    verdict    ${status_list_verdict}    ${var}    0334
        DOIP UNPLUG OBD PROBE
        SET DLT TRIGGER    notifyEnterIvcState. IVCState: StOnInit    1
        Sleep   2s
        START ANALYZING DLT DATA
        Run Keyword And Ignore Error    SYSTEM GET FILE FROM DEVICE   /mnt/mmc/logs/    ${loop_folder}
        CHECK KEYWORD STATUS    LOAD DLT DIRECTORY    no_verdict    ${status_list_no_verdict}    ${var}    ${loop_folder}/logs
        Sleep    120s
        ${w}    ${w_error} =   rfw_libraries.logmon.DltMonitor.WAIT FOR DLT TRIGGER    notifyEnterIvcState. IVCState: StOnInit
        CHECK KEYWORD STATUS    SHOULD BE TRUE    verdict    ${status_list_verdict}    ${var}    ${w}
        STOP ANALYZING DLT DATA
        Sleep    10s
        #configure string to search
        FOR    ${trigger}    IN    @{trigmsg_logcat_pa}
            CHECK KEYWORD STATUS    SET LOGCAT TRIGGER     no_verdict    ${status_list_no_verdict}    ${var}    ${trigger}
        END
        CHECK KEYWORD STATUS    START ANALYZING LOGCAT DATA     no_verdict    ${status_list_no_verdict}    ${var}
        Run Keyword And Ignore Error    RETRIEVE IVI APLOG   ${loop_folder}
        Run Keyword And Ignore Error    RETRIEVE IVI MEMORY INFORMATION    ${var}
        Run Keyword And Ignore Error    RETRIEVE IVI DMESG    ${ivi_adb_id}    ${var}
        IF    "${var}" == "${loop_ccs2_pa001}"
            SAVE IVI DROPBOX CRASHES    ${ivi_adb_id}
            EXTRACT ANDROID BUG REPORTS    ${ivi_adb_id}
        END
        ${verdict}    ${comment} =    LOAD LOGCAT FILE    file_path=${loop_folder}/logd/merged_logcats.txt
        Sleep    120s
        Run Keyword And Warn On Failure    Should be True    ${verdict}    ${comment}
        FOR    ${trigger}    IN    @{trigmsg_logcat_pa}
            CHECK KEYWORD STATUS    WAIT FOR LOGCAT TRIGGER    verdict    ${status_list_verdict}    ${var}    ${trigger}    120
        END
        CHECK KEYWORD STATUS    STOP ANALYZING LOGCAT DATA    verdict    ${status_list_verdict}    ${var}
        Run Keyword And Ignore Error    DELETE DLT LOGS
        Run Keyword And Ignore Error    SEND VEHICLE WAKEUP COMMAND    sleep
        Sleep    5s
        Run Keyword And Ignore Error     STOP CAN WRITING
        END RELIABILITY LOOP    ${status_list_verdict}    ${status_list_no_verdict}    ${var}    ${start_time}
    END
    CALCULATE RELIABILITY PASSRATE    ${kpi_ccs2_pa001}
