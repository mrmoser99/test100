public with sharing class FMZ_APP_PipelineController {

    public static List<String> appInProgress = new List<String> {
        'NEW - CREDIT PULLED',
        'NEW - ENTERED',
        'NEW - IN CREDIT CHECK',
        'APPROVED - APPROVED',
        'NEW - IN REVIEW',
        'NEW - PRICING GENERATED',
        'NEW - CHECKLIST GENERATED'
    };
    public static List<String> appOFACApproved = new List<String> {
        'CREDIT APPROVED'
    };

    @AuraEnabled
    public static List<FMZ_CommunityServices.Stage> getStages(){
        List<FMZ_CommunityServices.Stage> stages = new List<FMZ_CommunityServices.Stage>();

        List<String> statuses = new List<String>();
        statuses.addAll(appInProgress);
        statuses.addAll(appOFACApproved);


        Map<Id, genesis__Applications__c> applications = new Map<Id, genesis__Applications__c>([
                SELECT Name, View_Record__c, genesis__Status__c, genesis__Bank_Name__c
                FROM genesis__Applications__c
                WHERE genesis__Status__c IN: statuses
                ORDER BY CreatedDate DESC, genesis__Status__c
        ]);

        System.debug('!!! applications: '+applications );

        List<genesis__Applications__c> inProgressApps = new List<genesis__Applications__c>();
        List<genesis__Applications__c> ofacApps = new List<genesis__Applications__c>();

        for(genesis__Applications__c app : applications.values()){
            if(appInProgress.contains(app.genesis__Status__c)){
                inProgressApps.add(app);
            }else if(appOFACApproved.contains(app.genesis__Status__c)){
                ofacApps.add(app);
            }
        }

        stages.add(new FMZ_CommunityServices.Stage('Application', 'In Progress',inProgressApps, 'weak', 'standard:loop'));
        stages.add(new FMZ_CommunityServices.Stage('Application', 'Booked',ofacApps, 'success', 'standard:goals'));

        System.debug('!!! stages: '+stages);

        return stages;
    }
}