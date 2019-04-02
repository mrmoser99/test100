@isTest
public class TestATSemail {

    public static testMethod void TestATSemail(){
        
        Account test_acc = genesis.TestHelper.createAccount();
    
        genesis__Quick_Quotes__c qq = new genesis__Quick_Quotes__c(Dealer__c=test_acc.id, genesis__Business_Name__c='test business name',genesis__Address_Line_1__c='test street name',genesis__City__c='Orlando',genesis__State__c='FL',genesis__Postal_Code__c='123456',Estimated_Financed_Amount__c='10000',genesis__Status__c='NEW');
    
        insert qq;   
        
        string quote_number = [select id,name from genesis__Quick_Quotes__c where id=:qq.id].name;
        
        // Create a new email, envelope object and Attachment
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        


        email.subject =  'Credit Approval for COUNTRY DAY SCHOOL AT OVERBROOK FOUNDATION INC (application # FTW-118886-)';
        email.fromName = 'test test';
        email.plainTextBody = 'Thank you for submitting your credit application.|Approval|COUNTRY DAY SCHOOL AT OVERBROOK FOUNDATION INC|'+quote_number+'|FTW-118886-|';
        Messaging.InboundEmail.BinaryAttachment[] binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[1];  
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.Filename = 'test.txt';
        String algorithmName = 'HMacSHA1';
        Blob b = Crypto.generateMac(algorithmName, Blob.valueOf('test'),
        Blob.valueOf('test_key'));
        binaryAttachment.Body = b;
        binaryAttachments[0] =  binaryAttachment ;
        email.binaryAttachments = binaryAttachments ;
        envelope.fromAddress = 'user@acme.com';
        


        // setup controller object
        ProcessCreditApprovalResponse catcher = new ProcessCreditApprovalResponse();
        Messaging.InboundEmailResult result = catcher.handleInboundEmail(email, envelope);
        
        email.plainTextBody = 'Thank you for submitting your credit application.|Declined|COUNTRY DAY SCHOOL AT OVERBROOK FOUNDATION INC|'+quote_number+'|FTW-118886-|';
        qq.genesis__Status__c = 'CREDIT SUBMITTED';
        update qq;
        ProcessCreditApprovalResponse catcher2 = new ProcessCreditApprovalResponse();
        Messaging.InboundEmailResult result2 = catcher2.handleInboundEmail(email, envelope);


    
    }
}