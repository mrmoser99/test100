/********************************************************************************************
*
*  Change Log:
*
*	3/25/19 - Created Class
*
*********************************************************************************************/
public with sharing class APManualPayment { 
    
   
    
    public APManualPayment(ApexPages.StandardController stdController){

    	  
    }

    public PageReference init(){
        
        return new PageReference('/c/AP_ManualPayment.app');   
    }
}