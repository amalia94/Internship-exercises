#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Documentation     filesystem keywords library
Library           rfw_services.ivi.SystemLib    device=${ivi_adb_id}
Library           rfw_services.ivi.FileSystemLib    device=${ivi_adb_id}
Library           rfw_services.ivi.LemonadLib    device=${ivi_adb_id}
Library           String
Library           OperatingSystem

*** Variables ***
${mode}           running
${bench_path}     .

*** Keywords ***
CHECKSET FILE PRESENT
    [Arguments]    ${target_id}    ${file}
    [Documentation]    Check file presence on a target and copy it if absent
    ...    ${target_id} either the bench or DUT
    ...    ${file} path and file name to search
    Run Keyword If    "${target_id}" == "bench"    CHECKSET FILE PRESENT ON BENCH    ${target_id}    ${file}
    Run Keyword If    "${target_id}" == "ivi"    CHECKSET FILE PRESENT ON IVI    ${target_id}    ${file}

CHECKSET FILE PRESENT ON BENCH
    [Arguments]    ${target_id}    ${file}
    [Documentation]    Check file presence on a target and copy it if absent
    ...    ${target_id} bench
    ...    ${file} path and file name to search
    ...    ${download_url} All test cases have to initialize this variable to get this keyword to work properly
    ${d_name}    ${f_name} =    OperatingSystem.Split Path    ${file}
    @{first_files} =    OperatingSystem.List Files In Directory    ${d_name}
    ${first_check} =    Set Variable If    $f_name in $first_files    True    False
    ${is_downloaded} =    Run Keyword If    "${first_check}" == "False"    DOWNLOAD FILE FROM ARTIFACTORY    ${download_url}${f_name}
    Run Keyword If    "${first_check}" == "False"    Should Be True    ${is_downloaded}    File not downloaded
    Run Keyword If    "${first_check}" == "False"    OperatingSystem.Move File    ${bench_path}/${f_name}    ${d_name}
    @{second_files} =    Run Keyword If    "${first_check}" == "False"    OperatingSystem.List Files In Directory    ${d_name}
    ${second_check} =    Run Keyword If    "${first_check}" == "False"    Set Variable If    $f_name in $second_files    True    False
    ${is_present} =    Set Variable If    "${first_check}" != "False"    ${first_check}    ${second_check}
    Should Be True    ${is_present}    File not present on target

CHECKSET FILE PRESENT ON IVI
    [Arguments]    ${target_id}    ${file}
    [Documentation]    Check file presence on a target and copy it if absent
    ...    ${target_id} DUT
    ...    ${file} path and file name to search
    ...    ${download_url} All test cases have to initialize this variable to get this keyword to work properly
    ${first_check} =    CHECK FILE PRESENT    ${target_id}    ${file}
    Return From Keyword If    "${first_check}" == "True"
    ${file_name} =    Fetch From Right    ${file}    /
    ${status}    ${downloaded_file} =    DOWNLOAD FILE FROM ARTIFACTORY    ${download_url}${file_name}
    Should Be True    ${status}    File not downloaded
    SET FILE COPY    bench    ${target_id}    ${downloaded_file}    ${file}
    ${second_check} =    CHECK FILE PRESENT    ${target_id}    ${file}
    Should Be True    ${second_check}    File not present on target

SET CREATE FOLDER
    [Arguments]    ${target_id}    ${folder}
    [Documentation]    Create a folder on a dedicated target
    ...    ${target_id} DUT
    ...    ${folder} path and folder name to create
    Run Keyword If    "${target_id}" != "ivi"    Fail    Target id: ${target_id} is not implemented
    ${is_created} =    rfw_services.ivi.FileSystemLib.CREATE FOLDER    ${folder}
    Should Be True    ${is_created}    Folder not created on the target

