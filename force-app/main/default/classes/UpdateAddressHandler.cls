public class UpdateAddressHandler{
    
    @future
    public static void UpdateAddressHandler_func(list<id> qqlist){
    
    try{
        
        list<Address__c> insert_addrs = new list<Address__c>();
        list<Id> addr_ids = new list<Id>();
        map<id,id> acc_addr = new map<id,id>();
        Address__c addr;
        list<Account> acclist = new list<Account>();
        list<genesis__Applications__c> apps = new list<genesis__Applications__c>();
        list<id> appids = new list<id>();
        list<genesis__Application_Equipment__c> app_equips = new list<genesis__Application_Equipment__c>();
        Id addr_rectype = [select id from recordtype where developername='Lessee' and SobjectType = 'Address__c' and isactive=true limit 1].id;        
        
        for(genesis__Quick_Quotes__c qq: [select id,Dealer__c, genesis__Application__c, genesis__Application__r.genesis__Account__c, genesis__Status__c, genesis__Address_Line_1__c,
genesis__City__c,genesis__State__c,genesis__Postal_Code__c from genesis__Quick_Quotes__c where id in :qqlist]){
             addr = new Address__c();
             addr.Address_Line_1__c = qq.genesis__Address_Line_1__c;
             addr.City__c = qq.genesis__City__c;
             addr.State__c = qq.genesis__State__c;
             addr.Zip_Code__c = qq.genesis__Postal_Code__c;
             addr.Country__c = 'USA';
             addr.Bill_To_Usage__c = true;
             addr.Install_At__c = true;
             addr.Account__c = qq.genesis__Application__r.genesis__Account__c;
             addr.recordtypeid = addr_rectype;
             insert_addrs.add(addr);    
             appids.add(qq.genesis__Application__c);
        }
        
           
        Database.SaveResult[] srList = Database.insert(insert_addrs, false);

        // Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            
            
            if (sr.isSuccess()) {
                addr_ids.add(sr.getId());
            }
            else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Insert address failed for : ' + err.getFields());
                    }
            }
         }
         

        
        for(Address__c temp_addr : [select id, Account__c from Address__c where id in :addr_ids]){
            acc_addr.put(temp_addr.Account__c,temp_addr.id);
        }
        
       
        for(genesis__Applications__c ap : [select id,Billing_Address1__c,genesis__Account__c from genesis__Applications__c where id in :appids]){
            
            genesis__Applications__c temp_app = new genesis__Applications__c();
            temp_app = ap;
            temp_app.Billing_Address1__c = acc_addr.get(ap.genesis__Account__c);
            apps.add(temp_app);
            
        }
        
        update apps;
    
    }
    catch(exception e){
        system.debug('Exception in updating address on conversion '+ e.getmessage());
    }
    
    
    }

}