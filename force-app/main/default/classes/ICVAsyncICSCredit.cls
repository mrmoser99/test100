/*******************************************************************************************************************
*   ICVAsyncICSCredit
* 
*	Change Log: 
*	11/12/18 - MRM Created
* 
********************************************************************************************************************/
public class ICVAsyncICSCredit implements Queueable, Database.AllowsCallouts {
    
    private String myISODateTime = string.valueOf(json.serialize(datetime.now()));
    private String applicationId;
    private String messageId;
    public  ICVAsyncICSCredit(String applicationId, String messageId)
    {
        this.applicationId = applicationId;
        this.messageId = messageId;
    }
    
    public void execute(QueueableContext context) {
    	ICS_Application__c ar = [select quick_quote__c 
    									,transaction_id__c
    									from ICS_Application__c
    									where id = :applicationId ]; 
    									
    	Map<ID,String> quickQuoteMap = new Map<ID,String>(); 
		quickQuoteMap.put(ar.quick_quote__c,'Hello');
		//ICSUtility.sendRequest(quickQuoteMap,false,false,messageId,ar.transaction_id__c);
		if (ICSUtility.sendRequest(quickQuoteMap,false,false,messageId,ar.transaction_id__c)){ 
    		system.debug('Called getICS Credit ' + system.now());
    		ICVAsyncGetCommitmentLE job = new ICVAsyncGetCommitmentLE(applicationId);
        	System.enqueueJob(job);
		} 
    }
    
}