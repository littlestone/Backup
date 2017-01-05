using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.DirectoryServices;
using System.DirectoryServices.ActiveDirectory;
using System.Collections;

namespace Matrix
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Extrating Active Directory account informaiton from CORP domain, please wait...");

            string adPath = "LDAP://adc1.corp.local/OU=NetUsers,OU=UserAccounts,OU=Ipex,DC=corp,DC=local"; // IPEX

            // Directory Entry Class: this class encapsulates a node or object in the active directory hierarchy. Use this class for binding to objects, reading properties and updating attributes.
            using (DirectoryEntry dEntry = new DirectoryEntry(adPath))
            {
                // Directory Searcher: It will perform queries against the active directory hierarchy
                using (DirectorySearcher dSearcher = new DirectorySearcher(dEntry))
                {
                    // Executes the search and returns a collection of the entries that are found.
                    dSearcher.Filter = "(&(objectclass=user))";
                    dSearcher.PageSize = 1500;

                    List<string> userList = new List<string>();

                    // get all entries from the active directory.
                    // Last Name, name, initial, homepostaladdress, title, company etc..
                    foreach (SearchResult sResultSet in dSearcher.FindAll())
                    {
                        userList.Add(GetProperty(sResultSet, "cn") + "\t" +
                                     GetProperty(sResultSet, "sAMAccountName") + "\t" +
                                     GetProperty(sResultSet, "givenName") + "\t" +
                                     GetProperty(sResultSet, "sn") + "\t" +
                                     GetProperty(sResultSet, "streetAddress") + "\t" +
                                     GetProperty(sResultSet, "l") + "\t" +
                                     GetProperty(sResultSet, "st") + "\t" +
                                     GetProperty(sResultSet, "postalCode") + "\t" +
                                     GetProperty(sResultSet, "co") + "\t" +
                                     GetProperty(sResultSet, "telephoneNumber") + "\t" +
                                     GetProperty(sResultSet, "facsimileTelephoneNumber") + "\t" +
                                     GetProperty(sResultSet, "mail") + "\t" +
                                     GetProperty(sResultSet, "physicalDeliveryOfficeName") + "\t" +
                                     GetProperty(sResultSet, "manager") + "\t" +
                                     GetProperty(sResultSet, "title") + "\t" +
                                     GetProperty(sResultSet, "extensionAttribute5") + "\t" +
                                     GetProperty(sResultSet, "department"));
                    }

                    userList.Sort();
                    string path = Environment.GetEnvironmentVariable("USERPROFILE") + @"\Desktop\CorpActiveDirectoryExtract_" + DateTime.Now.ToString("yyyyMMddHHmmssfff") + ".txt";
                    File.WriteAllLines(path, userList);
                    Console.WriteLine("Succeed! -> " + path);
                    Console.WriteLine("Press any key to exit...");
                    Console.ReadKey();
                }
            }
        }

        public static string GetProperty(SearchResult searchResult, string PropertyName)
        {
            if (searchResult.Properties.Contains(PropertyName))
            {
                return searchResult.Properties[PropertyName][0].ToString();
            }
            else
            {
                return string.Empty;
            }
        }
    }
}
