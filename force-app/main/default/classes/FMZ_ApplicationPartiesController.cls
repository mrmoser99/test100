public without sharing class FMZ_ApplicationPartiesController {

    @AuraEnabled
    public static List<genesis__Application_Parties__c> getParties(Id applicationId) {

        List<genesis__Application_Parties__c> result =
            [SELECT Id, genesis__Party_Account_Name__c, genesis__Party_Account_Name__r.Name,
                    genesis__Party_Type__c
            FROM genesis__Application_Parties__c
            WHERE genesis__Application__c = :applicationId
            ORDER BY CreatedDate];

        return result;

    }

    private final static Integer MAX_RESULTS = 5;

    @AuraEnabled
    public static List<LookupSearchResult> search(String searchTerm, List<String> selectedIds) {

        searchTerm = '*' + searchTerm + '*';

        WithSharing ws = new WithSharing();
        List<List<SObject>> searchResults = ws.search(searchTerm);

            // Execute search query
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        String partyIcon = 'standard:account';
        Account[] parties = ((List<Account>) searchResults[0]);
        for (Account party : parties) {
            results.add(new LookupSearchResult(party.Id, 'Account', partyIcon, party.Name, null));
        }

        return results;

    }

    @AuraEnabled
    public static void addParty(String applicationId, String accountId) {

        genesis__Application_Parties__c party = new genesis__Application_Parties__c (
            genesis__Application__c = applicationId,
            genesis__Party_Account_Name__c = accountId
            //Install_Account__c = app.genesis__Account__c
        );

        insert party;

    }

    @AuraEnabled
    public static void deleteParty(String appPartyId) {

        genesis__Application_Parties__c party = new genesis__Application_Parties__c ( Id = appPartyId );

        delete party;

    }

    @AuraEnabled
    public static void updateParty(String appPartyString) {

        genesis__Application_Parties__c party  =
            (genesis__Application_Parties__c)JSON.deserialize(appPartyString, genesis__Application_Parties__c.class);

        update party;

    }

	@AuraEnabled
	public static List<FMZ_CommunityServices.PicklistOption> getPicklistOptions(String fieldName){
		return FMZ_CommunityServices.getPicklistOptions('genesis__Application_Parties__c', fieldName);
	}

    public with sharing class WithSharing {
        public List<List<SObject>> search(String searchTerm) {
            return
                [FIND :searchTerm
                IN ALL FIELDS
                    RETURNING
                    Account (Id, Name)
                LIMIT :MAX_RESULTS];
        }
    }

}