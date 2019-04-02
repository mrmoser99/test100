@isTest
public class TestCreatePermissionsBatchJob {
    
    static TestMethod void CreatePermissionsBatchJob() {
        
        try{        	
	        CreatePermissionsBatchJob cpb = new CreatePermissionsBatchJob();
	        DataBase.executeBatch(cpb);
    	}
        catch(Exception e){}
    }

}