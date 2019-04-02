/************************************************************************************************
*  
* Log:
*
*	8/10/18 - MRM Created
*   8/22/18 - MRM Removed auto close feature.
*
************************************************************************************************/
trigger clleasePeriodStatus on cllease__Period_Status__c (before update) {
     
    /*
    system.debug('************************** in status trigger');
    Integer i=0;
    for (cllease__Period_Status__c p :trigger.new){
    	if (trigger.new[i].cllease__Status__c == 'Closed' && trigger.old[i].cllease__Status__c != 'Closed'){
    		
    		p.send_urgent_email__c = false;
    		p.send_warning_email__c = false;
    		p.email_urgent_date_time__c = null;
    		p.email_warning_date_time__c = null;
    		
    	}
		i++;
    }
    */
    
}