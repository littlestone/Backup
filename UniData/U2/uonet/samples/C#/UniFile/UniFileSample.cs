using System;
using IBMU2.UODOTNET;

namespace IBMU2.Samples.UniFileSample
{
	/// <summary>
	/// Summary description for Class1.
	/// </summary>
	class UniFileSample
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
				
				// open customer file
				UniFile fl = us1.CreateUniFile("CUSTOMER");

				// read a record 
				UniDynArray ar_record = fl.Read("2");

				// read a field
				UniDynArray ar_record2 = fl.ReadField("2",7);

				// read number of fields
				int[] lFieldSet = {4,5,6};
				UniDynArray ar_record3 = fl.ReadFields("2",lFieldSet);

				
				// read named field
				UniDynArray ar_record4 = fl.ReadNamedField("2","LNAME");

				// read records as UniDataSet
				string [] sArray =  {"2","12","3","4"};
				UniDataSet uSet = fl.ReadRecords(sArray);
				foreach (UniRecord item in uSet) 
				{
					Console.WriteLine(item.ToString());
		  		}

				
				
				
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
