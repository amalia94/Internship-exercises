#
# Copyright (c) 2020, 2021, 2022 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
# Library used for specifying HLKs for APPIUM

*** Settings ***
Variables         ${CURDIR}/app_info_ivi_android_10.yaml
Variables         ${CURDIR}/app_info_ivi_android_12.yaml
Variables         ${CURDIR}/app_info_smartphone_android_9.yaml
Variables         ${CURDIR}/app_info_smartphone_android_10.yaml
Variables         ${CURDIR}/app_info_smartphone_android_11.yaml
Variables         ${CURDIR}/app_info_smartphone_android_12.yaml
Variables         ${CURDIR}/app_info_smartphone_android_13.yaml
Library           rfw_services.ivi.AppiumLib

*** Variables ***
${ivi_capabilities}               ${None}
${smartphone_capabilities}        ${None}
${app_package}                    com.renault.launcher
${app_activity}                   .NavigationActivity
${platform_version}               10
${smartphone_platform_version}    12
${ivi_driver}    None
${device_type}                    ivi

*** Keywords ***
GET PACKAGE AND ACTIVITY NAME FROM APP
    [Arguments]    ${app_name}    ${device_type}=ivi    ${platform_version}=${platform_version}
    ${app_package_variable} =    Catenate    SEPARATOR=    apps_    ${device_type}    _android_    ${platform_version}    ['${app_name}']    ['package']
    ${app_activity_variable} =   Catenate    SEPARATOR=    apps_    ${device_type}    _android_    ${platform_version}    ['${app_name}']    ['activity']
    [Return]    ${${app_package_variable}}    ${${app_activity_variable}}

GET COORDINATES NAME FROM APP
    [Arguments]    ${app_name}    ${device_type}=ivi    ${platform_version}=${platform_version}
    ${coordinates} =    Catenate    SEPARATOR=    apps_    ${device_type}    _android_    ${platform_version}    ['${app_name}']    ['coordinates']
    [Return]    ${${coordinates}}

CREATE APPIUM DRIVER
    [Arguments]    ${app_name}=Navigation    ${device_type}=ivi    ${dut_id}=${ivi_adb_id}    ${platform_version}=${platform_version}
    [Documentation]    == High Level Description: ==
    ...    Creates an Appium driver with the desired capabilities
    update_default_device      ${dut_id}
    ${app_package}    ${app_activity} =    GET PACKAGE AND ACTIVITY NAME FROM APP    ${app_name}    ${device_type}    ${platform_version}
    ${systemPortValue} =    Set Variable If    '${device_type}' == 'ivi'    8210    8214

    &{appium_dict} =   Create Dictionary    platformName=Android    platformVersion=${platform_version}    deviceName=${dut_id}    appPackage=${app_package}    appActivity=${app_activity}    autoGrantPermissions=true    automationName=UiAutomator2   udid=${dut_id}    systemPort=${systemPortValue}    dontStopAppOnReset=${True}
    ${appium_driver_session} =    rfw_services.ivi.AppiumLib.driver_creation    ${appium_dict}
    Run Keyword If    "None" in """${appium_driver_session}"""    Fail    Appium driver was not created

    Set Suite Variable    ${${device_type}_capabilities}    ${appium_dict}
    Run Keyword If    '${device_type}' == 'ivi'    Set Suite Variable    ${ivi_driver}    ${appium_driver_session}
    ...    ELSE IF    '${device_type}' == 'smartphone'    Set Suite Variable    ${mobile_driver}    ${appium_driver_session}
    [Return]    ${appium_driver_session}

REMOVE APPIUM DRIVER
    [Arguments]    ${driver_capabilities}=${ivi_capabilities}
    [Documentation]    == High Level Description: ==
    ...    To close appium session and warning if Appium related APKs were not properly removed from IVI
    IF    "${driver_capabilities}"=="${ivi_capabilities}"
        remove_driver    ${ivi_adb_id}    ${driver_capabilities}
    ELSE
        remove_driver    ${mobile_adb_id}    ${driver_capabilities}
    END
    Return From Keyword If    "${driver_capabilities}"=="${smartphone_capabilities}"
    ${status1} =    UNINSTALL APK    io.appium.settings
    ${status2} =    UNINSTALL APK    io.appium.uiautomator2.server
    ${status3} =    UNINSTALL APK    io.appium.uiautomator2.server.test
    ${message} =    Set variable    ${EMPTY}
    ${message} =    Set variable if    ${status1} == ${FALSE}    ${message}io.appium.settings;    ${message}
    ${message} =    Set variable if    ${status2} == ${FALSE}    ${message}io.appium.uiautomator2.server;    ${message}
    ${message} =    Set variable if    ${status3} == ${FALSE}    ${message}io.appium.uiautomator2.server.test    ${message}
    Run keyword if    (${status1} and ${status2} and ${status3}) == ${FALSE}    Log    Appium APK Package(s): ${message} not properly removed!!!    WARN

