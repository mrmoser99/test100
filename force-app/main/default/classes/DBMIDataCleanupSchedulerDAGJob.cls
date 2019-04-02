// Note: following job should run always with batch size = 1
global class DBMIDataCleanupSchedulerDAGJob extends clcommon.DynamicJob {
    private static String query;
    private static final String JOB_NAME = 'DMBI Datacleanup Schedulor Job';
    
    global DBMIDataCleanupSchedulerDAGJob() {
        super(JOB_NAME, initialize());
        doInitialize();
    }
    
    global virtual override String getRuntimeQuery() {
        System.debug(LoggingLevel.ERROR, 'DBMIDataCleanupSchedulerDAGJob in getRuntimeQuery : ' + query);
        return query; 
    }
    
    public static String initialize() {
        query = 'select id, DeveloperName, Delete_Order__c  from DMBI_Objects_To_Cleanup__mdt Order by Delete_Order__c asc';
        System.debug(LoggingLevel.ERROR, 'DBMIDataCleanupSchedulerDAGJob query in initialize : ' + query);
        return query;
    }
    
    public override void doExecute(Database.BatchableContext bc, List<sObject> scope) {
        // do nothing here: only initiate jobs in dofinish();
        /*List<DMBI_Objects_To_Cleanup__mdt> ObjectsToDelete = (List<DMBI_Objects_To_Cleanup__mdt>)scope;
        String objectName = ObjectsToDelete.get(0).DeveloperName;
        List<sObject> objects = Database.query('Select Id From '+objectName);
        delete objects;*/
        //Database.executeBatch(new DMBIDataCleanUpDAGJob(ObjectName),1000);
		
        //DMBIDataCleanUpScheduleJob job = new DMBIDataCleanUpScheduleJob();
        //job.execute(null);
    }
    
    public override void doInitialize() {}
    public override void doStart(Database.BatchableContext bc) { }
	public override void doFinish(Database.BatchableContext bc) {
        // Query all entries from "DMBI objects to Delete" Custom Metadata entry to delete
        List<DMBI_Objects_To_Cleanup__mdt> objectsToDeleteList = [SELECT id, MasterLabel , Delete_Order__c  
                                                              		FROM DMBI_Objects_To_Cleanup__mdt 
                                                              		ORDER BY Delete_Order__c asc];
        // Loop through all objects records and call the delete job
        for(DMBI_Objects_To_Cleanup__mdt objectsToDelete : objectsToDeleteList){
        	Database.executeBatch(new DMBIDataCleanUpDAGJob(objectsToDelete.MasterLabel )); // default batch limit 2000 records
        }
    }
}