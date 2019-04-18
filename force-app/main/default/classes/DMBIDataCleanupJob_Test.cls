@isTest public class DMBIDataCleanupJob_Test {
    public static testmethod void validateCleanUpJob(){
        int_agreement__c agr = DMBIInterfaceJobDataFactory.createagreement();
        agr.Committed__c = true;
        update agr;
        int_file_control__c fc = DMBIInterfaceJobDataFactory.createFilecontrol();
        Int_Asset__c asset = DMBIInterfaceJobDataFactory.createAsset();
        int_party__c party = DMBIInterfaceJobDataFactory.createEParty();
        int_delivery_control__c dc = DMBIInterfaceJobDataFactory.createDeliverycontrol();
        int_party_feature__c pf = DMBIInterfaceJobDataFactory.createPartyFeature(agr); 
        Int_Agreement_line_Feature__c ial = DMBIInterfaceJobDataFactory.createAgrlinefeature(agr);
        Int_Agreement_Party__c iap = DMBIInterfaceJobDataFactory.createAgrParty(agr);
        Int_Agreement_Exposure__c ae = DMBIInterfaceJobDataFactory.createAgrExposure(agr);
        Int_Agreement_Classification__c ac =DMBIInterfaceJobDataFactory.createAgrClassification(agr);
        /*Int_Party_External_Reference__c per = DMBIInterfaceJobDataFactory.createExernalRef(agr);
         Int_Party_Street_Address__c psa = DMBIInterfaceJobDataFactory.createStreetAddress(agr);
Int_Agreement_Payment_Schedule__c aps = DMBIInterfaceJobDataFactory.createpaymentShedule(agr);
        */
        List<String> ObjectSet = new List<string>{'Int_Agreement_Classification__c','Int_Agreement_Exposure__c','Int_Agreement_Party__c','Int_Agreement_line_Feature__c','int_party_feature__c','int_party__c','Int_Asset__c','Int_file_control__c','Int_Delivery_control__c','Int_Agreement__c'};
            for(string ObjectName : ObjectSet){
                Database.executeBatch(new DMBIDataCleanUpJob(ObjectName),1000);
        
             }
     }
}