using System;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using IBMU2.UODOTNET;
using System.Text;

namespace Walkthrough_WebAppl
{
	/// <summary>
	/// Summary description for WebForm1.
	/// </summary>
	public class WebForm1 : System.Web.UI.Page
	{
		protected System.Web.UI.WebControls.Label Label1;
		protected System.Web.UI.WebControls.TextBox TextBox_HostName;
		protected System.Web.UI.WebControls.Label Label2;
		protected System.Web.UI.WebControls.TextBox TextBox_Account;
		protected System.Web.UI.WebControls.Label Label3;
		protected System.Web.UI.WebControls.TextBox TextBox_UserID;
		protected System.Web.UI.WebControls.Label Label4;
		protected System.Web.UI.WebControls.TextBox TextBox_Password;
		protected System.Web.UI.WebControls.Label Label5;
		protected System.Web.UI.WebControls.TextBox TextBox_FileName;
		protected System.Web.UI.WebControls.Button Button_Load;
		protected System.Web.UI.WebControls.TextBox TextBox_data;
		protected System.Web.UI.WebControls.RadioButtonList RadioButtonList1;
	
		private void Page_Load(object sender, System.EventArgs e)
		{
			// Put user code to initialize the page here
		}

		#region Web Form Designer generated code
		override protected void OnInit(EventArgs e)
		{
			//
			// CODEGEN: This call is required by the ASP.NET Web Form Designer.
			//
			InitializeComponent();
			base.OnInit(e);
		}
		
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{    
			this.Button_Load.Click += new System.EventHandler(this.Button_Load_Click);
			this.Load += new System.EventHandler(this.Page_Load);

		}
		#endregion

		private void Button_Load_Click(object sender, System.EventArgs e)
		{
			string lHostName = TextBox_HostName.Text;
			string lAccount = TextBox_Account.Text;
			string lUser = TextBox_UserID.Text;
			string lPassword = TextBox_Password.Text;
			string lFileName = TextBox_FileName.Text;
			string lServiceType;
			StringBuilder lStrValue = new StringBuilder();
			string [] lRecIDArray ;
			ArrayList lRecIDList = new ArrayList();

			
			if (RadioButtonList1.Items[0].Selected)
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
				
				//get the session object
				us = UniObjects.OpenSession(lHostName,lUser,lPassword,lAccount,lServiceType);

				//open file
				UniFile fl = us.CreateUniFile(lFileName);
				
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
				TextBox_data.Text = lStrValue.ToString();
			}
			catch (Exception ex )
			{
				
				TextBox_data.Text = ex.Message;
				
			}
			finally
			{
				if(us != null && us.IsActive)
				{
					UniObjects.CloseSession(us);
				}
				

			}
			
		}
	}
}
