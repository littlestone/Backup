Attribute VB_Name = "modRevenuQuebec"
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

Public Sub DemoRevenuQuebec()
    ' Make sure you add references to Microsoft Internet Controls (shdocvw.dll) and
    ' Microsoft HTML object Library.
    ' Code will NOT run otherwise.
    
    On Error GoTo ErrorHandler
    
    Dim objIE As SHDocVw.InternetExplorer 'microsoft internet controls (shdocvw.dll)
    Dim objIE2 As SHDocVw.InternetExplorer
    Dim htmlDoc As MSHTML.HTMLDocument 'Microsoft HTML Object Library
    Dim htmlInput As MSHTML.HTMLInputElement
    Dim htmlTextArea As MSHTML.HTMLTextAreaElement
    Dim htmlColl As MSHTML.IHTMLElementCollection
    Dim x As Integer
    Dim NumRows As Integer
    
    Set objIE = New SHDocVw.InternetExplorer
     
    With objIE
        .Navigate "http://www.revenuquebec.ca/en/sepf/services/sgp_validation_tvq/default.aspx" ' Main page
        .Visible = True     ' IE1 backgroud running flag
        
        ' Wait for the new page to load
        Do While .ReadyState <> READYSTATE_COMPLETE Or objIE.Busy: DoEvents: Loop
            Application.Wait (Now + TimeValue("0:00:02"))
            
            ' Simulate Mouse Click on "Access Service" Button
            Call objIE.Document.parentWindow.execScript("SoumettreParam('S00047','A')", "JavaScript")
            Do While objIE.ReadyState <> READYSTATE_COMPLETE Or objIE.Busy: DoEvents: Loop
                Application.Wait (Now + TimeValue("0:00:02"))
                
                ' Get the start page and set the doc html document object
                Set objIE2 = getBrowserChildWindow(objIE)
                If objIE2 Is Nothing Then
                    MsgBox "Browser child window not found.", vbExclamation
                Else
                    objIE2.Visible = True   ' IE2 backgroud running flag
                    Do While objIE2.ReadyState <> READYSTATE_COMPLETE Or objIE2.Busy: DoEvents: Loop
                        Application.Wait (Now + TimeValue("0:00:02"))
                        
                        Set htmlDoc = objIE2.Document
                        Set htmlColl = htmlDoc.getElementsByTagName("input")
                        Do While htmlDoc.ReadyState <> "complete": DoEvents: Loop
                            For Each htmlInput In htmlColl
                                If Trim(htmlInput.ID) = "K1RubanBoutons_btnCommencer" Then
                                    htmlInput.Click
                                    Exit For
                                End If
                            Next htmlInput
                End If
    End With
    
    ' Wait for the new page to load
    Do While objIE2.ReadyState <> READYSTATE_COMPLETE Or objIE2.Busy: DoEvents: Loop
        Application.Wait (Now + TimeValue("0:00:02"))
        
        ' Set numrows = number of rows of data.
        Sheet1.Select
        NumRows = Sheet1.Range(Range("A2"), Range("A65535").End(xlUp)).Rows.Count
    
        ' Select cell a2.
        Range("A2").Select
    
        ' Establish "For" loop to loop "numrows" number of times.
        For x = 1 To NumRows
            ' Get the HTML document of the search page
            Set htmlDoc = objIE2.Document
            Set htmlColl = htmlDoc.getElementsByTagName("input")
            Do While htmlDoc.ReadyState <> "complete": DoEvents: Loop
                For Each htmlInput In htmlColl
                    If Trim(htmlInput.ID) = "S_ValidationNoTVQ1_S_LigneNoTVQ1_NumeroTVQ" And Trim(htmlInput.Type) = "text" Then
                        htmlInput.Value = Range("A" & x + 1).Text       'Enter the first 10 digits of the QST number displayed on the invoice from your supplier. (This is not a social insurance number, consumer number or certificate number)
                    End If
                    If Trim(htmlInput.ID) = "S_ValidationNoTVQ1_S_LigneNoTVQ1_SequentielTVQ" And Trim(htmlInput.Type) = "text" Then
                        htmlInput.Value = Range("B" & x + 1).Text       'Enter the TQ sequence number (4 digits)
                    End If
                    If Trim(htmlInput.ID) = "K1RubanBoutons_btnRechercher" Then
                        htmlInput.Click
                        Exit For
                    End If
                Next htmlInput
    
            ' Wait for the result page to load
            Do While objIE2.ReadyState <> READYSTATE_COMPLETE Or objIE2.Busy: DoEvents: Loop
                Application.Wait (Now + TimeValue("0:00:02"))
            
            ' Get the HTML document of the result page and populate the validation result back to excel
            Set htmlDoc = objIE2.Document
            Set htmlColl = htmlDoc.getElementsByTagName("input")
            Do While htmlDoc.ReadyState <> "complete": DoEvents: Loop
                For Each htmlInput In htmlColl
                    If Trim(htmlInput.Name) = "S_ResultatNoTVQ1$ReponseStatut" Then
                        Range("C" & x + 1) = Trim(htmlInput.Value)
                    End If
                    If Trim(htmlInput.Name) = "S_ResultatNoTVQ1$K1DateValide" Then
                        Range("D" & x + 1) = Trim(htmlInput.Value)
                        Exit For
                    End If
                Next htmlInput
        
            Set htmlColl = htmlDoc.getElementsByTagName("textarea")
            Do While htmlDoc.ReadyState <> "complete": DoEvents: Loop
                For Each htmlTextArea In htmlColl
                    If Trim(htmlTextArea.ID) = "S_ResultatNoTVQ1_ReponseRaison" Then
                        Range("E" & x + 1) = Trim(htmlTextArea.Value)
                        Exit For
                    End If
                Next htmlTextArea
    
            ' Go back to the search page and refresh the page
            Set htmlColl = htmlDoc.getElementsByTagName("input")
            Do While htmlDoc.ReadyState <> "complete": DoEvents: Loop
                For Each htmlInput In htmlColl
                    If Trim(htmlInput.ID) = "K1RubanBoutons_btnPrecedente" Then
                        htmlInput.Click
                        Exit For
                    End If
                Next htmlInput
        
            ' Wait for the search page to reload
            Do While objIE2.ReadyState <> READYSTATE_COMPLETE Or objIE2.Busy: DoEvents: Loop
                Application.Wait (Now + TimeValue("0:00:02"))
    
            If Range("C" & x + 1) = "" Then
               Range("C" & x + 1) = "The identification number is invalid. (1127)"
            End If
            
