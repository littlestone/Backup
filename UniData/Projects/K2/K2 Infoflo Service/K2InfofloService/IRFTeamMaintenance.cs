using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.Text;

namespace K2InfofloService
{
    // NOTE: You can use the "Rename" command on the "Refactor" menu to change the interface name "IRFTeamMaintenance" in both code and config file together.
    [ServiceContract]
    public interface IRFTeamMaintenance
    {
        [OperationContract]
        List<Team> GetTeamList(string warehouseCode);

        [OperationContract]
        List<Zone> GetZoneList(string warehouseCode);

        [OperationContract]
        List<Shift> GetShiftList(string warehouseCode);

        [OperationContract]
        RFTBLFILE_TEAM_RECORD READ_RFTBLFILE(string warehouseCode, string teamID);
    }

    [DataContract]
    public class Team
    {
        [DataMember]
        public string TeamId { get; set; }
        [DataMember]
        public string TeamName { get; set; }
    }

    [DataContract]
    public class Zone
    {
        [DataMember]
        public string ZoneCode { get; set; }
        [DataMember]
        public string ZoneName { get; set; }
    }

    [DataContract]
    public class Shift
    {
        [DataMember]
        public string ShiftCode { get; set; }
        [DataMember]
        public string ShiftName { get; set; }
    }

    [DataContract]
    public class RFTBLFILE_TEAM_RECORD
    {
        [DataMember]
        public string ID { get; set; }
        [DataMember]
        public string TEAM_NAME { get; set; }
        [DataMember]
        public string STATUS { get; set; }
        [DataMember]
        public string SHIFT { get; set; }
        [DataMember]
        public string TEAM_ZONE { get; set; }
        [DataMember]
        public string DC_PLT_USER { get; set; }
        [DataMember]
        public string ADMIN_USER { get; set; }
        [DataMember]
        public string DEF_PACKER { get; set; }
        [DataMember]
        public string BATCH_USER { get; set; }
        [DataMember]
        public string LAST_PKID_NO { get; set; }
        [DataMember]
        public string ORD_IN_PROCESS { get; set; }
        [DataMember]
        public string PIK_FLAG { get; set; }
        [DataMember]
        public string PAK_FLAG { get; set; }
        [DataMember]
        public string SHP_FLAG { get; set; }
        [DataMember]
        public string REC_FLAG { get; set; }
        [DataMember]
        public string OTH_FLAG { get; set; }
        [DataMember]
        public string FORK_LIFT_OPR { get; set; }
        [DataMember]
        public string USR_WLCM_MSG { get; set; }
    }
}
