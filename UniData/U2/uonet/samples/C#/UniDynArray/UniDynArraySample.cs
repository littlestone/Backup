using System;
using IBMU2.UODOTNET;

namespace IBMU2.Samples.UniDynArraySample
{
	/// <summary>
	/// Summary description for Class1.
	/// </summary>
	class UniDynArraySample
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
				
				//creating UniDynArray
				char bFM = Convert.ToChar(254);
				char bVM = Convert.ToChar(253);
				char bSVM = Convert.ToChar(252);

				UniDynArray lDynArray =  new UniDynArray(us1,"ab" + bFM + "cd" + bVM + "ef" + bVM
										+ "gh" + bVM + "ij" + bFM + "kl" + bSVM + "mn" + bSVM + "no" + 
										bVM + "p" + bVM + "qr" + bFM + "s" + bFM + "t" + bFM + "");
				
				// run  Count()
				int myVal = lDynArray.Count();
				
				// run Dcount()
				int myVal2 = lDynArray.Dcount();

				// run Extract 
				UniDynArray real = lDynArray.Extract(1,1,0);

				// run Replace
				lDynArray.Replace(2, 0, 0, "*");

				//run delete
				lDynArray.Delete(1, 0, 0);

				// run insert
				lDynArray.Insert(0, 0, 0, "2500");
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
