/**
 * Owner: Cloud Lending Solutions
 * Description: Following trigger helps updating Return ID when user select Contract Equipment 
 **/

Trigger AssetworkbenchTrigger on cllease__Asset_Workbench__c (before insert, before update) {
    Set<Id> equipmentIds = new Set<Id>();
    Map<Id,Id> equipmentToAssetMap = new Map<Id,Id>();
    Savepoint sp = database.setsavepoint();
    try {
        // 1. Loop through Asset workbench to get Contract Equipment IDs
        for(cllease__Asset_Workbench__c assetWorkBench : trigger.new) {
            if(assetWorkBench.cllease__Contract_Equipment__c != null) {
                equipmentIds.add(assetWorkBench.cllease__Contract_Equipment__c);
            }
        }

        if(equipmentIds.size() > 0) {
            // 2. Query and Loop through Asset Returns to create Map of Equipment ID with Return ID
            for(cllease__Asset_Return__c asstReturn : [SELECT Id, cllease__Contract_Equipment__c 
                                                        FROM cllease__Asset_Return__c 
                                                        WHERE cllease__Contract_Equipment__c IN :equipmentIds]) {
                equipmentToAssetMap.put(asstReturn.cllease__Contract_Equipment__c, asstReturn.Id);
            }

            // 3. Loop through asset workbench objects to update Asset WorkBench
            for(cllease__Asset_Workbench__c assetWorkBench : trigger.new) {
                assetWorkBench.Return_ID__c = equipmentToAssetMap.get(assetWorkBench.cllease__Contract_Equipment__c);
            }
        }
    } catch(Exception e) {
        Database.rollback(sp);
        System.debug(LoggingLevel.ERROR, ' Exception: '+e.getMessage());
        System.debug(LoggingLevel.ERROR, ' Exception Stack Trace: '+e.getStackTraceString());
        insert new cllease__Batch_Process_Log__c(Name='AssetworkbenchTrigger: ',
                                                cllease__Date__c=system.today(),
                                                cllease__Message__c=' Error: '+e.getMessage()
                                                +' StackTrace: '+ e.getStackTraceString());  
    }
    
}