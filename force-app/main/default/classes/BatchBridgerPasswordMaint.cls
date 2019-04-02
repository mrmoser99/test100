/*********************************************************************************************
*	This batch program checks the bridger password for expiration.  if it is < 5 days it 
*	changes the password and saves to the database
*
* ChangeLog:
*
*	6/27/18 - MRM Created Class
*
************************************************************************************************/
global class BatchBridgerPasswordMaint implements Database.Batchable<SObject>,Database.Stateful,Database.AllowsCallouts{
    /*********************************************************************************************
  	*	QUERY
  	*
  	*
  	************************************************************************************************/
    static final string QUERY = 'Select id from Bridger_Setting__c';
	
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
    global void execute(Database.BatchableContext c, List<Bridger_Setting__c> scope) {
        
        Bridger.maintainPassword();
    }
    
    /*********************************************************************************************
  	*	FINISH
  	*
  	*
  	************************************************************************************************/
    global void finish(Database.BatchableContext c) {
    }
  
}