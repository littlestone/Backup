Imports IBMU2.UODOTNET
Imports System.Threading
Public Class Form1
    Inherits System.Windows.Forms.Form
    Private m_IsPooling As Boolean = False
    Private m_IdleRemoveThreshold As Integer
    Private m_IdleRemoveExecInterval As Integer
    Private m_MinPoolSize As Integer
    Private m_MaxPoolSize As Integer
    Private m_SimultaneousConnection As Integer
    Private m_Server As String
    Private m_User As String
    Private m_Password As String
    Private m_Account As String
    Private m_DatabaseType As String = "uvcs"

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
    Friend WithEvents StatusBar1 As System.Windows.Forms.StatusBar
    Friend WithEvents ToolBar1 As System.Windows.Forms.ToolBar
    Friend WithEvents MainMenu1 As System.Windows.Forms.MainMenu
    Friend WithEvents MenuItem1 As System.Windows.Forms.MenuItem
    Friend WithEvents MenuItem2 As System.Windows.Forms.MenuItem
    Friend WithEvents MenuItem3 As System.Windows.Forms.MenuItem
    Friend WithEvents MenuItem4 As System.Windows.Forms.MenuItem
    Friend WithEvents MenuItem5 As System.Windows.Forms.MenuItem
    Friend WithEvents ToolBarButton1 As System.Windows.Forms.ToolBarButton
    Friend WithEvents ToolBarButton2 As System.Windows.Forms.ToolBarButton
    Friend WithEvents ImageList1 As System.Windows.Forms.ImageList
    Friend WithEvents Panel1 As System.Windows.Forms.Panel
    Friend WithEvents Splitter1 As System.Windows.Forms.Splitter
    Friend WithEvents Panel2 As System.Windows.Forms.Panel
    Friend WithEvents TabControl1 As System.Windows.Forms.TabControl
    Friend WithEvents TabPage1 As System.Windows.Forms.TabPage
    Friend WithEvents textBox_execinterval As System.Windows.Forms.TextBox
    Friend WithEvents textBox_idlethreshold As System.Windows.Forms.TextBox
    Friend WithEvents textBox_simulconn As System.Windows.Forms.TextBox
    Friend WithEvents textBox_maxsize As System.Windows.Forms.TextBox
    Friend WithEvents textBox_minsize As System.Windows.Forms.TextBox
    Friend WithEvents textBox_account As System.Windows.Forms.TextBox
    Friend WithEvents textBox_hostname As System.Windows.Forms.TextBox
    Friend WithEvents textBox_password As System.Windows.Forms.TextBox
    Friend WithEvents label9 As System.Windows.Forms.Label
    Friend WithEvents label8 As System.Windows.Forms.Label
    Friend WithEvents label7 As System.Windows.Forms.Label
    Friend WithEvents label6 As System.Windows.Forms.Label
    Friend WithEvents label5 As System.Windows.Forms.Label
    Friend WithEvents label4 As System.Windows.Forms.Label
    Friend WithEvents label3 As System.Windows.Forms.Label
    Friend WithEvents label2 As System.Windows.Forms.Label
    Friend WithEvents label1 As System.Windows.Forms.Label
    Friend WithEvents textBox_user As System.Windows.Forms.TextBox
    Friend WithEvents groupBox1 As System.Windows.Forms.GroupBox
    Friend WithEvents radioButton2 As System.Windows.Forms.RadioButton
    Friend WithEvents radioButton1 As System.Windows.Forms.RadioButton
    Friend WithEvents TextBox_output As System.Windows.Forms.TextBox
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
        Me.components = New System.ComponentModel.Container
        Dim resources As System.Resources.ResourceManager = New System.Resources.ResourceManager(GetType(Form1))
        Me.StatusBar1 = New System.Windows.Forms.StatusBar
        Me.ToolBar1 = New System.Windows.Forms.ToolBar
        Me.MainMenu1 = New System.Windows.Forms.MainMenu
        Me.MenuItem1 = New System.Windows.Forms.MenuItem
        Me.MenuItem2 = New System.Windows.Forms.MenuItem
        Me.MenuItem3 = New System.Windows.Forms.MenuItem
        Me.MenuItem4 = New System.Windows.Forms.MenuItem
        Me.MenuItem5 = New System.Windows.Forms.MenuItem
        Me.ToolBarButton1 = New System.Windows.Forms.ToolBarButton
        Me.ToolBarButton2 = New System.Windows.Forms.ToolBarButton
        Me.ImageList1 = New System.Windows.Forms.ImageList(Me.components)
        Me.Panel1 = New System.Windows.Forms.Panel
        Me.Splitter1 = New System.Windows.Forms.Splitter
        Me.Panel2 = New System.Windows.Forms.Panel
        Me.TabControl1 = New System.Windows.Forms.TabControl
        Me.TabPage1 = New System.Windows.Forms.TabPage
        Me.TextBox_output = New System.Windows.Forms.TextBox
        Me.textBox_execinterval = New System.Windows.Forms.TextBox
        Me.textBox_idlethreshold = New System.Windows.Forms.TextBox
        Me.textBox_simulconn = New System.Windows.Forms.TextBox
        Me.textBox_maxsize = New System.Windows.Forms.TextBox
        Me.textBox_minsize = New System.Windows.Forms.TextBox
        Me.textBox_account = New System.Windows.Forms.TextBox
        Me.textBox_hostname = New System.Windows.Forms.TextBox
        Me.textBox_password = New System.Windows.Forms.TextBox
        Me.label9 = New System.Windows.Forms.Label
        Me.label8 = New System.Windows.Forms.Label
        Me.label7 = New System.Windows.Forms.Label
        Me.label6 = New System.Windows.Forms.Label
        Me.label5 = New System.Windows.Forms.Label
        Me.label4 = New System.Windows.Forms.Label
        Me.label3 = New System.Windows.Forms.Label
        Me.label2 = New System.Windows.Forms.Label
        Me.label1 = New System.Windows.Forms.Label
        Me.textBox_user = New System.Windows.Forms.TextBox
        Me.groupBox1 = New System.Windows.Forms.GroupBox
        Me.radioButton2 = New System.Windows.Forms.RadioButton
        Me.radioButton1 = New System.Windows.Forms.RadioButton
        Me.Panel1.SuspendLayout()
        Me.Panel2.SuspendLayout()
        Me.TabControl1.SuspendLayout()
        Me.TabPage1.SuspendLayout()
        Me.groupBox1.SuspendLayout()
        Me.SuspendLayout()
        '
        'StatusBar1
        '
        Me.StatusBar1.Location = New System.Drawing.Point(0, 463)
        Me.StatusBar1.Name = "StatusBar1"
        Me.StatusBar1.Size = New System.Drawing.Size(704, 22)
        Me.StatusBar1.TabIndex = 0
        '
        'ToolBar1
        '
        Me.ToolBar1.Buttons.AddRange(New System.Windows.Forms.ToolBarButton() {Me.ToolBarButton1, Me.ToolBarButton2})
        Me.ToolBar1.DropDownArrows = True
        Me.ToolBar1.ImageList = Me.ImageList1
        Me.ToolBar1.Location = New System.Drawing.Point(0, 0)
        Me.ToolBar1.Name = "ToolBar1"
        Me.ToolBar1.ShowToolTips = True
        Me.ToolBar1.Size = New System.Drawing.Size(704, 43)
        Me.ToolBar1.TabIndex = 1
        '
        'MainMenu1
        '
        Me.MainMenu1.MenuItems.AddRange(New System.Windows.Forms.MenuItem() {Me.MenuItem1, Me.MenuItem2, Me.MenuItem3})
        '
        'MenuItem1
        '
        Me.MenuItem1.Index = 0
        Me.MenuItem1.MenuItems.AddRange(New System.Windows.Forms.MenuItem() {Me.MenuItem5})
        Me.MenuItem1.Text = "File"
        '
        'MenuItem2
        '
        Me.MenuItem2.Index = 1
        Me.MenuItem2.MenuItems.AddRange(New System.Windows.Forms.MenuItem() {Me.MenuItem4})
        Me.MenuItem2.Text = "Pooling"
        '
        'MenuItem3
        '
        Me.MenuItem3.Index = 2
        Me.MenuItem3.Text = "Help"
        '
        'MenuItem4
        '
        Me.MenuItem4.Index = 0
        Me.MenuItem4.Text = "Start"
        '
        'MenuItem5
        '
        Me.MenuItem5.Index = 0
        Me.MenuItem5.Text = "Exit"
        '
        'ToolBarButton1
        '
        Me.ToolBarButton1.ImageIndex = 0
        Me.ToolBarButton1.Text = "Start"
        '
        'ToolBarButton2
        '
        Me.ToolBarButton2.ImageIndex = 1
        Me.ToolBarButton2.Text = "Clear"
        '
        'ImageList1
        '
        Me.ImageList1.ImageSize = New System.Drawing.Size(16, 16)
        Me.ImageList1.ImageStream = CType(resources.GetObject("ImageList1.ImageStream"), System.Windows.Forms.ImageListStreamer)
        Me.ImageList1.TransparentColor = System.Drawing.Color.Transparent
        '
        'Panel1
        '
        Me.Panel1.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.Panel1.Controls.Add(Me.groupBox1)
        Me.Panel1.Controls.Add(Me.textBox_execinterval)
        Me.Panel1.Controls.Add(Me.textBox_idlethreshold)
        Me.Panel1.Controls.Add(Me.textBox_simulconn)
        Me.Panel1.Controls.Add(Me.textBox_maxsize)
        Me.Panel1.Controls.Add(Me.textBox_minsize)
        Me.Panel1.Controls.Add(Me.textBox_account)
        Me.Panel1.Controls.Add(Me.textBox_hostname)
        Me.Panel1.Controls.Add(Me.textBox_password)
        Me.Panel1.Controls.Add(Me.label9)
        Me.Panel1.Controls.Add(Me.label8)
        Me.Panel1.Controls.Add(Me.label7)
        Me.Panel1.Controls.Add(Me.label6)
        Me.Panel1.Controls.Add(Me.label5)
        Me.Panel1.Controls.Add(Me.label4)
        Me.Panel1.Controls.Add(Me.label3)
        Me.Panel1.Controls.Add(Me.label2)
        Me.Panel1.Controls.Add(Me.label1)
        Me.Panel1.Controls.Add(Me.textBox_user)
        Me.Panel1.Dock = System.Windows.Forms.DockStyle.Left
        Me.Panel1.Location = New System.Drawing.Point(0, 43)
        Me.Panel1.Name = "Panel1"
        Me.Panel1.Size = New System.Drawing.Size(296, 420)
        Me.Panel1.TabIndex = 2
        '
        'Splitter1
        '
        Me.Splitter1.BackColor = System.Drawing.SystemColors.HotTrack
        Me.Splitter1.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D
        Me.Splitter1.Location = New System.Drawing.Point(296, 43)
        Me.Splitter1.Name = "Splitter1"
        Me.Splitter1.Size = New System.Drawing.Size(3, 420)
        Me.Splitter1.TabIndex = 3
        Me.Splitter1.TabStop = False
        '
        'Panel2
        '
        Me.Panel2.Controls.Add(Me.TabControl1)
        Me.Panel2.Dock = System.Windows.Forms.DockStyle.Fill
        Me.Panel2.Location = New System.Drawing.Point(299, 43)
        Me.Panel2.Name = "Panel2"
        Me.Panel2.Size = New System.Drawing.Size(405, 420)
        Me.Panel2.TabIndex = 4
        '
        'TabControl1
        '
        Me.TabControl1.Controls.Add(Me.TabPage1)
        Me.TabControl1.Dock = System.Windows.Forms.DockStyle.Fill
        Me.TabControl1.Location = New System.Drawing.Point(0, 0)
        Me.TabControl1.Name = "TabControl1"
        Me.TabControl1.SelectedIndex = 0
        Me.TabControl1.Size = New System.Drawing.Size(405, 420)
        Me.TabControl1.TabIndex = 0
        '
        'TabPage1
        '
        Me.TabPage1.Controls.Add(Me.TextBox_output)
        Me.TabPage1.Location = New System.Drawing.Point(4, 23)
        Me.TabPage1.Name = "TabPage1"
        Me.TabPage1.Size = New System.Drawing.Size(397, 393)
        Me.TabPage1.TabIndex = 0
        Me.TabPage1.Text = "Output\Error"
        '
        'TextBox_output
        '
        Me.TextBox_output.Dock = System.Windows.Forms.DockStyle.Fill
        Me.TextBox_output.Location = New System.Drawing.Point(0, 0)
        Me.TextBox_output.Multiline = True
        Me.TextBox_output.Name = "TextBox_output"
        Me.TextBox_output.ScrollBars = System.Windows.Forms.ScrollBars.Both
        Me.TextBox_output.Size = New System.Drawing.Size(397, 393)
        Me.TextBox_output.TabIndex = 0
        Me.TextBox_output.Text = ""
        '
        'textBox_execinterval
        '
        Me.textBox_execinterval.Anchor = CType(((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Left) _
                    Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.textBox_execinterval.Location = New System.Drawing.Point(160, 264)
        Me.textBox_execinterval.Name = "textBox_execinterval"
        Me.textBox_execinterval.Size = New System.Drawing.Size(120, 20)
        Me.textBox_execinterval.TabIndex = 35
        Me.textBox_execinterval.Text = "300000"
        '
        'textBox_idlethreshold
        '
        Me.textBox_idlethreshold.Anchor = CType(((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Left) _
                    Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.textBox_idlethreshold.Location = New System.Drawing.Point(160, 233)
        Me.textBox_idlethreshold.Name = "textBox_idlethreshold"
        Me.textBox_idlethreshold.Size = New System.Drawing.Size(120, 20)
        Me.textBox_idlethreshold.TabIndex = 34
        Me.textBox_idlethreshold.Text = "300000"
        '
        'textBox_simulconn
        '
        Me.textBox_simulconn.Anchor = CType(((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Left) _
                    Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.textBox_simulconn.Location = New System.Drawing.Point(160, 202)
        Me.textBox_simulconn.Name = "textBox_simulconn"
        Me.textBox_simulconn.Size = New System.Drawing.Size(120, 20)
        Me.textBox_simulconn.TabIndex = 33
        Me.textBox_simulconn.Text = "5"
        '
        'textBox_maxsize
        '
        Me.textBox_maxsize.Anchor = CType(((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Left) _
                    Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.textBox_maxsize.Location = New System.Drawing.Point(160, 171)
        Me.textBox_maxsize.Name = "textBox_maxsize"
        Me.textBox_maxsize.Size = New System.Drawing.Size(120, 20)
        Me.textBox_maxsize.TabIndex = 32
        Me.textBox_maxsize.Text = "10"
        '
        'textBox_minsize
        '
        Me.textBox_minsize.Anchor = CType(((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Left) _
                    Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.textBox_minsize.Location = New System.Drawing.Point(160, 140)
        Me.textBox_minsize.Name = "textBox_minsize"
        Me.textBox_minsize.Size = New System.Drawing.Size(120, 20)
        Me.textBox_minsize.TabIndex = 31
        Me.textBox_minsize.Text = "2"
        '
        'textBox_account
        '
        Me.textBox_account.Anchor = CType(((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Left) _
                    Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.textBox_account.Location = New System.Drawing.Point(160, 109)
        Me.textBox_account.Name = "textBox_account"
        Me.textBox_account.Size = New System.Drawing.Size(120, 20)
        Me.textBox_account.TabIndex = 30
        Me.textBox_account.Text = "HS.SALES"
        '
        'textBox_hostname
        '
        Me.textBox_hostname.Anchor = CType(((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Left) _
                    Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.textBox_hostname.Location = New System.Drawing.Point(160, 78)
        Me.textBox_hostname.Name = "textBox_hostname"
        Me.textBox_hostname.Size = New System.Drawing.Size(120, 20)
        Me.textBox_hostname.TabIndex = 29
        Me.textBox_hostname.Text = "localhost"
        '
        'textBox_password
        '
        Me.textBox_password.Anchor = CType(((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Left) _
                    Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.textBox_password.Location = New System.Drawing.Point(160, 47)
        Me.textBox_password.Name = "textBox_password"
        Me.textBox_password.PasswordChar = Microsoft.VisualBasic.ChrW(42)
        Me.textBox_password.Size = New System.Drawing.Size(120, 20)
        Me.textBox_password.TabIndex = 28
        Me.textBox_password.Text = "ani2ka"
        '
        'label9
        '
        Me.label9.Location = New System.Drawing.Point(16, 264)
        Me.label9.Name = "label9"
        Me.label9.Size = New System.Drawing.Size(136, 32)
        Me.label9.TabIndex = 27
        Me.label9.Text = "IdleRemoveExecInterval:"
        '
        'label8
        '
        Me.label8.Location = New System.Drawing.Point(16, 233)
        Me.label8.Name = "label8"
        Me.label8.Size = New System.Drawing.Size(136, 32)
        Me.label8.TabIndex = 26
        Me.label8.Text = "IdleRemoveThreshold:"
        '
        'label7
        '
        Me.label7.Location = New System.Drawing.Point(16, 202)
        Me.label7.Name = "label7"
        Me.label7.Size = New System.Drawing.Size(136, 32)
        Me.label7.TabIndex = 25
        Me.label7.Text = "Simultaneous Connection:"
        '
        'label6
        '
        Me.label6.Location = New System.Drawing.Point(16, 171)
        Me.label6.Name = "label6"
        Me.label6.Size = New System.Drawing.Size(136, 32)
        Me.label6.TabIndex = 24
        Me.label6.Text = "Max Pool Size:"
        '
        'label5
        '
        Me.label5.Location = New System.Drawing.Point(16, 140)
        Me.label5.Name = "label5"
        Me.label5.Size = New System.Drawing.Size(136, 32)
        Me.label5.TabIndex = 23
        Me.label5.Text = "Min Pool size:"
        '
        'label4
        '
        Me.label4.Location = New System.Drawing.Point(16, 109)
        Me.label4.Name = "label4"
        Me.label4.Size = New System.Drawing.Size(136, 32)
        Me.label4.TabIndex = 22
        Me.label4.Text = "Account:"
        '
        'label3
        '
        Me.label3.Location = New System.Drawing.Point(16, 78)
        Me.label3.Name = "label3"
        Me.label3.Size = New System.Drawing.Size(136, 32)
        Me.label3.TabIndex = 21
        Me.label3.Text = "HostName:"
        '
        'label2
        '
        Me.label2.Location = New System.Drawing.Point(16, 47)
        Me.label2.Name = "label2"
        Me.label2.Size = New System.Drawing.Size(136, 32)
        Me.label2.TabIndex = 20
        Me.label2.Text = "Password:"
        '
        'label1
        '
        Me.label1.Location = New System.Drawing.Point(16, 16)
        Me.label1.Name = "label1"
        Me.label1.Size = New System.Drawing.Size(136, 32)
        Me.label1.TabIndex = 19
        Me.label1.Text = "User:"
        '
        'textBox_user
        '
        Me.textBox_user.Anchor = CType(((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Left) _
                    Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.textBox_user.Location = New System.Drawing.Point(160, 16)
        Me.textBox_user.Name = "textBox_user"
        Me.textBox_user.Size = New System.Drawing.Size(120, 20)
        Me.textBox_user.TabIndex = 18
        Me.textBox_user.Text = "rajank"
        '
        'groupBox1
        '
        Me.groupBox1.Controls.Add(Me.radioButton2)
        Me.groupBox1.Controls.Add(Me.radioButton1)
        Me.groupBox1.Location = New System.Drawing.Point(8, 296)
        Me.groupBox1.Name = "groupBox1"
        Me.groupBox1.Size = New System.Drawing.Size(112, 64)
        Me.groupBox1.TabIndex = 36
        Me.groupBox1.TabStop = False
        Me.groupBox1.Text = "U2 Database"
        '
        'radioButton2
        '
        Me.radioButton2.Location = New System.Drawing.Point(16, 32)
        Me.radioButton2.Name = "radioButton2"
        Me.radioButton2.Size = New System.Drawing.Size(72, 24)
        Me.radioButton2.TabIndex = 1
        Me.radioButton2.Text = "UniData"
        '
        'radioButton1
        '
        Me.radioButton1.Checked = True
        Me.radioButton1.Location = New System.Drawing.Point(16, 16)
        Me.radioButton1.Name = "radioButton1"
        Me.radioButton1.Size = New System.Drawing.Size(80, 24)
        Me.radioButton1.TabIndex = 0
        Me.radioButton1.TabStop = True
        Me.radioButton1.Text = "UniVerse"
        '
        'Form1
        '
        Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
        Me.ClientSize = New System.Drawing.Size(704, 485)
        Me.Controls.Add(Me.Panel2)
        Me.Controls.Add(Me.Splitter1)
        Me.Controls.Add(Me.Panel1)
        Me.Controls.Add(Me.ToolBar1)
        Me.Controls.Add(Me.StatusBar1)
        Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
        Me.Menu = Me.MainMenu1
        Me.Name = "Form1"
        Me.Text = "ConnectionPooling"
        Me.Panel1.ResumeLayout(False)
        Me.Panel2.ResumeLayout(False)
        Me.TabControl1.ResumeLayout(False)
        Me.TabPage1.ResumeLayout(False)
        Me.groupBox1.ResumeLayout(False)
        Me.ResumeLayout(False)

    End Sub

#End Region

    Private Sub ToolBar1_ButtonClick(ByVal sender As System.Object, ByVal e As System.Windows.Forms.ToolBarButtonClickEventArgs) Handles ToolBar1.ButtonClick
        Cursor.Current = Cursors.WaitCursor
        Dim sButton As String = e.Button.Text
        If sButton.Equals("Start") Then

            SrartFunction()
        ElseIf sButton.Equals("Clear") Then
            TextBox_output.Clear()

        End If
        ' Reset the cursor to the default for all controls.
        Cursor.Current = Cursors.Default

    End Sub
    Private Sub CallConnectionPooling()

        Dim lSimultaneousConnection As Integer = m_SimultaneousConnection
        ' create threads
        Dim lStartTime As DateTime = DateTime.Now
        Dim lThreads(lSimultaneousConnection - 1) As Thread
        Dim i As Integer

        For i = 0 To (lSimultaneousConnection - 1)
            Dim myThreadDelegate As New ThreadStart(AddressOf ThreadProc)
            Dim t As New Thread(myThreadDelegate)
            lThreads(i) = t

        Next i

        ' start threads
        For i = 0 To (lSimultaneousConnection - 1)
            Dim s2 As String = i + 1
            lThreads(i).Name = "ThreadProc" & s2
            lThreads(i).Start()
        Next i

        ' join threads
        For i = 0 To (lSimultaneousConnection - 1)
            lThreads(i).Join()
        Next i
        Dim ldiff As TimeSpan = DateTime.Now.Subtract(lStartTime)
        Dim s As String = "Total Time : " & ldiff.TotalMilliseconds & " Milliseconds"
        TextBox_output.AppendText(s)
        TextBox_output.AppendText(Environment.NewLine)

    End Sub

    Private Sub Form1_Closed(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyBase.Closed
        CloseAllSession()
    End Sub

    Private Sub CloseAllSession()
        UniObjects.CloseAllSessions()

    End Sub



    Private Sub MenuItem5_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles MenuItem5.Click
        ' Exit Button Clicked
        CloseAllSession()
        Close()
    End Sub

    Private Sub ThreadProc()
        Dim us1 As UniSession = Nothing

        Try
            'Connection Pooling <=>setting programmatically
            '====================================================
            UniObjects.UOPooling = m_IsPooling
            UniObjects.MinPoolSize = m_MinPoolSize
            UniObjects.MaxPoolSize = m_MaxPoolSize
            UniObjects.IdleRemoveThreshold = m_IdleRemoveThreshold
            UniObjects.IdleRemoveExecInterval = m_IdleRemoveExecInterval
            us1 = UniObjects.OpenSession(m_Server, m_User, m_Password, m_Account, m_DatabaseType)
            Dim cmd As UniCommand = us1.CreateUniCommand()
            cmd.Command = "LIST VOC SAMPLE 10"
            cmd.Execute()
            Dim response_str As String = cmd.Response
            Dim s As String = "Started  " + Thread.CurrentThread.Name & Environment.NewLine
            TextBox_output.AppendText(s)

            'Connection Pooling <=>using App.config file or ConnectionPooling.exe.config file
            '====================================================================================

            'reading from config file. Please uncomment <UO.NET> section in App.config file
            ' Please comment all the above code , and uncomment the below code.
            'us = UniObjects.OpenSession(m_Server,m_User,m_Password,m_Account,m_DatabaseType);
            'Dim cmd As UniCommand = us1.CreateUniCommand()
            'cmd.Command = "LIST VOC SAMPLE 10"
            'cmd.Execute()
            'Dim response_str As String = cmd.Response
            'Dim s As String = "Started  " + Thread.CurrentThread.Name & Environment.NewLine
            'TextBox_output.AppendText(s)
        Catch e As Exception
            If Not (us1 Is Nothing) Then
                If (us1.IsActive) Then
                    UniObjects.CloseSession(us1)
                    us1 = Nothing
                End If
            End If
            TextBox_output.AppendText(e.Message)
        Finally
            If Not (us1 Is Nothing) Then
                If (us1.IsActive) Then
                    UniObjects.CloseSession(us1)
                    Dim s As String = "Closing  " + Thread.CurrentThread.Name + Environment.NewLine
                    TextBox_output.AppendText(s)
                End If

            End If

        End Try

    End Sub
    Private Sub SrartFunction()
        TextBox_output.AppendText("Program started..." & Environment.NewLine)
        m_User = textBox_user.Text
        TextBox_output.AppendText(String.Format("User:{0}", m_User))
        TextBox_output.AppendText(Environment.NewLine)

        m_Password = textBox_password.Text
        TextBox_output.AppendText(String.Format("Password:{0}", m_Password))
        TextBox_output.AppendText(Environment.NewLine)

        m_Server = textBox_hostname.Text
        TextBox_output.AppendText(String.Format("HostName:{0}", m_Server))
        TextBox_output.AppendText(Environment.NewLine)

        m_Account = textBox_account.Text
        TextBox_output.AppendText(String.Format("Account:{0}", m_Account))
        TextBox_output.AppendText(Environment.NewLine)

        m_IsPooling = True
        TextBox_output.AppendText(String.Format("IsPooling:{0}", m_IsPooling))
        TextBox_output.AppendText(Environment.NewLine)

        m_MinPoolSize = Convert.ToInt32(textBox_minsize.Text)
        TextBox_output.AppendText(String.Format("MinPoolSize:{0}", m_MinPoolSize))
        TextBox_output.AppendText(Environment.NewLine)

        m_MaxPoolSize = Convert.ToInt32(textBox_maxsize.Text)
        TextBox_output.AppendText(String.Format("MaxPoolSize:{0}", m_MaxPoolSize))
        TextBox_output.AppendText(Environment.NewLine)

        m_SimultaneousConnection = Convert.ToInt32(textBox_simulconn.Text)
        TextBox_output.AppendText(String.Format("SimultaneousConnection:{0}", m_SimultaneousConnection))
        TextBox_output.AppendText(Environment.NewLine)


        m_IdleRemoveThreshold = Convert.ToInt32(textBox_idlethreshold.Text)
        TextBox_output.AppendText(String.Format("IdleRemoveThreshold:{0}", m_IdleRemoveThreshold))
        TextBox_output.AppendText(Environment.NewLine)


        m_IdleRemoveExecInterval = Convert.ToInt32(textBox_execinterval.Text)
        TextBox_output.AppendText(String.Format("IdleRemoveExecInterval:{0}", m_IdleRemoveExecInterval))
        TextBox_output.AppendText(Environment.NewLine)
        If (radioButton1.Checked) Then
            m_DatabaseType = "uvcs"
        Else
            m_DatabaseType = "udcs"
        End If

        TextBox_output.AppendText(String.Format("DatabaseType:{0}", m_DatabaseType))
        TextBox_output.AppendText(Environment.NewLine)
        CallConnectionPooling()
        TextBox_output.AppendText("Program finished..." & Environment.NewLine)
    End Sub

    Private Sub MenuItem4_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles MenuItem4.Click
        SrartFunction()
    End Sub
End Class
