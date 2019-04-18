public without sharing class FMZ_ApplicationConvertToLeaseController {

	@AuraEnabled
	public static genesis__Applications__c getApplication(Id applicationId) {

		genesis__Applications__c result =
			[SELECT Id, genesis__Status__c, Lease_Number__c, Lease_Number__r.cllease__Lease_Status__c
			FROM genesis__Applications__c
			WHERE Id = :applicationId];

		return result;

	}

	@AuraEnabled
	public static String convert(Id applicationId) {

		try {

			genesis__Applications__c app =
				[SELECT Id, genesis__Status__c, Lease_Number__c
				FROM genesis__Applications__c
				WHERE Id = :applicationId];

			if (app.Lease_Number__c != null) {
				return 'A funding request has already been created for this application';
			}

			// CREDIT APPROVED is API value for OFAC APROVED
			if (app.genesis__Status__c != 'CREDIT APPROVED') {
				return 'The application must be completed and approved before it can be funded';
			}

			List<Equipment_Funding_Detail__c> funding =
				[SELECT Id, Party__c
				FROM Equipment_Funding_Detail__c
				WHERE Application__c = :applicationId
				AND Party__c = NULL];
			if (!funding.isEmpty()) {
				fixDealerParty(applicationId, funding);
			}

			String result = genesis.ConvertApplicationCtrl.convertApplicationToContract(applicationId);
			System.debug('!!! Result from Convert to Contract: '+result);
			if (String.isNotBlank(result) && result.contains('EXCEPTION, ')) {
				result = getResultException(result);
			}else if(result == 'Application is converted to contract successfully'){
				app.genesis__Status__c = 'APPROVED - CONVERTED TO CONTRACT';
				update app;
			}

			return result;

		} catch(Exception e) {
			System.debug(e.getStackTraceString());
			throw new AuraHandledException(e.getMessage());
		}

	}

	@TestVisible
	private static String getResultException(String result){
		String outputResult;
		String[] splitResult = result.split('EXCEPTION, ');
		if (splitResult.size() > 1) {
			outputResult = splitResult[1];
			if (outputResult.contains(': [')) {
				splitResult = outputResult.split(': \\[');
				outputResult = splitResult[0];
			}
		}
		return outputResult;
	}

	// add the dealer party if they aren't added already
	// set the dealer on the equipment funding record
	private static void fixDealerParty(Id applicationId, List<Equipment_Funding_Detail__c> funding) {

		List<clcommon__Party__c>  dealerParty =
			[SELECT Id
			FROM clcommon__Party__c
			WHERE genesis__Application__c = :applicationId
			AND clcommon__Type__r.Name = 'DEALER'
			LIMIT 1];

		if (dealerParty.isEmpty()) {

			List<clcommon__Party_Type__c> dealerType =
				[SELECT Id
				FROM clcommon__Party_Type__c
				WHERE Name = 'DEALER'];

			if (dealerType.isEmpty()) {
				return;
			}

			List<User> u =
				[SELECT Id, AccountId
				FROM User
				WHERE Id = :UserInfo.getUserId()];

			if (u.isEmpty() || u[0].AccountId == null) {
				return;
			}

			dealerParty = new List<clcommon__Party__c>{
				new clcommon__Party__c (
					genesis__Application__c = applicationId,
					clcommon__Type__c = dealerType[0].Id,
					clcommon__Account__c = u[0].AccountId
				)
			};
			insert dealerParty;

		}

		for (Equipment_Funding_Detail__c efd : funding) {
			efd.Party__c = dealerParty[0].Id;
		}
		update funding;

	}

}