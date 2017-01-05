Imports System
Imports System.Drawing
Imports System.Collections
Imports System.ComponentModel
Imports System.Data
Imports System.Text
Imports IBMU2.UODOTNET

Public Class WebForm1
    Inherits System.Web.UI.Page

#Region " Web Form Designer Generated Code "

    'This call is required by the Web Form Designer.
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()

    End Sub
    Protected WithEvents Button_Load As System.Web.UI.WebControls.Button
    Protected WithEvents TextBox_data As System.Web.UI.WebControls.TextBox
    Protected WithEvents RadioButtonList1 As System.Web.UI.WebControls.RadioButtonList
    Protected WithEvents TextBox_FileName As System.Web.UI.WebControls.TextBox
    Protected WithEvents Label5 As System.Web.UI.WebControls.Label
    Protected WithEvents TextBox_Password As System.Web.UI.WebControls.TextBox
    Protected WithEvents Label4 As System.Web.UI.WebControls.Label
    Protected WithEvents TextBox_UserID As System.Web.UI.WebControls.TextBox
    Protected WithEvents Label3 As System.Web.UI.WebControls.Label
    Protected WithEvents TextBox_Account As System.Web.UI.WebControls.TextBox
    Protected WithEvents Label2 As System.Web.UI.WebControls.Label
    Protected WithEvents TextBox_HostName As System.Web.UI.WebControls.TextBox
    Protected WithEvents Label1 As System.Web.UI.WebControls.Label

    'NOTE: The following placeholder declaration is required by the Web Form Designer.
    'Do not delete or move it.
    Private designerPlaceholderDeclaration As System.Object

    Private Sub Page_Init(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Init
        'CODEGEN: This method call is required by the Web Form Designer
        'Do not modify it using the code editor.
        InitializeComponent()
    End Sub

#End Region

    Private Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        'Put user code to initialize the page here
    End Sub

    Private Sub Button_Load_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Button_Load.Click
        Dim lHostName As String = TextBox_HostName.Text
        Dim lAccount As String = TextBox_Account.Text
        Dim lUser As String = TextBox_UserID.Text
        Dim lPassword As String = TextBox_Password.Text
        Dim lFileName As String = TextBox_FileName.Text
        Dim lServiceType As String
        Dim lStrValue As New StringBuilder
        Dim lRecIDArray() As String
        Dim lRecIDList As New ArrayList

        If RadioButtonList1.Items(0).Selected Then
            lServiceType = "udcs"
        Else
            lServiceType = "uvcs"
        End If
        Dim us As UniSession = Nothing

        Try
            
            'get the session object
            us = UniObjects.OpenSession(lHostName, lUser, lPassword, lAccount, lServiceType)
            
            'open file
            Dim fl As UniFile = us.CreateUniFile(lFileName)
            ' create select list
            Dim sl As UniSelectList = us.CreateUniSelectList(2)
            sl.Select(fl)
            lRecIDArray = sl.ReadListAsStringArray()
            ' read records using array of records ids
            Dim lSet As UniDataSet = fl.ReadRecords(lRecIDArray)
            Dim item As UniRecord

            For Each item In lSet
                lStrValue.Append(item.Record.ToString())
                lStrValue.Append("\r\n")
            Next item
            ' display data
            TextBox_data.Text = lStrValue.ToString()

        Catch ex As Exception
            TextBox_data.Text = ex.Message
        Finally
            If Not (us Is Nothing) Then
                If (us.IsActive) Then
                    UniObjects.CloseSession(us)
                End If
            End If
            


        End Try

    End Sub
End Class