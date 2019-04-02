global class AssetSaleProcessing {
    WebService static String processAssetSale(String assetWorkBenchID) {
        List<cllease__Asset_workbench__c> assetProcessings = [Select Id, name,
                                                                cllease__Contract__c,
                                                                cllease__Contract__r.cllease__Residual_Amount__c, 
                                                                cllease__Contract_Equipment__c,
                                                                cllease__Contract_Equipment__r.cllease__Status__c,
                                                                cllease__Contract_Equipment__r.cllease__Estimated_Selling_Price__c,
                                                                cllease__Contract_Equipment__r.cllease__Residual_Amount__c,
                                                                Date_Sold__c,
                                                                Sale_Price__c,
                                                                Sold_to__c
                                                            From cllease__Asset_workbench__c
                                                            Where id =: assetWorkBenchID];
       // Savepoint sp;
        try {
               //Query Asset Sale Fee
                List<clcommon__Fee_Definition__c> fees = [SELECT id,name 
                               FROM clcommon__Fee_Definition__c
                               WHERE name = :DLLNewCoConstants.FEE_ASSETSALE limit 1];

                if(fees.size() == 0) {
                    return 'Fee Definition: ASSET SALE is missing from Fee Configuration, Please create it before Processing Asset Sale...';
                }
                clcommon__Fee_Definition__c fee = fees.get(0);
            
               //Query Asset Sale Transaction Type
                cllease__Transaction_Sub_Type__c transactionType = [SELECT id,name
                                FROM cllease__Transaction_Sub_Type__c
                                WHERE name = :DLLNewCoConstants.TXNSUBTYPE_ASSETSALE limit 1];                
              
            if(assetProcessings.size() >=0) {
                cllease__Asset_workbench__c assetProcessing = assetProcessings.get(0);
                System.debug(LoggingLevel.ERROR, '^^^^ASSET : ' + assetProcessing.cllease__Contract__r.cllease__Residual_Amount__c);
                validate(assetProcessing);
                
                // termination recordTypeID
                ID assetRecordTypeId;
                List<RecordType> exlist = [select Id
                                           , Name
                                           , SobjectType
                                           from RecordType
                                           where Name = :DLLNewCoConstants.REC_ASSETSALE
                                           and DeveloperName = 'Asset_Sale'
                                           and SObjectType = 'cllease__Other_Transaction__c'];
                
                if (exList != null && exList.size() > 0) {
                    assetRecordTypeId = exList.get(0).Id;
                }
              //  sp = Database.setSavepoint();
                //Updating AssetWorkBench returned status; modified by aniroodha; 6 Nov 2017
                assetProcessing.cllease__Return_Status__c='SOLD';
                update assetProcessing;
                
                // 1. Create Other transaction of ASSET SALE Type
                cllease__Other_Transaction__c termTrx    = new cllease__Other_Transaction__c();
                termTrx.cllease__Lease_Account__c        = assetProcessing.cllease__Contract__c;
                termTrx.cllease__txn_date__c             = assetProcessing.Date_Sold__c;
                termTrx.cllease__Txn_Amt__c              = assetProcessing.Sale_Price__c;
                termTrx.Sold_to__c                       = assetProcessing.Sold_to__c;
                termTrx.cllease__GL_Transaction_Flag__c  = true;
                termTrx.cllease__Transaction_Type__c     = DLLNewCoConstants.TXN_ASSETSALE;
                //added by aniroodha; on 27 Nov 2017; 
                termTrx.cllease__Residual_Amount_New__c  = assetProcessing.cllease__Contract_Equipment__r.cllease__Residual_Amount__c;
                termTrx.RecordTypeId                     = assetRecordTypeId;
                termTrx.Asset_workbench__c               = assetProcessing.Id;
                termTrx.Asset_Sale_Value__c              = assetProcessing.Sale_Price__c;
                termTrx.Asset_Cost_of_Sale__c            = assetProcessing.cllease__Contract_Equipment__r.cllease__Estimated_Selling_Price__c;
                insert termTrx;
                // 2. Create Bill with required fields
                cllease__Lease_account_Due_Details__c dueDetail = new cllease__Lease_account_Due_Details__c();
                dueDetail.cllease__Rental_Due_Amount__c = assetProcessing.Sale_Price__c;
                dueDetail.cllease__Total_Due_Amount__c  = assetProcessing.Sale_Price__c;
                dueDetail.cllease__Due_Type__c               = 1;
                dueDetail.cllease__Due_Type_Description__c   = DLLNewCoConstants.DUETYPE_BILLDUEDATE;
                dueDetail.cllease__Due_Date__c               = cllease.SystemDateUtil.getCurrentSystemDate();
                dueDetail.cllease__Transaction_Date__c       = cllease.SystemDateUtil.getCurrentSystemDate();
                dueDetail.cllease__GL_Transaction_Flag__c    = true;
                dueDetail.cllease__Lease_Account__c          = assetProcessing.cllease__Contract__c;
                dueDetail.cllease__Account__C                = assetProcessing.Sold_to__c;
                dueDetail.Gain_Loss__c                      = (assetProcessing.Sale_Price__c - assetProcessing.cllease__Contract__r.cllease__Residual_Amount__c);
                insert dueDetail;
                
                // create due line
                cllease__Due_Detail_Lines__c dueLine = new cllease__Due_Detail_Lines__c();
                dueline.cllease__Tax_Processed__c       = true;
                dueline.cllease__Remarks__c             = '';
                dueline.cllease__Total_Due_Amount__c    = dueDetail.cllease__Total_Due_Amount__c;
                dueline.cllease__Rental_Due_Amount__c   = dueDetail.cllease__Total_Due_Amount__c;
                dueline.cllease__Bill__c                = dueDetail.Id;
                dueline.cllease__Due_Date__c            = dueDetail.cllease__Due_Date__c;
                dueline.cllease__Transaction_Date__c    = cllease.SystemDateUtil.getCurrentSystemDate();
                dueline.cllease__Contract_Equipment__c  = assetProcessing.cllease__Contract_Equipment__c;
                insert dueLine;
                
                //create charge
                cllease__charge__c charge              =   new cllease__charge__c();
                charge.cllease__Lease_Account__c       =   assetProcessing.cllease__Contract__c;
                charge.cllease__Date__c                =   assetProcessing.Date_Sold__c;
                charge.cllease__Original_Amount__c     =   assetProcessing.Sale_Price__c;
                charge.cllease__GL_Transaction_Flag__c =   TRUE;
                charge.cllease__Fee_Definition__c      =   fee.id;
                charge.cllease__Transaction_Sub_Type__c=   transactionType.id;
                insert charge;
                
                cllease__Contract_Equipment__C equip = [Select id, name, cllease__Status__c
                                                        From cllease__Contract_Equipment__C
                                                        Where id =: assetProcessing.cllease__Contract_Equipment__c];
                equip.cllease__Status__c = 'SOLD';
                update equip;
            }
        } Catch(Exception e) {
           // Database.rollback(sp);
            System.debug(LoggingLevel.ERROR, '^^^^e : ' + e.getStackTraceString());
            return 'Exception: '+e.getMessage();
        }   
        return 'Processed Asset Sale Successfully';
    }
    
    private static void validate(cllease__Asset_workbench__c assetProcessing) {
        if(assetProcessing.cllease__Contract_Equipment__r.cllease__Status__c == 'SOLD') {
            throw new cllease.LeaseServicingException('Equipment is already sold', 'ERROR');
        }
        if(assetProcessing.Sale_Price__c==null || assetProcessing.Sale_Price__c <= 0) {
            throw new cllease.LeaseServicingException('Please enter Sale Prices', 'ERROR');
        }
        if(assetProcessing.Sold_to__c==null) {
            throw new cllease.LeaseServicingException('Please enter Sale To', 'ERROR');
        }
        if(assetProcessing.Date_Sold__c==null) {
            throw new cllease.LeaseServicingException('Please enter Sale Date', 'ERROR');
        }
        if(assetProcessing.cllease__Contract__c==null) {
            throw new cllease.LeaseServicingException('Contract is missing from Asset Processing', 'ERROR');
        }
        if(assetProcessing.cllease__Contract_Equipment__c==null) {
            throw new cllease.LeaseServicingException('Contract Equipment missing from Asset Processing', 'ERROR');
        }
    }
  
  
      WebService static String multiAssetProcess() {
        
        Database.executeBatch(new AssetProcessingJob());
        return 'Batch Process Initiated';
    } 

  
}