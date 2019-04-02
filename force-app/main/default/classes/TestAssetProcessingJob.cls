@isTest
public class TestAssetProcessingJob {
    public static testMethod void assetJob(){
        
        cllease__Lease_Account__c leaseContract= TestHelper.createContract();

        TestData.createTxnSubTypes();
        Date processingDate = Date.newInstance(2018, 02, 15); // Charge Due Date         
        cllease__Contract_Equipment__c contractEquipment= [ Select Id, cllease__Status__c
                          										From cllease__Contract_Equipment__c
                          										Where cllease__Contract__c = :leaseContract.Id];
        /*contractEquipment.cllease__Status__c = 'LEASED';
        update contractEquipment;*/
       
   
        List<cllease__Asset_workbench__c> assetWBList = new List<cllease__Asset_workbench__c>();
        assetWBList.add(new cllease__Asset_workbench__c(
                                cllease__Contract__c        = leaseContract.Id,
                                cllease__Return_Status__c   = 'Returned',
                                Date_Sold__c                = processingDate,
                                Sale_Price__c               = 10,
                                Sold_to__c                  = leaseContract.cllease__Account__c,
                                cllease__Contract_Equipment__c = contractEquipment.Id,
                                process_asset_sale__c       = true));

        assetWBList.add(new cllease__Asset_workbench__c(
                                cllease__Contract__c        = leaseContract.Id,
                                cllease__Return_Status__c   = 'Scheduled',
                                Date_Sold__c                = processingDate,
                                Sale_Price__c               = 20,
                                Sold_to__c                  = leaseContract.cllease__Account__c,
                                cllease__Contract_Equipment__c = contractEquipment.Id,
                                process_asset_sale__c       = true));
       
        insert assetWBList;
        
        clcommon__Fee_Definition__c  assetFeeDef   = cllease.Testhelper.createLeaseFee();
        assetFeeDef.Name = DLLNewCoConstants.FEE_ASSETSALE;
        update assetFeeDef;

        System.Test.startTest();
            AssetProcessingJob obj= new AssetProcessingJob();
            DataBase.executeBatch(obj);
        System.Test.stopTest();
        
    }

    static testMethod void testOther() {
        cllease__Lease_Account__c leaseContract= TestHelper.createContract();
        delete [ Select Id From cllease__Rental_Stream__c Limit 1];
    }  

    static testMethod void testOther2() {
        cllease__Lease_Account__c contract = TestHelper.createContract();
        Account acc = [Select Id From Account Limit 1];
        cllease__Insurance_Policy__c insurance = new cllease__Insurance_Policy__c();
        insurance.cllease__Contract__c = contract.Id;
        insurance.cllease__Effective_To__c = Date.newInstance(2018, 03, 15);
        insurance.cllease__Effective_From__c = Date.newInstance(2018, 01, 01);
        insurance.cllease__Insurance_Company__c = acc.Id;
        insurance.cllease__Policy_Number__c = '1234567';
        insert insurance;
    } 

    /*static testMethod void testOperatingLease() {
        cllease.TestHelper.createSeedDataForTesting();
        // Setting Current System Date in Test Context
        Date currentSystemDate = Date.newInstance(2018, 03, 31);
        // 1. Pre-Setup
        clcommon__Fee_Definition__c  dummyFee   = cllease.Testhelper.createLeaseFee();
        clcommon__Fee_Set__c  dummyFeeSet       = cllease.Testhelper.createLeaseFeeSet();
        insert new clcommon__Fee_Junction__c( clcommon__Fee__c = dummyFee.ID, clcommon__Fee_Set__c  = dummyFeeSet.ID);

        cllease__Office_Name__c dummyOffice     = cllease.TestHelper.createOffice('Test Office', true);
        dummyOffice.cllease__Current_System_Date__c = currentSystemDate;
        dummyOffice.Dll_Seg1_Company__c         = '00101';
        dummyOffice.Dll_Seg2_Business_Unit__c   = '02';
        dummyOffice.Dll_Seg3_Department__c      = '3030';
        dummyOffice.Dll_Seg6__c                 = '00000';
        dummyOffice.Dll_Seg7__c                 = '0000';
        update dummyOffice;

        TestData.createPeriodsFor2018(dummyOffice.cllease__Calendar__c);

        Account dummyAccount = new Account(Name = 'Sample Account');
        insert dummyAccount;

        // 2. Creating Sample Product with rental and Dep Streams enabled
        cllease__Lease_Product__c dummyLP    = cllease.TestHelper.createLeaseProduct(dummyOffice, dummyFeeSet);
        dummyLP.cllease__Product_Sub_Type__c = cllease.LendingConstants.PRODUCT_SUB_TYPE_OP_LEASE;
        dummyLP.cllease__Use_Open_Acct_Period__c = true;
        update dummyLP;

        clcommon__Agreement__c dealerProgram =new clcommon__Agreement__c(Name='NewCo');
        insert dealerProgram;

        // 3.Creating Contract
        Date currentDate = Date.newInstance(2018, 01, 01);
        cllease__Lease_Account__c leaseAccount      = new cllease__Lease_Account__c();
        leaseaccount.cllease__Account__c            = dummyAccount.ID;
        leaseAccount.cllease__Lease_Product_Name__c = dummyLP.ID;
        leaseAccount.cllease__Contract_Date__c      = currentDate;
        leaseaccount.cllease__Financed_Amount__c    = 10000;
        //leaseaccount.cllease__Residual_Amount__c    = 1000;
        leaseAccount.cllease__Term__c               = 12;
        leaseaccount.Dealer_Program__c              = dealerProgram.Id;

        // 3.a Adding Equipments to Contract
        List<cllease__Contract_Equipment__c> contractEquipments = new List<cllease__Contract_Equipment__c>();
        contractEquipments.add(new cllease__Contract_Equipment__c(cllease__Estimated_Selling_Price__c = 10000));
      
        // 3.b Adding Payment Schedules to Contract
        List<cllease__Payment_Schedule__c> paymentDetails =  new List<cllease__Payment_Schedule__c>();
        paymentDetails.add(new cllease__Payment_Schedule__c(cllease__Sequence__c = 1, cllease__Number_Of_Payments__c = 12,
                           cllease__Frequency__c = cllease.LendingConstants.PAYMENT_FREQ_MONTHLY,
                           cllease__Payment_Amount__c = 1200, cllease__Payment_Date__c = currentDate,
                           cllease__Total_Payment__c = 1200));

        // 4. Calling ContractBuilder for Contract Creation
        cllease.ContractBuilder builder = new cllease.ContractBuilder(leaseAccount);
        builder.addChildObjects(contractEquipments);
        builder.addChildObjects(paymentDetails);
        String response = builder.createContract(cllease.LendingConstants.ContractCreateOption.ACTIVATECONTRACT);
        System.debug(LoggingLevel.ERROR, ' Response from Contract Creation: '+response);
        // Validating Contract Activation
        System.assert(response.containsIgnoreCase('Contract Creation Successful'));

        cllease__Rental_Accrual_Stream1__c updateStream = [Select Id, Name, cllease__Rental_Accrual__c From cllease__Rental_Accrual_Stream1__c Limit 1];
        updateStream.cllease__Rental_Accrual__c = 100;
        update updateStream;
    }*/

}