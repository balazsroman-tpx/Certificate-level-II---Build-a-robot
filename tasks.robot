*** Settings ***
Documentation       Download CSV file and place robot orders/save confirmations based on that data, then package it as a zip

Library             RPA.Browser.Selenium
Library             RPA.HTTP
Library             RPA.Tables


*** Variables ***
${CSV_URL}=         https://robotsparebinindustries.com/orders.csv
${Order_URL}=       https://robotsparebinindustries.com/#/robot-order


*** Tasks ***
Order robots
    Download CSV    ${CSV_URL}
    Open Browser for Ordering    ${Order_URL}
    Process Orders
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

Process Orders
    ${orders}=    Read table from CSV    orders.csv    header=True
    FOR    ${order}    IN    @{orders}
        Add order details    ${order}
    END
