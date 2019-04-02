/********************************************************************************************
*
*  Change Log:
*
*	10/17/18 - MRM Created class for list of similar selection
*
*********************************************************************************************/
public with sharing class ICSExternalLEExtension {
    
    ICS_External_Legal_Entity__c s;
    ICS_Application__c a;
    genesis__Quick_Quotes__c q;
    
    public ICSExternalLEExtension(ApexPages.StandardController stdController){
    	
    	this.s = (ICS_External_Legal_Entity__c)stdController.getRecord();
    	
    	s = [Select id
    				,Legal_Name__c
    				,Address_Line__c
    				,City__c
    				,Phone__c
    				,State_Province_Code__c
    				,Postal_Code__c
    				,Country_Code__c
    				,ICS_Application_Request__c
    				from ICS_External_Legal_Entity__c
    				where id = :s.id
    				];
    				
    	a = [select name 
    				,status__c
    				,message_id__c
    				,quick_quote__c
    				,quick_quote__r.estimated_financed_amount__c
    				,system_approval_limit__c
    				,manual_approval_limit__c
    		from ICS_Application__c		
    		where id = :s.ics_application_request__c
    		];
    		
    	q = [select id 
    			,name  
    			,genesis__State__c
    			,genesis__Last_Name__c
    			,genesis__First_Name__c
    			,genesis__Business_Name__c
    			,genesis__Address_Line_1__c
    			,genesis__City__c
    			,genesis__Postal_Code__c
    			,Dealer__r.Name
    			,Dealer__r.Id
    			,dealer__r.account_number__c
    			,genesis__account__r.account_Number__c
    			,genesis__account__c
    			,Primary_Phone_number__c
    			,Estimated_Financed_Amount__c
    			,genesis__Account__r.Id 
    		from genesis__Quick_Quotes__c
    		where id = :a.quick_quote__c];
    			   
    } 
    /******************************************************************************************
    * CHOOSE
    *******************************************************************************************/
    public pageReference choose(){
    	
    	if (a.status__c != 'List of Similars'){
    		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Application statust must be List of Similars!');
 			ApexPages.addMessage(msg);
			return null;
    	}
    	
    	List<Group> gList = [Select Id
								,developername
								 From
								 Group g 
								 where type = 'QUEUE' and developerName in ('Credit','Past_Credit','Waiting_for_Credit')
								 ];
		Map<String,ID> gMap = new Map<String,ID>();
		for (Group g:gList)
			gMap.put(g.developername, g.id);
			
    	a.ownerid = gmap.get('Past_Credit');
    	a.status__c = 'Similar Chosen by CA';
   		q.genesis__status__c = 'CREDIT SUBMITTED';
    	q.Credit_Approval_Date__c = null;
		q.Approved_Credit_Amount__c = null;
		q.ATS_Reference_Number__c = null;
		q.Credit_Approval_Expiration_Date__c =  null;
		
    	update a;
    	update q;
    	
    	ICSUtility.acceptLOS(q.id,a.id,s.id);     
    	
    	PageReference newPage = new PageReference('/' + a.id);
    	newPage.setRedirect(true);
		return newPage;
    }
}