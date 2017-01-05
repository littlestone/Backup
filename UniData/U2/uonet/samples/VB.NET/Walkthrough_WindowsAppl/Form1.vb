Imports System
Imports System.Drawing
Imports System.Collections
Imports System.ComponentModel
Imports System.Windows.Forms
Imports System.Data
Imports System.Text
Imports IBMU2.UODOTNET

Public Class Form1
    Inherits System.Windows.Forms.Form

#Region " Windows Form Designer generated code "

    Public Sub New()
        MyBase.New()

        'This call is required by the Windows Form Designer.
        InitializeComponent()

        'Add any initialization after the InitializeComponent() call

    End Sub

    'Form overrides dispose to clean up the component list.
    Protected Overloads Overrides Sub Dispose(ByVal disposing As Boolean)
        If disposing Then
            If Not (components Is Nothing) Then
                components.Dispose()
            End If
        End If
        MyBase.Dispose(disposing)
    End Sub

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    Friend WithEvents groupBox2 As System.Windows.Forms.GroupBox
    Friend WithEvents comboBox_filename As System.Windows.Forms.ComboBox
    Friend WithEvents label5 As System.Windows.Forms.Label
    Friend WithEvents comboBox_record As System.Windows.Forms.ComboBox
    Friend WithEvents label7 As System.Windows.Forms.Label
    Friend WithEvents button_load As System.Windows.Forms.Button
    Friend WithEvents label6 As System.Windows.Forms.Label
    Friend WithEvents statusBar1 As System.Windows.Forms.StatusBar
    Friend WithEvents groupBox3 As System.Windows.Forms.GroupBox
    Friend WithEvents button_command As System.Windows.Forms.Button
    Friend WithEvents comboBox_command As System.Windows.Forms.ComboBox
    Friend WithEvents label8 As System.Windows.Forms.Label
    Friend WithEvents comboBox_account As System.Windows.Forms.ComboBox
    Friend WithEvents groupBox1 As System.Windows.Forms.GroupBox
    Friend WithEvents radioButton2 As System.Windows.Forms.RadioButton
    Friend WithEvents radioButton1 As System.Windows.Forms.RadioButton
    Friend WithEvents textBox_password As System.Windows.Forms.TextBox
    Friend WithEvents label4 As System.Windows.Forms.Label
    Friend WithEvents textBox_user As System.Windows.Forms.TextBox
    Friend WithEvents label2 As System.Windows.Forms.Label
    Friend WithEvents label3 As System.Windows.Forms.Label
    Friend WithEvents textBox_hostname As System.Windows.Forms.TextBox
    Friend WithEvents textBox_data As System.Windows.Forms.TextBox
    Friend WithEvents label1 As System.Windows.Forms.Label
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
        Dim resources As System.Resources.ResourceManager = New System.Resources.ResourceManager(GetType(Form1))
        Me.groupBox2 = New System.Windows.Forms.GroupBox
        Me.comboBox_filename = New System.Windows.Forms.ComboBox
        Me.label5 = New System.Windows.Forms.Label
        Me.comboBox_record = New System.Windows.Forms.ComboBox
        Me.label7 = New System.Windows.Forms.Label
        Me.button_load = New System.Windows.Forms.Button
        Me.label6 = New System.Windows.Forms.Label
        Me.statusBar1 = New System.Windows.Forms.StatusBar
        Me.groupBox3 = New System.Windows.Forms.GroupBox
        Me.button_command = New System.Windows.Forms.Button
        Me.comboBox_command = New System.Windows.Forms.ComboBox
        Me.label8 = New System.Windows.Forms.Label
        Me.comboBox_account = New System.Windows.Forms.ComboBox
        Me.groupBox1 = New System.Windows.Forms.GroupBox
        Me.radioButton2 = New System.Windows.Forms.RadioButton
        Me.radioButton1 = New System.Windows.Forms.RadioButton
        Me.textBox_password = New System.Windows.Forms.TextBox
        Me.label4 = New System.Windows.Forms.Label
        Me.textBox_user = New System.Windows.Forms.TextBox
        Me.label2 = New System.Windows.Forms.Label
        Me.label3 = New System.Windows.Forms.Label
        Me.textBox_hostname = New System.Windows.Forms.TextBox
        Me.textBox_data = New System.Windows.Forms.TextBox
        Me.label1 = New System.Windows.Forms.Label
        Me.groupBox2.SuspendLayout()
        Me.groupBox3.SuspendLayout()
        Me.groupBox1.SuspendLayout()
        Me.SuspendLayout()
        '
        'groupBox2
        '
        Me.groupBox2.Controls.Add(Me.comboBox_filename)
        Me.groupBox2.Controls.Add(Me.label5)
        Me.groupBox2.Controls.Add(Me.comboBox_record)
        Me.groupBox2.Controls.Add(Me.label7)
        Me.groupBox2.Controls.Add(Me.button_load)
        Me.groupBox2.Location = New System.Drawing.Point(296, 12)
        Me.groupBox2.Name = "groupBox2"
        Me.groupBox2.Size = New System.Drawing.Size(240, 120)
        Me.groupBox2.TabIndex = 31
        Me.groupBox2.TabStop = False
        Me.groupBox2.Text = "Read/Write:"
        '
        'comboBox_filename
        '
        Me.comboBox_filename.Items.AddRange(New Object() {"CUSTOMER", "PRODUCTS", "STATES", "PRODS"})
        Me.comboBox_filename.Location = New System.Drawing.Point(112, 24)
        Me.comboBox_filename.Name = "comboBox_filename"
        Me.comboBox_filename.Size = New System.Drawing.Size(121, 22)
        Me.comboBox_filename.TabIndex = 15
        Me.comboBox_filename.Text = "CUSTOMER"
        '
        'label5
        '
        Me.label5.Location = New System.Drawing.Point(8, 24)
        Me.label5.Name = "label5"
        Me.label5.Size = New System.Drawing.Size(72, 23)
        Me.label5.TabIndex = 14
        Me.label5.Text = "File Name:"
        '
        'comboBox_record
        '
        Me.comboBox_record.Items.AddRange(New Object() {"All", "2", "1002", "4"})
        Me.comboBox_record.Location = New System.Drawing.Point(112, 56)
        Me.comboBox_record.Name = "comboBox_record"
        Me.comboBox_record.Size = New System.Drawing.Size(121, 22)
        Me.comboBox_record.TabIndex = 13
        Me.comboBox_record.Text = "All"
        '
        'label7
        '
        Me.label7.Location = New System.Drawing.Point(8, 56)
        Me.label7.Name = "label7"
        Me.label7.Size = New System.Drawing.Size(56, 23)
        Me.label7.TabIndex = 12
        Me.label7.Text = "Record:"
        '
        'button_load
        '
        Me.button_load.Location = New System.Drawing.Point(8, 88)
        Me.button_load.Name = "button_load"
        Me.button_load.Size = New System.Drawing.Size(80, 23)
        Me.button_load.TabIndex = 1
        Me.button_load.Text = "Load_Record"
        '
        'label6
        '
        Me.label6.Location = New System.Drawing.Point(8, 196)
        Me.label6.Name = "label6"
        Me.label6.TabIndex = 30
        Me.label6.Text = "Output/Error:"
        '
        'statusBar1
        '
        Me.statusBar1.Location = New System.Drawing.Point(0, 487)
        Me.statusBar1.Name = "statusBar1"
        Me.statusBar1.Size = New System.Drawing.Size(808, 22)
        Me.statusBar1.SizingGrip = False
        Me.statusBar1.TabIndex = 29
        Me.statusBar1.Text = "Status"
        '
        'groupBox3
        '
        Me.groupBox3.Controls.Add(Me.button_command)
        Me.groupBox3.Controls.Add(Me.comboBox_command)
        Me.groupBox3.Controls.Add(Me.label8)
        Me.groupBox3.Location = New System.Drawing.Point(552, 4)
        Me.groupBox3.Name = "groupBox3"
        Me.groupBox3.Size = New System.Drawing.Size(240, 88)
        Me.groupBox3.TabIndex = 32
        Me.groupBox3.TabStop = False
        Me.groupBox3.Text = "Command/StoreProcedure"
        '
        'button_command
        '
        Me.button_command.Location = New System.Drawing.Point(8, 56)
        Me.button_command.Name = "button_command"
        Me.button_command.Size = New System.Drawing.Size(136, 23)
        Me.button_command.TabIndex = 2
        Me.button_command.Text = "Load_CommandOutput"
        '
        'comboBox_command
        '
        Me.comboBox_command.Items.AddRange(New Object() {"LIST VOC SAMPLE 10", "DATE"})
        Me.comboBox_command.Location = New System.Drawing.Point(80, 24)
        Me.comboBox_command.Name = "comboBox_command"
        Me.comboBox_command.Size = New System.Drawing.Size(152, 22)
        Me.comboBox_command.TabIndex = 1
        Me.comboBox_command.Text = "LIST VOC SAMPLE 10"
        '
        'label8
        '
        Me.label8.Location = New System.Drawing.Point(8, 24)
        Me.label8.Name = "label8"
        Me.label8.Size = New System.Drawing.Size(64, 23)
        Me.label8.TabIndex = 0
        Me.label8.Text = "Command:"
        '
        'comboBox_account
        '
        Me.comboBox_account.Items.AddRange(New Object() {"demo", "HS.SALES", "HS.SERVICE"})
        Me.comboBox_account.Location = New System.Drawing.Point(160, 36)
        Me.comboBox_account.Name = "comboBox_account"
        Me.comboBox_account.Size = New System.Drawing.Size(121, 22)
        Me.comboBox_account.TabIndex = 33
        Me.comboBox_account.Text = "demo"
        '
        'groupBox1
        '
        Me.groupBox1.Controls.Add(Me.radioButton2)
        Me.groupBox1.Controls.Add(Me.radioButton1)
        Me.groupBox1.Location = New System.Drawing.Point(24, 124)
        Me.groupBox1.Name = "groupBox1"
        Me.groupBox1.Size = New System.Drawing.Size(112, 64)
        Me.groupBox1.TabIndex = 28
        Me.groupBox1.TabStop = False
        Me.groupBox1.Text = "U2 Database"
        '
        'radioButton2
        '
        Me.radioButton2.Location = New System.Drawing.Point(16, 32)
        Me.radioButton2.Name = "radioButton2"
        Me.radioButton2.Size = New System.Drawing.Size(72, 24)
        Me.radioButton2.TabIndex = 1
        Me.radioButton2.Text = "UniVerse"
        '
        'radioButton1
        '
        Me.radioButton1.Checked = True
        Me.radioButton1.Location = New System.Drawing.Point(16, 16)
        Me.radioButton1.Name = "radioButton1"
        Me.radioButton1.Size = New System.Drawing.Size(64, 24)
        Me.radioButton1.TabIndex = 0
        Me.radioButton1.TabStop = True
        Me.radioButton1.Text = "UniData"
        '
        'textBox_password
        '
        Me.textBox_password.Location = New System.Drawing.Point(160, 100)
        Me.textBox_password.Name = "textBox_password"
        Me.textBox_password.PasswordChar = Microsoft.VisualBasic.ChrW(42)
        Me.textBox_password.Size = New System.Drawing.Size(121, 20)
        Me.textBox_password.TabIndex = 27
        Me.textBox_password.Text = "ani2ka"
        '
        'label4
        '
        Me.label4.Location = New System.Drawing.Point(24, 100)
        Me.label4.Name = "label4"
        Me.label4.TabIndex = 26
        Me.label4.Text = "Password:"
        '
        'textBox_user
        '
        Me.textBox_user.Location = New System.Drawing.Point(160, 68)
        Me.textBox_user.Name = "textBox_user"
        Me.textBox_user.Size = New System.Drawing.Size(121, 20)
        Me.textBox_user.TabIndex = 25
        Me.textBox_user.Text = "ZZZ"
        '
        'label2
        '
        Me.label2.Location = New System.Drawing.Point(24, 36)
        Me.label2.Name = "label2"
        Me.label2.TabIndex = 23
        Me.label2.Text = "Account:"
        '
        'label3
        '
        Me.label3.Location = New System.Drawing.Point(24, 68)
        Me.label3.Name = "label3"
        Me.label3.TabIndex = 24
        Me.label3.Text = "User ID:"
        '
        'textBox_hostname
        '
        Me.textBox_hostname.Location = New System.Drawing.Point(160, 4)
        Me.textBox_hostname.Name = "textBox_hostname"
        Me.textBox_hostname.Size = New System.Drawing.Size(121, 20)
        Me.textBox_hostname.TabIndex = 22
        Me.textBox_hostname.Text = "localhost"
        '
        'textBox_data
        '
        Me.textBox_data.Location = New System.Drawing.Point(8, 220)
        Me.textBox_data.Multiline = True
        Me.textBox_data.Name = "textBox_data"
        Me.textBox_data.ScrollBars = System.Windows.Forms.ScrollBars.Both
        Me.textBox_data.Size = New System.Drawing.Size(792, 260)
        Me.textBox_data.TabIndex = 20
        Me.textBox_data.Text = ""
        '
        'label1
        '
        Me.label1.Location = New System.Drawing.Point(24, 4)
        Me.label1.Name = "label1"
        Me.label1.TabIndex = 21
        Me.label1.Text = "Host Name:"
        '
        'Form1
        '
        Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
        Me.ClientSize = New System.Drawing.Size(808, 509)
        Me.Controls.Add(Me.groupBox2)
        Me.Controls.Add(Me.label6)
        Me.Controls.Add(Me.statusBar1)
        Me.Controls.Add(Me.groupBox3)
        Me.Controls.Add(Me.comboBox_account)
        Me.Controls.Add(Me.groupBox1)
        Me.Controls.Add(Me.textBox_password)
        Me.Controls.Add(Me.label4)
        Me.Controls.Add(Me.textBox_user)
        Me.Controls.Add(Me.label2)
        Me.Controls.Add(Me.label3)
        Me.Controls.Add(Me.textBox_hostname)
        Me.Controls.Add(Me.textBox_data)
        Me.Controls.Add(Me.label1)
        Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
        Me.Name = "Form1"
        Me.Text = "Walkthrough_WindowsAppl"
        Me.groupBox2.ResumeLayout(False)
        Me.groupBox3.ResumeLayout(False)
        Me.groupBox1.ResumeLayout(False)
        Me.ResumeLayout(False)

    End Sub

