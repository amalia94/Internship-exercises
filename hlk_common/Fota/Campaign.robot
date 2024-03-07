#
# Copyright (c) 2020, 2021, 2022, 2023 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Documentation    Resource file for fota-focused keywords.

...  Keyword calls can be customized using variables in the robot command line as follow:

...  robot --variable var1:value1 --variable var2:value2 mytest.robot.

...  List of available variables:

...  | *Name*         | *Description*                          | *Available values*                 | *Default value*    |
...  | vnext_pfx_file | Path to the vnext certificate file pfx | any file                           |                    |
...  | vnext_pfx_pwd  | Password for vnext certificate         | any string                         |                    |
...  | apim_info      | Name of VNext apim definition to use   | any filename in cirrus config path | apim_campaign.yaml |
...  | dhmi           | Path to dhmi definition file           | any json file                      |                    |

Library   Collections
Library   OperatingSystem
Library   String
Library   robot.libraries.DateTime
Library    ../fota_libs/libraries/VnextLib.py

Resource    DHMI_JSON.robot

*** Variables ***
${env}               stg-emea
${fota_step}         2
${apim_fota}         apim_campaign.yaml
${apim_sa}           apim_sa.yaml
${vnext_pfx_file}    FotaSit.pfx
${vnext_pfx_pwd_fota}     password
${dhmi}              ${empty}

*** Keywords ***
INIT VNEXT
    [Documentation]    Configure Cirrus lib for VNext connection
    ...  | *Keyword*  |
    ...  | INIT VNEXT |

    LOG  Fota Step ${fota_step}  console=True
    VNEXT LOAD CONFIG   Fota
    SET FOTA STEP  ${fota_step}

VNEXT LOAD CONFIG
    [Documentation]    Configure SWMS with desired file according to service and environment
    ...  | *Keyword*         | *Service* |
    ...  | VNEXT LOAD CONFIG | Fota      |
    ...  | VNEXT LOAD CONFIG | Sa        |
    [Arguments]  ${service}
    VNEXT SET CONFIG    ${env}
    RETURN FROM KEYWORD IF  'rdemo' in '${env}'
    IF  'Fota' in '${service}'
      VNEXT LOAD APIM DEFINITION  ${apim_fota}
    ELSE
      VNEXT LOAD APIM DEFINITION  ${apim_sa}
    END
    VNEXT SET CERTIF  ${vnext_pfx_file}  ${vnext_pfx_pwd_fota}

CREATE CAMPAIGN CLIENT CONFIG
    [Documentation]    Create client config campaign.
    ...  | *Keyword*                     | *Vins*    | *Setting Config* | *Name*      |
    ...  | CREATE CLIENT CONFIG CAMPAIGN | VIN1,VIN2 | @{list}          |             |
    ...  | CREATE CLIENT CONFIG CAMPAIGN | VIN1,VIN2 | @{list}          | my campaign |
    [Arguments]  ${vins}  ${setting_config}  ${name}=${EMPTY}
    RESET CAMPAIGN PARAMETERS
    ${vin_string}=  VIN STRING  ${vins}
    IF  '${name}'=='${EMPTY}'
        ${name}=  Catenate  SEPARATOR=_  ClientConfig  ${vin_string}
    END
    @{vin_list}=    SPLIT STRING    ${vins}  ,
    ${verdict}  ${comment}  ${campaign_id}=  CREATE CLIENT CONFIG CAMPAIGN  ${vin_list}  ${setting_config}   ${name}
    SET SUITE VARIABLE  ${camp_id}  ${campaign_id}
    LOG TO CONSOLE  ${\n}Create campaign: Client Config ${campaign_id}
    SHOULD BE TRUE  ${verdict}  ${comment}

