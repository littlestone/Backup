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
        Dim uSet As UniDataSet = Nothing
        Dim fl As UniFile = Nothing


        Try
            Console.WriteLine("Program started... ")
            us1 = UniObjects.OpenSession("localhost", "ZZZ", "xxxx", "HS.SALES", "uvcs")

            ' open customer file
            fl = us1.CreateUniFile("CUSTOMER")

            ' read a record 
            Dim ar_record As UniDynArray = fl.Read("2")

            'read a field
            Dim ar_record2 As UniDynArray = fl.ReadField("2", 7)

            'read number of fields
            Dim lFieldSet() As Integer = {4, 5, 6}
            Dim ar_record3 As UniDynArray = fl.ReadFields("2", lFieldSet)

            ' read named field
            Dim ar_record4 As UniDynArray = fl.ReadNamedField("2", "LNAME")

            ' read records as unidataset
            Dim sArray As String() = {"2", "12", "3", "4"}

            uSet = fl.ReadRecords(sArray)

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
