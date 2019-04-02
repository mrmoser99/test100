/*
Author: CLS
Summary: Class to populate the dealer related to logged-in user when new Credit approval record is created.
*/

global class PopulateDealer{

    /*
    
    SNEHA :: This class is no more used. defaulting dealer account is handled on skuid page. 16th March, 2018



    webservice static Account func_popdeal(){
    
        Dealers_and_Users__c[] du = [Select id,
                                            Admin_User__c,
                                            Dealer__c,
                                            Primary__c 
                                            from Dealers_and_Users__c 
                                            where Admin_User__c = :UserInfo.getUserId() 
                                                and Primary__c = true];
    
        Account acc = [select id, name from Account where id = :du[0].Dealer__c];
    
        if(du.size() == 1){
            return acc;
        }
        else
            return new Account();

    }
    */
}