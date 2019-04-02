public with sharing class TerminationQuoteCtrl {
	public cllease__Lease_Account__c contract;
	public cllease__Termination_Quote_Header__c quoteHeader;
	public List<cllease__Termination_Quote_Equipment__c> quoteEquimentsList;
	public List<cllease__Termination_Quote_Line__c> quoteLineList;

	public TerminationQuoteCtrl(ApexPages.StandardController controller) {
		contract = [Select Id, Name From cllease__Lease_Account__c Where Name = ''];
		// Creating Mockup data for Custom Termination Details
		quoteHeader = new cllease__Termination_Quote_Header__c(

		);
		//quoteHeader


		// Selected Quote Equipments
		quoteEquimentsList = new List<cllease__Termination_Quote_Equipment__c>();
		quoteEquimentsList.add(new cllease__Termination_Quote_Equipment__c(
			
			)
		);

		// Select Quote Lines
		quoteLineList = new List<cllease__Termination_Quote_Line__c>();
		quoteLineList.add(new cllease__Termination_Quote_Line__c(
			
			)
		);

	}
}