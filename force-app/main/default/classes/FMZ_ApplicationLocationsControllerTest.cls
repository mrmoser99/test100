@IsTest
public class FMZ_ApplicationLocationsControllerTest {
    
    private static genesis__Applications__c application;
    private static genesis__Company__c company;
    private static genesis__Rate_Card_Setup_Header__c rateCard;
    private static clcommon__CL_Product__c product;
    private static clcommon__Legal_Entity__c lentity;
    private static RecordType dealerRT;
    private static Account acc;
    private static clcommon__Agreement__c dealerProgram;
    
    private static void setUp(){
        company = new genesis__Company__c (
            Name = 'DeLage Landen',
            genesis__Short_Name__c = 'HQ',
            genesis__Default__c = true,
            genesis__Enabled_Flag__c = true
        );
        insert company;
        
        rateCard = new genesis__Rate_Card_Setup_Header__c (
            Name = 'Fair Market Value',
            genesis__Product_Type__c = 'LEASE',
            genesis__Company__c = company.Id,
            genesis__Start_Date__c = Date.today().addYears(-1),
            genesis__End_Date__c = Date.today().addYears(2),
            genesis__Transaction_Date__c = Date.today().addMonths(-1),
            genesis__Enabled_Flag__c = true
        );
        insert rateCard;
        
        product = new clcommon__CL_Product__c (
            clcommon__Product_Name__c = 'FINANCE LEASE'
        );
        insert product;
        
        lentity = new clcommon__Legal_Entity__c( Name = 'Corporation' );
        insert lentity;

        dealerRT = [SELECT Id FROM RecordType WHERE Name = 'Dealer' AND SobjectType = 'Account'];
        Account dealer = new Account ( Name = 'Dealer', RecordTypeId = dealerRT.Id );
        insert dealer;
        
        acc = new Account (
                Name = 'sample Account',
                clcommon__Legal_Entity_Type__c = lentity.Id,
                EIN__c='123456798',
                Email_Address__c='abc123@gmail.com',
                Oracle_Vendor_ID__c='Y795'
        );
        insert acc;
                
        dealerProgram = new clcommon__Agreement__c (
            Name = 'NewCo',
            CL_Product__c = product.Id,
            Rate_Card__c = rateCard.Id
        );
        insert dealerProgram;

        
        application = new genesis__Applications__c (
            genesis__CL_Product__c = product.Id,
            Dealer__c = dealer.Id,
            genesis__Account__c = acc.Id,
            Dealer_Invoice_Number__c = '123456',
            Dealer_Invoice_Date__c = Date.today(),
            //genesis__Term__c = 12,
            Dealer_Program__c = dealerProgram.Id,
            genesis__Expected_Start_Date__c = Date.today().addMonths(1),
            genesis__Expected_Close_Date__c = Date.today().addMonths(12),
            genesis__Product_Type__c = 'LEASE',
            genesis__Product_Sub_Type__c = 'FINANCE LEASE',
            genesis__Company__c = company.Id,
            Purchase_Option__c = 'Fair Market Value',
            genesis__Financed_Amount__c = 999.99
        );
        insert application;
    }
    
    private static testmethod void testGetLocations(){
        setUp();
        Address__c address = new Address__c(
            Address_Line_1__c = 'Main Street', 
            City__c = 'Denver', 
            State__c = 'CO', 
            Zip_Code__c = '80001',
            Account__c = acc.id
        );
        insert address;
        
        List<Address__c> accAddress = FMZ_ApplicationLocationsController.getLocations(application.id);
        
        System.assertEquals('80001', accAddress[0].Zip_Code__c);
    }
    
    private static testmethod void testAddLocation(){
        setUp();
        
        String newLocation = '{"Address": "111 Main Street", "City": "Parker", "State" :"CO", "Zip" :"80001"}';
        
        FMZ_ApplicationLocationsController.addLocation(application.id, newLocation);
        
        List<Address__c> result =
			[SELECT Id, Address_Line_1__c, City__c, State__c, Zip_Code__c, County__c, Install_At__c
			FROM Address__c
			WHERE Account__c = :acc.id];
        
        System.assertEquals(true, result[0].Install_At__c);
        
        
    }
    
    private static testmethod void testDeleteLocation(){
        setUp();
        
        String newLocation = '{"Address": "111 Main Street", "City": "Parker", "State" :"CO", "Zip" :"80001"}';
        
        FMZ_ApplicationLocationsController.addLocation(application.id, newLocation);
        
        List<Address__c> result =
			[SELECT Id, Address_Line_1__c, City__c, State__c, Zip_Code__c, County__c, Install_At__c
			FROM Address__c
			WHERE Account__c = :acc.id];
        
        System.assertEquals(1, result.size());
        
        FMZ_ApplicationLocationsController.deleteLocation(result[0].Id);
        
        List<Address__c> result1 =
			[SELECT Id, Address_Line_1__c, City__c, State__c, Zip_Code__c, County__c, Install_At__c
			FROM Address__c
			WHERE Account__c = :acc.id];
        
        System.assertEquals(0, result1.size());

    }
    
    private static testmethod void testUpdateLocation(){
        setUp();
        Address__c address = new Address__c(
            Address_Line_1__c = 'Main Street', 
            City__c = 'Denver', 
            State__c = 'CO', 
            Zip_Code__c = '80001',
            Account__c = acc.id
        );
        insert address;
        
        List<Address__c> accAddress = FMZ_ApplicationLocationsController.getLocations(application.id);
        
        System.assertEquals('Denver', accAddress[0].City__c);
        String newLocation = '{"Id":"'+accAddress[0].id+'","Address_Line_1__c":"Main Street","City__c":"Parker","State__c":"CO","Zip_Code__c":"80001","Install_At__c":false}';
        FMZ_ApplicationLocationsController.updateLocation(newLocation);
        
        List<Address__c> accAddressnew = FMZ_ApplicationLocationsController.getLocations(application.id);
        
        System.assertEquals('Parker', accAddressnew[0].City__c);
    }
    
    private static testmethod void testSearch(){
        setUp();
        List<String> selectedIds = new List<String>();
        
        List<LookupSearchResult> results = FMZ_ApplicationLocationsController.search('001', selectedIds);
        
        System.debug('results---------------: '+results);
        
        
        

    }

}