/**
 * Author: Cloud Lending Solutions
 * Description: Following class is test class for InvoiceSummaryUtil  
 **/
@isTest
public class CongaImplTest
{
 static TestMethod void CongaImpl() {
     
 
            clcommon__Legal_entity__c  l= new clcommon__Legal_entity__c();
                l.name = 'DLLNewco';
                insert l;
                System.debug('Legal Entity'+l.id);
          
            RecordType rt = [SELECT id,Name 
                             FROM RecordType 
                             WHERE SobjectType='Account' AND Name='Lessee' limit 1];
                
              Account a = new Account();
                a.name='CLStest1';
                a.clcommon__Legal_Entity_Type__c = l.id;
                a.RecordTypeId = rt.id;
                insert a;
                System.debug('Account Insert'+a.id);
             
     			clcommon__Agreement__c agg =new clcommon__Agreement__c();
                agg.name='NewCo';
                insert agg;
             
               
                genesis__Applications__c gen= new genesis__Applications__c();
                
                gen.genesis__Account__c = a.id;
                
                gen.EIN_Number__c= '123';
     			gen.dealer_program__c = agg.id;
                
                insert gen;

                
                 System.Test.startTest();         
                 System.Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
                 CongaImpl.generateLeaseDocument(gen.id);
                 System.Test.stopTest();  
        
          
 
 }
  
}