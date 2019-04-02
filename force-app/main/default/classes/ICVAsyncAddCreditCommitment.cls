/*******************************************************************************************************************
*   ICVAsyncAddCreditCommitment
* 
*	Change Log: 
*	11/12/18 - MRM Created
* 
********************************************************************************************************************/
public class ICVAsyncAddCreditCommitment implements Queueable, Database.AllowsCallouts {
    
    private String myISODateTime = string.valueOf(json.serialize(datetime.now()));
    private String applicationId;
    private String messageId;
    private String action;
    
    public  ICVAsyncAddCreditCommitment(String applicationId, String messageId, String action)
    {
        this.applicationId = applicationId;
        this.messageId = messageId;
        this.action = action;
    }
    
    public void execute(QueueableContext context) {
    	 
    	ICS_Application__c ar = [select id
    				,quick_quote__r.name
	  				from ICS_Application__c
	  				where id = :applicationId 
	  				];
    	
    	boolean resultsOK = true;
    	
    	if (action == 'Score'){
    		map<String,String> requestInfoMap = new Map<String,String>();
			requestInfoMap.put('TransactionID',ICVUtility.getMessageId());
			requestInfoMap.put('SourceCommitmentID',ar.quick_quote__r.name);//q.name);
			requestInfoMap.put('SourceCommitmentType','A');
			resultsOK = ICVUtility.addCommitment(requestInfoMap,applicationId,'PEND');
	    	system.debug('Results OK are: ' + resultsOK);
    	}
    	
    	if (resultsOK && !Test.isRunningTest()){
    		system.debug('Execute Add Commitment Performed for ' + system.now());
    		ICVAsyncICSCredit job = new ICVAsyncICSCredit(applicationId,messageId);
        	System.enqueueJob(job); 
    	} 
    		   
    } 
    
}