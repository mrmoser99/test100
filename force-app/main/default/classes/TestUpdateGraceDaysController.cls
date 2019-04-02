@isTest private class TestUpdateGraceDaysController 
{ 
     
     public static string org = string.valueOf(Label.OrgUrl);
     
    static testMethod void testSave() 
    { 
     
     
         cllease__Lease_Account__c LSContract = TestHelper.createContract();
         cllease__Lease_Account__c ls = [select id,name,cllease__Account__r.id from cllease__Lease_Account__c where id=:LSContract.id];
         System.debug('****LSContract.id****'+LSContract.id);
         
         Account acDealer = new Account();
         acDealer.Name             = 'venkat@1 Suhas';
         acDealer.Email_Address__c = 'venkata@Cloudlendinginc.com';
         insert acDealer;
    
         cllease__Contract_Parties__c parties   = new cllease__Contract_Parties__c();
         parties.cllease__Contract__c           = LSContract.id;
         parties.cllease__Party_Account_Name__c = acDealer.id;
         parties.cllease__Party_Type__c         =  'DEALER';
         insert parties;
         
         cllease__Lease_Account__c cl = new cllease__Lease_Account__c();
         cl.id = LSContract.id;
         cl.Custom_Late_Charge_Grace_Days__c = '2'; 
         cl.Custom_Finance_Charge_Grace_Days__c = '3';
         cl.cllease__Dealer__c  = acDealer.id;
         Update cl; 
       
         PageReference ref = new PageReference(TestUpdateGraceDaysController.org+'/'+cl.id); 
         Test.setCurrentPage(ref);
         ApexPages.currentPage().getParameters().put('Id',LSContract.id);
         System.debug('******ref*****'+ref); 
         
         Test.startTest(); 
             //This will run the constructor of the controller 
             UpdateGraceDaysController myController = new UpdateGraceDaysController();
             //Now we can test our action function on the controller 
             PageReference ref2 = myController.saveItem();
             System.debug('****ref2*******'+ref2); 
         Test.stopTest(); 
         system.assertNotEquals(ref2, null);
    }
 //test method to CancelAction function
     static testMethod void testCancel() 
    {
      cllease__Lease_Account__c LSid = TestHelper.createContract();
      PageReference ref = new PageReference(TestUpdateGraceDaysController.org+'/'+LSid); 
      Test.setCurrentPage(ref);
      System.debug('******ref*****'+ref); 
      
      Test.startTest(); 
         //This will run the constructor of the controller 
         UpdateGraceDaysController myController = new UpdateGraceDaysController();
         //Now we can test our action function on the controller 
         PageReference ref2 = myController.cancelAction();
         System.debug('****ref2*******'+ref2); 
     Test.stopTest(); 
     system.assertNotEquals(ref2, null);  
    } 
 
 }