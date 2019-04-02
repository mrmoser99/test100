/**
 * Created by samuelmeyers on 11/12/18.
 */

public without sharing class FMZ_NewAddressController {
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