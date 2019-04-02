/*******************************************************************************************************************
*   ICVAsyncGetCommitmentLE
* 
*	Change Log: 
*	11/12/18 - MRM Created
* 
********************************************************************************************************************/
public class ICVAsyncGetCommitmentLE implements Queueable, Database.AllowsCallouts {
    
    private String myISODateTime = string.valueOf(json.serialize(datetime.now()));
    private String applicationId;
    public  ICVAsyncGetCommitmentLE(String applicationId)
    {
        this.applicationId = applicationId;
    }
    
    public void execute(QueueableContext context) { 
    	
    	ICS_Application__c ar = [select id
    				,quick_quote__r.name
    				,quick_quote__c
    				,quick_quote__r.genesis__status__c
	  				from ICS_Application__c
	  				where id = :applicationId 
	  				];
    	
    	 
		Map<String,String> requestInfoMap = new Map<String,String>();
		requestInfoMap.put('TransactionID',ICVUtility.getMessageId());
		requestInfoMap.put('SourceCommitmentID',ar.quick_quote__r.name);//q.name);
		requestInfoMap.put('SourceCommitmentType','A');
		
		if(ICVUtility.getCommitmentLE(requestInfoMap,applicationId)){		
	    	system.debug('Execute Get Commitment LE Performed for ' + system.now());
	    	//if (ar.quick_quote__r.genesis__status__c != 'CREDIT DECLINED'){
    	 	ICVAsyncGetContractPerformance job = new ICVAsyncGetContractPerformance(applicationId);
        	System.enqueueJob(job);
	    	//} 
		} 	   
    }
    
}