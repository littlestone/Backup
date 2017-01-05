using System;
using System.Drawing;
using System.Collections;
using System.ComponentModel;
using System.Windows.Forms;
using System.Data;
using System.Text;
using IBMU2.UODOTNET;

namespace Walkthrough_WindowsAppl
{
	/// <summary>
	/// Summary description for Form1.
	/// </summary>
	public class Form1 : System.Windows.Forms.Form
	{
		private System.Windows.Forms.Label label1;
		private System.Windows.Forms.Label label2;
		private System.Windows.Forms.Label label3;
		private System.Windows.Forms.Label label4;
		private System.Windows.Forms.GroupBox groupBox1;
		private System.Windows.Forms.RadioButton radioButton1;
		private System.Windows.Forms.RadioButton radioButton2;
		private System.Windows.Forms.TextBox textBox_data;
		private System.Windows.Forms.TextBox textBox_hostname;
		private System.Windows.Forms.TextBox textBox_user;
		private System.Windows.Forms.TextBox textBox_password;
		private System.Windows.Forms.Button button_load;
		private System.Windows.Forms.StatusBar statusBar1;
		private System.Windows.Forms.Label label6;
		private System.Windows.Forms.GroupBox groupBox2;
		private System.Windows.Forms.Label label7;
		private System.Windows.Forms.ComboBox comboBox_record;
		private System.Windows.Forms.GroupBox groupBox3;
		private System.Windows.Forms.Label label8;
		private System.Windows.Forms.ComboBox comboBox_command;
		private System.Windows.Forms.Button button_command;
		private System.Windows.Forms.ComboBox comboBox_account;
		private System.Windows.Forms.Label label5;
		private System.Windows.Forms.ComboBox comboBox_filename;
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.Container components = null;

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
			this.textBox_data = new System.Windows.Forms.TextBox();
			this.button_load = new System.Windows.Forms.Button();
			this.label1 = new System.Windows.Forms.Label();
			this.textBox_hostname = new System.Windows.Forms.TextBox();
			this.label2 = new System.Windows.Forms.Label();
			this.textBox_user = new System.Windows.Forms.TextBox();
			this.label3 = new System.Windows.Forms.Label();
			this.textBox_password = new System.Windows.Forms.TextBox();
			this.label4 = new System.Windows.Forms.Label();
			this.groupBox1 = new System.Windows.Forms.GroupBox();
			this.radioButton2 = new System.Windows.Forms.RadioButton();
			this.radioButton1 = new System.Windows.Forms.RadioButton();
			this.statusBar1 = new System.Windows.Forms.StatusBar();
			this.label6 = new System.Windows.Forms.Label();
			this.groupBox2 = new System.Windows.Forms.GroupBox();
			this.comboBox_record = new System.Windows.Forms.ComboBox();
			this.label7 = new System.Windows.Forms.Label();
			this.groupBox3 = new System.Windows.Forms.GroupBox();
			this.button_command = new System.Windows.Forms.Button();
			this.comboBox_command = new System.Windows.Forms.ComboBox();
			this.label8 = new System.Windows.Forms.Label();
			this.comboBox_account = new System.Windows.Forms.ComboBox();
			this.label5 = new System.Windows.Forms.Label();
			this.comboBox_filename = new System.Windows.Forms.ComboBox();
			this.groupBox1.SuspendLayout();
			this.groupBox2.SuspendLayout();
			this.groupBox3.SuspendLayout();
			this.SuspendLayout();
			// 
			// textBox_data
			// 
			this.textBox_data.Location = new System.Drawing.Point(8, 224);
			this.textBox_data.Multiline = true;
			this.textBox_data.Name = "textBox_data";
			this.textBox_data.ScrollBars = System.Windows.Forms.ScrollBars.Both;
			this.textBox_data.Size = new System.Drawing.Size(792, 240);
			this.textBox_data.TabIndex = 0;
			this.textBox_data.Text = "";
			// 
			// button_load
			// 
			this.button_load.Location = new System.Drawing.Point(8, 88);
			this.button_load.Name = "button_load";
			this.button_load.Size = new System.Drawing.Size(80, 23);
			this.button_load.TabIndex = 1;
			this.button_load.Text = "Load_Record";
			this.button_load.Click += new System.EventHandler(this.button_load_Click);
			// 
			// label1
			// 
			this.label1.Location = new System.Drawing.Point(24, 8);
			this.label1.Name = "label1";
			this.label1.TabIndex = 2;
			this.label1.Text = "Host Name:";
			// 
			// textBox_hostname
			// 
			this.textBox_hostname.Location = new System.Drawing.Point(160, 8);
			this.textBox_hostname.Name = "textBox_hostname";
			this.textBox_hostname.Size = new System.Drawing.Size(121, 20);
			this.textBox_hostname.TabIndex = 3;
			this.textBox_hostname.Text = "localhost";
			// 
			// label2
			// 
			this.label2.Location = new System.Drawing.Point(24, 40);
			this.label2.Name = "label2";
			this.label2.TabIndex = 4;
			this.label2.Text = "Account:";
			// 
			// textBox_user
			// 
			this.textBox_user.Location = new System.Drawing.Point(160, 72);
			this.textBox_user.Name = "textBox_user";
			this.textBox_user.Size = new System.Drawing.Size(121, 20);
			this.textBox_user.TabIndex = 7;
			this.textBox_user.Text = "ZZZ";
			// 
			// label3
			// 
			this.label3.Location = new System.Drawing.Point(24, 72);
			this.label3.Name = "label3";
			this.label3.TabIndex = 6;
			this.label3.Text = "User ID:";
			// 
			// textBox_password
			// 
			this.textBox_password.Location = new System.Drawing.Point(160, 104);
			this.textBox_password.Name = "textBox_password";
			this.textBox_password.PasswordChar = '*';
			this.textBox_password.Size = new System.Drawing.Size(121, 20);
			this.textBox_password.TabIndex = 9;
			this.textBox_password.Text = "ani2ka";
			// 
			// label4
			// 
			this.label4.Location = new System.Drawing.Point(24, 104);
			this.label4.Name = "label4";
			this.label4.TabIndex = 8;
			this.label4.Text = "Password:";
			// 
			// groupBox1
			// 
			this.groupBox1.Controls.Add(this.radioButton2);
			this.groupBox1.Controls.Add(this.radioButton1);
			this.groupBox1.Location = new System.Drawing.Point(24, 128);
			this.groupBox1.Name = "groupBox1";
			this.groupBox1.Size = new System.Drawing.Size(112, 64);
			this.groupBox1.TabIndex = 10;
			this.groupBox1.TabStop = false;
			this.groupBox1.Text = "U2 Database";
			this.groupBox1.Enter += new System.EventHandler(this.groupBox1_Enter);
			// 
			// radioButton2
			// 
			this.radioButton2.Location = new System.Drawing.Point(16, 32);
			this.radioButton2.Name = "radioButton2";
			this.radioButton2.Size = new System.Drawing.Size(72, 24);
			this.radioButton2.TabIndex = 1;
			this.radioButton2.Text = "UniVerse";
			// 
			// radioButton1
			// 
			this.radioButton1.Checked = true;
			this.radioButton1.Location = new System.Drawing.Point(16, 16);
			this.radioButton1.Name = "radioButton1";
			this.radioButton1.Size = new System.Drawing.Size(64, 24);
			this.radioButton1.TabIndex = 0;
			this.radioButton1.TabStop = true;
			this.radioButton1.Text = "UniData";
			// 
			// statusBar1
			// 
			this.statusBar1.Location = new System.Drawing.Point(0, 471);
			this.statusBar1.Name = "statusBar1";
			this.statusBar1.Size = new System.Drawing.Size(808, 22);
			this.statusBar1.TabIndex = 15;
			this.statusBar1.Text = "Status";
			// 
			// label6
			// 
			this.label6.Location = new System.Drawing.Point(8, 200);
			this.label6.Name = "label6";
			this.label6.TabIndex = 16;
			this.label6.Text = "Output/Error:";
			// 
			// groupBox2
			// 
			this.groupBox2.Controls.Add(this.comboBox_filename);
			this.groupBox2.Controls.Add(this.label5);
			this.groupBox2.Controls.Add(this.comboBox_record);
			this.groupBox2.Controls.Add(this.label7);
			this.groupBox2.Controls.Add(this.button_load);
			this.groupBox2.Location = new System.Drawing.Point(296, 16);
			this.groupBox2.Name = "groupBox2";
			this.groupBox2.Size = new System.Drawing.Size(240, 120);
			this.groupBox2.TabIndex = 17;
			this.groupBox2.TabStop = false;
			this.groupBox2.Text = "Read/Write:";
			// 
			// comboBox_record
			// 
			this.comboBox_record.Items.AddRange(new object[] {
																 "All",
																 "2",
																 "1002",
																 "4"});
			this.comboBox_record.Location = new System.Drawing.Point(112, 56);
			this.comboBox_record.Name = "comboBox_record";
			this.comboBox_record.Size = new System.Drawing.Size(121, 21);
			this.comboBox_record.TabIndex = 13;
			this.comboBox_record.Text = "All";
			// 
			// label7
			// 
			this.label7.Location = new System.Drawing.Point(8, 56);
			this.label7.Name = "label7";
			this.label7.Size = new System.Drawing.Size(56, 23);
			this.label7.TabIndex = 12;
			this.label7.Text = "Record:";
			// 
			// groupBox3
			// 
			this.groupBox3.Controls.Add(this.button_command);
			this.groupBox3.Controls.Add(this.comboBox_command);
			this.groupBox3.Controls.Add(this.label8);
			this.groupBox3.Location = new System.Drawing.Point(552, 8);
			this.groupBox3.Name = "groupBox3";
			this.groupBox3.Size = new System.Drawing.Size(240, 88);
			this.groupBox3.TabIndex = 18;
			this.groupBox3.TabStop = false;
			this.groupBox3.Text = "Command/StoreProcedure";
			// 
			// button_command
			// 
			this.button_command.Location = new System.Drawing.Point(8, 56);
			this.button_command.Name = "button_command";
			this.button_command.Size = new System.Drawing.Size(136, 23);
			this.button_command.TabIndex = 2;
			this.button_command.Text = "Load_CommandOutput";
			this.button_command.Click += new System.EventHandler(this.button1_command);
			// 
			// comboBox_command
			// 
			this.comboBox_command.Items.AddRange(new object[] {
																  "LIST VOC SAMPLE 10",
																  "DATE"});
			this.comboBox_command.Location = new System.Drawing.Point(80, 24);
			this.comboBox_command.Name = "comboBox_command";
			this.comboBox_command.Size = new System.Drawing.Size(152, 21);
			this.comboBox_command.TabIndex = 1;
			this.comboBox_command.Text = "LIST VOC SAMPLE 10";
			// 
			// label8
			// 
			this.label8.Location = new System.Drawing.Point(8, 24);
			this.label8.Name = "label8";
			this.label8.Size = new System.Drawing.Size(64, 23);
			this.label8.TabIndex = 0;
			this.label8.Text = "Command:";
			// 
			// comboBox_account
			// 
			this.comboBox_account.Items.AddRange(new object[] {
																  "demo",
																  "HS.SALES",
																  "HS.SERVICE"});
			this.comboBox_account.Location = new System.Drawing.Point(160, 40);
			this.comboBox_account.Name = "comboBox_account";
			this.comboBox_account.Size = new System.Drawing.Size(121, 21);
			this.comboBox_account.TabIndex = 19;
			this.comboBox_account.Text = "demo";
			// 
			// label5
			// 
			this.label5.Location = new System.Drawing.Point(8, 24);
			this.label5.Name = "label5";
			this.label5.Size = new System.Drawing.Size(72, 23);
			this.label5.TabIndex = 14;
			this.label5.Text = "File Name:";
			// 
			// comboBox_filename
			// 
			this.comboBox_filename.Items.AddRange(new object[] {
																   "CUSTOMER",
																   "PRODUCTS",
																   "STATES",
																   "PRODS"});
			this.comboBox_filename.Location = new System.Drawing.Point(112, 24);
			this.comboBox_filename.Name = "comboBox_filename";
			this.comboBox_filename.Size = new System.Drawing.Size(121, 21);
			this.comboBox_filename.TabIndex = 15;
			this.comboBox_filename.Text = "CUSTOMER";
			// 
			// Form1
			// 
			this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
			this.ClientSize = new System.Drawing.Size(808, 493);
			this.Controls.Add(this.comboBox_account);
			this.Controls.Add(this.groupBox3);
			this.Controls.Add(this.groupBox2);
			this.Controls.Add(this.label6);
			this.Controls.Add(this.statusBar1);
			this.Controls.Add(this.groupBox1);
			this.Controls.Add(this.textBox_password);
			this.Controls.Add(this.label4);
			this.Controls.Add(this.textBox_user);
			this.Controls.Add(this.label3);
			this.Controls.Add(this.label2);
			this.Controls.Add(this.textBox_hostname);
			this.Controls.Add(this.label1);
			this.Controls.Add(this.textBox_data);
			this.Name = "Form1";
			this.Text = "Walkthrough_WindowsAppl";
			this.groupBox1.ResumeLayout(false);
			this.groupBox2.ResumeLayout(false);
			this.groupBox3.ResumeLayout(false);
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

