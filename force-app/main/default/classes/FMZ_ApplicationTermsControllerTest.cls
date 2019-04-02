@isTest
public class FMZ_ApplicationTermsControllerTest {

    @TestSetup
    static void setupApp() {

        cllease__Office_Name__c office = new cllease__Office_Name__c (
                cllease__Office_Short_Name__c = 'HQ',
                Name = 'sample Company'
        );
        insert office;

        clcommon__Legal_Entity__c lentity = new clcommon__Legal_Entity__c( Name = 'Corporation' );
        insert lentity;

        Account acc = new Account(
                Name = 'sample Account',
                clcommon__Legal_Entity_Type__c = lentity.Id,
                EIN__c = '123456798',
                Email_Address__c = 'abc123@gmail.com',
                Oracle_Vendor_ID__c = 'Y795'
        );
        insert acc;

        clcommon__Agreement__c agreement = new clcommon__Agreement__c( Name = 'NewCo' );
        insert agreement;

        genesis__Applications__c app = new  genesis__Applications__c (
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

    static testMethod void app_getTerms_returned() {

        genesis__Applications__c app = [SELECT Id, genesis__Payment_Frequency__c FROM genesis__Applications__c];

        Test.startTest();

        genesis__Applications__c app2 = FMZ_ApplicationTermsController.getApplicationTerms(app.Id);

        System.assertEquals(app.Id, app2.Id);
        System.assertEquals(app.genesis__Payment_Frequency__c, app2.genesis__Payment_Frequency__c);

        Test.stopTest();

    }

    static testMethod void app_updateTerm_updated() {

        genesis__Applications__c app = [SELECT Id FROM genesis__Applications__c];

        String appString = '{"Id":"' + app.Id + '", "genesis__Term__c":36}';

        Test.startTest();

        FMZ_ApplicationTermsController.updateApplicationTerms(appString);

        Test.stopTest();

        app = [SELECT Id, genesis__Term__c FROM genesis__Applications__c];

        System.assertEquals(36, app.genesis__Term__c);

    }

}