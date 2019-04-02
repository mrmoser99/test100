public class ICVAsyncGetContractPerformance implements Queueable, Database.AllowsCallouts {
    
    private String myISODateTime = string.valueOf(json.serialize(datetime.now()));
    private String applicationId;
    public  ICVAsyncGetContractPerformance(String applicationId)
    {
        this.applicationId = applicationId;
    }
    
    public void execute(QueueableContext context) { 
    	
    	ICS_Application__c ar = [select id
    				,quick_quote__r.name
    				,quick_quote__r.with_account__c
	  				,quick_quote__r.genesis__account__r.Account_Number__c
	  				from ICS_Application__c
	  				where id = :applicationId 
	  				];
    	
    	Map<String,String> requestInfoMap = new Map<String,String>();
		requestInfoMap.put('SourceSystem','CLND');
		requestInfoMap.put('IDType','PARTY_ID');
		if (ar.quick_quote__r.with_account__c == true)
			requestInfoMap.put('IDValue',ar.quick_quote__r.genesis__account__r.Account_Number__c);
		else 
			requestInfoMap.put('IDValue',ar.quick_quote__r.name);
		ICVUtility.getContractPerformanceData(requestInfoMap,applicationId);
	    
    	system.debug('Execute Get Contract Performance for ' + system.now());
    	
    	
    		   
    }
    
}