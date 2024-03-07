*** Settings ***
Library   Collections
Library   String
Library   OperatingSystem
Library   XML

*** Keywords ***
GET DHMI TEMPLATE
  [Arguments]  ${file}=dhmi_template
  ${dhmi_template}=  JOIN PATH  %{DHMI_CONFIG_PATH}  ${file}.xml
  ${xml_content}=  PARSE XML  ${dhmi_template}
  RETURN FROM KEYWORD  ${xml_content}

SET DOWNLOAD CONSENT 
  [Arguments]  ${content}  ${state}=YES
  ${new_content}=  SET ELEMENT TEXT  ${content}  ${state}  xpath=SignedData/Download/DownloadConsent
  RETURN FROM KEYWORD  ${new_content}

SET INSTALLATION CONSENT 
  [Arguments]  ${content}  ${state}=YES
  ${new_content}=  SET ELEMENT TEXT  ${content}  ${state}  xpath=SignedData/Installation/InstallConsent
  RETURN FROM KEYWORD  ${new_content}

SET INSTALL ESTIMATED TIME
  [Arguments]  ${content}  ${estimated_time}
  ${exists}=  RUN KEYWORD AND RETURN STATUS  ELEMENT SHOULD EXIST  ${content}  xpath=SignedData/Installation/InstallEstimatedTime
  IF  ${exists}==False
    ${content}=  ADD ELEMENT  ${content}  <InstallEstimatedTime/>  xpath=SignedData/Installation
  END
  ${new_content}=  SET ELEMENT TEXT  ${content}  ${estimated_time}  xpath=SignedData/Installation/InstallEstimatedTime
  RETURN FROM KEYWORD  ${content}

SET ACTIVATION ESTIMATED TIME
  [Arguments]  ${content}  ${estimated_time}
  ${exists}=  RUN KEYWORD AND RETURN STATUS  ELEMENT SHOULD EXIST  ${content}  xpath=SignedData/Activation/ActivationEstimatedTime
  IF  ${exists}==False
    ${content}=  ADD ELEMENT  ${content}  <ActivationEstimatedTime/>  xpath=SignedData/Activation
  END
  ${new_content}=  SET ELEMENT TEXT  ${content}  ${estimated_time}  xpath=SignedData/Activation/ActivationEstimatedTime
  RETURN FROM KEYWORD  ${content}

SET ACTIVATION CONSENT 
  [Arguments]  ${content}  ${state}=YES
  ${new_content}=  SET ELEMENT TEXT  ${content}  ${state}  xpath=SignedData/Activation/ActivationConsent
  RETURN FROM KEYWORD  ${new_content}

SET ACTIVATION DISCLAIMER ID
  [Arguments]  ${content}  ${id}
  ${id}=  CONVERT TO UPPERCASE  ${id}
  ${id}=  SET VARIABLE IF  '${id}'=='${EMPTY}'  ADID2  ${id}
  ${id}=  SET VARIABLE IF  'ADID' in '${id}'  ${id}  ADID${id}
  ${exists}=  RUN KEYWORD AND RETURN STATUS  ELEMENT SHOULD EXIST  ${content}  xpath=SignedData/Activation/ActivationDisclaimer
  IF  ${exists}==False
    ${content}=  ADD ELEMENT  ${content}  <ActivationDisclaimer/>  xpath=SignedData/Activation
    ${content}=  ADD ELEMENT  ${content}  <ActivationDisclaimerID/>  xpath=SignedData/Activation/ActivationDisclaimer
  END
    ${content}=  SET ELEMENT TEXT  ${content}  ${id}  xpath=SignedData/Activation/ActivationDisclaimer/ActivationDisclaimerID
  RETURN FROM KEYWORD  ${content}

SET SCHEDULE ACTIVATION
  [Arguments]  ${content}  ${state}=NO
  ${state}=  CONVERT TO UPPERCASE  ${state}
  ${state}=  SET VARIABLE IF  '${state}'=='YES'  YES  NO
  ${exists}=  RUN KEYWORD AND RETURN STATUS  ELEMENT SHOULD EXIST  ${content}  xpath=SignedData/Activation/ScheduleActivation
  IF  ${exists}==False
    ${content}=  ADD ELEMENT  ${content}  <ScheduleActivation/>  xpath=SignedData/Activation
  END
  ${content}=  SET ELEMENT TEXT  ${content}  ${state}  xpath=SignedData/Activation/ScheduleActivation
  RETURN FROM KEYWORD  ${content}

