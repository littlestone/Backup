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
        Dim cmd As UniCommand = Nothing
        

        Try
            Console.WriteLine("Program started... ")
            us1 = UniObjects.OpenSession("localhost", "ZZZ", "xxxx", "HS.SALES", "uvcs")
            cmd = us1.CreateUniCommand()
            cmd.Command = "LIST VOC SAMPLE 10"
            cmd.Execute()
            Dim response_str As String
            response_str = cmd.Response
            Console.WriteLine("  Response from UniCommand :" + response_str)

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
