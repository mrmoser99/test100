/**
 * Created by samuelmeyers on 11/26/18.
 */
@isTest
public with sharing class FMZ_LookupSearchResultTest {
    public static testMethod void lsrTest(){

        LookupSearchResult lsr = new LookupSearchResult(UserInfo.getUserId(), 'User', 'NONE', 'Test Title', 'Test Subtitle');
        System.assertEquals(UserInfo.getUserId(), lsr.getId());
        System.assertEquals('User', lsr.getSObjectType());
        System.assertEquals('NONE', lsr.getIcon());
        System.assertEquals('Test Title', lsr.getTitle());
        System.assertEquals('Test Subtitle', lsr.getSubtitle());

    }
}