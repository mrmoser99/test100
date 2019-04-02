/****************************************************************************
* Application Equipment
*
* Log:
*
* 	4/20/18 - MRM Created
*   6/13/18 - MRM Changed logic to maintain dealer funding record on update/insert
*
* This will automatically create/maintain the dealer funding record for the equipment
*
******************************************************************************/
trigger genesisApplicationEquipment on genesis__Application_Equipment__c (after insert, after update) {
    
    Set<ID> appEquipmentIds = new Set<ID>();
    Set<ID> appIds = new Set<ID>();
    
    /* get ids */
    
    for (genesis__Application_Equipment__c ae:trigger.new){
    	appEquipmentIds.add(ae.id);
    	appIds.add(ae.genesis__Application__c);
    }
    
    List <clcommon__Party__c> pList = new List<clcommon__Party__c>();
    
    /* get a list of equipment with extended data that trigger new does not have */ 
    List<genesis__Application_Equipment__c> aeList = new List<genesis__Application_Equipment__c>();
    aeList = [Select 
    			  g.genesis__Equipment__c
    			, g.genesis__Application__r.Dealer__c
    			, g.genesis__Application__c
    			, g.Name
    			, g.Dealer_Charges1__c 
    			, g.genesis__Application__r.genesis__account__c
    			, g.genesis__Estimated_Selling_Price__c
    			From genesis__Application_Equipment__c g 
    			where  id in :appEquipmentIds ];
 	
 	
    /* store off the dealer for each application */
    Map<ID,ID> dealerMap = new Map<ID,ID>();
    
    pList = [select id 
    			, genesis__application__c 
    			from  clcommon__Party__c
    			where party_type_name__c = 'DEALER'
    			and genesis__application__c in :appIds];
    for ( clcommon__Party__c p:pList)
    	dealerMap.put(p.genesis__application__c,p.id);	
    		
   
   	/* create map of equipment funding detail */
   		
   	List<Equipment_Funding_Detail__c> efList = [select id 
   												,equipment__c
   												from Equipment_Funding_Detail__c
   												where equipment__c in :appEquipmentIds
   												];
   	
   	Map<ID,Equipment_Funding_Detail__c> efMap = new Map<ID,Equipment_Funding_Detail__c>();
   	for (Equipment_Funding_Detail__c efd:efList)
   		efmap.put(efd.equipment__c,efd);
   	
   	List<Equipment_Funding_Detail__c> updateEFList = new List<Equipment_Funding_Detail__c>();
   	List<Equipment_Funding_Detail__c> insertEFList = new List<Equipment_Funding_Detail__c>();
   	List<Equipment_Funding_Detail__c> deleteEFList = new List<Equipment_Funding_Detail__c>();
   
	for (genesis__Application_Equipment__c ae:aeList){
   	
   		Equipment_Funding_Detail__c efd = efMap.get(ae.id);
   		if (trigger.isUpdate && efMap.containsKey(ae.id)){
   			efd.dealer_charges__c = ae.Dealer_Charges1__c;
			updateEFList.add(efd);   			
   		}
   		if (trigger.isInsert){
   			Equipment_Funding_Detail__c ef = new Equipment_Funding_Detail__c();
   			ef.application__c = ae.genesis__Application__c;
   			ef.dealer_charges__c = ae.genesis__Estimated_Selling_Price__c;
   			ef.equipment__c = ae.id;
   			ef.party__c = dealerMap.get(ae.genesis__Application__c);
   			insertEFList.add(ef);
   		}
	}
	if (!insertEFList.isEmpty())
   		insert insertEFList;
   	if (!updateEFList.isEmpty())
   		update updateEFList;
}