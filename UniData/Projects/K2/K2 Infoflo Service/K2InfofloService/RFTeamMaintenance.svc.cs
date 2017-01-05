using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.ServiceModel.Web;
using System.Web.Configuration;
using System.Text;
using U2.Data.Client;
using U2.Data.Client.UO;
using SourceCode.SmartObjects.Client;
using SourceCode.SmartObjects.Client.Filters;
using SourceCode.Hosting.Client.BaseAPI;
using SourceCode.Data.SmartObjectsClient;
using System.Xml.Linq;
using System.Diagnostics;

namespace K2InfofloService
{
    // NOTE: You can use the "Rename" command on the "Refactor" menu to change the class name "RFTeamMaintenance" in code, svc and config file together.
    public class RFTeamMaintenance : IRFTeamMaintenance
    {
        private U2Connection GetConnection()
        {
            U2ConnectionStringBuilder conn_str = new U2ConnectionStringBuilder();
            conn_str.UserID = WebConfigurationManager.AppSettings["UD_USERID"];
            conn_str.Password = WebConfigurationManager.AppSettings["UD_PASSWORD"];
            conn_str.Server = WebConfigurationManager.AppSettings["UD_HOSTNAME"];
            conn_str.Database = WebConfigurationManager.AppSettings["UD_ACCOUNT"];
            conn_str.ServerType = WebConfigurationManager.AppSettings["SERVER_TYPE"];
            conn_str.AccessMode = WebConfigurationManager.AppSettings["ACCESS_MODE"];           // For UO
            conn_str.RpcServiceType = WebConfigurationManager.AppSettings["RPC_SERVICE_TYPE"];  // For UO UniData (Universe=uvcs)
            conn_str.Pooling = false;
            string s = conn_str.ToString();
            U2Connection con = new U2Connection();
            con.ConnectionString = s;
            con.Open();

            return con;
        }

        public List<Team> GetTeamList(string warehouseCode)
        {
            using (U2Connection con = GetConnection())
            {
                // Get session object
                UniSession uSession = con.UniSession;

                // Execute UniQuery command, return result in XML then convert to DataSet
                UniXML cmd = uSession.CreateUniXML();
                cmd.GenerateXML(@"list RFTBLFILE WITH WAREHOUSE LIKE """ + warehouseCode + @"*..."" TEAM_NAME BY @ID");
                DataSet dsTeam = cmd.GetDataSet();

                // Build Team list
                List<Team> teamList = new List<Team>();
                teamList.Add(new Team { TeamId = "NEW", TeamName = "New Team User" });
                if (dsTeam.Tables.Count > 0)
                {
                    foreach (DataRow row in dsTeam.Tables[0].Rows)
                    {
                        if (row["_ID"].ToString().Split('*').Count() > 1)
                            teamList.Add(new Team { TeamId = row["_ID"].ToString().Split('*')[1], TeamName = row["TEAM_NAME"].ToString() });
                    }
                }

                return teamList;
            }
        }

