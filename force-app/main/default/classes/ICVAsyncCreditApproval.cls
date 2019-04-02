/*******************************************************************************************************************
*   This service is used to process the workflow for credit requests\
*
*	1.  Add Party (Quick Quote Name)
*	2.  Add Party (Account Number of Partner)
*	3. 	Add Commitment (Quick Quote Name)
*	4.  Call get ICS Credit
*	5.  Get Commitment LE (Quick Quote Name)
*	6.	Get Contract Performance (Quick Quote Name)
*	
*	Change Log:
*	10/1/18 - MRM Created
*   
********************************************************************************************************************/
public class ICVAsyncCreditApproval implements Queueable, Database.AllowsCallouts  { 
     
    private String applicationId; 
    private String messageId;
	private String action;
	  
	//Constructor   
    public  ICVAsyncCreditApproval(String applicationId, String messageId, String action)
    {
        this.applicationId = applicationId;
        this.messageId = messageId; 
        this.action = action;
    }
    //Execute
    public void execute(QueueableContext context) {
    	
    	system.debug('applicationid is: ' + applicationId);
    	
    	boolean resultsOK = true;
    	
    	if (action == 'Score'){
    		resultsOK = ICVUtility.addParty(applicationId,'C');
    		system.debug('Execute Add Party Performed for ' + system.now());
    	}
    	
    	if (action == 'LOS'){
    		resultsOK = ICVUtility.updateParty(applicationId,'LOS'); 
    	   	system.debug('Execute Update Party Performed for ' + system.now());
    	}
    	
    	if (resultsOK){
    		if (!Test.isRunningTest()){
	    		ICVAsyncAddPartner job = new ICVAsyncAddPartner(applicationId, messageId,action);
    	    	System.enqueueJob(job);
    		}
    	}
    		   
    }
    
}