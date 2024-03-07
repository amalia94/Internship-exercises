*** Settings ***
Library   Collections
Library   String
Library   OperatingSystem


*** Keywords ***
GET DHMI TEMPLATE
  [Arguments]  ${file}=dhmi_template
  ${dhmi_template}=  JOIN PATH  %{FOTA_RESOURCES}  dhmi_definition  ${file}.json
  ${json_template}=  GET BINARY FILE  ${dhmi_template}
  ${object}=  EVALUATE  json.loads('''${json_template}''')  json
  ${json_string}=  EVALUATE  json.dumps(${object})  json
  RETURN FROM KEYWORD  ${json_string}

SET STEP1 BUTTONS
  [Arguments]  ${object}  ${phase}
  &{buttons}=  CREATE DICTIONARY  BtnAcceptConsent=LABEL_FOTA_BUTTON_001  BtnPostpone=LABEL_FOTA_BUTTON_007  BtnCancel=LABEL_FOTA_BUTTON_004  BtnDetails=LABEL_FOTA_BUTTON_005
  @{messages}=  SPLIT STRING    LABEL_FOTA_MESSAGE_100  ,
  &{stateMessages}=  CREATE DICTIONARY  messages=${messages}
  SET TO DICTIONARY  ${object["Step1"]}[${phase}]  buttons=${buttons}  stateMessages=${stateMessages}
  RETURN FROM KEYWORD  ${object}

SET DOWNLOAD CONSENT
  [Arguments]  ${json}  ${state}=YES
  ${object}=  EVALUATE  json.loads('''${json}''')  json
  IF  '${state}'=='YES'
    SET TO DICTIONARY  ${object["Step1"]}[0]    isSilent=${False}
  ELSE
    SET TO DICTIONARY  ${object["Step1"]}[0]    isSilent=${True}
  END
  ${object}=  SET STEP1 BUTTONS  ${object}  0
  SET TO DICTIONARY  ${object["Step2"]["DownloadPhase"]}  IsDownloadConsent=${state}  IsEasyUpdate=NO  IsWifi=NO  IsUSB=NO
  ${json_string}=  EVALUATE  json.dumps(${object})  json
  RETURN FROM KEYWORD  ${json_string}

SET INSTALLATION CONSENT
  [Arguments]  ${json}  ${state}
  ${object}=  EVALUATE  json.loads('''${json}''')  json
  RUN KEYWORD IF  '${state}'=='YES'  SET TO DICTIONARY  ${object["Step1"]}[1]    isSilent=${False}
  ${object}=  RUN KEYWORD IF  '${state}'=='YES'  SET STEP1 BUTTONS  ${object}  1
          ...  ELSE  SET VARIABLE  ${object}
  SET TO DICTIONARY  ${object["Step2"]["InstallationPhase"]}  IsInstallationConsent=${state}
  ${json_string}=  EVALUATE  json.dumps(${object})  json
  RETURN FROM KEYWORD  ${json_string}

SET ACTIVATION CONSENT
  [Arguments]  ${json}  ${state}
  ${object}=  EVALUATE  json.loads('''${json}''')  json
  RUN KEYWORD IF  '${state}'=='YES'  SET TO DICTIONARY  ${object["Step1"]}[2]    isSilent=${False}
  ${object}=  RUN KEYWORD IF  '${state}'=='YES'  SET STEP1 BUTTONS  ${object}  2
          ...  ELSE  SET VARIABLE  ${object}
  SET TO DICTIONARY  ${object["Step2"]["ActivationPhase"]}  IsActivationConsent=${state}
  ${json_string}=  EVALUATE  json.dumps(${object})  json
  RETURN FROM KEYWORD  ${json_string}

SET INSTALL ESTIMATED TIME
  [Arguments]  ${json}  ${estimated_time}
  ${object}=  EVALUATE  json.loads('''${json}''')  json
  SET TO DICTIONARY  ${object["Step2"]["InstallationPhase"]}  EstimatedInstallationTimeStamp=${estimated_time}
  @{estimated_time}=  SPLIT STRING  ${estimated_time}  :
  ${hours}=  CONVERT TO INTEGER  ${estimated_time}[0]
  ${minutes}=  CONVERT TO INTEGER  ${estimated_time}[1]
  ${seconds}=  CONVERT TO INTEGER  ${estimated_time}[2]
  &{EstimatedInstallationTime}=  CREATE DICTIONARY  h=${hours}  m=${minutes}  s=${seconds}
  SET TO DICTIONARY  ${object["Step2"]["InstallationPhase"]}  EstimatedInstallationTime=${EstimatedInstallationTime}
  ${json_string}=  EVALUATE  json.dumps(${object})  json
  RETURN FROM KEYWORD  ${json_string}

