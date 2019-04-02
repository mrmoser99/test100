Public class CL_GenerateAccessTokenController{
public static string CL_GenerateAccessToken(){
//Connected_App_Details__c app=Connected_App_Details__c.getOrgDefaults();
System.debug(UserInfo.getSessionID());

String clientId = '3MVG97wqanbUM37KbULPF6MovhwBIeDb9FcQAxgdEesdPb2NmhawwcU8QSQ.tIf2gX7_q0TwqnZm4_fUtYrVo';
String clientSecret = '4428767531769863683';
String username = 'mohini.gupta@cloudlendinginc.com.newcodev';
String password = 'welcome12';
String URL      = 'https://test.salesforce.com';

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
 return  objAuthenticationInfo.access_token;
}

Public class OAuth2{
 Public String access_token;
}

}