#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Documentation  Resource file for fota-focused keywords.

...  Keyword calls can be customized using variables in the robot command line as follow:

...  robot --variable var1:value1 --variable var2:value2 mytest.robot.

...  List of available variables:

...  | *Name* | *Description*              | *Available values*            | *Default value* |
...  | ivi_adb_id | Adb identification for IVI | any string from 'adb devices' |                 |

Resource   Campaign.robot
Resource   ../../hlk_common/IVI/ivi.robot

Library   OperatingSystem

*** Variables ***
${POWER_OFF_TIME}       30
${onoff_transition_a}      OFF_STATE_TO_MMI_OFF_STATE_transition_a
${onoff_transition_b}      MMI_OFF_STATE_TO_OFF_STATE_transition_b
${onoff_transition_c}      MMI_OFF_STATE_TO_CHECK_WELCOME_transition_c
${onoff_transition_d}      MMI_ON_TO_MMI_OFF_STATE_transition_d
${onoff_transition_g}      CHECK_WELCOME_TO_MMI_ON_Full_User_Hmi_transition_g

*** Keywords ***

ACCEPT ACTIVATION
  [Documentation]  Wait for activation consent step, then click on corresponding button to accept activation phase
  ...  | *Keyword*         |
  ...  | ACCEPT ACTIVATION |
  [Arguments]   ${timeout}=15min
  WAIT UPDATE STATE  wait_for_activate   ${timeout}
  PRESS BUTTON  Accept
  SLEEP  60

ACCEPT DOWNLOAD
  [Documentation]  Wait for download consent step, then click on corresponding button to accept download phase
  ...  | *Keyword*       |
  ...  | ACCEPT DOWNLOAD |
  WAIT FOR DOWNLOAD STATE  wait_for_download
  PRESS BUTTON  Accept

ACCEPT INSTALL
  [Documentation]  Wait for install consent step, then click on corresponding button to accept installation phase
  ...  | *Keyword*      |
  ...  | ACCEPT INSTALL |
  [Arguments]   ${timeout}=30min
  WAIT UPDATE STATE  wait_for_install  ${timeout}
  PRESS BUTTON  Accept

CHECK UPDATE
  [Documentation]  Navigate in IVI menu to manual check for available update
  ...  | *Keyword*    |
  ...  | CHECK UPDATE |
  START FOTA APPLICATION
  PRESS UPDATE BUTTON
  SLEEP  5s
  FOR  ${i}  IN RANGE  12
    # wait end of "check for update"
    ${state}=  IVI.GET UPDATE STATE
    EXIT FOR LOOP IF  '${state}'!='check_for_update'
    SLEEP  10s
  END
  FOR  ${i}  IN RANGE  30
    # wait end of "generating dp"
    ${state}=  IVI.GET UPDATE STATE
    EXIT FOR LOOP IF  '${state}'!='generating_dp'
    TAP_ON_ELEMENT_USING_ID    ${VehicleSettings_back_button}    10
    PRESS UPDATE BUTTON
    SLEEP  10s
  END
  ${state}=  IVI.GET UPDATE STATE
  RETURN FROM KEYWORD IF  '${state}'=='idle'

PRESS UPDATE BUTTON
  [Documentation]  Press one of the update button (check for update or update in progress)
  ...  | *Keyword*           | *Timeout* |
  ...  | PRESS UPDATE BUTTON |           |
  ...  | PRESS UPDATE BUTTON | 5min      |
  [Arguments]  ${timeout}=7min
  WAIT UNTIL KEYWORD SUCCEEDS  ${timeout}  20s  IS UPDATE BUTTON ENABLED
  ${button}=  GET UPDATE BUTTON
  PRESS BUTTON  ${button}

IS UPDATE BUTTON ENABLED
  [Documentation]  Check if any of the update buttons is enable
  ...  | *Keyword*                | *Timeout* |
  ...  | IS UPDATE BUTTON ENABLED |           |
  ...  | IS UPDATE BUTTON ENABLED | 5min      |
  [Arguments]  ${timeout}=7min
  ${button}=  GET UPDATE BUTTON
  SHOULD NOT BE EMPTY  ${button}

CONFIGURE OFFBOARD CONNECTION
  [Documentation]  Configure connection to SoftWare Management Server.
  ...  | *Keyword*                     | *Environment*  |
  ...  | CONFIGURE OFFBOARD CONNECTION | sit-emea       |
  ...  | CONFIGURE OFFBOARD CONNECTION | rdemo2-FOTARSL |
  [Arguments]  ${environment}
  ${configured_rdemo}=  RUN KEYWORD AND RETURN STATUS  IS PATH EXISTS  ${REDBEND_SWMS_SELECT_FILE}
  ${request_rdemo}=  RUN KEYWORD AND RETURN STATUS  SHOULD CONTAIN  ${environment}  rdemo
  IF  ${configured_rdemo}!=${request_rdemo}
    CLEAR FOTA CLIENT FILES
    UPDATE OFFBOARD CONNECTION  ${environment}
  END
  RESET FOTA CLIENT

UPDATE OFFBOARD CONNECTION
    [Documentation]  Configure connection to SoftWare Management Server.
    ...  | *Keyword*                  | *Environment*  |
    ...  | UPDATE OFFBOARD CONNECTION | sit-emea       |
    [Arguments]  ${environment}
    DELETE FILE  ${REDBEND_SWMS_SELECT_FILE}
    IF  'rdemo' in '${environment}'
      rfw_services.ivi.FileSystemLib.Create File    ${REDBEND_SWMS_SELECT_FILE}
    END
    RESTART MISSION

RESET FOTA CLIENT
    [Documentation]  Reset the fota client.
    ...  | *Keyword*         |
    ...  | RESET FOTA CLIENT |
    ${adb_state}=  RUN KEYWORD AND RETURN STATUS  IS AVAILABLE
    RETURN FROM KEYWORD IF  ${adb_state}==False
    ${result}=  RUN KEYWORD AND RETURN STATUS  WAIT FOTA READY
    RETURN FROM KEYWORD IF  ${result}==True
    LOG  Fota not ready: try use Diag routine  console=True
    RUN KEYWORD AND IGNORE ERROR  RESET DIAG ROUTINE
    ${result}=  RUN KEYWORD AND RETURN STATUS  WAIT FOTA READY
    RETURN FROM KEYWORD IF  ${result}==True
    LOG  Fota not ready: clean fota directories  console=True
    CLEAR FOTA CLIENT FILES
    RESTART MISSION
    WAIT FOTA READY
    LOG  Cleanup done  console=True

RESTART MISSION
    SET VEHICLE SPEED    0
    SEND VEHICLE STATE COMMAND    AutoACC - BatTempoLevel
    Sleep     ${POWER_OFF_TIME}
    SEND VEHICLE IVI ONOFF TRANSITION SEQUENCE    ${onoff_transition_d}
    SEND VEHICLE IVI ONOFF TRANSITION SEQUENCE    ${onoff_transition_b}
    CHECK STATE EXPECTED    offline    120    ${ivi_adb_id}
    SEND VEHICLE IVI ONOFF TRANSITION SEQUENCE    ${onoff_transition_a}
    SEND VEHICLE IVI ONOFF TRANSITION SEQUENCE    ${onoff_transition_c}
    SEND VEHICLE IVI ONOFF TRANSITION SEQUENCE    ${onoff_transition_g}
    CHECK IVI BOOT COMPLETED    booted    120
    SET VEHICLE SPEED    0
    Sleep     60
