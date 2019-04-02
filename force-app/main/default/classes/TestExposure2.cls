@isTest
public  class TestExposure2 {

   
    static TestMethod void Test1() {

        cllease__lease_account__c l = TestCDManualController.createContract();

        id batchinstanceid = database.executeBatch(new BatchExposureCalc(),1); 
         
    }

    static TestMethod void test2(){
		 test.starttest();
         ExecuteExposureCalc myClass = new  ExecuteExposureCalc ();   
         String chron = '0 0 23 * * ?';        
         system.schedule('Test Sched', chron, myClass);
         test.stopTest();

	}



}