/*********************************************************************************************
*
* Assists with auto closing and opening next period
*
* Change Log:
*
* 8/3/18 - MRM Created
*
*
**********************************************************************************************/
trigger periodStatus on cllease__Period_Status__c (before update) {
 	/*
 	if (trigger.new.size() == 1){  //only do this if one record is being updated at a time
 		integer i=0;
 		for (cllease__Period_Status__c p:trigger.new){
 			if (trigger.new[i].cllease__status__c == 'Closed' && trigger.old[i].cllease__status__c != 'Closed'){
 				List<cllease__Period_Status__c>	pList = [select id 
 														from
 														cllease__Period_Status__c
 														where cllease__Start_Date__c > :trigger.new[i].cllease__start_Date__c
 														order by cllease__Start_Date__c
 														limit 1
 														];
 				pList[0].cllease__status__c = 'Open';
 				update pList;										 
 			}
 			i++;
 		}
 	} 
 	*/  
}