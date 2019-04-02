@isTest public class DMBIDataCleanupJob_Test {
    public static Id fcid;
    public static Id agrid;
    
   //Create test data and test Delete job.
    @testSetup static void creatTestData(){  
        //Create Agreement record      
        int_agreement__c agr = DMBIInterfaceJobDataFactoryTestUtil.createagreement();
        agrId = agr.id;
        agr.Committed__c = true;
        update agr;
        System.Assert((agr.ID != Null) && (agr.Committed__c = true));        
        
        //Create Asset record.
        Int_Asset__c asset = DMBIInterfaceJobDataFactoryTestUtil.createAsset();
        System.Assert(asset.ID != Null);
        
        //Create Party record.
        int_party__c party = DMBIInterfaceJobDataFactoryTestUtil.createEParty();
        System.Assert(party.ID != Null);
        
        //Create Delivery control record
        int_delivery_control__c dc = DMBIInterfaceJobDataFactoryTestUtil.createDeliverycontrol();
        System.Assert(dc.ID != Null);
        
        //Create Party feature record.
        int_party_feature__c pf = DMBIInterfaceJobDataFactoryTestUtil.createPartyFeature(agr); 
        System.Assert(pf.ID != Null);
        
        //Create agreement line feature record
        Int_Agreement_line_Feature__c ial = DMBIInterfaceJobDataFactoryTestUtil.createAgrlinefeature(agr);
        System.Assert(ial.ID != Null);
        
        //Create agreement party record.
        Int_Agreement_Party__c iap = DMBIInterfaceJobDataFactoryTestUtil.createAgrParty(agr);
        System.Assert(iap.ID != Null);
        
        //Create agreement exposure record
        Int_Agreement_Exposure__c ae = DMBIInterfaceJobDataFactoryTestUtil.createAgrExposure(agr);
        System.Assert(ae.ID != Null);
        
        //Create agreement classification record
        Int_Agreement_Classification__c ac =DMBIInterfaceJobDataFactoryTestUtil.createAgrClassification(agr);
        System.Assert(ac.ID != Null);
        
        //Create File control record.
        int_file_control__c fc = DMBIInterfaceJobDataFactoryTestUtil.createFilecontrol();
        fcid = fc.Id;
        update fc;
        System.Assert(fc.ID != Null);        
    } 
    
    //Delete file control record created above.   
    @isTest public static void deletefilecontrolData(){    
         Test.startTest();
        Database.executeBatch(new DMBIDataCleanUpJob('int_file_control__c'),10);
        Test.stopTest();
        List<int_file_control__c> deletedfc = [Select Id From int_file_control__c where Id = :fcId];
        System.Assert(deletedfc.size()==0);                           
     }
     
    //Delete agreement record created above.   
    @isTest public static void deleteAgreementData(){    
         Test.startTest();
        Database.executeBatch(new DMBIDataCleanUpJob('int_agreement__c'),10);
        Test.stopTest();
        List<int_agreement__c> deletedagr = [Select Id From int_agreement__c where Id = :agrId];
        System.Assert(deletedagr.size()==0);                           
     }
}