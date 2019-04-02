trigger Int_Px_NSF on Int_PX_NSF__c (before insert, after insert) {
    public class CommonException extends Exception {}
	

	List<Int_Batch_Status__c> bList = [	select id
										from Int_Batch_Status__c
										where name = 'Px NSF' and status__c = 'Ready' and Completed__c = false];
	if (bList.size() > 0)
		throw new CommonException('Cannot load more than 1 nsf file at a time!');
						
	if (trigger.isBefore){
		
		for (Int_PX_NSF__c r:trigger.new){
			List<String> columnList = new List<String>();
			String line = r.line_data__c;
			columnList = line.split('\\|');
			if (columnList[0].isNumeric()){
				/*RECORD NUMBER|0
                ACCOUNT NUM   |1
                TRAN UID|2
                DATE|3
                TIME|4
                TRANS SOURCE|5
                TRANSACTION AMOUNT|6
                INVOICE NUMBER|7
                INVOICE AMOUNT DUE|8
                INVOICE AMOUNT PAID|9
                NFS CHARGE 10                                 
                */
				r.record_number__c = decimal.valueOf(columnList[0]); 
				r.account_num__c = columnList[1];
				r.trans_uid__c = columnList[2]; 
				Integer year, month, day;
				year = integer.valueOf(columnList[3].mid(0,4));
				month = integer.valueOf(columnList[3].mid(4,2));
				day = integer.valueOf(columnList[3].mid(6,2));
				r.date__c = Date.newInstance(year,month,day);
				 
				r.trans_source__c = columnList[5];
				r.transaction_amount__c = decimal.valueOf(columnList[6])/100;
				r.invoice_number__c = columnList[7];
				r.invoice_amount_paid__c = decimal.valueOf(columnList[9])/100;
                r.nsf_amount__c =  decimal.valueOf(columnList[10])/100;
				r.line_data__c = null;
			}
			else{
				system.debug('in here');
				system.debug(columnlist);
				if (columnList[0] == 'V1.0'){
					system.debug('header');
					r.record_number__c = 0; 
					r.invoice_number__c = 'BATCH HEADER';
					r.payment_batch_date__c = NewCoUtility.convertDateYYYYMMDD(columnList[4]);
					//r.payment_batch_total_amount__c = decimal.valueOf(columnList[5])/100;
				}
			}
		}
	}
	else{
		system.debug('here 2');
		List<Int_Px_NSF__c> dList = new List<Int_PX_NSF__c>();
		
		for (Int_PX_NSF__c r:trigger.new){
			Int_PX_NSF__c d = new Int_PX_NSF__c();
			d.id = r.id;
			if (r.record_number__c == null || r.record_number__c == 0)
					dList.add(d);
		}
		if (!dList.isEmpty())
			delete dList;
			
	}    
}