CREATE CAMPAIGN SCOMO
    [Documentation]    Create regular scomo campaign using Dynamic HMI definition from file ``dhmi`` with multiple ecus capability
    ...  | *Keyword*             | *Vins*    | *Ecus*  | *Content IDs*                           | *DHMI*             | *Fota Type* | *Name*      | *Duration* | *SMS*  | *Retries* |
    ...  | CREATE CAMPAIGN SCOMO | VIN1,VIN2 | RDO     | aaaa-bbbb-cccc-dddd                     |                    |             |             |            |        |           |
    ...  | CREATE CAMPAIGN SCOMO | VIN1,VIN2 | TCU,RDO | bbbb-cccc-dddd-aaaa,bbbb-cccc-dddd-aaaa | /path/to/dhmi.json | Regular     | my campaign | 3days      | Normal | 3         |
    [Arguments]  ${vins}  ${ecus}  ${content_ids}  ${dhmi}  ${fota_type}=Regular  ${name}=${EMPTY}  ${duration}=1day  ${sms}=NONE  ${retries}=0
    RESET CAMPAIGN PARAMETERS
    ${vin_string}=  VIN STRING  ${vins}
    ${ecu_string}=  ECU STRING  ${ecus}
    IF  '${name}'=='${EMPTY}'
        ${name}=  Catenate  SEPARATOR=_  Scomo  ${ecu_string}  ${vin_string}
    END
    @{vin_list}=    SPLIT STRING    ${vins}  ,
    @{sw_list}=  SPLIT STRING    ${content_ids}  ,
    @{ecu_list}=  SPLIT STRING    ${ecus}  ,
    USE DYNAMIC HMI  ${dhmi}
    SET SUITE VARIABLE  ${dynamic_hmi}  ${dhmi}
    SET FOTA TYPE  ${fota_type}
    SET RETRIES  ${retries}
    DEFINE CAMPAIGN DURATION  ${duration}
    USE SMS PUSH  ${sms}
    ${verdict}  ${comment}  ${campaign_id}=  CREATE SCOMO CAMPAIGN  ${vin_list}  ${ecu_list}  ${sw_list}  ${name}
    SET SUITE VARIABLE  ${camp_id}  ${campaign_id}
    LOG TO CONSOLE  ${\n}Create campaign: Scomo ${campaign_id}
    SHOULD BE TRUE  ${verdict}  ${comment}

CREATE CAMPAIGN VESPA
    [Documentation]    Create regular vespa campaign using Dynamic HMI definition from file ``dhmi``
    ...  | *Keyword*             | *Vins*    | *Ecus*  | *Vespa Type* | *DHMI*             | *Name*      | *Duration* | *SMS*  | *Update Mode* | *Retries* |
    ...  | CREATE CAMPAIGN VESPA | VIN1,VIN2 | DAS     | Calib        |                    |             |            |        |               |           |
    ...  | CREATE CAMPAIGN VESPA | VIN1,VIN2 | TCU,RDO | Software     | /path/to/dhmi.json | my campaign | 3days      | Urgent | 1             | 2         |
    [Arguments]  ${vins}  ${ecus}  ${vespa_type}  ${dhmi}  ${name}=${EMPTY}  ${duration}=1day  ${sms}=NONE  ${update_mode}=0  ${retries}=0
    RESET CAMPAIGN PARAMETERS
    ${vin_string}=  VIN STRING  ${vins}
    ${ecu_string}=  ECU STRING  ${ecus}
    IF  '${name}'=='${EMPTY}'
        ${name}=  Catenate  SEPARATOR=_  Vespa  ${ecu_string}  ${vin_string}
    END
    @{vin_list}=    SPLIT STRING    ${vins}  ,
    @{ecu_list}=  SPLIT STRING    ${ecus}  ,
    DEFINE CAMPAIGN DURATION  ${duration}
    SET RETRIES  ${retries}
    USE DYNAMIC HMI  ${dhmi}
    SET SUITE VARIABLE  ${dynamic_hmi}  ${dhmi}
    USE SMS PUSH  ${sms}
    ${verdict}  ${comment}  ${campaign_id}=  CREATE VESPA CAMPAIGN  vin_list=${vin_list}  ecus=${ecu_list}  vespa_type=${vespa_type}  name=${name}  update_mode=${update_mode}
    SET SUITE VARIABLE  ${camp_id}  ${campaign_id}
    LOG TO CONSOLE  ${\n}Create campaign: Vespa ${campaign_id}
    SHOULD BE TRUE  ${verdict}  ${comment}

