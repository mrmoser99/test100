@isTest
private class FinalNoticeLetterJobTest
{
   /* @testSetup static void setup(){
        cllease__Lease_Account__c LSContract = TestHelper.createContract();
        system.debug('Contact ID::::'+LSContract.id);
        cllease__Lease_Account__c ls = [select id,name,cllease__Account__r.id from cllease__Lease_Account__c where id=:LSContract.id];
        system.debug('Accout ID::::'+ls.cllease__Account__r.id);

        Account ac = new Account();
        ac.id                           = ls.cllease__Account__r.id;
        ac.BillingState                 = 'PA';
        //acc.Billing.Email_Address__c    = 'venkata.suhas123@cloudlendinginc.com'
        update ac;

        Address__c ad       = new Address__c();
        ad.Account__c       = ls.cllease__Account__r.id;
        ad.Bill_To_Usage__c = true;
        ad.Email_Address__c = 'venkata.suhas123@cloudlendinginc.com';
        insert ad;

        cllease__Lease_Account__c leac = new cllease__Lease_Account__c();
        leac.id                                  = LSContract.id;
        leac.cllease__Lease_Status__c            = 'ACTIVE - BAD STANDING';
        leac.cllease__Days_Past_Due__c           = 91;
        leac.Final_Notice_Letter_Sent__c         = false;
        leac.Billing_Address__c                  = ad.id;
        Update leac;
        
        Account acDealer = new Account();
        acDealer.Name             = 'venkat@1 Suhas';
        acDealer.Email_Address__c = 'venkata@Cloudlendinginc.com';
        insert acDealer;

        cllease__Contract_Parties__c parties   = new cllease__Contract_Parties__c();
        parties.cllease__Contract__c           = LSContract.id;
        parties.cllease__Party_Account_Name__c = acDealer.id;
        parties.cllease__Party_Type__c         =  'DEALER';
        insert parties;
    }
    public class MockHttpFinalNoticeGenerator implements HttpCalloutMock {
     public HTTPResponse respond(HTTPRequest req)
        {         
          HttpResponse resp = new HttpResponse();
          resp.setStatusCode(200);
          resp.setStatus('OK');       
          resp.setBody('{"access_token":"00D280000018Hvv!ARgAQBj17OZhZ95TxwWrpGA93KXT3Jt4sMigISu7EohyBKY.cDC5L4E6PKbsIQ4cBRJD8FXmyrRuxpIOSOY8jZjHAX7KzUUB","instance_url":"https://ap2.salesforce.com","id":"https://login.salesforce.com/id/00D280000018HvvEAE/00528000001kQShAAM","token_type":"Bearer","issued_at":"1484826597893","signature":"Fi7S9LKkcQy7W84CtIME4IjJCQtWhg3NQ1TFx4KAawc="}');

          return resp;
      }
  
    }
    public class CL_FinalNoticeLetter_Mock implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req)
        { 
             HttpResponse resp = new HttpResponse();
              resp.setStatusCode(200);
              resp.setStatus('OK');       
              resp.setBody('done');        
            return resp;
      }
    }
    public class CL_FinalNoticeLetter_Mock1 implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req)
        { 
             HttpResponse resp = new HttpResponse();
              resp.setStatusCode(200);
              resp.setStatus('OK');       
              resp.setBody('error: Failed to get the authorization.');        
            return resp;
      }
    } 
    public class CL_FinalNoticeLetter_Mock2 implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req)
        { 
             HttpResponse resp = new HttpResponse();
              resp.setStatusCode(200);
              resp.setStatus('OK');       
              resp.setBody('error: Failed');        
            return resp;
      }
    } 
    @isTest
    static void FinalNoticeLetterJob()
    {
            Test.startTest();
                Database.QueryLocator QL;
                Database.BatchableContext BC;
                List<cllease__Lease_Account__c> AcctList = new List<cllease__Lease_Account__c>();
                FinalNoticeLetterJob ER = new FinalNoticeLetterJob();
                QL = ER.start(bc);
                
                
                Database.QueryLocatorIterator QIT =  QL.iterator();
                System.debug('Query Locator'+QIT);
                while (QIT.hasNext())
                {
                    cllease__Lease_Account__c Lacc = (cllease__Lease_Account__c)QIT.next();           
                    System.debug('Loan Accounts'+Lacc);
                    AcctList.add(Lacc);
                }  
                
                system.debug('List of loan accounts '+AcctList);     
              
                Test.setMock(HttpCalloutMock.class, new MockHttpFinalNoticeGenerator());
                CongaRequest.CL_GenerateAccessToken();
                Test.setMock(HttpCalloutMock.class, new CL_FinalNoticeLetter_Mock1());
                CongaRequest.FinalNoticeLetterRequest('kljkljljiojiojt','suhas@gmail.com','00D280000018Hvv!ARgAQBj17OZhZ95TxwWrpGA93KXT3Jt4sMigISu7EohyBKY','venkata@Cloudlendinginc.com');
                Test.setMock(HttpCalloutMock.class, new CL_FinalNoticeLetter_Mock());
                CongaRequest.FinalNoticeLetterRequest('kljkljljiojiojt','suhas@gmail.com','00D280000018Hvv!ARgAQBj17OZhZ95TxwWrpGA93KXT3Jt4sMigISu7EohyBKY','venkata@Cloudlendinginc.com');
                
                ER.execute(BC, AcctList);
                ER.finish(BC);
            Test.stopTest();   
    }

    @isTest
    static void FinalNoticeLetterJob1()
    {
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new MockHttpFinalNoticeGenerator());
                CongaRequest.CL_GenerateAccessToken();
                Test.setMock(HttpCalloutMock.class, new CL_FinalNoticeLetter_Mock1());
                CongaRequest.FinalNoticeLetterRequest('kljkljljiojiojt','suhas@gmail.com','00D280000018Hvv!ARgAQBj17OZhZ95TxwWrpGA93KXT3Jt4sMigISu7EohyBKY','venkata@Cloudlendinginc.com');
                FinalNoticeLetterJob f1 = new FinalNoticeLetterJob(); 
                DataBase.executeBatch(f1); 
            Test.stopTest();   
    }
    @isTest
    static void FinalNoticeLetterJob2()
    {
           
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new MockHttpFinalNoticeGenerator());
                CongaRequest.CL_GenerateAccessToken();
                Test.setMock(HttpCalloutMock.class, new CL_FinalNoticeLetter_Mock2());
                CongaRequest.FinalNoticeLetterRequest('kljkljljiojiojt','suhas@gmail.com','00D280000018Hvv!ARgAQBj17OZhZ95TxwWrpGA93KXT3Jt4sMigISu7EohyBKY','venkata@Cloudlendinginc.com');
                FinalNoticeLetterJob f1 = new FinalNoticeLetterJob();
                f1.errorLog.put('test','test'); 
                DataBase.executeBatch(f1); 
            Test.stopTest();    
    }
    @isTest
    static void FinalNoticeLetterJob3()
    {
           
            Test.startTest();
              try{
                Test.setMock(HttpCalloutMock.class, new MockHttpFinalNoticeGenerator());
                CongaRequest.CL_GenerateAccessToken();
                Test.setMock(HttpCalloutMock.class, new CL_FinalNoticeLetter_Mock2());
                CongaRequest.FinalNoticeLetterRequest('kljkljljiojiojt','suhas@gmail.com','00D280000018Hvv!ARgAQBj17OZhZ95TxwWrpGA93KXT3Jt4sMigISu7EohyBKY','venkata@Cloudlendinginc.com');
                List<cllease__Lease_Account__c> contractlist = [select id,name,cllease__Account__r.BillingState from cllease__Lease_Account__c where cllease__Account__r.BillingState = 'PA'];
                List<string> s2 = new list<string>();
                s2.add(contractlist[0].name);
                FinalNoticeLetterJob f1 = new FinalNoticeLetterJob(s2);
                f1.errorLog.put('test','test'); 
                DataBase.executeBatch(f1);
                }
                catch(exception e){
                    System.debug('***exception ***'+e);
                } 
            Test.stopTest();    
    }
    @isTest
    static void FinalNoticeLetterJob4()
    {
           
            Test.startTest();
              try{
                Test.setMock(HttpCalloutMock.class, new CL_FinalNoticeLetter_Mock1());
                CongaRequest.FinalNoticeLetterRequest('kljkljljiojiojt','suhas@gmail.com','00D280000018Hvv!ARgAQBj17OZhZ95TxwWrpGA93KXT3Jt4sMigISu7EohyBKY','venkata@Cloudlendinginc.com');
                Test.setMock(HttpCalloutMock.class, new CL_FinalNoticeLetter_Mock2());
                CongaRequest.FinalNoticeLetterRequest('kljkljljiojiojt','suhas@gmail.com','00D280000018Hvv!ARgAQBj17OZhZ95TxwWrpGA93KXT3Jt4sMigISu7EohyBKY','venkata@Cloudlendinginc.com');
                List<cllease__Lease_Account__c> contractlist = [select id,name,cllease__Account__r.BillingState from cllease__Lease_Account__c where cllease__Account__r.BillingState = 'PA'];
                List<string> s3 = new list<string>();
                s3.add(contractlist[0].name);
                FinalNoticeLetterJob f1 = new FinalNoticeLetterJob(s3);
                f1.errorLog.put('test','test'); 
                DataBase.executeBatch(f1);
                }
                catch(exception e){
                    System.debug('***exception ***'+e);
                } 
            Test.stopTest();    
    }
    @isTest
    static void FinalNoticeLetterJob5()
    {
           
            Test.startTest();
               Account a = [select id,name from Account where name = 'venkat@1 Suhas' Limit 1];
               cllease__Contract_Parties__c part = [SELECT id,name,cllease__Party_Account_Name__c from cllease__Contract_Parties__c Where cllease__Party_Account_Name__c =:a.id];
               Delete part;
                CongaRequest.CL_GenerateAccessToken();
                CongaRequest.FinalNoticeLetterRequest('kljkljljiojiojt','suhas@gmail.com','00D280000018Hvv!ARgAQBj17OZhZ95TxwWrpGA93KXT3Jt4sMigISu7EohyBKY','venkata@Cloudlendinginc.com');
                FinalNoticeLetterJob f1 = new FinalNoticeLetterJob();
                DataBase.executeBatch(f1);
            Test.stopTest();    
    }*/
}