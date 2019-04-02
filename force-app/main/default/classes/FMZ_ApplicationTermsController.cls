public without sharing class FMZ_ApplicationTermsController {

    @AuraEnabled
    public static genesis__Applications__c getApplicationTerms(Id applicationId) {

        genesis__Applications__c result =
            [SELECT Id, genesis__Term__c, Rate_Card_Selection__c,
                    genesis__Payment_Frequency__c
            FROM genesis__Applications__c
            WHERE Id = :applicationId];

        return result;

    }

    @AuraEnabled
    public static void updateApplicationTerms(String applicationString) {

        genesis__Applications__c applications =
                (genesis__Applications__c)JSON.deserialize(applicationString, genesis__Applications__c.class);

        update applications;

    }

}