CREATE CAMPAIGN INVENTORY
    [Documentation]    Create inventory campaign
    ...  | *Keyword*                 | *Vins*     | *Name*      | *Duration* | *SMS*  | *Retries* |
    ...  | CREATE CAMPAIGN INVENTORY | VIN1,VIN2  |             |            |        |           |
    ...  | CREATE CAMPAIGN INVENTORY | VIN1,VIN2  | my campaign | 5days      | Normal | 1         |
    [Arguments]  ${vins}  ${name}=${EMPTY}  ${duration}=1day  ${sms}=NONE  ${retries}=0
    RESET CAMPAIGN PARAMETERS
    ${vin_string}=  VIN STRING  ${vins}
    IF  '${name}'=='${EMPTY}'
        ${name}=  Catenate  SEPARATOR=_  Inventory  ${vin_string}
    END
    @{vin_list}=    SPLIT STRING    ${vins}  ,
    DEFINE CAMPAIGN DURATION  ${duration}
    SET RETRIES  ${retries}
    USE SMS PUSH  ${sms}
    ${verdict}  ${comment}  ${campaign_id}=  CREATE INVENTORY CAMPAIGN  ${vin_list}  ${name}
    SET SUITE VARIABLE  ${camp_id}  ${campaign_id}
    LOG TO CONSOLE  ${\n}Create campaign: Inventory ${campaign_id}
    SHOULD BE TRUE  ${verdict}  ${comment}

CREATE CAMPAIGN LOGS
    [Documentation]    Create Logs campaign
    ...  | *Keyword*            | *Vins*     | *Name*      | *Duration* | *SMS*  | *Retries* |
    ...  | CREATE CAMPAIGN LOGS | VIN1,VIN2  |             |            |        |           |
    ...  | CREATE CAMPAIGN LOGS | VIN1,VIN2  | my campaign | 5days      | Urgent | 2         |
    [Arguments]  ${vins}  ${name}=${EMPTY}  ${duration}=1day  ${sms}=NONE  ${retries}=0
    RESET CAMPAIGN PARAMETERS
    ${vin_string}=  VIN STRING  ${vins}
    IF  '${name}'=='${EMPTY}'
        ${name}=  Catenate  SEPARATOR=_  Logs  ${vin_string}
    END
    @{vin_list}=    SPLIT STRING    ${vins}  ,
    DEFINE CAMPAIGN DURATION  ${duration}
    SET RETRIES  ${retries}
    USE SMS PUSH  ${sms}
    ${verdict}  ${comment}  ${campaign_id}=  CREATE LOGS CAMPAIGN  ${vin_list}  ${name}
    SET SUITE VARIABLE  ${camp_id}  ${campaign_id}
    LOG TO CONSOLE  ${\n}Create campaign: Logs ${campaign_id}
    SHOULD BE TRUE  ${verdict}  ${comment}

CREATE CAMPAIGN DESCMO
    [Documentation]    Create descmo campaign
    ...  setting_list can be declared as the example below:
    ...    - create one or more property dictionaries like '&{prop1}=  CREATE DICTIONARY  Value  ON  Name  Status'
    ...    - create the list of properties like '@{props}=  CREATE LIST  ${prop1}  ${prop2} ...'
    ...    - create one or more setting dictionaries like '&{sett1}=  CREATE DICTIONARY  SettingName  Bcall_IVI  Properties  ${props}  Method  Xcall.bcall_activation_A_IVI  SettingId  d5863e95-5d25-49f4-ae49-1788c6abeaf4'
    ...    - create list of settings like @{setting_list}=  CREATE LIST  ${sett1}  ${sett2}  ..'
    ...  | *Keyword*              | *Vins*     | *Action* | *Ecu* | *Setting List*  | *Name*      | *Duration* | *SMS*  | *Retries* |
    ...  | CREATE DESCMO CAMPAIGN | VIN1,VIN2  | SET      | RDO   | @{setting_list} |             |            |        |           |
    ...  | CREATE DESCMO CAMPAIGN | VIN1,VIN2  | GET      | TCU   | @{setting_list} | my campaign | 3days      | Normal | 2         |
    [Arguments]  ${vins}  ${action}  ${ecu}  ${setting_list}  ${name}=${EMPTY}  ${duration}=1day  ${sms}=NONE  ${retries}=0
    RESET CAMPAIGN PARAMETERS
    ${vin_string}=  VIN STRING  ${vins}
    IF  '${name}'=='${EMPTY}'
      ${name}=  Catenate  SEPARATOR=_  Descmo${action}  ${ecu}  ${vin_string}
    END
    @{vin_list}=    SPLIT STRING    ${vins}  ,
    DEFINE CAMPAIGN DURATION  ${duration}
    SET RETRIES  ${retries}
    USE SMS PUSH  ${sms}
    ${verdict}  ${comment}  ${campaign_id}=  CREATE DESCMO CAMPAIGN  ${vin_list}  ${action}  ${ecu}  ${setting_list}  ${name}
    SET SUITE VARIABLE  ${camp_id}  ${campaign_id}
    LOG TO CONSOLE  ${\n}Create campaign: Descmo ${campaign_id}
    SHOULD BE TRUE  ${verdict}  ${comment}

