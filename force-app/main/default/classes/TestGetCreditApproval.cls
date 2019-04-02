@isTest
public class TestGetCreditApproval implements HttpCalloutMock {
     public HTTPResponse respond(HTTPRequest req)
        {         
          HttpResponse res = new HttpResponse();
          res.setStatusCode(200);
            String accessToken = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJbaW52YWxpZCBmaWVsZF0iLCJzY3AiOiJjcmVhdGVfYW5kX21hbmFnZV9maW5hbmNpYWxfY29udHJhY3RzIiwidmVyIjoiMS4wIiwiaXNzIjoiZXh0ZXJuYWxnYXRld2F5LmRsbC5jb3JwIiwib2lkIjoiW2ludmFsaWQgZmllbGRdIiwiZ2l2ZW5fbmFtZSI6Ik5vIExEQVAiLCJ0aWQiOiJbaW52YWxpZCBmaWVsZF0iLCJhdWQiOiJbaW52YWxpZCBmaWVsZF0iLCJhY3IiOiIxIiwidXBuIjoiTm8gTERBUCIsInVuaXF1ZV9uYW1lIjoiTm8gTERBUCIsIm5iZiI6MTUxODM1MTA1MywiYXBwaWRhY3IiOiIwIiwiYXBwaWQiOiJkYWJiNzAyZC1jNTlhLTQ5YTMtOTMwZi1iZjc1Zjg5NWYwYjQiLCJleHAiOjE1MTg5NTU4NTMsImlhdCI6MTUxODM1MTA1MywiZmFtaWx5X25hbWUiOiJObyBMREFQIn0.erqVtqqUdzIfnwBAJ_b-eYzun0ahJCCtM3NAwJV_bv5Yd1qP7lhSMsDxVtPupGYGfLgc0DlyIAJrRaMlJ1OxSTL1SbNoJZjeF0Z-W60JywnjdGsPP-mg-ARyPN0jKL0whcehfE6PjAkEfjW8_HkzFAZ6qn1ls-rhTvmyQQIto-hJcZ7VQAyQs8k6YjYIw42iEB-TBDzjuPiYV5_dftEDMdCr5apCUZoZAaOWGg6Y-7NZoahWEcVASvQtW7QkrOGGrhAp9ZXLoKBav-GLJWUDP-gfyxzl7hqAhzZQgTWtHw9xvE-a_s6i-5NAoJeTwRbG3NuB0blsvD9Q9noc0FDLhw';
                String refreshToken = '3pd4KvkxkV51l5T9lCQGDlJnqsstack8M8oItEZFUK6p5y';
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"access_token": '+ accessToken +
                ',"token_type": "Bearer", "expires_in": "604800","expires_on": "1518955853","resource": "DLL corp","refresh_token": '+
                refreshToken +'}');
                res.setStatusCode(200);

