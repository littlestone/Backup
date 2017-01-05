#define DOTNET_FW_20
using System;
using System.Drawing;
using System.Collections;
using System.ComponentModel;
using System.Windows.Forms;
using System.Data;
using IBMU2.UODOTNET;
using System.Configuration;
using System.Diagnostics;
using System.Threading;


namespace ConnectionPooling
{
	/// <summary>
	/// Summary description for Form1.
	/// </summary>
	public class Form1 : System.Windows.Forms.Form
	{
		private System.Windows.Forms.MainMenu mainMenu1;
		private System.Windows.Forms.MenuItem menuItem1;
		private System.Windows.Forms.MenuItem menuItem2;
		private System.Windows.Forms.MenuItem menuItem3;
		private System.Windows.Forms.MenuItem menuItem4;
		private System.Windows.Forms.MenuItem menuItem5;
		private System.Windows.Forms.ToolBar toolBar1;
		private System.Windows.Forms.ToolBarButton toolBarButton1;
		private System.Windows.Forms.ToolBarButton toolBarButton2;
		private System.Windows.Forms.StatusBar statusBar1;
		private System.Windows.Forms.Panel panel1;
		private System.Windows.Forms.Splitter splitter1;
		private System.Windows.Forms.Panel panel2;
		private System.Windows.Forms.TabControl tabControl1;
		private System.Windows.Forms.TabPage tabPage1;
		private System.Windows.Forms.Label label1;
		private System.Windows.Forms.Label label2;
		private System.Windows.Forms.Label label3;
		private System.Windows.Forms.Label label4;
		private System.Windows.Forms.Label label5;
		private System.Windows.Forms.Label label6;
		private System.Windows.Forms.Label label7;
		private System.Windows.Forms.Label label8;
		private System.Windows.Forms.Label label9;
		private System.Windows.Forms.TextBox textBox_user;
		private System.Windows.Forms.TextBox textBox_output;
		private System.Windows.Forms.TextBox textBox_password;
		private System.Windows.Forms.TextBox textBox_hostname;
		private System.Windows.Forms.TextBox textBox_account;
		private System.Windows.Forms.TextBox textBox_minsize;
		private System.Windows.Forms.TextBox textBox_maxsize;
		private System.Windows.Forms.TextBox textBox_simulconn;
		private System.Windows.Forms.TextBox textBox_idlethreshold;
		private System.Windows.Forms.TextBox textBox_execinterval;
		private System.Windows.Forms.GroupBox groupBox1;
		private System.Windows.Forms.RadioButton radioButton2;
		private System.Windows.Forms.RadioButton radioButton1;
		private System.Windows.Forms.ImageList imageList1;
		private System.ComponentModel.IContainer components;
		private bool	m_IsPooling=false;
		private int		m_IdleRemoveThreshold;
		private int		m_IdleRemoveExecInterval;
		private int		m_MinPoolSize;
		private int		m_MaxPoolSize;
		private int		m_SimultaneousConnection;
		private string m_Server;
		private string m_User;
		private string m_Password;
		private string m_Account;
		private string m_DatabaseType="uvcs";
		

		public Form1()
		{
			//
			// Required for Windows Form Designer support
			//
			InitializeComponent();

			//
			// TODO: Add any constructor code after InitializeComponent call
			//
		}

		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		protected override void Dispose( bool disposing )
		{
			if( disposing )
			{
				if (components != null) 
				{
					components.Dispose();
				}
			}
			base.Dispose( disposing );
		}

