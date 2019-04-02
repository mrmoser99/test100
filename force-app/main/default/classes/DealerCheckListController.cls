public class DealerCheckListController {

public Integer Count{get;set;}
public Integer openCount{get;set;}
public Integer eCount{get;set;}
public Integer eopenCount{get;set;}
public Integer nCount{get;set;}
public Integer nopenCount{get;set;}

public List<Task> tasklist { get; set;}
public List<Task> ntasklist { get; set;}
public List<Task> etasklist { get; set;}

public String appid{get;set;}
// wrapper List details

public List<nwrapTask> nwrapTaskList{get;set;}
public List<wrapTask> wrapTaskList{get;set;}
public List<Task> selectedTasks{get;set;}
public List<genesis__Department__c> Dealerdept = new List<genesis__Department__c>();
public List<genesis__Department__c> NewCoList = new List<genesis__Department__c>();

public List<Task> nselectedTasks{get;set;}

public List<ewrapTask> ewrapTaskList{get;set;}
public List<Task> eselectedTasks{get;set;}
  

    public DealerCheckListController() {
        if(ApexPages.currentPage().getParameters().get('id') != null){
                appid = ApexPages.currentPage().getParameters().get('id');
            }
   
        if(   wrapTaskList==null)  {
        wrapTaskList= new List<wrapTask>();
          Dealerdept=[select id,name from genesis__Department__c where Name = 'DEALER CHECKLIST'];
        for(Task  tasklist:[Select Description,status from Task where genesis__Application__c=:appid and genesis__Department__c=:Dealerdept[0].id]){
        wrapTaskList.add(new wrapTask(tasklist));
        }
        }
         if(nwrapTaskList==null)  {
        nwrapTaskList= new List<nwrapTask>();
        NewCoList=[select id, name from genesis__Department__c where Name = 'NEWCO CHECKLIST'];
        for(Task  ntasklist:[Select Description,status from Task where genesis__Application__c=:appid and genesis__Department__c=:NewCoList[0].id]){
        nwrapTaskList.add(new nwrapTask(ntasklist));
        }
        }
        
        if(ewrapTaskList==null)  {
        ewrapTaskList= new List<ewrapTask>();
        for(Task  etasklist:[Select Description,status,Subject from Task where genesis__Application__c=:appid and genesis__Department__c!=:Dealerdept[0].id and genesis__Department__c!=:NewCoList[0].id]){
        ewrapTaskList.add(new ewrapTask(etasklist));
        }
        }
          
        Count=[SELECT count() FROM Task WHERE genesis__Application__c=:appid and genesis__Department__c=:Dealerdept[0].id ];
        openCount=[SELECT count() FROM Task WHERE genesis__Application__c=:appid and Status='Completed' and genesis__Department__c=:Dealerdept[0].id]; 
         nCount=[SELECT count() FROM Task WHERE genesis__Application__c=:appid and genesis__Department__c=:NewCoList[0].id ];
        nopenCount=[SELECT count() FROM Task WHERE genesis__Application__c=:appid and Status='Completed' and genesis__Department__c=:NewCoList[0].id];
        
             eCount=[SELECT count() FROM Task WHERE genesis__Application__c=:appid and genesis__Department__c!=:Dealerdept[0].id and genesis__Department__c!=:NewCoList[0].id ];
        eopenCount=[SELECT count() FROM Task WHERE genesis__Application__c=:appid and Status='Completed' and genesis__Department__c!=:Dealerdept[0].id and genesis__Department__c!=:NewCoList[0].id]; 
    }


    public PageReference processSelected() {
    selectedTasks = new List<Task>();
 
        for(wrapTask wrapTaskObj : wrapTaskList) {
            if(wrapTaskObj.selected == true) {
                selectedTasks.add(wrapTaskObj.tas);
            }
        }
         List<task> taskupdate=new List<Task>();
        for(Task t:selectedTasks)
        {
            if(t.status!='Completed')
            {
           
            t.status='Completed';
            taskupdate.add(t);
            }
        }
        if(taskupdate.size()>0)
        update taskupdate;
        PageReference pageRef = new PageReference('/apex/DealerCheckList?id=' + appid); 
    pageRef.setRedirect(true); 
    return pageRef;
    }
    // new co checklist not editable
    public PageReference nprocessSelected() {
    nselectedTasks = new List<Task>();
 
        for(nwrapTask nwrapTaskObj : nwrapTaskList) {
            if(nwrapTaskObj.nselected == true) {
                nselectedTasks.add(nwrapTaskObj.ntas);
            }
        }
         List<task> ntaskupdate=new List<Task>();
        for(Task nt:nselectedTasks)
        {
            if(nt.status!='Completed')
            {
           
            nt.status='Completed';
            ntaskupdate.add(nt);
            }
        }
        if(ntaskupdate.size()>0)
        update ntaskupdate;
        PageReference pageRef = new PageReference('/apex/DealerCheckList?id=' + appid); 
    pageRef.setRedirect(true); 
    return pageRef;
    }
 
 // exception task List
 public PageReference eprocessSelected() {
    eselectedTasks = new List<Task>();
 
        for(ewrapTask ewrapTaskObj : ewrapTaskList) {
            if(ewrapTaskObj.eselected == true) {
                eselectedTasks.add(ewrapTaskObj.etas);
            }
        }
         List<task> etaskupdate=new List<Task>();
        for(Task et:eselectedTasks)
        {
            if(et.status!='Completed')
            {
           
            et.status='Completed';
            etaskupdate.add(et);
            }
        }
        if(etaskupdate.size()>0)
        update etaskupdate;
        PageReference pageRef = new PageReference('/apex/DealerCheckList?id=' + appid); 
    pageRef.setRedirect(true); 
    return pageRef;
    }
 
    // This is our wrapper/container class. In this example a wrapper class contains both the standard salesforce object Task and a Boolean value
    public class wrapTask {
        public Task tas {get; set;}
        public Boolean selected {get; set;}
 
        public wrapTask(Task a) {
            tas = a;
            selected = false;
        }
    }


    // This is our wrapper/container class. In this example a wrapper class contains both the standard salesforce object Task and a Boolean value
    public class ewrapTask {
        public Task etas {get; set;}
        public Boolean eselected {get; set;}
 
        public ewrapTask(Task a) {
            etas = a;
            eselected = false;
        }
    }
    
    // This is our wrapper/container class. In this example a wrapper class contains both the standard salesforce object Task and a Boolean value
    public class nwrapTask {
        public Task ntas {get; set;}
        public Boolean nselected {get; set;}
 
        public nwrapTask(Task a) {
            ntas = a;
            nselected = false;
        }
    }

}