SET ACTIVATION ESTIMATED TIME
  [Arguments]  ${json}  ${estimated_time}
  SET SUITE VARIABLE  ${activation_estimated_time}  ${estimated_time}
  ${object}=  EVALUATE  json.loads('''${json}''')  json
  SET TO DICTIONARY  ${object["Step2"]["ActivationPhase"]}  EstimatedActivationTimeStamp=${estimated_time}
  @{estimated_time}=  SPLIT STRING  ${estimated_time}  :
  ${hours}=  CONVERT TO INTEGER  ${estimated_time}[0]
  ${minutes}=  CONVERT TO INTEGER  ${estimated_time}[1]
  ${seconds}=  CONVERT TO INTEGER  ${estimated_time}[2]
  &{EstimatedActivationTime}=  CREATE DICTIONARY  h=${hours}  m=${minutes}  s=${seconds}
  SET TO DICTIONARY  ${object["Step2"]["ActivationPhase"]}  EstimatedActivationTime=${EstimatedActivationTime}
  ${json_string}=  EVALUATE  json.dumps(${object})  json
  RETURN FROM KEYWORD  ${json_string}

SET DHMI VEHICLE CONDITIONS
  [Arguments]  ${json}  ${phase}  ${DriveStage}=NA  ${VehicleMotion}=NA  ${ParkingBrake}=NA  ${HVSOC}=NA  ${HazardLamps}=NA
  ${DriveStage}=  CONVERT TO UPPERCASE  ${DriveStage}
  ${VehicleMotion}=  CONVERT TO UPPERCASE  ${VehicleMotion}
  ${ParkingBrake}=  CONVERT TO UPPERCASE  ${ParkingBrake}
  ${HVSOC}=  CONVERT TO UPPERCASE  ${HVSOC}
  ${HazardLamps}=  CONVERT TO UPPERCASE  ${HazardLamps}
  ${object}=  EVALUATE  json.loads('''${json}''')  json
  ${phase}=  CATENATE  SEPARATOR=  ${phase}  Phase
  SET TO DICTIONARY  ${object["Step2"]["${phase}"]}  HMIConditionParkingBrake=${ParkingBrake}  HMIConditionVehicleMotion=${VehicleMotion}  HMIConditionDriveStage=${DriveStage}  HMIConditionHazardLamps=${HazardLamps}  HMIConditionHVSoc=${HVSOC}
  ${json_string}=  EVALUATE  json.dumps(${object})  json
  RETURN FROM KEYWORD  ${json_string}

SET DHMI RELEASE NOTE
  [Arguments]  ${json}  ${lang}  ${campaign_name}  ${text}=${EMPTY}
  ${object}=  EVALUATE  json.loads('''${json}''')  json
  ${lang}=  REPLACE STRING  ${lang}  -  _
  @{rns_before}=  GET FROM DICTIONARY  ${object["Step2"]}  ReleaseNotes
  @{rns_after}=  CREATE LIST
  &{ReleaseNote}=  CREATE DICTIONARY  lang=${lang}  releaseNote=${text}  name=${campaign_name}
  IF  ${rns_before} == @{EMPTY}
    APPEND TO LIST  ${rns_after}  ${ReleaseNote}
  ELSE
    FOR  ${rn}  IN  @{rns_before}
      IF  '${rn}[lang]'=='${lang}'
        APPEND TO LIST  ${rns_after}  ${ReleaseNote}
      ELSE
        APPEND TO LIST  ${rns_after}  ${rn}
      END
    END
  END
  SET TO DICTIONARY  ${object["Step2"]}  ReleaseNotes  ${rns_after}
  ${json_string}=  EVALUATE  json.dumps(${object})  json
  RETURN FROM KEYWORD  ${json_string}

