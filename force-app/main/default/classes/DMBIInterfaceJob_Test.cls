@isTest public class DMBIInterfaceJob_Test {
    Public static testmethod void ValidateDMBIInterfaceJob(){
        list<cllease__Lease_Account__c> LeaseContactList = new list<cllease__Lease_Account__c>();//DMBIInterfaceJobDataFactory.createLeaseContract(5);
        LeaseContactList.add(TestHelper.createContract());
        DMBIInterfaceJob DIJ = new DMBIInterfaceJob();
        DataBase.executeBatch(DIJ,50);
    }
}