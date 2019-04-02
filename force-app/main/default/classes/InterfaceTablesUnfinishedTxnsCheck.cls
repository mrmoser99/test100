/**
 * Owner: Cloud Lending Solutions
 * Description: Following Class helps in checking unfinished Transactions in Interface tables
 * List of jobs
 * 		1. GL Consolidation Job 
 *				Class: GLConsolidatedEntriesBatch.cls
 *				Object: Int_OLMN_GL__c
 *		2. GL SubLedgers Job
 *				Class: GLSubledgerEntriesBatch.cls
 *				Object: Int_OLMN_Accounting_Entry__c
 *		3. AP Integration
 *				Class: PopulateAPinterfaceDealerfunding.cls
 *				Object: Int_OLMN_AP__c
 *		4. PNC Integration 
 *				Class: PNCFileCreationJob.cls
 *				Object: Int_PX_Billing__c
 * 
 **/
public with sharing class InterfaceTablesUnfinishedTxnsCheck {
	
	// return true if any remaining unfinished transactions in interface table
	// else false if there are no unfinished transactions in interface table
	public static Boolean checkUnfinishedTxnsForGLConsolidations() {
		List<Int_OLMN_GL__c> unfinishedTxns = [SELECT Id
													FROM Int_OLMN_GL__c
													WHERE Committed__c = false];
		if(unfinishedTxns.size() > 0) {
			return true;
		} else {
			return false;
		}
	}

	// return true if any remaining unfinished transactions in interface table
	// else false if there are no unfinished transactions in interface table
	public static Boolean checkUnfinishedTxnsForGLSubLedgers() {
		List<Int_OLMN_Accounting_Entry__c> unfinishedTxns 
												= [SELECT Id
													FROM Int_OLMN_Accounting_Entry__c
													WHERE Committed__c = false];
		if(unfinishedTxns.size() > 0) {
			return true; 
		} else {
			return false;
		}
	}

	// return true if any remaining unfinished transactions in interface table
	// else false if there are no unfinished transactions in interface table
	public static Boolean checkUnfinishedTxnsForAPIntegration() {
		List<Int_OLMN_AP__c> unfinishedTxns 	= [SELECT Id
													FROM Int_OLMN_AP__c
													WHERE Committed__c = false];
		if(unfinishedTxns.size() > 0) {
			return true; 
		} else {
			return false;
		}
	}

	// return true if any remaining unfinished transactions in interface table
	// else false if there are no unfinished transactions in interface table
	public static Boolean checkUnfinishedTxnsForPNCIntegration() {
		List<Int_PX_Billing__c> unfinishedTxns 	= [SELECT Id
													FROM Int_PX_Billing__c
													WHERE Committed__c = false];
        System.debug('unFinishedTxns.size = ' + unfinishedTxns.size());
		if(unfinishedTxns.size() > 0) {
			return true; //ahr
		} else {
			return false; //ahr
		}
	}

	// return true if any remaining unfinished transactions in interface table
	// else false if there are no unfinished transactions in interface table
	public static Boolean checkUnfinishedTxnsForNetInvestmentReport() {
		List<Int_OLMN_Net_Investment__c> unfinishedTxns = [SELECT Id
													FROM Int_OLMN_Net_Investment__c
													WHERE Committed__c = false];
		if(unfinishedTxns.size() > 0) {
			return true;
		} else {
			return false;
		}
	}
}