@isTest 
public class DMBIDataCleanUpScheduleJob_Test {
    @isTest public static void SchedulerTest(){
    Test.startTest();
    DMBIDataCleanUpScheduleJob sh1 = new DMBIDataCleanUpScheduleJob();
    String sch = '0 0 2 * * ?'; 
    system.schedule('Test Scheduler Job', sch, sh1); 
    Test.stopTest();
    }
}