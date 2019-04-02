@IsTest
public class FMZ_ApplicationPartiesControllerTest {

    @TestSetup
    static void setupApp() {

        cllease__Office_Name__c office = new cllease__Office_Name__c (
                cllease__Office_Short_Name__c = 'HQ',
                Name = 'sample Company'
        );
        insert office;

        clcommon__Legal_Entity__c lentity = new clcommon__Legal_Entity__c(Name = 'Corporation');
        insert lentity;

        Account acc = new Account(
                Name = 'sample Account',
                clcommon__Legal_Entity_Type__c = lentity.Id,
                EIN__c = '123456798',
                Email_Address__c = 'abc123@gmail.com',
                Oracle_Vendor_ID__c = 'Y795'
        );
        insert acc;

        Address__c installAddress = new Address__c (
                Account__c = acc.Id,
                Install_At__c = true
        );
        insert installAddress;

        clcommon__Agreement__c agreement = new clcommon__Agreement__c(Name = 'NewCo');
        insert agreement;

        genesis__Applications__c app = new genesis__Applications__c (
                genesis__Account__c = acc.Id,
                Payment_Method__c = 'ADVANCE',
                genesis__Payment_Frequency__c = 'MONTHLY',
                genesis__Expected_Start_Date__c = Date.today(),
                genesis__Product_Type__c = 'LEASE',
                genesis__Product_Sub_Type__c = 'FINANCE LEASE',
                genesis__Term__c = 12,
                Dealer_Program__c = agreement.Id
        );
        insert app;

    }

    static testMethod void app_getParties_retrieved() {

        genesis__Applications__c app = [SELECT Id, genesis__Account__c FROM genesis__Applications__c];
        Account acc = [SELECT Id FROM Account];

        List<genesis__Application_Parties__c> parties = new List<genesis__Application_Parties__c>{
                new genesis__Application_Parties__c(genesis__Application__c = app.Id, genesis__Party_Account_Name__c = acc.Id,
                        genesis__Party_Type__c = 'LESSEE'),
                new genesis__Application_Parties__c(genesis__Application__c = app.Id, genesis__Party_Account_Name__c = acc.Id,
                        genesis__Party_Type__c = 'DEALER')
        };
        insert parties;

        Test.startTest();

        parties = FMZ_ApplicationPartiesController.getParties(app.Id);

        System.assertEquals(2, parties.size());

        Test.stopTest();

    }

    static testMethod void app_seachParties_found() {

        List<Account> parties = new List<Account> {
            new Account( Name = 'Account 1' ),
            new Account( Name = 'Account 2' ),
            new Account( Name = 'Account 3' )
        };
        insert parties;

        Test.startTest();

        Test.setFixedSearchResults(new List<String>{
            parties[0].Id, parties[1].Id, parties[2].Id
        });

        List<LookupSearchResult> results = FMZ_ApplicationPartiesController.search('Account', new List<String>());

        System.assertEquals(3, results.size());

        Test.stopTest();

    }

    static testMethod void app_addParty_added() {

        genesis__Applications__c app = [SELECT Id, genesis__Account__c FROM genesis__Applications__c];

        Account acc = [SELECT Id FROM Account];

        Test.startTest();

        FMZ_ApplicationPartiesController.addParty(app.Id, acc.Id);

        Test.stopTest();

        genesis__Application_Parties__c appParty =
            [SELECT Id, genesis__Application__c, genesis__Party_Account_Name__c
            FROM genesis__Application_Parties__c];

        System.assertEquals(app.Id, appParty.genesis__Application__c);
        System.assertEquals(acc.Id, appParty.genesis__Party_Account_Name__c);

    }

    static testMethod void app_deleteParty_deleted() {

        genesis__Applications__c app = [SELECT Id, genesis__Account__c FROM genesis__Applications__c];

        Account acc = [SELECT Id FROM Account];

        List<genesis__Application_Parties__c> parties = new List<genesis__Application_Parties__c>{
                new genesis__Application_Parties__c(genesis__Application__c = app.Id, genesis__Party_Account_Name__c = acc.Id,
                        genesis__Party_Type__c = 'LESSEE'),
                new genesis__Application_Parties__c(genesis__Application__c = app.Id, genesis__Party_Account_Name__c = acc.Id,
                        genesis__Party_Type__c = 'BORROWER')
        };
        insert parties;

        Test.startTest();

        FMZ_ApplicationPartiesController.deleteParty(parties[1].Id);

        genesis__Application_Parties__c deleted =
            [SELECT Id FROM genesis__Application_Parties__c WHERE IsDeleted = TRUE ALL ROWS];

        System.assertEquals(parties[1].Id, deleted.Id);

        Test.stopTest();

    }

    static testMethod void app_updateEquipment_updated() {

        genesis__Applications__c app = [SELECT Id, genesis__Account__c FROM genesis__Applications__c];

        Account acc = [SELECT Id FROM Account];

        List<genesis__Application_Parties__c> parties = new List<genesis__Application_Parties__c>{
                new genesis__Application_Parties__c(genesis__Application__c = app.Id, genesis__Party_Account_Name__c = acc.Id,
                        genesis__Party_Type__c = 'DEALER'),
                new genesis__Application_Parties__c(genesis__Application__c = app.Id, genesis__Party_Account_Name__c = acc.Id,
                        genesis__Party_Type__c = 'LESSEE')
        };
        insert parties;

        Test.startTest();

        String appPartyString = '{"Id":"' + parties[0].Id + '", "genesis__Party_Type__c":"LESSEE"}';

        FMZ_ApplicationPartiesController.updateParty(appPartyString);

        genesis__Application_Parties__c updated =
            [SELECT Id, genesis__Party_Type__c
        FROM genesis__Application_Parties__c
        WHERE Id = :parties[0].Id];

        System.assertEquals('LESSEE', updated.genesis__Party_Type__c);

        Test.stopTest();

    }

    static testMethod void app_getPartyTypes_retrieved() {

        List<FMZ_CommunityServices.PicklistOption> partyTypes =
            FMZ_ApplicationPartiesController.getPicklistOptions('genesis__Party_Type__c');

        System.assert(!partyTypes.isEmpty());

    }

}