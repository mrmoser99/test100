/**
 *  Author: Cloud Lending Solutions
 *  Description: Batch class to Read AP interface table for Dealer Funding and Passthrough transactions 
 *               (inbound to Salesforce) 
 *         a. Dealer Funding Transactions 
 *         b. Disbursement Transactions           
 *
 **/
global class ReadAPinterface extends clcommon.DynamicJob {
    
    private static String query;
    private static final String JOB_Name = 'Update AP Payment Confirmation Job';

    global ReadAPinterface() {
        super(JOB_Name, initialize(null));
    }
    
    global ReadAPinterface(List<String> pmtCnfrmNames) {
        super(JOB_Name, initialize(pmtCnfrmNames));
    }
    
    global virtual override String getRuntimeQuery() {
        System.debug(LoggingLevel.ERROR, 'ReadAPinterface query in getRuntimeQuery : ' + query);
        return query; 
    }

    public static String initialize(List<String> pmtCnfrmNames) {
        
        query = ' SELECT Id, Name, Contract_Number__c, Funding_Type__c, Vendor_Code__c,         '+
                '   Invoice_Number__c, Payment_Reference__c, Payment_Date__c, Remark__c         '+
                ' FROM Int_OLMN_Payment_Confirmation__c                                         '+
                ' WHERE Committed__c = false                                                    ';
        
        if(pmtCnfrmNames != null && pmtCnfrmNames.size() > 0) {
            String pmtCnfrmNamesStr = '';
            for (String pmtCnfrmName : pmtCnfrmNames) {
              pmtCnfrmNamesStr = pmtCnfrmNamesStr + '\'' + String.escapeSingleQuotes(pmtCnfrmName) + '\'' + ',';
            }
            pmtCnfrmNamesStr = pmtCnfrmNamesStr.subString(0, pmtCnfrmNamesStr.length() - 1);
            query += ' AND Name in ('+ pmtCnfrmNamesStr + ')';
        }
        
        System.debug(LoggingLevel.ERROR, 'ReadAPinterface query in initialize : ' + query);
        return query;
    }
    
    public override void doExecute(Database.BatchableContext bc, List<sObject> scope) {
    
        System.debug(LoggingLevel.ERROR, 'Processing Started for ReadAPinterface...'); 

        List<Int_OLMN_Payment_Confirmation__c> apPaymentRecords = (List<Int_OLMN_Payment_Confirmation__c>)scope; 

        Map<String, Int_OLMN_Payment_Confirmation__c> groupAPPaymentRecordsMap  = new Map<String, Int_OLMN_Payment_Confirmation__c>();
        List<String> contractIds                = new List<String>();
        Set<String> successfulGroupAPRecords    = new Set<String>();
        List<Int_OLMN_Payment_Confirmation__c> apPaymentRecordToUpdate = new List<Int_OLMN_Payment_Confirmation__c>();

        Savepoint sp = database.setsavepoint();        
        try{
        
            // Extracting Groups for Dealer funding and Disbursement Transactions
            for(Int_OLMN_Payment_Confirmation__c apPaymentRecord : apPaymentRecords){
                // Skipping the record in case if Contract Number or Invoice Number is missing from AP Payment Record
                if(apPaymentRecord.Contract_Number__c != null && apPaymentRecord.Invoice_Number__c != null) {
                    groupAPPaymentRecordsMap.put(apPaymentRecord.Contract_Number__c+':'+apPaymentRecord.Invoice_Number__c, apPaymentRecord);
                    contractIds.add(apPaymentRecord.Contract_Number__c);
                } else {
                    apPaymentRecord.Remark__c = 'Contract Number/Invoice Number is null to process AP Payment Record. Cannot process the record...';
                    apPaymentRecordToUpdate.add(apPaymentRecord);
                }
            }

            // Start the processing only when contract Ids size > 0
            if(contractIds.size() > 0) {
                // a. retrieving all Dealer funding transactions related to contracts 
                List<cllease__Other_Transaction__c> dealerFundingTxnsList = [SELECT Id, Name,
                                                                                Payment_Reference__c, 
                                                                                Payment_Date__c,
                                                                                Invoice_Number__c,
                                                                                cllease__Lease_Account__c,
                                                                                cllease__Lease_Account__r.Name,
                                                                                cllease__Description__c,
                                                                                AP_Processing_Status__c
                                                                            FROM cllease__Other_Transaction__c 
                                                                            WHERE cllease__Lease_Account__r.Name IN :contractIds];

                if(dealerFundingTxnsList.size() > 0) {
                    Map<Id, cllease__Other_Transaction__c> dealerTxnsMap = new Map<Id, cllease__Other_Transaction__c>(); 
                    // Looping through Dealer Funding Transactions for Updating  Payment Details
                    for(cllease__Other_Transaction__c dealerFundingTxn : dealerFundingTxnsList) {
                        // Only Process the dealer Funding Transaction in case Contract and invoice Number are not null
                        if(dealerFundingTxn.cllease__Lease_Account__c != null && dealerFundingTxn.Invoice_Number__c != null) {
                            String groupKey = dealerFundingTxn.cllease__Lease_Account__r.Name+':'+dealerFundingTxn.Invoice_Number__c;
                            if(groupAPPaymentRecordsMap.containsKey(groupKey)) {
                                Int_OLMN_Payment_Confirmation__c apPaymentRecord = groupAPPaymentRecordsMap.get(groupKey);
                                dealerFundingTxn.Payment_Reference__c   = apPaymentRecord.Payment_Reference__c;
                                dealerFundingTxn.Payment_Date__c        = apPaymentRecord.Payment_Date__c;
                                dealerFundingTxn.AP_Processing_Status__c= 'Funded';
                                dealerTxnsMap.put(dealerFundingTxn.Id, dealerFundingTxn);
                            }
                        }                        
                    }

                    // Proceed with Dealer funding transaction updates only if there are some records to update
                    if(dealerTxnsMap.size() > 0) {
                        // Committing Dealer Funding transactions Updates
                        Database.SaveResult[] srList = Database.update(dealerTxnsMap.values(), false);
                        for (Database.SaveResult sr : srList) {                    
                            if (sr.isSuccess()) {
                                cllease__Other_Transaction__c dealerFundingTxn = dealerTxnsMap.get(sr.getId());
                                successfulGroupAPRecords.add(dealerFundingTxn.cllease__Lease_Account__r.Name+':'+dealerFundingTxn.Invoice_Number__c);
                            } else {
                                System.debug(LoggingLevel.ERROR, 'error: '+sr.getErrors());
                            }
                        } 
                    }
                }

                // b. retrieving all disbursements transactions related to contrcts for updates
                List<cllease__Disbursement_Transaction__c> disbTxnsList = [SELECT Id, Name, 
                                                                                Payment_Reference__c,
                                                                                Payment_Date__c,
                                                                                cllease__Contract__c,
                                                                                cllease__Contract__r.Name,
                                                                                Remark__c,
                                                                                AP_Processing_Status__c
                                                                            FROM cllease__Disbursement_Transaction__c 
                                                                            WHERE cllease__Contract__r.Name IN :contractIds];

                if(disbTxnsList.size() > 0) {
                    Map<Id, cllease__Disbursement_Transaction__c> disbTxnsMap = new Map<Id, cllease__Disbursement_Transaction__c>(); 
                    for(cllease__Disbursement_Transaction__c disbTxn : disbTxnsList) {
                        // Only Process the dealer Funding Transaction in case Contract and invoice Number are not null
                        if(disbTxn.cllease__Contract__c != null && disbTxn.Name != null) {
                            String groupKey = disbTxn.cllease__Contract__r.Name+':'+disbTxn.Name;
                            if(groupAPPaymentRecordsMap.containsKey(groupKey)) {
                                Int_OLMN_Payment_Confirmation__c apPaymentRecord = groupAPPaymentRecordsMap.get(groupKey);
                                disbTxn.Payment_Reference__c   = apPaymentRecord.Payment_Reference__c;
                                disbTxn.Payment_Date__c        = apPaymentRecord.Payment_Date__c;
                                disbTxn.AP_Processing_Status__c= 'Funded';
                                disbTxnsMap.put(disbTxn.Id, disbTxn);
                            }
                        }                        
                    }

                    // Proceed with Dealer funding transaction updates only if there are some records to update
                    if(disbTxnsMap.size() > 0) {
                        // Committing Dealer Funding transactions Updates
                        Database.SaveResult[] srList = Database.update(disbTxnsMap.values(), false);
                        for (Database.SaveResult sr : srList) {                    
                            if (sr.isSuccess()) {
                                cllease__Disbursement_Transaction__c disbTxn = disbTxnsMap.get(sr.getId());
                                successfulGroupAPRecords.add(disbTxn.cllease__Contract__r.Name+':'+disbTxn.Name);
                            } else {
                                System.debug(LoggingLevel.ERROR, 'error: '+sr.getErrors());
                            }
                        } 
                    }
                }
            }

            System.debug(LoggingLevel.ERROR, '----successfulGroupAPRecords: '+successfulGroupAPRecords);
            // Checking with groups which are successful
            if(successfulGroupAPRecords.size() > 0) {
                for(String successgroupKey : successfulGroupAPRecords) {
                    if(groupAPPaymentRecordsMap.containsKey(successgroupKey)) {
                        Int_OLMN_Payment_Confirmation__c apPaymentRecord = groupAPPaymentRecordsMap.get(successgroupKey);
                        apPaymentRecord.Committed__c = true;
                        apPaymentRecord.Remark__c = 'Successfully processed the AP Payment Confirmation Record...';
                        apPaymentRecordToUpdate.add(apPaymentRecord);
                    }
                }

                if(apPaymentRecordToUpdate.size() > 0) {
                    update apPaymentRecordToUpdate;
                }
            }     
       
       } catch(exception e){       
            database.rollback(sp);
            System.debug(LoggingLevel.ERROR, 'Exception: '+e.getMessage());    
            System.debug(LoggingLevel.ERROR, 'Exception Stack: '+e.getStackTraceString());   
            //insert batch process log for exceptions
            insert new cllease__Batch_Process_Log__c(Name='ReadAPinterface: ',cllease__Date__c=system.today(),
            cllease__Message__c='Error is '+e.getmessage()+' in line number: '+ e.getlinenumber());
       }
        
    }
    
    public override voId doInitialize() { }
    public override voId doStart(Database.BatchableContext bc) { }   
    public override voId doFinish(Database.BatchableContext bc) { 
        // Query  Int_Batch_Status__c for first "Ready" on "AP Confirm"  and update as completed.
        List<Int_Batch_Status__c> apConfirmBatchStatusRecords = [SELECT Id, Name, Status__c
                                                                    FROM Int_Batch_Status__c
                                                                    WHERE Name = 'AP Confirm' 
                                                                        AND Status__c = 'Ready'
                                                                        AND Completed__c = false
                                                                    ORDER BY createdDate];
        // Should only update first remit record as InitiateCLSReceiptJobsTrigger will trigger for first record.
        if(apConfirmBatchStatusRecords.size() > 0) {
            Int_Batch_Status__c apConfirmBatchStatusRecord = apConfirmBatchStatusRecords.get(0);
            apConfirmBatchStatusRecord.Status__c = 'Completed';
            apConfirmBatchStatusRecord.Completed__c = true;
            update apConfirmBatchStatusRecord;
        }
    }
}