SET FILE COPY
    [Arguments]    ${source_target_id}    ${destination_target_id}    ${source_file}    ${destination_file}
    [Documentation]    Copy a file from a source target to a destination target
    ...    ${source_target_id} the target (either the bench or DUT) from where to copy the file
    ...    ${destination_target_id} the target (either DUT or USB drive) where to copy the file
    ...    ${source_file} path and file name to copy
    ...    ${destination_file} path and file name to get in the end
    SET ROOT
    Sleep    1    reason=Switching to adb root...
    IF    "${source_target_id}" == "bench" and "${destination_target_id}" == "ivi"
        ${stdout}    ${stderr} =    rfw_services.ivi.SystemLib.PUSH    ${source_file}    ${destination_file}
        IF    "${stderr}" != "${EMPTY}"
            ${is_created} =    Set Variable    ${FALSE}
        ELSE
            ${is_created} =    Set Variable    ${TRUE}
        END
    ELSE IF    "${source_target_id}" == "ivi" and "${destination_target_id}" == "bench"
        ${stdout}    ${stderr} =    rfw_services.ivi.SystemLib.PULL    ${source_file}    ${destination_file}
        IF    "${stderr}" != "${EMPTY}"
            ${is_created} =    Set Variable    ${FALSE}
        ELSE
            ${is_created} =    Set Variable    ${TRUE}
        END
    ELSE
        ${is_created} =    rfw_services.ivi.FileSystemLib.COPY FILE    ${source_target_id}    ${destination_target_id}    ${source_file}    ${destination_file}
    END
    Sleep    5    reason=Waiting for copy...
    Should Be True    ${is_created}    File not copied to destination target

SET MD5 COMPARE
    [Arguments]    ${source_target_id}    ${source_file}    ${destination_target_id}    ${destination_file}
    [Documentation]    Compare the MD5 sum of 2 files, and return True if MD5 sum is identical, False otherwise.
    ...    ${source_target_id} the target (either the bench or DUT) containing the first file to compare
    ...    ${destination_target_id} the target (either the bench or DUT) containing the second file to compare
    ...    ${source_file} path and file name of the first file for which to compute the MD5 sum
    ...    ${destination_file} path and file name of the second file for which to compute the MD5 sum
    ${md5_1} =    RUN KEYWORD IF    ${source_target_id} == "bench"    RUN    md5sum ${source_file}
    ...           ELSE    rfw_services.ivi.SystemLib.md5_sum    ${source_file}
    ${md5_2} =    RUN KEYWORD IF    ${destination_target_id} == "bench"    RUN    md5sum ${destination_file}
    ...           ELSE    rfw_services.ivi.SystemLib.md5_sum    ${destination_file}
    Should Be Equal    ${md5_1}    ${md5_2}    Different MD5 sums between files

CHECK FILE PRESENT
    [Arguments]    ${target_id}    ${file}
    [Documentation]    Return True if a file is present on a target, False otherwise.
    ...    ${target_id} either the bench or DUT
    ...    ${file} path and file name to check
    Run Keyword If    "${target_id}" != "ivi"    Fail    Target id: ${target_id} is not implemented
    ${is_present} =    rfw_services.ivi.FileSystemLib.IS FILE ON TARGET    ${file}
    [Return]    ${is_present}

SET DELETE FOLDER
    [Arguments]    ${target_id}    ${folder}
    [Documentation]    Delete a folder on a target
    ...    ${target_id} either the bench or DUT
    ...    ${folder} path and folder name to delete
    Run Keyword If    "${target_id}" == "bench"    SET DELETE FOLDER ON BENCH    ${folder}
    Run Keyword If    "${target_id}" == "ivi"    SET DELETE FOLDER ON IVI    ${folder}

SET DELETE FOLDER ON BENCH
    [Arguments]    ${folder}
    [Documentation]    Delete a folder on a bench
    ...    ${folder} path and folder name to delete
    ${is_deleted} =    Run Keyword And Return Status    OperatingSystem.Remove Directory    ${folder}    recursive=True
    Should Be True    ${is_deleted}    Folder not deleted on bench

SET DELETE FOLDER ON IVI
    [Arguments]    ${folder}
    [Documentation]    Delete a folder on IVI
    ...    ${folder} path and folder name to delete
    ${is_deleted} =    DELETE FOLDER OR FILE    ${folder}
    Should Be True    ${is_deleted}    Folder not deleted on IVI

SET DELETE FILE
    [Arguments]    ${target_id}    ${file}
    [Documentation]    Delete a file on on a target
    ...    ${target_id} either the bench or DUT
    ...    ${file} path and file name to delete
    Run Keyword If    "${target_id}" == "bench"    SET DELETE FILE ON BENCH    ${file}
    Run Keyword If    "${target_id}" == "ivi"    SET DELETE FILE ON IVI    ${file}

SET DELETE FILE ON BENCH
    [Arguments]    ${file}
    [Documentation]    Delete a file on bench
    ...    ${file} path and file name to delete
    ${is_deleted} =    Run Keyword And Return Status    OperatingSystem.Remove File   ${file}
    Should Be True    ${is_deleted}    File ${file} not deleted on bench

SET DELETE FILE ON IVI
    [Arguments]    ${file}
    [Documentation]    Delete a file on IVI
    ...    ${file} path and file name to delete
    ${is_deleted} =    DELETE FOLDER OR FILE    ${file}
    Should Be True    ${is_deleted}    File ${file} not deleted on IVI

