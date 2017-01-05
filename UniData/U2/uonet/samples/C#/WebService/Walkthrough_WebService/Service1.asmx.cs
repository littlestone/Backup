using System;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Web;
using System.Web.Services;
using IBMU2.UODOTNET;
using System.Text;

namespace Walkthrough_WebService
{
	/// <summary>
	/// Summary description for Service1.
	/// </summary>
	[System.Web.Services.WebService(
		 Namespace="http://localhost/Walkthrough_WebService/",
		 Description="Describes how to create Web Service using UODOTNET and U2 Databases.")]
	public class Service1 : System.Web.Services.WebService
	{
		public Service1()
		{
			//CODEGEN: This call is required by the ASP.NET Web Services Designer
			InitializeComponent();
		}

		#region Component Designer generated code
		
		//Required by the Web Services Designer 
		private IContainer components = null;
				
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
		}

		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		protected override void Dispose( bool disposing )
		{
			if(disposing && components != null)
			{
				components.Dispose();
			}
			base.Dispose(disposing);		
		}
		
		#endregion

		// WEB SERVICE EXAMPLE
		// The HelloWorld() example service returns the string Hello World
		// To build, uncomment the following lines then save and build the project
		// To test this web service, press F5

//		[WebMethod]
//		public string HelloWorld()
//		{
//			return "Hello World";
//		}


		// WEB SERVICE EXAMPLE
		// The GetCustomer() example service returns the CUSTOMER Table
		[WebMethod(Description="This method will use UODOTNET and U2 Database to get CUSTOMER data")]
		public string GetCustomer(string pUser,string pPassword,string pHostName,string pAccount,string pServiceType,string pFileName)
		{
			string lHostName = pHostName;
			string lAccount = pAccount;
			string lUser = pUser;
			string lPassword = pPassword;
			string lFileName = pFileName;
			string lServiceType = pServiceType;
			StringBuilder lStrValue = new StringBuilder();
			string [] lRecIDArray ;
			ArrayList lRecIDList = new ArrayList();
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
				return lStrValue.ToString();
			}
			catch (Exception ex )
			{
				lStrValue.Append(ex.Message);
				return lStrValue.ToString();
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
