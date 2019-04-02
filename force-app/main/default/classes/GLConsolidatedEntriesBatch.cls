/**
 * Owner: Cloud Lending Solutions
 * Usage: Following job helps in Consolidate the GL Account Entries on GL Account Level.
 * Script to Run Job:
 *      
 **/
global with sharing class GLConsolidatedEntriesBatch extends clcommon.DynamicJob {
    
    private static String query;
    private String openPeriodEndDate;
    private String currentSystemDateStr;
    private Map<String, Int_OLMN_GL__c> interfaceObjectsCreditMap = new Map<String, Int_OLMN_GL__c>();
    private Map<String, Int_OLMN_GL__c> interfaceObjectsDebitMap = new Map<String, Int_OLMN_GL__c>();
    private Integer journalEntryNumber;
    private Integer journalEntryLineNumber = 1;
    private static final String JOB_NAME = 'GL Consolidation Generator Job';
    private static Datetime txnDate;
    
    global GLConsolidatedEntriesBatch() {
        super(JOB_NAME, initialize(null));
        doInitialize();
    }
    
    global GLConsolidatedEntriesBatch(List<String> contractNames) {
        super(JOB_NAME, initialize(contractNames));
        doInitialize();
    }
    
    global virtual override String getRuntimeQuery() {
        System.debug(LoggingLevel.ERROR, 'GLConsolidatedEntriesBatch query in getRuntimeQuery : ' + query);
        return query; 
    }

    public static String initialize(List<String> contractNames) {

        String excludeTxns = '\''+DLLNewCoConstants.TXN_DISBURSEMENT +'\', \''+DLLNewCoConstants.TXN_DEALERFUNDING+'\'';
        //'\'DISBURSEMENT\', \'DEALER FUNDING\'';
        String txnDateStr        = String.valueOf(cllease.SystemDateUtil.getCurrentSystemDate());
        
        query=  ' SELECT Id, Name,                        '+
                '   cllease__Transaction_Type__c,         '+
                '   cllease__Credit_Amount__c,            '+
                '   cllease__Credit_GL_Account__r.Name,   '+
                '   cllease__Credit_GL_Account_Code__c,   '+
                '   cllease__Debit_Amount__c,             '+
                '   cllease__Debit_GL_Account__r.Name,    '+
                '   cllease__Debit_GL_Account_Code__c,    '+
                '   CL_Lease_Transaction_Type__c,         '+
                '   GL_Consolidation_Credit_Record_Id__c, '+
                '   GL_Consolidation_Debit_Record_Id__c,  '+
                '   cllease__Transaction_type1__c,        '+
                '   Movement_Code_CR_Segment__c,          '+
                '   Movement_Code_DR_Segment__c,          '+
                '   Journal_Entry_Number__c,              '+
                '   cllease__GL_Date__c                   '+
                ' FROM cllease__GL_Transaction_Detail__c  '+
                ' WHERE ( GL_Consolidation_Credit_Record_Id__c = null   '+
                '   OR GL_Consolidation_Debit_Record_Id__c = null )     '+
                '   AND CL_Lease_Transaction_Type__c not in ( '+excludeTxns+' ) '+
            	'   AND cllease__Contract__c != null '+
                '  AND cllease__GL_Date__c <= '+ txnDateStr;

        if(contractNames!=null && contractNames.size() > 0) {
            String contractNamesStr = '';
            for (String contractName : contractNames) {
              contractNamesStr = contractNamesStr + '\'' + String.escapeSingleQuotes(contractName) + '\'' + ',';
            }
            contractNamesStr = contractNamesStr.substring(0, contractNamesStr.length() - 1);
            query += ' AND cllease__Contract__r.Name in ('+ contractNamesStr + ')';
        }

        query += ' ORDER BY Name ';
        
        System.debug(LoggingLevel.ERROR, 'GLConsolidatedEntriesBatch Query: '+query);
        return query;
    }
    
    /** Steps: Grouping Criteria(Movement Code Segment)
     * 1. Loop Through GL Accounting Entries
     *    Create 2 groups on GL Accounting Entries with Movement Code Segment
     *    i. credit group with movement code credit segment
     *    ii. debit group with movement code debit segment
     * 2. Looping through groups for Mapping records
     *    i. credit group and Map records to Int_OLMN_GL__c record
     *    ii. debit group and Map records to Int_OLMN_GL__c record
     **/
    public override void doExecute(Database.BatchableContext bc, List<sObject> scope) {

        Map<String, List<cllease__GL_Transaction_Detail__c>> creditGroup
            = new Map<String, List<cllease__GL_Transaction_Detail__c>>();

        Map<String, List<cllease__GL_Transaction_Detail__c>> debitGroup
            = new Map<String, List<cllease__GL_Transaction_Detail__c>>();

        Map<Id, cllease__GL_Transaction_Detail__c> glEntriesToUpdate
            = new Map<Id, cllease__GL_Transaction_Detail__c>();

        Decimal totalCreditAmount = 0, totalDebitAmount = 0;
        String lastDebitMovementCodeKey;

        Savepoint sp = database.setsavepoint();
        try {
            // 1. Looping through cllease__GL_Transaction_Detail__c to create Credit and Debit Groups
            List<cllease__GL_Transaction_Detail__c> glEntries = (List<cllease__GL_Transaction_Detail__c>)scope;
            
            System.debug(LoggingLevel.ERROR, ' Total Records for Processing: '+glEntries.size());
            for(cllease__GL_Transaction_Detail__c glEntry : glEntries) {
                System.debug(LoggingLevel.ERROR, ' Processing GL Entry: '+glEntry.Name);
                // Validations
                if(glEntry.Movement_Code_CR_Segment__c == null 
                    || glEntry.Movement_Code_DR_Segment__c == null) {
                    glEntry.Remark__c = 'Movement Code Debit/Credit Segments are not yet computed. Edit and Save GL Accounting Entry...';
                    glEntriesToUpdate.put(glEntry.Id, glEntry);
                }
            
                // i. credit group with movement code credit segment
                List<cllease__GL_Transaction_Detail__c> tempCreditList = creditGroup.get(glEntry.Movement_Code_CR_Segment__c);
                if(tempCreditList == null) {
                    tempCreditList = new List<cllease__GL_Transaction_Detail__c>();
                }
                // Considering GL Record for processing only if it's Consolidation Credit Record ID is null
                if(glEntry.GL_Consolidation_Credit_Record_Id__c == null) {
                    tempCreditList.add(glEntry);
                    creditGroup.put(glEntry.Movement_Code_CR_Segment__c, tempCreditList);
                }
            
                // ii. debit group with movement code debit segment
                List<cllease__GL_Transaction_Detail__c> tempDebitList = debitGroup.get(glEntry.Movement_Code_DR_Segment__c);
                if(tempDebitList == null) {
                    tempDebitList = new List<cllease__GL_Transaction_Detail__c>();
                }
                // Considering GL Record for processing only if it's Consolidation Debit Record ID is null
                if(glEntry.GL_Consolidation_Debit_Record_Id__c == null) {
                    tempDebitList.add(glEntry);
                    debitGroup.put(glEntry.Movement_Code_DR_Segment__c, tempDebitList);
                }                
            }


            System.debug(LoggingLevel.ERROR, ' creditGroup size: '+creditGroup.size());
            System.debug(LoggingLevel.ERROR, ' debitGroup size: '+debitGroup.size());
            // 2. Looping through groups for Mapping records only when both Credit & DebitMaps Size > 0
            if(creditGroup.size() > 0 || debitGroup.size() > 0) {
                
                // i. credit group and Map records to Int_OLMN_GL__c record
                for(String movementCodeCrSegment : creditGroup.keySet()) {
                    System.debug(LoggingLevel.ERROR, 'Processing movementCodeCrSegment : '+movementCodeCrSegment);
                    Decimal amount = 0;
                    // Summing up Amount from Credit GL Accounting Entries
                    List<cllease__GL_Transaction_Detail__c> creditGLList = creditGroup.get(movementCodeCrSegment);
                    //System.debug(LoggingLevel.ERROR, ' creditGLList: '+creditGLList);
                    if(creditGLList != null && creditGLList.size() > 0) {
                        for(cllease__GL_Transaction_Detail__c creditGL : creditGLList) {
                            System.debug(LoggingLevel.ERROR, ' Credit Amount : '+amount);
                            amount += cllease.ValueUtil.round(((creditGL.cllease__Debit_Amount__c == null) ? 0: creditGL.cllease__Debit_Amount__c), 2, 'Nearest');   
                            //totalCreditAmount += amount;
                        }
                        // Checking for Existing Interface record with movementCode
                        Int_OLMN_GL__c interfaceObject = interfaceObjectsCreditMap.get(movementCodeCrSegment);
                        if(interfaceObject == null) {
                            interfaceObject = createOLMNGL(creditGLList.get(0), amount, 'Credit');
                        } else {
                            interfaceObject.Amount__c = (interfaceObject.Amount__c == null ? 0 : interfaceObject.Amount__c);
                            interfaceObject.Amount__c += amount;
                        }
                        interfaceObjectsCreditMap.put(movementCodeCrSegment, interfaceObject);
                        System.debug(LoggingLevel.ERROR, 'Created object interfaceObject : '+interfaceObject);
                    }                    
                }

                // ii. debit group and Map records to Int_OLMN_GL__c record
                for(String movementCodeDrSegment : debitGroup.keySet()) {
                    System.debug(LoggingLevel.ERROR, 'Processing movementCodeDrSegment : '+movementCodeDrSegment);
                    Decimal amount = 0;
                    // Summing up Amount from Credit GL Accounting Entries
                    List<cllease__GL_Transaction_Detail__c> debitGLList = debitGroup.get(movementCodeDrSegment);
                    //System.debug(LoggingLevel.ERROR, ' debitGLList: '+debitGLList);
                    if(debitGLList != null && debitGLList.size() > 0) {
                        for(cllease__GL_Transaction_Detail__c debitGL : debitGLList) {
                            System.debug(LoggingLevel.ERROR, ' Debit Amount : '+amount);
                            amount += cllease.ValueUtil.round(((debitGL.cllease__Debit_Amount__c == null) ? 0: debitGL.cllease__Debit_Amount__c), 2, 'Nearest');
                            //totalDebitAmount += amount;
                        }
                        // Checking for Existing Interface record with movementCode
                        Int_OLMN_GL__c interfaceObject = interfaceObjectsDebitMap.get(movementCodeDrSegment);
                        if(interfaceObject == null) {
                            interfaceObject = createOLMNGL(debitGLList.get(0), amount, 'Debit');
                        } else {
                            interfaceObject.Amount__c = (interfaceObject.Amount__c == null ? 0 : interfaceObject.Amount__c);
                            interfaceObject.Amount__c += amount;
                        }
                        interfaceObjectsDebitMap.put(movementCodeDrSegment, interfaceObject);
                        lastDebitMovementCodeKey = movementCodeDrSegment;
                        System.debug(LoggingLevel.ERROR, 'Created object interfaceObject : '+interfaceObject);
                    }                    
                }
            }

            System.debug(LoggingLevel.ERROR, ' Processing interfaceObjectsCreditMap size: '+interfaceObjectsCreditMap.size());
            System.debug(LoggingLevel.ERROR, ' Processing interfaceObjectsDebitMap size: '+interfaceObjectsDebitMap.size());
            // Create Credit Interface Records
            if(interfaceObjectsCreditMap.size() > 0) {
                // Correcting Cent issue in last record.
                /*Decimal diffAmount = totalCreditAmount - totalDebitAmount;
                if(diffAmount != 0 && lastDebitMovementCodeKey != null) {
                    Int_OLMN_GL__c lastDebitRecord = interfaceObjectsCreditMap.get(lastDebitMovementCodeKey);
                    lastDebitRecord.Amount__c += lastDebitRecord.Amount__c + diffAmount;
                }*/
                

                Database.UpsertResult[] srList = Database.upsert(interfaceObjectsCreditMap.values(), false);
                Set<Id> successEntrieIDs = new Set<Id>();
                 // Iterate through each returned result
                for (Database.UpsertResult sr : srList) {
                    if (sr.isSuccess()) {
                        successEntrieIDs.add(sr.getId());
                    }
                }
                
                Map<String, Id> movementSegIDMap = new Map<String, Id>();
                for(Int_OLMN_GL__c olmnGL : [SELECT Id, Movement_Code__c, Amount__C 
                                                FROM Int_OLMN_GL__c 
                                                WHERE Id IN :successEntrieIDs]){
                    movementSegIDMap.put(olmnGL.Movement_Code__c, olmnGL.Id);
                }
                
                // Looping through all Credit and Debit groups to update Interface ID to GL Accounting Entries
                for(String movementCodeCrSegment : creditGroup.keySet()) {
                    ID olmnGLId = movementSegIDMap.get(movementCodeCrSegment);
                    for(cllease__GL_Transaction_Detail__c creditGL : creditGroup.get(movementCodeCrSegment)) {
                        creditGL.GL_Consolidation_Credit_Record_Id__c = olmnGLId;
                        creditGL.Remark__c = 'Successfully Consolidated GL Accounting Entry to Interface table...';
                        creditGL.Journal_Entry_Number__c = journalEntryNumber;
                        glEntriesToUpdate.put(creditGL.Id, creditGL);
                    }
                }
            }


            // Create Debit Interface Records
            if(interfaceObjectsDebitMap.size() > 0) {

                Database.UpsertResult[] srList = Database.upsert(interfaceObjectsDebitMap.values(), false);
                Set<Id> successEntrieIDs = new Set<Id>();
                 // Iterate through each returned result
                for (Database.UpsertResult sr : srList) {
                    if (sr.isSuccess()) {
                        successEntrieIDs.add(sr.getId());
                    }
                }
                
                Map<String, Id> movementSegIDMap = new Map<String, Id>();
                for(Int_OLMN_GL__c olmnGL : [SELECT Id, Movement_Code__c, Amount__C 
                                                FROM Int_OLMN_GL__c 
                                                WHERE Id IN :successEntrieIDs]){
                    movementSegIDMap.put(olmnGL.Movement_Code__c, olmnGL.Id);
                }
                
                // Looping through all Credit and Debit groups to update Interface ID to GL Accounting Entries
                for(String movementCodeDrSegment : debitGroup.keySet()) {
                    ID olmnGLId = movementSegIDMap.get(movementCodeDrSegment);
                    for(cllease__GL_Transaction_Detail__c debitGL : debitGroup.get(movementCodeDrSegment)) {
                        debitGL.GL_Consolidation_Debit_Record_Id__c = olmnGLId;
                        debitGL.Remark__c = 'Successfully Consolidated GL Accounting Entry to Interface table...';
                        debitGL.Journal_Entry_Number__c = journalEntryNumber;
                        glEntriesToUpdate.put(debitGL.Id, debitGL);
                    }
                }
            }

            // Update GL Entries
            if(glEntriesToUpdate.size() > 0) {
                update glEntriesToUpdate.values();
            }
            //System.debug(LoggingLevel.ERROR, ' Processing Completed for GL Entries Consolidation ');
            
        } catch(exception e){           
           database.rollback(sp);   
           System.debug(LoggingLevel.ERROR, 'Exception: '+e.getMessage());    
           System.debug(LoggingLevel.ERROR, 'Exception Stack: '+e.getStackTraceString());            
           //insert batch process log for exceptions
           insert new cllease__Batch_Process_Log__c(Name='GLConsolidatedEntriesBatch',
                                                    cllease__Date__c=system.today(),
                                                    cllease__Message__c='Error is '+e.getmessage()
                                                            +' in line number: '+ e.getlinenumber());
       }

    }

    private Int_OLMN_GL__c createOLMNGL(cllease__GL_Transaction_Detail__c glEntry, Decimal amount, String creditOrDebit) {

        String accountingYear  = openPeriodEndDate.substring(0, 4);
        String accountingMonth = openPeriodEndDate.substring(4, 6);

        // Datetime glDate     = txnDate; 
        // adding hour , minutes & Second from System.now for correct format conversion, otherwise format gives 1 day less to gldate on format conversion for datetime variable.
        /*Datetime currentSystemNow = System.now();

        glDate = glDate.addHours(currentSystemNow.hour());
        glDate = glDate.addMinutes(currentSystemNow.minute());
        glDate = glDate.addSeconds(currentSystemNow.second());*/

        // always making date to open period month end
        string glDateStr    = openPeriodEndDate; //glDate.format('yyyyMMdd'); 

        // Mapping as per "Oracle GL Mapping"
        Int_OLMN_GL__c olmnGL  = new Int_OLMN_GL__c();
        olmnGL.JOURNAL_ENTRY_NUMBER__C      = journalEntryNumber;
        olmnGL.JOURNAL_ENTRY_LINE_NUMBER__C = journalEntryLineNumber++;      
        olmnGL.ACCOUNTING_YEAR__C       = accountingYear;
        olmnGL.ACCOUNTING_MONTH__C      = accountingMonth;
        olmnGL.FOREIGN_SUBSYSTEM_ID__C  = 'NEWCO'; // Constant
        olmnGL.JOURNAL_DESCRIPTION__C   = 'NEWCO'+glDateStr; // Date in formate yyyyMMDD
        olmnGL.JOURNAL_DATE__C          = glDateStr;
        olmnGL.JOURNAL_SOURCE_CODE__C   = 'NEWCO';
        olmnGL.JOURNAL_CATEGORY__c      = 'NEWCO';
        olmnGL.JOURNAL_REFERENCE__C     = glDateStr;
        olmnGL.JOURNAL_CURRENCY__C      = 'USD';        
        olmnGL.TRANSACTION_DESCRIPTION__C = glEntry.CL_Lease_Transaction_Type__c;
        olmnGL.AMOUNT__C                = cllease.ValueUtil.round(amount, 2, 'Nearest');

        if(creditOrDebit == 'Credit') {
            olmnGL.Movement_Code__c = glEntry.Movement_Code_CR_Segment__c;            
            olmnGL.ACCOUNT__C       = glEntry.Movement_Code_CR_Segment__c;
            olmnGL.SIGN__C          = '-';
        } else if(creditOrDebit == 'Debit'){
            olmnGL.Movement_Code__c = glEntry.Movement_Code_DR_Segment__c;
            olmnGL.ACCOUNT__C       = glEntry.Movement_Code_DR_Segment__c;
            olmnGL.SIGN__C          = '+';
        }
        return olmnGL;
    }

    public override void doInitialize() { 
        // Querying Int_OLMN_GL__c Interface File for Journal Entry Number
        AggregateResult[] results = [SELECT max(JOURNAL_ENTRY_NUMBER__c) maxjenum
                                            FROM Int_OLMN_GL__c];
        if(results.size() > 0) {
            AggregateResult maxResult = results[0];
            journalEntryNumber = Integer.valueOf(maxResult.get('maxjenum'));
            journalEntryNumber = (journalEntryNumber != null ? journalEntryNumber : 0);
            journalEntryNumber++;
        } else {
            journalEntryNumber = 1;
        }

        // A. Retrieve the Open Periods Records Order by Period Month ASC Order
        List<cllease__Period_Status__c> openPeriods = [SELECT Id, Name,
                                                            cllease__End_Date__c,
                                                            cllease__Period_Year__c
                                                        FROM cllease__Period_Status__c
                                                        WHERE cllease__Status__c = 'Open'
                                                        ORDER BY cllease__End_Date__c DESC];

        if(openPeriods.size() == 0) {
            // Throw exception that No Open Periods
            new CLSCustomException('No Period Open from Accounting Periods, Please Open a Period and Continue...');
        }
        
        txnDate = openPeriods[0].cllease__End_Date__c;
        Datetime currentSystemNow = System.now();
        txnDate = txnDate.addHours(currentSystemNow.hour());
        txnDate = txnDate.addMinutes(currentSystemNow.minute());
        txnDate = txnDate.addSeconds(currentSystemNow.second());
        openPeriodEndDate           = txnDate.format('yyyyMMdd');

        Datetime currentCLLeaseDate = cllease.SystemDateUtil.getCurrentSystemDate();
        currentSystemDateStr        = currentCLLeaseDate.format('yyyyMMdd');
    }

    public override void doStart(Database.BatchableContext bc) { 
        //0. Checking for unfinished transactions in interface table.
        //   Incase of any unfinished transactions, job should not run till all txns commited to DLL
        //Throw exception and skip the job run in case of any unfinished transactions
        //    uncommittedInterfaceRecordsExist = true for all interface records not processed
        //                               = false for all interface records  processed 
        Boolean uncommittedInterfaceRecordsExist 
            = InterfaceTablesUnfinishedTxnsCheck.checkUnfinishedTxnsForGLConsolidations();
        
        if(uncommittedInterfaceRecordsExist) {
            throw new CLSCustomException('GL Consolidation Interface table(Int_OLMN_GL__c) has unfinished transactions. '+
                'Please commit all transactions from Interface table and run Job again...');
        }
    }   
    public override void doFinish(Database.BatchableContext bc) { }
}