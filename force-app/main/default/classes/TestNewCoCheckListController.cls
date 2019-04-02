@isTest
public class TestNewCoCheckListController
{
static testmethod void TestNewCoCheckListCntrl ()
{
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

genesis__Department__c Dealerdept= new genesis__Department__c();
Dealerdept.name = 'DEALER CHECKLIST';
insert Dealerdept;

//List<Task> DealertaskLst = new List<Task>();
//for(Integer i=0;i<=5;i++)
//{                                                   
Task DealertaskLst= new Task(Description='Test-DealerCheckList',genesis__Application__c=application.id);
DealertaskLst.genesis__Department__c =Dealerdept.id;
DealertaskLst.status='OPEN';
//DealertaskLst .add(task);
//}
insert DealertaskLst;

genesis__Department__c NewCodept= new genesis__Department__c();
NewCodept.name = 'NEWCO CHECKLIST';
insert NewCodept;

//List<Task> NewCotaskLst = new List<Task>();
//for(Integer j=0;j<=5;j++)
//{                                                   
Task NewCotaskLst= new Task(Description='Test-DealerCheckList',genesis__Application__c=application.id);
NewCotaskLst.genesis__Department__c =NewCodept.id;
NewCotaskLst.status='OPEN';
//NewCotaskLst.add(task1);
//}
insert NewCotaskLst;

genesis__Department__c Exceptiondept= new genesis__Department__c();
Exceptiondept.name = 'Exception CHECKLIST';
insert Exceptiondept;

Task ExceptiontaskLst= new Task(Description='Test-ExceptionCheckList',genesis__Application__c=application.id);
ExceptiontaskLst.genesis__Department__c =Exceptiondept.id;
ExceptiontaskLst.status='OPEN';
insert  ExceptiontaskLst;

ApexPages.currentPage().getParameters().put('id',application.Id);
NewCoCheckListController testNewCoCheckList = new NewCoCheckListController();

NewCoCheckListController.wrapTask wrapper = new NewCoCheckListController.wrapTask(DealertaskLst);
//testDealerCheckList.wrapTaskList[0].selected = true;
wrapper.selected = true;
NewCoCheckListController.nwrapTask wrapper1 = new NewCoCheckListController.nwrapTask (NewCotaskLst);
wrapper1.nselected = true;
NewCoCheckListController.ewrapTask wrapper2 = new NewCoCheckListController.ewrapTask(ExceptiontaskLst);
wrapper2.eselected = true;
//testDealerCheckList.wrapTaskList[0].selected = true;
//System.Assert(testDealerCheckList.wrapTaskList!=null);

PageReference pageRef = Page.NewCoCheckList; 
Test.setCurrentPage(pageRef);
testNewCoCheckList.processSelected();
testNewCoCheckList.nprocessSelected();
testNewCoCheckList.eprocessSelected();

}
}