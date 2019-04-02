trigger QuickQuotes on genesis__Quick_Quotes__c (before insert, before update) {
	
    
    if (system.label.ICS_AutoApproval == 'AUTO') {
   	 	integer i =0;
    	for (genesis__Quick_Quotes__c q:trigger.new){
        	if (trigger.new[i].genesis__status__c == 'CREDIT SUBMITTED' || trigger.new[i].genesis__status__c == 'CREDIT REFERRED' || trigger.new[i].genesis__status__c == 'CREDIT DECLINED'){  
           	 	trigger.new[i].genesis__status__c = 'CREDIT APPROVED';
        		trigger.new[i].approved_credit_amount__c = decimal.valueOf(trigger.new[i].estimated_financed_amount__c);
        		trigger.new[i].credit_approval_date__c = date.today();
    
        	}
       		i++;
    	}
    }
    
}