SET ACTIVATION DISCLAIMER ID
  [Arguments]  ${json}  ${id}
  ${id}=  CONVERT TO UPPERCASE  ${id}
  ${id}=  SET VARIABLE IF  '${id}'=='${EMPTY}'  ADID2  ${id}
  ${id}=  SET VARIABLE IF  'ADID' in '${id}'  ${id}  ADID${id}
  ${object}=  EVALUATE  json.loads('''${json}''')  json
  SET TO DICTIONARY  ${object["Step2"]["ActivationPhase"]}  ActivationStaticDisclaimer=${id}
  ${json_string}=  EVALUATE  json.dumps(${object})  json
  RETURN FROM KEYWORD  ${json_string}

SET SCHEDULE ACTIVATION
  [Arguments]  ${json}  ${state}=${None}
  ${state}=  CONVERT TO UPPERCASE  ${state}
  ${state}=  SET VARIABLE IF  '${state}'=='YES'  YES  ${None}
  ${object}=  EVALUATE  json.loads('''${json}''')  json
  SET TO DICTIONARY  ${object["Step2"]["ActivationPhase"]}  ScheduleActivation=${state}
  ${json_string}=  EVALUATE  json.dumps(${object})  json
  RETURN FROM KEYWORD  ${json_string}

SAVE DHMI
  [Arguments]  ${json}  ${filename}
  ${json}=  REPLACE STRING  ${json}  CarriageReturn  \\n
  ${path}=  JOIN PATH  ${OUTPUT DIR}  JSON_DHMI
  OperatingSystem.CREATE DIRECTORY  ${path}
  ${path}=  JOIN PATH  ${path}  ${filename}.json
  OperatingSystem.CREATE FILE  ${path}  ${json}  
  RETURN FROM KEYWORD  ${path}

CONFIGURE REGULARFULL DHMI
  [Documentation]    Configure a regularFull dynamic HMI from an json template
  ...  |        *Keyword*           |
  ...  | CONFIGURE REGULARFULL DHMI |

  [Arguments]  ${disclaimer}=ADID0
  ${content}=  CONFIGURE REGULAR DHMI  ${disclaimer}
  ${content}=  SET INSTALLATION CONSENT  ${content}  YES
  ${content}=  SET DHMI VEHICLE CONDITIONS  ${content}  Installation
  ${content}=  SET INSTALL ESTIMATED TIME  ${content}  00:45:00
  RETURN FROM KEYWORD  ${content}

CONFIGURE REGULAR DHMI
  [Documentation]    Configure a regular dynamic HMI from an json template
  ...  |        *Keyword*       |
  ...  | CONFIGURE REGULAR DHMI |

  [Arguments]  ${disclaimer}=ADID0
  ${content}=  CONFIGURE SILENT DHMI
  ${content}=  SET DOWNLOAD CONSENT  ${content}
  ${content}=  SET DHMI VEHICLE CONDITIONS  ${content}  Download
  ${content}=  SET ACTIVATION CONSENT  ${content}  YES
  ${content}=  SET DHMI VEHICLE CONDITIONS  ${content}  Activation
  ${content}=  SET ACTIVATION DISCLAIMER ID  ${content}  ${disclaimer}
  ${content}=  SET ACTIVATION ESTIMATED TIME  ${content}  00:30:00
  ${content}=  SET SCHEDULE ACTIVATION  ${content}  NO
  RETURN FROM KEYWORD  ${content}

CONFIGURE SILENT DHMI
  [Documentation]    Configure a silent dynamic HMI from an json template
  ...  |       *Keyword*       |
  ...  | CONFIGURE SILENT DHMI |

  ${content}=  GET DHMI TEMPLATE
  ${content}=  SET DHMI RELEASE NOTE  ${content}  en_GB  FOTA Update Campaign  This is a FOTA test campaign.CarriageReturnIt allows to test FOTA.
  ${content}=  SET DHMI RELEASE NOTE  ${content}  fr_FR  Campagne de mise à jour FOTA  Ceci est une campagne de test FOTA.CarriageReturnElle permet de tester le FOTA.
  RETURN FROM KEYWORD  ${content}

