/**
 * Created by samuelmeyers on 11/26/18.
 */
@isTest
public with sharing class FMZ_NewAddressControllerTest {

    public testMethod static void getMatchesTest(){
        Test.setMock(HttpCalloutMock.class, new FMZ_EDQAddressCalloutMock());
        List<FMZ_EDQ_Address_Callout.Match> matches = FMZ_NewAddressController.getMatches('10 Main');
        System.assertEquals(2, matches.size());
    }

    public testMethod static void getFormatTest(){
        Test.setMock(HttpCalloutMock.class, new FMZ_EDQAddressCalloutMock());
        FMZ_EDQ_Address_Callout.Address address = FMZ_NewAddressController.getFormat('https://api.edq.com/capture/address/v2/format?country=USA&id=b83c0b90-b221-48db-a877-b6cf06f857d9_U40_24_0_0_0%3D10%24QL7%24GEO0');
        System.assertNotEquals(null, address);
    }

    public testMethod static void createAddressTest(){
        Account acc = new Account (
                Name = 'sample Account',
                EIN__c = '12-1234567',
                Email_Address__c='abc123@gmail.com',
                Oracle_Vendor_ID__c='Y795'
        );
        insert acc;

        Address__c address = new Address__c (
                Account__c = acc.Id,
                Address_Line_1__c = '123 Main Street',
                City__c = 'Morristown',
                State__c = 'NJ',
                County__c = 'Morris',
                Country__c = 'USA',
                Install_At__c = true
        );

        FMZ_NewAddressController.createAddress(address);
        List<Address__c> addrs = [SELECT Id FROM Address__c WHERE Account__c =: acc.Id];
        System.assertEquals(1, addrs.size());
    }

    public testMethod static void getAddress(){
        Account acc = new Account (
                Name = 'sample Account',
                EIN__c = '12-1234567',
                Email_Address__c='abc123@gmail.com',
                Oracle_Vendor_ID__c='Y795'
        );
        insert acc;

        Address__c address = new Address__c (
                Account__c = acc.Id,
                Address_Line_1__c = '123 Main Street',
                City__c = 'Morristown',
                State__c = 'NJ',
                County__c = 'Morris',
                Country__c = 'USA',
                Install_At__c = true
        );
        insert address;

        Address__c addr1 = FMZ_NewAddressController.getAddress(acc.Id);
        Address__c addr2 = FMZ_NewAddressController.getAddress(address.Id);

        System.assertEquals(acc.Id, addr1.Account__c);
        System.assertEquals(address.Id, addr2.Id);
    }

}