        public List<Zone> GetZoneList(string warehouseCode)
        {
            using (U2Connection con = GetConnection())
            {
                // Get session object
                UniSession uSession = con.UniSession;

                // Execute UniQuery command, return result in XML then convert to DataSet
                UniXML cmd = uSession.CreateUniXML();
                cmd.GenerateXML(@"list RFTBLFILE WITH WAREHOUSE = """ + warehouseCode + @""" ZONE ZONE_DESC BY @ID");
                DataSet dsZone = cmd.GetDataSet();

                // Build Zone list
                List<Zone> zoneList = new List<Zone>();
                List<string> zoneCode = new List<string>();
                List<string> zoneName = new List<string>();

                if (dsZone.Tables.Count > 0)
                {
                    for (int i = 0; i < dsZone.Tables.Count; i++)
                    {
                        // for ZoneS_MV
                        if (dsZone.Tables[i].TableName == "ZONE_MV")
                        {
                            foreach (DataRow dr in dsZone.Tables[i].Rows)
                            {
                                zoneCode.Add(dr["ZONE"].ToString());
                            }
                        }

                        // for ZoneS_DESC_MV
                        if (dsZone.Tables[i].TableName == "ZONE_DESC_MV")
                        {
                            foreach (DataRow dr in dsZone.Tables[i].Rows)
                            {
                                // [TODO] enconding conversion
                                if (dr["ZONE_DESC"].ToString() == "ENTREPâT") 
                                    zoneName.Add("ENTREPOT");
                                else
                                    zoneName.Add(dr["ZONE_DESC"].ToString());
                            }
                        }
                    }

                    zoneList.Add(new Zone { ZoneCode = "0", ZoneName = "All Zones" });
                    for (int i = 0; i < zoneCode.Count; i++)
                    {
                        zoneList.Add(new Zone { ZoneCode = zoneCode[i], ZoneName = zoneName[i] });
                    }
                }

                return zoneList;
            }
        }

        public List<Shift> GetShiftList(string warehouseCode)
        {
            using (U2Connection con = GetConnection())
            {
                // Get session object
                UniSession uSession = con.UniSession;

                // Execute UniQuery command, return result in XML then convert to DataSet
                UniXML cmd = uSession.CreateUniXML();
                cmd.GenerateXML(@"list RFTBLFILE WITH WAREHOUSE = """ + warehouseCode + @""" SHIFTS SHIFTS_DESC BY @ID");
                DataSet dsShift = cmd.GetDataSet();

                // Build Shift list
                List<Shift> shiftList = new List<Shift>();
                List<string> shiftCode = new List<string>();
                List<string> shiftName = new List<string>();
                if (dsShift.Tables.Count > 0)
                {
                    for (int i = 0; i < dsShift.Tables.Count; i++)
                    {
                        // for SHIFTS_MV
                        if (dsShift.Tables[i].TableName == "SHIFTS_MV")
                        {
                            foreach (DataRow dr in dsShift.Tables[i].Rows)
                            {
                                shiftCode.Add(dr["SHIFTS"].ToString());
                            }
                        }

                        // for SHIFTS_DESC_MV
                        if (dsShift.Tables[i].TableName == "SHIFTS_DESC_MV")
                        {
                            foreach (DataRow dr in dsShift.Tables[i].Rows)
                            {
                                shiftName.Add(dr["SHIFTS_DESC"].ToString());
                            }
                        }
                    }

                    for (int i = 0; i < shiftCode.Count; i++)
                    {
                        shiftList.Add(new Shift { ShiftCode = shiftCode[i], ShiftName = shiftName[i] });
                    }
                }

                return shiftList;
            }
        }

        public RFTBLFILE_TEAM_RECORD READ_RFTBLFILE(string warehouseCode, string teamID)
        {
            using (U2Connection con = GetConnection())
            {
                char FM = Convert.ToChar(254);  // UniData Delimiter Symbol @FM
                char VM = Convert.ToChar(253);  // UniData Delimiter Symbol @VM
                string teamRecordID = warehouseCode + "*" + teamID;

                // Get session object
                UniSession uSession = con.UniSession;

                // Read RFTBLFILE record
                UniFile fl = uSession.CreateUniFile("RFTBLFILE");
                UniDynArray ar = fl.Read(teamRecordID);
                List<string> fields = ar.ToString().Split(FM).ToList();
                fields.Insert(0, teamRecordID);

                // Build RFTBLFILE team record
                RFTBLFILE_TEAM_RECORD record = new RFTBLFILE_TEAM_RECORD()
                {
                    ID = fields[0],
                    TEAM_NAME = fields[1],
                    STATUS = fields[13],
                    SHIFT = fields[14],
                    TEAM_ZONE = fields[11],
                    DC_PLT_USER = (ar.Count() >= 20) ? (fields[22] == "Y") ? "1" : "0" : "",
                    ADMIN_USER = (ar.Count() >= 31) ? (fields[32] == "Y") ? "1" : "0" : "",
                    DEF_PACKER = (ar.Count() >= 30) ? (fields[31] == "Y") ? "1" : "0" : "",
                    BATCH_USER = (ar.Count() >= 33) ? (fields[34] == "Y") ? "1" : "0" : "",
                    LAST_PKID_NO = (ar.Count() >= 34) ? fields[35] : "",  // unary condition is used here to avoid the possibility of index out of boundary error because UniDynArray ar may return various size of fields
                    ORD_IN_PROCESS = (ar.Count() >= 19) ? fields[20] : "",
                    PIK_FLAG = (fields[2] == "Y") ? "1" : "0",
                    PAK_FLAG = (fields[3] == "Y") ? "1" : "0",
                    SHP_FLAG = (fields[4] == "Y") ? "1" : "0",
                    REC_FLAG = (fields[5] == "Y") ? "1" : "0",
                    OTH_FLAG = (fields[6] == "Y") ? "1" : "0",
                    FORK_LIFT_OPR = (fields[10] == "Y") ? "1" : "0",
                    USR_WLCM_MSG = fields[7].Replace(VM, '\n')
                };

                return record;
            }
        }
    }
}
