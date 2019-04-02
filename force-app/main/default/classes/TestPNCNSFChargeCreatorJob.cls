@isTest
public with sharing class TestPNCNSFChargeCreatorJob {
	@isTest
	public static void testPNCNSFCharges1() {

		Testhelper.getVertexCustomSettings();
		// A. Creating Contract Using TestHelper
        cllease__Lease_Account__c contract = TestHelper.createContract();
        String contractStatus = 'ACTIVE - GOOD STANDING';
        System.assert(contractStatus.containsIgnoreCase(contract.cllease__Lease_Status__c));

        // Creating charges for january , february periods
        Date chargeDate = Date.newInstance(2018, 01, 15);

        // Creating  Charge with Equipment Linked
        clcommon__Fee_Definition__c  dummyFee   = cllease.Testhelper.createLeaseFee();
        dummyFee.Name = 'NSF Fees';
        update dummyFee;

        // Creating Invoice
    	Invoice__c invoice 			= new invoice__c();
        invoice.LS_Contract__c      = contract.Id;
        invoice.Invoice_Due_Date__c = chargeDate; 
        insert invoice;

        cllease__Lease_Account_Due_Details__c bill = new cllease__Lease_Account_Due_Details__c();
    	bill.cllease__Due_Date__c 			= Date.parse('09/1/2016');
        bill.cllease__Lease_Account__c		= contract.Id;
		bill.cllease__Total_Due_Amount__c 	= 100.00;
		bill.cllease__Tax_Processed__c      = true;
		bill.Invoiced_In__c                 = invoice.Id;
    	insert bill;

    	// Creating PNC NSF Record
    	Invoice__c retrieveInvoice = [Select Id, Name From Invoice__c Limit 1];

    	Int_PX_NSF__c pxNSFRecord = new Int_PX_NSF__c();
    	pxNSFRecord.Committed__c 		= false;
    	pxNSFRecord.Date__c 			= chargeDate;
    	pxNSFRecord.Invoice_Number__c   = retrieveInvoice.Name;
    	pxNSFRecord.Line_Data__c        = 'xxx|xxx|xxx';
    	pxNSFRecord.NSF_Amount__c		= 45;
    	insert pxNSFRecord;

        // Creating and runnning the Batch jobs for Invoice Consolidation and PNC File Generation
        System.Test.startTest();
            // Creating DAG
            String dagName = 'Test DAG - Apply PNC NSF Charges';
            List<String> listOfJobs = new List<String>{'PNCNSFChargeCreatorJob'};
            TestHelper.createDAGSpecificJobs(listOfJobs, dagName);
            // Running DAG
            TestHelper.runDAG(dagName);
        System.Test.stopTest();

        List<cllease__Charge__c> chargesCreated = [Select Id, Name, cllease__Original_Amount__c, cllease__Fee_Definition__r.Name From cllease__Charge__c];

        System.assertEquals(1,  chargesCreated.size(), 'Mismatch in No Of NSF Charges created...');
        System.assertEquals(45, chargesCreated.get(0).cllease__Original_Amount__c, 'Mismatch in NSF Amount in Charge created...');
        System.assertEquals('NSF Fees', chargesCreated.get(0).cllease__Fee_Definition__r.Name, 'Mismatch in NSF Fee Definition Name in Charges created...');
        
        List<Int_PX_NSF__c> pxNSFRecordRetrieved = [Select Id, Name, Committed__c, Remark__c From Int_PX_NSF__c];
        System.assertEquals(1,  pxNSFRecordRetrieved.size(), 'Mismatch in No Of PNC NSF Records in System...');
        System.assertEquals(true, pxNSFRecordRetrieved.get(0).Committed__c, 'Mismatch in PNC NSF Commited Field Update...');
        System.assertEquals('NSF Charge Created Successfully', pxNSFRecordRetrieved.get(0).Remark__c, 'Mismatch in PNC NSF Remark Field Update...');
    
    }    

    @isTest
	public static void testPNCNSFCharges2() {

		Testhelper.getVertexCustomSettings();
		// A. Creating Contract Using TestHelper
        cllease__Lease_Account__c contract = TestHelper.createContract();
        String contractStatus = 'ACTIVE - GOOD STANDING';
        System.assert(contractStatus.containsIgnoreCase(contract.cllease__Lease_Status__c));

        // Creating charges for january , february periods
        Date chargeDate = Date.newInstance(2018, 01, 15);

        // Creating  Charge with Equipment Linked
        clcommon__Fee_Definition__c  dummyFee   = cllease.Testhelper.createLeaseFee();
        dummyFee.Name = 'NSF Fees';
        update dummyFee;

        // Creating Invoice
    	Invoice__c invoice 			= new invoice__c();
        invoice.LS_Contract__c      = contract.Id;
        invoice.Invoice_Due_Date__c = chargeDate; 
        insert invoice;

        cllease__Lease_Account_Due_Details__c bill = new cllease__Lease_Account_Due_Details__c();
    	bill.cllease__Due_Date__c 			= Date.parse('09/1/2016');
        bill.cllease__Lease_Account__c		= contract.Id;
		bill.cllease__Total_Due_Amount__c 	= 100.00;
		bill.cllease__Tax_Processed__c      = true;
		bill.Invoiced_In__c                 = invoice.Id;
    	insert bill;

    	// Creating PNC NSF Record
    	Invoice__c retrieveInvoice = [Select Id, Name From Invoice__c Limit 1];

    	Int_PX_NSF__c pxNSFRecord = new Int_PX_NSF__c();
    	pxNSFRecord.Committed__c 		= false;
    	pxNSFRecord.Date__c 			= chargeDate;
    	pxNSFRecord.Invoice_Number__c   = retrieveInvoice.Name;
    	pxNSFRecord.Line_Data__c        = 'xxx|xxx|xxx';
    	pxNSFRecord.NSF_Amount__c		= 45;
    	insert pxNSFRecord;

    	Int_PX_NSF__c retrievedPXNSFRecord = [Select Id, Name From Int_PX_NSF__c Limit 1];

        // Creating and runnning the Batch jobs for Invoice Consolidation and PNC File Generation
        System.Test.startTest();
            // Creating DAG
            List<String> pxNSFRecordNames = new List<string>{retrievedPXNSFRecord.Name};
            PNCNSFChargeCreatorJob job = new PNCNSFChargeCreatorJob();
            Database.executeBatch(job);
        System.Test.stopTest();

        List<cllease__Charge__c> chargesCreated = [Select Id, Name, cllease__Original_Amount__c, cllease__Fee_Definition__r.Name From cllease__Charge__c];

        System.assertEquals(1,  chargesCreated.size(), 'Mismatch in No Of NSF Charges created...');
        System.assertEquals(45, chargesCreated.get(0).cllease__Original_Amount__c, 'Mismatch in NSF Amount in Charge created...');
        System.assertEquals('NSF Fees', chargesCreated.get(0).cllease__Fee_Definition__r.Name, 'Mismatch in NSF Fee Definition Name in Charges created...');
        
        List<Int_PX_NSF__c> pxNSFRecordRetrieved = [Select Id, Name, Committed__c, Remark__c From Int_PX_NSF__c];
        System.assertEquals(1,  pxNSFRecordRetrieved.size(), 'Mismatch in No Of PNC NSF Records in System...');
        System.assertEquals(true, pxNSFRecordRetrieved.get(0).Committed__c, 'Mismatch in PNC NSF Commited Field Update...');
        System.assertEquals('NSF Charge Created Successfully', pxNSFRecordRetrieved.get(0).Remark__c, 'Mismatch in PNC NSF Remark Field Update...');
    
    }  

}