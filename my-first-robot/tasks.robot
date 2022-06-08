*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.PDF
Library             RPA.Archive
Library             RPA.Robocorp.Vault


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Download the Excel file
    ${orders}=    Get orders
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        Preview the robot
        Wait Until Keyword Succeeds    5x    1sec    Submit the order
        ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Go to order another robot
    END
    Create a ZIP file of the receipts


*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Download the Excel file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

Get orders
    ${orders}=    Read table from CSV    orders.csv
    RETURN    ${orders}

Close the annoying modal
    Click Button    Yep

Fill the form
    [Arguments]    ${row}
    Select From List By Value    head    ${row}[Head]
    Select Radio Button    body    ${row}[Body]
    Input Text    class:form-control    ${row}[Legs]
    Input Text    address    ${row}[Address]

Preview the robot
    Click Button    preview

Submit the order
    Click Button    order
    Element Should Be Visible    id:receipt

Store the receipt as a PDF file
    [Arguments]    ${row}
    Wait Until Element Is Visible    id:receipt
    ${receipt_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt_html}    ${OUTPUT_DIR}${/}receipt-${row}.pdf
    RETURN    ${CURDIR}/output/receipt-${row}.pdf

Take a screenshot of the robot
    [Arguments]    ${row}
    Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}robot-${row}.png
    RETURN    ${CURDIR}/output/robot-${row}.png

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}
    ...    ${pdf}
    ${file}=    Create List
    ...    ${pdf}
    ...    ${screenshot}
    Add Files To Pdf    ${file}    ${pdf}

Go to order another robot
    Click Button    order-another

Create a ZIP file of the receipts
    Archive Folder With Zip    ${CURDIR}/output    output.zip
