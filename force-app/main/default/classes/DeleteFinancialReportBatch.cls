/**
 * Owner: Cloud Lending Solutions
 * Usage: Following job helps in Deleting the existing Finacial report
 * Script to Run Job:
 *
 *     List<String> reportNames = List<String>{''};
 *     DeleteFinancialReportBatch job = new DeleteFinancialReportBatch();
 *     Database.executeBatch(job);
 *    
 **/
global with sharing class DeleteFinancialReportBatch extends clcommon.DynamicJob {

    private static String query;
    private static final String JOB_NAME = 'DELETE FINANCIAL REPORT JOB';
    
    global DeleteFinancialReportBatch() {
        super(JOB_NAME, initialize(null));
        doInitialize();
    }

    global DeleteFinancialReportBatch(List<String> reportNames) {
        super(JOB_NAME, initialize(reportNames));
        doInitialize();
    }
    
    global virtual override String getRuntimeQuery() {
        System.debug(LoggingLevel.ERROR, 'DeleteFinancialReportBatch query in getRuntimeQuery : ' + query);
        return query; 
    }

    public static String initialize(List<String> reportNames) {
        // Creating Query for Financial Report to delete
        query = 'SELECT Id, Name '+
                ' FROM CL_Lease_Financial_Report__c';

        // Filtering the specific report to delete
        if(reportNames!=null && reportNames.size() > 0) {
            String reportNameStr = '';
            for (String reportName : reportNames) {
              reportNameStr = reportNameStr + '\'' + String.escapeSingleQuotes(reportName) + '\'' + ',';
            }
            reportNameStr = reportNameStr.substring(0, reportNameStr.length() - 1);
            query += ' WHERE Name in ('+ reportNameStr + ')';
        }

        query += ' ORDER BY Name ';

        System.debug(LoggingLevel.ERROR, 'DeleteFinancialReportBatch query : ' + query);
        
        return query;
    }

    public override void doExecute(Database.BatchableContext bc, List<sObject> scope) {
        List<CL_Lease_Financial_Report__c> finReprt = new List<CL_Lease_Financial_Report__c>();
        
        Savepoint sp = database.setsavepoint();
        try {
            // object to delete
            for(Sobject obj : scope) { 
                CL_Lease_Financial_Report__c FinRep = (CL_Lease_Financial_Report__c)obj;
                finReprt.add(FinRep);
            }
            
            // Deleting the existing reports 
            if(finReprt.size() > 0) {
                delete finReprt; 
            }
        } catch(Exception e) {
            database.rollback(sp);   
            System.debug(LoggingLevel.ERROR, 'Exception: '+e.getMessage());    
            System.debug(LoggingLevel.ERROR, 'Exception Stack: '+e.getStackTraceString());      
            //insert batch process log for exceptions
            insert new cllease__Batch_Process_Log__c(Name = 'DeleteFinancialReportBatch Creating: ', cllease__Date__c = System.today(),
            cllease__Message__c = 'Error is '+e.getMessage() +' in line number: '+ e.getLineNumber());
        }

    }

    public override void doInitialize() { }
    public override void doStart(Database.BatchableContext bc) { }
    public override void doFinish(Database.BatchableContext bc) { }

}