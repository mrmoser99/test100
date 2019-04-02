/**
 * Author: Cloud Lending Solutions
 * Description: Following class helps in testing the functionality : Residual Burndown
 **/
@isTest
public with sharing class TestResidualBurndown {

	public static testMethod void testResidualBurnDown() {
        // A. Creating Contract Using TestHelper
        cllease__Lease_Account__c contract = TestHelper.createContract();
        String contractStatus = 'ACTIVE - GOOD STANDING';
        System.assert(contractStatus.containsIgnoreCase(contract.cllease__Lease_Status__c));

        // B. Adding accounting configuration to Product and Creating other setup
        cllease__Lease_Product__c product = [SELECT Id, Name From cllease__Lease_Product__c Limit 1];
        cllease__Office_Name__c company = [SELECT Id, Name From cllease__Office_Name__c Where Name = 'Test Office'];

        TestData.doPreSetup();
        TestData.createAccountingTemplateSetup(product.Id, company.Id);

        // Changing the current System Date
        Date currentSystemDate = Date.newInstance(2019, 01, 01);
        List<cllease__Office_Name__c> companies = [Select Id, Name, cllease__Current_System_Date__c
                                                    From cllease__Office_Name__c];
        for(cllease__Office_Name__c company1 : companies) {
            company1.cllease__Current_System_Date__c = currentSystemDate;
        }
        update companies;

        // Updating the Contract status to EVERGREEN
        contract.cllease__Lease_Status__c = 'EVERGREEN';
        update contract;

                                        
        // Creating and runnning the Batch jobs for General Entries Creation.
        System.Test.startTest();
            // Creating DAG
            String dagName = 'CLLease-BatchTestDAG';
            List<String> listOfJobs = new List<String>{ 'ResidualBurndown'};
            TestHelper.createDAGSpecificJobs(listOfJobs, dagName);
            // Running DAG
            TestHelper.runDAG(dagName);
        System.Test.stopTest();

        System.debug(LoggingLevel.ERROR, ' Transactions: '+ [Select Id, Name, Residual_Burndown_Amount__c, Remaining_Evergreen_Depreciable_Cost__c
        														From cllease__Other_Transaction__c 
        														Where cllease__Transaction_Type__c = 'EVERGREEN DEPRECIATION']);

        System.debug(LoggingLevel.ERROR, ' Equipment Detials: '+[Select Id, Name, Remaining_Evergreen_Depreciable_Cost__c, Last_Residual_Burndown_Date__c
        															From cllease__Contract_Equipment__c
        															where cllease__Contract__c =: contract.Id]);

        // TODO: Asset the Transaction and Equipment Amounts


    }


    public static testMethod void testResidualBurnDownPerContract() {
        // A. Creating Contract Using TestHelper
        cllease__Lease_Account__c contract = TestHelper.createContract();
        String contractStatus = 'ACTIVE - GOOD STANDING';
        System.assert(contractStatus.containsIgnoreCase(contract.cllease__Lease_Status__c));

        // B. Adding accounting configuration to Product and Creating other setup
        cllease__Lease_Product__c product = [SELECT Id, Name From cllease__Lease_Product__c Limit 1];
        cllease__Office_Name__c company = [SELECT Id, Name From cllease__Office_Name__c Where Name = 'Test Office'];

        TestData.doPreSetup();
        TestData.createAccountingTemplateSetup(product.Id, company.Id);

        // Changing the current System Date
        Date currentSystemDate = Date.newInstance(2019, 01, 01);
        List<cllease__Office_Name__c> companies = [Select Id, Name, cllease__Current_System_Date__c
                                                    From cllease__Office_Name__c];
        for(cllease__Office_Name__c company1 : companies) {
            company1.cllease__Current_System_Date__c = currentSystemDate;
        }
        update companies;

        // Updating the Contract status to EVERGREEN
        contract.cllease__Lease_Status__c = 'EVERGREEN';
        update contract;

                                        
        // Creating and runnning the Batch jobs for General Entries Creation.
        System.Test.startTest();
            // Creating DAG
            List<String> contractNames = new List<String>{contract.Name};
            ResidualBurndown job = new ResidualBurndown(contractNames);
            Database.executeBatch(job);
        System.Test.stopTest();


    }
}