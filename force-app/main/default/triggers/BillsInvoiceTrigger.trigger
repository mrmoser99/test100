trigger BillsInvoiceTrigger on cllease__Lease_account_Due_Details__c (before insert, after update) {
  	
  	if(Trigger.isAfter && Trigger.isUpdate) {
  		Set<Id> invIds = new Set<Id>();
	   	for (cllease__Lease_account_Due_Details__c childObj : Trigger.new) {
	   		if(childObj.Invoiced_In__c != null) {
	   			invIds.add(childObj.Invoiced_In__c);
	   		}    	
	  	}
	  
	  	if(invIds.size()>0){
	  		InvoiceSummaryUtil.InvoiceSummary(invIds);
	  	}

  	} else if(Trigger.isBefore && Trigger.isInsert) {
  		// Update the Termination bill's Tax flag to false to vertex tax processing.
  		for(cllease__Lease_account_Due_Details__c bill : Trigger.new) {
  			// check for termination bill and update "cllease__Tax_Processed__c" true for tax calculation
  			if(bill.cllease__Due_Type_Description__c == 'TERMINATION') {
  				bill.cllease__Tax_Processed__c = false;
  			}
  		}
  	}
  	
}