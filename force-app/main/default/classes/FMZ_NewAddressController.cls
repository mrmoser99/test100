/**
 * Created by samuelmeyers on 11/12/18.
 */

public without sharing class FMZ_NewAddressController {

    @AuraEnabled
    public static Address__c getAddress(Id recordId){
        Address__c addr = new Address__c();

        if(recordId != null){
            if(recordId.getSobjectType() == Account.sObjectType){
                addr.Account__c = recordId;
            }else if(recordId.getSobjectType() == Address__c.sObjectType){
                addr = [
                        SELECT Id, Account__c, Address_Line_1__c, Address_Line_2__c, City__c, County__c, Country__c, State__c,
                                Zip_Code__c, Validation_Time_Stamp__c, Validation_Status__c, Bill_To_Usage__c, Primary_Address__c,
                                Install_At__c
                        FROM Address__c
                        WHERE Id=:recordId
                ];
            }
        }
        return addr;
    }

    @AuraEnabled
    public static List<FMZ_EDQ_Address_Callout.Match> getMatches(String addressString){
        return FMZ_EDQ_Address_Callout.getAddressMatches(addressString);
    }

    @AuraEnabled
    public static FMZ_EDQ_Address_Callout.Address getFormat(String formatUrl){
        return FMZ_EDQ_Address_Callout.getAddressFormat(formatUrl);
    }

    @AuraEnabled
    public static void createAddress(Address__c address){
        address.Install_At__c = true;
        insert address;
    }
}