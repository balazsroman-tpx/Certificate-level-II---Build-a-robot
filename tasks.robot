*** Settings ***
Documentation       Download CSV file and place robot orders/save confirmations based on that data, then package it as a zip

Library             RPA.Browser.Selenium
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.FileSystem


*** Variables ***
${CSV_URL}=         https://robotsparebinindustries.com/orders.csv
${Order_URL}=       https://robotsparebinindustries.com/#/robot-order


*** Tasks ***
Order robots
    Remove Directory    ${OUTPUT_DIR}${/}screenshots
    Download CSV    ${CSV_URL}
    Open Browser for Ordering    ${Order_URL}

    ${orders}=    Read table from CSV    orders.csv    header=True
    FOR    ${order}    IN    @{orders}
        Add order details    ${order}
        Take Screenshot of Robot    ${order}[Order number]
    END

    [Teardown]    Close Browser for Ordering


*** Keywords ***
Open Browser for Ordering
    [Arguments]    ${URL}
    Open Available Browser    ${URL}
    Wait And Click Button    css:.btn-dark

Close Browser for Ordering
    Close Browser

Download CSV
    [Arguments]    ${URL}
    Download    ${URL}    overwrite=True

Add order details
    [Arguments]    ${order}
    Select From List By Index    head    ${order}[Head]
    Click Element    id:id-body-${order}[Body]
    Input Text    //label[contains(.,'Legs')]/../input    ${order}[Legs]
    Input Text    id:address    ${order}[Address]

Take Screenshot of Robot
    [Arguments]    ${no}
    Click Button    id:preview
    Wait Until Page Contains Element    id:robot-preview-image
    Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}screenshots${/}order${no}.png
