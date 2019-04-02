/**
 * Created by samuelmeyers on 11/2/18.
 */
@isTest
public with sharing class FMZ_APP_PipelineControllerTest {
    
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

        stages = FMZ_APP_PipelineController.getStages();

        System.assertEquals('New', stages[0].label);
        System.assertEquals('In Progress', stages[1].label);
        System.assertEquals('Booked', stages[2].label);
        System.assertEquals('Withdrawn', stages[3].label);
        
        List<genesis__Applications__c> genApp = stages[0].values;
        System.assertEquals('NEW - CREDIT PULLED', genApp[0].genesis__Status__c);
        
        List<genesis__Applications__c> genAppApproved = stages[1].values;
        System.assertEquals('APPROVED - APPROVED', genAppApproved[0].genesis__Status__c);
        
        List<genesis__Applications__c> genAppConv = stages[2].values;
        System.assertEquals('APPROVED - CONVERTED TO CONTRACT', genAppConv[0].genesis__Status__c);

    }

}