/*
Author: CLS

Summary: Class to create the Account for credit approval record being converted to application
*/
// This class not needed as it is handled by ConvertQuickQuoteToApplication.cls

Global class createAccountForCreditApproval{

/*
    webservice static string func_createacc(genesis__Quick_Quotes__c quickQuote){
    
    try {
    
        system.debug('quick quote record '+quickQuote);
    
        Map<String,genesis__Quick_Quote_Application_Account__c> qqToAccountMapping = genesis__Quick_Quote_Application_Account__c.getAll();
        
        clcommon__Legal_Entity__c corp_le = [select id, name from clcommon__Legal_Entity__c where name= 'Corporation' limit 1];

        if(qqToAccountMapping != null){

            List<genesis__Quick_Quote_Application_Account__c> mappingList = qqToAccountMapping.values();
            Account acc = new Account();
            for(genesis__Quick_Quote_Application_Account__c qa: mappingList){
               if(String.isNotBlank(qa.genesis__Quick_Quote_Field_Name__c) &&  
                  String.isNotBlank(qa.genesis__App_Account_Field_Name__c)){
                   acc.put(qa.genesis__App_Account_Field_Name__c, quickQuote.get(qa.genesis__Quick_Quote_Field_Name__c));
                   acc.put('clcommon__Legal_Entity_Type__c',corp_le.id);    
               }   
            }
            // insert acc;
            
                   
           Database.SaveResult saveResult = Database.insert(acc, false);

            if (!saveResult.isSuccess()) {

                for (Database.Error error : saveResult.getErrors()) {

                    // If there are duplicates, an error occurs
                    // Process only duplicates and not other errors 
                    //   (e.g., validation errors)
                    if (error instanceof Database.DuplicateError) {
                        // Handle the duplicate error by first casting it as a 
                        //   DuplicateError class
                        // This lets you use methods of that class 
                        //  (e.g., getDuplicateResult())
                        Database.DuplicateError duplicateError = 
                                (Database.DuplicateError)error;
                        Datacloud.DuplicateResult duplicateResult = 
                                duplicateError.getDuplicateResult();
                        
                        // Display duplicate error message as defined in the duplicate rule
                        system.debug('Duplicate Error: ' + 
                                duplicateResult.getErrorMessage());

                        
                        // Get duplicate records
                        List<Account> duplicateRecords = new List<Account>();

                        // Return only match results of matching rules that 
                        //  find duplicate records
                        Datacloud.MatchResult[] matchResults = duplicateResult.getMatchResults();

                        // Just grab first match result (which contains the 
                        //   duplicate record found and other match info)
                        Datacloud.MatchResult matchResult = matchResults[0];

                        Datacloud.MatchRecord[] matchRecords = matchResult.getMatchRecords();

                        // Add matched record to the duplicate records variable
                        for (Datacloud.MatchRecord matchRecord : matchRecords) {
                            System.debug('MatchRecord: ' + matchRecord.getRecord());
                            duplicateRecords.add((Account)matchRecord.getRecord());
                        }
                        
                        system.debug('duplicateRecords '+duplicateRecords);
                        string hurl =  URL.getSalesforceBaseUrl().toExternalForm();
                         return 'An Account already exists with same Business legal Name - '+duplicateRecords[0].name
                        +' . Below is the URL \n\n'
                        + hurl+ '/'+duplicateRecords[0].id + ' \n'
                        +'If you would like to use existing Account, press OK, else click Cancel to stop coversion to Application.';
                       
                    }
                    else {
                        System.debug(LoggingLevel.ERROR, 'DML Error : ' + error.getMessage());
                        return 'DML Error : ' + error.getMessage() + '\n';                        
                    }
                }
            }
        
            if (saveResult.isSuccess()) {   
                system.debug('able to save the account  '+ acc);
                genesis__Quick_Quotes__c qq = quickQuote;
                qq.genesis__Account__c = saveResult.getId();
                update qq;

                //insert address
                 Id addr_rectype = [select id from recordtype where developername='Lessee' and SobjectType = 'Address__c' and isactive=true limit 1].id;    

                 Address__c addr = new Address__c();
                 addr.Address_Line_1__c = qq.genesis__Address_Line_1__c;
                 addr.City__c = qq.genesis__City__c;
                 addr.State__c = qq.genesis__State__c;
                 addr.Zip_Code__c = qq.genesis__Postal_Code__c;
                 addr.Country__c = 'USA';
                 addr.Bill_To_Usage__c = true;
                 addr.Install_At__c = true;
                 addr.Account__c = saveResult.getId();
                 addr.Validation_Status__c = qq.Validation_Status__c;
                 addr.Validation_Time_Stamp__c = qq.Validation_Time_Stamp__c;
                 addr.recordtypeid = addr_rectype;

                 Database.SaveResult saveResult1 = Database.insert(addr, false);

                if (!saveResult1.isSuccess()) {
                    system.debug('not able to save the address  '+ addr);
                    for (Database.Error error : saveResult1.getErrors()) {
                        system.debug('Error encountered while inserting Address -- '+error.getMessage());
                       // return 'Error encountered while inserting Address -- '+error.getMessage()+' Please contact System Admin.';
                    }
                }
                else {
                    system.debug(' able to save the address,  '+ addr + ' , quick quote updating = ' + qq);
                        qq.Billing_Address__c = saveResult1.getid();
                        update qq;
                }
			system.debug(' new account created with address update,  ');
                return 'New Account created';
            }
            
            
        }    
        else {   
            system.debug(' Issue with Quick Quote to Account mapping. Please contact System Admin.  ');
            return 'Issue with Quick Quote to Account mapping. Please contact System Admin.';
        }
    }

    catch(exception e){
       system.debug('Error encountered : ' + e.getmessage() +', please contact System Admin.');
        return 'Error encountered : ' + e.getmessage() +', please contact System Admin.';
    }
	
        system.debug('end of func');
        return 'end of func';
}

    webservice static string func_useExistingAcc(genesis__Quick_Quotes__c quickQuote,string accountId){
        
        try{
                //User chose to use existing record, update it in Quick quote and Application
                genesis__Quick_Quotes__c qq = quickQuote;
                qq.genesis__Account__c = accountId;
                update qq;

                //insert address, if duplicate address found, do not insert

                 Id addr_rectype = [select id from recordtype where developername='Lessee' and SobjectType = 'Address__c' and isactive=true limit 1].id;    

                 Address__c addr = new Address__c();
                 addr.Address_Line_1__c = qq.genesis__Address_Line_1__c;
                 addr.City__c = qq.genesis__City__c;
                 addr.State__c = qq.genesis__State__c;
                 addr.Zip_Code__c = qq.genesis__Postal_Code__c;
                 addr.Country__c = 'USA';
                 addr.Bill_To_Usage__c = true;
                 addr.Install_At__c = true;
                 addr.Account__c = accountId;
                 addr.recordtypeid = addr_rectype;

                 Database.SaveResult saveResult = Database.insert(addr, false);

                if (!saveResult.isSuccess()) {
                    for (Database.Error error : saveResult.getErrors()) {
                        
                        if (error instanceof Database.DuplicateError) {
                        
                        Database.DuplicateError duplicateError =  (Database.DuplicateError)error;
                        Datacloud.DuplicateResult duplicateResult = duplicateError.getDuplicateResult();
                        
                        List<Address__c> duplicateRecords = new List<Address__c>();

                        Datacloud.MatchResult[] matchResults = duplicateResult.getMatchResults();

                        Datacloud.MatchResult matchResult = matchResults[0];

                        Datacloud.MatchRecord[] matchRecords = matchResult.getMatchRecords();

                        // Add matched record to the duplicate records variable
                        for (Datacloud.MatchRecord matchRecord : matchRecords) {
                            System.debug('MatchRecord: ' + matchRecord.getRecord());
                            duplicateRecords.add((Address__c)matchRecord.getRecord());
                        }
                        
                        qq.Billing_Address__c = duplicateRecords[0].id;
                        update qq;
                            
                        return 'Existing Account linked successfully. An address already exists for this Account';
                     }
                        else {

                            return 'Error encountered while inserting Address -- '+error.getMessage()+' Please contact System Admin.';
                        }
                    }

                }
                
                if (saveResult.isSuccess() && saveResult.getid() != null){
                        qq.Billing_Address__c = saveResult.getid();
                        update qq;
                }
                
                return 'Existing Account linked successfully';
           

        }
        
        catch(exception e){

        return 'Error encountered: ' + e.getmessage() +', please contact System Admin.';

        }

    }*/

}