SET DHMI RELEASE NOTE
  [Arguments]  ${content}  ${lang}  ${campaign_name}  ${text}=${EMPTY}
  ${exists}=  RUN KEYWORD AND RETURN STATUS  ELEMENT SHOULD EXIST  ${content}  xpath=SignedData/GlobalData/ReleaseNote
  IF  ${exists}==False
    ${content}=  ADD ELEMENT  ${content}  <ReleaseNote/>  xpath=SignedData/GlobalData
  END
  ${exists}=  RUN KEYWORD AND RETURN STATUS  ELEMENT SHOULD EXIST  ${content}  xpath=SignedData/GlobalData/ReleaseNote/Translation[@lang="${lang}"]
  IF  ${exists}==True
    ${content}=  REMOVE ELEMENT  ${content}  xpath=SignedData/GlobalData/ReleaseNote/Translation[@lang="${lang}"]
  END
  ${content}=  ADD ELEMENT  ${content}  <Translation lang="${lang}" name="${campaign_name}">${text}</Translation>  xpath=SignedData/GlobalData/ReleaseNote
  RETURN FROM KEYWORD  ${content}

SET DHMI VEHICLE CONDITIONS
  [Arguments]  ${content}  ${phase}  ${DriveStage}=NA  ${VehicleMotion}=NA  ${ParkingBrake}=NA  ${HVSOC}=NA  ${HazardLamps}=NA
  ${exists}=  RUN KEYWORD AND RETURN STATUS  ELEMENT SHOULD EXIST  ${content}  xpath=SignedData/${phase}/HMIConditions
  IF  ${exists}==True
    ${content}=  REMOVE ELEMENT  ${content}  xpath=SignedData/${phase}/HMIConditions
  END
  ${DriveStage}=  CONVERT TO UPPERCASE  ${DriveStage}
  ${VehicleMotion}=  CONVERT TO UPPERCASE  ${VehicleMotion}
  ${ParkingBrake}=  CONVERT TO UPPERCASE  ${ParkingBrake}
  ${HVSOC}=  CONVERT TO UPPERCASE  ${HVSOC}
  ${HazardLamps}=  CONVERT TO UPPERCASE  ${HazardLamps}
  ${content}=  ADD ELEMENT  ${content}  <HMIConditions DriveStage="${DriveStage}" VehicleMotion="${VehicleMotion}" ParkingBrake="${ParkingBrake}" HVSOC="${HVSOC}" HazardLamps="${HazardLamps}"/>  xpath=SignedData/${phase}
  RETURN FROM KEYWORD  ${content}

SAVE DHMI
  [Arguments]  ${content}  ${filename}
  ${path}=  JOIN PATH  ${OUTPUT DIR}  XML_DHMI
  OperatingSystem.CREATE DIRECTORY  ${path}
  ${path}=  JOIN PATH  ${path}  ${filename}.xml
  SAVE XML  ${content}  ${path}
  RETURN FROM KEYWORD  ${path}

CONFIGURE REGULARFULL DHMI
  [Documentation]    Configure a regularFull dynamic HMI from an xml template
  ...  |        *Keyword*           |
  ...  | CONFIGURE REGULARFULL DHMI |

  [Arguments]  ${disclaimer}=ADID0
  ${content}=  CONFIGURE REGULAR DHMI  ${disclaimer}
  ${content}=  SET INSTALLATION CONSENT  ${content}  YES
  ${content}=  SET DHMI VEHICLE CONDITIONS  ${content}  Installation
  ${content}=  SET INSTALL ESTIMATED TIME  ${content}  00:45:00
  RETURN FROM KEYWORD  ${content}

CONFIGURE REGULAR DHMI
  [Documentation]    Configure a regular dynamic HMI from an xml template
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
  [Documentation]    Configure a silent dynamic HMI from an xml template
  ...  |       *Keyword*       |
  ...  | CONFIGURE SILENT DHMI |

  ${xml_content}=  GET DHMI TEMPLATE
  ${xml_content}=  SET DHMI RELEASE NOTE  ${xml_content}  en_GB  FOTA Update Campaign  This is a FOTA test campaign.&#xA; It allows to test FOTA.
  ${xml_content}=  SET DHMI RELEASE NOTE  ${xml_content}  fr_FR  Campagne de mise à jour FOTA  Ceci est une campagne de test FOTA.&#xA;Elle permet de tester le FOTA.
  RETURN FROM KEYWORD  ${xml_content}

CONFIGURE DO NOT DISTURB DHMI
  [Documentation]    Configure a do not disturb dynamic HMI from an xml template
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
  ${content}=  SET SCHEDULE ACTIVATION  ${content}  NO
  RETURN FROM KEYWORD  ${content}

