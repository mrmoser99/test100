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

}