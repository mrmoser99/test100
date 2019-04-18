/**
 * Author: Cloud Lending Solutions
 * Usage: Following Test class helps in testing the Financial Report Batch
 *      
 **/
 @isTest
 public with sharing class TestFinancialReportBatch {

 	// Creating Contract
	/*public static cllease__Lease_Account__c createContract() {
		cllease.TestHelper.createSeedDataForTesting();
        // Setting Current System Date in Test Context
        // 1. Pre-Setup
        clcommon__Fee_Definition__c  dummyFee   = cllease.Testhelper.createLeaseFee();
        clcommon__Fee_Set__c  dummyFeeSet       = cllease.Testhelper.createLeaseFeeSet();
        insert new clcommon__Fee_Junction__c( clcommon__Fee__c = dummyFee.ID, clcommon__Fee_Set__c  = dummyFeeSet.ID);

        cllease__Office_Name__c dummyOffice     	= cllease.TestHelper.createOffice('Test Office', true);

        Date currentDate = cllease.SystemDateUtil.getCurrentSystemDate();
        
        dummyOffice.cllease__Current_System_Date__c = currentDate;
        dummyOffice.cllease__Prior_Period_Income_Reversal_Days__c = 90;
        update dummyOffice;


        Account dummyAccount = new Account(Name = 'Sample Account');
        insert dummyAccount;

        // 2. Creating Sample Product with rental and Dep Streams enabled
        cllease__Lease_Product__c dummyLP    = cllease.TestHelper.createLeaseProduct(dummyOffice, dummyFeeSet);
        dummyLP.cllease__Product_Sub_Type__c = cllease.LendingConstants.PRODUCT_SUB_TYPE_FN_LEASE;
        dummyLP.cllease__Use_Open_Acct_Period__c = true;
        update dummyLP;

        // 3.Creating Contract
        cllease__Lease_Account__c leaseAccount      = new cllease__Lease_Account__c();
        leaseaccount.cllease__Account__c            = dummyAccount.ID;
        leaseAccount.cllease__Lease_Product_Name__c = dummyLP.ID;
        leaseAccount.cllease__Contract_Date__c      = currentDate;
        leaseaccount.cllease__Financed_Amount__c    = 10000;
        //leaseaccount.cllease__Residual_Amount__c    = 1000;
        leaseAccount.cllease__Term__c               = 12;
        leaseAccount.Termination_Reason__c 			= 'CHARGE-OFF';

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
        System.debug(LoggingLevel.ERROR, ' contract details: '+builder.getContract());
        // Validating Contract Activation
        System.assert(response.containsIgnoreCase('Contract Creation Successful'));

        return builder.getContract();
	}

 	@isTest
	public static void testFinancialReportBatch() {
		// Creating the contract
		cllease__Lease_Account__c contract = createContract();

		System.debug(LoggingLevel.ERROR, 'status: '+contract.cllease__Lease_Status__c);
		// Create Financial Report Mapping
		createFinancialReportMapping();
		// Run the Batch jobs to check the validation
		// Creating and runnning the Batch jobs for General Entries Creation.
        System.Test.startTest();
            List<String> contractNames 	= new List<String>{contract.Name};
            FinancialReportBatch job 	= new FinancialReportBatch(contractNames);
        	job.getRuntimeQuery();
            Database.executeBatch(job);
        System.Test.stopTest();

	}

	@isTest
	public static void testDeleteFinancialReportBatch() {
		cllease__Lease_Account__c contract = createContract();

		CL_Lease_Financial_Report__c report = new CL_Lease_Financial_Report__c();
		report.Name = contract.Name;
		insert report;

		System.Test.startTest();
			List<String> reportNames 	= new List<String>{report.Name};
        	DeleteFinancialReportBatch job 	= new DeleteFinancialReportBatch(reportNames);
        	job.getRuntimeQuery();
        	Database.executeBatch(job);
        System.Test.stopTest();

	}

	@isTest 
	public static void testDefaultReportBatches() {
		// Creating the contract
		cllease__Lease_Account__c contract = createContract();
		// Creating Report
		CL_Lease_Financial_Report__c report = new CL_Lease_Financial_Report__c();
		report.Name = contract.Name;
		insert report;
		// Create Financial Report Mapping
		createFinancialReportMapping();
		// Run the Batch jobs to check the validation
		// Creating and runnning the Batch jobs for General Entries Creation.
        System.Test.startTest();
            // Creating DAG
            String dagName = 'CLLease-BatchTestDAG';
            List<String> listOfJobs = new List<String>{ 'DeleteFinancialReportBatch',  'FinancialReportBatch'};
            TestGLIntegration.createDAGSpecificJobs(listOfJobs, dagName);
            // Running DAG
            TestGLIntegration.runDAG(dagName);
        System.Test.stopTest();
	}


	private static void createFinancialReportMapping() {
		List<Lease_Financial_Report_Mapping__c> mapping = new List<Lease_Financial_Report_Mapping__c>();

		mapping.add(new Lease_Financial_Report_Mapping__c(
				Child_Parent_Contract_API__c 	= '' ,
				Child_Relation__c 				= '' ,
				Count_All_Child_Records__c 		= false ,
				Current_Period__c 				= '' ,
				Current_Year__c 				= '' ,
				Is_Ending_Balance__c 			= false ,
				Source_Child_Relation__c 		= false ,
				Source_Field_Name__c 			= 'cllease__Days_Past_Due__c' ,
				Source_Object_Name__c 			= 'cllease__Lease_Account__c' ,
				Sum_All_Child_Records__c 		= false ,
				Target_Field_Name__c 			= 'Number_of_Days_Delinquent__c' ,
				Target_Object_Name__c 			= 'CL_Lease_Financial_Report__c' ,
				Where_Condition__c 				= '' 
			));

		mapping.add(new Lease_Financial_Report_Mapping__c(
				Child_Parent_Contract_API__c 	= '' ,
				Child_Relation__c 				= '' ,
				Count_All_Child_Records__c 		= false ,
				Current_Period__c 				= '' ,
				Current_Year__c 				= '' ,
				Is_Ending_Balance__c 			= false ,
				Source_Child_Relation__c 		= false,
				Source_Field_Name__c 			= 'Unbilled_Rent_Amount__c' ,
				Source_Object_Name__c 			= 'cllease__Lease_Account__c' ,
				Sum_All_Child_Records__c 		= false ,
				Target_Field_Name__c 			= 'Unbilled_Receivable_Rent__c' ,
				Target_Object_Name__c 			= 'CL_Lease_Financial_Report__c' ,
				Where_Condition__c 				= 'cllease__Lease_Status__c IN (\'ACTIVE - BAD STANDING\', \'ACTIVE - GOOD STANDING\')' 
			));

		mapping.add(new Lease_Financial_Report_Mapping__c(
				Child_Parent_Contract_API__c 	= 'cllease__Lease_Account__c' ,
				Child_Relation__c 				= '' ,
				Count_All_Child_Records__c 		= false ,
				Current_Period__c 				= '' ,
				Current_Year__c 				= '' ,
				Is_Ending_Balance__c 			= false ,
				Source_Child_Relation__c 		= true ,
				Source_Field_Name__c 			= 'Rent_Balance__c' ,
				Source_Object_Name__c 			= 'cllease__Lease_account_Due_Details__c' ,
				Sum_All_Child_Records__c 		= true ,
				Target_Field_Name__c 			= 'Billed_Unpaid_Receivable__c' ,
				Target_Object_Name__c 			= 'CL_Lease_Financial_Report__c' ,
				Where_Condition__c 				= 'cllease__Due_Type_Description__c != \'CONTRACT SALE\'' 
			));

		mapping.add(new Lease_Financial_Report_Mapping__c(
				Child_Parent_Contract_API__c 	= 'cllease__Contract__c' ,
				Child_Relation__c 				= 'cllease__Rental_Stream__c' ,
				Count_All_Child_Records__c 		= false,
				Current_Period__c 				= '' ,
				Current_Year__c 				= '' ,
				Is_Ending_Balance__c 			= false ,
				Source_Child_Relation__c 		= true ,
				Source_Field_Name__c 			= 'cllease__Lease_Income__c' ,
				Source_Object_Name__c 			= 'cllease__Rental_Stream__c' ,
				Sum_All_Child_Records__c 		= true ,
				Target_Field_Name__c 			= 'Original_Unearned_Lease_Income__c' ,
				Target_Object_Name__c 			= 'CL_Lease_Financial_Report__c' ,
				Where_Condition__c 				= '' 
			));

		 mapping.add(new Lease_Financial_Report_Mapping__c(
				Child_Parent_Contract_API__c 	= 'cllease__Contract__c' ,
				Child_Relation__c 				= 'cllease__Rental_Stream__c' ,
				Count_All_Child_Records__c 		= false ,
				Current_Period__c 				= '' ,
				Current_Year__c 				= '' ,
				Is_Ending_Balance__c 			= true ,
				Source_Child_Relation__c 		= true ,
				Source_Field_Name__c 			= 'cllease__Lease_Income__c' ,
				Source_Object_Name__c 			= 'cllease__Rental_Stream__c' ,
				Sum_All_Child_Records__c 		= true ,
				Target_Field_Name__c 			= 'Ending_Unearned_Lease_Income__c' ,
				Target_Object_Name__c 			= 'CL_Lease_Financial_Report__c' ,
				Where_Condition__c 				= 'DATEFILTER' 
			));

		 mapping.add(new Lease_Financial_Report_Mapping__c(
				Child_Parent_Contract_API__c 	= 'cllease__Contract__c' ,
				Child_Relation__c 				= 'cllease__Rental_Stream__c' ,
				Count_All_Child_Records__c 		= false ,
				Current_Period__c 				= 'cllease__Date__c' ,
				Current_Year__c 				= '' ,
				Is_Ending_Balance__c 			= false ,
				Source_Child_Relation__c 		= true ,
				Source_Field_Name__c 			= 'cllease__Lease_Income__c' ,
				Source_Object_Name__c 			= 'cllease__Rental_Stream__c' ,
				Sum_All_Child_Records__c 		= true ,
				Target_Field_Name__c 			= 'Earned_Lease_Income_MTD__c' ,
				Target_Object_Name__c 			= 'CL_Lease_Financial_Report__c' ,
				Where_Condition__c 				= 'DATEFILTER' 
			));

		 mapping.add(new Lease_Financial_Report_Mapping__c(
				Child_Parent_Contract_API__c 	= 'cllease__Contract__c' ,
				Child_Relation__c 				= 'cllease__Rental_Stream__c' ,
				Count_All_Child_Records__c 		= false ,
				Current_Period__c 				= '' ,
				Current_Year__c 				= 'cllease__Date__c' ,
				Is_Ending_Balance__c 			= false ,
				Source_Child_Relation__c 		= true ,
				Source_Field_Name__c 			= 'cllease__Lease_Income__c' ,
				Source_Object_Name__c 			= 'cllease__Rental_Stream__c' ,
				Sum_All_Child_Records__c 		= true ,
				Target_Field_Name__c 			= 'Earned_Lease_Income_YTD__c' ,
				Target_Object_Name__c 			= 'CL_Lease_Financial_Report__c' ,
				Where_Condition__c 				= 'DATEFILTER' 
			));

		 mapping.add(new Lease_Financial_Report_Mapping__c(
				Child_Parent_Contract_API__c 	= 'cllease__Lease_Account__c' ,
				Child_Relation__c 				= '' ,
				Count_All_Child_Records__c 		= false ,
				Current_Period__c 				= '' ,
				Current_Year__c 				= '' ,
				Is_Ending_Balance__c 			= false ,
				Source_Child_Relation__c 		= true ,
				Source_Field_Name__c 			= 'cllease__Txn_Date__c' ,
				Source_Object_Name__c 			= 'cllease__Other_Transaction__c' ,
				Sum_All_Child_Records__c 		= false ,
				Target_Field_Name__c 			= 'Activation_Date__c' ,
				Target_Object_Name__c 			= 'CL_Lease_Financial_Report__c' ,
				Where_Condition__c 				= 'cllease__Transaction_Type__c = \'BOOKING\'' 
			));

		 // inserting mapping 
		 insert mapping;

	}
	*/
}