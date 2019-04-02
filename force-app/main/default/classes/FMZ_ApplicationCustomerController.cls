public without sharing class FMZ_ApplicationCustomerController {

	@AuraEnabled
	public static Account getAccount(Id applicationId) {
		Account acct =
			[SELECT Id, Name, Phone, Email_Address__c, EIN__c
			FROM Account
			WHERE Id IN
				(SELECT genesis__Account__c
				FROM genesis__Applications__c
				WHERE Id = :applicationId)];
		return acct;
	}

	@AuraEnabled
	public static void updateAccount(Account acct) {
		update acct;
	}

}