/*******************************************************************************************************************
*   ICVAsyncAddParty
* 
*	Change Log: 
*	1/21/19 - MRM Created
* 
********************************************************************************************************************/
public class ICVAsyncAddParty implements Queueable, Database.AllowsCallouts {
    
    private String leaseId;
    private String typeCode;
    public  ICVAsyncAddParty(String leaseId,String typeCode)
    {
        this.leaseId = leaseId;
        this.typeCode = typeCode;
    }
    
    public void execute(QueueableContext context) {
    	
    	ICVUtility.addParty(leaseId,typeCode);
    }	
    
}