CHECKSET DELETE FILE
    [Arguments]    ${target_id}    ${file}
    [Documentation]    Checks whether a file exists on target, and deletes it if it does
    ...    ${target_id} either the bench or DUT
    ...    ${file} the file to delete
    ${is_present} =    CHECK FILE PRESENT    ${target_id}    ${file}
    Run Keyword If    "${is_present}" == "True"    SET DELETE FILE    ${target_id}    ${file}

SET HOST FILE PERMISSION
    [Arguments]    ${access_permission}    ${file_name}
    [Documentation]    Changes the file permission
    ...    ${access_permission} permission of the file to be set
    ...    ${file_name} name and path of the file
    OperatingSystem.Run    chmod ${access_permission} ${file_name}
    ${result} =    OperatingSystem.Run    ls -lr ${file_name}
    ${to_check} =    ACCESS PERMISSION CONVERSATION    ${access_permission}
    Should Contain    ${result}    ${to_check}

ACCESS PERMISSION CONVERSATION
    [Arguments]    ${access_permission}
    [Documentation]    Convert numeric value to read/write/execute permission
    ${val} =    Convert To Integer    ${access_permission}
    ${val_status} =    Evaluate   ${val}<= 777
    ${string_len} =    Get Length    ${access_permission}
    ${status} =     Evaluate    ${string_len}==3
    Should Be True     ${status} and ${val_status}    Unexpected access type
    ${permission_dict} =    Create Dictionary    0=---   1=--x   2=-w-   3=-wx   4=r--   5=r-x   6=rw-   7=rwx
    ${output} =     Catenate    SEPARATOR=    ${permission_dict}[${access_permission}[0]]    ${permission_dict}[${access_permission}[1]]    ${permission_dict}[${access_permission}[2]]
    [return]    ${output}

SET UNCOMPRESS FILE
     [Arguments]    ${target}    ${file}
     [Documentation]    Uncompress a tar or zip file: ${file} on target: ${target}
     ...    ${target}  the platform on which the file will be uncompressed
     ...    ${file}    path to the file to be uncompressed
     Log To Console    Uncompress a tar or zip file: ${file} on target: ${target}
     ${path}    ${ext} =    OperatingSystem.Split Extension    ${file}
     ${err_zip}    ${out_zip} =    Run Keyword If    "${ext}" == "zip"    OperatingSystem.Run And Return Rc And Output   unzip -o ${file}
     ${err_tar}    ${out_tar} =    Run Keyword If    "${ext}" == "tar"    OperatingSystem.Run And Return Rc And Output   tar -xvf ${file}
     ${err_gz}    ${out_gz} =    Run Keyword If    "${ext}" == "gz"    OperatingSystem.Run And Return Rc And Output    tar -zxvf ${file}

     ${path_to_file} =    Set Variable If
     ...    "${ext}" == "zip"    ${out_zip}
     ...    "${ext}" == "tar"    ${out_tar}
     ...    "${ext}" == "gz"     ${out_gz}

     ${error} =    Set Variable If
     ...    "${ext}" == "zip"    ${err_zip}
     ...    "${ext}" == "tar"    ${err_tar}
     ...    "${ext}" == "gz"     ${err_gz}

     ${path_to_file} =    Remove String    ${path_to_file}    b'
     ${path_to_file} =    Split String     ${path_to_file}     \\n
     ${list_length} =    Get Length    ${path_to_file}
     ${path_to_file} =    Run Keyword If    ${list_length} <= 2    Set Variable    ${path_to_file}[0]
     ...    ELSE    Set Variable     ${path_to_file}[-2]
     ${path_to_file} =    Remove String    ${path_to_file}    \\n
     ${path_to_file} =    Remove String    ${path_to_file}    '

     Should Be Equal As Integers    ${error}    0    File: ${file} could not be uncompressed
     [Return]    ${path_to_file}

CHECK MAP FILE PRESENT ON IVI
    [Arguments]    ${map_path}    ${file}    ${is_file_present}=True
    [Documentation]    Return True if a file is present on specified path, False otherwise.
    ...    ${map_path} path name to check
    ...    ${file} file name to check
    IF    "${file}" == "PRODUCT_3_22"
        IF    not ("${env}" == "stg-emea" or "${env}" == "sit-emea")
            Fail    Map Region is not available other Than Europe
        END
    END
    @{output} =    LISTING CONTENTS     ${map_path}
    ${output} =    Evaluate    "".join(${output})
    ${verdict} =    Evaluate    '${file}' in '${output}'
    Run Keyword If    "${is_file_present}" == "True"    Should Be True    ${verdict}    ${file} file is not present on ${map_path} target
    ...     ELSE    Should Not Be True    ${verdict}    ${file} file is present on ${map_path} target

