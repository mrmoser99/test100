@isTest(seealldata=true)
public  class TestExposure {

   
    static TestMethod void Test1() {
    
        List<cllease__Lease_Account__c> lList = [select id from cllease__Lease_Account__c limit 4];
        Set<String> leaseSet = new Set<String>();
        cllease__Lease_Account__c ls;
        for (cllease__Lease_Account__c l:lList){
            leaseSet.add(l.id);
            ls = l;
        }

        ExposureUtility.getExposureFuture(leaseSet);
        
        ApexPages.StandardController controller  = new ApexPages.StandardController(ls);
        EXExposureController x = new EXExposureController(controller);
        x.showExposure();

        
         
    }

    


}