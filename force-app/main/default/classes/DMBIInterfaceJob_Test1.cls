@isTest public class DMBIInterfaceJob_Test1 {
    @isTest Public static  void ValidateDMBIInterfaceJob1(){
        //Create Contract Test Data
        list<cllease__Lease_Account__c> LeaseContractList = new list<cllease__Lease_Account__c>();//DMBIInterfaceJobDataFactory.createLeaseContract(5);
        LeaseContractList.add(TestHelper.createContract());
        System.Debug('LeaseContactList.Size -->' +LeaseContractList.Size());
        System.Assert(LeaseContractList.Size() > 0);
        //Check for Agreement Object Record Creation 
        Test.startTest();
        DMBIInterfaceJob DIJ = new DMBIInterfaceJob();
        DataBase.executeBatch(DIJ,50);
        Test.stopTest();
        List<int_agreement__c> agr = [Select Id From int_agreement__c];
        System.Debug('agr.size -->' +agr.size());
        System.Assert(agr.size() > 0);   
    }
}