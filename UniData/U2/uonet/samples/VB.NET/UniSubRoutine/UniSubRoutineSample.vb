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
        Dim subr As UniSubroutine = Nothing


        Try
            Console.WriteLine("Program started... ")
            us1 = UniObjects.OpenSession("localhost", "ZZZ", "xxxx", "HS.SALES", "uvcs")

            Dim RoutineName As String = "!TIMDAT"
            Dim IntTotalAtgs As Integer = 1
            Dim largs([IntTotalAtgs]) As String
            largs(0) = "1"
            Dim tmpStr2 As UniDynArray
            subr = us1.CreateUniSubroutine(RoutineName, IntTotalAtgs)
            Dim i As Integer
            For i = 0 To (IntTotalAtgs - 1)
                subr.SetArg(i, largs(i))
            Next i
            subr.Call()
            tmpStr2 = subr.GetArgDynArray(0)
            Dim result As String = Environment.NewLine & "Result is :" & tmpStr2.ToString()
            Console.WriteLine("  Response from UniSubRoutineSample :" + result)
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
