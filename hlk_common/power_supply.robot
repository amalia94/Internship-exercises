#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Documentation     Power supply setup done by "pw_config"
Library          rfw_services.power_supply.PowerSupplyLib
Library          OperatingSystem
Resource         ../hlk_common/Tools/logs.robot
Library          rfw_libraries.tools.RelayCardManager

*** Variables ***
${console_logs}    yes
${bench_power_type}         relaycard
${pw_config}    ${bench_power_type}
@{bench_power_type_list}    domino    domino_v2    domino_v2+    domino_v3    relaycard    E3648@debug    E3642@debug    A66319@debug    keithley@debug    A66319@pnp    deviceRigol
# Ecu concerned by the power supply are : ivi ivc or ccs2
${ecu_to_power}         ivi
# raspi relay manufacturer is:  kulman or sb
${raspi_relay_manuf}     kulman

*** Keywords ***
START POWER SUPPLY
    [Arguments]    ${power_supply_params}=${None}
    Run Keyword if    "${power_supply_params}[use_power_supply]" != "True"    Return From Keyword
    Run Keyword if    "${console_logs}" == "yes"     Log    **** START POWER SUPPLY ****    console=yes
    DO POWER OFF BATTERY
    Sleep    2
    DO POWER ON BATTERY

STOP POWER SUPPLY
    [Arguments]    ${power_supply_params}=${None}
    Run Keyword if    "${power_supply_params}[use_power_supply]" != "True"    Return From Keyword
    Run Keyword if    "${console_logs}" == "yes"     Log    **** STOP POWER SUPPLY ****    console=yes
    DO POWER OFF BATTERY
    DO WAIT   5000

DO POWER ON BATTERY
    [Documentation]    Main KW in reliability testing to power ON a DUT like connecting the battery of the car
    Run Keyword If  $bench_power_type not in $bench_power_type_list  Fail  Power supply not managed/filled.
    Run Keyword If    "relaycard" == "${bench_power_type}"    POWER ON BATT RELAYCARD
    ...    ELSE IF    "domino" == "${bench_power_type}" or "domino_v2" == "${bench_power_type}"    POWER BATT DOMINOBENCH    ON
    ...    ELSE IF     "domino_v2+" == "${bench_power_type}"      POWER ON BATT RELAYCARD DOMINO V2+
    ...    ELSE IF     "domino_v3" == "${bench_power_type}"      POWER ON BATT RELAYCARD DOMINO V3
    # For GPIB Power Supply
    ...    ELSE    POWER ON BATT POWER SUPPLY    ${pw_config}

DO POWER OFF BATTERY
    [Documentation]    Main KW in reliability testing to power OFF a DUT like disconnecting the battery of the car
     Run Keyword If  $bench_power_type not in $bench_power_type_list  Fail  Power supply not managed/filled.
     Run Keyword If    "relaycard" == "${bench_power_type}"    POWER OFF BATT RELAYCARD
     ...    ELSE IF    "domino" == "${bench_power_type}" or "domino_v2" == "${bench_power_type}"    POWER BATT DOMINOBENCH    OFF
     ...    ELSE IF     "domino_v2+" == "${bench_power_type}"      POWER OFF BATT RELAYCARD DOMINO V2+
     ...    ELSE IF     "domino_v3" == "${bench_power_type}"      POWER OFF BATT RELAYCARD DOMINO V3
     # For GPIB Power Supply
     ...    ELSE   POWER OFF BATT POWER SUPPLY    ${pw_config}

POWER ON BATT RELAYCARD
    [Documentation]    Power ON via relaycard a DUT like connecting the battery of the car
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    DO POWER ON BATTERY by switch on relay 5 (NormallyClose)

    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.CONNECT    card_id=USB-RLY08
    Should Be True    ${verdict}    ${comment}

    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.SWITCH OFF    card_id=USB-RLY08    relay=4
    Should Be True    ${verdict}    ${comment}

    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.DISCONNECT    card_id=USB-RLY08
    Should Be True    ${verdict}     ${comment}


