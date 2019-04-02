/**
 * Owner: Cloud Lending Solutions
 * Usage: Following Future utility helps in resetting primary address flag for  the non primary address records.
 *      
 **/
global with sharing class PrimaryAddressUpdateUtil {
	
	@future
	public static void processRecords(List<ID> accIdSet) {
		// Retrieving all addresses linked from accounts
		if(accIdSet.size() > 0) {
			List<Address__c> addressToUpdate = new List<Address__c>();
			List<Account> accountsWithAddresses = [Select Id, Name, Primary_Address__c,
														(Select Id, Name, Account__c, Primary_Address__c
														From Addresses__r)
													From Account 
													Where Id IN :accIdSet];


			for(Account acc : accountsWithAddresses) {
				for(Address__c address : acc.Addresses__r) {
					// check for non primary addresses and update the primary flag as false
					if(acc.Primary_Address__c != address.Id) {
						address.Primary_Address__c = false;
						addressToUpdate.add(address);
					}
				}
			}

			// update addresses for primary field flag update
			if(addressToUpdate.size() > 0) {
				update addressToUpdate;
			}
		}
	}
}