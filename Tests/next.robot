*** Settings ***
Library    SeleniumLibrary
Library    ../venv/lib/python3.12/site-packages/robot/libraries/Collections.py

Suite Setup    Launch Browser   
Suite Teardown     Close Browser

*** Variables ***
${username}    Isagani

*** Test Cases ***
# First Test Case
    # Login User    demo    demo
    # Go To Link    Customers
    # Display All name

*** Keywords ***
Launch Browser
    [Arguments]    ${url}=https://marmelab.com/react-admin-demo
    ${options}    Set Variable    add_argument("--start-maximized")
    Open Browser    ${url}    chrome    remote_url=172.17.0.1:4444    options=${options}

Login User
    [Arguments]    ${user}    ${password}
    Wait Until Element Is Visible    //button[@type="submit"]
    Input Text    name:username    ${user}
    Input Text    name:password    ${password}
    Click Button    //button[@type="submit"]
    


Go To Link
    [Arguments]    ${text}
    Click Element    //a[text()="${text}"]
    Wait Until Element Is Visible    //tbody//tr[last()-2]


Display All name
    ${web_element}    Get WebElements    //tbody//tr
    ${len}    Get Length    ${web_element}
    ${name_list}    Create List
    ${name_dict}    Create Dictionary
    FOR    ${counter}    IN RANGE    1   ${len}+1
        ${current}    Set Variable    ((//tbody//tr)[${counter}]//td)[2]
        ${text}    Get Text    ${current}
        ${status}  Run Keyword And Return Status    Page Should Contain Element    ${current}
        IF  not ${status}
           ${text}    Evaluate    """${text}""".replace("\\n","")[1:] 
        END
        Append To List    ${name_list}    ${text}
        ${name_list}    Set To Dictionary    ${name_dict}  name_${counter}=${text}
    END

    Log To Console    \n\n${name_list}\n\n
    Log To Console    \n\n${name_dict}\n\n