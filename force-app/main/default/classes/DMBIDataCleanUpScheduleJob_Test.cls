@isTest 
public class DMBIDataCleanUpScheduleJob_Test {
    @isTest public static void testScheduleJob(){
    Test.startTest();
    DMBIDataCleanUpScheduleJob job = new DMBIDataCleanUpScheduleJob();
    String sch = '0 0 2 * * ?'; 
    system.schedule('Test Scheduler Job', sch, job); 
    CronTrigger CronTrg = [Select Id, OwnerId, CronJobDetail.Name From CronTrigger where CronJobDetail.Name = 'Test Scheduler Job']; 
    System.Assert(CronTrg.Id != Null);
    Test.stopTest();
    }
}