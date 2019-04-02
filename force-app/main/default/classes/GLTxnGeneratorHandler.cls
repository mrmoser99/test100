/**
 * Author: Cloud Lending Solutions
 * Description: Following GL Entries handler is just a replica from product but following are the reasons to 
 *      to implement
 *          a. Bill and charge's GL Transactions should be on Transaction Date instead on Due Date.
 *
 **/
public virtual class GLTxnGeneratorHandler {
    public Date sodDate;
    private List<cllease__Lease_Account__c> contracts;    
    private OpenPeriodIdentifier openPerIdentifier;
    private Map<String, String> columnMap;
    private Map<String, List<cllease__Accounting_Template_Header__c>> accountingTemplatesMap;
    private Map<String, List<cllease__Accounting_Template_Header__c>> npaAccountingTemplatesMap;
    private Map<String, List<cllease__Accounting_Template_Header__c>> npaReversalAccountingTemplatesMap;
    private Map<String, List<cllease__Accounting_Template_Header__c>> npaCatchupAccountingTemplatesMap;

    private static final Date MAXDATE = Date.newInstance(2099, 01, 01);
    private List<cllease__Lease_Trx_Lines__c> accrualTxnLinesToBeUpdated;
    private List<cllease__Other_Transaction__c> otherTxnsToBeUpdated;
    private List<cllease__Disbursement_Transaction__c> disbTxnsToBeUpdated;
    private List<cllease__Lease_account_Due_Details__c> billsToBeUpdated;
    private List<cllease__Charge__c> chargesToBeUpdated;
    private List<cllease__Lease_Payment_Detail__c> paymentTxnsToBeUpdated;

    public GLTxnGeneratorHandler(List<cllease__Lease_Account__c> leaseAccounts, Date sodD) {
        initialize(leaseAccounts, null, sodD);        
    }  

    public GLTxnGeneratorHandler(Set<Id> contractIds, Date sodDate) {
        initialize(null, contractIds, sodDate);
    }  
 
    public virtual List<cllease__Lease_Account__c> getContractRecords(Set<Id> contractIds) { 
        String contractIdStr = CLSCustomUtil.getStringFromIds(contractIds);
        String namespacePrefix = 'cllease__';
        String dateStr = String.valueOf(this.sodDate);
        String BILL_STATUS_TAX_PROCESSED = 'Tax Calculated'; 
        String query = 'SELECT ' + CLSCustomUtil.fetchObjectFields('cllease__Lease_Account__c') + ', ' +
                            namespacePrefix + 'Lease_Product_Name__r.' + namespacePrefix + 'Use_Open_Acct_Period__c, ' +
                            '(SELECT ' + CLSCustomUtil.fetchObjectFields('cllease__Lease_Trx_Lines__c') + ', ' +
                                namespacePrefix + 'Trx_Header__r.' + namespacePrefix + 'NPA_Flag__c ' + ',' +
                                namespacePrefix + 'Trx_Header__r.' + namespacePrefix + 'NPA_Reversal_Flag__c ' + ',' +
                                namespacePrefix + 'Trx_Header__r.' + namespacePrefix + 'Catch_up_Flag__c ' +
                            'FROM ' + namespacePrefix + 'Lease_Transaction_Line__r ' +
                            'WHERE ' + namespacePrefix + 'accounted_yn__c = false ' +
                                'AND ' + namespacePrefix + 'Transaction_Date__c <= ' + dateStr  + '), ' +
                            '(SELECT ' + CLSCustomUtil.fetchObjectFields('cllease__Other_Transaction__c') + ' ' +
                            'FROM ' + namespacePrefix + 'Other_Lease_Transactions__r ' +
                            'WHERE ' + namespacePrefix + 'GL_Posted_Flag__c = false ' +
                                'AND ' + namespacePrefix + 'GL_Transaction_Flag__c = true '+
                                'AND ' + namespacePrefix + 'Txn_Date__c <= ' + dateStr  + '), ' +
                            '(SELECT ' + CLSCustomUtil.fetchObjectFields('cllease__Disbursement_Transaction__c') + ' ' +
                            'FROM ' + namespacePrefix + 'Disbursement_Transactions__r ' +
                                'WHERE ' + namespacePrefix + 'GL_Posted_Flag__c = false ' +
                                'AND ' + namespacePrefix + 'GL_Transaction_Flag__c = true ' +
                                'AND ' + namespacePrefix + 'Transaction_Date__c <= ' + dateStr  + '), ' +
                            '(SELECT ' + CLSCustomUtil.fetchObjectFields('cllease__Lease_Payment_Detail__c') + ' ' +
                            'FROM ' + namespacePrefix + 'Lease_Payment_Details__r ' +
                            'WHERE ' + namespacePrefix + 'GL_Posted_Flag__c = false ' +
                                'AND ' + namespacePrefix + 'GL_Transaction_Flag__c = true ' +
                                'AND ' + namespacePrefix + 'Payment_Transaction__r.' + namespacePrefix + 'Cleared__c = true ' +
                                'AND ' + namespacePrefix + 'Reversed__c = false ' +
                                'AND ' + namespacePrefix + 'Transaction_Date__c <= ' + dateStr  + '), ' +
                            '(SELECT ' + CLSCustomUtil.fetchObjectFields('cllease__Charge__c') + ', ' +
                                namespacePrefix + 'Fee__r.' + namespacePrefix + 'Time_Of_Charge__c, ' +
                                namespacePrefix + 'Fee__r.' + namespacePrefix + 'Type_Of_Charge__c, ' +
                                namespacePrefix + 'Fee__r.name ' +
                            'FROM ' + namespacePrefix + 'Charges__r ' +
                            'WHERE ' + namespacePrefix + 'GL_Posted_Flag__c = false ' +
                                'AND ' + namespacePrefix + 'GL_Transaction_Flag__c = true ' +
                                'AND ' + namespacePrefix + 'Transaction_Date__c <= ' + dateStr  + '), ' +
                            '(SELECT ' + CLSCustomUtil.fetchObjectFields('cllease__Lease_account_Due_Details__c') + ' ' +
                            'FROM ' + namespacePrefix + 'Dues_Details__r ' +
                            'WHERE ' + namespacePrefix + 'GL_Posted_Flag__c = false ' +
                                'AND ' + namespacePrefix + 'GL_Transaction_Flag__c = true ' +
                                'AND ' + namespacePrefix + 'Status__c = \'' + BILL_STATUS_TAX_PROCESSED + '\' ' +
                                'AND ' + namespacePrefix + 'Transaction_Date__c <= ' + dateStr  + ')' +
                    ' FROM ' + namespacePrefix + 'Lease_Account__c ' +
                    ' WHERE Id in (' + contractIdStr + ') order by name ';

        System.debug(Logginglevel.ERROR, 'GL Entries query: ' + query);
        List<cllease__Lease_Account__c> lsContracts = Database.Query(query);
        return lsContracts;
    }
    private void initialize(List<cllease__Lease_Account__c> leaseAccounts, Set<Id> contractIds, Date sodD) {
        //check for access       
        accrualTxnLinesToBeUpdated = new List<cllease__Lease_Trx_Lines__c>();
        otherTxnsToBeUpdated = new List<cllease__Other_Transaction__c>();
        disbTxnsToBeUpdated = new List<cllease__Disbursement_Transaction__c>();
        billsToBeUpdated = new List<cllease__Lease_account_Due_Details__c>();
        chargesToBeUpdated = new List<cllease__Charge__c>();
        paymentTxnsToBeUpdated = new List<cllease__Lease_Payment_Detail__c>();
        this.sodDate = sodD;
        if(this.sodDate == null) {
            this.sodDate = cllease.SystemDateUtil.getCurrentSystemDate();
        } 
        List<cllease__Amount_Columns__c> columns = [SELECT Name,
                                                cllease__Amount_Object__r.Name,  
                                                cllease__Amount_Object__r.cllease__Api_Name__c, 
                                                cllease__Column_Api_Name__c  
                                            FROM cllease__Amount_Columns__c
                                            WHERE cllease__Amount_Object__r.cllease__Active__c = TRUE]; // added where clause to avoid blind query
        if(columns.size() == 0) {
           throw new CLSCustomException('System.label.ACCOUNTING_OBJECT_COLUMNS');
        }        
        this.contracts = leaseAccounts;
        
        if(this.contracts == null) {
            this.contracts = getContractRecords(contractIds);
        } 
        Set<Id> productIds = new Set<Id>();
        Set<Id> companyIds = new Set<Id>();
        for(cllease__Lease_Account__c contract : this.contracts) {
            if(contract.cllease__Lease_Product_Name__c != null) {  
                productIds.add(contract.cllease__Lease_Product_Name__c);
            }
            if(contract.cllease__Branch__c != null) {
                companyIds.add(contract.cllease__Branch__c);
            }
        }       
        //TODO - NEED TO HAVE CALENDAR BY BRANCH
        Map<String, cllease__Period_Status__c> periodStatusMap = new Map<String, cllease__Period_Status__c>();
        //TODO - we can limit the no of records from start, by taking no of min(date) from all txns
        List<cllease__Calendar__c> calendars  = [SELECT Id, Name,
                                (SELECT 
                                    cllease__Period_Year__c, 
                                    cllease__Period_month__c, 
                                    cllease__Start_Date__c, 
                                    cllease__End_Date__c, 
                                    cllease__Status__c 
                               FROM cllease__Period_Status__r
                               WHERE cllease__Start_Date__c <= :this.sodDate.addMonths(1) //This is to support customization around txn date for dues
                               ORDER BY cllease__Start_Date__c DESC) //desc is needed for logic down the line
                           FROM cllease__Calendar__c 
                           LIMIT 1];
        
        if(calendars.size() == 0) {
           throw new CLSCustomException('System.label.NO_CALENDAR');
        }
        List<cllease__Period_Status__c> periodStatusList = calendars.get(0).cllease__Period_Status__r;

        System.debug(LoggingLevel.ERROR, 'calendars: '+calendars);   
        System.debug(LoggingLevel.ERROR, 'Periods for GL: '+periodStatusList);   
        if (periodStatusList.size() == 0) {
            throw new CLSCustomException('System.label.PERIODS_NOT_POPULATED');
        }
        openPerIdentifier = new OpenPeriodIdentifier(periodStatusList);
        
        columnMap = new Map<String, String>();
        
        for(cllease__Amount_Columns__c cols : columns) {
            String colkey = cols.cllease__Amount_Object__r.Name + '|' + cols.Name;
            String valkey = cols.cllease__Amount_Object__r.cllease__Api_Name__c + '|' + cols.cllease__Column_API_Name__c;
            columnMap.put(colkey, valkey);
        }
        
        List<cllease__Accounting_Template_Header__c> accountingTemplatesHdrList =  
                                                    [SELECT Name,
                                                        ID,
                                                        cllease__Account_Status__c, // this field is being used to determine the accrual type
                                                        cllease__Branch__c,
                                                        cllease__Company__c,
                                                        cllease__Enabled__c,
                                                        cllease__NPA_Flag__c,
                                                        cllease__Product__c,
                                                        cllease__Securitization_Flag__c,
                                                        cllease__Transaction_Type__c,
                                                        (SELECT Id,
                                                            Name,
                                                            cllease__Accounting_Template_Header__c,
                                                            cllease__Credit_GL_Account__c,
                                                            cllease__Debit_GL_Account__c,
                                                            cllease__Description__c,
                                                            cllease__Enabled__c,
                                                            cllease__Amount_Object__c,
                                                            cllease__Amount_Object_Column__c,
                                                            cllease__Transaction_Sub_Type__c,
                                                            cllease__Transaction_Sub_Type__r.name,
                                                            cllease__Transaction_Type__c,
                                                            cllease__Bill_As_Invoice__c,
                                                            cllease__Item_Id__c,
                                                            cllease__Item_Name__c
                                                        FROM cllease__Accounting_Template_Lines__r
                                                        WHERE cllease__Enabled__c = true)
                                                    FROM cllease__Accounting_Template_Header__c
                                                    WHERE cllease__Enabled__c = true
                                                        AND (cllease__Product__c in :productIds)
                                                        AND (cllease__Company__c in :companyIds)
                                                        ORDER BY cllease__Company__c, cllease__Product__c, cllease__Transaction_Type__c];

        System.debug(LoggingLevel.FINE, 'Accounting templates headers :' + accountingTemplatesHdrList.size());
        accountingTemplatesMap = new Map<String, List<cllease__Accounting_Template_Header__c>>();
        npaAccountingTemplatesMap = new Map<String, List<cllease__Accounting_Template_Header__c>>();
        npaReversalAccountingTemplatesMap = new Map<String, List<cllease__Accounting_Template_Header__c>>();
        npaCatchupAccountingTemplatesMap = new Map<String, List<cllease__Accounting_Template_Header__c>>();

        for(cllease__Accounting_Template_Header__c atmpHdr : accountingTemplatesHdrList) {
            if(atmpHdr.cllease__Company__c != null && atmpHdr.cllease__Product__c != null && atmpHdr.cllease__Transaction_Type__c != null) {
                String key = atmpHdr.cllease__Company__c + '-' + atmpHdr.cllease__Product__c + '-' + atmpHdr.cllease__Transaction_Type__c;
                if (atmpHdr.cllease__Account_Status__c == null 
                        || atmpHdr.cllease__Account_Status__c == cllease.LendingConstants.ACCRUAL_TYPE_REGULAR) {
                    List<cllease__Accounting_Template_Header__c> temp = accountingTemplatesMap.get(key);
                    if(temp == null) {
                        temp = new List<cllease__Accounting_Template_Header__c>();
                        accountingTemplatesMap.put(key, temp);
                    }
                    temp.add(atmpHdr);
                } else if (atmpHdr.cllease__Account_Status__c == cllease.LendingConstants.ACCRUAL_TYPE_NPA) {
                    List<cllease__Accounting_Template_Header__c> temp = npaAccountingTemplatesMap.get(key);
                    if (temp == null) {
                        temp = new List<cllease__Accounting_Template_Header__c>();
                        npaAccountingTemplatesMap.put(key, temp);
                    }
                    temp.add(atmpHdr);
                } else if (atmpHdr.cllease__Account_Status__c == cllease.LendingConstants.ACCRUAL_TYPE_NPA_REVERSAL) {
                    List<cllease__Accounting_Template_Header__c> temp = npaReversalAccountingTemplatesMap.get(key);
                    if (temp == null) {
                        temp = new List<cllease__Accounting_Template_Header__c>();
                        npaReversalAccountingTemplatesMap.put(key, temp);
                    }
                    temp.add(atmpHdr);
                } else if (atmpHdr.cllease__Account_Status__c == cllease.LendingConstants.ACCRUAL_TYPE_NPA_CATCHUP) {
                    List<cllease__Accounting_Template_Header__c> temp = npaCatchupAccountingTemplatesMap.get(key);
                    if (temp == null) {
                        temp = new List<cllease__Accounting_Template_Header__c>();
                        npaCatchupAccountingTemplatesMap.put(key, temp);
                    }
                    temp.add(atmpHdr);
                }
            }
        }
    }  

    public Decimal getAmount(SObject obj, String objectName, String columnName) {
        String columnKey;
        String [] output;
        try {
            columnKey = objectName + '|' + columnName;
            String objectColumn = this.columnMap.get(columnKey);
            output = objectColumn.split('\\|');
            String columnAPIName = output[1];
            Decimal amount = (Decimal) obj.get(columnAPIName);            
            return amount;
        } catch(Exception e) {
            String msg;
            if(obj.getSObjectType().getDescribe().getLocalName() != output[0]) {
                msg = 'Transaction type on header does not match with Amount Object. ';
            } 
            msg += 'Not able to process : ' + columnName + ' on ' + objectName + '. Please check accounting setup.';
            
            System.debug(LoggingLevel.ERROR, 'Error while getting the amount : ' + msg);
            throw new CLSCustomException(msg);
        }
    }

    private cllease__GL_Transaction_Detail__c generateGLTransaction(cllease__Accounting_Template_Line__c templateLine,
                                                            SObject obj,
                                                            TransactionInfo txn, 
                                                            cllease__Lease_Account__c contract,
                                                            Date glDate,
                                                            SObject reversalObj) {
        cllease__GL_Transaction_Detail__c glTxnDetail = new cllease__GL_Transaction_Detail__c();
        glTxnDetail.cllease__Contract__c = contract.Id;
        //txnAPIForGL should not have a namespace, else it will fail in case of <namespace>__r
        SObject lookupObj = obj;
        glTxnDetail.put(txn.txnAPIForGL.replace('__r', '__c'), lookupObj.Id);
        glTxnDetail.putSObject(txn.txnAPIForGL, lookupObj);
        if(templateLine.cllease__Bill_As_Invoice__c) {
            glTxnDetail.cllease__Item_Id__c = templateLine.cllease__Item_Id__c;
            glTxnDetail.cllease__Item_Name__c = templateLine.cllease__Item_Name__c;
        }
        
        Decimal amount = getAmount(obj, templateLine.cllease__Amount_Object__c,
                                              templateLine.cllease__Amount_Object_Column__c);
        if(amount == null || amount == 0) {
            return null;
        }

        glTxnDetail.cllease__Credit_Amount__c = amount;
        glTxnDetail.cllease__Debit_Amount__c =  amount;
        glTxnDetail.cllease__GL_Date__c = glDate;
        glTxnDetail.cllease__Credit_GL_Account__c = templateLine.cllease__Credit_GL_Account__c;
        glTxnDetail.cllease__Debit_GL_Account__c = templateLine.cllease__Debit_GL_Account__c;
        glTxnDetail.cllease__Transaction_Type__c = templateLine.cllease__Transaction_Sub_Type__c;
        glTxnDetail.cllease__Transaction_Description__c = templateLine.cllease__Transaction_Sub_Type__r.name;
        glTxnDetail.cllease__Company__c = contract.cllease__Branch__c;
        glTxnDetail.cllease__Transaction_Description__c = obj.get('Name') + ' - ' + templateLine.name;
        return glTxnDetail;
    }

    public void process() {        
        List<cllease__GL_Transaction_Detail__c> glTxnsToBeInserted = new List<cllease__GL_Transaction_Detail__c>();
        // Currency changes        
        Map<Id, List<SObject>> contractNewObjects = new Map<Id, List<SObject>>();        
        if(accountingTemplatesMap.size() == 0) {
            System.debug(Logginglevel.ERROR, 'No accounting templates found.');
            return;
        }        
        System.debug(LoggingLevel.ERROR, 'Number of recs picked up by gl entries handler :' + this.contracts.size());
        SavePoint sp = Database.setSavePoint();
        try { 
            
            processGL(glTxnsToBeInserted, contractNewObjects);

            //perform DMLs
            if(contractNewObjects.size() > 0) {
                clcommon.MultiCurrencyUtil.setCurrencyCodes(contractNewObjects);
            }
            if(accrualTxnLinesToBeUpdated.size() > 0) {
                update accrualTxnLinesToBeUpdated;
            }
            if(otherTxnsToBeUpdated.size() > 0) {
                update otherTxnsToBeUpdated;
            }
            if(disbTxnsToBeUpdated.size() > 0) {
                update disbTxnsToBeUpdated;
            }
            if(billsToBeUpdated.size() > 0) {
                update billsToBeUpdated;
            }
            if(chargesToBeUpdated.size() > 0) {
                update chargesToBeUpdated;
            }
            if(paymentTxnsToBeUpdated.size() > 0) {
                update paymentTxnsToBeUpdated;
            }
            if(glTxnsToBeInserted.size() > 0) {
                insert glTxnsToBeInserted; 
            }             
        } catch(Exception e) {
            Database.rollback(sp);
            System.debug(LoggingLevel.ERROR, 'Exception in GLEntriesHandler : ' + e.getMessage() 
            + ' Stacktrace : ' + e.getStackTraceString() + ' line number : ' + e.getLineNumber());
            insert new cllease__Batch_Process_Log__c(Name='GLTxnGeneratorHandler ',
            cllease__Date__c=system.today(), cllease__Message__c='Error is '+e.getmessage()
            +' in line number: '+ e.getlinenumber());
        }
    }
    
    private void processGL(List<cllease__GL_Transaction_Detail__c> glTxnsToBeInserted, 
                            Map<Id, List<SObject>> contractNewObjects) {
        for(cllease__Lease_Account__c contract : this.contracts) {
            List<SObject> newObjects = new List<SObject>();
            //If there is no transaction available, skip to next contract
            if((contract.cllease__Other_Lease_Transactions__r.size() == 0)
                    && (contract.cllease__Dues_Details__r.size() == 0)
                    && (contract.cllease__Disbursement_Transactions__r.size() == 0)
                    && (contract.cllease__Charges__r.size() == 0)
                    && (contract.cllease__Lease_Payment_Details__r.size() == 0)
                    && (contract.cllease__Lease_Transaction_Line__r.size() == 0)) {
                System.debug(Logginglevel.DEBUG, 'Ignoring contract :' + contract.name);
                continue;
            }
            System.debug(Logginglevel.FINE, 'Processing contract :' + contract.name);
            //Other txns
            TransactionInfo txn = new TransactionInfo('cllease__Transaction_Type__c',
                                                        null,
                                                        'cllease__GL_Processing_Message__c',
                                                        'cllease__GL_Process_Date__c',
                                                        'cllease__Txn_Date__c',
                                                        'cllease__GL_Posted_Flag__c',
                                                        'cllease__GL_Transaction_Flag__c',
                                                        'cllease__Other_Transactions__r');
            List<cllease__GL_Transaction_Detail__c> generatedTxns = this.processTransactions(contract.cllease__Other_Lease_Transactions__r,
                                                                    txn, contract, null);
            glTxnsToBeInserted.addAll(generatedTxns);
            newObjects.addAll((List<SObject>)generatedTxns);
            otherTxnsToBeUpdated.addAll(contract.cllease__Other_Lease_Transactions__r);                
            //Disbursal txns
            txn = new TransactionInfo('cllease__Transaction_Type__c',
                                        null,
                                        'cllease__GL_Processing_Message__c',
                                        'cllease__GL_Process_Date__c',
                                        'cllease__Transaction_Date__c',
                                        'cllease__GL_Posted_Flag__c',
                                        'cllease__GL_Transaction_Flag__c',
                                        'cllease__Disbursement_Transaction__r');
            generatedTxns = this.processTransactions(contract.cllease__Disbursement_Transactions__r,
                                        txn, contract, null);
            glTxnsToBeInserted.addAll(generatedTxns);
            newObjects.addAll((List<SObject>)generatedTxns);
            disbTxnsToBeUpdated.addAll(contract.cllease__Disbursement_Transactions__r);                
            //Due details
            txn = new TransactionInfo('BILLING',
                                        null,
                                        'cllease__GL_Processing_Message__c',
                                        'cllease__GL_Process_Date__c',
                                        'cllease__Transaction_Date__c',
                                        'cllease__GL_Posted_Flag__c',
                                        'cllease__GL_Transaction_Flag__c',
                                        'cllease__Billing_Transactions__r');
            generatedTxns = this.processTransactions(contract.cllease__Dues_Details__r,
                                        txn, contract, null);
            glTxnsToBeInserted.addAll(generatedTxns);
            newObjects.addAll((List<SObject>)generatedTxns);
            billsToBeUpdated.addAll(contract.cllease__Dues_Details__r);
            //charges
            txn = new TransactionInfo('CHARGES',
                                        'cllease__Transaction_Sub_type__c',
                                        'cllease__GL_Processing_Message__c',
                                        'cllease__GL_Process_Date__c',
                                        'cllease__Transaction_Date__c',
                                        'cllease__GL_Posted_Flag__c',
                                        'cllease__GL_Transaction_Flag__c',
                                        'cllease__Charge__r');
            generatedTxns = this.processTransactions(contract.cllease__Charges__r,
                                        txn, contract, null);
            glTxnsToBeInserted.addAll(generatedTxns);
            newObjects.addAll((List<SObject>)generatedTxns);
            chargesToBeUpdated.addAll(contract.cllease__Charges__r);
            //Accrual txns
            txn = new TransactionInfo('ACCRUAL',
                                        'cllease__Transaction_Sub_type__c',
                                        'cllease__GL_Processing_Message__c',
                                        'cllease__GL_Process_Date__c',
                                        'cllease__Transaction_Date__c',
                                        'cllease__GL_Posted_Flag__c',
                                        'cllease__GL_Posted_Flag__c',
                                        'cllease__Lease_Accrual_Transaction__r');
            System.debug(LoggingLevel.ERROR, 'trxlines:' + contract.cllease__Lease_Transaction_Line__r);
            generatedTxns = this.processTransactions(contract.cllease__Lease_Transaction_Line__r,
                                        txn, contract, null);
            //hack, need to set accounted_yn__c on Accrual txns as there is no GL transaction flag            
            for(cllease__Lease_Trx_Lines__c accrualTxn: contract.cllease__Lease_Transaction_Line__r) {
                if(accrualTxn.cllease__GL_Processing_Message__c == 'GL transaction generated') {
                    accrualTxn.cllease__accounted_yn__c = true;
                }
            }
            glTxnsToBeInserted.addAll(generatedTxns);
            newObjects.addAll((List<SObject>)generatedTxns);
            accrualTxnLinesToBeUpdated.addAll(contract.cllease__Lease_Transaction_Line__r);                
            //Payment txns
            txn = new TransactionInfo('PAYMENT',
                                        'cllease__Transaction_Sub_type__c',
                                        'cllease__GL_Processing_Message__c',
                                        'cllease__GL_Process_Date__c',
                                        'cllease__Transaction_Date__c',
                                        'cllease__GL_Posted_Flag__c',
                                        'cllease__GL_Transaction_Flag__c',
                                        'cllease__Lease_Payment_Detail__r');
            generatedTxns = this.processTransactions(contract.cllease__Lease_Payment_Details__r,
                                        txn, contract, null);
            glTxnsToBeInserted.addAll(generatedTxns);
            newObjects.addAll((List<SObject>)generatedTxns);
            paymentTxnsToBeUpdated.addAll(contract.cllease__Lease_Payment_Details__r); 
            contractNewObjects.put(contract.Id, newObjects); 
        } 
    }
    
    //In case of reversal fourth parameter is null
    //fourth parameter is the map from of Id of Original object (like Lease Payment Detail
    //to the object to which gl txn is to be attached (like Payment Transaction Reversal)
    private List<cllease__GL_Transaction_Detail__c> processTransactions(List<SObject> objects,
                                                            TransactionInfo txn, 
                                                            cllease__Lease_Account__c contract,
                                                            Map<Id, SObject> orgObjToGLTxnObj) {
        List<cllease__GL_Transaction_Detail__c> glTxns = new List<cllease__GL_Transaction_Detail__c>();
        if(objects == null || objects.size() <= 0) {
            return glTxns;
        }
        System.debug(Logginglevel.DEBUG, 'Processing transaction type : ' + txn.getType(objects.get(0)));
        for(SObject obj : objects) {
            // TODO: Currently we only support NPA for Lease Accruals- We need to support it for all transaction types
            // To support NPA for all transactions, we need to add the field NPA_Flag__c on the corresponding transaction
            // that way the NPA can be handled generically in this code.
            Boolean npaFlag = false;
            Boolean npaReversalFlag = false;
            Boolean npaCatchupFlag = false;
            if (obj.getSObjectType() == cllease__Lease_Trx_Lines__c.SObjectType) {
                npaFlag = (Boolean) obj.getSObject('cllease__Trx_Header__r').get('cllease__NPA_Flag__c');
                npaReversalFlag = (Boolean) obj.getSObject('cllease__Trx_Header__r').get('cllease__NPA_Reversal_Flag__c');
                npaCatchupFlag = (Boolean) obj.getSObject('cllease__Trx_Header__r').get('cllease__Catch_Up_Flag__c');
            }
            List<cllease__Accounting_Template_Header__c> accountingTemplatesList;
            if (npaFlag) {
                accountingTemplatesList = this.npaAccountingTemplatesMap.get(contract.cllease__Branch__c + '-' +
                        contract.cllease__Lease_Product_Name__c + '-' +
                        txn.getType(obj));
            } else if (npaReversalFlag) {
                accountingTemplatesList = this.npaReversalaccountingTemplatesMap.get(contract.cllease__Branch__c + '-' +
                        contract.cllease__Lease_Product_Name__c + '-' +
                        txn.getType(obj));
            } else if (npaCatchupFlag) {
                accountingTemplatesList = this.npaCatchupaccountingTemplatesMap.get(contract.cllease__Branch__c + '-' +
                        contract.cllease__Lease_Product_Name__c + '-' +
                        txn.getType(obj));
            } else {
                accountingTemplatesList = this.accountingTemplatesMap.get(contract.cllease__Branch__c + '-' +
                        contract.cllease__Lease_Product_Name__c + '-' +
                        txn.getType(obj));
            }
            //check if accounting templates are there for this type
            if((accountingTemplatesList == null) || (accountingTemplatesList.size() == 0)) {
                System.debug(Logginglevel.ERROR, 'No template found for ' + contract.cllease__Branch__c + '-' +
                                                                            contract.cllease__Lease_Product_Name__c + '-' + 
                                                                            txn.getType(obj));
                
                obj.put(txn.glMsg, 'No templates found for the transaction type ' + txn.getType(obj));
                obj.put(txn.glProcessDate, this.sodDate);
                continue;
            }
            //for reversal txn date should be taken from reversal record
            Date txnDate = (Date)obj.get(txn.txnDate);

            System.debug(Logginglevel.ERROR, '-- object: '+obj);
            System.debug(Logginglevel.ERROR, '-- txnDate: '+txnDate);

            Date derivedGLDate = openPerIdentifier.getOpenPeriod(txnDate, contract.cllease__Lease_Product_Name__r.cllease__Use_Open_Acct_Period__c);

            if(derivedGLDate == MAXDATE) {
                obj.put(txn.glMsg, 'Could not derive open accounting period');
                obj.put(txn.glProcessDate, this.sodDate);                
                continue;
            }
            boolean accountingGenerated = false;
            String failureReason = 'Template lines not found'; // this can only be the reason when there is no exception
            for(cllease__Accounting_Template_Header__c templateHeader : accountingTemplatesList) {                
                List<cllease__GL_Transaction_Detail__c> headerGLTxns = new List<cllease__GL_Transaction_Detail__c>();          
                for(cllease__Accounting_Template_Line__c templateline : templateHeader.cllease__Accounting_Template_Lines__r) {
                    try {
                        if(String.isEmpty(txn.subType) || templateline.cllease__Transaction_Sub_type__c == (String)obj.get(txn.subtype)) {
                            cllease__GL_Transaction_Detail__c glTxn = generateGLTransaction(templateline, obj, txn, contract, derivedGLDate, null);
                            //can be null only if amount is 0, 
                            //this should be assumed that if txn is not generated and there is no failure reason then amount is 0
                            if(glTxn == null) { 
                                accountingGenerated = true;
                                //failureReason = 'Amount is not valid';
                            } else {                                
                                headerGLTxns.add(glTxn);
                                accountingGenerated = true;
                            }                            
                        }
                    } catch(Exception e) {
                        accountingGenerated = false;
                        failureReason = 'TemplateHeader:[' + templateHeader.name + '] TemplateLine:[' + templateline.name + '] ' + e.getMessage();
                        break;
                    }                    
                }
                if(accountingGenerated) {
                    glTxns.addAll(headerGLTxns);
                }
                               
            }     
            obj.put(txn.glPostedFlag, false);
            obj.put(txn.glProcessDate, this.sodDate);           
            if(!accountingGenerated) {                
                //TODO-change all gl msg fields to text area
                obj.put(txn.glMsg, failureReason.substring(0, failureReason.length() > 255 ? 254 : failureReason.length()));                
            } else { 
                obj.put(txn.glMsg, 'GL transaction generated');
                obj.put(txn.glFlag, false);
            }
            
        }
        return glTxns;        
    }
    
    //This class is used for passing metadata of a txn to a common method
    //which generates the GL trasaction
    class TransactionInfo {
        //Type e.g. BILLING, mentioned in "Transaction Type" in accounting template header
        //Or this can be a field name of the txn getType method should be used to get type
        String type; 
        //Name of the Field which determines subtype, this can be null not used for all txns
        String subtype;
        //Name of the Field which stores processing msg 
        String glMsg; 
        //Name of the Field which stores processing date
        String glProcessDate;
        //Name of the field which gives txn date
        String txnDate;
        //Name of the field which marks GL Posted
        String glPostedFlag;
        //Name of the field which marks if GL is to be processed
        String glFlag;
        //Name of the lookup field on GL txn for the txn 
        //for which we are generating gl
        String txnAPIForGL;        
        
        TransactionInfo(String type,
                            String subtype,
                            String glMsg,
                            String glProcessDate,
                            String txnDate,
                            String glPostedFlag,
                            String glFlag,
                            String txnAPIForGL) {
            this.type = type;
            this.subtype = subType;
            this.glMsg = glMsg;
            this.glProcessDate = glProcessDate;
            this.txnDate = txnDate;
            this.glPostedFlag = glPostedFlag;
            this.glFlag = glFlag;
            this.txnAPIForGL = txnAPIForGL;
        }
        
        String getType(SObject obj) {
            //type can be a field name or a direct string
            //depending on __c we can identify what is the case and return the value
            if(!String.isEmpty(this.type) && obj != null) {
                if(this.type.contains('__c') 
                        || this.type.contains('__C')) {
                    return (String)obj.get(this.type);
                }
                return this.type;
            }
            return null;
        }
    }
    
    class OpenPeriod {
        Date withDeriveOpenPeriod;
        Date withoutDeriveOpenPeriod;
        public override String toString() {
            return 'withDeriveOpenPeriod : ' + withDeriveOpenPeriod + ', withoutDeriveOpenPeriod : ' + withoutDeriveOpenPeriod;
        }
    }
    
    class OpenPeriodIdentifier {
        List<cllease__Period_Status__c> periods;
        
        Map<String, OpenPeriod> openPeriods = new Map<String, OpenPeriod>();
        OpenPeriodIdentifier(List<cllease__Period_Status__c> periods) {
            this.periods = periods;
            init();
        }
        
        void init() {
            //Periods are ordered in descending order with respect to start date
            //following code identifies the next open period
            Date currentOpenPeriod = MAXDATE;
            for(cllease__Period_Status__c period : periods) {
                OpenPeriod val = new OpenPeriod();
                val.withoutDeriveOpenPeriod = MAXDATE;
                if(period.cllease__Status__c == 'Open') {
                    currentOpenPeriod = Date.newInstance(Integer.valueOf(period.cllease__Period_Year__c), Integer.valueOf(period.cllease__Period_month__c), 1);
                    val.withoutDeriveOpenPeriod = currentOpenPeriod;           
                } 
                val.withDeriveOpenPeriod = currentOpenPeriod; 
                openPeriods.put(String.valueof(period.cllease__Period_Year__c) + String.valueof(period.cllease__Period_month__c), val);           
            }             
        }
     
        Date getOpenPeriod(Date txnDate, boolean deriveOpenPeriod) {
            String key = String.valueof(txnDate.year()) + String.valueof(txnDate.month());
            if(!openPeriods.containsKey(key)) {
                return MAXDATE;   
            }
            if(deriveOpenPeriod) {
                return openPeriods.get(key).withDeriveOpenPeriod;
            }
            return openPeriods.get(key).withoutDeriveOpenPeriod;
        }        
    }
}