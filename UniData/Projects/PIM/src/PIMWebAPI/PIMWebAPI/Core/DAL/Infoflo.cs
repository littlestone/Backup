using System;
using System.Collections.Generic;
using System.Linq;
using U2.Data.Client;
using U2.Data.Client.UO;
using PIMWebAPI.Properties;

namespace PIMWebAPI.Core.DAL
{
    public class Infoflo : IDisposable
    {
        #region Field

        private string _AM = Char.ConvertFromUtf32(254);  // UniData Delimiter - Attribute Mark @AM
        private string _VM = Char.ConvertFromUtf32(253);  // UniData Delimiter - Value Mark @VM
        private string _SM = Char.ConvertFromUtf32(252);  // UniData Delimiter - Sub-Value Mark @SM
        private U2ConnectionStringBuilder _connectionString = new U2ConnectionStringBuilder();
        private U2Connection _session = null;

        #endregion

        #region Constructor

        public Infoflo()
        {
            _connectionString.UserID = Settings.Default.UD_USERID;
            _connectionString.Password = Settings.Default.UD_PASSWORD;
            _connectionString.Server = Settings.Default.UD_HOSTNAME;
            _connectionString.Database = Settings.Default.UD_ACCOUNT;
            _connectionString.ServerType = Settings.Default.UD_SERVER_TYPE;
            _connectionString.AccessMode = Settings.Default.UD_ACCESS_MODE;           // For UO
            _connectionString.RpcServiceType = Settings.Default.UD_RPC_SERVICE_TYPE;  // For UO UniData (Universe=uvcs)
            _connectionString.Pooling = false;
        }

        #endregion

        #region Destructor

        ~Infoflo()
        {
            Disconnect();
        }

        #endregion

        #region Property

        public string AM
        {
            get
            {
                return _AM;
            }
        }

        public string VM
        {
            get
            {
                return _VM;
            }
        }

        public string SM
        {
            get
            {
                return _SM;
            }
        }

        #endregion

        #region Method

        public U2Connection Connect()
        {
            if (_session == null || !_session.IsOpen)
            {
                _session = new U2Connection(_connectionString.ToString());
                _session.Open();
            }

            return _session;
        }

        public void Disconnect()
        {
            if (_session != null)
            {
                _session.Close();
            }
        }

        public string CallUniBasicProgram(string aSubName, int aNumArgs, List<string> aParmsList)
        {
            try
            {
                UniSubroutine uniSub = _session.UniSession.CreateUniSubroutine(aSubName, aNumArgs);

                for (int i = 0; i < aParmsList.Count(); i++)
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

        #endregion

        #region IDisposable
        void IDisposable.Dispose()
        {
            Disconnect();
        }

        #endregion
    }
}