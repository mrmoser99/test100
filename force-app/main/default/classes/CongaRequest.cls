global Class CongaRequest{

public static List<cllease__Lease_Account__c> leaselist = new List<cllease__Lease_Account__c>();
public static string version = '/services/Soap/u/42.0/';
public static string partnerUrl = Url.getSalesforceBaseUrl().toExternalForm() + version + UserInfo.getOrganizationId().subString(0, 15);

public static string CL_GenerateAccessToken(){
  string access; 
   try{ 
        Connected_App_Details__c app = Connected_App_Details__c.getOrgDefaults();
        String clientId     =  app.Client_Id__c;
        String clientSecret =  app.Client_Secret__c;
        String username     =  app.User_Name__c;
        String password     =  app.Password__c;
        String URL          =  app.Url__c;
        
        String reqbody = 'grant_type=password&client_id='+clientId+'&client_secret='+clientSecret+'&username='+username+'&password='+password;
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setBody(reqbody);
        req.setMethod('POST');
        req.setEndpoint(URL+'/services/oauth2/token');
        req.setTimeout(120000);
        HttpResponse res = h.send(req);
        system.debug('====body====='+res.getbody());
        OAuth2 objAuthenticationInfo =new OAuth2 ();
        objAuthenticationInfo = (OAuth2)JSON.deserialize(res.getbody(), OAuth2.class);
        System.debug('***access token **** '+objAuthenticationInfo.access_token);
        access = objAuthenticationInfo.access_token;
        System.debug('**access***'+access);
         
      }
      catch(exception e){
        cllease__Batch_Process_Log__c l = new cllease__Batch_Process_Log__c();
         l.Name='FinalNoticeLetter';
         l.cllease__Date__c = System.today();
         l.cllease__Message__c = 'Error is '+e.getmessage()+' in line number: '+ e.getlinenumber();
         insert l;
      }
      return  access;
}    

Public class OAuth2{
  Public String access_token;
}

public static HttpResponse FinalNoticeLetterRequest(string leaseid,string Email,String session, String DealerEmail){
HttpResponse res = new HttpResponse();
System.debug('***'+leaseid+'****'+'******'+Email+'********'+session+'********'+DealerEmail+'*********');
try{
    string str = '[EquipmentQuery]'+Label.ContractEquipmentQueryDetails;
    System.debug('***'+str);
    string fromID = Label.FromID;
    String congaEmailTemplate = Label.FinalLetterCongaEmailTemplate;
    String congaTemplate = Label.FinalLetterCongaTemplate;
    
            string CongUrl = 'https://composer.congamerge.com/composer8/index.html?SolMgr=1'+
                                            '&APIMode=12'+                         
                                            '&sessionId='+session+
                                            '&serverUrl='+partnerUrl+
                                            '&EmailSubject=Final+Notice+Letter+for'+
                                            '&EmailAdditionalTo='+Email+
                                            '&EmailCC='+DealerEmail+
                                            '&EmailFromId='+fromID+
                                            '&QueryId='+str+
                                            '&CongaEmailTemplateId='+congaEmailTemplate+
                                            '&id='+leaseid+
                                            '&DefaultPDF=1'+
                                            '&DS7=12'+
                                            '&TemplateId='+Label.FinalLetterCongaTemplate;
            Http h = new  Http();
            // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
            HttpRequest req = new  HttpRequest();
            req.setEndpoint(CongUrl);
            req.setMethod('GET');
            req.setTimeout(60000);
            // Send the request, and return a response  
            res = h.send(req);
            System.debug('*****'+res.getbody()+'******'+res.getStatusCode()+'********'+res.getStatus());
            if(res.getStatusCode() != 200){
                System.debug('******'+res.getStatus());
                return res;
            }
            else If(res.getStatusCode() == 200){
                System.debug('********Document Created successfully!!'+res.getStatusCode());
                            System.debug('*******resbody******* '+res.getBody());
                return res;
            }
            else{
                return res;
            }
     } 
     catch(exception e){
         cllease__Batch_Process_Log__c l = new cllease__Batch_Process_Log__c();
         l.Name='FinalNoticeLetterJob';
         l.cllease__Date__c = System.today();
         l.cllease__Message__c = 'Error is '+e.getmessage()+' in line number: '+ e.getlinenumber();
         insert l;
     }
     return res;   
   }
}