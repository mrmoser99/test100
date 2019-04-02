global class DMBIDataCleanUpScheduleJob implements Schedulable {
    global void execute(SchedulableContext sc) {
        List<String> ObjectSet = new List<string>{'Int_Agreement_Payment_Schedule__c','Int_Agreement_Feature__c','Int_Agreement_Classification__c','Int_Agreement_Line__c','Int_Asset__c','Int_Agreement_Line_Asset__c','Int_Collateral__c','Int_Collateral_Agreement__c','Int_Collateral_Party__c','Int_Agreement_Exposure__c','Int_Agreement_Interest__c','Int_Party__c','Int_Agreement_Party__c','Int_Party_Street_Address__c','Int_Party_External_Reference__c','Int_file_control__c','Int_Delivery_control__c','Int_Agreement__c'};
            for(string ObjectName : ObjectSet){
                Database.executeBatch(new DMBIDataCleanUpJob(ObjectName),1000);
            }        
    }
}