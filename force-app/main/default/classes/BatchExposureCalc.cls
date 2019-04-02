/*********************************************************************************************
*	This batch calculates exposure for all leases
*    
*   Keep batch size to 10 or lesss

* ChangeLog:
*
*	2/28/18 - MRM Created Class
*
************************************************************************************************/
global class BatchExposureCalc implements Database.Batchable<SObject>,Database.Stateful{
    /*********************************************************************************************
  	*	QUERY
  	*
  	*
  	************************************************************************************************/
    static final string QUERY = 'Select id, name  from cllease__Lease_Account__c';
	/*********************************************************************************************
  	*	CONSTRUCTOR
  	*
  	*
  	************************************************************************************************/
	global BatchExposureCalc(){
    	
    }
    /*********************************************************************************************
  	*	START
  	*
  	************************************************************************************************/				
    global Database.QueryLocator start(Database.BatchableContext c) {    
        return Database.getQueryLocator(QUERY);        
    }
  	/*********************************************************************************************
  	*	EXECUTE
  	*
  	*
  	************************************************************************************************/
    global void execute(Database.BatchableContext c, List<cllease__Lease_Account__c> scope) {
        
        Set<String> contractIDSet = new Set<String>();
        
        for (cllease__Lease_Account__c l : scope)  {
        	contractIdSet.add(l.id);
            system.debug('Lease Included: ' + l.name);
        }

        ExposureUtility.getExposure(contractIdSet);
        
       
    }
     
    /*********************************************************************************************
  	*	FINISH
  	*
  	*
  	************************************************************************************************/
    global void finish(Database.BatchableContext c) {
    }
  
}