CREATE CAMPAIGN NRE
    [Documentation]    Create regular nre campaign using Dynamic HMI definition from file ``dhmi``
    ...  | *Keyword*           | *Vins*    | *Ecu* | *NRE Type* | *DHMI*             | *Name*      | *Duration* | *SMS*  | *Retries* |
    ...  | CREATE CAMPAIGN NRE | VIN1,VIN2 | DAS   | Calib      |                    |             |            |        |           |
    ...  | CREATE CAMPAIGN NRE | VIN1,VIN2 | RDO   | Config     | /path/to/dhmi.json | my campaign | 3days      | Normal | 2         |
    [Arguments]  ${vins}  ${ecu}  ${nre_type}  ${dhmi}  ${name}=${EMPTY}  ${duration}=1day  ${sms}=NONE  ${retries}=0
    RESET CAMPAIGN PARAMETERS
    ${vin_string}=  VIN STRING  ${vins}
    IF  '${name}'=='${EMPTY}'
      ${name}=  Catenate  SEPARATOR=_  Nre  ${ecu}  ${vin_string}
    END
    @{vin_list}=    SPLIT STRING    ${vins}  ,
    DEFINE CAMPAIGN DURATION  ${duration}
    SET RETRIES  ${retries}
    USE SMS PUSH  ${sms}
    ${verdict}  ${comment}  ${campaign_id}=  CREATE NRE CAMPAIGN  ${vin_list}  ${ecu}  ${nre_type}  ${name}
    SET SUITE VARIABLE  ${camp_id}  ${campaign_id}
    LOG TO CONSOLE  ${\n}Create campaign: Nre ${campaign_id}
    SHOULD BE TRUE  ${verdict}  ${comment}

WAIT CAMPAIGN RESULT
    [Documentation]  Wait for campaign result from multiple criteria (final state, number of updated vins)
    ...  | *Keyword*            | *Timeout* | *Warning* |
    ...  | WAIT CAMPAIGN RESULT | 1h        | 10min     |
    [Arguments]    ${timeout}=30min  ${warning}=10min
    WAIT STATE  Finished  ${timeout}  ${warning}
    # Workaround for CCSEXT-45904 -->
    ${res}=  RUN KEYWORD AND RETURN STATUS  WORKAROUND WAIT STATS
    RUN KEYWORD IF  ${res}==False  LOG  Inconsistent statistics  WARN
    # <-- Workaround for CCSEXT-45904

WORKAROUND WAIT STATS
   WAIT UNTIL KEYWORD SUCCEEDS  5x  60s  CHECK CAMPAIGN STATISTICS

GET CAMPAIGN STATUS
    [Documentation]  Return campaign status
    ...  | *Result* | *Keyword*           |
    ...  | ${state} | GET CAMPAIGN STATUS |
    ${campaign_id}=  GET VARIABLE VALUE  ${camp_id}
    ${verdict}  ${comment}  ${state}=  GET CAMPAIGN STATE  ${campaign_id}
    SHOULD BE TRUE  ${verdict}  ${comment}
    RETURN FROM KEYWORD  ${state}

