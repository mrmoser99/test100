/****************************************************************************
* Contract Trigger
*
* Log:
*
*   5/4/18 - MRM Created
*   10/1/18 - MRM Added line to call icv booking flow
*   3/8/19 - MRM added exposure calc for updates
*
* This trigger sends off a welcome packet when the contract is booked
*   
*
******************************************************************************/
trigger clleaseLeaseAccount on cllease__Lease_Account__c (before update) {
    

    //only send welcome packet if this is a single lease update
    if (trigger.new.size() == 1){
         
        Map<ID,String> leaseMap = new Map<ID,String>(); 
        if  (
            (!trigger.old[0].cllease__Lease_Status__c.contains('ACTIVE') 
            && trigger.new[0].cllease__Lease_Status__c.contains('ACTIVE') ) 
        
        || (trigger.old[0].welcome_package_requested__c == false &&
            trigger.new[0].welcome_package_requested__c == true)
            )
        { 
            system.debug('welcome packet on the way');
            trigger.new[0].welcome_package_requested__c = false;
            leaseMap.put(trigger.new[0].id,'Welcome');
            NewCoUtility.sendWelcomePacket(leaseMap);
        }
        
        if  (!trigger.old[0].cllease__Lease_Status__c.contains('ACTIVE') 
            && trigger.new[0].cllease__Lease_Status__c.contains('ACTIVE')){
                Map<ID,String> leaseMap2 = new Map<ID,String>();
                leaseMap2.put(trigger.new[0].id,'Hello');
                //superTrumpUtil.sendRequest(leaseMap2);
                if (!Test.isRunningTest()){
                	ICVAsyncBookLease job = new ICVAsyncBookLease(trigger.new[0].id);  
                	System.enqueueJob(job);
                } 
        }
        /*
        if (!ExposureUtility.exposureCalcRunning){
            Set<String> leaseSet = new Set<String>();
            leaseSet.add(trigger.old[0].id);
            ExposureUtility.getExposureFuture(leaseSet);
        }
        */
    }
}