trigger ContractTermination  on cllease__Lease_Account__c (after insert, after update) {
    Set<String> ContractRollOverQuoteIds = new Set<String>();
    for (cllease__Lease_Account__c clcont : Trigger.new){
        if(clcont.Roll_Over_Quote_Number__c != null)
        ContractRollOverQuoteIds.add(clcont.Roll_Over_Quote_Number__c);
        }
    if(ContractRollOverQuoteIds.size() > 0){
        ContractTerminationController.contractTermination(ContractRollOverQuoteIds);
    } 
    system.debug('ContractRollOverQuoteIds---->'+ContractRollOverQuoteIds);
}