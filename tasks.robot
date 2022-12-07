*** Settings ***
Documentation       Download CSV file and place robot orders/save confirmations based on that data

Library             RPA.Browser.Selenium


*** Tasks ***
Minimal task
    Open Browser    https://robotsparebinindustries.com/#/robot-order
    [Teardown]    Close Browser


*** Keywords ***
Open Browser
    [Arguments]    ${URL}
    Open Available Browser    ${URL}

Close Browser
    Close Browser
