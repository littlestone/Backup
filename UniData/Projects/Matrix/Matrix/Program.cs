using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.DirectoryServices;
using System.DirectoryServices.ActiveDirectory;
using System.Collections;
using System.DirectoryServices.AccountManagement;

namespace Matrix
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Extrating Active Directory account informaiton from CORP domain, please wait...");

            /*
            string header = "cn" + "\t" + "sAMAccountName" + "\t" + "givenName" + "\t" + "sn" + "\t" +
                            "streetAddress" + "\t" + "l" + "\t" + "st" + "\t" + "postalCode" + "\t" +
                            "co" + "\t" + "telephoneNumber" + "\t" + "facsimileTelephoneNumber" + "\t" +
                            "mail" + "\t" + "physicalDeliveryOfficeName" + "\t" + "manager" + "\t" +
                            "title" + "\t" + "extensionAttribute5" + "\t" + "department" + "\t" + 
                            "userAccountControl" + "\t" + "isCrmUser";
            */

            List<string> userList = new List<string>();

            GetActiveUserAccounts(userList);
            GetInactiveUserAccounts(userList);
            
            userList.Sort();
            //userList.Insert(0, header);
            string path = Environment.GetEnvironmentVariable("USERPROFILE") + @"\Desktop\CorpActiveDirectoryExtract_" + DateTime.Now.ToString("yyyyMMddHHmmssfff") + ".txt";
            File.WriteAllLines(path, userList, Encoding.GetEncoding(65001));
            Console.WriteLine("Succeed! -> " + path);
            Console.WriteLine("Press any key to exit...");
            Console.ReadKey();
        }

        public static void GetActiveUserAccounts(List<string> userList)
        {
            // active user accounts AD path
            string adPath = "LDAP://adc1.corp.local/OU=NetUsers,OU=UserAccounts,OU=Ipex,DC=corp,DC=local"; // IPEX

            // set up domain context
            PrincipalContext ctx = new PrincipalContext(ContextType.Domain, "adc1.corp.local");

            // Directory Entry Class: this class encapsulates a node or object in the active directory hierarchy. Use this class for binding to objects, reading properties and updating attributes.
            using (DirectoryEntry dEntry = new DirectoryEntry(adPath))
            {
                // Directory Searcher: It will perform queries against the active directory hierarchy
                using (DirectorySearcher dSearcher = new DirectorySearcher(dEntry))
                {
                    // Executes the search and returns a collection of the entries that are found.
                    dSearcher.Filter = "(&(objectclass=user))";
                    dSearcher.PageSize = 1500;

                    // get all entries from the active directory.
                    // Last Name, name, initial, homepostaladdress, title, company etc..
                    foreach (SearchResult sResultSet in dSearcher.FindAll())
                    {
                        string username = GetProperty(sResultSet, "cn");
                        bool isCrmUser = false;

                        // find a user
                        UserPrincipal user = UserPrincipal.FindByIdentity(ctx, username);
                        //var user = new UserPrincipal(ctx);
                        //user.SamAccountName = username;
                        //var userSearcher = new PrincipalSearcher(user);
                        //user = userSearcher.FindOne() as UserPrincipal;

                        // find the group in question
                        //GroupPrincipal group = GroupPrincipal.FindByIdentity(ctx, "o365-crm-users"); // old
                        GroupPrincipal group = GroupPrincipal.FindByIdentity(ctx, "O365_LIC_Ipex_Dyn365_CRM_Pro");
                        //var group = new GroupPrincipal(ctx);
                        //group.SamAccountName = "o365-crm-users";
                        //var groupSearcher = new PrincipalSearcher(group);
                        //group = groupSearcher.FindOne() as GroupPrincipal;

                        if (user != null)
                        {
                            // check if user is member of that group
                            if (user.IsMemberOf(group))
                            {
                                isCrmUser = true;
                            }
                        }

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
                                     GetProperty(sResultSet, "department") + "\t" +
                                     isCrmUser + "\t" +
                                     GetProperty(sResultSet, "userAccountControl") + "\t" +
                                     GetProperty(sResultSet, "userPrincipalName") + GetProperty(sResultSet, "uPNSuffixes"));

                        Console.WriteLine(username + " " + isCrmUser.ToString());
                    }
                }
            }
        }

        public static void GetInactiveUserAccounts(List<string> userList)
        {
            // set inactive user accounts AD path
            string adPath = "LDAP://adc1.corp.local/OU=NetUsersDisabled,OU=UserAccounts,OU=Ipex,DC=corp,DC=local"; // IPEX

            // set up domain context
            PrincipalContext ctx = new PrincipalContext(ContextType.Domain, "adc1.corp.local");

            // Directory Entry Class: this class encapsulates a node or object in the active directory hierarchy. Use this class for binding to objects, reading properties and updating attributes.
            using (DirectoryEntry dEntry = new DirectoryEntry(adPath))
            {
                // Directory Searcher: It will perform queries against the active directory hierarchy
                using (DirectorySearcher dSearcher = new DirectorySearcher(dEntry))
                {
                    // Executes the search and returns a collection of the entries that are found.
                    dSearcher.Filter = "(&(objectclass=user))";
                    dSearcher.PageSize = 1500;

                    // get all entries from the active directory.
                    // Last Name, name, initial, homepostaladdress, title, company etc..
                    foreach (SearchResult sResultSet in dSearcher.FindAll())
                    {
                        string username = GetProperty(sResultSet, "cn");
                        string userAccountControl = GetProperty(sResultSet, "userAccountControl") != "514" ? "514" : "514";
                        bool isCrmUser = false;

                        // find a user
                        UserPrincipal user = UserPrincipal.FindByIdentity(ctx, username);
                        //var user = new UserPrincipal(ctx);
                        //user.SamAccountName = username;
                        //var userSearcher = new PrincipalSearcher(user);
                        //user = userSearcher.FindOne() as UserPrincipal;

                        // find the group in question
                        //GroupPrincipal group = GroupPrincipal.FindByIdentity(ctx, "o365-crm-users"); // old
                        GroupPrincipal group = GroupPrincipal.FindByIdentity(ctx, "O365_LIC_Ipex_Dyn365_CRM_Pro");
                        //var group = new GroupPrincipal(ctx);
                        //group.SamAccountName = "o365-crm-users";
                        //var groupSearcher = new PrincipalSearcher(group);
                        //group = groupSearcher.FindOne() as GroupPrincipal;

                        if (user != null)
                        {
                            // check if user is member of that group
                            if (user.IsMemberOf(group))
                            {
                                isCrmUser = true;
                            }
                        }

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
                                     GetProperty(sResultSet, "department") + "\t" +
                                     isCrmUser + "\t" +
                                     userAccountControl + "\t" +
                                     GetProperty(sResultSet, "userPrincipalName") + GetProperty(sResultSet, "uPNSuffixes"));

                        Console.WriteLine(username + " " + isCrmUser.ToString());
                    }
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
