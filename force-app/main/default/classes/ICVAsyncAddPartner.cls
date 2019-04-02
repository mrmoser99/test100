/*******************************************************************************************************************
*   ICS UTILITY
* 
*	Change Log: 
*	11/12/18 - MRM Created
* 
********************************************************************************************************************/
public class ICVAsyncAddPartner implements Queueable, Database.AllowsCallouts {
    
    private String myISODateTime = string.valueOf(json.serialize(datetime.now()));
    private String applicationId;
    private String messageId;
    private String action;
    
    public  ICVAsyncAddPartner(String applicationId, String messageId,String action)
    {
        this.applicationId = applicationId;
        this.messageId = messageId;
        this.action = action;
    }
    
    public void execute(QueueableContext context) { 
    	
    	if (action == 'Score')
    		if (ICVUtility.addParty(applicationId,'P')){
    			system.debug('Execute Add Partner Performed for ' + system.now()); 
    			
    			if (!Test.isRunningTest()){
    				ICVAsyncAddCreditCommitment job = new ICVAsyncAddCreditCommitment(applicationId, messageId,action);
        			System.enqueueJob(job);
    			}
    		} 
    		
    	if (action == 'Re-Score' || action == 'Re-ScoreLOS'){
    		system.debug('Execute ICSCredit Performed for ' + system.now()); 
    		if (!Test.isRunningTest()){
    			ICVAsyncICSCredit job = new ICVAsyncICSCredit(applicationId,messageId);
        		System.enqueueJob(job);
    		} 
    	}
    } 
    
}