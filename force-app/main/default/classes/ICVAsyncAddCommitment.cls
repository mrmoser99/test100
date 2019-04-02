/*******************************************************************************************************************
*   ICVAsyncAddCommitment
* 
*	Change Log: 
*	11/12/18 - MRM Created
* 
********************************************************************************************************************/
public class ICVAsyncAddCommitment implements Queueable, Database.AllowsCallouts {
    
    private String myISODateTime = string.valueOf(json.serialize(datetime.now()));
    private String leaseId;
    public  ICVAsyncAddCommitment(String leaseId)
    {
        this.leaseId = leaseId;
    }
    
    public void execute(QueueableContext context) {
    	
    	cllease__Lease_Account__c  l = [select 
    									name
    									,application_number__c
    									from cllease__Lease_Account__c 
    									where id = :leaseId	
    								 	];
    									
    	 									
    	genesis__applications__c a = [	select genesis__Quick_Quote__c 
    									from genesis__applications__c 
    									where name = :l.application_number__c
    									]; 
    									
    	map<String,String> requestInfoMap = new Map<String,String>();
		requestInfoMap.put('TransactionID',ICVUtility.getMessageId());
		requestInfoMap.put('SourceCommitmentID',l.name);
		requestInfoMap.put('SourceCommitmentType','A');
	    requestInfoMap.put('SourceSystemTimestamp',myISODateTime.substring(1,20));
	    
		if (ICVUtility.addCommitment(requestInfoMap,l.id,'BOOK')){				
    		system.debug('Execute Add Commitment Performed for ' + system.now());
    		ICVAsyncRemoveCommitment job = new ICVAsyncRemoveCommitment(a.genesis__quick_quote__c,'Book');
        	System.enqueueJob(job);	   
		}	   
    } 
    
}