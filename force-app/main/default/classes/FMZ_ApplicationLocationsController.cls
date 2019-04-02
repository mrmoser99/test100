public without sharing class FMZ_ApplicationLocationsController {

	@AuraEnabled
	public static List<Address__c> getLocations(Id applicationId) {

		genesis__Applications__c app =
			[SELECT Id, genesis__Account__c FROM genesis__Applications__c
			WHERE Id = :applicationId];

		List<Address__c> result =
			[SELECT Id, Address_Line_1__c, City__c, State__c, Zip_Code__c, County__c, Install_At__c
			FROM Address__c
			WHERE Account__c = :app.genesis__Account__c];

		return result;

	}

	@AuraEnabled
	public static String getAppAccount(Id applicationId) {

		genesis__Applications__c app =
		[SELECT Id, genesis__Account__c FROM genesis__Applications__c
		WHERE Id = :applicationId];

		return app.genesis__Account__c;

	}

	private final static Integer MAX_RESULTS = 5;

	@AuraEnabled
	public static List<LookupSearchResult> search(String searchTerm, List<String> selectedIds) {

		searchTerm = '*' + searchTerm + '*';

		// Execute search query
		List<List<SObject>> searchResults = [
			FIND :searchTerm
			IN ALL FIELDS
				RETURNING
				Account (Id, Name)
			LIMIT :MAX_RESULTS
		];

		List<LookupSearchResult> results = new List<LookupSearchResult>();

		String partyIcon = 'standard:address';
		Account[] parties = ((List<Account>) searchResults[0]);
		for (Account party : parties) {
			results.add(new LookupSearchResult(party.Id, 'Account', partyIcon, party.Name, null));
		}

		return results;

	}

	@AuraEnabled
	public static void addLocation(String applicationId, String addressString) {

		genesis__Applications__c app =
			[SELECT Id, genesis__Account__c FROM genesis__Applications__c
			WHERE Id = :applicationId];

		Address__c newAddress = (Address__c)JSON.deserialize(addressString, Address__c.class);
		newAddress.Install_At__c = true;
		newAddress.Account__c = app.genesis__Account__c;

		insert newAddress;

	}

	@AuraEnabled
	public static void deleteLocation(String addressId) {

		Address__c address = new Address__c ( Id = addressId );

		delete address;

	}

	@AuraEnabled
	public static void updateLocation(String addressString) {

		Address__c address = (Address__c)JSON.deserialize(addressString, Address__c.class);
		update address;

	}

}