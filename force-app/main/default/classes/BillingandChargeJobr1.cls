global with sharing  class BillingandChargeJobr1 extends clcommon.DynamicJob{
    private static String query;
    private static final String JOB_NAME = 'BILL AND CHARGE FILE JOB';
    private static String sysDateStr;
    
    global BillingandChargeJobr1() {
        super(JOB_NAME, initialize(null));
        doInitialize();
    }

    global BillingandChargeJobr1(List<String> contractNames) {
        super(JOB_NAME, initialize(contractNames));
        doInitialize();
    }
    
    global virtual override String getRuntimeQuery() {
        System.debug(LoggingLevel.ERROR, 'BillingandChargeJobr1 query in getRuntimeQuery : ' + query);
        return query; 
    }

    public static String initialize(List<String> contractNames) {
        
        // Creating the Contract Query String
        query = ' SELECT Id, Name, cllease__Pre_Bill_Days__c'+
                ' FROM cllease__Lease_Account__c ';

        // Filtering specific contracts for batch processing
        if(contractNames!=null && contractNames.size() > 0) {
            String contractNamestr = '';
            for (String dueDetailName : contractNames) {
                contractNamestr = contractNamestr + '\'' + String.escapeSingleQuotes(dueDetailName) + '\'' + ',';
            }
            contractNamestr = contractNamestr.subString(0, contractNamestr.length() - 1);
            query += ' WHERE Name in ('+ contractNamestr + ')';
        }

        query += ' ORDER BY Name ';

        System.debug(LoggingLevel.ERROR, 'BillingandChargeJobr1 query in initialize : ' + query);
        return query;
    }

    public override void doExecute(Database.BatchableContext bc, List<sObject> scope) {
        List<cllease__Lease_Account__c> contracts = (List<cllease__Lease_Account__c>)scope;
        //List<cllease__Lease_account_Due_Details__c> billList = new List<cllease__Lease_account_Due_Details__c>();
        Set<Id> contractIds = new Set<Id>();
            
        Savepoint sp = database.setsavepoint();
        try {
      // Extracting the Custom System Date
            Datetime currentCLLeaseDate = cllease.SystemDateUtil.getCurrentSystemDate();
            String currentSystemDateStr = currentCLLeaseDate.format('dd/MM/yyyy');
            Date currentDate = cllease.SystemDateUtil.getCurrentSystemDate();
            date currentDate1 = date.newinstance(currentCLLeaseDate.year(), currentCLLeaseDate.month(), currentCLLeaseDate.daygmt());
            System.debug(currentCLLeaseDate);
            System.debug(currentDate);
            // Looping through all contracts for extracting the bills
            for(cllease__Lease_Account__c contract : contracts) {
                if(contract != null){
                    System.debug(currentCLLeaseDate.daygmt());
                    System.debug(contract.cllease__Pre_Bill_Days__c);
                    //System.debug(contract.Bill_Cycle_Day__c);
                    integer Days =(integer)(currentCLLeaseDate.daygmt() + contract.cllease__Pre_Bill_Days__c);
                    integer lastday = currentDate1.addMonths(1).toStartofMonth().addDays(-1).day();
                    //if(Days > lastday)
                       // Days = Days - lastday;
                    //System.debug(Days);
                    //if(Days == contract)
                       contractIds.add(contract.Id); 
                }  
            }

            String csvBody;
            // Call Utility for Creating the csv file for the Bills and charges
            csvBody = DisplayRecordHandlerr1.doCreateCSV(contractIds);
            //docBody = displayRecHandler.doSearch(billList);
            
            system.debug(csvBody);
            
            // Creating the report file and insert into documents
            Folder reportFolder = [SELECT Id,Name FROM Folder WHERE Name = 'Billing and charges report' Limit 1];

            // Checking the existing file for creation
            String fileName = 'Billing_and_Charges_Report--'+ String.valueOf(currentDate) +'.csv';
            List<Document> documents = [SELECT Id, Name, Body, FolderId, IsPublic, ContentType FROM Document WHERE Name = :fileName LIMIT 1];
            

            system.debug('documents Size :'+ documents.size());
            system.debug('File Name= '+fileName);
            
            
            Document document;
            String existingContent = '';
            //if(documents.size()==0) {
                document = new Document(Name = fileName);
                document.body = Blob.valueOf(DisplayRecordHandlerr1.getABillAndChargeCSVFileHeader() + csvBody);
                system.debug('File Does not exist');
                
            //} else {
             //   document = documents.get(0);
               // existingContent = document.body.toString();
                document.body   = Blob.valueOf(existingContent + csvBody);
                system.debug('File exist');
            //}
            
            document.FolderId    =   reportFolder.Id;
            document.IsPublic    =   true;
            document.ContentType = 'application/vnd.ms-excel.xls';
           
            upsert document;

            System.debug(LoggingLevel.ERROR, 'docuemnt ID: '+document);
            // update the Bills and charges with Report Docuemnt Id.
            String url = URL.getSalesforceBaseUrl().toExternalForm();
            System.debug(LoggingLevel.ERROR, 'url: '+url);

            System.debug(LoggingLevel.ERROR, 'bill size: '+ DisplayRecordHandlerr1.billsToUpdate.size());
            System.debug(LoggingLevel.ERROR, 'charge size : '+ DisplayRecordHandlerr1.chargesToUpdate.size());

            if(DisplayRecordHandlerr1.billsToUpdate.size() > 0) {
                for(cllease__Lease_account_Due_Details__c bill : DisplayRecordHandlerr1.billsToUpdate) {
                    //bill= url +'/'+ document.Id;
                }

                update DisplayRecordHandlerr1.billsToUpdate;
            }

            if(DisplayRecordHandlerr1.chargesToUpdate.size() > 0) {
                for(cllease__Charge__c charge : DisplayRecordHandlerr1.chargesToUpdate) {
                    //charge = url +'/'+ document.Id;
                }

                update DisplayRecordHandlerr1.chargesToUpdate;
            }

        } catch(Exception e) {
            database.rollback(sp);   
            System.debug(LoggingLevel.ERROR, 'Exception: '+e.getMessage());    
            System.debug(LoggingLevel.ERROR, 'Exception Stack: '+e.getStackTraceString());      
            //insert batch process log for exceptions
            insert new cllease__Batch_Process_Log__c(Name = 'BillingandChargeJobr1 Creating: ', cllease__Date__c = System.today(),
            cllease__Message__c = 'Error is '+e.getMessage() +' in line number: '+ e.getLineNumber());
        }

    }

    public override void doInitialize() { }
    public override void doStart(Database.BatchableContext bc) { }

    public override void doFinish(Database.BatchableContext bc) { 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {'vericode@cloudlendinginc.com'});
        mail.setReplyTo('vericode@cloudlendinginc.com');
        mail.setSenderDisplayName('Batch Processing');
        mail.setSubject('BILL AND CHARGE FILE JOB Completed');
        mail.setPlainTextBody('Batch Process has completed');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

}