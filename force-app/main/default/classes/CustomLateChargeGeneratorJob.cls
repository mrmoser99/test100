/**
 * Usage:  Following job is replacement for Late Charge job generator for bills.
 *          Late charge grace days has to depends on formula field: AutoCaluclate_Finance_Charge_Grace_Days__c
 *  List<String> contractNames = new List<String>{'a6u0t0000000GNg'};
 *  CustomLateChargeGeneratorJobCustomLateChargeGeneratorJob job 
 *          = new CustomLateChargeGeneratorJob(contractNames, DateToRun);
 *  Database.executeBatch(job);
 *
 **/
global with sharing class CustomLateChargeGeneratorJob extends clcommon.DynamicJob {
    private static String JOB_NAME = 'CUSTOM LATE CHARGE GENERATOR JOB';
    private static Date sodDate;
    private static String query;
    //private Date currentSystemDate;

    global CustomLateChargeGeneratorJob() {
        super(JOB_NAME, initialize(null));
    }
    
    global CustomLateChargeGeneratorJob(List<String> contractNames) {
        super(JOB_NAME, initialize(contractNames));
        //openPeriod   		= periodToRun;
    }
    
    global virtual override String getRuntimeQuery() {
        System.debug(LoggingLevel.ERROR, 'CustomLateChargeGeneratorJob query in getRuntimeQuery : ' + query);
        return query; 
    }

    public static String initialize(List<String> contractNames) {  
       	String namespacePrefix = 'cllease__';
       	sodDate = cllease.SystemDateUtil.getCurrentSystemDate();
        
        // Creating Dynamic Query on Contract Object 
        query = 'SELECT Id ' +
                'FROM ' + namespacePrefix + 'Lease_Account__c ' +
                'WHERE ' + namespacePrefix + 'Lease_Status__c in (\'ACTIVE - BAD STANDING\', \'ACTIVE - GOOD STANDING\', '+
                                                              '\'EVERGREEN\',\'ACTIVE - MATURED\') '+
                'AND '  + namespacePrefix + 'Active_flag__c = true '+
                'AND '  + namespacePrefix + 'Invalid_Data__c = false ';                                              

        if(contractNames!=null && contractNames.size() > 0) {
            String contractNamesStr = '';
            for (String contractName : contractNames) {
              contractNamesStr = contractNamesStr + '\'' + String.escapeSingleQuotes(contractName) + '\'' + ',';
            }
            contractNamesStr = contractNamesStr.substring(0, contractNamesStr.length() - 1);
            query += ' AND Name in ('+ contractNamesStr + ') ';
        }

        query += ' ORDER BY Name';
        
        System.debug(LoggingLevel.ERROR, 'CustomLateChargeGeneratorJob query in initialize : ' + query);
        return query;
    }
    
    public override void doExecute(Database.BatchableContext bc, List<sObject> scope){
        Set<id> lstContractIds = new Set<id>();

        Savepoint sp = Database.setSavepoint();
        try {
            for (sObject s : scope) {
                lstContractIds.add(s.id);
            }

            CustomLateChargeCreator c = new CustomLateChargeCreator(lstContractIds, sodDate);
            // ChargeLeases() method do both create charges and insert to DB
            c.chargeLeases();
        } catch (Exception e) {
            Database.rollback(sp);System.debug(LoggingLevel.ERROR, 'Exception while processing CustomLateChargeGeneratorJob: '+e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Exception StackTrace: '+e.getStackTraceString());
            //insert batch process log for exceptions
            insert new cllease__Batch_Process_Log__c(Name=' CustomLateChargeGeneratorJob ', cllease__Date__c = System.today(), 
            cllease__Message__c = 'Error is '+e.getmessage() +' in line number: '+ e.getlinenumber());
        }
    }

    public override void doInitialize() { }
    public override void doStart(Database.BatchableContext bc) { }
    public override void doFinish(Database.BatchableContext bc) { }

    
}