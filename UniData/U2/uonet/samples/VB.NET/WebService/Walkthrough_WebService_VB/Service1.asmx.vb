Imports System.Web.Services
Imports System.Text
Imports IBMU2.UODOTNET


<System.Web.Services.WebService(Namespace := "http://tempuri.org/Walkthrough_WebService_VB/Service1")> _
Public Class Service1
    Inherits System.Web.Services.WebService

#Region " Web Services Designer Generated Code "

    Public Sub New()
        MyBase.New()

        'This call is required by the Web Services Designer.
        InitializeComponent()

        'Add your own initialization code after the InitializeComponent() call

    End Sub

    'Required by the Web Services Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Web Services Designer
    'It can be modified using the Web Services Designer.  
    'Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
        components = New System.ComponentModel.Container()
    End Sub

    Protected Overloads Overrides Sub Dispose(ByVal disposing As Boolean)
        'CODEGEN: This procedure is required by the Web Services Designer
        'Do not modify it using the code editor.
        If disposing Then
            If Not (components Is Nothing) Then
                components.Dispose()
            End If
        End If
        MyBase.Dispose(disposing)
    End Sub

#End Region

    ' WEB SERVICE EXAMPLE
    ' The HelloWorld() example service returns the string Hello World.
    ' To build, uncomment the following lines then save and build the project.
    ' To test this web service, ensure that the .asmx file is the start page
    ' and press F5.
    '
    '<WebMethod()> _
    'Public Function HelloWorld() As String
    '   Return "Hello World"
    'End Function

    ' WEB SERVICE EXAMPLE
    ' The GetCustomer() example service returns the CUSTOMER Table
    <WebMethod(Description:="This method will use UODOTNET and U2 Database to get CUSTOMER data")> _
    Public Function GetCustomer(ByVal pUser As String, ByVal pPassword As String, ByVal pHostName _
                As String, ByVal pAccount As String, ByVal pServiceType As String, _
                ByVal pFileName As String) As String



        Dim lHostName As String = pHostName
        Dim lAccount As String = pAccount
        Dim lUser As String = pUser
        Dim lPassword As String = pPassword
        Dim lFileName As String = pFileName
        Dim lServiceType As String = pServiceType
        Dim lStrValue As New StringBuilder
        Dim lRecIDArray() As String
        Dim lRecIDList As New ArrayList

        
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
            ' return  data
            Return lStrValue.ToString()

        Catch ex As Exception
            Return ex.Message
        Finally
            If Not (us Is Nothing) Then
                If (us.IsActive) Then
                    UniObjects.CloseSession(us)
                End If
            End If



        End Try



    End Function


End Class
