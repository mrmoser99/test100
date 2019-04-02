public without sharing class FMZ_ApplicationServiceAndFeesController {
    private static final String OBJECT_NAME = 'Application_Fee__c';

    @AuraEnabled
    public static List<FMZ_CommunityServices.PicklistOption> getPicklistOptions(String fieldName){
        return FMZ_CommunityServices.getPicklistOptions(OBJECT_NAME, fieldName);
    }

    @AuraEnabled
    public static List<FMZ_CommunityServices.PicklistOption> getEquipmentOptions(Id applicationId) {

        List<genesis__Application_Equipment__c> result =
        [SELECT Id, genesis__Equipment__r.Manufacturer__c, genesis__Equipment__r.genesis__Model__c, Serial_Number__c
        FROM genesis__Application_Equipment__c
        WHERE genesis__Application__c = :applicationId
        ORDER BY genesis__Equipment__r.Manufacturer__c, genesis__Equipment__r.genesis__Model__c];

        List<FMZ_CommunityServices.PicklistOption> options = new List<FMZ_CommunityServices.PicklistOption>();
        if(result.size() > 0){
            for(genesis__Application_Equipment__c e : result){
                options.add(new FMZ_CommunityServices.PicklistOption(
                        e.genesis__Equipment__r.Manufacturer__c+' '+e.genesis__Equipment__r.genesis__Model__c + ' ( ' + e.Serial_Number__c + ')', e.Id
                ));
            }
        }

        return options;
    }

    @AuraEnabled
    public static List<Application_Fee__c> getFees(Id applicationId) {

        List<Application_Fee__c> result =
        [SELECT Id, Amount__c, Equipment__c, /*Escalate_Service_On__c, Escalation_Frequency__c, Escalation_Type__c,
                Escalation_Value__c,*/ Fee__c, Fee__r.Name, Fee_Amount__c, Frequency__c, Number_of_Payments__c,
                /*Number_of_Terms__c, Service_Escalation__c,*/ Start_Date__c, /*Service_Escalate__c,*/
                Equipment__r.genesis__Equipment__r.Manufacturer__c,
                Equipment__r.genesis__Equipment__r.genesis__Model__c
        FROM Application_Fee__c
        WHERE Application__c = :applicationId
        ORDER BY CreatedDate];

        return result;

    }

    @AuraEnabled
    public static genesis__Applications__c getApp(Id applicationId) {

        genesis__Applications__c result =
        [SELECT Id, Customer_Provided_Insurance__c
        FROM genesis__Applications__c
        WHERE Id = :applicationId
        LIMIT 1];

        return result;

    }

    @AuraEnabled
    public static String getFeeName(Id feeDefId) {

        List<clcommon__Fee_Definition__c> result =
        [SELECT Id, Name
        FROM clcommon__Fee_Definition__c
        WHERE Id = :feeDefId
        LIMIT 1];

        return result[0].Name;

    }

    private final static Integer MAX_RESULTS = 5;

    @AuraEnabled
    public static List<LookupSearchResult> search(String searchTerm, List<String> selectedIds) {

        if (searchTerm.contains('')) {
            searchTerm = '("*' + searchTerm.trim().replace(' ', '*" AND "*') + '*")';
        } else {
            searchTerm = '*' + searchTerm + '*';
        }

        // Execute search query
        List<List<SObject>> searchResults = [
                FIND :searchTerm
                IN ALL FIELDS
                        RETURNING
                        clcommon__Fee_Definition__c (Id, Name, clcommon__Amount__c, clcommon__Taxable__c, RateFactor__c)
                LIMIT :MAX_RESULTS
        ];

        List<LookupSearchResult> results = new List<LookupSearchResult>();

        String feeIcon = 'standard:partner_marketing_budget';
        clcommon__Fee_Definition__c [] fees = ((List<clcommon__Fee_Definition__c>) searchResults[0]);
        for (clcommon__Fee_Definition__c f : fees) {
            results.add(new LookupSearchResult(
                    f.Id, 'clcommon__Fee_Definition__c', feeIcon,
                    f.Name, f.clcommon__Taxable__c ? 'Taxable' : 'Non-Taxable'));
        }
        System.debug('!!!' + results);
        return results;

    }

    @AuraEnabled
    public static Id addFees(String applicationId, String feeId) {
        Application_Fee__c fee = new Application_Fee__c (
            Application__c = applicationId,
            Fee__c = feeId
        );
        insert fee;

        return fee.Id;
    }

    @AuraEnabled
    public static void addAllFees(Application_Fee__c fee, List<String> equipment){
        System.debug('!!!'+equipment);
        List<Application_Fee__c> fees = new List<Application_Fee__c>();
        if(equipment!=null && equipment.size()>0){
            for(String e : equipment){
                Application_Fee__c clonedFee = fee.clone(false,true,false,false);
                clonedFee.Equipment__c = e;
                fees.add(clonedFee);
                System.debug('!!!'+clonedFee.Frequency__c);
            }
        }else{
            fees.add(fee);
        }
        insert fees;
    }

    @AuraEnabled
    public static void deleteFee(String appFeeId) {

        List<Application_Fee_Payment__c> payments = [
                SELECT Id
                FROM Application_Fee_Payment__c
                WHERE Application_Fee__c =: appFeeId];

        delete payments;

        Application_Fee__c fee = new Application_Fee__c( Id = appFeeId );

        delete fee;

    }

    @AuraEnabled
    public static void updateFee(String feeString) {
        System.debug('!!!'+feeString);
        Application_Fee__c fee = (Application_Fee__c)JSON.deserialize(feeString, Application_Fee__c.class);
        //System.debug('!!!'+fee.Escalation_Frequency__c);
        update fee;
    }

    @AuraEnabled
    public static void updateApplication(String appId, Boolean customerInsurance) {
        genesis__Applications__c app = new genesis__Applications__c(Id = appId, Customer_Provided_Insurance__c = customerInsurance);
        System.debug('!!!'+app.Customer_Provided_Insurance__c);
        update app;
    }
}