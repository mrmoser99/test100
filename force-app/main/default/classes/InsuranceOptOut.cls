global class InsuranceOptOut {
    
    WebService static String insuranceOptOut(String applicationid) {
    
      try {
        
         ID RecordTypeId;
                List<RecordType> exlist = [SELECT  Id
                                           , Name
                                           , SobjectType
                                           FROM  RecordType
                                           WHERE  Name = :DLLNewCoConstants.REC_STOP_PERIODIC_FEE
                                           and DeveloperName = 'Stop_Periodic_Fee'
                                           and SObjectType = 'cllease__Other_Transaction__c'];
                  
        Date currentSystemDate = cllease.SystemDateUtil.getCurrentSystemDate();                         
        Date dateToCompare = currentSystemDate.toStartOfMonth();                                   
                                           
        List<cllease__Other_Transaction__c> transactionList = new List<cllease__Other_Transaction__c>();
        
        List<cllease__Payment_Stream__c> paymentProcessings = [ SELECT  id, name, 
                                                                cllease__Beginning_Receivable__c, 
                                                                cllease__Rental_Amount__c, 
                                                                cllease__Ending_Receivable__c , 
                                                                cllease__Active__c, 
                                                                cllease__Date__c, 
                                                                cllease__Billed__c,
                                                                cllease__Contract__c 
                                                              FROM  cllease__Payment_Stream__c 
                                                              WHERE  cllease__Contract__c =:applicationid 
                                                                and cllease__Payment_Type__c = 'FEES'
                                                                and cllease__Billed__c = false
                                                                and cllease__Transaction_Sub_Type__r.Name= :DLLNewCoConstants.TXNSUBTYPE_INSURANCE_FEE
                                                                and cllease__Date__c>=:dateToCompare];
                                                              
                                                              //(cllease__Billed__c=False 
                                                              //or (cllease__Billed__c=True))];
                                                              
      List<cllease__Fee_Stream__c> feesProcessings = [ SELECT  id, name, 
                                                              cllease__Beginning_Balance__c, 
                                                              cllease__Fee_Amount__c, 
                                                              cllease__Ending_Balance__c , 
                                                              cllease__Active__c, 
                                                              cllease__Date__c,
                                                              cllease__Contract__c,
                                                              cllease__Fee_Name__r.RateFactor__c,
                                                              cllease__Fee_Name__r.clcommon_Amount__c 
                                                              FROM  cllease__Fee_Stream__c 
                                                              WHERE  cllease__Contract__c =:applicationid
                                                                and cllease__Accrued__c = false
                                                                and cllease__Transaction_Sub_Type__r.Name= :DLLNewCoConstants.TXNSUBTYPE_INSURANCE_FEE
                                                                and cllease__Date__c >=:dateToCompare];
                                                              
                         
              
            if(paymentProcessings.size() >=0) {
            for(cllease__Payment_Stream__c paymentProcessing :paymentProcessings)
                {
                paymentProcessing.cllease__Active__c=False;
                }
                update paymentProcessings;
            }
            
            if(feesProcessings.size() >=0) {
             if (exList != null && exList.size() > 0) {
                        RecordTypeId = exList.get(0).Id;
                    }
            for(cllease__Fee_Stream__c feeProcessing :feesProcessings)
                {
                feeProcessing.cllease__Active__c=False;
                /*cllease__Other_Transaction__c termTrx    = new cllease__Other_Transaction__c();
                termTrx.cllease__Lease_Account__c        = feeProcessing.cllease__Contract__c;
                termTrx.cllease__Unpaid_Fees__c          = feeProcessing.cllease__Fee_Amount__c;
                termTrx.cllease__Description__c          = 'The Rate Factor and Flat fees are as follows '+feeProcessing.cllease__Fee_Name__r.RateFactor__c +' and '+ feeProcessing.cllease__Fee_Name__r.clcommon_Amount__c;
                termTrx.cllease__GL_Transaction_Flag__c  = true;
                termTrx.cllease__Transaction_Type__c     = 'Stop-Periodic-Fee';
                termTrx.RecordTypeId                     = RecordTypeId;
                transactionList.add(termTrx);*/
                }
                update feesProcessings;
               //insert transactionList;
            }
            
               
               
            
        } Catch(Exception e) {
            return 'Exception: '+e.getMessage();
        }   
        return 'Processed Insurance Opt Out Successfully';
        
   }
     
}