		private void button_load_Click(object sender, System.EventArgs e)
		{

			Cursor currentCursor = Cursor.Current;

			string lHostName = textBox_hostname.Text;
			string lAccount = comboBox_account.Text;
			string lUser = textBox_user.Text;
			string lPassword = textBox_password.Text;
			string lFileName = comboBox_filename.Text;
			string lServiceType;
			StringBuilder lStrValue = new StringBuilder();
			string [] lRecIDArray ;
			ArrayList lRecIDList = new ArrayList();
			string lRecordID = comboBox_record.Text;
			if(radioButton1.Checked)
			{
				lServiceType = "udcs";
			}
			else
			{
				lServiceType = "uvcs";
			}
			UniSession us = null;
			
			try
			{
				
				Cursor.Current = Cursors.WaitCursor;
				statusBar1.Text ="Connecting..." + lHostName + " " + lUser + " " + lAccount + " " + lServiceType;
				
				//get the session object
				us = UniObjects.OpenSession(lHostName,lUser,lPassword,lAccount,lServiceType);

				statusBar1.Text ="Connected..." + lHostName + " " + lUser + " " + lAccount + " " + lServiceType;
				Cursor.Current = currentCursor;

				
				statusBar1.Text ="Loading Data...";
				Cursor.Current = Cursors.WaitCursor;
				//open file
				UniFile fl = us.CreateUniFile(lFileName);

				if(lRecordID.CompareTo("All") == 0)
				{
				
					// create select list
					UniSelectList sl = us.CreateUniSelectList(2);
					sl.Select(fl);
				
					// create array of Record IDs
					bool lLastRecord = sl.LastRecordRead;
					while(!lLastRecord)
					{
						string s = sl.Next();
						lRecIDList.Add(s);
						lLastRecord = sl.LastRecordRead;
					}
					lRecIDArray = new string[lRecIDList.Count];
					lRecIDList.CopyTo(0,lRecIDArray,0,lRecIDList.Count);

				
					// read records using array of records ids
					UniDataSet lSet = fl.ReadRecords(lRecIDArray);
				
				
					//use foreach statement to construct data to be displayed
					foreach (UniRecord item in lSet) 
					{
						lStrValue.Append(item.Record.ToString());
						lStrValue.Append("\r\n");
					
					}

					// display data
					textBox_data.Text = lStrValue.ToString();
				}
				else
				{
					
					// display data
					textBox_data.Text = fl.Read(lRecordID).StringValue;
				}
			}
			catch (Exception ex )
			{
				//MessageBox.Show(ex.Message);
				textBox_data.Text = ex.Message;
			}
			finally
			{
				if(us != null && us.IsActive)
				{
					UniObjects.CloseSession(us);
				}
				statusBar1.Text ="Done..." + lHostName + " " + lUser + " " + lAccount + " " + lServiceType;
				Cursor.Current = currentCursor;

			}
			
		}

