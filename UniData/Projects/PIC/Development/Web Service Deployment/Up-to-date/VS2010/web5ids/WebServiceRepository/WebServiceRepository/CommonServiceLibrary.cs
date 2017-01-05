using System;
using System.Collections.Generic;
using System.ServiceModel;
using System.ServiceModel.Channels;
using System.Net;
using System.Linq;
using System.Text;
using System.DirectoryServices;
using System.Runtime.InteropServices;

namespace WebServiceRepository
{
    class CommonServiceLibrary
    {
        public List<string> GetEncryptedParmsList(string paramsEncrypted)
        {
            List<string> parmsList = new List<string>();
            string FM = Char.ConvertFromUtf32(254);     // UniData Delimiter Symbol @FM
            parmsList.Add(paramsEncrypted + FM + "D");
            parmsList.Add("");

            return parmsList;
        }

        public string GetHostName()
        {
            var hostName = "Unknown hostname...";

            try
            {
                var remoteEndpointMessageProperty = OperationContext.Current.IncomingMessageProperties[RemoteEndpointMessageProperty.Name] as RemoteEndpointMessageProperty;
                hostName = remoteEndpointMessageProperty.Address;

                var hostEntry = Dns.GetHostEntry(hostName);
                hostName = hostEntry.HostName;
            }
            catch (Exception ex)
            {
                return ex.Message;
            }

            return hostName;
        }

        //srvr = ldap server, e.g. LDAP://domain.com
        //usr = user name
        //pwd = user password
        public bool IsAuthenticated(string srvr, string usr, string pwd)
        {
            bool authenticated = false;

            try
            {
                // create LDAP connection object  
                DirectoryEntry entry = new DirectoryEntry(srvr, usr, pwd);
                object nativeObject = entry.NativeObject;
                authenticated = true;
            }
            catch (DirectoryServicesCOMException cex)
            {
                //not authenticated; reason why is in cex
            }
            catch (Exception ex)
            {
                //not authenticated due to some other exception [this is optional]
            }
            return authenticated;
        }

        // Query AD Natively
        public bool IsAuthenticated(string usr, string pwd)
        {
            using (DirectoryEntry entry = new DirectoryEntry())
            {
                entry.Username = usr;
                entry.Password = pwd;

                DirectorySearcher searcher = new DirectorySearcher(entry);
                searcher.Filter = "(objectclass=user)";

                try
                {
                    searcher.FindOne();
                }
                catch (COMException ex)
                {
                    if (ex.ErrorCode == -2147023570)
                    {
                        // Login or password is incorrect
                        return false;
                    }
                }
            }

            // FindOne() didn't throw, the credentials are correct
            return true;
        }
    }
}
