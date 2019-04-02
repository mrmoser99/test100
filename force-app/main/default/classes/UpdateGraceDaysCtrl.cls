/**
 * Owner: Cloud Lending Solutions
 * Usage: Following Controller helps in Overiding the values for "Finance charge grace days" & "Late charge grace days"
 *      
 **/
public with sharing class UpdateGraceDaysCtrl {
    // Contract object for details
    public cllease__Lease_Account__c contract {get;set;}
    
    public UpdateGraceDaysCtrl(ApexPages.StandardController controller) {
        Id ContractId = ((cllease__Lease_Account__c)controller.getRecord()).Id;
        contract = [SELECT Id, Name, Custom_Late_Charge_Grace_Days__c, Custom_Finance_Charge_Grace_Days__c
                    FROM cllease__Lease_Account__c
                    WHERE Id =:ContractId];
    }
    
    // Cancel Action to redirect to Contract Page
    public pageReference cancelAction() {
       return returnToOrigination(); 
    }
    
    // Save details , its a call from VF page (SetGraceDays.vf)
    public pageReference saveItem() { 
    
       //Do something to the Contract object and then update it //
       Savepoint sp = Database.setSavepoint();
       try{  
            
            System.debug('*****contract*******'+contract); 
            // do validation
            validate();
            // do dml operations
            update contract;
           
       } catch(Exception ex){
            Database.rollback(sp);
            ApexPages.addMessages(ex);
            return null;
       }
       return returnToOrigination();
    }
    
    public void validate() {
        if(Integer.ValueOF(contract.Custom_Finance_Charge_Grace_Days__c) < 0) {
             throw new CLSCustomException('Please enter valid value for Finance Charge Grace Days...');
        }
        
        if(Integer.ValueOF(contract.Custom_Late_Charge_Grace_Days__c) < 0) {
             throw new CLSCustomException('Please enter valid value for Late Charge Grace Days...');
        }
    }
    
    private pageReference returnToOrigination() {
         // Following gives the custom domain name if any.
         string orgUrl = URL.getSalesforceBaseUrl().toExternalForm();
         PageReference ref = new PageReference(orgUrl +'/apex/tabbedLeaseAccount?id=' + contract.Id);
         ref.setRedirect(true); 
         return ref; 
    }                                                                    
 }