LAUNCH APP APPIUM
    [Arguments]    ${app_name}    ${device_type}=${device_type}    ${port}=4723    ${path_to_save}=${OUTPUT_DIR}    ${screenshot_name}=${TEST NAME}    ${platform_version}=${platform_version}
    IF    "${device_type}"=="emulator"
        CHECK AND SWITCH DRIVER    ${emulator_driver}
    ELSE IF    "${device_type}"=="ivi"
        CHECK AND SWITCH DRIVER    ${ivi_driver}
    END
    # Workaround till CCSEXT-112000 is fixed
    IF    "${app_name}"=="Navigation" and "${ivi_my_feature_id}"=="MyF3"
        Log    Using GO HOME SCREEN APPIUM. Instead of Launching App [${app_name}]    console=True
        GO HOME SCREEN APPIUM
        ${verdict} =    Set Variable    ${True}
    ELSE
        ${app_package}    ${app_activity} =    GET PACKAGE AND ACTIVITY NAME FROM APP    ${app_name}    ${device_type}    ${platform_version}
        Log    Launching App [${app_name}] - Package: [${app_package}] - Activity: [${app_activity}]    console=True
        ${verdict} =    START ACTIVITY    ${app_package}    ${app_activity}
        Run Keyword If    ${verdict} != True    Run Keyword and Ignore Error    SAVE SCREENSHOT APPIUM    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
    END
    Should Be True    ${verdict}
    [Return]    ${verdict}

TAP_ON_BUTTON
    [Arguments]    ${button}    ${retries}    ${path_to_save}=${OUTPUT_DIR}    ${screenshot_name}=${TEST NAME}
    ${elmt} =    APPIUM_WAIT_FOR_ELEMENT    ${button}    ${retries}    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
    Should be True    ${elmt}
    ${location} =    APPIUM_GET_LOCATION    ${button}
    APPIUM_TAP_LOCATION    ${location}

APPIUM_WAIT_FOR_ELEMENT
    [Arguments]    ${buttonId}    ${retries}    ${path_to_save}=${OUTPUT_DIR}    ${screenshot_name}=${TEST NAME}
    ${retries} =    Convert To Integer    ${retries}
    ${is_present} =    wait_element_by_id    ${buttonId}    retries=${retries}
    Run Keyword If    ${is_present} == False    Run Keyword and Ignore Error    SAVE SCREENSHOT APPIUM    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
    Log To Console    Wait for element for ${buttonId} returns ${is_present}
    [Return]    ${is_present}

APPIUM_GET_LOCATION
    [Arguments]    ${button}
    ${location} =    GET ELEMENT LOCATION    ${button}
    [Return]    ${location}

APPIUM_TAP_LOCATION
    [Arguments]    ${location}
    tap_by_location    ${location}

APPIUM_TAP_XPATH
    [Arguments]    ${tap_xpath}    ${retries}=10    ${scroll_tries}=0    ${path_to_save}=${OUTPUT_DIR}    ${screenshot_name}=${TEST NAME}
    ${elmt} =    APPIUM_WAIT_FOR_XPATH    ${tap_xpath}    ${retries}    scroll_tries=${scroll_tries}    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
    Should be True    ${elmt}
    # As per MATRIX-55619
    click_element_by_xpath    ${tap_xpath}

APPIUM_TAP_ELEMENTID
    [Arguments]    ${elementid}    ${retries}=10
    ${elmt} =    APPIUM_WAIT_FOR_ELEMENT    ${elementid}    ${retries}
    Should be True    ${elmt}
    PRESS BUTTON BY ID    ${elementid}

APPIUM_GET_ATTRIBUTE_BY_XPATH
    [Arguments]    ${elm_xpath}    ${attribute}
    [Documentation]    == High Level Description: ==
    ...    Returns the attribute of a given xpath
    ...    == Parameters: ==
    ...    - _elm_xpath_: represents the xpath of the element
    ...    - _attribute_: represents the attribute whose value is needed
    ...    == Expected Results: ==
    ...    output: passed/failed
    ${is_present} =    APPIUM_WAIT_FOR_XPATH    ${elm_xpath}    5
    ${attribute_value} =    Run Keyword If    ${is_present} == True    get_attribute_by_xpath    ${elm_xpath}    ${attribute}
    ...    ELSE    Set Variable    False
    [Return]    ${attribute_value}