          return res;
      }
  


     static  TestMethod void creditApproval()
    {
         RecordType lessee = [SELECT ID FROM RecordType wHERE DeveloperName = 'Lessee'AND SobjectType = 'Account'AND IsActive = true limit 1];                                    
        //RecordType lessee1 = [SELECT ID FROM RecordType WHERE DeveloperName = 'Lessee'AND SobjectType = 'Address__c'AND IsActive = true limit 1]; 
        //clcommon__Legal_Entity__c corp = [SELECT ID FROM clcommon__Legal_Entity__c WHERE Name = 'Corporation' limit 1];
        
        Account a = new Account(name='Talentica');
        //a.clcommonportal__Legal_Entity_Type__c=corp.id;
        a.RecordTypeId=lessee.id;
        insert a;
        
        Address__c address = new Address__c();
        address.Account__c = a.Id;
        address.Country__c = 'USA';
        address.Bill_To_Usage__c = true;
        address.Install_At__c = true;
        insert address;
      
        List<RecordType> rtypes = [Select Name,Id From RecordType where isActive=true and sObjectType='genesis__Loan_Product__c' ];
        Map<String,String> productRecordTypes = new Map<String,String>{};
        for(RecordType rt: rtypes)
            productRecordTypes.put(rt.Name,rt.Id);
        genesis__Loan_Product__c prod = new genesis__Loan_Product__c(recordtypeid = productRecordTypes.get('Lease Product Record Type'));
        prod.RecordTypeId = productRecordTypes.get('Lease Product Record Type');
        prod.Name = 'DEMO LEASE PRODUCT';
        insert prod;
        
            ATS_Integration_setup__c cust=new ATS_Integration_setup__c();
            cust.Client_ID__c='dabb702d-c59a-49a3-930f-bf75f895f0b4';
            cust.Client_Secret__c='c341f95c-ec3c-4cf8-9935-8d68a5765ccc';
            cust.Email_service_alias__c='newco-creditDecision-dev@dllgroup.com';
            cust.Endpoint_for_ATS_call__c='https://api.dllgroup.com/americas/v1/application/';
            cust.Endpoint_for_Token__c='https://api.dllgroup.com/oauth/token';
            cust.Sandbox_Name__c='dev';
            cust.Scope_for_token_call__c='create_and_manage_financial_contracts';
            insert cust;

        
        
        
        genesis__Quick_Quotes__c q= new genesis__Quick_Quotes__c();
            q.Dealer__c=a.id;
            q.genesis__Lending_Product__c=prod.id;
            q.genesis__Collateral_Value__c=100;
            q.genesis__Estimated_Selling_Price__c=100;
            q.genesis__Expected_Start_Date__c=Date.today();
            q.genesis__Source__c='DIRECT';
            q.genesis__Payment_Frequency__c='MONTHLY';
            q.genesis__Account__c=a.id;
            q.Estimated_Financed_Amount__c='10000';
            insert q;
        System.Test.startTest();
        GetCreditApproval.func_getcreditapproval(q);
        System.Test.stopTest();
    }
     static  TestMethod void creditApproval1()
    {
         RecordType lessee = [SELECT ID FROM RecordType wHERE DeveloperName = 'Lessee'AND SobjectType = 'Account'AND IsActive = true limit 1];                                    
        //RecordType lessee1 = [SELECT ID FROM RecordType WHERE DeveloperName = 'Lessee'AND SobjectType = 'Address__c'AND IsActive = true limit 1]; 
        //clcommon__Legal_Entity__c corp = [SELECT ID FROM clcommon__Legal_Entity__c WHERE Name = 'Corporation' limit 1];
        
        Account a = new Account(name='Talentica');
        //a.clcommonportal__Legal_Entity_Type__c=corp.id;
        a.RecordTypeId=lessee.id;
        insert a;
        
        Address__c address = new Address__c();
        address.Account__c = a.Id;
        address.Country__c = 'USA';
        address.Bill_To_Usage__c = true;
        address.Install_At__c = true;
        insert address;
      
        List<RecordType> rtypes = [Select Name,Id From RecordType where isActive=true and sObjectType='genesis__Loan_Product__c' ];
        Map<String,String> productRecordTypes = new Map<String,String>{};
        for(RecordType rt: rtypes)
            productRecordTypes.put(rt.Name,rt.Id);
        genesis__Loan_Product__c prod = new genesis__Loan_Product__c(recordtypeid = productRecordTypes.get('Lease Product Record Type'));
        prod.RecordTypeId = productRecordTypes.get('Lease Product Record Type');
        prod.Name = 'DEMO LEASE PRODUCT';
        insert prod;
        
            ATS_Integration_setup__c cust=new ATS_Integration_setup__c();
            cust.Client_ID__c='dabb702d-c59a-49a3-930f-bf75f895f0b4';
            cust.Client_Secret__c='c341f95c-ec3c-4cf8-9935-8d68a5765ccc';
            cust.Email_service_alias__c='newco-creditDecision-dev@dllgroup.com';
            cust.Endpoint_for_ATS_call__c='https://api.dllgroup.com/americas/v1/application/';
            cust.Endpoint_for_Token__c='https://api.dllgroup.com/oauth/token';
            cust.Sandbox_Name__c='dev';
            cust.Scope_for_token_call__c='create_and_manage_financial_contracts';
            insert cust;
            genesis__Quick_Quotes__c q= new genesis__Quick_Quotes__c();
            q.Dealer__c=a.id;
            q.genesis__Lending_Product__c=prod.id;
            q.genesis__Collateral_Value__c=100;
            q.genesis__Estimated_Selling_Price__c=100;
            q.genesis__Expected_Start_Date__c=Date.today();
            q.genesis__Source__c='DIRECT';
            q.genesis__Payment_Frequency__c='MONTHLY';
            q.genesis__Account__c=a.id;
            q.Estimated_Financed_Amount__c='10000';
            insert q;
        System.Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, new TestGetCreditApproval());

        GetCreditApproval.get_token();

        System.Test.stopTest();
    }
   
}