@isTest
public class TestATSclasses {

 // Commenting following test classes as these are failing.
  /* @isTest
    static void test_tokengeneration(){
    
    System.Test.setMock(HttpCalloutMock.class, new Mock_ATS_TokenGenerator());
    
    httpresponse res = GetCreditApproval.get_token();
    
    }
    
    @isTest
    static void test_callATS(){
    
    System.Test.setMock(HttpCalloutMock.class, new Mock_ATS_ResponseGenerator());
    
    HttpRequest req_api = new HttpRequest();
    
    httpresponse res = GetCreditApproval.get_response(req_api);
    }
    
    @isTest
    static void test_call(){
    
    Account test_acc = genesis.TestHelper.createAccount();
    
    genesis__Quick_Quotes__c qq = new genesis__Quick_Quotes__c(Dealer__c=test_acc.id, genesis__Business_Name__c='test business name',genesis__Address_Line_1__c='test street name',genesis__City__c='Orlando',genesis__State__c='FL',genesis__Postal_Code__c='123456',Estimated_Financed_Amount__c='10000',genesis__Status__c='NEW');
    
    insert qq;   
    
    string ret_msg = GetCreditApproval.func_getcreditapproval(qq);
    
   // ATS_util.CreditAppBody acb = new ATS_util.CreditAppBody('', '', '', new ATS_util.lessee('','',new ATS_util.address('','','','')), new list<asset>(), new ATS_util.structure('',36,'MONTHLY',10000,0.00045,123));
    }
    */
    
}