WAIT STATE
    [Documentation]  Wait for campaign to reach desired state
    ...  A warn message is added in the log if the duration exceeds `warning`.
    ...  Keyword returns failure if the duration exceeds `timeout`.
    ...  | *Keyword*  | *State*  | *Timeout* | *Warning* |
    ...  | WAIT STATE | Finished | 30min     | 10min     |
    ...  | WAIT STATE | Ongoing  | 10min     |           |
    [Arguments]  ${state}  ${timeout}  ${warning}=${EMPTY}
    ${campaign_id}=  GET VARIABLE VALUE  ${camp_id}
    IF  '${warning}'=='${EMPTY}'
      ${warning}=  SET VARIABLE  ${timeout}
    END
    ${warning_seconds}=  robot.libraries.DateTime.CONVERT TIME  ${warning}
    ${verdict}  ${comment}=  WAIT CAMPAIGN STATE  ${campaign_id}  ${state}  ${warning_seconds}
    RETURN FROM KEYWORD IF  ${verdict}==True
    LOG  Campaign not ${state} after ${warning}s  WARN
    ${remaining}=  robot.libraries.DateTime.SUBTRACT TIME FROM TIME  ${timeout}  ${warning}
    ${remaining}=  robot.libraries.DateTime.CONVERT TIME  ${remaining}
    ${verdict}  ${comment}=  WAIT CAMPAIGN STATE  ${campaign_id}  ${state}  ${remaining}
    SHOULD BE TRUE  ${verdict}  ${comment}

CHECK CAMPAIGN STATISTICS
    [Documentation]  Check campaign statistics to verify, consistency, nb of vins, nb of pending operations
    ...  | *Keyword*                 |
    ...  | CHECK CAMPAIGN STATISTICS |
    ${campaign_id}=  GET VARIABLE VALUE  ${camp_id}
    ${verdict}  ${comment}  ${stats}=  GET CAMPAIGN STATISTICS  ${campaign_id}
    ${nb_vin}=  GET FROM DICTIONARY  ${stats}  totalVin
    SHOULD NOT BE EQUAL AS INTEGERS  ${nb_vin}  0
    ${pending}=  GET FROM DICTIONARY  ${stats}  pendingCount
    SHOULD BE EQUAL AS INTEGERS  ${pending}  0
    ${ongoing}=  GET FROM DICTIONARY  ${stats}  onGoingCount
    SHOULD BE EQUAL AS INTEGERS  ${ongoing}  0

CHECK CAMPAIGN STATE
  [Documentation]  Check if campaign expected counter got expected value.
  ...  | *Keyword*            | *Counter*     | *Value* |
  ...  | CHECK CAMPAIGN STATE | canceledCount | 2       |
  ...  | CHECK CAMPAIGN STATE | failedCount   |         |
  [Arguments]  ${counter}  ${value}=1
  WAIT CAMPAIGN RESULT
  ${campaign_id}=  GET VARIABLE VALUE  ${camp_id}
  ${verdict}  ${message}  ${stats}=  GET CAMPAIGN STATISTICS  ${campaign_id}
  SHOULD BE TRUE  ${verdict}  ${message}
  ${count}=  GET FROM DICTIONARY  ${stats}  ${counter}
  SHOULD BE EQUAL AS INTEGERS  ${value}  ${count}

CHECK CAMPAIGN SUCCESS
  [Documentation]  Wait until campaign closed then check success status
  ...  A warn message is added in the log if the duration exceeds `warning`.
  ...  Keyword returns failure if the duration exceeds `timeout`.
  ...  | *Keyword*              | *Timeout* | *Warning* |
  ...  | CHECK CAMPAIGN SUCCESS | 30min     | 10min     |
  ...  | CHECK CAMPAIGN SUCCESS | 30min     |           |
  [Arguments]  ${timeout}=30min  ${warning}=${EMPTY}
  WAIT CAMPAIGN RESULT  timeout=${timeout}  warning=${warning}
  ${campaign_id}=  GET VARIABLE VALUE  ${camp_id}
  ${verdict}  ${message}  ${stats}=  GET CAMPAIGN STATISTICS  ${campaign_id}
  SHOULD BE TRUE  ${verdict}  ${message}
  ${nb_vin}=  GET FROM DICTIONARY  ${stats}  totalVin
  ${success}=  GET FROM DICTIONARY  ${stats}  updateSuccessCount
  # Workaround for CCSEXT-45904 -->
