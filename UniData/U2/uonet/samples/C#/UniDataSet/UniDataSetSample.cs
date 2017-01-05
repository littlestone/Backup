using System;
using IBMU2.UODOTNET;

namespace IBMU2.Samples.UniDataSetSample
{
	/// <summary>
	/// Summary description for Class1.
	/// </summary>
	class UniDataSetSample
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
				// get session object
				us1 = UniObjects.OpenSession("localhost","ZZZ","xxxx","HS.SALES","uvcs");
				
				// open customer file
				UniFile fl = us1.CreateUniFile("CUSTOMER");

				// read records as unidataset
				string [] sArray =  {"2","12","3","4"};
				UniDataSet uSet = fl.ReadRecords(sArray);

				// use for each statement to print the record
				foreach (UniRecord item in uSet) 
				{
					Console.WriteLine(item.ToString());
		  
				}

				// use index to print the record
				int lCount = uSet.RowCount;
				for(int ii=0; ii<lCount; ii++)
				{
					UniRecord ee = uSet[ii];
					Console.WriteLine(ee.ToString());
				}

				// print one by one record
				UniRecord q2 = uSet["2"];
				string sq2 = q2.ToString();
				Console.WriteLine("  Record data for rec id 2:"+sq2);
				UniRecord q3 = uSet["3"];
				string sq3 = q3.ToString();
				Console.WriteLine("  Record data for rec id 3:"+sq3);
				UniRecord q4 = uSet["4"];
				string sq4 = q4.ToString();
				Console.WriteLine("  Record data for rec id 4:"+sq4);

				// create UniDataSet in the Client Side
				UniDataSet uSet3 = us1.CreateUniDataSet();
				uSet3.Insert("3","aaa");
				uSet3.Insert("4","bbb");
				uSet3.Insert("5","vvv");
				uSet3.Insert(2,"8","www");

				
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
