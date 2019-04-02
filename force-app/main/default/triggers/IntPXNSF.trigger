/*********************************************************************************************
*
* Int_PX_NSF
*
* Change Log:
*
* 1/4/19 - MRM Created
*
**********************************************************************************************/
trigger IntPXNSF on Int_PX_NSF__c (before insert, after insert) {
    
     
    public class CommonException extends Exception {}
    
    List<Int_Batch_Status__c> bList = [ select id
                                        from Int_Batch_Status__c
                                        where name = 'Px NSF' and status__c = 'Ready' and Completed__c = false];
    //if (bList.size() > 0)
        //throw new CommonException('Cannot load more than 1 nsf file at a time!');
                    
    if (trigger.isBefore){
        for (Int_PX_NSF__c r:trigger.new){
            List<String> columnList = new List<String>();
            String line = r.line_data__c;
            columnList = line.split('\\|');
            if (columnList[0].isNumeric()){
                /*
                ﻿RECORD NUMBER
                ACCOUNT NUM
                TRANSACTION TYPE
                TRANS UID
                DATE|
                TRANS SOURCE (Future place holder)
                TRANSACTION AMOUNT
                INVOICE NUMBER
                INVOICE AMOUNT PAID
                NSF AMOUNT
                */
                r.record_number__c = decimal.valueOf(columnList[0]); 
                r.account_num__c = columnList[1];
                r.transaction_type__c = columnList[2];
                r.trans_uid__c = columnList[3]; 
                Integer year, month, day;
                year = integer.valueOf(columnList[4].mid(0,4));
                month = integer.valueOf(columnList[4].mid(4,2));
                day = integer.valueOf(columnList[4].mid(6,2));
                r.date__c = Date.newInstance(year,month,day);
                 
                r.trans_source__c = columnList[5];
                r.transaction_amount__c = decimal.valueOf(columnList[6])/100;
                r.invoice_number__c = columnList[7];
                r.invoice_amount_paid__c = decimal.valueOf(columnList[8])/100;
                r.nsf_amount__c = decimal.valueOf(columnList[9])/100;
                r.line_data__c = null;
            }
            
        }
    }
    else{
        
        List<Int_PX_NSF__c> dList = new List<Int_PX_NSF__c>();
        
        for (Int_PX_NSF__c r:trigger.new){
            Int_PX_NSF__c d = new Int_PX_NSF__c();
            d.id = r.id;
            if (r.record_number__c == null)
                dList.add(d);
        }
        if (!dList.isEmpty())
            delete dList;
            
    }    
}