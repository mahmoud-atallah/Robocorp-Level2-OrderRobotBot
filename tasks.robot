*** Settings ***
Documentation       Orders robots from RobotSpareBin Industies Inc.
...                 saves the order HTML ordered robot.
...                 Saves the screenshot of the ordered robot.
...                 Embed the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipt and the images.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.Excel.Files
Library             RPA.Tables
Library             RPA.PDF
Library             RPA.Archive
Library             RPA.Desktop


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Download the Excel file
    Open the robot order website
    ${orders}=    Get orders
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        Preview the robot
        Submit the order
        ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Go to order another robot
    END
    Create a ZIP file of the receipts


*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Close the annoying modal
    Click Button    OK

Download the Excel file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=${TRUE}

Get orders
    ${orders}=    Read table from CSV    orders.csv    header=True    dialect=Excel
    RETURN    ${orders}

Fill the form
    [Arguments]    ${row}
    Select From List By Value    id:head    ${row}[Head]
    #${body_locator}=    Catenate    SEPARATOR=    id:id-body-    ${row}[Body]
    #Click Button    ${body_locator}
    Select Radio Button    body    ${row}[Body]
    Input Text    css:.form-control    ${row}[Legs]
    Input Text    id:address    ${row}[Address]

Preview the robot
    Click Button    Preview

Submit the order
    Click Button    id:order
    ${res}=    Does Page Contain Button    id:order
    IF    ${res}    Wait Until Keyword Succeeds    3    3s    Submit the order

Store the receipt as a PDF file
    [Arguments]    ${Order_number}
    Wait Until Element Is Visible    id:receipt
    ${receipt_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt_html}    ${OUTPUT_DIR}${/}receipts${/}receipt${Order_number}.pdf
    RETURN    ${OUTPUT_DIR}${/}receipts${/}receipt${Order_number}.pdf

Take a screenshot of the robot
    [Arguments]    ${Order_number}
    Sleep    3s
    Screenshot    css:div#robot-preview-image    ${OUTPUT_DIR}${/}receipts${/}receipt${Order_number}.png
    RETURN    ${OUTPUT_DIR}${/}receipts${/}receipt${Order_number}.png

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf_File}
    ${files}=    Create List    ${screenshot}
    Add Files To PDF    ${files}    ${pdf_File}    append=${True}

Go to order another robot
    sleep    2s
    Click Button    id:order-another

Create a ZIP file of the receipts
    Archive Folder With Zip    ${OUTPUT_DIR}${/}receipts${/}    robottasks.zip    include=*.pdf
