trigger ICSApplicationRequest on ICS_Application__c (after update) {
 
 	List<Account> aList = new List<Account>();
 	
 	List<genesis__Quick_Quotes__c> qList = new List<genesis__Quick_Quotes__c>();
 	
 	Set<ID> qqSet = new Set<ID>();
 	
 	for (ICS_Application__c app:trigger.new)
 		qqSet.add(app.quick_quote__c);   
	
	Map<String,String> qqAcctMap = new Map<String,String>();
	Set<String> aSet = new Set<String>();
	
 	qList = [Select  Name
 					,genesis__Account__c
 					From genesis__Quick_Quotes__c 
 					where id in :qqSet];
 	for (genesis__Quick_Quotes__c q:qList){
 		qqAcctMap.put(q.id,q.genesis__Account__c);
 		aSet.add(q.genesis__Account__c);
 	}
 	
 	Map<String,Account> acctMap = new Map<String,Account>([select id from Account where id in:aSet]);
 		
 	for (ICS_Application__c app:trigger.new){
 		if (app.status__c != null){
			if (app.status__c.contains('Approved') && qqAcctMap.get(app.quick_quote__c) != null){
	 			Account temp = acctMap.get(qqAcctMap.get(app.quick_quote__c));
				temp.le_id__c = app.legal_entity_id__c;
				aList.add(temp);
			}
 		}
 	}
 	
 	if (!alist.isEmpty())
 		update aList;
 		
}