#  SHOULD BE EQUAL AS INTEGERS  ${nb_vin}  ${success}
  RETURN FROM KEYWORD IF  '${nb_vin}'=='${success}'
  &{codes}=  GET CAMPAIGN RESULT CODES
  LENGTH SHOULD BE  ${codes}  ${nb_vin}
  FOR  ${vin}  IN  @{codes}
    &{result}=  GET FROM DICTIONARY  ${codes}  ${vin}
    ${code}=  GET FROM DICTIONARY  ${result}  code
    SHOULD BE EQUAL AS INTEGERS  ${code}  0
  END
  # <-- Workaround for CCSEXT-45904

FINISH CAMPAIGN
    [Documentation]    Close current campaign if not already done
    ...  | *Keyword*       |
    ...  | FINISH CAMPAIGN |
    SLEEP  10s
    ${campaign_id}=  GET VARIABLE VALUE  ${camp_id}
    ${verdict}  ${message}=  CLOSE CAMPAIGN  ${campaign_id}
    SLEEP  60s
    RUN KEYWORD IF  ${verdict}==False  LOG  ${message}  WARN
    LOG TO CONSOLE  ${message}

VIN STRING
    [Documentation]    Generate a string based on a comma separated vin list
    ...  | *Keyword*  | *Vins*    |
    ...  | VIN STRING | VIN1,VIN2 |
    [Arguments]    ${vins}
    @{vin_list}=  SPLIT STRING    ${vins}  ,
    ${nb}=  GET LENGTH  ${vin_list}
    ${first_vin}=  GET FROM LIST  ${vin_list}  0
    ${first_vin}=  GET SUBSTRING  ${first_vin}  -6
    RETURN FROM KEYWORD IF  ${nb} == 1  ${first_vin}
    RETURN FROM KEYWORD  MultiVin

ECU STRING
    [Documentation]    Generate a string based on a comma separated ecu list
    ...  | *Keyword*  | *Ecus*    |
    ...  | ECU STRING | ECU1,ECU2 |
    [Arguments]    ${ecus}
    @{ecu_list}=    SPLIT STRING    ${ecus}  ,
    ${nb}=  GET LENGTH  ${ecu_list}
    ${first_vin}=  GET FROM LIST  ${ecu_list}  0
    RETURN FROM KEYWORD IF  ${nb} == 1  ${first_vin}
    ${ecu_str}=  CATENATE  SEPARATOR=-  @{ecu_list}
    RETURN FROM KEYWORD  ${ecu_str}

GET DHMI FILE
  [Documentation]  Get dhmi file from its name in the resource directory
  ...  | *Result*    | *Keyword*     | *Dhmi Name* |
  ...  | ${filepath} | GET DHMI FILE | RegularFull |
  ...  | ${filepath} | GET DHMI FILE | Silent      |
  [Arguments]  ${dhmi_name}
  ${hmi_content}=  GET DHMI TEMPLATE  ${dhmi_name}
  ${date}=  robot.libraries.DateTime.GET CURRENT DATE  result_format=%Y-%m-%d_%H-%M-%S
  ${hmi_file}=  SAVE DHMI  ${hmi_content}  ${dhmi_name}_${date}
  RETURN FROM KEYWORD  ${hmi_file}

CANCEL PENDING CAMPAIGNS
  [Documentation]  Cancel all pending campaigns for vins provided as argument.
  ...  | *Keyword*                | *Vins*    |
  ...  | CANCEL PENDING CAMPAIGNS | VIN1,VIN2 |
  [Arguments]  ${vins}
  LOG TO CONSOLE  ${\n}Cleanup potential pending campaigns...
  @{list_of_vins}=  SPLIT STRING  ${vins}  ,
  FOR  ${vin}  IN  @{list_of_vins}
    ${verdict}  ${comment}=  CANCEL VEHICLE PENDING OPERATIONS  ${vin}
    SHOULD BE TRUE  ${verdict}  ${comment}
  END
  LOG TO CONSOLE  ...Done

