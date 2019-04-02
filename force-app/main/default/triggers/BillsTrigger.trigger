trigger BillsTrigger on cllease__Lease_account_Due_Details__c (after insert, after update) {
 Set<Id> clAccIds = new Set<Id>();
   for (cllease__Lease_account_Due_Details__c childObj : Trigger.new) {
    clAccIds.add(childObj.cllease__Lease_Account__c);
  }
  try{
  BillAndChargeTriggerHandler.afterinsertAndUpdate(clAccIds);
  }
  
  catch(exception e){
  
  }
  }