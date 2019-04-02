@isTest
public class ContractTerminationControllerTest {
    
    public static TestMethod void Testmethod1() {
         cllease__Lease_Account__c LSContract = TestHelper.createContract();
          
         cllease__Termination_Quote_Header__c tqh = new cllease__Termination_Quote_Header__c();
         tqh.cllease__Contract__c = LSContract.Id;
         insert tqh;
         cllease__Payment_Mode__c pm = new cllease__Payment_Mode__c();
         pm.name = 'TERMINATION';
         insert pm;
         set<id> Conrollqids = new set<id>();
         Conrollqids.add(tqh.id);
         System.Test.startTest();    
           ContractTerminationController.contractTermination(Conrollqids);        
         System.Test.stopTest(); 
         
    }
    
}