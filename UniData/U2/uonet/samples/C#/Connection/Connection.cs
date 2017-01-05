using System;
using IBMU2.UODOTNET;

namespace IBMU2.Connection
{
	/// <summary>
	/// Summary description for Class1.
	/// </summary>
	class Connection
	{
		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		[STAThread]
		static void Main(string[] args)
		{
			UniSession us1=null;
			
			try
			{
				us1 = UniObjects.OpenSession("localhost","ZZZ","xxxx","HS.SALES","uvcs");
			}
			catch(Exception e)
			{
				if(us1 != null && us1.IsActive)
				{
					UniObjects.CloseSession(us1);
					us1= null;
				}
				Console.WriteLine("");
				string s = "Connection Failed : " + e.Message;
				Console.WriteLine(s);
			}
			finally
			{
				if(us1 != null && us1.IsActive)
				{
					Console.WriteLine("");
					string s = "Connection Passed";
					Console.WriteLine(s);
					UniObjects.CloseSession(us1);
				}
				
			}
		}
	}
}
