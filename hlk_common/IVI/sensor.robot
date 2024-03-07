#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Documentation     We want to make sure Accelerometer, Magnetometer and Gyroscope devices are detected when booting
Library           rfw_services.ivi.FileSystemLib    device=${ivi_adb_id}
Library           rfw_services.ivi.SystemLib    device=${ivi_adb_id}
Library           OperatingSystem

*** Variables ***
&{target}               host=bench    dut=ivi
${more_options}         //*[@content-desc='More options']
${settings}             //*[@text='Settings']
${log_name}             Name in log
${start_logging}        //*[@text='START LOGGING']
${stop_logging}         //*[@text='STOP LOGGING']
${check_gyroscope}      GYROSCOPE:
${check_accelerometer}    ACCELEROMETER
${check_accelerometer_uncalibrated}    UNKNOWN 
${check_gyroscope_uncalibrated}     GYROSCOPE UNCALIBRATED
${check_gravity}         GRAVITY
${check_linear_acceleration}     LINEAR ACCELERATION
${check_game_rotation}        GAME ROTATION VECTOR 
${sensor_host_dir}      ./
${stop}             stopped

*** Keywords ***
CHECK SENSOR CMD
    [Arguments]    ${sensor}
    [Documentation]    Grep Sensor
    ${output} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell dumpsys sensorservice | grep -A 1 ${sensor}
    Should Contain    ${output}    ${sensor}   failed to grep  ${sensor}

CHECK SENSOR IVI
    [Arguments]    ${sensor_app}    ${sensor_type}
    [Documentation]    Check that the Sensor ${sensor_type} is working as expected
    # 08-Oct-2018: Recent adb versions are creating a directory based on source path (possible bug), uncommenting this line
    # to align with this new behaviour
    # create_folder    host    ${host_dest_path}    ${sensor_host_dir}
    ${configure_sensor_app} =    CONFIGURE SENSOR APP
    Should Be True    ${configure_sensor_app}
    ${ivi_src_dir} =  Set Variable if    "${platform_version}" == "10"   /storage/emulated/10/sensorlogger/    /mnt/pass_through/10/emulated/10/sensorlogger/
    CHECK SENSOR DATA    ${sensor_type}    ${sensor_limits_gyroscope}    ${ivi_src_dir}    ${sensor_host_dir}

CONFIGURE SENSOR APP
    APPIUM_TAP_XPATH    ${more_options}
    APPIUM_TAP_XPATH    ${settings}
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='${log_name}']    direction=down    scroll_tries=12
    Should Be True    "${result}" == "True"    ${log_name} is not found.
    APPIUM_TAP_XPATH    //*[@text='${log_name}']
    APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}
    APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}
    [Return]    ${result} 

CHECK SENSOR DATA    
    [Arguments]    ${sensor_type}    ${sensor_limits_gyroscope}    ${ivi_src_dir}    ${sensor_host_dir}    
    ${file} =  GENERATE SENSOR DATA     ${sensor_type}    ${ivi_src_dir}    ${sensor_host_dir}     
    ${sensor_csv_file} =  OPEN SENSOR FILE    ${file}    /opt/rfw/logs/sensorlogger/file.csv    
    ${verdict} =    VALIDATE SENSOR DATA    ${sensor_type}    ${sensor_csv_file}
    Should Be True    ${verdict}    ${sensor_type}
    VALIDATE SENSOR LIMITS    ${sensor_csv_file}    ${sensor_type}    ${sensor_limits_gyroscope}