POWER OFF BATT RELAYCARD
    [Documentation]    Power OFF via relaycard a DUT like disconnecting the battery of the car
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    DO POWER OFF BATTERY by switch on relay 5 (NormallyClose)

    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.CONNECT    card_id=USB-RLY08
    Should Be True    ${verdict}    ${comment}

    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.SWITCH ON    card_id=USB-RLY08    relay=4
    Should Be True    ${verdict}    ${comment}

    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.DISCONNECT    card_id=USB-RLY08
    Should Be True    ${verdict}     ${comment}


POWER ON BATT RELAYCARD DOMINO V2+
    [Documentation]    Power ON via relaycard a DUT like connecting the battery of the car
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    DO POWER ON BATTERY by switch on relay 12

    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.CONNECT    card_id=FT245R USB FIFO
    Should Be True    ${verdict}    ${comment}

    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.SWITCH ON    card_id=FT245R USB FIFO    relay=1
    Should Be True    ${verdict}    ${comment}
    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.SWITCH ON    card_id=FT245R USB FIFO    relay=2
    Should Be True    ${verdict}    ${comment}

    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.DISCONNECT    card_id=FT245R USB FIFO
    Should Be True    ${verdict}     ${comment}

POWER OFF BATT RELAYCARD DOMINO V2+
    [Documentation]    Power OFF via relaycard a DUT like disconnecting the battery of the car
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    DO POWER OFF BATTERY by switch off relay 12

    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.CONNECT    card_id=FT245R USB FIFO
    Should Be True    ${verdict}    ${comment}

    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.SWITCH OFF    card_id=FT245R USB FIFO    relay=1
    Should Be True    ${verdict}    ${comment}
    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.SWITCH OFF    card_id=FT245R USB FIFO    relay=2
    Should Be True    ${verdict}    ${comment}

    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.DISCONNECT    card_id=FT245R USB FIFO
    Should Be True    ${verdict}     ${comment}


POWER OFF BATT RELAYCARD DOMINO V3
    [Documentation]    Power OFF via relaycard a DUT like disconnecting the battery of the car
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    DO POWER OFF BATTERY by switch off relay 12

    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.CONNECT    card_id=FT245R USB FIFO
    Should Be True    ${verdict}    ${comment}

    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.SWITCH OFF    card_id=FT245R USB FIFO    relay=3
    Should Be True    ${verdict}    ${comment}
    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.SWITCH OFF    card_id=FT245R USB FIFO    relay=7
    Should Be True    ${verdict}    ${comment}
    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.SWITCH OFF    card_id=FT245R USB FIFO    relay=8
    Should Be True    ${verdict}    ${comment}

    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.DISCONNECT    card_id=FT245R USB FIFO
    Should Be True    ${verdict}     ${comment}


POWER ON BATT RELAYCARD DOMINO V3
    [Documentation]    Power ON via relaycard a DUT like connecting the battery of the car
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    DO POWER ON BATTERY by switch on relay 12

    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.CONNECT    card_id=FT245R USB FIFO
    Should Be True    ${verdict}    ${comment}

    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.SWITCH ON    card_id=FT245R USB FIFO    relay=3
    Should Be True    ${verdict}    ${comment}
    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.SWITCH ON    card_id=FT245R USB FIFO    relay=7
    Should Be True    ${verdict}    ${comment}
    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.SWITCH ON    card_id=FT245R USB FIFO    relay=8
    Should Be True    ${verdict}    ${comment}

    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.DISCONNECT    card_id=FT245R USB FIFO
    Should Be True    ${verdict}     ${comment}

SET_VAR_DOMINO_V2
    [Documentation]    Set the variables required for domino_v2
    ${raspi_relay_manuf} =    Convert To Lower Case    ${raspi_relay_manuf}
    Run keyword if    "${raspi_relay_manuf}"!="kulman" and "${raspi_relay_manuf}"!="sb"     Fail    Raspi power manufacturer unknown
    ${raspi_relay_manuf_short} =    Set Variable if     "${raspi_relay_manuf}" == "kulman"    k    s
    Set Test Variable    ${raspi_relay_manuf_short}