CONFIGURE DO NOT DISTURB DHMI
  [Documentation]    Configure a do not disturb dynamic HMI from an json template
  ...  |           *Keyword*           |
  ...  | CONFIGURE DO NOT DISTURB DHMI |
  
  ${content}=  CONFIGURE SILENT DHMI
  ${content}=  SET ACTIVATION CONSENT  ${content}  YES
  ${content}=  SET DHMI VEHICLE CONDITIONS  ${content}  Activation
  ${content}=  SET ACTIVATION DISCLAIMER ID  ${content}  ADID0
  ${content}=  SET ACTIVATION ESTIMATED TIME  ${content}  00:30:00
  RETURN FROM KEYWORD  ${content}
  
CONFIGURE VESPA DHMI
  [Documentation]    Configure a do not disturb dynamic HMI from an json template
  ...  | *Keyword*            | *Disclaimer* | *Schedule* |
  ...  | CONFIGURE VESPA DHMI | ADID3        | YES        |
  [Arguments]  ${disclaimer}=ADID3  ${schedule}=NO
  ${content}=  CONFIGURE DO NOT DISTURB DHMI
  ${content}=  SET ACTIVATION CONSENT  ${content}  YES
  ${content}=  SET ACTIVATION DISCLAIMER ID  ${content}  ${disclaimer}
  ${content}=  SET DHMI RELEASE NOTE  ${content}  en_GB  VESPA Update Campaign  Vespa update campaign ${disclaimer}.
  ${content}=  SET DHMI RELEASE NOTE  ${content}  fr_FR  Campagne de mise à jour VESPA  Campagne de mise à jour Vespa ${disclaimer}.
  ${content}=  SET SCHEDULE ACTIVATION  ${content}  ${schedule}
  ${content}=  SET DHMI VEHICLE CONDITIONS  ${content}  Activation  DriveStage=AFTERDRIVING  VehicleMotion=STOPPED  ParkingBrake=ON  HazardLamps=OFF
  RETURN FROM KEYWORD  ${content}

CONFIGURE REGULARFULL DHMI INSTALL LATER
  [Documentation]    Configure regular full with DriverStage
  ...  |           *Keyword*                  |
  ...  | CONFIGURE REGULARFULL DHMI INSTALL LATER |
  ${content}=  CONFIGURE SILENT DHMI
  ${content}=  SET DOWNLOAD CONSENT  ${content}
  ${content}=  SET DHMI VEHICLE CONDITIONS  ${content}  Download
  ${content}=  SET INSTALLATION CONSENT  ${content}  YES
  ${content}=  SET DHMI VEHICLE CONDITIONS  ${content}  Installation  DriveStage=DURINGDRIVING
  ${content}=  SET INSTALL ESTIMATED TIME  ${content}  00:45:00
  ${content}=  SET ACTIVATION CONSENT  ${content}  YES
  ${content}=  SET DHMI VEHICLE CONDITIONS  ${content}  Activation
  ${content}=  SET ACTIVATION DISCLAIMER ID  ${content}  ADID0
  ${content}=  SET ACTIVATION ESTIMATED TIME  ${content}  00:30:00
  ${content}=  SET SCHEDULE ACTIVATION  ${content}  YES
  Return From Keyword  ${content}

CONFIGURE REGULARFULL DHMI ACTIVATION LATER
  [Documentation]    Configure regular full with DriverStage afterdriving.
  ...  |           *Keyword*                  |
  ...  | CONFIGURE REGULARFULL DHMI ACTIVATION LATER |
  ${content}=  CONFIGURE SILENT DHMI
  ${content}=  SET DOWNLOAD CONSENT  ${content}
  ${content}=  SET DHMI VEHICLE CONDITIONS  ${content}  Download
  ${content}=  SET INSTALLATION CONSENT  ${content}  YES
  ${content}=  SET DHMI VEHICLE CONDITIONS  ${content}  Installation
  ${content}=  SET INSTALL ESTIMATED TIME  ${content}  00:45:00
  ${content}=  SET ACTIVATION CONSENT  ${content}  YES
  ${content}=  SET DHMI VEHICLE CONDITIONS  ${content}  Activation  DriveStage=AFTERDRIVING
  ${content}=  SET ACTIVATION DISCLAIMER ID  ${content}  ADID0
  ${content}=  SET ACTIVATION ESTIMATED TIME  ${content}  00:30:00
  ${content}=  SET SCHEDULE ACTIVATION  ${content}  YES
  RETURN FROM KEYWORD  ${content}
