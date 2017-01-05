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
        Try
            Console.WriteLine("Program started... ")
            us1 = UniObjects.OpenSession("localhost", "ZZZ", "xxxx", "HS.SALES", "uvcs")

            '/creating UniDynArray
            Dim bFM As Char = Convert.ToChar(254)
            Dim bVM As Char = Convert.ToChar(253)
            Dim bSVM As Char = Convert.ToChar(252)
            Dim str As String
            str = "ab" & bFM & "cd" & bVM & "ef" & bVM & "gh" & bVM & "ij" & bFM & "kl" & bSVM & "mn" & bSVM & "no" & bVM & "p" & bVM & "qr" & bFM & "s" & bFM & "t" & bFM & ""
            Dim lDynArray As New UniDynArray(us1, str)

            ' run  Count()
            Dim myVal As Integer = lDynArray.Count()

            ' run Dcount()
            Dim myVal2 As Integer = lDynArray.Dcount()

            ' run Extract 
            Dim real As UniDynArray = lDynArray.Extract(1, 1, 0)

            'run Replace
            lDynArray.Replace(2, 0, 0, "*")

            'run delete
            lDynArray.Delete(1, 0, 0)

            ' run insert
            lDynArray.Insert(0, 0, 0, "2500")

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
