/**
 * Owner: Cloud Lending Solutions
 * Usage: Following trigger helps in Primary address update in Account.
 *      
 **/
trigger PrimaryAddressUpdatetTrigger on Address__c (after insert, after update) {
	Set<Id> accountIds = new Set<Id>();
	for(Address__c address : trigger.new) {
		if(address.Account__c != null && address.Primary_Address__c != null && address.Primary_Address__c) {
			accountIds.add(address.Account__c);
		}
	}

	if(accountIds.size() > 0) {
		Map<Id, Account> accountsMap = new Map<Id, Account> ([Select Id, Name, Primary_Address__c From Account Where Id =:accountIds]);
		if(accountsMap.size() > 0) {
			for(Address__c address : trigger.new) {
				// updating primary addres in account in case of primary field update
			    // and this code assumes only one address will get updated at a time for primary address field in address
			    // incase of multiple addresses's primary address field updates as true one single transaction, 
			    // order can't be predicted
			    if(address.Primary_Address__c != null && address.Primary_Address__c) {
			        Account temp = accountsMap.get(address.account__c);
			        temp.Primary_Address__c = address.Id;
			    }
			}

			// updating the Accounts
			if(accountsMap.size() > 0) {
				update accountsMap.values();

				//List<Id> accIdsSet = new List<Id>
				// calling future method utility for non primary address field updates
				PrimaryAddressUpdateUtil.processRecords(new List<Id> (accountsMap.keySet()));
			}

		}
	}
	
}