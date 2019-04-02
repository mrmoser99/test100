trigger WaiveFeesCharges on cllease__Charge__c(before update) {
 
    List<cllease__Charge__c> cupdate = new List<cllease__Charge__c>();
    //Tax_Processed__c,cllease__Paid__c,cllease__GL_Transaction_Flag__c
    cllease__Charge__c cprocess = new cllease__Charge__c();
    for(cllease__Charge__c charge:Trigger.new)
    {
        if(Trigger.isBefore && Trigger.isUpdate && trigger.oldMap.get(charge.id).cllease__Waive__c != charge.cllease__Waive__c && charge.cllease__Waive__c)
		{
			if(charge.cllease__Tax_Processed__c=='Tax Calculated' && charge.cllease__GL_Transaction_Flag__c && !charge.cllease__Paid__c)
			{	
                string ChargeId = charge.id;
             	WaiveFeesChargesUtil.DistributedTaxCall(ChargeId);
                System.debug('***se-1'+chargeId);
			}
			else if(charge.cllease__Tax_Processed__c=='Tax Calculated' && !charge.cllease__GL_Transaction_Flag__c && !charge.cllease__Paid__c)
			{				
               string ChargeId = charge.id;
               WaiveFeesChargesUtil.DistributedTaxCall(ChargeId);
               System.debug('***se-2'+chargeId);
			}
			else if(charge.cllease__Tax_Processed__c=='Tax Calculated' && !charge.cllease__GL_Transaction_Flag__c && charge.cllease__Paid__c)
			{	
                string ChargeId = charge.id;
             	WaiveFeesChargesUtil.DistributedTaxCall(ChargeId);  
                System.debug('***se-3'+chargeId);
			}
	    }
    } 
}