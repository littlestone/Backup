Imports System.Data
Imports System.Data.SqlClient
Imports System.Diagnostics
Imports System.Configuration
Imports System.Windows.Threading
Imports System.Globalization
Imports System.Threading

Namespace IpexCheckImageDisplay

    ''' <summary>
    ''' Interaction logic for MainWindow.xaml
    ''' </summary>
    ''' 
    Class MainWindow

        Private dtAccountPayablePayment As DataTable = Nothing
        Private objApp As Microsoft.Office.Interop.Excel.Application = Nothing
        Private objBook As Microsoft.Office.Interop.Excel.Workbook = Nothing
        Private strFileName As String = Nothing

        Private Sub Window_Loaded(sender As System.Object, e As System.Windows.RoutedEventArgs)
            Keyboard.Focus(dpFromCheckDate)
        End Sub

        Private Sub tabSearch_Loaded(sender As Object, e As RoutedEventArgs)
            ' Set default check date range (-6mths to yesterday)
            dpFromCheckDate.SelectedDate = DateTime.Today.AddMonths(-6)
            dpToCheckDate.SelectedDate = DateTime.Today.AddDays(-1)
            cboCurrency.SelectedIndex = 0
        End Sub

        Private Sub btnSearch_Click(sender As Object, e As RoutedEventArgs)
            If UserInputValidationRules() = True Then
                ' Set status
                Cursor = Cursors.Wait
                statusTextBlock.Text = My.Resources.stbWait
                btnSearch.IsEnabled = False
                btnReset.IsEnabled = False
                btnExtract.IsEnabled = False
                AllowUIToUpdate()  ' Refresh UI

                ' Query result
                FillAccountPayablePayments()
                tcCheckSearchDisplay.SelectedItem = tabResult

                ' Reset status
                btnSearch.IsEnabled = True
                btnReset.IsEnabled = True
                btnExtract.IsEnabled = True
                Cursor = Cursors.Arrow
            End If
        End Sub

        Private Function UserInputValidationRules() As Boolean
            Try
                If dpFromCheckDate.SelectedDate > dpToCheckDate.SelectedDate Then
                    Keyboard.Focus(dpFromCheckDate)
                    Throw New Exception(My.Resources.msgCheckDateValidation)
                End If

                Dim dayDifference As TimeSpan = Convert.ToDateTime(dpToCheckDate.SelectedDate.ToString()).Subtract(Convert.ToDateTime(dpFromCheckDate.SelectedDate.ToString()))
                If Convert.ToInt32(dayDifference.TotalDays) > My.Settings.MaximumDayRange Then
                    Keyboard.Focus(dpFromCheckDate)
                    Throw New Exception(My.Resources.msgCheckDateRange & My.Settings.MaximumDayRange & My.Resources.msgDays)
                End If
            Catch ex As Exception
                MessageBox.Show(ex.Message)
                Return False
            End Try
            Return True
        End Function

        Private Sub FillAccountPayablePayments()
            Try
                Dim strFromCheckDate As String = dpFromCheckDate.SelectedDate.Value.ToString("yyyy-MM-dd")
                Dim strToCheckDate As String = dpToCheckDate.SelectedDate.Value.ToString("yyyy-MM-dd")
                Dim strCheckNumber As String = tbCheckNumber.Text
                Dim strBankCode As String = tbBankCode.Text
                Dim strCurrencyCode As String = cboCurrency.Text
                Dim strCompanyCode As String = tbCompany.Text
                Dim strSupplierCode As String = tbSupplier.Text
                Dim strInvoiceNumber As String = tbInvoiceNumber.Text
                Dim strCheckImageFileName As String = ""

                Using conn As New SqlConnection(My.Settings.ConnectionString)
                    ' Open the connection
                    conn.Open()

                    ' Call SQL store procedure with parameters
                    Dim cmd As SqlCommand = Nothing
                    Dim strCulture As String = CultureInfo.CurrentCulture.Name

                    If Not String.IsNullOrEmpty(My.Settings.DefaultlLanguage) Then
                        strCulture = My.Settings.DefaultlLanguage
                    End If

                    Dim strLanguage As String = "FR"
                    cmd = New SqlCommand("spd_Select_AccountPayablePayment", conn)

                    If strculture = "fr-CA" Or strCulture = "fr" Then
                        strLanguage = "FR"
                    Else
                        strLanguage = "EN"
                    End If

                    cmd.CommandType = CommandType.StoredProcedure
                    cmd.Parameters.AddWithValue("@strFromCheckDate", strFromCheckDate)
                    cmd.Parameters.AddWithValue("@strToCheckDate", strToCheckDate)
                    cmd.Parameters.AddWithValue("@strCheckNumber", strCheckNumber)
                    cmd.Parameters.AddWithValue("@strBankCode", strBankCode)
                    cmd.Parameters.AddWithValue("@strCurrencyCode", strCurrencyCode)
                    cmd.Parameters.AddWithValue("@strCompanyCode", strCompanyCode)
                    cmd.Parameters.AddWithValue("@strSupplierCode", strSupplierCode)
                    cmd.Parameters.AddWithValue("@strInvoiceNumber", strInvoiceNumber)
                    cmd.Parameters.AddWithValue("@strCheckImageFileName", strCheckImageFileName)
                    cmd.Parameters.AddWithValue("@strLanguage", strLanguage)

                    Dim adp As New SqlDataAdapter(cmd)
                    Dim dt As New DataTable("AccountPayablePayment")
                    adp.Fill(dt)
                    dtAccountPayablePayment = dt

                    ' Regenerate ViewImage button column to avoid duplicate
                    dgResult.Columns.Clear()

                    dgResult.DataContext = dt.DefaultView
                    statusTextBlock.Text = dgResult.Items.Count.ToString() + My.Resources.stbResult

                    ' Close it myself
                    conn.Close()
                End Using
            Catch ex As SqlException
                MessageBox.Show(ex.Message)
            End Try
        End Sub

        Private Sub dgResult_AutoGeneratedColumns(sender As Object, e As EventArgs)
            ' Generate ViewImage button column
            Dim viewCheckImage As New DataGridTemplateColumn()
            viewCheckImage.Header = My.Resources.dgvCheckImage

            Dim btnView As New FrameworkElementFactory(GetType(Button))
            btnView.SetValue(Button.ContentProperty, My.Resources.btnView)
            btnView.[AddHandler](Button.ClickEvent, New RoutedEventHandler(AddressOf btnViewImage_Click))

            Dim cellView As New DataTemplate()
            cellView.VisualTree = btnView
            viewCheckImage.CellTemplate = cellView
            dgResult.Columns.Add(viewCheckImage)
            dgResult.UpdateLayout()
        End Sub

        Private Sub btnViewImage_Click(sender As Object, e As RoutedEventArgs)
            Try
                Dim row As DataRowView = DirectCast(dgResult.SelectedItems(0), DataRowView) ' Get current selected check record

                Dim filename As String = row.Item(7).ToString() ' The image file name we need to split.
                If filename = "" Then
                    Throw New Exception(My.Resources.msgCheckImageFile)
                End If
                Dim parts As String() = filename.Split(New Char() {"_"c}) ' Split the string on the underscore character.
                Dim dirname As String = parts(0) + "_" + parts(1) + "_" + parts(2) ' Build the target image file directory from parts
                Dim filepath As String = My.Settings.CheckImageFilePath + dirname + "\" + filename
                MessageBox.Show(filepath)
                System.Diagnostics.Process.Start(filepath) ' Display check image with windows default picture viewer application
            Catch ex As Exception
                MessageBox.Show(ex.Message)
            End Try
        End Sub

        Private Sub btnReset_Click(sender As Object, e As RoutedEventArgs)
            dpFromCheckDate.SelectedDate = DateTime.Today.AddMonths(-6)
            dpToCheckDate.SelectedDate = DateTime.Today.AddDays(-1)
            tbCheckNumber.Text = ""
            tbBankCode.Text = ""
            tbCompany.Text = ""
            tbSupplier.Text = ""
            tbInvoiceNumber.Text = ""
        End Sub

        Private Sub btnExtract_Click(sender As System.Object, e As System.Windows.RoutedEventArgs)
            Try
                ' Quit if no check records found
                If dgResult.Items.Count = 0 Then
                    Throw New Exception(My.Resources.msgNoRecord)
                End If

                ' Get ready
                Cursor = Cursors.Wait
                statusTextBlock.Text = My.Resources.msgSaveAsDialogBox
                btnSearch.IsEnabled = False
                btnReset.IsEnabled = False
                btnExtract.IsEnabled = False
                AllowUIToUpdate()  ' Refresh UI

                Dim objSaveFileDialog As New Microsoft.Win32.SaveFileDialog()
                objApp = New Microsoft.Office.Interop.Excel.Application

                ' Configure open file dialog box
                If objApp.Version >= "12.0" Then
                    objSaveFileDialog.FileName = My.Resources.strExcelFileName & dpFromCheckDate.SelectedDate.Value.ToString("yyyyMMdd") & "_" & dpToCheckDate.SelectedDate.Value.ToString("yyyyMMdd") & ".xlsx"  ' Default file name
                    objSaveFileDialog.DefaultExt = ".xlsx"                     ' Default file extension
                    objSaveFileDialog.Filter = My.Resources.dlgSaveAsFilter    ' Filter files by extension
                Else
                    objSaveFileDialog.FileName = My.Resources.strExcelFileName & dpFromCheckDate.SelectedDate.Value.ToString("yyyyMMdd") & "_" & dpToCheckDate.SelectedDate.Value.ToString("yyyyMMdd") & ".xls"
                    objSaveFileDialog.DefaultExt = ".xls"
                    objSaveFileDialog.Filter = My.Resources.dlgSaveAsFilter2003
                End If

                ' Call the ShowDialog method to show the dialog box
                Dim result As Nullable(Of Boolean) = objSaveFileDialog.ShowDialog()

                ' Store the full file name (with path)
                strFileName = objSaveFileDialog.FileName

                ' If the user clicked OK
                If result = True Then
                    ' Check if excel file is alreay opened and in use, stop if it is the case
                    Try
                        Dim fileTemp As System.IO.FileStream = System.IO.File.OpenWrite(strFileName)
                        fileTemp.Close()

                        ' Remove the excel file if exists
                        If System.IO.File.Exists(strFileName) Then
                            System.IO.File.Delete(strFileName)
                        End If

                        ' Start exporting to excel
                        Cursor = Cursors.Wait
                        statusTextBlock.Text = My.Resources.msgExportToExcel
                        AllowUIToUpdate()  ' Refresh UI
                        If ExportToExcelSucceed() = True Then
                            System.Diagnostics.Process.Start(strFileName)
                        End If
                    Catch ex As Exception
                        MessageBox.Show(ex.Message)
                        ' Clean up
                        objApp.Quit()
                        objApp = Nothing
                        objSaveFileDialog = Nothing
                    End Try
                Else
                    ' Clean up
                    objApp.Quit()
                    objApp = Nothing
                    objSaveFileDialog = Nothing
                End If
            Catch ex As Exception
                MessageBox.Show(ex.Message)
                ' Clean up
                If Not objApp Is Nothing Then
                    objApp.Quit()
                    objApp = Nothing
                End If
            Finally
                ' Reset status
                statusTextBlock.Text = My.Resources.stbSearch
                btnSearch.IsEnabled = True
                btnReset.IsEnabled = True
                btnExtract.IsEnabled = True
                Cursor = Cursors.Arrow

                ' Clean up
                GC.Collect()
                GC.WaitForPendingFinalizers()
            End Try
        End Sub

        Private Sub tcCheckSearchDisplay_SelectionChanged(sender As System.Object, e As System.Windows.Controls.SelectionChangedEventArgs) Handles tcCheckSearchDisplay.SelectionChanged
            If tcCheckSearchDisplay.SelectedItem.Header = My.Resources.tabSearch Then
                statusTextBlock.Text = My.Resources.stbSearch
            Else
                statusTextBlock.Text = dgResult.Items.Count.ToString() + My.Resources.stbResult
            End If
        End Sub

        Private Function ExportToExcelSucceed() As Boolean
            Try
                Dim objSheet As Microsoft.Office.Interop.Excel.Worksheet
                Dim range As Microsoft.Office.Interop.Excel.Range

                ' Start a new workbook
                objBook = objApp.Workbooks.Add()
                objSheet = objBook.ActiveSheet()

                Dim dt As System.Data.DataTable = dtAccountPayablePayment
                Dim dc As System.Data.DataColumn
                Dim dr As System.Data.DataRow
                Dim colIndex As Integer = 0
                Dim rowIndex As Integer = 0

                'Get the range where the starting cell has the address m_sStartingCell and its dimensions are m_iNumRows x m_iNumCols
                range = objSheet.Range("A1", Reflection.Missing.Value)
                range = range.Resize(dt.Rows.Count + 1, dt.Columns.Count)
                range.NumberFormat = "@"    ' Set number format as text

                ' Create an array list.
                Dim multiArray(dt.Rows.Count + 1, dt.Columns.Count) As String

                ' Fill column names to array
                For Each dc In dt.Columns
                    multiArray(0, colIndex) = dc.ColumnName
                    colIndex = colIndex + 1
                Next

                ' Fill each record row to array
                For Each dr In dt.Rows
                    rowIndex = rowIndex + 1
                    colIndex = 0
                    For Each dc In dt.Columns
                        multiArray(rowIndex, colIndex) = dr(dc.ColumnName)
                        colIndex = colIndex + 1
                    Next
                Next

                ' Set the range value to the array
                range.Value = multiArray

                ' Column width auto fit as cell value
                objSheet.Columns.AutoFit()

                Return True
            Catch ex As Exception
                MessageBox.Show(ex.Message)
                Return False
            Finally
                ' Save the excel file
                objBook.SaveAs(strFileName)

                ' Clean up
                objBook = Nothing
                objApp.Quit()
                objApp = Nothing
                GC.Collect()
                GC.WaitForPendingFinalizers()
            End Try
        End Function

        ' This function needs to be called right before the long running operation to force the UI thread to update
        Public Sub AllowUIToUpdate()
            Dim frame As New DispatcherFrame()
            Dispatcher.CurrentDispatcher.BeginInvoke(DispatcherPriority.Render, New DispatcherOperationCallback(AddressOf JunkMethod), frame)
            Dispatcher.PushFrame(frame)
            DoEvents()
        End Sub

        Private Function JunkMethod(ByVal arg As Object) As Object
            'DirectCast(arg, DispatcherFrame).Continue = False
            CType(arg, DispatcherFrame).Continue = False
            Return Nothing
        End Function

        ' Use the DoEvents method to update control content before "do other code"
        Public Sub DoEvents()
            Dim frame As New DispatcherFrame()
            Dispatcher.CurrentDispatcher.BeginInvoke(DispatcherPriority.Background, New DispatcherOperationCallback(AddressOf ExitFrame), frame)
            Dispatcher.PushFrame(frame)
        End Sub

        Public Function ExitFrame(ByVal f As Object) As Object
            CType(f, DispatcherFrame).Continue = False
            Return Nothing
        End Function

    End Class

End Namespace
