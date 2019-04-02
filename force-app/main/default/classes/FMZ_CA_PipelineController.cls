public with sharing class FMZ_CA_PipelineController {
    public static List<String> qqSubmitted= new List<String> {
        'CREDIT SUBMITTED',
        'CREDIT REFERRED'
    };
    public static List<String> qqApproved = new List<String> {
        'CREDIT APPROVED'
    };
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
        statuses.addAll(qqSubmitted);
        statuses.addAll(qqApproved);


        Map<Id, genesis__Quick_Quotes__c> quickQuotes = new Map<Id, genesis__Quick_Quotes__c>([
                SELECT Name, View_Record__c, genesis__Business_Name__c, genesis__Status__c, genesis__Application__c
                FROM genesis__Quick_Quotes__c
                WHERE genesis__Status__c IN: statuses
                ORDER BY CreatedDate DESC, genesis__Status__c
        ]);

        System.debug('!!! quickQuotes: '+quickQuotes);

        List<genesis__Quick_Quotes__c> submittedQQs = new List<genesis__Quick_Quotes__c>();
        List<genesis__Quick_Quotes__c> approvedQQs = new List<genesis__Quick_Quotes__c>();

        if(quickQuotes.size() > 0){
            for(genesis__Quick_Quotes__c qq : quickQuotes.values()){
                if(qqSubmitted.contains(qq.genesis__Status__c)){
                    submittedQQs.add(qq);
                }else if(qqApproved.contains(qq.genesis__Status__c)){
                    approvedQQs.add(qq);
                }
            }
        }
        

        stages.add(new FMZ_CommunityServices.Stage('Credit Checks', 'Submitted',submittedQQs, 'weak', 'standard:assigned_resource'));
        stages.add(new FMZ_CommunityServices.Stage('Credit Checks', 'Credit Approved',approvedQQs, 'weak', 'standard:task2'));

        statuses = new List<String>();
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

        if(applications.size() > 0){
            for(genesis__Applications__c app : applications.values()){
                if(appInProgress.contains(app.genesis__Status__c)){
                    inProgressApps.add(app);
                }else if(appOFACApproved.contains(app.genesis__Status__c)){
                    ofacApps.add(app);
                }
            }
        }

        stages.add(new FMZ_CommunityServices.Stage('Applications', 'In Progress',inProgressApps, 'weak', 'standard:loop'));
        stages.add(new FMZ_CommunityServices.Stage('Applications', 'Ready to Fund',ofacApps, 'success', 'standard:goals'));

        return stages;
    }
}