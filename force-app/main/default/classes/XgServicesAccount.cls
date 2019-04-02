public class XgServicesAccount {
  
  	public class GetDaysUntilPasswordExpires_element {
        public XgServicesAccount.ClientContext context;
        private String[] context_type_info = new String[]{'context','https://bridgerinsight.lexisnexis.com/BridgerInsight.Web.Services.Interfaces.10.2',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://bridgerinsight.lexisnexis.com/BridgerInsight.Web.Services.Interfaces.10.2','true','false'};
        private String[] field_order_type_info = new String[]{'context'};
    }
	public class ChangePasswordResponse_element {
        public Boolean ChangePasswordResult;
        private String[] ChangePasswordResult_type_info = new String[]{'ChangePasswordResult','https://bridgerinsight.lexisnexis.com/BridgerInsight.Web.Services.Interfaces.10.2',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://bridgerinsight.lexisnexis.com/BridgerInsight.Web.Services.Interfaces.10.2','true','false'};
        private String[] field_order_type_info = new String[]{'ChangePasswordResult'};
    }
   public class ClientContext {
        public String ClientID;
        public String ClientReference;
        public String DPPA;
        public Integer GLB;
        public String Password;
        public String UserID;
        private String[] ClientID_type_info = new String[]{'ClientID','https://bridgerinsight.lexisnexis.com/BridgerInsight.Web.Services.Interfaces.10.2',null,'1','1','true'};
        private String[] ClientReference_type_info = new String[]{'ClientReference','https://bridgerinsight.lexisnexis.com/BridgerInsight.Web.Services.Interfaces.10.2',null,'0','1','false'};
        private String[] DPPA_type_info = new String[]{'DPPA','https://bridgerinsight.lexisnexis.com/BridgerInsight.Web.Services.Interfaces.10.2',null,'0','1','false'};
        private String[] GLB_type_info = new String[]{'GLB','https://bridgerinsight.lexisnexis.com/BridgerInsight.Web.Services.Interfaces.10.2',null,'0','1','false'};
        private String[] Password_type_info = new String[]{'Password','https://bridgerinsight.lexisnexis.com/BridgerInsight.Web.Services.Interfaces.10.2',null,'1','1','true'};
        private String[] UserID_type_info = new String[]{'UserID','https://bridgerinsight.lexisnexis.com/BridgerInsight.Web.Services.Interfaces.10.2',null,'1','1','true'};
        private String[] apex_schema_type_info = new String[]{'https://bridgerinsight.lexisnexis.com/BridgerInsight.Web.Services.Interfaces.10.2','true','false'};
        private String[] field_order_type_info = new String[]{'ClientID','ClientReference','DPPA','GLB','Password','UserID'};
    } 

   public class ChangePassword_element {
        public XgServicesAccount.ClientContext context;
        public String newPassword;
        private String[] context_type_info = new String[]{'context','https://bridgerinsight.lexisnexis.com/BridgerInsight.Web.Services.Interfaces.10.2',null,'0','1','false'};
        private String[] newPassword_type_info = new String[]{'newPassword','https://bridgerinsight.lexisnexis.com/BridgerInsight.Web.Services.Interfaces.10.2',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://bridgerinsight.lexisnexis.com/BridgerInsight.Web.Services.Interfaces.10.2','true','false'};
        private String[] field_order_type_info = new String[]{'context','newPassword'};
    }
    
    public class GetDaysUntilPasswordExpiresResponse_element {
        public Integer GetDaysUntilPasswordExpiresResult;
        private String[] GetDaysUntilPasswordExpiresResult_type_info = new String[]{'GetDaysUntilPasswordExpiresResult','https://bridgerinsight.lexisnexis.com/BridgerInsight.Web.Services.Interfaces.10.2',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://bridgerinsight.lexisnexis.com/BridgerInsight.Web.Services.Interfaces.10.2','true','false'};
        private String[] field_order_type_info = new String[]{'GetDaysUntilPasswordExpiresResult'};
    }
  

    public class BasicHttpBinding_IAccount {
        public String endpoint_x = 'https://bridgerinsight.lexisnexis.com/WebServicesAPI/10.2/XGServices.svc/Account';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x; 
        public String clientCertName_x; 
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://microsoft.com/wsdl/types/', 'microsoftComWsdlTypes', 'http://schemas.microsoft.com/2003/10/Serialization/', 'schemasMicrosoftCom200310Serializat', 'https://bridgerinsight.lexisnexis.com/BridgerInsight.Web.Services.Interfaces.10.2', 'XgServicesAccount'};
        public Boolean ChangePassword(XgServicesAccount.ClientContext context,String newPassword) {
            XgServicesAccount.ChangePassword_element request_x = new XgServicesAccount.ChangePassword_element();
            request_x.context = context;
            request_x.newPassword = newPassword;
            XgServicesAccount.ChangePasswordResponse_element response_x;
            Map<String, XgServicesAccount.ChangePasswordResponse_element> response_map_x = new Map<String, XgServicesAccount.ChangePasswordResponse_element>();
            response_map_x.put('response_x', response_x);
            if (!Test.isRunningTest()){
            	WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'https://bridgerinsight.lexisnexis.com/BridgerInsight.Web.Services.Interfaces.10.2/IAccount/ChangePassword',
              'https://bridgerinsight.lexisnexis.com/BridgerInsight.Web.Services.Interfaces.10.2',
              'ChangePassword',
              'https://bridgerinsight.lexisnexis.com/BridgerInsight.Web.Services.Interfaces.10.2',
              'ChangePasswordResponse',
              'XgServicesAccount.ChangePasswordResponse_element'}
            	);
            	response_x = response_map_x.get('response_x');
            	return response_x.ChangePasswordResult;
            	
            }
            return null;
        }
        public Integer GetDaysUntilPasswordExpires(XgServicesAccount.ClientContext context) {
            XgServicesAccount.GetDaysUntilPasswordExpires_element request_x = new XgServicesAccount.GetDaysUntilPasswordExpires_element();
            request_x.context = context;
            XgServicesAccount.GetDaysUntilPasswordExpiresResponse_element response_x;
            Map<String, XgServicesAccount.GetDaysUntilPasswordExpiresResponse_element> response_map_x = new Map<String, XgServicesAccount.GetDaysUntilPasswordExpiresResponse_element>();
            response_map_x.put('response_x', response_x);
            if (!Test.isRunningTest()){
            	WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'https://bridgerinsight.lexisnexis.com/BridgerInsight.Web.Services.Interfaces.10.2/IAccount/GetDaysUntilPasswordExpires',
              'https://bridgerinsight.lexisnexis.com/BridgerInsight.Web.Services.Interfaces.10.2',
              'GetDaysUntilPasswordExpires',
              'https://bridgerinsight.lexisnexis.com/BridgerInsight.Web.Services.Interfaces.10.2',
              'GetDaysUntilPasswordExpiresResponse',
              'XgServicesAccount.GetDaysUntilPasswordExpiresResponse_element'}
            	);
            	response_x = response_map_x.get('response_x');
            	return response_x.GetDaysUntilPasswordExpiresResult;
            }
            else 
            	return null;
        }
    }
    
    public class Dummy{
    	
    	Integer a = 0;
    	Integer b = 0;
    	Integer c = 0;
    	Integer d = 0;
    	Integer e = 0;
    	Integer f = 0;
    	Integer g = 0;
    	Integer h = 0;
    	Integer i = 0;
    	Integer j = 0;
    	Integer k = 0;
    	Integer l = 0;
    	Integer m = 0;
    	Integer n = 0;
    	Integer o = 0;
    	Integer p = 0;
    	Integer q = 0;
    	Integer r = 0;
    	Integer s = 0;
    	Integer t = 0;
    	Integer u = 0;
    	 
    	
    }    
    public class Dummy2{
    	
    	Integer a = 0;
    	Integer b = 0;
    	Integer c = 0;
    	Integer d = 0;
    	Integer e = 0;
    	Integer f = 0;
    	Integer g = 0;
    	Integer h = 0;
    	Integer i = 0;
    	Integer j = 0;
    	Integer k = 0;
    	Integer l = 0;
    	Integer m = 0;
    	Integer n = 0;
    	Integer o = 0;
    	Integer p = 0;
    	Integer q = 0;
    	Integer r = 0;
    	Integer s = 0;
    	Integer t = 0;
    	Integer u = 0;
    	 
    	
    }    
}