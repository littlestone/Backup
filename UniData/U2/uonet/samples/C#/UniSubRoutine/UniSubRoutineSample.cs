using System;
using IBMU2.UODOTNET;

namespace IBMU2.Samples.UniSubRoutineSample
{
	/// <summary>
	/// Summary description for Class1.
	/// </summary>
	class UniSubRoutineSample
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
				string RoutineName = "!TIMDAT";
				int IntTotalAtgs = 1;
				string [] largs = new string[IntTotalAtgs];
				largs[0] = "1";
				UniDynArray tmpStr2;
				UniSubroutine sub = us1.CreateUniSubroutine(RoutineName,IntTotalAtgs);

				for (int i=0; i<IntTotalAtgs; i++)
				{
					sub.SetArg(i,largs[i]);
				}
				
				sub.Call();
				tmpStr2 = sub.GetArgDynArray(0);
				string result = "\n"+ "Result is :" +tmpStr2;
				Console.WriteLine("  Response from UniSubRoutineSample :"+result);
				
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
