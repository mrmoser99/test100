/**
 * Created by samuelmeyers on 11/2/18.
 */
@isTest
public with sharing class FMZ_CA_PipelineControllerTest { 

    private static testmethod void testgetStages(){
        List<FMZ_CommunityServices.Stage> stages = new List<FMZ_CommunityServices.Stage>();

        clcommon__Agreement__c testAgreement = new clcommon__Agreement__c();
        testAgreement.Name = 'NewCo';
        insert testAgreement;
        
        genesis__Applications__c testNewGenApps = new genesis__Applications__c();
        testNewGenApps.genesis__Status__c = 'NEW - CREDIT PULLED';
        insert testNewGenApps;
        
        genesis__Applications__c testAppGenApps = new genesis__Applications__c();
        testAppGenApps.genesis__Status__c = 'APPROVED - APPROVED';
        insert testAppGenApps;
        
        genesis__Applications__c testConvGenApps = new genesis__Applications__c();
        testConvGenApps.genesis__Status__c = 'APPROVED - CONVERTED TO CONTRACT';
        insert testConvGenApps;

        stages = FMZ_CA_PipelineController.getStages();

        System.assertEquals('Submitted', stages[0].label);
        System.assertEquals('Credit Approved', stages[1].label);
        System.assertEquals('In Progress', stages[2].label);
        System.assertEquals('Ready to Fund', stages[3].label);

    }

}