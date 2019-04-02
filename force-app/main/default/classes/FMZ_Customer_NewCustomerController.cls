public with sharing class FMZ_Customer_NewCustomerController {

    public static final String CUSTOMER_OBJECT = 'Account';

    @AuraEnabled
    public static List<FMZ_CommunityServices.FieldSetMember> getCustomerFields(String fieldsetName) {

        return FMZ_CommunityServices.getFieldSetMembers(CUSTOMER_OBJECT, fieldSetName);

    }

    @AuraEnabled
    public static Id submitAccount(Account acc, Address__c address) {
        Savepoint sp = Database.setSavepoint();
        try{
            insert acc;
            if(address != null){
                address.Account__c = acc.Id;
                address.Primary_Address__c = true;
                insert address;
                acc.Primary_Address__c = address.Id;
                update acc;
            }
            return acc.Id;
        }catch(exception e){

        }
        return null;
    }

}