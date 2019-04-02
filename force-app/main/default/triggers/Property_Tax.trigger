/*********************************************************************************************
*
* Property_Tax
*
* Change Log:
*
* 2/15/18 - MRM Created
*
**********************************************************************************************/
trigger Property_Tax on Property_Tax__c (before insert) {
	
	for (Property_Tax__c p:trigger.new){
		
		/*
			converting mm/dd/yyyy
		*/
		
		Integer year, month, day;
				
		p.ap_export_date__c = NewCoUtility.convertDate(p.ap_export_date_text__c);
		p.exported_to_ar_date__c = NewCoUtility.convertDate(p.exported_to_ar_date_text__c);
		p.installment_due_date__c = NewCoUtility.convertDate(p.installment_due_date_text__c);
		p.installment_mail_by_date__c = NewCoUtility.convertDate(p.installment_mail_by_date_text__c);
		p.lease_end_date__c = NewCoUtility.convertDate(p.lease_end_date_text__c);
		p.lease_start_date__c = NewCoUtility.convertDate(p.lease_start_date_text__c);
		p.processed_date__c = NewCoUtility.convertDate(p.processed_date_text__c);
	
		
	}
	
}