Option Explicit On 
Option Strict On

' Add the classes in the following namespaces to our namespace
Imports System
Imports System.IO
Imports System.Text
Imports System.Collections
Imports IBMU2.UODOTNET


Class App


    Public Shared Function Main(ByVal args() As String) As Integer

        Dim us1 As UniSession = Nothing
        Dim sl As UniSelectList = Nothing
        Dim fl As UniFile = Nothing



        Try
            Console.WriteLine("Program started... ")
            us1 = UniObjects.OpenSession("localhost", "ZZZ", "xxxx", "HS.SALES", "uvcs")

            sl = us1.CreateUniSelectList(2)
            ' open customer file
            fl = us1.CreateUniFile("CUSTOMER")
            sl.Select(fl)
            Dim lLastRecord As Boolean = sl.LastRecordRead
            While Not (lLastRecord)
                Dim s As String = sl.Next()
                Console.WriteLine("Record ID:" + s)
                lLastRecord = sl.LastRecordRead
            End While

            
            ' read select list as string array
            sl.ClearList()
            sl.Select(fl)
            Dim str_array() As String = sl.ReadListAsStringArray()
            Dim uSet As UniDataSet = fl.ReadRecords(str_array)
            ' use for each statement to print the record
            Dim item As UniRecord

            For Each item In uSet
                Console.WriteLine(item.ToString())
            Next item


        Catch e As Exception
            If Not (us1 Is Nothing) Then
                If (us1.IsActive) Then
                    UniObjects.CloseSession(us1)
                    us1 = Nothing
                End If
            End If
            Console.WriteLine("")
            Dim s As String
            s = "Connection Failed : " + e.Message
            Console.WriteLine(s)
        Finally
            If Not (us1 Is Nothing) Then
                If (us1.IsActive) Then
                    Console.WriteLine("")
                    Dim s As String
                    s = "Connection Passed"
                    Console.WriteLine(s)
                    UniObjects.CloseSession(us1)
                    Console.WriteLine("Program finished... ")
                End If

            End If

        End Try
        Console.Read()
        Return 0
    End Function 'Main
End Class 'App
