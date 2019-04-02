@isTest
public with sharing class AddressDataQualityExtTest {
	static testMethod void AddressDataQualityExtTestConstructor() {
		Address__c address = new Address__c(City__c = 'London');	
		ApexPages.StandardController standardController = new ApexPages.StandardController(address);
		
		AddressDataQualityExt addressDataQualityExt = new AddressDataQualityExt(standardController);
		
		System.assertNotEquals(addressDataQualityExt.PageRenderer, null);
	}	
}