GET CAMPAIGN RESULT CODES
  [Documentation]  Get the campaign result code for each vin.
  ...  | *Keyword*                 |
  ...  | GET CAMPAIGN RESULT CODES |
  ${campaign_id}=  GET VARIABLE VALUE  ${camp_id}
  &{result}=  CREATE DICTIONARY
  ${verdict}  ${message}  ${data}=  GET CAMPAIGN OPERATION DETAILS  ${campaign_id}
  SHOULD BE TRUE  ${verdict}  ${message}
  FOR  ${vin}  ${vin_data}  IN  &{data}
    ${code}=  GET DICT VALUE  ${vin_data}  ResultCode  9999
    ${message}=  GET DICT VALUE  ${vin_data}  ResultCodeMessage
    ${extended}=  GET DICT VALUE  ${vin_data}  ResultCodeExtended
    &{res_vin}=  CREATE DICTIONARY  code  ${code}  message  ${message}  extended  ${extended}
    SET TO DICTIONARY  ${result}  ${vin}  ${res_vin}
  END
  RETURN FROM KEYWORD  ${result}

GET VIN RESULTS
  [Documentation]  Get the campaign extended result codes for the `vin` defined as argument.
  ...  Result is a dictionary like {'code', 'message', 'extended'}
  ...  | *Result* | *Keyword*      | *Vin* |
  ...  | &{codes} | GET VIN RESULTS| VIN1  |
  [Arguments]  ${vin}
  ${codes}=  GET CAMPAIGN RESULT CODES
  ${vin_result}=  GET FROM DICTIONARY  ${codes}  ${vin}
  RETURN FROM KEYWORD  ${vin_result}

GET VIN RESULT CODE
  [Documentation]  Get the campaign result code for the `vin` defined as argument.
  ...  Result is a numeric result code.
  ...  | *Result* | *Keyword*           | *Vin* |
  ...  | ${code}  | GET VIN RESULT CODE | VIN1  |
  [Arguments]  ${vin}
  ${vin_result}=  GET VIN RESULTS  ${vin}
  ${code}=  GET FROM DICTIONARY  ${vin_result}  code
  RETURN FROM KEYWORD  ${code}

GET VIN RESULT MESSAGE
  [Documentation]  Get the campaign result code for the `vin` defined as argument.
  ...  Result is a numeric result code.
  ...  | *Result* | *Keyword*              | *Vin* |
  ...  | ${code}  | GET VIN RESULT MESSAGE | VIN1  |
  [Arguments]  ${vin}
  ${vin_result}=  GET VIN RESULTS  ${vin}
  ${code}=  GET FROM DICTIONARY  ${vin_result}  message
  RETURN FROM KEYWORD  ${code}

GET VIN EXTENDED RESULT CODES
  [Documentation]  Get the campaign extended result code for the `vin` defined as argument.
  ...  Result is a result code description as text.
  ...  | *Result*         | *Keyword*                    | *Vin* |
  ...  | ${extended_code} | GET VIN EXTENDED RESULT CODES | VIN1  |
  [Arguments]  ${vin}
  ${vin_result}=  GET VIN RESULTS  ${vin}
  ${extended_code}=  GET FROM DICTIONARY  ${vin_result}  extended
  RETURN FROM KEYWORD  ${extended_code}

GET VIN EVENTS
  [Documentation]  Get list of events linked to the desired vincampaign result code for desired vins.
  ...  | *Keyword*      | *Vin* |
  ...  | GET VIN EVENTS | VIN1  |
  [Arguments]  ${vin}
  ${campaign_id}=  GET VARIABLE VALUE  ${camp_id}
  @{list_of_vins}=  SPLIT STRING  ${vins}  ,
  ${result}=  CREATE DICTIONARY
  ${verdict}  ${message}  ${data}=  GET CAMPAIGN OPERATION DETAILS  ${campaign_id}
  SHOULD BE TRUE  ${verdict}  ${message}
  RETURN FROM KEYWORD  ${data}[${vin}][Events]