		#region Windows Form Designer generated code
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			this.components = new System.ComponentModel.Container();
			System.Resources.ResourceManager resources = new System.Resources.ResourceManager(typeof(Form1));
			this.mainMenu1 = new System.Windows.Forms.MainMenu();
			this.menuItem1 = new System.Windows.Forms.MenuItem();
			this.menuItem2 = new System.Windows.Forms.MenuItem();
			this.menuItem3 = new System.Windows.Forms.MenuItem();
			this.menuItem4 = new System.Windows.Forms.MenuItem();
			this.menuItem5 = new System.Windows.Forms.MenuItem();
			this.toolBar1 = new System.Windows.Forms.ToolBar();
			this.toolBarButton1 = new System.Windows.Forms.ToolBarButton();
			this.toolBarButton2 = new System.Windows.Forms.ToolBarButton();
			this.imageList1 = new System.Windows.Forms.ImageList(this.components);
			this.statusBar1 = new System.Windows.Forms.StatusBar();
			this.panel1 = new System.Windows.Forms.Panel();
			this.groupBox1 = new System.Windows.Forms.GroupBox();
			this.radioButton2 = new System.Windows.Forms.RadioButton();
			this.radioButton1 = new System.Windows.Forms.RadioButton();
			this.textBox_execinterval = new System.Windows.Forms.TextBox();
			this.textBox_idlethreshold = new System.Windows.Forms.TextBox();
			this.textBox_simulconn = new System.Windows.Forms.TextBox();
			this.textBox_maxsize = new System.Windows.Forms.TextBox();
			this.textBox_minsize = new System.Windows.Forms.TextBox();
			this.textBox_account = new System.Windows.Forms.TextBox();
			this.textBox_hostname = new System.Windows.Forms.TextBox();
			this.textBox_password = new System.Windows.Forms.TextBox();
			this.label9 = new System.Windows.Forms.Label();
			this.label8 = new System.Windows.Forms.Label();
			this.label7 = new System.Windows.Forms.Label();
			this.label6 = new System.Windows.Forms.Label();
			this.label5 = new System.Windows.Forms.Label();
			this.label4 = new System.Windows.Forms.Label();
			this.label3 = new System.Windows.Forms.Label();
			this.label2 = new System.Windows.Forms.Label();
			this.label1 = new System.Windows.Forms.Label();
			this.textBox_user = new System.Windows.Forms.TextBox();
			this.splitter1 = new System.Windows.Forms.Splitter();
			this.panel2 = new System.Windows.Forms.Panel();
			this.tabControl1 = new System.Windows.Forms.TabControl();
			this.tabPage1 = new System.Windows.Forms.TabPage();
			this.textBox_output = new System.Windows.Forms.TextBox();
			this.panel1.SuspendLayout();
			this.groupBox1.SuspendLayout();
			this.panel2.SuspendLayout();
			this.tabControl1.SuspendLayout();
			this.tabPage1.SuspendLayout();
			this.SuspendLayout();
			// 
			// mainMenu1
			// 
			this.mainMenu1.MenuItems.AddRange(new System.Windows.Forms.MenuItem[] {
																					  this.menuItem1,
																					  this.menuItem3,
																					  this.menuItem5});
			// 
			// menuItem1
			// 
			this.menuItem1.Index = 0;
			this.menuItem1.MenuItems.AddRange(new System.Windows.Forms.MenuItem[] {
																					  this.menuItem2});
			this.menuItem1.Text = "File";
			// 
			// menuItem2
			// 
			this.menuItem2.Index = 0;
			this.menuItem2.Text = "Exit";
			this.menuItem2.Click += new System.EventHandler(this.menuItem2_Click);
			// 
			// menuItem3
			// 
			this.menuItem3.Index = 1;
			this.menuItem3.MenuItems.AddRange(new System.Windows.Forms.MenuItem[] {
																					  this.menuItem4});
			this.menuItem3.Text = "Pooling";
			// 
			// menuItem4
			// 
			this.menuItem4.Index = 0;
			this.menuItem4.Text = "Start";
			// 
			// menuItem5
			// 
			this.menuItem5.Index = 2;
			this.menuItem5.Text = "Help";
			// 
			// toolBar1
			// 
			this.toolBar1.Buttons.AddRange(new System.Windows.Forms.ToolBarButton[] {
																						this.toolBarButton1,
																						this.toolBarButton2});
			this.toolBar1.DropDownArrows = true;
			this.toolBar1.ImageList = this.imageList1;
			this.toolBar1.Location = new System.Drawing.Point(0, 0);
			this.toolBar1.Name = "toolBar1";
			this.toolBar1.ShowToolTips = true;
			this.toolBar1.Size = new System.Drawing.Size(760, 43);
			this.toolBar1.TabIndex = 0;
			this.toolBar1.ButtonClick += new System.Windows.Forms.ToolBarButtonClickEventHandler(this.toolBar1_ButtonClick);
			// 
			// toolBarButton1
			// 
			this.toolBarButton1.ImageIndex = 0;
			this.toolBarButton1.Text = "Start";
			// 
			// toolBarButton2
			// 
			this.toolBarButton2.ImageIndex = 1;
			this.toolBarButton2.Text = "Clear";
			// 
			// imageList1
			// 
			this.imageList1.ImageSize = new System.Drawing.Size(16, 16);
			this.imageList1.ImageStream = ((System.Windows.Forms.ImageListStreamer)(resources.GetObject("imageList1.ImageStream")));
			this.imageList1.TransparentColor = System.Drawing.Color.Transparent;
			// 
			// statusBar1
			// 
			this.statusBar1.Location = new System.Drawing.Point(0, 447);
			this.statusBar1.Name = "statusBar1";
			this.statusBar1.Size = new System.Drawing.Size(760, 22);
			this.statusBar1.TabIndex = 1;
			// 
			// panel1
			// 
			this.panel1.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
			this.panel1.Controls.Add(this.groupBox1);
			this.panel1.Controls.Add(this.textBox_execinterval);
			this.panel1.Controls.Add(this.textBox_idlethreshold);
			this.panel1.Controls.Add(this.textBox_simulconn);
			this.panel1.Controls.Add(this.textBox_maxsize);
			this.panel1.Controls.Add(this.textBox_minsize);
			this.panel1.Controls.Add(this.textBox_account);
			this.panel1.Controls.Add(this.textBox_hostname);
			this.panel1.Controls.Add(this.textBox_password);
			this.panel1.Controls.Add(this.label9);
			this.panel1.Controls.Add(this.label8);
			this.panel1.Controls.Add(this.label7);
			this.panel1.Controls.Add(this.label6);
			this.panel1.Controls.Add(this.label5);
			this.panel1.Controls.Add(this.label4);
			this.panel1.Controls.Add(this.label3);
			this.panel1.Controls.Add(this.label2);
			this.panel1.Controls.Add(this.label1);
			this.panel1.Controls.Add(this.textBox_user);
			this.panel1.Dock = System.Windows.Forms.DockStyle.Left;
			this.panel1.Location = new System.Drawing.Point(0, 43);
			this.panel1.Name = "panel1";
			this.panel1.Size = new System.Drawing.Size(352, 404);
			this.panel1.TabIndex = 2;
			this.panel1.Paint += new System.Windows.Forms.PaintEventHandler(this.panel1_Paint);
			// 
			// groupBox1
			// 
			this.groupBox1.Controls.Add(this.radioButton2);
			this.groupBox1.Controls.Add(this.radioButton1);
			this.groupBox1.Location = new System.Drawing.Point(8, 304);
			this.groupBox1.Name = "groupBox1";
			this.groupBox1.Size = new System.Drawing.Size(112, 64);
			this.groupBox1.TabIndex = 18;
			this.groupBox1.TabStop = false;
			this.groupBox1.Text = "U2 Database";
			// 
			// radioButton2
			// 
			this.radioButton2.Location = new System.Drawing.Point(16, 32);
			this.radioButton2.Name = "radioButton2";
			this.radioButton2.Size = new System.Drawing.Size(72, 24);
			this.radioButton2.TabIndex = 1;
			this.radioButton2.Text = "UniData";
			// 
			// radioButton1
			// 
			this.radioButton1.Checked = true;
			this.radioButton1.Location = new System.Drawing.Point(16, 16);
			this.radioButton1.Name = "radioButton1";
			this.radioButton1.Size = new System.Drawing.Size(80, 24);
			this.radioButton1.TabIndex = 0;
			this.radioButton1.TabStop = true;
			this.radioButton1.Text = "UniVerse";
			// 
			// textBox_execinterval
			// 
			this.textBox_execinterval.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
				| System.Windows.Forms.AnchorStyles.Right)));
			this.textBox_execinterval.Location = new System.Drawing.Point(152, 272);
			this.textBox_execinterval.Name = "textBox_execinterval";
			this.textBox_execinterval.Size = new System.Drawing.Size(176, 20);
			this.textBox_execinterval.TabIndex = 17;
			this.textBox_execinterval.Text = "300000";
			// 
			// textBox_idlethreshold
			// 
			this.textBox_idlethreshold.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
				| System.Windows.Forms.AnchorStyles.Right)));
			this.textBox_idlethreshold.Location = new System.Drawing.Point(152, 240);
			this.textBox_idlethreshold.Name = "textBox_idlethreshold";
			this.textBox_idlethreshold.Size = new System.Drawing.Size(176, 20);
			this.textBox_idlethreshold.TabIndex = 16;
			this.textBox_idlethreshold.Text = "300000";
			// 
			// textBox_simulconn
			// 
			this.textBox_simulconn.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
				| System.Windows.Forms.AnchorStyles.Right)));
			this.textBox_simulconn.Location = new System.Drawing.Point(152, 208);
			this.textBox_simulconn.Name = "textBox_simulconn";
			this.textBox_simulconn.Size = new System.Drawing.Size(176, 20);
			this.textBox_simulconn.TabIndex = 15;
			this.textBox_simulconn.Text = "5";
			// 
			// textBox_maxsize
			// 
			this.textBox_maxsize.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
				| System.Windows.Forms.AnchorStyles.Right)));
			this.textBox_maxsize.Location = new System.Drawing.Point(152, 176);
			this.textBox_maxsize.Name = "textBox_maxsize";
			this.textBox_maxsize.Size = new System.Drawing.Size(176, 20);
			this.textBox_maxsize.TabIndex = 14;
			this.textBox_maxsize.Text = "10";
			// 
			// textBox_minsize
			// 
			this.textBox_minsize.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
				| System.Windows.Forms.AnchorStyles.Right)));
			this.textBox_minsize.Location = new System.Drawing.Point(152, 144);
			this.textBox_minsize.Name = "textBox_minsize";
			this.textBox_minsize.Size = new System.Drawing.Size(176, 20);
			this.textBox_minsize.TabIndex = 13;
			this.textBox_minsize.Text = "2";
			// 
			// textBox_account
			// 
			this.textBox_account.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
				| System.Windows.Forms.AnchorStyles.Right)));
			this.textBox_account.Location = new System.Drawing.Point(152, 112);
			this.textBox_account.Name = "textBox_account";
			this.textBox_account.Size = new System.Drawing.Size(176, 20);
			this.textBox_account.TabIndex = 12;
			this.textBox_account.Text = "HS.SALES";
			// 
			// textBox_hostname
			// 
			this.textBox_hostname.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
				| System.Windows.Forms.AnchorStyles.Right)));
			this.textBox_hostname.Location = new System.Drawing.Point(152, 80);
			this.textBox_hostname.Name = "textBox_hostname";
			this.textBox_hostname.Size = new System.Drawing.Size(176, 20);
			this.textBox_hostname.TabIndex = 11;
			this.textBox_hostname.Text = "localhost";
			// 
			// textBox_password
			// 
			this.textBox_password.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
				| System.Windows.Forms.AnchorStyles.Right)));
			this.textBox_password.Location = new System.Drawing.Point(152, 48);
			this.textBox_password.Name = "textBox_password";
			this.textBox_password.PasswordChar = '*';
			this.textBox_password.Size = new System.Drawing.Size(176, 20);
			this.textBox_password.TabIndex = 10;
			this.textBox_password.Text = "ani2ka";
			// 
			// label9
			// 
			this.label9.Location = new System.Drawing.Point(8, 272);
			this.label9.Name = "label9";
			this.label9.Size = new System.Drawing.Size(136, 32);
			this.label9.TabIndex = 9;
			this.label9.Text = "IdleRemoveExecInterval:";
			// 
			// label8
			// 
			this.label8.Location = new System.Drawing.Point(8, 240);
			this.label8.Name = "label8";
			this.label8.Size = new System.Drawing.Size(136, 32);
			this.label8.TabIndex = 8;
			this.label8.Text = "IdleRemoveThreshold:";
			this.label8.Click += new System.EventHandler(this.label8_Click);
			// 
			// label7
			// 
			this.label7.Location = new System.Drawing.Point(8, 208);
			this.label7.Name = "label7";
			this.label7.Size = new System.Drawing.Size(136, 32);
			this.label7.TabIndex = 7;
			this.label7.Text = "Simultaneous Connection:";
			// 
			// label6
			// 
			this.label6.Location = new System.Drawing.Point(8, 176);
			this.label6.Name = "label6";
			this.label6.Size = new System.Drawing.Size(136, 32);
			this.label6.TabIndex = 6;
			this.label6.Text = "Max Pool Size:";
			// 
			// label5
			// 
			this.label5.Location = new System.Drawing.Point(8, 144);
			this.label5.Name = "label5";
			this.label5.Size = new System.Drawing.Size(136, 32);
			this.label5.TabIndex = 5;
			this.label5.Text = "Min Pool size:";
			// 
			// label4
			// 
			this.label4.Location = new System.Drawing.Point(8, 112);
			this.label4.Name = "label4";
			this.label4.Size = new System.Drawing.Size(136, 32);
			this.label4.TabIndex = 4;
			this.label4.Text = "Account:";
			// 
			// label3
			// 
			this.label3.Location = new System.Drawing.Point(8, 80);
			this.label3.Name = "label3";
			this.label3.Size = new System.Drawing.Size(136, 32);
			this.label3.TabIndex = 3;
			this.label3.Text = "HostName:";
			// 
			// label2
			// 
			this.label2.Location = new System.Drawing.Point(8, 48);
			this.label2.Name = "label2";
			this.label2.Size = new System.Drawing.Size(136, 32);
			this.label2.TabIndex = 2;
			this.label2.Text = "Password:";
			// 
			// label1
			// 
			this.label1.Location = new System.Drawing.Point(8, 16);
			this.label1.Name = "label1";
			this.label1.Size = new System.Drawing.Size(136, 32);
			this.label1.TabIndex = 1;
			this.label1.Text = "User:";
			// 
			// textBox_user
			// 
			this.textBox_user.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
				| System.Windows.Forms.AnchorStyles.Right)));
			this.textBox_user.Location = new System.Drawing.Point(152, 16);
			this.textBox_user.Name = "textBox_user";
			this.textBox_user.Size = new System.Drawing.Size(176, 20);
			this.textBox_user.TabIndex = 0;
			this.textBox_user.Text = "rajank";
			// 
			// splitter1
			// 
			this.splitter1.BackColor = System.Drawing.SystemColors.HotTrack;
			this.splitter1.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
			this.splitter1.Location = new System.Drawing.Point(352, 43);
			this.splitter1.Name = "splitter1";
			this.splitter1.Size = new System.Drawing.Size(3, 404);
			this.splitter1.TabIndex = 3;
			this.splitter1.TabStop = false;
			// 
			// panel2
			// 
			this.panel2.Controls.Add(this.tabControl1);
			this.panel2.Dock = System.Windows.Forms.DockStyle.Fill;
			this.panel2.Location = new System.Drawing.Point(355, 43);
			this.panel2.Name = "panel2";
			this.panel2.Size = new System.Drawing.Size(405, 404);
			this.panel2.TabIndex = 4;
			// 
			// tabControl1
			// 
			this.tabControl1.Controls.Add(this.tabPage1);
			this.tabControl1.Dock = System.Windows.Forms.DockStyle.Fill;
			this.tabControl1.Location = new System.Drawing.Point(0, 0);
			this.tabControl1.Name = "tabControl1";
			this.tabControl1.SelectedIndex = 0;
			this.tabControl1.Size = new System.Drawing.Size(405, 404);
			this.tabControl1.TabIndex = 0;
			// 
			// tabPage1
			// 
			this.tabPage1.Controls.Add(this.textBox_output);
			this.tabPage1.Location = new System.Drawing.Point(4, 23);
			this.tabPage1.Name = "tabPage1";
			this.tabPage1.Size = new System.Drawing.Size(397, 377);
			this.tabPage1.TabIndex = 0;
			this.tabPage1.Text = "Output\\Error";
			// 
			// textBox_output
			// 
			this.textBox_output.Dock = System.Windows.Forms.DockStyle.Fill;
			this.textBox_output.Location = new System.Drawing.Point(0, 0);
			this.textBox_output.Multiline = true;
			this.textBox_output.Name = "textBox_output";
			this.textBox_output.Size = new System.Drawing.Size(397, 377);
			this.textBox_output.TabIndex = 0;
			this.textBox_output.Text = "";
			// 
			// Form1
			// 
			this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
			this.ClientSize = new System.Drawing.Size(760, 469);
			this.Controls.Add(this.panel2);
			this.Controls.Add(this.splitter1);
			this.Controls.Add(this.panel1);
			this.Controls.Add(this.statusBar1);
			this.Controls.Add(this.toolBar1);
			this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
			this.Menu = this.mainMenu1;
			this.Name = "Form1";
			this.Text = "ConnectionPooling";
			this.Closed += new System.EventHandler(this.Form1_Closed);
			this.panel1.ResumeLayout(false);
			this.groupBox1.ResumeLayout(false);
			this.panel2.ResumeLayout(false);
			this.tabControl1.ResumeLayout(false);
			this.tabPage1.ResumeLayout(false);
			this.ResumeLayout(false);

		}
		#endregion

		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		[STAThread]
		static void Main() 
		{
			Application.Run(new Form1());
		}

		private void label8_Click(object sender, System.EventArgs e)
		{
		
		}

		private void panel1_Paint(object sender, System.Windows.Forms.PaintEventArgs e)
		{
		
		}

		private void toolBar1_ButtonClick(object sender, System.Windows.Forms.ToolBarButtonClickEventArgs e)
		{
			Cursor.Current = Cursors.WaitCursor;
			String sButton = e.Button.Text;
			if(sButton.Equals("Start"))
			{
				this.textBox_output.AppendText("Program started...\n");
				m_User = this.textBox_user.Text;
				this.textBox_output.AppendText(string.Format("User:{0}",m_User));
				this.textBox_output.AppendText("\n");
			
				m_Password =  this.textBox_password.Text;
				this.textBox_output.AppendText(string.Format("Password:{0}",m_Password));
				this.textBox_output.AppendText("\n");
			
				m_Server =this.textBox_hostname.Text;
				this.textBox_output.AppendText(string.Format("HostName:{0}",m_Server));
				this.textBox_output.AppendText("\n");
			
				m_Account =this.textBox_account.Text;
				this.textBox_output.AppendText(string.Format("Account:{0}",m_Account));
				this.textBox_output.AppendText("\n");
			
				m_IsPooling = true;
				this.textBox_output.AppendText(string.Format("IsPooling:{0}",m_IsPooling));
				this.textBox_output.AppendText("\n");
			
				m_MinPoolSize = Convert.ToInt32(this.textBox_minsize.Text);
				this.textBox_output.AppendText(string.Format("MinPoolSize:{0}",m_MinPoolSize));
				this.textBox_output.AppendText("\n");
			
				m_MaxPoolSize = Convert.ToInt32(this.textBox_maxsize.Text);
				this.textBox_output.AppendText(string.Format("MaxPoolSize:{0}",m_MaxPoolSize));
				this.textBox_output.AppendText("\n");
			
				m_SimultaneousConnection = Convert.ToInt32(this.textBox_simulconn.Text);
				this.textBox_output.AppendText(string.Format("SimultaneousConnection:{0}",m_SimultaneousConnection));
				this.textBox_output.AppendText("\n");
			
			
				m_IdleRemoveThreshold = Convert.ToInt32(this.textBox_idlethreshold.Text);
				this.textBox_output.AppendText(string.Format("IdleRemoveThreshold:{0}",m_IdleRemoveThreshold));
				this.textBox_output.AppendText("\n");
			
			
				m_IdleRemoveExecInterval = Convert.ToInt32(this.textBox_execinterval.Text);
				this.textBox_output.AppendText(string.Format("IdleRemoveExecInterval:{0}",m_IdleRemoveExecInterval));
				this.textBox_output.AppendText("\n");
				if(radioButton1.Checked)
				{
					m_DatabaseType = "uvcs";
				}
				else
				{
					m_DatabaseType = "udcs";
				}

				this.textBox_output.AppendText(string.Format("DatabaseType:{0}",m_DatabaseType));
				this.textBox_output.AppendText("\n");
#if (DOTNET_FW_20)
                Control.CheckForIllegalCrossThreadCalls = false;
                
                
#else
                
               
#endif
                CallConnectionPooling();
				
				this.textBox_output.AppendText("Program finished...\n");
			}
			else if(sButton.Equals("Clear"))
			{
				this.textBox_output.Clear();
			}
			// Reset the cursor to the default for all controls.
			Cursor.Current = Cursors.Default;

		
		}

		private void CallConnectionPooling()
		{
			Thread[] lThreads=null;
			int lSimultaneousConnection		= m_SimultaneousConnection;
						
			// create threads
			DateTime lStartTime = DateTime.Now;
			lThreads = new Thread[lSimultaneousConnection];
			for (int i = 0; i < lSimultaneousConnection; i++) 
			{
				Thread t = new Thread(new ThreadStart(ThreadProc));
				lThreads[i] = t;
			}
			
			// start threads
			for (int i = 0; i < lSimultaneousConnection; i++) 
			{
				lThreads[i].Name="ThreadProc" + (i+1);
				lThreads[i].Start();
				
			}

			// join threads
			for (int i = 0; i < lSimultaneousConnection; i++) 
			{
				lThreads[i].Join();
			}
			TimeSpan ldiff = (DateTime.Now - lStartTime);
			string s = "Total Time : " + ldiff.TotalMilliseconds + " Milliseconds";
			this.textBox_output.AppendText(s);
			this.textBox_output.AppendText("\n");
			return ;

		}

		private  void ThreadProc()
		{
			UniSession us=null;  
			try
			{
				
				//Connection Pooling <=>setting programmatically
				//====================================================
				UniObjects.UOPooling = this.m_IsPooling;
				UniObjects.MinPoolSize = this.m_MinPoolSize;
				UniObjects.MaxPoolSize = this.m_MaxPoolSize;
				UniObjects.IdleRemoveThreshold = this.m_IdleRemoveThreshold;
				UniObjects.IdleRemoveExecInterval = this.m_IdleRemoveExecInterval;
				us = UniObjects.OpenSession(m_Server,m_User,m_Password,m_Account,m_DatabaseType);
				UniCommand cmd = us.CreateUniCommand();
				cmd.Command="LIST VOC SAMPLE 10";
				cmd.Execute();
				string response_str = cmd.Response;
				Console.WriteLine("  Response from UniCommand :"+response_str);
				string s = "Started  " +Thread.CurrentThread.Name + "\n";
				this.textBox_output.AppendText(s);

				//Connection Pooling <=>using App.config file or ConnectionPooling.exe.config file
				//====================================================================================
				
				//reading from config file. Please uncomment <UO.NET> section in App.config file
				// Please comment all the above code , and uncomment the below code.
				//us = UniObjects.OpenSession(m_Server,m_User,m_Password,m_Account,m_DatabaseType);
				//UniCommand cmd = us.CreateUniCommand();
				//cmd.Command="LIST VOC SAMPLE 10";
				//cmd.Execute();
				//string response_str = cmd.Response;
				//Console.WriteLine("  Response from UniCommand :"+response_str);
				//string s = "Started  " +Thread.CurrentThread.Name + "\n";
				//this.textBox_output.AppendText(s);
			}
			catch(Exception e)
			{
				this.textBox_output.AppendText(e.Message);
			}
			finally
			{
				if(us != null && us.IsActive)
				{
					UniObjects.CloseSession(us);
					string s = "Closing  " +Thread.CurrentThread.Name + "\n";
					this.textBox_output.AppendText(s);
					
				}
			}
		}

		private void Form1_Closed(object sender, System.EventArgs e)
		{
			CloseAllSession();
		
		}

		private void menuItem2_Click(object sender, System.EventArgs e)
		{
			// Exit Button Clicked
			CloseAllSession();
			this.Close();

		}

		private void CloseAllSession()
		{
			UniObjects.CloseAllSessions();
		}

	}
}
