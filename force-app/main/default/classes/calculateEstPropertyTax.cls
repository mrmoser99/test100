/*
Author: CLS

Summary: Class to calculate the Estimated Property tax (EPT) for application equipments
*/

Global class calculateEstPropertyTax{


webservice static string func_calcEPT(ID applicationId){

    //list to store the application equipments for Application ID passed
    List<genesis__Application_Equipment__c> list_equipments = new List<genesis__Application_Equipment__c>();
    
    //map to store application ID and related application equipment record
    Map<ID,genesis__Application_Equipment__c> map_App_Equipment = new Map<ID,genesis__Application_Equipment__c>();
    
    //storing the info from the Application   
    genesis__Applications__c app_info = [select id,Purchase_Option__c, genesis__Term__c,genesis__Expected_First_Payment_Date__c,genesis__Payment_Frequency__c from genesis__Applications__c where id = :applicationId];
    
    //to store the term of lease
    String app_term = String.valueOf(app_info.genesis__Term__c);
    
    //to hold the Application fee record
    Application_Fee__c app_fee = new Application_Fee__c();
    
    //to get the Fee record for Estimated Property Tax Fee
    clcommon__Fee_Definition__c EPT_Fee = [select id,name from clcommon__Fee_Definition__c where name= :DLLNewCoConstants.FEE_ESTIMATED_PROPERTY_TAX limit 1];
    
    //to store the total EPT for all equipments
    Decimal Total_EPT = 0; 
        
    //Map to store rate factors for Property tax
    Map<String,Double> state_rates = new Map<String,Double>();
    
    //to store return message
    String return_msg;
    
    //to store list of existing application fee records
    List<Application_Fee__c> list_app_fee = new List<Application_Fee__c>();
    
    //to store list of application fee records to be inserted/updated
    List<Application_Fee__c> list_app_fee_upsert = new List<Application_Fee__c>();       
    
    //map to store <Application:Equipment-Application Fee record> info
    Map<String,Application_Fee__c> map_Equip_AppFee = new Map<String,Application_Fee__c>();
    
    
    try{
        //querying application equipments
        list_equipments = [select id, Install_Address1__r.State__c,genesis__Estimated_Selling_Price__c,genesis__Application__c  from genesis__Application_Equipment__c where genesis__Application__c = :applicationId];
        
        for(Property_Tax_Rate_Factors__c PTRF : [select id, Rate_Factor__c,State__c, Term__c from Property_Tax_Rate_Factors__c where Term__c = :app_term]){
        state_rates.put(PTRF.State__c,PTRF.Rate_Factor__c);
        }
           
        //if application has equipments related to it
        if(list_equipments.size() > 0 && app_info.genesis__Term__c > 0){
        
            //to store the existing application fee record for EPT, if any
            list_app_fee = [select id,Number_of_Payments__c,Start_Date__c, Amount__c,Application__c,Equipment__c from Application_Fee__c where Application__c = :app_info.id and Fee__c= :EPT_Fee.id];   

            //looping through app fee records to populate Map
            if(list_app_fee.size() > 0){
                for(Application_Fee__c a_f : list_app_fee){
                
                map_Equip_AppFee.put(a_f.Application__c+':'+a_f.Equipment__c,a_f);
                }
            }
            
            
            for(genesis__Application_Equipment__c equipment: list_equipments){
             
                if(map_Equip_AppFee.get(equipment.genesis__Application__c+':'+equipment.id) == null){
                    
                    //if no existing application fee record for EPT for this equipment, create one
                    app_fee = new Application_Fee__c(
                            Equipment__c=equipment.id,
                            Application__c=app_info.id,
                            Fee__c=EPT_Fee.id,Frequency__c='MONTHLY',
                            Number_of_Payments__c=app_info.genesis__Term__c,
                            Start_Date__c=app_info.genesis__Expected_First_Payment_Date__c,
                            Amount__c=cllease.ValueUtil.round(equipment.genesis__Estimated_Selling_Price__c * state_rates.get(equipment.Install_Address1__r.State__c)));
                    if(app_fee.Amount__c > 0)
                     list_app_fee_upsert.add(app_fee);
                }
                else{
                // update the existing application fee record for EPT
                    app_fee = new Application_Fee__c();
                    app_fee = map_Equip_AppFee.get(equipment.genesis__Application__c+':'+equipment.id);
                    app_fee.Number_of_Payments__c=app_info.genesis__Term__c;
                    app_fee.Start_Date__c=app_info.genesis__Expected_First_Payment_Date__c;
                    app_fee.Amount__c=cllease.ValueUtil.round(equipment.genesis__Estimated_Selling_Price__c * state_rates.get(equipment.Install_Address1__r.State__c));
                    if(app_fee.Amount__c > 0)
                    list_app_fee_upsert.add(app_fee);
                
                    
                }                
            }
        
        upsert list_app_fee_upsert;
        
        }
        
    }
    catch(exception e){
    //debug exceptions and return with Failure status
    return_msg = 'FAILURE';
    system.debug('** Error in calculating Property tax fee **'+e.getmessage());
    system.debug('======line====='+e.getlinenumber());
    return return_msg;
    }
    
    //return with success status
    return_msg = 'SUCCESS';
    
    return return_msg;
    
}

}