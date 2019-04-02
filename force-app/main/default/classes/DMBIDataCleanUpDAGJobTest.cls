@isTest
public with sharing class DMBIDataCleanUpDAGJobTest {
	
	@isTest
	public static void validateCleanUpJob(){
        int_agreement__c agr = DMBIInterfaceJobDataTestFactory.createagreement();
        agr.Committed__c = true;
        update agr;

        // Creating Interface Object Records through Test Factory
        int_file_control__c fc 				= DMBIInterfaceJobDataTestFactory.createFilecontrol();
        Int_Asset__c asset 					= DMBIInterfaceJobDataTestFactory.createAsset();
        int_party__c party 					= DMBIInterfaceJobDataTestFactory.createEParty();
        int_delivery_control__c dc 			= DMBIInterfaceJobDataTestFactory.createDeliverycontrol();
        int_party_feature__c pf 			= DMBIInterfaceJobDataTestFactory.createPartyFeature(agr); 
        Int_Agreement_line_Feature__c ial 	= DMBIInterfaceJobDataTestFactory.createAgrlinefeature(agr);
        Int_Agreement_Party__c iap 			= DMBIInterfaceJobDataTestFactory.createAgrParty(agr);
        Int_Agreement_Exposure__c ae 		= DMBIInterfaceJobDataTestFactory.createAgrExposure(agr);
        Int_Agreement_Classification__c ac 	= DMBIInterfaceJobDataTestFactory.createAgrClassification(agr);
       
   		List<String> ObjectSet = new List<string>{
   					'Int_Agreement_Classification__c',
   					'Int_Agreement_Exposure__c',
   					'Int_Agreement_Party__c',
   					'Int_Agreement_line_Feature__c',
   					'int_party_feature__c',
   					'int_party__c',
   					'Int_Asset__c',
   					'Int_file_control__c',
   					'Int_Delivery_control__c',
   					'Int_Agreement__c'};
        for(string ObjectName : ObjectSet){
            Database.executeBatch(new DMBIDataCleanUpDAGJob(ObjectName), 1000);
         }
    }

    @isTest
	public static void validateScheduleJob(){
        int_agreement__c agr = DMBIInterfaceJobDataTestFactory.createagreement();
        agr.Committed__c = true;
        update agr;

        // Creating Interface Object Records through Test Factory
        int_file_control__c fc 				= DMBIInterfaceJobDataTestFactory.createFilecontrol();
        Int_Asset__c asset 					= DMBIInterfaceJobDataTestFactory.createAsset();
        int_party__c party 					= DMBIInterfaceJobDataTestFactory.createEParty();
        int_delivery_control__c dc 			= DMBIInterfaceJobDataTestFactory.createDeliverycontrol();
        int_party_feature__c pf 			= DMBIInterfaceJobDataTestFactory.createPartyFeature(agr); 
        Int_Agreement_line_Feature__c ial 	= DMBIInterfaceJobDataTestFactory.createAgrlinefeature(agr);
        Int_Agreement_Party__c iap 			= DMBIInterfaceJobDataTestFactory.createAgrParty(agr);
        Int_Agreement_Exposure__c ae 		= DMBIInterfaceJobDataTestFactory.createAgrExposure(agr);
        Int_Agreement_Classification__c ac 	= DMBIInterfaceJobDataTestFactory.createAgrClassification(agr);
       
   		// Running the Scheduled job
   		DMBIDataCleanUpScheduleJob scheduler = new DMBIDataCleanUpScheduleJob();
   		scheduler.execute(null);
    }

    @isTest
    public static void ValidateDMBIInterfaceJob(){
        list<cllease__Lease_Account__c> LeaseContactList = new list<cllease__Lease_Account__c>();
        LeaseContactList.add(TestHelper.createContract());
        DMBIInterfaceDAGJob DIJ = new DMBIInterfaceDAGJob();
        DataBase.executeBatch(DIJ, 50);
    }

}