POWER BATT DOMINOBENCH
    [Arguments]    ${power_supply_state_to_send}
    [Documentation]    Power ON or OFF a DUT like connecting the battery of the car on a domino-bench
    ...
    Run Keyword If    "domino_v2" == "${bench_power_type}"    Run keywords    Run Keyword if    "${console_logs}" == "yes"    Log To Console    DO POWER ${power_supply_state_to_send} BATTERY on DOMINO_V2 BENCH    AND
    ...     SET_VAR_DOMINO_V2
    ...    ELSE    Run Keyword if    "${console_logs}" == "yes"    Log To Console    DO POWER ON BATTERY on DOMINO_V1 BENCH
    ${var_ssh_on} =    Set Variable if     "domino_v2" == "${bench_power_type}"    ${raspi_relay_manuf_short} ${ecu_to_power}    -batt
    ${var_ssh_ls} =    Set Variable if     "domino" == "${bench_power_type}"    && ls -al &&     &&
    ${power_supply_state_to_send} =    Convert To Lower Case    ${power_supply_state_to_send}
    OperatingSystem.Run    sshpass -p pi ssh -o StrictHostKeyChecking=no pi@192.168.0.1 'cd PycharmProjects/raspi ${var_ssh_ls} python3 raspi_setGPIO.py ${var_ssh_on}_${power_supply_state_to_send}'

POWER ON BATT POWER SUPPLY
    [Arguments]    ${pw_config}
    [Documentation]    Power ON a DUT like disconnecting the battery of the car on a GPIB power supply
    POWER SUPPLY CONFIG    ${pw_config}
    POWER SUPPLY RESET    ${pw_config}
    POWER SUPPLY ON    ${pw_config}
    POWER SUPPLY FORCE VOLTAGE    ${pw_config}

POWER OFF BATT POWER SUPPLY
    [Arguments]    ${pw_config}
    [Documentation]    Power OFF a DUT like disconnecting the battery of the car on a GPIB power supply
    POWER SUPPLY CONFIG    ${pw_config}
    POWER SUPPLY RESET    ${pw_config}
    POWER SUPPLY OFF    ${pw_config}
    SLEEP    2

DO POWER SUPPLY ID
    [arguments]    ${pw_config}
    ${return_var} =    POWER SUPPLY ID    ${pw_config}
    [Return]    ${return_var}

DO POWER SUPPLY CONFIG
    [arguments]    ${pw_config}
    POWER SUPPLY CONFIG    ${pw_config}

DO POWER SUPPLY OFF
    [arguments]    ${pw_config}
    POWER SUPPLY OFF    ${pw_config}

DO POWER SUPPLY ON
    [arguments]    ${pw_config}
    POWER SUPPLY ON    ${pw_config}

DO POWER SUPPLY FORCE VOLTAGE
    [arguments]    ${pw_config}
    POWER SUPPLY FORCE VOLTAGE    ${pw_config}

DO POWER SUPPLY GET VOLTAGE
    [arguments]    ${pw_config}
    ${volt} =    POWER SUPPLY GET VOLTAGE    ${pw_config}
    [Return]    ${volt}

DO POWER SUPPLY MEASURE CURRENT
    [arguments]    ${pw_config}
    ${verdict}    ${curr}    ${info} =    POWER SUPPLY MEASURE CURRENT    ${pw_config}
    [Return]    ${curr}

MEASURE CURRENT CONSUMPTION DURING TIME
    [arguments]    ${pw_config}
    [Documentation]     Measure power supply current cunsumption during duration time
    ...                 from config file. Return the current consumption average.
    Log To Console                          Start Power measurement
    ${curr} =   DO POWER SUPPLY MEASURE CURRENT    ${pw_config}
    ${verdict}  ${meas_points} =   POWER SUPPLY FETCH MEASUREMENT POINTS    ${pw_config}
    Log To Console                          Stop Power measurement
    LOG MEASUREMENT    ${meas_points}
    ${statistics} = 	COMPUTE STATISTICS    ${meas_points}
    ${curr_avg} =   Set Variable    ${statistics["average"]}
    [Return]    ${curr_avg}