DO ANALYZE PNP_BOOT_RVC
    [Arguments]    ${file_path}    ${ivi_build_id}
    [Documentation]    To analyze output of pnp script for time taken to display camera on ivi.
    ...    ${file_path} path name to intail path of results file
    ...    ${ivi_build_id} ivi build id
    ${build}=    Replace String    ${ivi_build_id}    .sit-0abd03c2    ${EMPTY}
    ${build1}=    Replace String    ${build}    CUB.    ${EMPTY}
    ${folder3}=    Catenate   SEPARATOR=_    BootData_FullNav    ${build}.json
    ${folder2} =    OperatingSystem.Run    ls ${file_path}/${build1}
    ${FILECONTENT}=    Get File    ${file_path}/${build1}/${folder2}/${folder3}
    ${values} =    Create List
    FOR    ${ELEMENT}    IN    @{JSON}
        FOR    ${key}    ${value}    IN    &{ELEMENT}
            FOR    ${valu}    IN    @{value}
                FOR    ${key}    ${value}    IN    &{valu}
                    ${sorted}=    Get Dictionary Values    ${valu}
                    ${strip}=    Remove Values From List    ${sorted}    normal    earlycamera first frame    p
                    Run Keyword If    '${value}'=='earlycamera first frame'    Append To List    ${values}    ${sorted}
                END
            END
        END
    END
    ${val} =	Get From List	${values}[0]	0
    ${val1} =	Get From List	${values}[1]	0
    ${val2} =	Get From List	${values}[2]	0
    ${val3} =	Get From List	${values}[3]	0
    ${val4} =	Get From List	${values}[4]	0
    ${Average}=     Evaluate       (${val}+${val1}+${val2}+${val3}+${val4}/5   

CHECK FILE PRESENT ON IVC
    [Arguments]    ${file}
    [Documentation]    Check file presence on ivc
    ...    ${file} path and file name to search
    ${verdict}    ${comment} =    rfw_services.wicket.SystemLib.Is File On Target    ${file}
    Should Be True    ${verdict}    ${comment}

CHECK MEMORY
    [Arguments]    ${path}
    [Documentation]    Check memory information for certain path
    ${memory_dict} =    rfw_services.ivi.FileSystemLib.Check Memory    ${path}
    should not be empty    ${memory_dict}
    ${used_memory} =   Set variable    ${memory_dict}[Used]
    [Return]    ${used_memory}

DO IVI CHOWN
    [Arguments]    ${path}    ${owner}
    [Documentation]    Change owner of specified path
    ...    ${path} target path in the device
    ...    ${owner} name of the new owner
    ${verdict} =    rfw_services.ivi.FileSystemLib.Change File Owner    ${path}    ${owner}
    Should be true    ${verdict}    Filed to change the owner on the ivi device

CREATE FILE ON IVI
    [Arguments]    ${file}    ${ivi_adb_id}
    [Documentation]    Create file on ivi
    ...    ${file} path and file name to create
    OperatingSystem.Run    adb -s ${ivi_adb_id} shell /vendor/bin/pnp_collect -p 200 -d 1000 -m platinfo -o ${file}

CREATE FOLDER ON USB STICK
    [Arguments]    ${target_id}
    [Documentation]    create folder on USB stick
    ...    ${target_id} DUT
    Run Keyword If    "${target_id}" != "ivi"    Fail    Target id: ${target_id} is not implemented
    SET ROOT  
    IF    "${platform_version}" == "10"
        ${is_created} =    rfw_services.ivi.FileSystemLib.CREATE FOLDER    storage/${usb_stick_id}/logfiles_aivi2
        ${is_created} =    rfw_services.ivi.FileSystemLib.CREATE FOLDER    storage/${usb_stick_id}/logfiles_aivi2/alliance_log
    ELSE
        ${user_id} =   OperatingSystem.Run    adb -s ${ivi_adb_id} shell am get-current-user
        ${is_created} =    rfw_services.ivi.FileSystemLib.CREATE FOLDER    mnt/pass_through/${user_id}/${usb_stick_id}/logfiles_aivi2
        ${is_created} =    rfw_services.ivi.FileSystemLib.CREATE FOLDER    mnt/pass_through/${user_id}/${usb_stick_id}/logfiles_aivi2/alliance_log
    END
    Should Be True    ${is_created}    Folder not created on the target