		private void groupBox1_Enter(object sender, System.EventArgs e)
		{
		
		}

		private void button1_command(object sender, System.EventArgs e)
		{
			Cursor currentCursor = Cursor.Current;

			string lHostName = textBox_hostname.Text;

			
			string lAccount = comboBox_account.Text;
			string lUser = textBox_user.Text;
			string lPassword = textBox_password.Text;
			string lServiceType;
			string lCommand_Name = comboBox_command.Text;
			if(radioButton1.Checked)
			{
				lServiceType = "udcs";
			}
			else
			{
				lServiceType = "uvcs";
			}
			UniSession us = null;
			
			try
			{
				
				Cursor.Current = Cursors.WaitCursor;
				statusBar1.Text ="Connecting..." + lHostName + " " + lUser + " " + lAccount + " " + lServiceType;
				
				//get the session object
				us = UniObjects.OpenSession(lHostName,lUser,lPassword,lAccount,lServiceType);

				statusBar1.Text ="Connected..." + lHostName + " " + lUser + " " + lAccount + " " + lServiceType;
				Cursor.Current = currentCursor;

				
				statusBar1.Text ="Loading Data...";
				Cursor.Current = Cursors.WaitCursor;
				UniCommand cmd = us.CreateUniCommand();
				
				

				cmd.Command=lCommand_Name;//"LIST VOC SAMPLE 10";
				cmd.Execute();
				string response_str = cmd.Response;


				// display data
				textBox_data.Text = response_str;
			}
			catch (Exception ex )
			{
				//MessageBox.Show(ex.Message);
				textBox_data.Text = ex.Message;
			}
			finally
			{
				if(us != null && us.IsActive)
				{
					UniObjects.CloseSession(us);
				}
				statusBar1.Text ="Done..." + lHostName + " " + lUser + " " + lAccount + " " + lServiceType;
				Cursor.Current = currentCursor;

			}
		
		}

		

		
	}
}
