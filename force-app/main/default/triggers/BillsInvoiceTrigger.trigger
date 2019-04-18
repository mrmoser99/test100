trigger BillsInvoiceTrigger on cllease__Lease_account_Due_Details__c (after update) {
  	Set<Id> invIds = new Set<Id>();
   	for (cllease__Lease_account_Due_Details__c childObj : Trigger.new) {
   		if(childObj.Invoiced_In__c != null) {
   			invIds.add(childObj.Invoiced_In__c);
   		}    	
  	}
  
  	if(invIds.size()>0){
  		InvoiceSummaryUtil.InvoiceSummary(invIds);
  	}
}