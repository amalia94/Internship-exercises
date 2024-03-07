#
# Copyright (c) 2020, 2021, 2022 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Library           OperatingSystem
Resource          ${CURDIR}/../Vehicle/DOIP/doip.robot

*** Variables ***
${sgw_sw}    None
${sgw_calib}    None
${sgw_mode}    None
${sgw_pairing}    None
${sgw_vin}    None
&{sgw_mode_dict}     ${0}=MEMORY_FAIL    ${1}=EMPTY    ${2}=CONFIG_FAIL    ${3}=SECURE    ${4}=reserved    ${5}=reserved    ${6}=INTERMEDIATE    ${7}=PLANT    ${8}=DIAG_COM_Z1    ${9}=DIAG_COM_Z2    ${10}=PLANT_IN_MONITOR    ${11}=DIAG_COM_Z1_IN_MONITOR    ${12}=DIAG_COM_Z2_IN_MONITOR}
&{sgw_pairing_dict}     00=NOT_DONE    01=DONE
@{sgw_unlock_did_val}    0xbb

*** Keywords ***
GET SGW INFO
    GET SGW SW
    GET SGW VIN
    GET SGW CALIBRATION
    GET SGW MODE
    GET SGW PAIRING
    # GET SGW IVI ETH STATUS
    # GET SGW IVC ETH STATUS

GET SGW SW
    ${verdict}    ${comment}    ${data} =    DOIP READ DID    sgw    SystemSupplierECUSoftwareVersionNumber    session=default
    Should Be True    ${verdict}
    Set Suite Variable     ${sgw_sw}     ${data}[SystemSupplierECUSoftwareVersionNumber]
    [Return]    ${sgw_sw}

GET SGW VIN
    ${verdict}    ${comment}    ${data} =    DOIP READ DID    sgw    VIN    session=default
    Should Be True    ${verdict}
    Set Suite Variable     ${sgw_vin}     ${data}[VIN]
    [Return]    ${sgw_vin}

GET SGW CALIBRATION
    ${verdict}    ${comment}    ${data} =    DOIP READ DID    sgw    F182    session=default
    Should Be True    ${verdict}
    Set Suite Variable     ${sgw_calib}    ${data}[F182]
    [Return]    ${sgw_calib}

GET SGW MODE
    ${verdict}    ${comment}    ${data} =    DOIP READ DID    sgw    Data_Monitor    session=default
    Should Be True    ${verdict}
    Set Suite Variable     ${sgw_mode}    ${sgw_mode_dict}[${data}[Gateway_Mode]]
    [Return]    ${sgw_mode}

GET SGW PAIRING
    ${verdict}    ${comment}    ${data} =    DOIP READ DID    sgw    Pairing_Status    session=default
    Should Be True    ${verdict}
    Set Suite Variable     ${sgw_pairing}    ${sgw_pairing_dict}[${data}[Pairing_Status]]
    [Return]    ${sgw_pairing}

GET SGW ACTIVATION LINE STATUS
    ${verdict}    ${comment}    ${data} =    DOIP READ DID    sgw    Data_Monitor    session=default
    Run Keyword And Continue On Failure    Should Be True    ${verdict}
    [Return]    ${data}[Activation_Line_Status]

GET SGW APC STATUS
    ${verdict}    ${comment}    ${data} =    DOIP READ DID    sgw    Data_Monitor    session=default
    Run Keyword And Continue On Failure    Should Be True    ${verdict}
    [Return]    ${data}[APC_Hard_Wire_Status]

GET SGW IVI ETH STATUS
    ${verdict}    ${comment}    ${data} =    DOIP READ DID    sgw    100BASE_Diagnostic    session=default
    Run Keyword And Continue On Failure    Should Be True    ${verdict}
    IF    "${data}[Interface1_Link_Status]" == "AA"
        ${status} =    Set Variable    UP
    ELSE
        ${status} =    Set Variable    DOWN
        Log    IVI ETH Status on SGW is DOWN    WARN
    END
    [Return]    ${status}

GET SGW IVC ETH STATUS
    ${verdict}    ${comment}    ${data} =    DOIP READ DID    sgw    100BASE_Diagnostic    session=default
    Run Keyword And Continue On Failure    Should Be True    ${verdict}
    IF    "${data}[Interface4_Link_Status]" == "AA"
        ${status} =    Set Variable    UP
    ELSE
        ${status} =    Set Variable    DOWN
        Log    IVC ETH Status on SGW is DOWN    WARN
    END
    [Return]    ${status}

SGW DOIP UNLOCK
    SEND VEHICLE DIAG START SESSION    sgw    extended
    ${verdict}    ${comment} =     DOIP UNLOCK ECU   sgw
    IF    "${comment}" != "ECU is already unlocked"
        DOIP WRITE DID    sgw    SGW_Unlock    ${sgw_unlock_did_val}
    END

SGW PORT MIRRORING START
    [Arguments]     ${capture_port}=ETH1_IVC     ${sniffer_port}=ETH3_ADAS
    SEND VEHICLE DIAG START SESSION    sgw    extended
    ${ecu_canakin_name}    ${ecu_eth_name} =    GET ECU DOIP INFO    sgw
    ${verdict}    ${comment} =    Start SGW Ethernet Port Mirroring    ${ecu_canakin_name}     Z1_START   RECEIVE_TRANSMIT     ${capture_port}    ${sniffer_port}    itf=${ecu_eth_name}

SGW PORT MIRRORING STOP
    ${ecu_canakin_name}    ${ecu_eth_name} =    GET ECU DOIP INFO    sgw
    SEND VEHICLE DIAG START SESSION    sgw    extended
    ${verdict}    ${comment} =    Stop SGW Ethernet Port Mirroring    ${ecu_canakin_name}         itf=${ecu_eth_name}

START SGW PORT MIRRORING ON WAKEUP
    [Arguments]    ${output_folder}=${logs_folder}
    [Documentation]    Wait the SGW is waking up to launch port mirroring
    IF    '${sweet400_bench_type}' not in "'${bench_type}'"
        Return From Keyword
    END
    Log    Waiting SGW wakeup to enable port mirroring    console=${console_logs}
    ${verdict}    ${comment} =    Canakin Seek Signal    can0    CGW_FOTABusyFlag    1    60
    ${verdict}    ${comment} =    Canakin Get Seek Signal Result    can0    CGW_FOTABusyFlag
    DOIP PLUG OBD PROBE
    START SGW ONBOARD LOGS    True    ${output_folder}
    DOIP UNPLUG OBD PROBE

STOP SGW PORT MIRRORING
    [Documentation]    Wait the SGW is waking up to launch port mirroring
    IF    '${sweet400_bench_type}' not in "'${bench_type}'"
        Return From Keyword
    END
    DOIP PLUG OBD PROBE
    STOP SGW ONBOARD LOGS
    DOIP UNPLUG OBD PROBE
