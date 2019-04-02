@isTest
private class CongaRequestTest
{
	 public class CongaRequestTestGenerateAccessTokenControllermock implements HttpCalloutMock 
 {
        public HTTPResponse respond(HTTPRequest req)
        {         
	        HttpResponse resp = new HttpResponse();
	        resp.setStatusCode(200);
	        resp.setStatus('OK');       
	     //  resp.setendpoint('https://login.salesforce.com/services/oauth2/token');
	        resp.setBody('{"access_token":"00D280000018Hvv!ARgAQBj17OZhZ95TxwWrpGA93KXT3Jt4sMigISu7EohyBKY.cDC5L4E6PKbsIQ4cBRJD8FXmyrRuxpIOSOY8jZjHAX7KzUUB","instance_url":"https://ap2.salesforce.com","id":"https://login.salesforce.com/id/00D280000018HvvEAE/00528000001kQShAAM","token_type":"Bearer","issued_at":"1484826597893","signature":"Fi7S9LKkcQy7W84CtIME4IjJCQtWhg3NQ1TFx4KAawc="}');

	        return resp;
	    }
	}
	public class CongaRequestTestGenerateAccessTokenControllermock1 implements HttpCalloutMock 
 {
        public HTTPResponse respond(HTTPRequest req)
        {         
	        HttpResponse resp = new HttpResponse();
	        resp.setStatusCode(200);
	        resp.setStatus('OK');       
	     //  resp.setendpoint('https://login.salesforce.com/services/oauth2/token');
	        resp.setBody('done');

	        return resp;
	    }
	}

	 public class CongaRequestTestGenerateAccessTokenControllermock2 implements HttpCalloutMock 
	 {
	        public HTTPResponse respond(HTTPRequest req)
	        {         
		        HttpResponse resp = new HttpResponse();
		        resp.setStatusCode(400);
		        resp.setStatus('OK');       
		     //  resp.setendpoint('https://login.salesforce.com/services/oauth2/token');
		        resp.setBody('done');

		        return resp;
		    }
		}

    Static testmethod void CongaRequestTestGenerateAccessTokenController_Test()
    {
    	//Connected_App_Details__c app = Connected_App_Details__c.getOrgDefaults();
    	test.starttest();
	    	Test.setMock(HttpCalloutMock.class, new CongaRequestTestGenerateAccessTokenControllermock()); 
	    	CongaRequest.CL_GenerateAccessToken();
    	test.stoptest();
    }
    Static testmethod void CongaRequestTestGenerateAccessTokenController_Test1()
    {
    	//Connected_App_Details__c app = Connected_App_Details__c.getOrgDefaults();
    	test.starttest();
	    	//Test.setMock(HttpCalloutMock.class, new CongaRequestTestGenerateAccessTokenControllermock()); 
	    	CongaRequest.CL_GenerateAccessToken();
    	test.stoptest();
    }
    Static testmethod void CongaRequestTestGenerateAccessTokenController_Test2()
    {
    	//Connected_App_Details__c app = Connected_App_Details__c.getOrgDefaults();
    	test.starttest();
	    	Test.setMock(HttpCalloutMock.class, new CongaRequestTestGenerateAccessTokenControllermock1()); 
	    	CongaRequest.FinalNoticeLetterRequest('kljkljljiojiojt','suhas@gmail.com','00D280000018Hvv!ARgAQBj17OZhZ95TxwWrpGA93KXT3Jt4sMigISu7EohyBKY','venkata@Cloudlendinginc.com');
    	test.stoptest();
    }
    Static testmethod void CongaRequestTestGenerateAccessTokenController_Test3()
    {
    	//Connected_App_Details__c app = Connected_App_Details__c.getOrgDefaults();
    	test.starttest();
	    	Test.setMock(HttpCalloutMock.class, new CongaRequestTestGenerateAccessTokenControllermock2()); 
	    	CongaRequest.FinalNoticeLetterRequest('kljkljljiojiojt','suhas@gmail.com','00D280000018Hvv!ARgAQBj17OZhZ95TxwWrpGA93KXT3Jt4sMigISu7EohyBKY','venkata@Cloudlendinginc.com');
    	test.stoptest();
    }
    Static testmethod void CongaRequestTestGenerateAccessTokenController_Test4()
    {
    	//Connected_App_Details__c app = Connected_App_Details__c.getOrgDefaults();
    	test.starttest();
	    	//Test.setMock(HttpCalloutMock.class, new CongaRequestTestGenerateAccessTokenControllermock2()); 
	    	CongaRequest.FinalNoticeLetterRequest('kljkljljiojiojt','suhas@gmail.com','00D280000018Hvv!ARgAQBj17OZhZ95TxwWrpGA93KXT3Jt4sMigISu7EohyBKY','venkata@Cloudlendinginc.com');
    	test.stoptest();
    }

}