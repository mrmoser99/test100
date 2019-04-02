/**
 * Following scheduler helper in initiating the DMBIDataCleanUpDAGJob which cleanup the records before populating the records.
 * Note: Schedule the following jobs 1 hr before the " CL Lease Batch jobs" to avoid any conflicts 
 *  
 **/

global class DMBIDataCleanUpScheduleJob_Old implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        
        // Query all entries from "DMBI objects to Delete" Custom Metadata entry to delete
        List<DMBI_Objects_To_Cleanup__mdt> objectsToDeleteList = [SELECT id, MasterLabel, Delete_Order__c  
                                                                    FROM DMBI_Objects_To_Cleanup__mdt 
                                                                    ORDER BY Delete_Order__c asc];
        // Loop through all objects records and call the delete job
        try {
            for(DMBI_Objects_To_Cleanup__mdt objectsToDelete : objectsToDeleteList){
                Database.executeBatch(new DMBIDataCleanUpDAGJob(objectsToDelete.MasterLabel)); // default batch limit 2000 records
            } 
        } catch(Exception e) {
              System.debug(LoggingLevel.ERROR, 'Exception in line: '+e.getlinenumber());
              System.debug(LoggingLevel.ERROR, 'Exception : '+e.getMessage());
              System.debug(LoggingLevel.ERROR, 'Exception StackTrace: '+e.getStackTraceString());
                insert new cllease__Batch_Process_Log__c(Name='DMBIDataCleanUpScheduleJob ',
                cllease__Date__c=system.today(), cllease__Message__c='Error is '+e.getmessage()
                +' in line number: '+ e.getlinenumber());           
          }           
    }
}