ProcessNext:
            ' Selects cell down 1 row from active cell.
            ActiveCell.Offset(1, 0).Select
        Next
        
        ' Close IE
        Call CloseAllOpenIEWindows
            
ErrorHandler:
    ' Clean up
    Set objIE = Nothing
    Set objIE2 = Nothing
    Set htmlDoc = Nothing
    Set htmlInput = Nothing
    Set htmlColl = Nothing
    
    ' Close IE
    Call CloseAllOpenIEWindows
    
    If Err <> 0 Then
        MsgBox Err.Source & " --> " & Err.Number & " --> " & Err.Description, , "Error"
    End If
End Sub

Private Function getBrowserChildWindow(ByVal ie1 As InternetExplorer) As InternetExplorer
    On Error GoTo ErrorHandler

    Dim windowList As SHDocVw.ShellWindows
    Set windowList = New SHDocVw.ShellWindows
  
    Dim windowIdx As Long
    For windowIdx = 0 To windowList.Count - 1
        Dim tmpWindow As SHDocVw.InternetExplorer
    
        On Error Resume Next
        
        Set tmpWindow = windowList.Item(windowIdx)
        If Err.Number = 0 Then
            If ie1.FullName = tmpWindow.FullName And ie1.hwnd <> tmpWindow.hwnd Then
                Set getBrowserChildWindow = tmpWindow
                Exit For
            End If
        Else
            Err.Clear
        End If
  Next windowIdx
  
  Set tmpWindow = Nothing
  Exit Function

ErrorHandler:

  Set tmpWindow = Nothing
  Set getBrowserChildWindow = Nothing
  
  Err.Raise Err.Number, Err.Source, Err.Description

End Function

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
