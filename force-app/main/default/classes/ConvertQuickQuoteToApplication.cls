global class ConvertQuickQuoteToApplication{
    
    public static final String RESPONSE_KEYWORD_STATUS = 'Status';
    public static final String RESPONSE_KEYWORD_MESSAGE = 'Message';
    public static final String STATUS_ERROR = 'ERROR';
    public static final String STATUS_SUCCESS = 'SUCCESS';  
    public static final String DUPLICATE_RECORD_ID = 'DuplicateId';
    
    // key = account field , value = quick quote field
    public static Map<String,String> accountFieldByQuickQuoteField = new Map<String,String>();
    // key = address field , value = quick quote field
    public static Map<String,String> addressFieldByQuickQuoteField = new Map<String,String>();
    
    
    
    private static genesis__Quick_Quotes__c queryQuickQuote(String quickQuoteId){
        mfiflexUtil.ExecutionContext ec = mfiflexUtil.ExecutionContext.getExecContext();
        mfiflexUtil.ObjectCache quickQuoteOC = ec.createObject('QuickQuoteOC','genesis__Quick_Quotes__c');
        quickQuoteOC.addFields('Name, Id');
        quickQuoteOC.addFields(accountFieldByQuickQuoteField.values());
        quickQuoteOC.addFields(addressFieldByQuickQuoteField.values());
        quickQuoteOC.addNamedParameter('quickQuoteId', quickQuoteId);
        quickQuoteOC.setWhereClause('Id = :quickQuoteId');    
        quickQuoteOC.buildQuery();  
        return (genesis__Quick_Quotes__c) quickQuoteOC.executeQuery().getRecords()[0];
    }
    
    private static Account getAccountWithDefaultValues(){
        Account newRecord = new Account();
        RecordType lessee = [SELECT ID
                                    FROM RecordType
                                    WHERE DeveloperName = 'Lessee' 
                                        AND SobjectType = 'Account' 
                                        AND IsActive = true limit 1];                                    
        clcommon__Legal_Entity__c corp = [SELECT ID
                                                 FROM clcommon__Legal_Entity__c 
                                                 WHERE Name = 'Corporation' limit 1];
        newRecord.clcommon__Legal_Entity_Type__c = corp.Id;
        newRecord.RecordTypeId = lessee.Id;
        return newRecord;
    }
    
    private static Address__c getAddressWithDefaultValues(){
        RecordType lessee = [SELECT ID
                                    FROM RecordType
                                    WHERE DeveloperName = 'Lessee' 
                                        AND SobjectType = 'Address__c' 
                                        AND IsActive = true limit 1];   
        Address__c address = new Address__c();
        address.RecordTypeId = lessee.Id;
        address.Country__c = 'USA';
        address.Bill_To_Usage__c = true;
        address.Install_At__c = true;
        address.Primary_Address__c = true;

        return address;                                    
    }
    
    private static List<sObject> getDuplicateRecords(Database.DuplicateError duplicateError){
        List<sObject> duplicateRecords = new List<sObject>();
        if (duplicateError != NULL){       
            Datacloud.DuplicateResult duplicateResult = duplicateError.getDuplicateResult();
            Datacloud.MatchResult[] matchResults = duplicateResult.getMatchResults();
            Datacloud.MatchResult matchResult = matchResults[0];
            Datacloud.MatchRecord[] matchRecords = matchResult.getMatchRecords();
            for (Datacloud.MatchRecord matchRecord : matchRecords) {
                duplicateRecords.add(matchRecord.getRecord());
            }
        }
        return duplicateRecords;
    }
    
    webservice static string createApplication(String quickQuoteId,
                                               Boolean mapDuplicateAccount){
        
        return Json.serialize(processAccountAndAddress(quickQuoteId, mapDuplicateAccount));                                       
    }
    
    private static Map<String, String> processAccountAndAddress(String quickQuoteId, Boolean mapDuplicateAccount){
        
        Map<String, String> response = new Map<String, String>();                                       
        Map<String,genesis__Quick_Quote_Application_Account__c> quickQuoteToAccountFieldMappings = 
                                                    genesis__Quick_Quote_Application_Account__c.getAll();
        if (quickQuoteToAccountFieldMappings != NULL){   
            for (genesis__Quick_Quote_Application_Account__c mapping : quickQuoteToAccountFieldMappings.values()){
                 if (String.isNotBlank(mapping.genesis__Quick_Quote_Field_Name__c) 
                     && String.isNotBlank(mapping.genesis__App_Account_Field_Name__c)){
                     // add field mapping to map
                     accountFieldByQuickQuoteField.put(mapping.genesis__App_Account_Field_Name__c,
                                                       mapping.genesis__Quick_Quote_Field_Name__c);
                 }
            }
            
            List<Quick_Quote_to_Address_Mapping__mdt> addressMapping = [SELECT Address_Field__c,
                                                                         Quick_Quote_Field__c
                                                                         FROM Quick_Quote_to_Address_Mapping__mdt];
            for(Quick_Quote_to_Address_Mapping__mdt mapping : addressMapping){
                addressFieldByQuickQuoteField.put(mapping.Address_Field__c, 
                                                  mapping.Quick_Quote_Field__c);
            }                                                                          
                                                                         
        }
                                                                           
        try{
            genesis__Quick_Quotes__c quickQuote = queryQuickQuote(quickQuoteId);
            Account accRecord = getAccountWithDefaultValues();
            for (String accountField : accountFieldByQuickQuoteField.keySet()){
                String qqField = accountFieldByQuickQuoteField.get(accountField);
                accRecord.put(accountField, quickQuote.get(qqField)); 
            }
             
            Database.SaveResult saveResult = Database.insert(accRecord, false);
            if (!saveResult.isSuccess()) {
                for (Database.Error error : saveResult.getErrors()) {
                    if (error instanceof Database.DuplicateError) {
                        List<sObject> duplicates = getDuplicateRecords((Database.DuplicateError)error);
                        if(duplicates.size() > 1){
                            response.put(RESPONSE_KEYWORD_STATUS, STATUS_ERROR);
                            response.put(RESPONSE_KEYWORD_MESSAGE, 
                                            'There are multiple duplicate Account records. Please resolve manually');   
                            return response;
                        } 
                        accRecord = (Account) duplicates[0];
                        if(mapDuplicateAccount == false){
                            response.put(RESPONSE_KEYWORD_STATUS, STATUS_ERROR);
                            response.put(RESPONSE_KEYWORD_MESSAGE, 'An account already exists in the system'); 
                            response.put(DUPLICATE_RECORD_ID, accRecord.Id); 
                            return response;                
                        }
                    } else {
                        response.put(RESPONSE_KEYWORD_STATUS, STATUS_ERROR);
                        response.put(RESPONSE_KEYWORD_MESSAGE, error.getMessage()); 
                        return response;
                    }
                }      
            }  
                  
            // map address
            Address__c address = getAddressWithDefaultValues();
            for (String addressField : addressFieldByQuickQuoteField.keySet()){
                String qqField = addressFieldByQuickQuoteField.get(addressField);
                address.put(addressField, quickQuote.get(qqField)); 
            }
            address.Account__c = accRecord.Id;
            saveResult = Database.insert(address, false);
            if (!saveResult.isSuccess()) {
                for (Database.Error error : saveResult.getErrors()) {
                    if (error instanceof Database.DuplicateError) {
                        List<sObject> duplicates = getDuplicateRecords((Database.DuplicateError)error);
                        if(duplicates.size() == 1){
                            address = (Address__c) duplicates[0];
                        } 
                    }
                }
            }
            
            
            quickQuote.genesis__Account__c = accRecord.Id;
            quickQuote.Billing_Address__c = address.Id;
            update quickQuote;
            
            String result = genesis.QuickQuoteController.convertQuickQuoteToApplication(quickQuote);       
            if (result.contains('Error :')){
                response.put(RESPONSE_KEYWORD_STATUS, STATUS_ERROR);
            } else {
                response.put(RESPONSE_KEYWORD_STATUS, STATUS_SUCCESS);
            }  
            response.put(RESPONSE_KEYWORD_MESSAGE, result);
            
        } catch(Exception error){
            response.put(RESPONSE_KEYWORD_STATUS, STATUS_ERROR);
            response.put(RESPONSE_KEYWORD_MESSAGE, error.getMessage()); 
            return response;
        }                                   
        return response;                                           
    }

}