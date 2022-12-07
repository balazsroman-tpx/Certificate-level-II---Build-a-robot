*** Settings ***
Documentation       Download CSV file and place robot orders/save confirmations based on that data, then package it as a zip

Library             RPA.Browser.Selenium
Library             RPA.HTTP


*** Tasks ***
Order robots
    Download CSV    https://robotsparebinindustries.com/orders.csv
    Open Browser    https://robotsparebinindustries.com/#/robot-order
    [Teardown]    Close Browser


*** Keywords ***
Open Browser
    [Arguments]    ${URL}
    Open Available Browser    ${URL}

Close Browser
    Close Browser

Download CSV
    [Arguments]    ${URL}
    Download    ${URL}