APPIUM_GET_TEXT_USING_XPATH
    [Arguments]    ${xpath}    ${retries}=10    ${path_to_save}=${OUTPUT_DIR}    ${screenshot_name}=${TEST NAME}
    APPIUM_WAIT_FOR_XPATH    ${xpath}    ${retries}
    ${ret} =    get_text_by_xpath    ${xpath}
    Run Keyword and Ignore Error    SAVE SCREENSHOT APPIUM    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
    [Return]    ${ret}

APPIUM_GET_ATTRIBUTE_BY_ID
    [Arguments]    ${element_id}    ${attribute}
    APPIUM_WAIT_FOR_ELEMENT    ${element_id}    5
    ${ret} =    get_attribute_by_id    ${element_id}    ${attribute}
    [Return]    ${ret}

APPIUM_GET_XPATH_LOCATION
    [Arguments]    ${xpath}
    ${location} =    GET ELEMENT LOCATION BY XPATH    ${xpath}
    [Return]    ${location}

APPIUM_GET_TEXT
    [Arguments]    ${buttonId}    ${retries}=10    ${path_to_save}=${OUTPUT_DIR}    ${screenshot_name}=${TEST NAME}
    APPIUM_WAIT_FOR_ELEMENT    ${buttonId}    ${retries}
    ${ret} =    get_text    ${buttonId}
    Run Keyword and Ignore Error    SAVE SCREENSHOT APPIUM    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
    [Return]    ${ret}

APPIUM_WAIT_FOR_XPATH
    [Arguments]    ${xpath}    ${retries}=6    ${direction}=down    ${scroll_tries}=0
    ...    ${path_to_save}=${OUTPUT_DIR}    ${screenshot_name}=${TEST NAME}    ${from_xpath_element}=${None}
    ${retries} =    Convert To Integer    ${retries}
    ${is_present_before_scroll} =    WAIT ELEMENT BY XPATH    ${xpath}    retries=${retries}
    ${is_present_after_scroll} =    Run Keyword If    "${scroll_tries}" != "0" and "${is_present_before_scroll}" == "False"   SCROLL TO EXACT ELEMENT    element_id_or_xpath=${xpath}    direction=${direction}
    ...    scroll_tries=${scroll_tries}    from_xpath_element=${from_xpath_element}
    ${is_present} =    Set Variable If     "${is_present_before_scroll}" == "True" or "${is_present_after_scroll}" == "True"    ${True}    ${False}
    Run Keyword If    ${is_present} == False    Run Keyword and Ignore Error    SAVE SCREENSHOT APPIUM    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
    Log To Console    Wait for element for ${xpath} returns ${is_present}
    [Return]    ${is_present}

APPIUM_GET_TEXT_BY_ID
    [Documentation]    Get text from ID
    [Arguments]    ${id}    ${retries}=10    ${path_to_save}=${OUTPUT_DIR}    ${screenshot_name}=${TEST NAME}
    APPIUM_WAIT_FOR_ELEMENT    ${id}    ${retries}
    ${text} =    rfw_services.ivi.AppiumLib.get_text_by_id    ${id}
    Run Keyword and Ignore Error    SAVE SCREENSHOT APPIUM    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
    [Return]    ${text}

APPIUM_GET_ELEMENTS_BY_CLASS
    [Arguments]    ${class_name}
    [Documentation]    == High Level Description: ==
    ...    Returns the elements that corresponds to a certain class
    ...    == Parameters: ==
    ...    - _class_name_: represents the name of the class
    ...    == Expected Results: ==
    ...    output: passed/failed
    ${elements} =    get_elements_by_class_name    ${class_name}
    [Return]    ${elements}

APPIUM_SCROLL_NOTIFICATION_BAR
    [Arguments]    ${start_X}=200    ${start_Y}=100    ${end_X}=200    ${end_Y}=800
    [Documentation]    To swipe the notification manager
    swipe_by_coordinates    ${start_X}    ${start_Y}    ${end_X}    ${end_Y}    2000

TAP_ON_ELEMENT_USING_ID
    [Arguments]    ${button}    ${retries}    ${path_to_save}=${OUTPUT_DIR}    ${screenshot_name}=${TEST NAME}
    ${elmt} =    APPIUM_WAIT_FOR_ELEMENT    ${button}    ${retries}    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
    Should be True    ${elmt}
    click_element_by_id    ${button}

TAP_ON_ELEMENT_USING_XPATH
    [Arguments]    ${xpath_value}    ${wait_time}    ${path_to_save}=${OUTPUT_DIR}    ${screenshot_name}=${TEST NAME}    ${scroll_tries}=0    ${direction}=down
    ${elmt} =    APPIUM_WAIT_FOR_XPATH    ${xpath_value}    ${wait_time}    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}    scroll_tries=${scroll_tries}
    Should be True    ${elmt}
    click_element_by_xpath    ${xpath_value}