DEFINE CAMPAIGN DURATION
  [Documentation]  Define campaign duration in hours
  ...  | *Keyword*                 | *Duration* |
  ...  | DEFINE CAMPAIGN DURATION | 2days      |
  ...  | DEFINE CAMPAIGN DURATION | 5h         |
  ...  | DEFINE CAMPAIGN DURATION | 7250       |
  [Arguments]  ${duration}=1day
  ${seconds}=  robot.libraries.DateTime.CONVERT TIME  ${duration}
  ${days}=  EVALUATE  int((${seconds}+86399)/86400)
  SET CAMPAIGN DURATION  duration=${days}

GET CAMPAIGN NAME
  [Documentation]  Extract campaign name from the dhmi file in expected language
  ...  | *Keyword*         | *Language* |
  ...  | GET CAMPAIGN NAME | fr_FR      |
  ...  | GET CAMPAIGN NAME | en-GB      |
  [Arguments]  ${lang}
  ${lang}=  REPLACE STRING  ${lang}  -  _
  ${hmi_file}=  GET VARIABLE VALUE  ${dynamic_hmi}
  ${verdict}  ${comment}  ${rn}=  EXTRACT RELEASE NOTE  ${lang}  ${hmi_file}
  SHOULD BE TRUE  ${verdict}  ${comment}
  RETURN FROM KEYWORD  ${rn}[campaign_name]

GET CAMPAIGN DESCRIPTION
  [Documentation]  Extract campaign description from the dhmi file in expected language
  ...  | *Keyword*         | *Language* |
  ...  | GET CAMPAIGN DESCRIPTION | fr_FR      |
  ...  | GET CAMPAIGN DESCRIPTION | en-GB      |
  [Arguments]  ${lang}
  ${lang}=  REPLACE STRING  ${lang}  -  _
  ${hmi_file}=  GET VARIABLE VALUE  ${dynamic_hmi}
  ${verdict}  ${comment}  ${rn}=  EXTRACT RELEASE NOTE  ${lang}  ${hmi_file}
  SHOULD BE TRUE  ${verdict}  ${comment}
  ${camp_descr}=  REPLACE STRING  ${rn}[campaign_desc]  ${\n}  CarriageReturn
  RETURN FROM KEYWORD  ${camp_descr}

GET DICT VALUE
  [Documentation]  Return the value of the dictionary key, or default value if key is missing
  ...  | *Keyword*      | *Dictionary* | *Key* | *Default Value* |
  ...  | GET DICT VALUE | MyDict       | MyKey |                 |
  ...  | GET DICT VALUE | MyDict       | MyKey | missing key     |
  [Arguments]  ${dictionary}  ${key}  ${default_value}=NoData
  ${key_found}=  RUN KEYWORD AND RETURN STATUS  DICTIONARY SHOULD CONTAIN KEY  ${dictionary}  ${key}
  RETURN FROM KEYWORD IF  ${key_found}==False  ${default_value}
  RETURN FROM KEYWORD  ${dictionary}[${key}]

CHECK CAMPAIGN FAILURE
  [Documentation]  Wait until campaign closed then check Failure status
  ...  A warn message is added in the log if the duration exceeds `warning`.
  ...  Keyword returns failure if the duration exceeds `timeout`.
  ...  | *Keyword*              | *Timeout* | *Warning* |
  ...  | CHECK CAMPAIGN FAILURE | 30min     | 10min     |
  ...  | CHECK CAMPAIGN FAILURE | 30min     |           |
  [Arguments]  ${timeout}=1h  ${warning}=${EMPTY}
  WAIT CAMPAIGN RESULT  timeout=${timeout}  warning=${warning}
  ${campaign_id}=  GET VARIABLE VALUE  ${camp_id}
  ${verdict}  ${message}  ${stats}=  GET CAMPAIGN STATISTICS  ${campaign_id}
  SHOULD BE TRUE  ${verdict}  ${message}
  ${nb_vin}=  GET FROM DICTIONARY  ${stats}  totalVin
  ${success}=  GET FROM DICTIONARY  ${stats}  updateSuccessCount
  SHOULD BE EQUAL AS INTEGERS     ${success}    0