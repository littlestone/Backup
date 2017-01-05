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

            ' read records as unidataset
            Dim sArray As String() = {"2", "12", "3", "4"}

            uSet = fl.ReadRecords(sArray)

            ' use for each statement to print the record
            Dim item As UniRecord

            For Each item In uSet
                Console.WriteLine(item.ToString())
            Next item

            ' use index to print the record
            Dim lCount As Integer = uSet.RowCount
            Dim ii As Integer
            For ii = 0 To (lCount - 1)
                Dim ee As UniRecord = uSet(ii)
                Console.WriteLine(ee.ToString())
            Next ii

            ' print one by one record
            Dim q2 As UniRecord = uSet("2")
            Dim sq2 As String = q2.ToString()
            Console.WriteLine("  Record data for rec id 2:" + sq2)
            Dim q3 As UniRecord = uSet("3")
            Dim sq3 As String = q3.ToString()
            Console.WriteLine("  Record data for rec id 3:" + sq3)

            'create UniDataSet in the Client Side
            Dim uSet3 As UniDataSet = us1.CreateUniDataSet()
            uSet3.Insert("3", "aaa")
            uSet3.Insert("4", "bbb")
            uSet3.Insert("5", "vvv")
            uSet3.Insert(2, "8", "www")

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
