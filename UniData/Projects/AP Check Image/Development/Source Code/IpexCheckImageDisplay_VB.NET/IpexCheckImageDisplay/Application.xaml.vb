Imports System.Globalization
Imports System.Threading
Imports System.Configuration

Class Application
    ' Application-level events, such as Startup, Exit, and DispatcherUnhandledException
    ' can be handled in this file.
    Public Sub New()
        If My.Settings.DefaultlLanguage = "" Then
            My.Settings.DefaultlLanguage = Thread.CurrentThread.CurrentCulture.Name ' Initialize to OS default language for usersettings
        Else
            My.Settings.DefaultlLanguage = My.Settings.DefaultlLanguage ' Initialize to user's default lanugage choice
        End If
        My.Settings.Save()

        If Not String.IsNullOrEmpty(My.Settings.DefaultlLanguage) Then
            Thread.CurrentThread.CurrentUICulture = New CultureInfo(My.Settings.DefaultlLanguage)
        End If
        If Not String.IsNullOrEmpty(My.Settings.DefaultlLanguage) Then
            Thread.CurrentThread.CurrentCulture = New CultureInfo(My.Settings.DefaultlLanguage)
        End If
        FrameworkElement.LanguageProperty.OverrideMetadata(GetType(FrameworkElement), New FrameworkPropertyMetadata(System.Windows.Markup.XmlLanguage.GetLanguage(CultureInfo.CurrentCulture.IetfLanguageTag)))
    End Sub
End Class
