/**
 * Created by samuelmeyers on 12/11/18.
 */
@isTest
public class FMZ_WelcomeMessageControllerTest {
    @isTest
    public static void getWelcomeMessage(){
        FMZ_Welcome_Message__c message = FMZ_Welcome_Message__c.getOrgDefaults();
        message.Text_Color_Hex_Code__c = '000000';
        message.Background_Color_Hex_Code__c = '999999';
        message.Title__c = 'TEST TITLE';
        message.Subtitle__c = 'TEST SUBTITLE';
        insert message;

        FMZ_WelcomeMessageController.MessageSetting setting = FMZ_WelcomeMessageController.getWelcomeMessage();

        System.assert(setting != null);
    }
}