SCROLL_TO_ELEMENT
    [Arguments]    ${element}   ${scroll_direction}=down    ${scroll_tries}=12
    ${ret} =    scroll_to_exact_element    element_id_or_xpath=${element}    scroll_tries=${scroll_tries}    direction=${scroll_direction}
    [Return]    ${ret}

APPIUM_ENTER_TEXT
    [Arguments]    ${element_id}   ${text}    ${path_to_save}=${OUTPUT_DIR}    ${screenshot_name}=${TEST NAME}
    APPIUM_WAIT_FOR_ELEMENT    ${element_id}    10
    ${ret} =    enter_text_by_id    ${element_id}    ${text}
    Run Keyword and Ignore Error    SAVE SCREENSHOT APPIUM    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
    [Return]    ${ret}

APPIUM_PRESS_KEYCODE
    [Arguments]    ${key_code}
    ${ret} =    press_key_code    ${key_code}
    [Return]    ${ret}

APPIUM LAUNCH DRIVER APPLICATION
    [Documentation]    == High Level Description: ==
    ...    Launch the application with the appPackage and appActivity specified in the desired
    ...    capabilities for CREATE APPIUM DRIVER while also retaining default intents and flags
    LAUNCH APPLICATION

CHECK AND SWITCH DRIVER
    [Arguments]    ${requested_driver}
    [Documentation]    == High Level Description: ==
    ...    Switch the driver if requested driver is different from current one
    ...    == Parameters: ==
    ...    - _requested_driver_: Appium driver that will be selected
    IF    '''${requested_driver}''' == '''${mobile_driver}'''
        update_default_device      ${mobile_adb_id}
    ELSE
        update_default_device      ${ivi_adb_id}
    END

SAVE SCREENSHOT APPIUM
    [Arguments]    ${path_to_save}    ${screenshot_name}
    [Documentation]    == High Level Description: ==
    ...    Save the screenshot from IVI or smartphone.
    ...    Do not modify the folder name or the file name because they are linked with Silk
    SAVE SCREENSHOT    ${path_to_save}/    screenshot_${screenshot_name}.png

LONG PRESS ELEMENT APPIUM
    [Arguments]    ${element}
    longPressOnElement    ${None}    ${element}

APPIUM_ENTER_TEXT_XPATH
    [Arguments]    ${element_xpath}   ${text}    ${path_to_save}=${OUTPUT_DIR}    ${screenshot_name}=${TEST NAME}
    APPIUM_TAP_XPATH    ${element_xpath}    retries=20
    ${ret} =    enter_text_by_xpath    ${element_xpath}    ${text}
    Run Keyword and Ignore Error    SAVE SCREENSHOT APPIUM    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
    [Return]    ${ret}

APPIUM_GET_ELEMENTS_BY_XPATH
    [Arguments]    ${element_xpath}
    [Documentation]    == High Level Description: ==
    ...    Returns the elements that corresponds to a certain xpath
    ...    == Parameters: ==
    ...    - _element_xpath_: represents the xpath of an element
    ...    == Expected Results: ==
    ...    output: passed/failed
    ${elements} =    get_elements_by_xpath    ${element_xpath}
    [Return]    ${elements}

CONFIGURE SMARTPHONE WITH APPIUM
    [Arguments]     ${app_smartphone}
    [Documentation]    To switch to the smartphone, it takes the ${app_smartphone} to specify the home page of it.
    ${result} =    Run Process    adb    -s    ${mobile_adb_id}    shell    getprop    ro.build.version.release
    Set Suite Variable    ${smartphone_platform_version}    ${result.stdout}
    CREATE APPIUM DRIVER        ${app_smartphone}    smartphone    ${mobile_adb_id}    ${smartphone_platform_version}
    LAUNCH APPIUM APP ON SMARTPHONE    ${app_smartphone}    smartphone

UNCONFIGURE SMARTPHONE WITH APPIUM
    [Arguments]     ${smartphone_home_page}
    LAUNCH APPIUM APP ON SMARTPHONE    ${smartphone_home_page}    smartphone
    REMOVE APPIUM DRIVER    ${smartphone_capabilities}

APPIUM CHECK ELEMENT BY XPATH
    [Arguments]    ${element_resource_xpath}
    ${status}      Run Keyword And Return Status      get_element_by_xpath     ${element_resource_xpath}
    Log            ${status}
    ${verdict}     Set Variable If	    ${status}     True     False
    [Return]       ${verdict}

APPIUM LOG VIEW SOURCE CODE
    ${verdict}      log_source
    [Return]        ${verdict}

FIND IMAGE ON SCREEN APPIUM
    [Arguments]    ${reference_image}    ${threshold}=80
    ${coord}    ${center}    ${verdict} =    FIND IMAGE ON SCREEN    ${reference_image}    ${threshold}
    [Return]    ${coord}    ${center}    ${verdict}
