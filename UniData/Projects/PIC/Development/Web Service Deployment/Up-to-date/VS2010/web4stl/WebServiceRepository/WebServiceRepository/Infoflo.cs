using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Configuration;
using IBMU2.UODOTNET;

namespace WebServiceRepository
{
    public class Infoflo
    {
        private static UniSession uniSession = null;

        public Infoflo()
        {
            string hostname = WebConfigurationManager.AppSettings["UD_HOSTNAME"].ToString();
            string userid = WebConfigurationManager.AppSettings["UD_USERID"].ToString();
            string password = WebConfigurationManager.AppSettings["UD_PASSWORD"].ToString();
            string account = WebConfigurationManager.AppSettings["UD_ACCOUNT"].ToString();
            uniSession = UniObjects.OpenSession(hostname, userid, password, account);
        }

        public Infoflo(string hostname, string userid, string password, string account)
        {
            uniSession = UniObjects.OpenSession(hostname, userid, password, account);
        }

        ~Infoflo()
        {
            if (uniSession != null && uniSession.IsActive)
            {
                UniObjects.CloseSession(uniSession);
                uniSession = null;
            }
        }

        public void Disconnect()
        {
            if (uniSession != null && uniSession.IsActive)
            {
                UniObjects.CloseSession(uniSession);
                uniSession = null;
            }
        }

        public string CallUniBasicProgram(string aSubName, int aNumArgs, List<string> aParmsList)
        {
            try
            {
                UniSubroutine uniSub = uniSession.CreateUniSubroutine(aSubName, aNumArgs);

                for (var i = 0; i < aParmsList.Count(); i++)
                {
                    uniSub.SetArg(i, aParmsList[i]);
                }
                uniSub.Call();

                return uniSub.GetArg(aNumArgs - 1);
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }
    }
}