DO POWER SUPPLY READ ERROR
    [arguments]    ${pw_config}
    POWER SUPPLY READ ERROR    ${pw_config}

DO POWER SUPPLY RESET
    [arguments]    ${pw_config}
    POWER SUPPLY RESET    ${pw_config}

DO POWER GO TO LOCAL
    [arguments]    ${pw_config}
    POWER SUPPLY GOTO LOCAL    ${pw_config}

CHECK POWER CONSUMPTION PERIODICALLY
    [arguments]    ${pw_config}    ${iterations}    ${interval}
    FOR    ${i}    IN RANGE    ${iterations}
        ${current} =  DO POWER SUPPLY MEASURE CURRENT    ${pw_config}
        ${result}=    Convert To Number  ${current}
        Should Be True    0.06<=${result}<=0.30
        BuiltIn.Sleep    ${interval}
    END

CHECK POWER CONSUMPTION DURING REBOOT
    [arguments]    ${pw_config}    ${iterations}    ${interval}
    FOR    ${i}    IN RANGE    ${iterations}
        ${current} =  DO POWER SUPPLY MEASURE CURRENT    ${pw_config}
        ${result}=    Convert To Number  ${current}
        Should Be True    0.001<=${result}<=0.30
        BuiltIn.Sleep    ${interval}
    END

DO POWER SUPPLY SET CURRENT RANGE
    [Arguments]    ${pw_config}    ${current_range}
    [Documentation]    Set power supply current range
    POWER SUPPLY SET IRANGE             ${pw_config}  ${current_range}
    SET POWER SUPPLY CURRENT RANGE      ${pw_config}

SET ACTIVATION LINE STATUS
    [Arguments]    ${status}
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    Set ACTIVATION LINE to ${status}

    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.CONNECT    card_id=FT245R USB FIFO
    Should Be True    ${verdict}    ${comment}

    IF    "${status}" == "probe"
        ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.SWITCH ON    card_id=FT245R USB FIFO    relay=5
        Should Be True    ${verdict}    ${comment}
    ELSE
        ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.SWITCH OFF    card_id=FT245R USB FIFO    relay=5
        Should Be True    ${verdict}    ${comment}
    END

SET APC STATUS
    [Arguments]    ${status}
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    Set APC to ${status}
    IF    "${status}" == "on"
        ${relay_state} =    Set Variable   0
    ELSE
        ${relay_state} =    Set Variable    1
    END
    OperatingSystem.Run    usbrelay ${usbrelay_type}_2=${relay_state}

SET ACC STATUS
    [Arguments]    ${status}
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    Set ACC to ${status}
    IF    "${status}" == "on"
        ${relay_state} =    Set Variable   0
    ELSE
        ${relay_state} =    Set Variable    1
    END
    OperatingSystem.Run    usbrelay ${usbrelay_type}_1=${relay_state}


SET IVI POWER
    [Arguments]    ${status}
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    Set IVI POWER to ${status}

    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.CONNECT    card_id=FT245R USB FIFO
    Should Be True    ${verdict}    ${comment}

    IF    "${status}" == "on"
        ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.SWITCH ON    card_id=FT245R USB FIFO    relay=7
        Should Be True    ${verdict}    ${comment}
    ELSE
        ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.SWITCH OFF    card_id=FT245R USB FIFO    relay=7
        Should Be True    ${verdict}    ${comment}
    END

    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.DISCONNECT    card_id=FT245R USB FIFO
    Should Be True    ${verdict}     ${comment}

SET IVC POWER
    [Arguments]    ${status}
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    Set IVC POWER to ${status}
    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.CONNECT    card_id=FT245R USB FIFO
    Should Be True    ${verdict}    ${comment}

    IF    "${status}" == "on"
        ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.SWITCH ON    card_id=FT245R USB FIFO    relay=8
        Should Be True    ${verdict}    ${comment}
    ELSE
        ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.SWITCH OFF    card_id=FT245R USB FIFO    relay=8
        Should Be True    ${verdict}    ${comment}
    END

    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.DISCONNECT    card_id=FT245R USB FIFO
    Should Be True    ${verdict}     ${comment}

