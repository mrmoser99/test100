trigger CreateTaskList on genesis__Applications__c (after insert) {
    
    List<genesis__Applications__c> ownerid= new List<genesis__Applications__c>();
    List<User> pid = new List<User>();   
    List<User> pname = new List<User>();
    List<genesis__Department__c> Dealerdept = new List<genesis__Department__c>();
    List<genesis__Department__c> NewCoList = new List<genesis__Department__c>();
    
    //public List<genesis__Task_Setup__c> listOfTasks = new List<genesis__Task_Setup__c>();
    //newcotask=[select id from genesis__Task_Setup__c where Dept_Type__c='NewCo Admin'];
    //listOfTasks = [select id,Dept_Type__c,genesis__Description__c,genesis__Task_Name__c from genesis__Task_Setup__c];
    
    
    String appid;
    List<Task> tasklist = new List<Task>();
    List<Task> NewCotasklist = new List<Task>();
    NewCoList=[select id,name from genesis__Department__c where Name = 'NEWCO CHECKLIST'];
    Dealerdept=[select id,name from genesis__Department__c where Name = 'DEALER CHECKLIST'];
    for(genesis__Applications__c app:[SELECT id,OwnerId FROM genesis__Applications__c WHERE Id IN:trigger.new])
    {
        appid = app.id;
        ownerid = [SELECT OwnerId FROM genesis__Applications__c WHERE Id=:appid];
        System.debug('ownerr id '+ownerid[0].id);
        pname = [select Profile.name,UserRole.Name from User where id=:ownerid[0].OwnerId];
    }
    /*if(pname[0].Profile.Name == 'System Administrator' || pname[0].UserRole.Name == 'Dealer User')
    {
        for(genesis__Task_Setup__c ts:[select id,Dept_Type__c,genesis__Description__c,genesis__Task_Name__c from genesis__Task_Setup__c where  Dept_Type__c = 'Dealer User'])
        {
           
                Task t1 = new Task();
                t1.genesis__Application__c=appid;
                t1.Description=ts.genesis__Description__c;
                t1.Status='Open';
                t1.genesis__Department__c =  Dealerdept[0].id;
                t1.OwnerId=ownerid[0].OwnerId;
                t1.Subject=ts.genesis__Description__c;  
                t1.genesis__Task_Setup__c=ts.id;
                NewCotasklist.add(t1);
         }
        
    }*/
    if(pname[0].Profile.Name == 'System Administrator' || pname[0].UserRole.Name == 'Dealer User'){
        for(genesis__Task_Setup__c tss:[select id,Dept_Type__c,genesis__Description__c,genesis__Task_Name__c from genesis__Task_Setup__c where Dept_Type__c = 'NewCo Admin'])
        
        {
            
                
                Task t2 = new Task();
                t2.genesis__Application__c=appid;
                t2.Description=tss.genesis__Description__c;
                t2.Status='Open';
                t2.genesis__Department__c = NewCoList[0].id;
                t2.OwnerId=ownerid[0].OwnerId;
                t2.Subject=tss.genesis__Description__c; 
                t2.genesis__Task_Setup__c=tss.id;
                NewCotasklist.add(t2);  
    
                
        }
    }
   
    if(NewCotasklist.size()>0){
    insert NewCotasklist;
    }

}