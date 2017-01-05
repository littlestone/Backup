Attribute VB_Name = "modRevenueCanada"
Option Explicit

Private Declare Function PostMessage Lib "user32" Alias "PostMessageA" ( _
ByVal hwnd As Long, _
ByVal wMsg As Long, _
ByVal wParam As Long, _
ByVal lParam As Long) As Long

Private Declare Function FindWindowEx Lib "user32" Alias "FindWindowExA" ( _
ByVal hWnd1 As Long, _
ByVal hWnd2 As Long, _
ByVal lpsz1 As String, _
ByVal lpsz2 As String) As Long

Private Const WM_CLOSE As Long = &H10

Sub DemoRevenueCanada()
    ' Make sure you add references to Microsoft Internet Controls (shdocvw.dll) and
    ' Microsoft HTML object Library.
    ' Code will NOT run otherwise.
    
    On Error GoTo ErrorHandler
    
    Dim objIE As SHDocVw.InternetExplorer   ' Microsoft internet controls (shdocvw.dll)
    Dim htmlDoc As MSHTML.HTMLDocument      ' Microsoft HTML Object Library
    Dim htmlInput As MSHTML.HTMLInputElement
    Dim htmlColl As MSHTML.IHTMLElementCollection
    Dim htmlTextArea As MSHTML.HTMLTextAreaElement
    Dim htmlCell As MSHTML.htmlTableCell
    Dim resultFlag As Boolean
    Dim x As Integer
    Dim NumRows As Integer
    
    Set objIE = New SHDocVw.InternetExplorer
     
    With objIE
        .Navigate "http://www.cra-arc.gc.ca/esrvc-srvce/tx/bsnss/gsthstrgstry/menu-eng.html"
        .Visible = True
        Do While .ReadyState <> READYSTATE_COMPLETE Or objIE.Busy: DoEvents: Loop
            Application.Wait (Now + TimeValue("0:00:02"))
            
            ' Simulating click on "I agree" button
            Set htmlDoc = .Document
            Set htmlColl = htmlDoc.getElementsByTagName("input")
            Do While htmlDoc.ReadyState <> "complete": DoEvents: Loop
                For Each htmlInput In htmlColl
                    If Trim(htmlInput.Value) = "I agree" And Trim(htmlInput.Type) = "submit" Then
                        htmlInput.Click
                        Exit For
                    End If
                Next htmlInput
    End With
    
    ' Wait for the new page to load
    Do While objIE.ReadyState <> READYSTATE_COMPLETE Or objIE.Busy: DoEvents: Loop
        Application.Wait (Now + TimeValue("0:00:02"))
    
    ' Set numrows = number of rows of data.
    Sheet2.Select
    NumRows = Sheet2.Range(Range("A2"), Range("A65535").End(xlUp)).Rows.Count
    Range("A2").Select  ' Select cell A2.
    
    ' Establish "For" loop to loop "numrows" number of times.
    For x = 1 To NumRows
        ' Get the HTML document of the new page
        Set htmlDoc = objIE.Document
        Set htmlColl = htmlDoc.getElementsByTagName("input")
        Do While htmlDoc.ReadyState <> "complete": DoEvents: Loop
            ' set GST/HST Number, Business Name and Transaction Date
            For Each htmlInput In htmlColl
                If Trim(htmlInput.Name) = "businessNumber" And Trim(htmlInput.Type) = "text" Then
                    htmlInput.Value = Range("A" & x + 1).Text   'Enter the first 9 digits of the GST/HST number displayed on the invoice from your supplier. (This is not a social insurance number, consumer number or certificate number)
                End If
                If Trim(htmlInput.Name) = "requestDate" And Trim(htmlInput.Type) = "text" Then
                    htmlInput.Value = Range("C" & x + 1).Text   'Enter the transaction date (yyyy-mm-dd) (usually the date on the invoice)
                    Exit For
                End If
            Next htmlInput
            
        Set htmlColl = htmlDoc.getElementsByTagName("textarea")
        Do While htmlDoc.ReadyState <> "complete": DoEvents: Loop
            For Each htmlTextArea In htmlColl
                If Trim(htmlTextArea.Name) = "businessName" Then
                    htmlTextArea.Value = Range("B" & x + 1).Text 'Enter the name of the business displayed on the invoice from your supplier or the name the business is known by.
                    Exit For
                End If
            Next htmlTextArea
            
        ' Simulating click on "Search" button
        Set htmlColl = htmlDoc.getElementsByTagName("input")
        Do While htmlDoc.ReadyState <> "complete": DoEvents: Loop
            For Each htmlInput In htmlColl
                If Trim(htmlInput.Value) = "Search" And Trim(htmlInput.Type) = "submit" Then
                    htmlInput.Click
                    Exit For
                End If
            Next htmlInput
            
        'Wait for the result page to load
        Do While objIE.ReadyState <> READYSTATE_COMPLETE Or objIE.Busy: DoEvents: Loop
            Application.Wait (Now + TimeValue("0:00:02"))
    
        ' Get the HTML document of the result page
        resultFlag = False
        Set htmlDoc = objIE.Document
        Set htmlColl = htmlDoc.getElementsByTagName("span")
        Do While htmlDoc.ReadyState <> "complete": DoEvents: Loop
            For Each htmlCell In htmlColl
                ' Here's the part that looks for the specific text in the HTML Table result
                If resultFlag And Trim(htmlCell.innerText) <> "" Then
                    Range("D" & x + 1) = Trim(htmlCell.innerText)
                    Exit For
                End If
                If Trim(htmlCell.innerText) = "Result" Then
                    resultFlag = True
                End If
            Next htmlCell
        
        ' Go back to the search page and refresh the page
        objIE.GoBack
        
        ' Wait for the result page to load
        Do While objIE.ReadyState <> READYSTATE_COMPLETE Or objIE.Busy: DoEvents: Loop
            Application.Wait (Now + TimeValue("0:00:02"))

        ' Selects cell down 1 row from active cell.
        ActiveCell.Offset(1, 0).Select
    Next
        
    ' Close IE
    Call CloseAllOpenIEWindows

ErrorHandler:
    ' Clean up
    Set objIE = Nothing
    Set htmlDoc = Nothing
    Set htmlInput = Nothing
    Set htmlColl = Nothing
    Set htmlTextArea = Nothing
    Set htmlCell = Nothing
    
    ' Close IE
    Call CloseAllOpenIEWindows
    
    If Err <> 0 Then
        MsgBox Err.Source & "-->" & Err.Description, , "Error"
    End If
End Sub

Private Sub CloseAllOpenIEWindows()
    On Error GoTo ErrorHandler
    
    Dim lhWnd As Long
    Do
        lhWnd = FindWindowEx(0&, lhWnd, "IEFrame", vbNullString)
        If lhWnd Then PostMessage lhWnd, WM_CLOSE, 0&, 0&
    Loop While lhWnd

ErrorHandler:

    If Err <> 0 Then
        MsgBox Err.Source & " --> " & Err.Number & " --> " & Err.Description, , "Error"
    End If
End Sub

