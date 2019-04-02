/**
 * Owner: Cloud Lending Solutions
 * Usage: Following Test class helps in testing the primary address update functionality
 *      
 **/
@isTest
public with sharing class TestPrimaryAddressUpdate {
	
	@isTest
	public static void testAccountPrimaryAddressUpdate() {
		// Creating Account with Lessee type
		RecordType lessee 	= [SELECT Id FROM RecordType WHERE DeveloperName = 'Lessee'AND SobjectType = 'Account'AND IsActive = true limit 1];                                    
        Account a 			= genesis.TestHelper.createAccount();
        a.RecordTypeId 		= lessee.id;
        upsert a;

        // Creating Address
        RecordType lesseeAdd = [SELECT Id FROM RecordType WHERE DeveloperName = 'Lessee'  AND SobjectType = 'Address__c'  AND IsActive = true limit 1];  
        List<Address__c> addressToInsert = new List<Address__c>(); 
        Address__c address 		= new Address__c();
        address.RecordTypeId 	= lesseeAdd.Id;
        address.Country__c 		= 'USA';
        address.Bill_To_Usage__c= false;
        address.Install_At__c 	= true;
        address.Primary_Address__c = true;
        address.Account__c 		= a.Id;
        addressToInsert.add(address);

        Address__c address2 		= new Address__c();
        address2.RecordTypeId 		= lesseeAdd.Id;
        address2.Country__c 		= 'USA';
        address2.Bill_To_Usage__c 	= true;
        address2.Install_At__c 		= false;
        address2.Account__c 		= a.Id;
        addressToInsert.add(address2);

        insert addressToInsert;

        // validating address's primary address field
        Id accId = a.Id;
        Account accountToValidate = [SELECT Id, Primary_Address__c FROM Account Where Id = :accId];
        System.debug(LoggingLevel.ERROR, ' account details: '+accountToValidate);

        System.assert(accountToValidate.Primary_Address__c == address.Id);

	}
}