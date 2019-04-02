@isTest
public class TestDummy_EmailHandler {

    public static testMethod void TestDummy_EmailHandler(){
        
        
        // Create a new email, envelope object and Attachment
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        


        email.subject =  'Credit Approval for COUNTRY DAY SCHOOL AT OVERBROOK FOUNDATION INC (application # FTW-118886-)';
        email.fromName = 'test test';
        email.plainTextBody = 'Thank you for submitting your credit application.|Approval|COUNTRY DAY SCHOOL AT OVERBROOK FOUNDATION';
        envelope.fromAddress = 'user@acme.com';
        


        // setup controller object
        Dummy_EmailHandler catcher = new Dummy_EmailHandler();
        Messaging.InboundEmailResult result = catcher.handleInboundEmail(email, envelope);
        
           
    }
}