/**
 *  Author: Cloud Lending Solutions
 *  Description: Following Visualforce Page helps in Creating New Dealer Funding Details Record
 **/
public class DealerFundingDetailController {
    public cllease__Dealer_Funding_Detail__c dealerFundDetailsObj {get; set;}
    public Id contractEquipmentId {get; set;}
    public cllease__Contract_Equipment__c contractEquipment {get; set;}
    
    public DealerFundingDetailController(ApexPages.StandardController controller) {

        this.dealerFundDetailsObj = (cllease__Dealer_Funding_Detail__c)controller.getRecord();
        //System.debug(LoggingLevel.ERROR, '---Record: '+dealerFundDetailsObj);
        contractEquipmentId = dealerFundDetailsObj.cllease__Contract_Equipment__c;

        // retrieving Contract Equipment Details
        contractEquipment = [SELECT Id, Name, 
                                cllease__Contract__c,
                                Net_Trade_Up_Amount__c, 
                                Balance_Net_Trade_Up_Amount__c,
                                cllease__Dealer_Name__r.Name, 
                                cllease__Dealer_Name__c,
                                Dealer_Charges__c 
                            FROM cllease__Contract_Equipment__c 
                            WHERE Id = :contractEquipmentId];
        
        // Update the required details in Dealer Funding Details Objects                                
        dealerFundDetailsObj.cllease__Contract__c       = contractEquipment.cllease__Contract__c; 
        dealerFundDetailsObj.cllease__Dealer_Charges__c = contractEquipment.Dealer_Charges__c;     
    }

    public PageReference save(){
       try{
            insert dealerFundDetailsObj;
            PageReference pg = new PageReference('/'+dealerFundDetailsObj.id);
            return pg;
        } catch(Exception ex){  
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage());
            ApexPages.addMessage(msg);
        }
        return null;
    }

}