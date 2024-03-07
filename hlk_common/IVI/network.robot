#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Documentation     Network Related Meta-Keywords Library
Library           rfw_services.ivi.NetworkLib    device=${ivi_adb_id}
Library           rfw_services.ivi.WebviewLib    device=${ivi_adb_id}
Library		      OperatingSystem

*** Variables ***
${more_button}            //*[@text='More']
${system_item}            //*[@text='System']
${reset_options_item}     //*[@text='Reset options']
${reset_network_item}     //*[@text='Reset network']
${reset_settings_item}    //*[@text='RESET SETTINGS']
${reset_network_settings_confirmation}    //*[@text='Reset all network settings? You can't undo this action!']
${network_settings_reset}    //*[@text='Network settings have been reset']
${scrollview}    androidx.recyclerview.widget.RecyclerView

*** Keywords ***
SET PING
    [Arguments]    ${target_id}    ${size}    ${number_of_pings}    ${interval}    ${address}    ${rttmax}
    ...    ${packet_loss_max}    ${status}
    Log To Console    SET PING target_id:${target_id} size:${size}bytes number_of_pings:${number_of_pings} interval:${interval}s address:${address} rttmax:${rttmax}ms packet_loss_max:${packet_loss_max}% status:${status}
    ${dut_ping_response} =    CHECK PING RESPONSE    ${number_of_pings}    ${interval}    ${address}    ${rttmax}    ${packet_loss_max}
    ...    ${size}
    Run Keyword If    "${status}" == "reachable"    Should Be True    ${dut_ping_response}    Ping response failed, ${address} is not reachable
    Run Keyword If    "${status}" == "unreachable"    Should Not Be True    ${dut_ping_response}    Ping response succeeded, ${address} is reachable

CHECK STATUS IP ADDRESS
    [Arguments]    ${target_id}    ${status}    ${timeout}
    Log To Console    CHECK STATUS IP ADDRESS target_id:${target_id}    status:${status}    timeout:${timeout}ms
    ${check_ip} =    CHECK IP ADDRESS    ${none}    ${timeout}
    Run Keyword If    "${status}" == "assigned"    Should Be True    ${check_ip}    IP Address not assigned on ${target_id}
    Run Keyword If    "${status}" == "not_assigned"    Should Not Be True    ${check_ip}    IP Address assigned on ${target_id}


SET CLOSE WEBPAGE
    [Arguments]    ${target_id}    ${web_address}
    Log To Console    SET CLOSE WEBPAGE target_id:${target_id} webaddress:${web_address}
    CLOSE WEB BROWSER

SET ETHERNET
    [Arguments]    ${target_id}    ${status}
    Log To Console    SET ETHERNET target_id:${target_id} status:${status}
    ${verdict} =    rfw_services.ivi.NetworkLib.SET ETHERNET    ${status}
    Should Be True    ${verdict}    Failed to set ethernet to ${status}

CHECK DATA CONNECTIVITY
    [Arguments]    ${status}
    [Documentation]    To check wheather ivi has data connectivity or not.
    ${dut_ping_response} =    RUN KEYWORD AND IGNORE ERROR    CHECK PING RESPONSE    10    1    8.8.8.8    1000   1000    32
    ${response} =   Evaluate    "FAIL" in """${dut_ping_response}"""
    Run Keyword If    ${response}     Log To Console    Data connectivity is unavailable.
    ...    ELSE    Log To Console    Data connectivity is available
    run keyword if    "${status}" == "available"    should not be true    ${response}
    run keyword if    "${status}" == "unavailable"    should be true    ${response}

CHECK PING SUCCEEDS
    [Arguments]    ${numberofpings}    ${interval}    ${address}
    ${result} =    rfw_services.ivi.NetworkLib.Ping    ${numberofpings}    ${interval}    ${address}
    Should Contain    ${result}    1 packets transmitted, 1 received

SET CONNECT WIFI IP ADDRESS TO ADB
    [Arguments]       ${target_id}
    [Documentation]    To connect WIFI IP adress to ADB.
    CHECK STATUS IP ADDRESS    ${target_id}   assigned    3000
    ${ip_value} =    GET IP ADDRESS    
    ${output} =    OperatingSystem.Run   adb -s ${target_id} connect ${ip_value}:5555
    CHECK TARGET IN ADB DEVICES LIST     ${ip_value}    30
   
