/**
 * Owner: Cloud Lending Solutions
 * Usage: Following job helps in Creating the Interface Record for each GL Account Entries
 * Script to Run Job:
 *      
 **/
global with sharing class ResidualBurndown extends clcommon.DynamicJob {

	private static String query;
    private static final String JOB_NAME = 'EVERGREEN RESIDUAL BURNDOWN GENERATOR JOB';


	global ResidualBurndown() {
        super(JOB_NAME, initialize(null));
        doInitialize();
    }
    
    global ResidualBurndown(List<String> contractNames) {
        super(JOB_NAME, initialize(contractNames));
        doInitialize();
    }
    
    global virtual override String getRuntimeQuery() {
        System.debug(LoggingLevel.ERROR, 'ResidualBurndown query in getRuntimeQuery : ' + query);
        return query; 
    }

    public static String initialize(List<String> contractNames) {

    	// Creating ResidualBurndown Query
        query = ' SELECT Id, Name, 									'+
        			' cllease__Lease_Status__c,           			'+
		    		' (SELECT Id, Name, 							'+
		    		'		cllease__Residual_Amount__c, 			'+
		    		'		Salvage_Value__c, 						'+
		    		'		Evergreen_Depreciable_Cost__c,			'+
		    		'		Evergreen_Depreciable_Life__c,			'+
		    		'		Last_Residual_Burndown_Date__c,			'+
		    		'		Remaining_Evergreen_Depreciable_Cost__c '+
		    		'	FROM cllease__Contract_Equipments__r    	'+
		    		'	WHERE cllease__Status__c = \'LEASED\' ) 	'+
                ' FROM cllease__Lease_Account__c 			'+
                ' WHERE cllease__Lease_Status__c in (\'EVERGREEN\')';

        // Specifying contracts incase of contact numbers specified
        if(contractNames!=null && contractNames.size() > 0) {
            String contractNamesStr = '';
            for (String contractName : contractNames) {
              contractNamesStr = contractNamesStr + '\'' + String.escapeSingleQuotes(contractName) + '\'' + ',';
            }
            contractNamesStr = contractNamesStr.substring(0, contractNamesStr.length() - 1);
            query += ' AND Name in ('+ contractNamesStr + ')';
        }
        
        System.debug(LoggingLevel.ERROR, 'ResidualBurndown Query: '+query);       
        return query;

    }

    public override void doExecute(Database.BatchableContext bc, List<sObject> scope) {
    	
    	List<cllease__Lease_Account__c> contracts = (List<cllease__Lease_Account__c>)scope;
    	List<cllease__Contract_Equipment__c> equipmentsToUpdate 	= new List<cllease__Contract_Equipment__c>();
    	List<cllease__Other_Transaction__c> residualBurndownTrans 	= new List<cllease__Other_Transaction__c>();

    	Savepoint sp = database.setsavepoint();
    	try {

    		// 0. Retrieving the record type for Evergreen
    		ID txnRecordId;
            List<RecordType> rtlist = [SELECT Id FROM RecordType WHERE Name = 'Evergreen Record Type' AND SObjectType = 'cllease__Other_Transaction__c'];

          	if (rtList != null && rtList.size() > 0) {
              	txnRecordId = rtList.get(0).Id;
          	}

          	// 1. Processing th3e contracts
    		Date currentSystemDate = cllease.SystemDateUtil.getCurrentSystemDate();
    		// 1. Loop through contracts
    		for(cllease__Lease_Account__c contract: contracts) {
    			Decimal totalResidualBurnDownOnContract = 0;
    			Decimal remainingResidualAmount = 0;

    			System.debug(LoggingLevel.ERROR, ' Processing the Contract: '+contract.Name);
    			// looping through Contract Equipment for residual amount.
    			for(cllease__Contract_Equipment__c contractEqp : contract.cllease__Contract_Equipments__r) {

    				Date nextResidualBurnDownDate = (contractEqp.Last_Residual_Burndown_Date__c != null ? contractEqp.Last_Residual_Burndown_Date__c.addMonths(1) : null);

    				System.debug(LoggingLevel.ERROR, ' Processing the contractEqp: '+contractEqp.Name);
    				System.debug(LoggingLevel.ERROR, ' nextResidualBurnDownDate: '+nextResidualBurnDownDate);

    			
    				// Process the contract Equipment for Residual burndown only incase of contract in evergreen status , last burndown is null or <= current system date.
    				if(contractEqp.Last_Residual_Burndown_Date__c == null || nextResidualBurnDownDate <= currentSystemDate) {
    					Decimal residualBurnDown = 0;
    					// Assigning 0 incase of null
    					contractEqp.Remaining_Evergreen_Depreciable_Cost__c 	= contractEqp.Remaining_Evergreen_Depreciable_Cost__c != null ? contractEqp.Remaining_Evergreen_Depreciable_Cost__c : 0.00;
    					Decimal calcResidualBurnDown = cllease.ValueUtil.round((contractEqp.Evergreen_Depreciable_Cost__c / contractEqp.Evergreen_Depreciable_Life__c), 2, 'Nearest');
	    				
	    				// Calculate the Depreciations only when remaining amount available and also evergreen depreciation life > 0
	    				if(contractEqp.Remaining_Evergreen_Depreciable_Cost__c > 0 && contractEqp.Evergreen_Depreciable_Life__c > 0) {
	    					// Calculating the remaining terms.
	    					if( contractEqp.Remaining_Evergreen_Depreciable_Cost__c >= calcResidualBurnDown ) {
	    						residualBurnDown = calcResidualBurnDown;
	    					} else {
	    						residualBurnDown = contractEqp.Remaining_Evergreen_Depreciable_Cost__c;
	    					}
		    				
		    				// Totalling the residualBurnDown
		    				totalResidualBurnDownOnContract 					+= residualBurnDown;
	    					contractEqp.Remaining_Evergreen_Depreciable_Cost__c -= residualBurnDown;
		    				remainingResidualAmount 						  	+= contractEqp.Remaining_Evergreen_Depreciable_Cost__c;
		    				contractEqp.Last_Residual_Burndown_Date__c 	 	   	 = currentSystemDate;
		    				equipmentsToUpdate.add(contractEqp);
	    				}
    				}
    			}

    			if(totalResidualBurnDownOnContract > 0) {
    				cllease__Other_Transaction__c termTrx    = new cllease__Other_Transaction__c();
                    termTrx.cllease__Lease_Account__c        = contract.Id;
                    termTrx.RecordTypeId                     = txnRecordId;
                    termTrx.cllease__Transaction_Type__c     = 'EVERGREEN DEPRECIATION';
                    termTrx.cllease__GL_Transaction_Flag__c  = true;
                    termTrx.Residual_Burndown_Amount__c      = totalResidualBurnDownOnContract;
                    termTrx.Remaining_Evergreen_Depreciable_Cost__c     = remainingResidualAmount;
                    
    				residualBurndownTrans.add(termTrx);
    			}
    		}
	    	// 1.a. Loop through Equipments
	    	// 1.a.a. Calculate the residual burndown amount for transactions
	    	// 2. Create Transaction with Residual burndown.

	    	if(residualBurndownTrans.size() > 0) {
	    		insert residualBurndownTrans;
	    	}

	    	if(equipmentsToUpdate.size() > 0) {
	    		update equipmentsToUpdate;
	    	}


		} catch(exception e){           
           	database.rollback(sp);   
           	System.debug(LoggingLevel.ERROR, 'Exception: '+e.getMessage());    
           	System.debug(LoggingLevel.ERROR, 'Exception Stack: '+e.getStackTraceString());      
           	//insert batch process log for exceptions
           	insert new cllease__Batch_Process_Log__c(Name='ResidualBurndown: ', cllease__Date__c=system.today(),
            cllease__Message__c='Error is '+e.getmessage() +' in line number: '+ e.getlinenumber());
       }
       
    }

    public override void doInitialize() { }
    public override void doStart(Database.BatchableContext bc) { }   
    public override void doFinish(Database.BatchableContext bc) { }
     
}


/*
	Configuration Needed:
		1. Calculation Setup on Contract Equipment ( Remaining Residual burndown = residual value)
		2. Aplication Equipment New Fields:
			- Residual burndown value
		3. Conversion mapping



	Contract Equipment fields:
		1. Remaining Residual Amount
		2. Residual Burn Down
		3. Last Residual BurnDown Date
		4. Asset Life Time
		5. Rental Term.
	Application Equipment fields:
		1. Residual Amount Copy
		2. Residual Burndown Amount

	skuid page:

		

	
	Note:
		Currently Asset Life not copying to contract and numbers won't shown up in Other Transaction(Residual burndown type).

*/