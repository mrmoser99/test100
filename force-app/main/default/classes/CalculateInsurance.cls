Global class CalculateInsurance{ 

    webservice static string GetInsuranceAmount(string applicationid){
        try{ 
            // query for term and start date details
            List<genesis__Applications__c> applist = [SELECT genesis__Term__c,
                                                             genesis__Expected_First_Payment_Date__c 
                                                             FROM genesis__Applications__c 
                                                                 WHERE id=:applicationid 
                                                             LIMIT 1];
     
            // query for total equipment value for a contract
            AggregateResult[] groupedResults = [SELECT SUM(genesis__Estimated_Selling_Price__c)TotalPrice 
                                                FROM genesis__Application_Equipment__c 
                                                    WHERE genesis__Application__c=:applicationid]; 
            Object SumAmount = groupedResults[0].get('TotalPrice');
            Decimal TotalEquipmentValue = (Decimal)SumAmount;
     
            // query for ratefactor and flat fee details
            List<clcommon__Fee_Definition__c> ClleaseFee=[SELECT Id,
                                                                  Name,
                                                                  RateFactor__c,
                                                                  clcommon__Amount__c 
                                                                      FROM clcommon__Fee_Definition__c 
                                                                          WHERE Name='Insurance Fees' 
                                                                              AND clcommon__Active__c = true 
                                                                              AND RateFactor__c > 0 
                                                                          LIMIT 1];
      
     
            list<Application_Fee__c> appfeestobeinserted = new list<Application_Fee__c>();
            list<Application_Fee__c> appfeelist=[SELECT Amount__c,
                                                        Start_Date__c,
                                                        Number_of_Payments__c
                                                        FROM Application_Fee__c 
                                                            WHERE Fee__r.Name='Insurance Fees' 
                                                                AND Application__c=:applicationid];
            if(appfeelist.size() > 0 && ClleaseFee.size() > 0){
                Boolean shouldUpdateAppFees = false;
                // code for update of application fee records
                Decimal insuranceAmount = (TotalEquipmentValue *  ClleaseFee[0].RateFactor__c) + ClleaseFee[0].clcommon__Amount__c;
                if(insuranceAmount != appfeelist[0].Amount__c){
                    appfeelist[0].Amount__c=insuranceAmount;
                    shouldUpdateAppFees = true;
                } 
                if(appfeelist[0].Start_Date__c != applist[0].genesis__Expected_First_Payment_Date__c){
                    appfeelist[0].Start_Date__c = applist[0].genesis__Expected_First_Payment_Date__c;
                    shouldUpdateAppFees = true;
                }
                if(appfeelist[0].Number_of_Payments__c != applist[0].genesis__Term__c){
                    appfeelist[0].Number_of_Payments__c = applist[0].genesis__Term__c;
                    shouldUpdateAppFees = true;
                }
                
                if(shouldUpdateAppFees == true){
                    update appfeelist;
                }
            } else if(appfeelist.size() == 0 && ClleaseFee.size() > 0){
                // code for insert of application fee records
                //(Total equipment Value * 0.00028) + $17.25 = Monthly Insurance Charge
                Decimal insuranceAmount = (TotalEquipmentValue *  ClleaseFee[0].RateFactor__c) + ClleaseFee[0].clcommon__Amount__c;
                Application_Fee__c appfee = new Application_Fee__c(
                                                Fee__c=ClleaseFee[0].id,
                                                Amount__c= cllease.ValueUtil.round(insuranceAmount),
                                                Application__c=applicationid,
                                                Fee_Amount__c=ClleaseFee[0].clcommon__Amount__c,
                                                Frequency__c='Monthly',
                                                Number_of_Payments__c=applist[0].genesis__Term__c,
                                                Start_Date__c=applist[0].genesis__Expected_First_Payment_Date__c);
                appfeestobeinserted.add(appfee);   
                insert appfeestobeinserted;        
                     
            }
            
            updateDateOnFees(applicationid, applist[0].genesis__Expected_First_Payment_Date__c);
            // update service fee if needed
            UpdateServiceFeeHandler.updateDateOnFees(applicationid);
        } catch(exception e){
            //debug exceptions and return with Failure status
            String return_msg;
            // return_msg = 'FAILURE';
            return_msg =e.getmessage();
            system.debug('** Error in calculating Property tax fee **'+e.getmessage());
            system.debug('=====line======='+e.getLinenumber());
            return return_msg;
        }
    
        //return with success status
        String return_msg = 'SUCCESS';
    
        return return_msg;    
    }
    
    // Update date on Interm Rent and Origination Fee if payment due date changes
    public static void updateDateOnFees(String applicationId, Date firstPaymentDueDate){
        Set<String> feeTypes = new Set<String>{'Origination Fees', 'Interim Rent'};
        List<Application_Fee__c> fees = [SELECT ID,
                                                Start_Date__c
                                                FROM Application_Fee__c
                                                Where Application__c = :applicationId
                                                    AND Fee__r.Name IN :feeTypes]; 
        for(Application_Fee__c fee : fees){
            if(fee.Start_Date__c != firstPaymentDueDate){
                fee.Start_Date__c = firstPaymentDueDate;
            }
        }  
        update fees;                                                                                                                                                                       
    }
     
}