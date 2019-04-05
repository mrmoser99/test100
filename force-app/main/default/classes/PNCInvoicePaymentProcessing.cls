/**
 * Owner: Cloud Lending Solutions
 * Description: Following job helps in processing PNC return file and 
 *              Create payments towards Bills and Charges FROM Invoice.
 *  next step: 
 *     
 **/
global with sharing class PNCInvoicePaymentProcessing extends clcommon.DynamicJob {
   
    private Map<String, Id> paymentModesMap;
    private Date currentSystemDate;
    private String autoACHPaymentMode = 'Auto ACH';
    //private Int_PX_Remit__c pncBatchHeaderRecord;
    private static String query;
    private static final String JOB_NAME = 'PNC Invoice Payment Creation Job';

    global PNCInvoicePaymentProcessing() {
        super(JOB_NAME, initialize(null));
        doInitialize();
    }
    
    global PNCInvoicePaymentProcessing(List<String> pncReturnRecordNames) {
        super(JOB_NAME, initialize(pncReturnRecordNames));
        doInitialize();
    }
    
    global virtual override String getRuntimeQuery() {
        System.debug(LoggingLevel.ERROR, 'PNCInvoicePaymentProcessing query in getRuntimeQuery : ' + query);
        return query; 
    }

    public static String initialize(List<String> pncReturnRecordNames) {

        // Query the PNC's BATCH HEADER Record for total payment date and batch date.
        // and take only latest Batch records for processing to avoid confusion in batch processing.
        /*List<Int_PX_Remit__c> pncBatchRecords = [SELECT Id, Name, 
                                                    Committed__c,
                                                    Payment_Batch_Date__c, 
                                                    Payment_Batch_Total_Amount__c
                                                FROM Int_PX_Remit__c
                                                WHERE Committed__c = false
                                                    AND Invoice_Number__c = :DLLNewCoConstants.PNC_BATCH_HEADER
                                                ORDER BY CreatedDate desc 
                                                LIMIT 1];

        Int_PX_Remit__c pncBatchHeaderRecordTemp;
        if(pncBatchRecords.size() > 0) {
            pncBatchHeaderRecordTemp = pncBatchRecords.get(0);
        } else {
            // Stop the PNC processing if no batch records are available in the system.
            return null; 
        }*/

        // 3. Querying PNC Response Object : Int_PX_Remit__c for payments creation
        // Following query skips the first record of PNC Payment which is for BATCH HEADER
        query = ' SELECT Id, Name,            '+
                '   Account_Num__c,           '+
                '   Date__c,                  '+
                '   Invoice_Amount_Paid__c,   '+
                '   Invoice_Number__c,        '+
                '   Line_Data__c,             '+
                '   Record_Number__c,         '+
                '   Transaction_Amount__c,    '+
                '   Transaction_Type__c,      '+
                '   Trans_Source__c,          '+
                '   Trans_UID__c,             '+
                '   Committed__c,             '+
                '   Remark__c                 '+
                ' FROM Int_PX_Remit__c        '+
                ' WHERE Committed__c = false  ';
                //'   AND Name > \''+ pncBatchHeaderRecordTemp.Name +'\'';

        if(pncReturnRecordNames!=null && pncReturnRecordNames.size() > 0) {
            String pncReturnRecordNamesStr = '';
            for (String pncReturnRecordName : pncReturnRecordNames) {
              pncReturnRecordNamesStr = pncReturnRecordNamesStr + '\'' + String.escapeSingleQuotes(pncReturnRecordName) + '\'' + ',';
            }
            pncReturnRecordNamesStr = pncReturnRecordNamesStr.substring(0, pncReturnRecordNamesStr.length() - 1);
            query += ' AND Name IN ('+ pncReturnRecordNamesStr + ')';
        }

        query += ' ORDER BY Date__c ';
        
        System.debug(LoggingLevel.ERROR, 'PNCInvoicePaymentProcessing query in getRuntimeQuery : ' + query);
        return query;
    }
    
    /**
     * Following execute method helps in creating Payment Transactions towards Bills and charges
     *      a. Creating payments towards Bills attached to Invoice
     *      b. Creating Payment towards Charges attached to Invoice
     **/
    public override void doExecute(Database.BatchableContext bc, List<sObject> scope) {
          
        Map<string, List<Int_PX_Remit__c>> multPxRemMap = new Map<string, List<Int_PX_Remit__c>>();
        Map<string, Decimal> multPxRemTrnAmount = new Map<string,Decimal>();
        List<Int_PX_Remit__c> updatePxremList = new List<Int_PX_Remit__c>();
        List<cllease__Lease_Payment_Transaction__c> pmtsToInsert = new List<cllease__Lease_Payment_Transaction__c>();
        
        Savepoint sp = database.setsavepoint();
        try {
            List<Int_PX_Remit__c> pxRemitList = (List<Int_PX_Remit__c>)scope;     
            // A. Looping all PNC return records to consolidate all related PNC Return records with total amount
            for(Int_PX_Remit__c pxRem: pxRemitList) {
                
                // Validations
                // 1. Remit file cannot process if Invoice Number null.
                if(pxRem.Invoice_Number__c == null) {
                    pxRem.Remark__c = ' Remit Record doesnot have invoice Number to process...';
                    updatePxremList.add(pxRem);
                    continue; 
                } 
                // 2. Future Payments Can't Create in CL Lease System.
                if(pxRem.Date__c > currentSystemDate) {
                    pxRem.Remark__c = ' Futute Payments Cannot Create in CL Lease, Remit Transaction Date: '+pxRem.Date__c +
                                      ' Current System Date: '+currentSystemDate;
                    updatePxremList.add(pxRem);
                    continue;
                }   
                // a. Consolidating all PNC Return records per Invoice Number
                List<Int_PX_Remit__c> pxRemitlst = multPxRemMap.get(pxRem.Invoice_Number__c);
                if(pxRemitlst == null) {
                    pxRemitlst = new List<Int_PX_Remit__c>();
                }
                pxRemitlst.add(pxRem);
                multPxRemMap.put(pxRem.Invoice_Number__c, pxRemitlst);
            }

            // B. Querying all invoices with charges where invoices with Bills and Charges
            List<Invoice__c> invoicesList = [SELECT Id, Name, LS_Contract__c,
                                                (SELECT Id, Name, cllease__Total_Due_Amount__c, Invoiced_In__c 
                                                    FROM Invoice_Bills__r
                                                    WHERE cllease__Payment_Satisfied__c = false),
                                                (SELECT Id, Name,cllease__Total_Due_Amount__c,Invoiced_In__c 
                                                    FROM Invoice_Charges__r
                                                    WHERE cllease__Paid__c = false) 
                                            FROM Invoice__c 
                                            WHERE name IN :multPxRemMap.keyset()];

            Map<Id, Decimal> billDueAmountMap = new Map<Id, Decimal>();
            Map<Id, Decimal> chargeDueAmountMap = new Map<Id, Decimal>();

            // Creating Map of Due Amount per Bill and Charges
            for(Invoice__c invoice : invoicesList) {
                for(cllease__Lease_account_Due_Details__c bill : invoice.Invoice_Bills__r) {
                    if(bill.cllease__Total_Due_Amount__c != null && bill.cllease__Total_Due_Amount__c > 0) {
                        billDueAmountMap.put(bill.Id, bill.cllease__Total_Due_Amount__c);
                    }                    
                }
                for(cllease__Charge__c charge: invoice.Invoice_Charges__r) {
                    if(charge.cllease__Total_Due_Amount__c != null && charge.cllease__Total_Due_Amount__c > 0) {
                        chargeDueAmountMap.put(charge.Id, charge.cllease__Total_Due_Amount__c);
                    }
                }
            }

            System.debug(LoggingLevel.ERROR, ' BillDueAmountMap: '+billDueAmountMap);
            System.debug(LoggingLevel.ERROR, ' ChargeDueAmountMap: '+chargeDueAmountMap);

            Decimal currentPmtAmount, pxTotalPmtAmount, billDueAmount, chargeDueAmount; 
            List<cllease__Lease_Payment_Transaction__c> pmtsPerRemit;
            // C. Looping through all Invoices for Creating Payment Transactions in System
            for(Invoice__c invoice : invoicesList) {
                // Looping all PNC Return files per Invoices to apply payments
                for(Int_PX_Remit__c pxRem : multPxRemMap.get(invoice.Name)) {
                    pxRem.Transaction_Amount__c = pxRem.Transaction_Amount__c != null ? pxRem.Transaction_Amount__c : 0;
                    pxTotalPmtAmount = pxRem.Transaction_Amount__c;
                    Date pmtDate = pxRem.Date__c;
                    pmtsPerRemit = new List<cllease__Lease_Payment_Transaction__c>();

                    // Validations
                    // 1. Payment Amount can't be <= 0 to create payments for Remit file
                    if(pxTotalPmtAmount <= 0 ) {
                        pxRem.Remark__c = 'Remit file has Transaction Amount = 0. Payments Cannot Create for it.';
                        updatePxremList.add(pxRem);
                        continue;
                    }

                    if(invoice.LS_Contract__c == null) {
                        pxRem.Remark__c = 'Invoice not linked to any Contract to create payments, Please verify Invoice: '+invoice.Name;
                        updatePxremList.add(pxRem);
                        continue;
                    }

                    // Applying Payments per PNC Return file to get exact payment Date
                    
                    // a. Looping through all bills from invoice and create payments
                    for(cllease__Lease_account_Due_Details__c bill : invoice.Invoice_Bills__r) {
                        currentPmtAmount = 0;
                        // Process bill only if bill due amount > 0
                        if(billDueAmountMap.containsKey(bill.Id)
                            && billDueAmountMap.get(bill.Id) > 0) {
                            billDueAmount    = billDueAmountMap.get(bill.Id);
                        } else {
                            continue; // skip payment process if Bill due amount = 0
                        }

                        if(pxTotalPmtAmount <= billDueAmount) {
                           currentPmtAmount = pxTotalPmtAmount;
                        } else {
                            currentPmtAmount = billDueAmount;    
                        }
                        // Creating Payment with currentPaymentAmount
                        cllease__Lease_Payment_Transaction__c pmtTxn = new cllease__Lease_Payment_Transaction__c();
                        pmtTxn.cllease__Contract__c = invoice.LS_Contract__c;                    
                        pmtTxn.cllease__Bill__c     = bill.Id;
                        pmtTxn.For_Invoice__c       = invoice.Id;
                        pmtTxn.cllease__Transaction_Amount__c   = currentPmtAmount;
                        pmtTxn.cllease__Payment_Mode__c         = paymentModesMap.get(autoACHPaymentMode);
                        pmtTxn.cllease__Transaction_Date__c     = pmtDate;
                        pmtTxn.cllease__Receipt_Date__c         = pmtDate;
                        pmtTxn.cllease__Cheque_Number__c        = pxRem.Transaction_Type__c;
                        //pmtTxn.PNC_Payment_Batch_Date__c            = pncBatchHeaderRecord.Payment_Batch_Date__c;
                        //pmtTxn.PNC_Payment_Batch_Total_Amount__c    = pncBatchHeaderRecord.Payment_Batch_Total_Amount__c;
                        
                        pmtsPerRemit.add(pmtTxn);
                        pxTotalPmtAmount -= currentPmtAmount;
                        billDueAmountMap.put(bill.Id, billDueAmount - currentPmtAmount);                    
                    }

                    // b. Looping through all charges from invoice and create payments  
                    for(cllease__Charge__c charge: invoice.Invoice_Charges__r) {
                        currentPmtAmount    = 0;
                        // Process charge only if charge due amount > 0
                        if(chargeDueAmountMap.containsKey(charge.Id)
                            && chargeDueAmountMap.get(charge.Id) > 0) {
                            chargeDueAmount    = chargeDueAmountMap.get(charge.Id);
                        } else {
                            continue; // skip payment process if charge due amount = 0
                        }

                        if(pxTotalPmtAmount <= chargeDueAmount) {
                            currentPmtAmount = pxTotalPmtAmount;
                        } else {
                            currentPmtAmount = chargeDueAmount;    
                        }

                        // Skip the payment creation in case of currentPmtAmount <=0 which is invalid forpayment creation 
                        if(currentPmtAmount <= 0) break; 
                        // Creating Payment with currentPaymentAmount
                        cllease__Lease_Payment_Transaction__c pmtTxn = new cllease__Lease_Payment_Transaction__c();
                        pmtTxn.cllease__Contract__c = invoice.LS_Contract__c;
                        pmtTxn.cllease__Charge__c   = charge.Id ;
                        pmtTxn.For_Invoice__c       = invoice.Id;
                        pmtTxn.cllease__Transaction_Amount__c       = currentPmtAmount;
                        pmtTxn.cllease__Payment_Mode__c             = paymentModesMap.get(autoACHPaymentMode);
                        pmtTxn.cllease__Transaction_Date__c         = pmtDate;
                        pmtTxn.cllease__Receipt_Date__c             = pmtDate;
                        pmtTxn.cllease__Cheque_Number__c            = pxRem.Transaction_Type__c;
                        //pmtTxn.PNC_Payment_Batch_Date__c            = pncBatchHeaderRecord.Payment_Batch_Date__c;
                        //pmtTxn.PNC_Payment_Batch_Total_Amount__c    = pncBatchHeaderRecord.Payment_Batch_Total_Amount__c;
                        
                        pmtsPerRemit.add(pmtTxn);
                        pxTotalPmtAmount -= currentPmtAmount;
                        chargeDueAmountMap.put(charge.Id, chargeDueAmount - currentPmtAmount); 
                    }

                    // c. Creating Payment if still amount available from PNT Return files for specific Invoice
                    //    Expecting extra amount goes to Excess
                    if(pxTotalPmtAmount > 0) {
                        cllease__Lease_Payment_Transaction__c pmtTxn = new cllease__Lease_Payment_Transaction__c();
                        pmtTxn.cllease__Contract__c = invoice.LS_Contract__c;
                        pmtTxn.For_Invoice__c       = invoice.Id;
                        pmtTxn.cllease__Transaction_Amount__c   = pxTotalPmtAmount;
                        pmtTxn.cllease__Payment_Mode__c         = paymentModesMap.get(autoACHPaymentMode);
                        pmtTxn.cllease__Transaction_Date__c     = pmtDate;
                        pmtTxn.cllease__Receipt_Date__c         = pmtDate;
                        pmtTxn.cllease__Cheque_Number__c        = pxRem.Transaction_Type__c;
                        //pmtTxn.PNC_Payment_Batch_Date__c            = pncBatchHeaderRecord.Payment_Batch_Date__c;
                        //pmtTxn.PNC_Payment_Batch_Total_Amount__c    = pncBatchHeaderRecord.Payment_Batch_Total_Amount__c;

                        pmtsPerRemit.add(pmtTxn);
                    }

                    if(pmtsPerRemit.size() > 0) {
                        pmtsToInsert.addAll(pmtsPerRemit);
                    }
                    pxRem.Committed__c = true;
                    pxRem.Remark__c = 'Remit file Successfully Processed. Check Invoice for Payments...';
                    updatePxremList.add(pxRem);
                }
            }
        
            System.debug(LoggingLevel.ERROR,'pmtsToInsert values :::'+pmtsToInsert);
        
            // D. DML Operations on New Payments
            if(pmtsToInsert.size() > 0) {
                insert pmtsToInsert;
            }

            // E. Applying the created payments
            //applyPayments(pmtsToInsert);

            // F. Updating PNC Return records for processing "Committed__c = true"
            if(updatePxremList.size()>0) {
                update updatePxremList;
            }
                 
        } catch(Exception e) {
            database.rollback(sp);   
            System.debug(LoggingLevel.ERROR, 'Exception: '+e.getMessage());    
            System.debug(LoggingLevel.ERROR, 'Exception Stack: '+e.getStackTraceString());      
            //insert batch process log for exceptions
            insert new cllease__Batch_Process_Log__c(Name='PNCInvoicePaymentProcessing',
            cllease__Date__c=system.today(), cllease__Message__c='Error is '+e.getMessage()
            +' in line number: '+ e.getLineNumber());
        }
    }
    
    public override void doInitialize() { 
        // Other Required setup: Payment Mode
        List<cllease__Payment_Mode__c> paymentModes = [SELECT Id, Name 
                                                            FROM cllease__Payment_Mode__c
                                                            LIMIT 100];

        paymentModesMap = new Map<String, Id>();                                                    
        for(cllease__Payment_Mode__c paymentMode : paymentModes) {
            paymentModesMap.put(paymentMode.Name, paymentMode.Id);
        }

        // 2. Current CL Lease System Date
        currentSystemDate = cllease.SystemDateUtil.getCurrentSystemDate();

        // Query the PNC's BATCH HEADER Record for total payment date and batch date.
        // and take only latest Batch records for processing to avoid confusion in batch processing.
        /*List<Int_PX_Remit__c> pncBatchRecords = [SELECT Id, Name, 
                                                    Committed__c,
                                                    Payment_Batch_Date__c, 
                                                    Payment_Batch_Total_Amount__c
                                                FROM Int_PX_Remit__c
                                                WHERE Committed__c = false
                                                    AND Invoice_Number__c = :DLLNewCoConstants.PNC_BATCH_HEADER
                                                ORDER BY CreatedDate desc 
                                                LIMIT 1];

        if(pncBatchRecords.size() > 0) {
            pncBatchHeaderRecord = pncBatchRecords.get(0);
        }*/
    }

    public override void doStart(Database.BatchableContext bc) { }   

    public override void doFinish(Database.BatchableContext bc) { 
        // Marking Processed PNC's "BATCH HEADER" as Commited.
        /*if(pncBatchHeaderRecord != null) {
            pncBatchHeaderRecord.Committed__c = true;
            update pncBatchHeaderRecord;
        }*/
    }
}