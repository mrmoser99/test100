/**
 *  Author: Cloud Lending Solutions
 *  Description: 
 *
 **/
global class AssetProcessingJob extends clcommon.DynamicJob {
   
    private static String query;
    private static final String JOB_NAME = 'Asset Processing Job';

    global AssetProcessingJob() {
        super(JOB_NAME, initialize(null));
    }
    
    global AssetProcessingJob(List<String> assetWorkbenchNames) {
        super(JOB_NAME, initialize(assetWorkbenchNames));
    }
    
    global virtual override String getRuntimeQuery() {
        System.debug(LoggingLevel.ERROR, 'AssetProcessingJob query in getRuntimeQuery : ' + query);
        return query; 
    }

    public static String initialize(List<String> assetWorkbenchNames) {
        
        query = ' SELECT Id, name,                                                                                         '+
                '   cllease__Contract__c,                                                                                  '+
                '   cllease__Contract__r.cllease__Residual_Amount__c,                                                      '+
                '   cllease__Contract_Equipment__c,                                                                        '+
                '   cllease__Contract_Equipment__r.cllease__Residual_Amount__c,                                            '+
                '   cllease__Contract_Equipment__r.cllease__Status__c,                                                     '+
                '   cllease__Contract_Equipment__r.cllease__Estimated_Selling_Price__c,                                    '+
                '   Date_Sold__c,                                                                                          '+
                '   Sale_Price__c,                                                                                         '+
                '   Sold_to__c                                                                                             '+
                ' FROM cllease__Asset_workbench__c                                                                         '+
                ' WHERE process_asset_sale__c = true                                                                       '+
                '   AND cllease__Contract_Equipment__r.cllease__Status__c != \''+DLLNewCoConstants.EQUIPMENT_STATUS_SOLD+'\'';

        if(assetWorkbenchNames!=null && assetWorkbenchNames.size() > 0) {
            String assetWorkBenchNamesStr = '';
            for (String assetWorkbenchName : assetWorkbenchNames) {
                assetWorkBenchNamesStr = assetWorkBenchNamesStr + '\'' + String.escapeSingleQuotes(assetWorkbenchName) + '\'' + ',';
            }
            assetWorkBenchNamesStr = assetWorkBenchNamesStr.substring(0, assetWorkBenchNamesStr.length() - 1);
            query += ' AND Name in ('+ assetWorkBenchNamesStr + ')';
        }
        
        System.debug(LoggingLevel.ERROR, 'AssetProcessingJob query in initialize : ' + query);
        return query;
    }
          
    public override void doExecute(Database.BatchableContext bc, List<sObject> scope) {  
     
        List<cllease__Asset_workbench__c> assetProcessings = (List<cllease__Asset_workbench__c>)scope;
        Savepoint sp = database.setsavepoint();
        try {
            if(assetProcessings.size() >=0) {
                
                system.debug('assets:'+assetProcessings);
                //Query record type Asset Sale
                ID assetRecordTypeId;
                List<RecordType> exlist = [select Id
                                           , Name
                                           , SobjectType
                                           from RecordType
                                           where Name = :DLLNewCoConstants.REC_ASSETSALE
                                           and DeveloperName = 'Asset_Sale'
                                           and SObjectType = 'cllease__Other_Transaction__c'];
                
                //Query Asset Sale Fee
                //   cllease__fee__c 
                clcommon__Fee_Definition__c fee = [SELECT id,name
                              // FROM cllease__fee__c
                              FROM clcommon__Fee_Definition__c
                               WHERE name = :DLLNewCoConstants.FEE_ASSETSALE limit 1];
                
                //Query Asset Sale Transaction Type
                cllease__Transaction_Sub_Type__c transactionType = [SELECT id,name
                                                            FROM cllease__Transaction_Sub_Type__c
                                                            WHERE name = :DLLNewCoConstants.TXNSUBTYPE_ASSETSALE limit 1]; 
              
                List<cllease__Contract_Equipment__C> equipmentList  = new List<cllease__Contract_Equipment__C>();
                List<cllease__Other_Transaction__c> transactionList = new List<cllease__Other_Transaction__c>();
                List<cllease__charge__c>            chargeList      = new List<cllease__charge__c>();
                List<cllease__Asset_workbench__c>   assetworkbenchupdateList      = new List<cllease__Asset_workbench__c>();
                    
                for(cllease__Asset_workbench__c assetProcessing : assetProcessings){
              
                    if (exList != null && exList.size() > 0) {
                        assetRecordTypeId = exList.get(0).Id;
                    }
                    
                    
                    //Updating AssetWorkBench returned status; modified by aniroodha; 6 Nov 2017
                    assetProcessing.cllease__Return_Status__c='SOLD';
                    assetworkbenchupdateList.add(assetProcessing);
                    
                    //Creating Other transactions record;
                    cllease__Other_Transaction__c termTrx    = new cllease__Other_Transaction__c();
                    termTrx.RecordTypeId             = assetRecordTypeId;
                    termTrx.cllease__Lease_Account__c        = assetProcessing.cllease__Contract__c;
                    termTrx.cllease__txn_date__c           = assetProcessing.Date_Sold__c;
                    termTrx.cllease__Txn_Amt__c        = assetProcessing.Sale_Price__c;
                    termTrx.Sold_to__c               = assetProcessing.Sold_to__c;
                    termTrx.cllease__GL_Transaction_Flag__c  = true;
                    termTrx.cllease__Transaction_Type__c    = DLLNewCoConstants.TXN_ASSETSALE;
                    termTrx.cllease__Residual_Amount_New__c  = assetProcessing.cllease__Contract_Equipment__r.cllease__Residual_Amount__c;
                    termTrx.Asset_workbench__c             = assetProcessing.Id;
                    termTrx.Asset_Sale_Value__c             = assetProcessing.Sale_Price__c;
                    termTrx.Asset_Cost_of_Sale__c             = assetProcessing.cllease__Contract_Equipment__r.cllease__Estimated_Selling_Price__c;
                    transactionList.add(termTrx);
                    
                    //Creating charge record;
                    cllease__charge__c charge              =   new cllease__charge__c();
                    charge.cllease__Lease_Account__c       =   assetProcessing.cllease__Contract__c;
                    charge.cllease__Date__c                =   assetProcessing.Date_Sold__c;
                    charge.cllease__Original_Amount__c     =   assetProcessing.Sale_Price__c;
                    charge.cllease__GL_Transaction_Flag__c =   TRUE;                    
                   // charge.cllease__Fee__c                 =   fee.id;
                   charge.cllease__Fee_Definition__c =   fee.id;
                    charge.cllease__Transaction_Sub_Type__c=   transactionType.id;
                    chargeList.add(charge);
                    
                   //Updating Equipment status;         
                   cllease__Contract_Equipment__C equip = [Select id, name, cllease__Status__c
                                                            From cllease__Contract_Equipment__C
                                                            Where id =: assetProcessing.cllease__Contract_Equipment__c];
                    equip.cllease__Status__c = 'SOLD';
                    equipmentList.add(equip);
                }
              
                update assetworkbenchupdateList;
                insert transactionList;
                insert chargeList;
                update equipmentList;
            }
         } Catch(Exception e) {
            database.rollback(sp);  
            System.debug(LoggingLevel.ERROR, 'Exception: '+e.getMessage());    
            System.debug(LoggingLevel.ERROR, 'Exception Stack: '+e.getStackTraceString());           
            //insert batch process log for exceptions
            insert new cllease__Batch_Process_Log__c(name='AssetProcessingJob: ',cllease__Date__c=system.today(),
            cllease__Message__c='Error is '+e.getmessage()+' in line number: '+ e.getlinenumber());
        }   
      
    }
    
    public override void doInitialize() { }
    public override void doStart(Database.BatchableContext bc) { }   
    public override void doFinish(Database.BatchableContext bc) { }

}