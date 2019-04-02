// this code comment due to upfront tax not calculated right now ,it may use in future
Global class CapitalizeTax
{
/*  WebService static String CapitalizeTax(string applicationid, string response)
    {
    
        list<genesis__Applications__c> applist=[SELECT genesis__Term__c,genesis__Expected_First_Payment_Date__c FROM genesis__Applications__c WHERE id=:applicationid LIMIT 1];
    
        list<clcommon__Fee_Definition__c> ClleaseFee=[SELECT id,Name FROM 
        clcommon__Fee_Definition__c WHERE Name= :DLLNewCoConstants.FEE_UPFRONT_TAX_FEE AND clcommon__Active__c=true LIMIT 1];
          
        list<Application_Fee__c> appfeestobeinserted = new list<Application_Fee__c>();
        
        String Status;
        
        List<genesis__Applications__c> appslist = [select id,Name,
                                                             genesis__Financed_Amount__c,
                                                             Capitalize_UpFront_Tax__c,
                                                             Total_Upfront_Tax_Amount__c
                                                             from genesis__Applications__c
                                                             where id=:applicationid];
        system.debug('@@@@@@@' + appslist);
        
        for(genesis__Applications__c app:appslist)
         {
         if( response=='YES' && app.Capitalize_UpFront_Tax__c=='NONE')
            {
            app.genesis__Financed_Amount__c+=app.Total_Upfront_Tax_Amount__c;
            app.Capitalize_UpFront_Tax__c='YES';
            Status='Please recalculate lease pricing as upfront tax amount added to financed amount';  
            }
            
         else if(response=='YES' && app.Capitalize_UpFront_Tax__c=='NO')
            {
            Application_Fee__c appfee =[select id,Amount__c,Application__r.id from Application_Fee__c where Application__r.id=:applicationid AND Amount__c=:app.Total_Upfront_Tax_Amount__c ];
            delete appfee;
            app.genesis__Financed_Amount__c+=app.Total_Upfront_Tax_Amount__c;
            app.Capitalize_UpFront_Tax__c='YES';
            Status= 'Please recalculate lease pricing as upfront tax amount added to financed amount';  
            }
            
         else if(response=='NO' && app.Capitalize_UpFront_Tax__c=='YES')
            {
            app.genesis__Financed_Amount__c-=app.Total_Upfront_Tax_Amount__c;
            app.Capitalize_UpFront_Tax__c='NO';
            Application_Fee__c appfee = new Application_Fee__c(
                                     Fee__c=ClleaseFee[0].id,
                                     Amount__c=app.Total_Upfront_Tax_Amount__c,
                                     Application__c=applicationid,
                                     Fee_Amount__c=0,
                                     Frequency__c='Monthly',
                                     Number_of_Payments__c=1,
                                     Start_Date__c=applist[0].genesis__Expected_First_Payment_Date__c);
            appfeestobeinserted.add(appfee);   
            insert appfeestobeinserted; 
            Status= 'Tax Uncapitalized Successfully and '+ appfeestobeinserted[0].name+' inserted';
            }
            
          else if(response=='NO' && app.Capitalize_UpFront_Tax__c=='NONE')
            {
            app.Capitalize_UpFront_Tax__c='NO';
            Application_Fee__c appfee = new Application_Fee__c(
                                     Fee__c=ClleaseFee[0].id,
                                     Amount__c=app.Total_Upfront_Tax_Amount__c,
                                     Application__c=applicationid,
                                     Fee_Amount__c=0,
                                     Frequency__c='Monthly',
                                     Number_of_Payments__c=1,
                                     Start_Date__c=applist[0].genesis__Expected_First_Payment_Date__c);
            appfeestobeinserted.add(appfee);   
            insert appfeestobeinserted; 
            Status= 'Tax Uncapitalized Successfully and '+ appfeestobeinserted[0].name+' inserted';
            }  
         
         }
        
         return Status;
        
      }    */
      
    }