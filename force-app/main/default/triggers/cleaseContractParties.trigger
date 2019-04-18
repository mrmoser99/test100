/****************************************************************************
* Contract Parties Trigger
*
* Log:
*
* 	4/18/18 - MRM Created
*
* Place the delear name, state and createddate on the lease when inserting contract parties that are 
* delears.  This will be used for reporting etc...
*
******************************************************************************/
trigger cleaseContractParties on cllease__Contract_Parties__c (before update, before insert) {

	Map<ID,String> nameMap = new Map<ID,String>();
	Map<ID,String> accountMap = new Map<ID,String>();
	Map<ID,ID> contractAccountMap = new Map<ID,ID>();
	Map<ID,String> contractAccountState = new Map<ID,String>();
	Map<ID,Date> contractAccountApprovedDate = new Map<ID,Date>();
	Map<ID,String> oracleVendor = new Map<ID,String>();
	
	Set<ID> contractSet = new Set<ID>();
	Set<ID> partyAcctSet = new Set<ID>();
	
	for (cllease__Contract_Parties__c p:trigger.new){
		if (p.cllease__Contract__c != null && p.cllease__Party_Type__c == 'DEALER'){
			contractSet.add(p.cllease__Contract__c);
			partyAcctSet.add(p.cllease__Party_Account_Name__c);
			contractAccountMap.put(p.cllease__Contract__c,p.cllease__Party_Account_Name__c);
			
		}
	}
	//accounts	 
	List<Account>	aList = [select name
							, oracle_vendor_id__c 
							from Account 
							where id in: partyAcctSet];
	for (Account a:aList){
		oraclevendor.put(a.id,a.oracle_vendor_id__c);
		accountMap.put(a.id,a.name);
	}
	
	List<Address__c> addrList = [select state__c
								, createddate 
								, account__c
								from Address__c 
								where account__c in: partyAcctSet
								and pay_to__c = true];
	for (Address__c ad:addrList){
		contractAccountState.put(ad.account__c,ad.state__c);
		contractAccountApprovedDate.put(ad.account__c,date.valueOf(ad.createddate));
	}
									
	//contracts
	List<cllease__Lease_Account__c> lList = new List<cllease__Lease_Account__c>();
	lList = [select id from cllease__Lease_Account__c where id in :contractSet];
	
	for (cllease__Lease_Account__c l: lList){
		l.dealer_name__c = accountMap.get(contractAccountMap.get(l.id));
		l.dealer_state__c = contractAccountState.get(contractAccountMap.get(l.id));
		l.dealer_approved_date__c = contractAccountApprovedDate.get(contractAccountMap.get(l.id));
		l.dealer_oracle_vendor_id__c = oraclevendor.get(contractAccountMap.get(l.id));
	}
 
	if (!lList.isEmpty())
		update lList;
}