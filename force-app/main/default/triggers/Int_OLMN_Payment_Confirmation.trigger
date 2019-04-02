/*********************************************************************************************
*
* Int_OLMN_Payment_Confirmation
*
* Change Log:
*
* 2/15/18 - MRM Created
*
**********************************************************************************************/
trigger Int_OLMN_Payment_Confirmation on Int_OLMN_Payment_Confirmation__c (before insert) {
	
	for (Int_OLMN_Payment_Confirmation__c r:trigger.new){
				/*
				0Contract number
				1Vendor
				2Payment reference
				3Payment date
				4Void date
				5Payment amount
				6Payment method
				7Status
				8Invoice number
				9Invoice date
				10Invoice amount
				11Last update date
				12Run date

				*/
				Integer year, month, day;
				
				if (r.text_payment_date__c != null){
				
					year = integer.valueOf(r.text_payment_date__c.mid(0,4));
					month = integer.valueOf(r.text_payment_date__c.mid(4,2));
					day = integer.valueOf(r.text_payment_date__c.mid(6,2));
					r.payment_date__c = Date.newInstance(year,month,day);
				}
				
				if (r.text_void_date__c != null){
					year = integer.valueOf(r.text_void_date__c.mid(0,4));
					month = integer.valueOf(r.text_void_date__c.mid(4,2));
					day = integer.valueOf(r.text_void_date__c.mid(6,2));
					r.void_date__c = Date.newInstance(year,month,day);
				}
				
				if (r.text_invoice_date__c != null){
					year = integer.valueOf(r.text_invoice_date__c.mid(0,4));
					month = integer.valueOf(r.text_invoice_date__c.mid(4,2));
					day = integer.valueOf(r.text_invoice_date__c.mid(6,2));
					r.invoice_date__c = Date.newInstance(year,month,day);
				}
				
			
		}
    
}