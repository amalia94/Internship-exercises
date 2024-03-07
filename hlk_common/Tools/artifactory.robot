#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Documentation     Artifactory utility
Library           rfw_libraries.toolbox.Artifactory
Library           OperatingSystem
Library           String

*** Variables ***
${artifactory_path}    https://artifactory.dt.renault.com/artifactory

*** Keywords ***
DOWNLOAD ARTIFACTORY FILE
    [Arguments]     ${path}    ${keep_existing_file}=${TRUE}
    [Documentation]    == High Level Description: ==
    ...    Download the expected file from artifactory.
    ...    == Arguments: ==
    ...    path: Path to download from artifactory
    ...    keep_existing_file: Keep or delete the existing file
    ${file_split}=    Split String From Right    ${path}    /    1
    ${file_split}=    Get From List    ${file_split}    1
    Run Keyword If    ${keep_existing_file}==${FALSE}    OperatingSystem.remove file     ${file_split}
    ${status}    ${file} =    DOWNLOAD FILE FROM ARTIFACTORY    ${path}
    Should Be True    ${status}    file cannot be downloaded from artifactory

PUSH FILES TO ARTIFACTORY
    [Arguments]    ${source}    ${destination}=${None}
    [Documentation]  Uploads files to artifactory
    ...    source : The location of the file to be uploaded
    ...    destination: The location where the file is uploaded (artifactory) ${None} means do not push the files to artifactory
    Return From Keyword If    "${destination}" == "${None}"
    ${verdict} =    UPLOAD FILE TO ARTIFACTORY    ${source}    ${destination}
    Should Be True    ${verdict}    Failed to UPLOAD FILES TO ARTIFACTORY
    Log    Logs artifactory path: ${artifactory_path}/${destination}    console="yes"

PUSH FOLDER TO ARTIFACTORY
    [Arguments]    ${source_folder}    ${destination}=${None}
    [Documentation]  Uploads folder to artifactory keeping folder structure
    ...    source_folder : Folder to be uploaded
    ...    destination: artifactory path. ${None} means do not push the files to artifactory
    Return From Keyword If    "${destination}" == "${None}"
    ${files} =    OperatingSystem.Run    find ${source_folder} -type f -exec printf "%q\n" {} \\;
    ${lines} =    Split To Lines   ${files}
    FOR    ${line}    IN    @{lines}
      ${path} =    Normalize Path    ${line}
      PUSH FILES TO ARTIFACTORY    ${path}    ${destination}/${path}
    END
    Log    Logs artifactory path: ${artifactory_path}/${destination}    console="yes"

DISPLAY ARTIFACTORY LOGS PATH
    [Arguments]    ${destination}=${None}
    Log    Logs artifactory path: ${artifactory_path}/${destination}    WARN