GENERATE SENSOR DATA
    [Arguments]    ${sensor_type}    ${ivi_src_dir}    ${sensor_host_dir}
    @{list_sensor}=  Create List   accelerometer  gyroscope  unknown  gyroscope uncalibrated  gravity  linear acceleration  game rotation vector
    ${ret} =  Convert To Lower Case    ${sensor_type}
    List Should Contain Value   ${list_sensor}   ${sensor_type}
    ${elements_list}   APPIUM_GET_ELEMENTS_BY_CLASS    android.widget.CheckedTextView
    Log    ${elements_list}
    FOR  ${element}   IN   @{elements_list}
        Log   ${element}
        ${content}    Set Variable      ${element.text}
        ${verdict}    Run Keyword And Return Status   Should Contain  ${content}   ${check_${sensor_type}}
        Run Keyword If   ${verdict}   Call method    ${element}    click
        Run Keyword If   ${verdict}   Exit For Loop
    END
    DELETE FOLDER OR FILE  ${ivi_src_dir}*.log
    APPIUM_TAP_XPATH    ${start_logging}
    Sleep    5
    APPIUM_TAP_XPATH    ${stop_logging}
    SET ROOT 
    Sleep    5
    ${dest_path}      Set Variable         /opt/rfw/logs
    Run Keyword And Continue On Failure    Create Directory    ${dest_path}
    Run Keyword And Continue On Failure    Empty Directory     ${dest_path}
    ${LOG FILE} =    PULL    ${ivi_src_dir}    ${dest_path}    
    ${dest_path}      Set Variable         ${dest_path}/sensorlogger
    @{files} = 	List Files In Directory 	${dest_path}
    ${count} = 	Count Files In Directory 	${dest_path}
    ${count} = 	Convert To Integer 	${count}
    IF   ${count} == 0
        Fail    No Such File or directory pulled
    END
    ${file_log}   Set Variable    @{files}
    ${size_log}   Get File Size   ${dest_path}/${file_log} 
    IF  ${size_log} != 0
        ${file_path}   Set Variable    ${dest_path}/${file_log}
    END
    [Return]    ${file_path}

OPEN SENSOR FILE
    [Arguments]    ${source}     ${destination}
    ${sensor_csv_file} =  OperatingSystem.COPY FILE     ${source}     ${destination}
    ${sensor_csv_file} =    Get File    ${sensor_csv_file}
    [return]     ${sensor_csv_file}
    
VALIDATE SENSOR DATA
    [Arguments]    ${sensor}    ${sensor_csv_file_content}
    @{read} =    Create List    ${sensor_csv_file_content}
    @{lines} =    Split To Lines    @{read}    1
    Should Contain  ${lines}[-1]   ${stop}
    ${verdict}   Run keyword and return status   Should Contain   ${lines}[0]    ${sensor}    ignore_case=True
    FOR    ${line_csv}    IN    ${lines}[0]
        @{elements} =    Split String    ${line_csv}    ,
    END
    ${count}=  Get length  ${elements}
    ${count} = 	Convert To Integer 	${count}
    IF   ${count} < 12
        ${verdict}    Set Variable    False 
        Log     "data missing from sensor file"   
    END
    [Return]   ${verdict}

VALIDATE SENSOR LIMITS 
    [Arguments]          ${sensor_csv_file_content}    ${sensor}      ${sensor_limits_gyroscope}
    @{read} =    Create List    ${sensor_csv_file_content}
    @{lines} =    Split To Lines    @{read} 
    Log      ${lines}
    Should Contain  ${lines}[-1]   ${stop}
    @{list_x_values} = 	Create List
    @{list_y_values} = 	Create List
    @{list_z_values} = 	Create List
    FOR  ${line_csv}    IN    @{lines}
        @{elements} =    Split String    ${line_csv}    ,
        Run Keyword And Ignore Error  Append To List  ${list_x_values}   ${elements}[9]
        Run Keyword And Ignore Error  Append To List  ${list_y_values}   ${elements}[10]
        Run Keyword And Ignore Error  Append To List  ${list_z_values}   ${elements}[11]
    END
    FOR   ${items}  IN  @{list_x_values}
        ${verdict} = 	Evaluate 	${sensor_limits_gyroscope}[0] < ${items} < ${sensor_limits_gyroscope}[1]
        Should Be True   ${verdict}
    END
    FOR   ${items}  IN  @{list_y_values}
        ${verdict} = 	Evaluate 	${sensor_limits_gyroscope}[2] < ${items} < ${sensor_limits_gyroscope}[3]    
        Should Be True   ${verdict}
    END
    FOR   ${items}  IN  @{list_z_values}
        ${verdict} = 	Evaluate 	${sensor_limits_gyroscope}[4] < ${items} < ${sensor_limits_gyroscope}[5]       
        Should Be True   ${verdict}
    END