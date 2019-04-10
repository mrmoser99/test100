global with sharing class AP_VoidInvoice {

    @AuraEnabled
	public static String void(String recordId){

        Map<String,String> response = new Map<String,String>();

        Invoice__c i = [SELECT ID
            ,name
            ,voided_in_pnc__c
            ,sent_to_pnc__c
            FROM Invoice__c
            where id = :recordId 
            ]; 

        if (i.voided_in_pnc__c){
            response.put('Message','This invoice has been previously voided!');
            return JSON.serialize(response);
        }

         List<Int_PX_Billing__c> lineList = [Select line_data__c
                                        from Int_PX_Billing__c 
                                        where committed__c = false
                                    ];
         if (!lineList.isEmpty()) {
            response.put('Message','There is a pending PNC void transaction. Retry in a few minutes!');
            return JSON.serialize(response);
        }
        
        if (!i.sent_to_pnc__c){
            response.put('Message','This invoice was never sent to PNC! Contact system administrator!');
            return JSON.serialize(response);
        }

        /* limit to 120 days to void */

        lineList = new List<Int_PX_Billing__c>();
        Boolean invoiceFound = false;

        lineList = [Select line_data__c
                                        from Int_PX_Billing__c 
                                        where createdDate = last_n_days: 120
                                        and committed__c = true
                                    ];

       
        String origLine = '';
        for (Int_PX_Billing__c l: lineList){
            if(l.line_data__c.contains(i.name)){
                invoiceFound = true;
                origLine = l.line_data__c;
                break;
            }              
        }
        
        if (!invoiceFound){
            response.put('Message','This invoice could not be found in the pnc transaction list for the last 120 days.  Void not allowed!');
            return JSON.serialize(response);
        }
             
        PNCUtility.voidInvoice(recordId,true);
        
        return JSON.serialize(response);

    }
    
     public class resultLine{

        @AuraEnabled public String chargeId;
        @AuraEnabled public String fee;
        @AuraEnabled public String feeAmount;
        @AuraEnabled public String	taxAmount;
      
     }

      public class resultLine2{

        @AuraEnabled public String type;
        @AuraEnabled public String debit;
        @AuraEnabled public String credit;
        @AuraEnabled public String taxAmount;
      
     }
    /********************************************************************************************
   	*get charges and bills
   	* 
   	********************************************************************************************/
    @AuraEnabled
    public static List<resultLine> getCharges(String invoiceId, Integer intOffset){
        
        List<resultLine> results = new List<resultLine>();

        List<cllease__charge__c> cList = new List<cllease__Charge__c>();
        cList = [select Id
                ,name
                ,cllease__Original_Amount__c
                ,cllease__Tax_Due__c
                ,cllease__Fee_Definition__r.name
                from cllease__Charge__c
                where invoiced_In__c = :invoiceId
                
                ];
        
        for (cllease__charge__c c:cList){
            resultLine  r = new resultLine();
            r.chargeId = c.name;
            r.fee = c.cllease__Fee_Definition__r.name;
            r.feeAmount =  string.valueOf(c.cllease__Original_Amount__c);
            r.taxAmount = string.valueOf(c.cllease__Tax_Due__c);
            system.debug('REsult is ' + r);
            results.add(r);
        }

        List<cllease__Lease_account_Due_Details__c> bList = new List<cllease__Lease_account_Due_Details__c>();
        bList = [select Id
                ,name
                ,cllease__Due_Type_Description__c
                ,cllease__Tax_Due_Amount__c
                ,cllease__Rental_Due_Amount__c
                from cllease__Lease_account_Due_Details__c
                where invoiced_In__c = :invoiceId
                
                ];

         for (cllease__Lease_account_Due_Details__c b:bList){
            resultLine  r = new resultLine();
            r.chargeId = b.name;
            r.fee = b.cllease__Due_Type_Description__c;
            r.feeAmount =  string.valueOf(b.cllease__Rental_Due_Amount__c);
            r.taxAmount = string.valueOf(b.cllease__Tax_Due_Amount__c);
            system.debug('REsult is ' + r);
            results.add(r);
        }
        return results;


    }

    /********************************************************************************************
   	* Get Adjustments
   	* 
   	********************************************************************************************/
    @AuraEnabled
    public static List<adjustment__c> getAdjustments(String invoiceId, Integer intOffset){
        
        List<resultLine2> results = new List<resultLine2>();
        
        List<adjustment__c> aList = new List<adjustment__c>();
        aList = [select Id
                ,adjustment_category__c
                ,credit__c
                ,debit__c
                ,tax_amount__c
                from adjustment__c
                where invoice__c = :invoiceId
          ];
        
        
        return aList;

    }    
    /********************************************************************************************
   	* Delete Adjustment
   	* 
   	********************************************************************************************/
    @AuraEnabled
	public static String deleteAdj(Adjustment__c toDelete){
        
        Map<String,String> response = new Map<String,String>(); 
        system.debug('to delete is: ' + toDelete);
        
        delete toDelete;

        return JSON.serialize(response);

    }     
        

}