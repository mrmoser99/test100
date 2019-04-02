/**
 * Created by samuelmeyers on 11/2/18.
 */
@isTest
public with sharing class FMZ_AddressDataQualityExtTest {
    @isTest
    static void AddressDataQualityExtTestConstructor() {
        Address__c address = new Address__c(City__c = 'London');
        ApexPages.StandardController standardController = new ApexPages.StandardController(address);

        FMZ_AddressDataQualityExt addressDataQualityExt = new FMZ_AddressDataQualityExt(standardController);

        System.assertNotEquals(addressDataQualityExt.PageRenderer, null);
        System.assertNotEquals(addressDataQualityExt.PageBody, null);
        System.assertNotEquals(addressDataQualityExt.outputFields, null);
    }
}