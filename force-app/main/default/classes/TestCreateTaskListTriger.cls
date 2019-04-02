@isTest
public class TestCreateTaskListTriger
{

static testmethod void TestCreateTaskList()
{

Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
UserRole role=[select id,name from UserRole where name='Dealer User'] ;
        User u = new User(Alias = 'mclar', Email='mclarke=leasedirect.com@example.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId=role.id,
            TimeZoneSidKey='America/Los_Angeles', UserName='testing@Tasklist.com.dev');
system.runas(u)
{

genesis__Department__c Dealerdept= new genesis__Department__c();
Dealerdept.name = 'DEALER CHECKLIST';
insert Dealerdept;

genesis__Department__c NewCodept= new genesis__Department__c();
NewCodept.name = 'NEWCO CHECKLIST';
insert NewCodept;

List<genesis__Task_Setup__c> TaskSetupLst= new List<genesis__Task_Setup__c >();
for(Integer i=0;i<=5;i++)
{
genesis__Task_Setup__c TaskSetup1 = new genesis__Task_Setup__c ();
TaskSetup1.genesis__Description__c='TAX ELIGIBILITY';
TaskSetup1.genesis__Task_Name__c='TAX ELIGIBILITY';
TaskSetup1.Dept_Type__c ='Dealer User';
TaskSetupLst.add(TaskSetup1);
}
insert TaskSetupLst;

List<genesis__Task_Setup__c> TaskSetupLst1= new List<genesis__Task_Setup__c >();
for(Integer j=0;j<=5;j++)
{
genesis__Task_Setup__c TaskSetup2 = new genesis__Task_Setup__c ();
TaskSetup2.genesis__Description__c='TAX ELIGIBILITY';
TaskSetup2.genesis__Task_Name__c='TAX ELIGIBILITY';
TaskSetup2.Dept_Type__c ='NewCo Admin';
TaskSetupLst1.add(TaskSetup2);
}
insert TaskSetupLst1;


System.debug('Role is ' + role.name);
Account a = new Account();
a.Name = 'TestAccount-NewCoCheckList';
a.Phone = '98767 678987';
a.BillingPostalCode = 'BD1 1HA';
a.BillingCity = 'NewYork';
a.ShippingPostalCode = 'BD1 1HA';
a.ShippingCity = 'NewYork';
insert a;
        
Contact contact = new Contact();
contact.FirstName = 'Test1';
contact.LastName = 'contact';
contact.Account = a;

clcommon__Agreement__c dealerProgram = new clcommon__Agreement__c();
dealerProgram.Name='NewCo';
insert dealerProgram;

genesis__Applications__c application = new genesis__Applications__c(genesis__Account__c=a.id,
                                                    Dealer_Invoice_Number__c='123456',Dealer_Invoice_Date__c=Date.today(),genesis__Term__c=12);
application.dealer_program__c = dealerProgram.id;
insert application;

application.OwnerId=u.id;
update application;

//List<genesis__Applications__c> ownerid= [SELECT OwnerId FROM genesis__Applications__c WHERE Id=:application.id];

}
}

}