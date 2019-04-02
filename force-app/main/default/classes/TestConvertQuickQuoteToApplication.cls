@isTest
public class TestConvertQuickQuoteToApplication {
    public static testMethod void QuotetoApplication()
    {
        RecordType lessee = [SELECT ID FROM RecordType wHERE DeveloperName = 'Lessee'AND SobjectType = 'Account'AND IsActive = true limit 1];                                    
        Account a= genesis.TestHelper.createAccount();
        a.RecordTypeId=lessee.id;
        upsert a;
        Map<String,String> lentity=genesis.TestHelper.createLegalEntityTypes();
        genesis.TestHelper h = new genesis.TestHelper();
        h.createQQToAppAccount();
        
       
        
      
        List<RecordType> rtypes = [Select Name,Id From RecordType where isActive=true and sObjectType='genesis__Loan_Product__c' ];
        Map<String,String> productRecordTypes = new Map<String,String>{};
        for(RecordType rt: rtypes)
            productRecordTypes.put(rt.Name,rt.Id);
        genesis__Loan_Product__c prod = new genesis__Loan_Product__c(recordtypeid = productRecordTypes.get('Lease Product Record Type'));
        prod.RecordTypeId = productRecordTypes.get('Lease Product Record Type');
        prod.Name = 'DEMO LEASE PRODUCT';
        insert prod;
        
        
        
        
        genesis__Quick_Quotes__c q= new genesis__Quick_Quotes__c();
            q.Dealer__c=a.id;
            q.genesis__Lending_Product__c=prod.id;
            q.genesis__Collateral_Value__c=100;
            q.genesis__Estimated_Selling_Price__c=100;
            q.genesis__Expected_Start_Date__c=Date.today();
            q.genesis__Source__c='DIRECT';
            q.genesis__Payment_Frequency__c='MONTHLY';
            q.genesis__Account__c=a.id;
            insert q;
        ConvertQuickQuoteToApplication.createApplication(q.Id, true);
       // ConvertQuickQuoteToApplication.getDuplicateRecords(q.id);
        ConvertQuickQuoteToApplication.createApplication(q.Id, true);
        //ConvertQuickQuoteToApplication.processAccountAndAddress(q.Id, true);
        
       
    }
  
}