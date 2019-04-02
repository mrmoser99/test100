/********************************************************************************************
*
*  Change Log:
*
*	02/28/19- MRM Created class for exposure viewing; cls is still classic so this is it
*
*********************************************************************************************/
public with sharing class EXExposureController{
    
    Lease_Exposure__c e;
    cllease__Lease_Account__c l;
    
    
    public EXExposurecontroller(ApexPages.StandardController stdController){
    	
    	this.l = (cllease__Lease_Account__c)stdController.getRecord();
    	     
    	l = [Select id from cllease__Lease_Account__c where id = :l.id];
  	} 

    /******************************************************************************************
    * Show Exposure
    *******************************************************************************************/
    public pageReference showExposure(){
        
        Set<String> leaseSet = new Set<String>();
        leaseSet.add(l.id);
        ExposureUtility.getExposure(leaseSet);

        e = [ SELECT Asset_Sale__c
                  ,Estimated_Property_Tax__c
                  ,Evergreen_Billed_Not_Paid__c
                  ,Evergreen_Billed__c
                  ,Exposure__c
                  ,Finance_Fees__c
                  ,Id,Insurance_Fees__c
                  ,Late_Fees__c
                  ,LS_Contract__c
                  ,Name
                  ,NSF_Fees__c
                  ,Origination_Fees__c
                  ,Rent_Accrual__c
                  ,Rent_Billed_Not_Paid__c
                  ,Rent_Billed__c
                  ,Rent__c
                  ,Residual_Amount__c
                  ,Service_Fees__c
                  ,Termination_Quote_Fees__c
                  ,Unearned_Income__c
                  ,Unearned_Residual__c 
                  FROM Lease_Exposure__c
                  where ls_contract__c = :l.id
            ];
        
        PageReference newPage = new PageReference('/' + e.id);
    	newPage.setRedirect(true);
		return newPage; 
    }
}