/**
 * Author: Cloud Lending Solutions
 * Description: Following class is test class for DealerFundingDetailController  
 **/
@isTest
public class TestDealerFundingDetailController {
    
    static TestMethod void  DealerFundingDetailController() {
        // Creating Contract
        cllease__Lease_Account__c contract = TestHelper.createContract();
        System.debug(LoggingLevel.ERROR, 'Contract Created'+contract.Id);

        // Retrieving Contract Equipment Where it needs Dealer Funding Details
        cllease__Contract_Equipment__c contractEquipment = [Select Id From cllease__Contract_Equipment__c Limit 1];
        contractEquipment.cllease__Total_Dealer_Charges__c  = 10000;
        update contractEquipment;

        cllease__Dealer_Funding_Detail__c dealerFundingDetail = new cllease__Dealer_Funding_Detail__c();
        dealerFundingDetail.cllease__Contract_Equipment__c    = contractEquipment.Id;

        ApexPages.StandardController controller = new ApexPages.StandardController(dealerFundingDetail);
        DealerFundingDetailController dealerFundDetailCtrl = new DealerFundingDetailController(controller);
        dealerFundDetailCtrl.save();

        cllease__Other_Transaction__c dFTxn  = new cllease__Other_Transaction__c();
        dFTxn.cllease__Txn_Date__c           = Date.newInstance(2018, 01, 01);
        dFTxn.cllease__Transaction_Type__c   = cllease.LendingConstants.TXN_DEALER_FUNDING_CONTRACT;
        dFTxn.cllease__GL_Transaction_Flag__c= true;
        dFTxn.cllease__Lease_Account__c      = contract.Id;
        dFTxn.cllease__Accrue_Subvention__c  = 0;
        dFTxn.cllease__Txn_Amt__c            = 10000;
        dFTxn.cllease__Dealer_Payable_Amount__c  = 10000;
        insert dFTxn;

        cllease__Dealer_Funding_Detail__c temp = [Select Id, cllease__Dealer_Funding_Transaction__c
                                                     From cllease__Dealer_Funding_Detail__c Limit 1];
        temp.cllease__Dealer_Funding_Transaction__c = dFTxn.Id;
        update temp;
        
        cllease__Dealer_Funding_Detail__c updatedDealerFundDetail = [Select Id, cllease__Dealer_Charges__c, 
                                                                        cllease__Dealer_Funding_Transaction__c
                                                                      From cllease__Dealer_Funding_Detail__c
                                                                      Limit 1];

        // Validating Dealer Funding Detail Record for Fund Amount        
        System.debug(LoggingLevel.ERROR, ' updatedDealerFundDetail: '+updatedDealerFundDetail);                                                                      
        System.assertEquals(10000, updatedDealerFundDetail.cllease__Dealer_Charges__c, 'Mismatch in Dealer Fund Amount.');
        
        /*System.assert(updatedDealerFundDetail.cllease__Dealer_Funding_Transaction__c != null, 'Mismatch in Dealer Funding Transaction Creation.');                                                                      
        
        System.debug(LoggingLevel.ERROR, ' updatedDealerFundDetail: '+updatedDealerFundDetail);*/
        // Validating Dealer Funding Transaction Creation
        /*cllease__Other_Transaction__c dealerFundTxn = [Select Id, Name, cllease__Dealer_Payable_Amount__c
                                                        From cllease__Other_Transaction__c
                                                        Where Id =: updatedDealerFundDetail.cllease__Dealer_Funding_Transaction__c];
        System.debug(LoggingLevel.ERROR, ' dealer funding transation: '+dealerFundTxn);
        *///System.assertEquals(10000, dealerFundTxn.cllease__Dealer_Payable_Amount__c, 'Mismatch in Dealer Fund Amount in Txn.');

    }
}