#End Region

    Private Sub button_load_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles button_load.Click
        Dim currentCursor As Cursor = Cursor.Current
        Dim lHostName As String = textBox_hostname.Text
        Dim lAccount As String = comboBox_account.Text
        Dim lUser As String = textBox_user.Text
        Dim lPassword As String = textBox_password.Text
        Dim lFileName As String = comboBox_filename.Text
        Dim lServiceType As String
        Dim lStrValue As New StringBuilder
        Dim lRecIDArray() As String
        Dim lRecIDList As New ArrayList
        Dim lRecordID As String = comboBox_record.Text
        If radioButton1.Checked Then
            lServiceType = "udcs"
        Else
            lServiceType = "uvcs"
        End If
        Dim us As UniSession = Nothing

        Try
            Cursor.Current = Cursors.WaitCursor
            statusBar1.Text = "Connecting..." & lHostName & " " & lUser & " " & lAccount & " " & lServiceType
            'get the session object
            us = UniObjects.OpenSession(lHostName, lUser, lPassword, lAccount, lServiceType)
            statusBar1.Text = "Connected..." & lHostName & " " & lUser & " " & lAccount & " " & lServiceType
            Cursor.Current = currentCursor
            statusBar1.Text = "Loading Data..."
            Cursor.Current = Cursors.WaitCursor
            'open file
            Dim fl As UniFile = us.CreateUniFile(lFileName)
            If lRecordID.Equals("All") Then
                ' create select list
                Dim sl As UniSelectList = us.CreateUniSelectList(2)
                sl.Select(fl)
                lRecIDArray = sl.ReadListAsStringArray()
                ' read records using array of records ids
                Dim lSet As UniDataSet = fl.ReadRecords(lRecIDArray)
                Dim item As UniRecord

                For Each item In lSet
                    textBox_data.AppendText(item.ToString())
                    textBox_data.AppendText(Environment.NewLine)
                Next item


            Else
                ' display data
                textBox_data.Text = fl.Read(lRecordID).StringValue

            End If


        Catch ex As Exception
            textBox_data.Text = ex.Message
        Finally
            If Not (us Is Nothing) Then
                If (us.IsActive) Then
                    UniObjects.CloseSession(us)
                End If
            End If
            statusBar1.Text = "Done..." & lHostName & " " & lUser & " " & lAccount & " " & lServiceType
            Cursor.Current = currentCursor


        End Try
    End Sub

    Private Sub button_command_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles button_command.Click
        Dim currentCursor As Cursor = Cursor.Current
        Dim lHostName As String = textBox_hostname.Text
        Dim lAccount As String = comboBox_account.Text
        Dim lUser As String = textBox_user.Text
        Dim lPassword As String = textBox_password.Text
        Dim lFileName As String = comboBox_filename.Text
        Dim lServiceType As String
        Dim lStrValue As New StringBuilder
        Dim lRecIDArray() As String
        Dim lRecIDList As New ArrayList
        Dim lRecordID As String = comboBox_record.Text
        Dim lCommand_Name As String = comboBox_command.Text
        If radioButton1.Checked Then
            lServiceType = "udcs"
        Else
            lServiceType = "uvcs"
        End If
        Dim us As UniSession = Nothing

        Try
            Cursor.Current = Cursors.WaitCursor
            statusBar1.Text = "Connecting..." & lHostName & " " & lUser & " " & lAccount & " " & lServiceType
            'get the session object
            us = UniObjects.OpenSession(lHostName, lUser, lPassword, lAccount, lServiceType)
            statusBar1.Text = "Connected..." & lHostName & " " & lUser & " " & lAccount & " " & lServiceType
            Cursor.Current = currentCursor
            statusBar1.Text = "Loading Data..."
            Cursor.Current = Cursors.WaitCursor
            Dim cmd As UniCommand = us.CreateUniCommand()
            cmd.Command = lCommand_Name '"LIST VOC SAMPLE 10";
            cmd.Execute()
            Dim response_str As String = cmd.Response
            ' display data
            textBox_data.Text = response_str


        Catch ex As Exception
            textBox_data.Text = ex.Message
        Finally
            If Not (us Is Nothing) Then
                If (us.IsActive) Then
                    UniObjects.CloseSession(us)
                End If
            End If
            statusBar1.Text = "Done..." & lHostName & " " & lUser & " " & lAccount & " " & lServiceType
            Cursor.Current = currentCursor


        End Try

    End Sub
End Class
