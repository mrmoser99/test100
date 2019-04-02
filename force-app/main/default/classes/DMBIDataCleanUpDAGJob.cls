/**
 * Following job helps in cleaning up the DMBI table records 
 * Which runs through multiple instances 
 **/
global class DMBIDataCleanUpDAGJob extends clcommon.DynamicJob {
	  private static String query;
    private static final String JOB_NAME = 'DMBI Data CleanUp DAG Job';
    public integer NumberOfRecordsDeleted;
    public String objectNameToQuery;
    
    public DMBIDataCleanUpDAGJob(String objectNameToQuery) {
        super(JOB_NAME, initialize(objectNameToQuery));
        NumberOfRecordsDeleted 	= 0;
        this.objectNameToQuery 	= objectNameToQuery;
    }
    
    global virtual override String getRuntimeQuery() {
        System.debug(LoggingLevel.ERROR, 'DMBIDataCleanUpDAGJob query in getRuntimeQuery : ' + query);
        return query; 
    }

    public static String initialize(String objectNameToQuery) {                                                   
        // Creating Dynamic Query on  Object  to delete
        query = 'SELECT Id FROM '+ objectNameToQuery ;

        System.debug(LoggingLevel.ERROR, 'DMBIDataCleanUpDAGJob query in initialize : ' + query);
        return query;
    }

    public override void doExecute(Database.BatchableContext bc, List<sObject> scope) {
        try {            
            System.debug(LoggingLevel.ERROR, 'DMBIDataCleanUpDAGJob records retrieved per batch  :' + scope.size());
            NumberOfRecordsDeleted += scope.size();
            // Delete object records
            delete Scope;
            
        } catch(Exception e){
            System.debug(LoggingLevel.ERROR, 'Exception in execute method : '+e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Exception in linenumber : '+e.getLineNumber());
            insert new cllease__Batch_Process_Log__c(Name='DMBIDataCleanUpDAGJob ',  cllease__Date__c=system.today(), 
            cllease__Message__c='Error is '+e.getmessage() + ' in line number: '+ e.getlinenumber());
        }
    }

    public override void doInitialize() { }

    public override void doStart(Database.BatchableContext bc) { }  

    public override void doFinish(Database.BatchableContext bc) {
        system.debug(objectNameToQuery + ' Delete Batch Finished. Number of records Deleted : '+NumberOfRecordsDeleted);
        insert new cllease__Batch_Process_Log__c(Name='DMBIDataCleanUpDAGJob : ', cllease__Date__c= system.today(), 
        cllease__Message__c='Total No of records deleted from Object : '+objectNameToQuery+' Records: '+ NumberOfRecordsDeleted);
    }  
}