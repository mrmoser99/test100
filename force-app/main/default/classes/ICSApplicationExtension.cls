/********************************************************************************************
*
*  Change Log:
*
*	10/17/18 - MRM Created class for manual approval on credit app
*
*********************************************************************************************/
public with sharing class ICSApplicationExtension {
    
    ICS_Application__c a;
    genesis__Quick_Quotes__c q;
    List<Attachment> aList;
    List<Note> nList;
    Boolean error = false;
    Boolean notes, attachments = false;
    
    
    public ICSApplicationExtension(ApexPages.StandardController stdController){
    	
    	this.a = (ICS_Application__c)stdController.getRecord();
    	     
    	a = [select name 
    				,kyc_reason__c
    				,kyc_source__c
    				,status__c
    				,message_id__c
    				,quick_quote__c
    				,transaction_id__c
    				,quick_quote__r.estimated_financed_amount__c
    				,system_approval_limit__c
    				,manual_approval_limit__c
    				,kyc__c
    				,error__c
    		from ICS_Application__c		
    		where id = :a.id
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
    	
    	aList = [select id	
    			From Attachment 
				where parentid= :a.id
				];
				
    	nList = [select id	
    			From Note
				where parentid= :a.id
				];		  
				
		system.debug('**** constructor complete');	  
		
		system.debug('returl = ' + ApexPages.currentPage().getParameters().get('retURL'));
    	
	} 
    
    /******************************************************************************************
    * APPROVE
    *******************************************************************************************/
    public pageReference approve(){
    	
    	aList = [select id	
    			From Attachment 
				where parentid= :a.id
				];
				
    	nList = [select id	
    			From Note
				where parentid= :a.id
				];		  
				
    	Boolean error=false;
    	 
    	if (a.status__c != 'Manual Review' && a.status__c != 'CRE Rating Required'){
    		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Status must be Manual Review or CRE Rating Required to approve!');
 			ApexPages.addMessage(msg);
 			error=true;
    		
    	}
    	else{
    		if (a.manual_approval_limit__c == 0 || a.manual_approval_limit__c == null) {
    			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Enter a manual approval amount before approving!');
 				ApexPages.addMessage(msg);
 				error=true;
    		} 
    		if (a.manual_approval_limit__c != decimal.valueOf(a.quick_quote__r.estimated_financed_amount__c)){
    			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Manual approval amount must equal quick quote estimated financed amount!');
 				ApexPages.addMessage(msg);
 				error=true;
    		}  
    		if (aList.size() ==0 && nList.size() == 0){
    			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'A note or attachment as backup for manual approval is required!');
 				ApexPages.addMessage(msg);
 				error=true;
    		}  
    		if (a.kyc__c == true && a.kyc_reason__c == null){
    			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'KYC Reason is required!');
    			ApexPages.addMessage(msg);
 				error=true;
    		} 
    		if (a.kyc__c == true && a.kyc_source__c == null){
    			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'KYC Source(s) are required!');
    			ApexPages.addMessage(msg);
 				error=true;
    		} 
    	}
    	  
   		if (error){
  	 		a.error__c = true;
    		update a;
    		return null;
     	}
     	
     	if (a.error__c == true){
     		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Click Approve to continue!');
 			ApexPages.addMessage(msg);
 			a.error__c = false;
 			update a;
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
			
    	a.status__c = 'Credit Analyst Approved';
    	a.ownerid = gmap.get('Past_Credit');
    	q.genesis__status__c = 'CREDIT APPROVED';
    	q.Credit_Approval_Date__c = date.today();
		q.Approved_Credit_Amount__c = a.Manual_Approval_Limit__c;
		q.ATS_Reference_Number__c = a.message_id__c;	
		q.Credit_Approval_Expiration_Date__c =  date.today().addDays(90);		
    
    	update a;
    	update q;
    	
    	/* call the service to register manaul decline with ICS */
    	Map<String,String> md = new Map<String,String>();
    	
    	md.put('decision','ACCEPT');
    	String myISODateTime = string.valueOf(json.serialize(datetime.now()));
		md.put('decisionDate', myISODateTime.replace('Z',''));		
		md.put('decisionAmount', string.valueOf(q.Approved_Credit_Amount__c ));	
		md.put('decisionReasonCode','MAPPR');
		md.put('decisionReasonDesc', 'Manual Approval');
		md.put('decisionReasonUserName', userInfo.getUserName());	
	 
	 	ICSUtility.updateICSManualDecision(a.id,md);
    	
    	ICSUtility.manualCreditApproval(a.id);   
    	PageReference newPage = new PageReference('/' + a.id);
    	newPage.setRedirect(true);
		return newPage;
    }
    
    /******************************************************************************************
    * DECLINE
    *******************************************************************************************/
    public pageReference decline(){
    	
    	
    	if (a.status__c != 'Manual Review' && a.status__c != 'CRE Rating Required'){
    		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Status must be Manual Review or CRE Rating Required to decline!');
 			ApexPages.addMessage(msg);
 			error=true;
    	}
    	
    	if (aList.size() ==0 && nList.size() == 0){
    		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'A note or attachment as backup for manual approval is required!');
 			ApexPages.addMessage(msg);
 			error=true;
    	}
    	
    	if (error){
    		a.error__c = true;
    		update a;
    		return null;
     	}
     	
     	if (a.error__c == true){
     		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Click Decline to continue!');
 			ApexPages.addMessage(msg);
 			a.error__c = false;
 			update a;
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
			
    	a.status__c = 'Credit Analyst Declined';
    	a.ownerid = gmap.get('Past_Credit');
    	q.genesis__status__c = 'CREDIT DECLINED';
    	q.Credit_Approval_Date__c = date.today(); 
		q.Approved_Credit_Amount__c = 0;
		q.ATS_Reference_Number__c = a.message_id__c;	
		q.Credit_Approval_Expiration_Date__c =  null;
    	update a;
    	update q;
    	
    	system.debug('Calling manual decision');
    	
    	/* call the service to register manaul decline with ICS */
    	Map<String,String> md = new Map<String,String>();
    	
    	md.put('decision','DECLINE');
    	String myISODateTime = string.valueOf(json.serialize(datetime.now()));
		md.put('decisionDate', myISODateTime.replace('Z',''));		
		md.put('decisionAmount', '0.00');	
		md.put('decisionReasonCode','MD');
		md.put('decisionReasonDesc', 'Manual Decline');
		md.put('decisionReasonUserName', userInfo.getUserName());	
	 
	 	ICSUtility.updateICSManualDecision(a.id,md);
	 	
	 	if (!Test.isRunningTest()){
	 		ICVAsyncRemoveCommitment job = new ICVAsyncRemoveCommitment(q.id,'Decline');
        	System.enqueueJob(job);	 
	 	}
	 	 
    	PageReference newPage = new PageReference('/' + a.id);
    	newPage.setRedirect(true);
		return newPage;
    }
   	/******************************************************************************************
    * RESCORE
    *******************************************************************************************/
    public pageReference rescore(){
    	
    	aList = [select id	
    			From Attachment 
				where parentid= :a.id 
				];
				
    	nList = [select id	
    			From Note
				where parentid= :a.id
				];		  
    	
    	Boolean error=false;
    		
    	if (aList.size() ==0 && nList.size() == 0){
    		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'A note or attachment as backup for re-score is required!');
 			ApexPages.addMessage(msg);
 			error=true;
    	}
    	  
      
   		if (error){
  	 		a.error__c = true;
    		update a;
    		return null;
     	}
     	
     	if (a.error__c == true){
     		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Click Rescore to continue!');
 			ApexPages.addMessage(msg);
 			a.error__c = false;
 			update a;
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
			
    	a.status__c = 'Credit Analyst Rescored';
    	a.ownerid = gmap.get('Past_Credit');
    	
    	
    	q.genesis__status__c = 'CREDIT SUBMITTED';
    	q.Credit_Approval_Date__c = null;
		q.Approved_Credit_Amount__c = null;
		q.ATS_Reference_Number__c = null;
		q.Credit_Approval_Expiration_Date__c =  null;
    	update a;
    	update q;
    	 
    	ICSUtility.score(q,'Re-Score',null);   
    	PageReference newPage = new PageReference('/' + a.id);
    	newPage.setRedirect(true);
		return newPage;
    }
    /******************************************************************************************
    * RESCORE LOS
    *******************************************************************************************/
    public pageReference rejectLOS(){
    	
    	Boolean error=false;
    	
     
    	if (a.status__c != 'List Of Similars'){
    		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Application status must be List of Similars to rescore LOS!');
 			ApexPages.addMessage(msg);
 			error=true;
    		
    	}
    	
    	  
    	if (error){
  	 		a.error__c = true;
    		update a;
    		return null;
     	}
     	
     	if (a.error__c == true){
     		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Click Reject LOS to continue!');
 			ApexPages.addMessage(msg);
 			a.error__c = false;
 			update a;
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
			
    	a.status__c = 'Credit Analyst Rejected LOS';
    	a.ownerid = gmap.get('Past_Credit');
    	
    	
    	q.genesis__status__c = 'CREDIT REFERRED';
    	q.Credit_Approval_Date__c = null;
		q.Approved_Credit_Amount__c = null;
		q.ATS_Reference_Number__c = null;
		q.Credit_Approval_Expiration_Date__c =  null;
    	update a;
    	update q;
    	 
    	ICSUtility.rejectLOS(a.id);   
    	PageReference newPage = new PageReference('/' + a.id);
    	newPage.setRedirect(true);
		return newPage;
    }
}