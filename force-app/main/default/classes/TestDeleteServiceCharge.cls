@isTest
private class TestDeleteServiceCharge
{
    @testSetup
    static void setup()
    {
    
        RecordType r = [SELECT ID 
               FROM RecordType 
               WHERE DeveloperName = 'Dealer'AND SobjectType = 'Account'
               AND IsActive = true limit 1];
               
        Account ac = new Account();
        ac.Name = 'TestAccountDLL1';
        ac.RecordTypeId=r.id;
        insert ac;
        
        genesis__Quick_Quotes__c qq = new genesis__Quick_Quotes__c(
               Dealer__c=ac.id
              ,genesis__Business_Name__c='test business name'
              ,genesis__Address_Line_1__c='85 milford road'
              ,genesis__City__c='Downingtown'
              ,genesis__State__c='PA'
              ,genesis__Postal_Code__c='19335'
              ,Estimated_Financed_Amount__c='10000'
              ,genesis__Status__c='NEW');
    
      insert qq;

        Address__c addr = new Address__c(
                 address_line_1__c=qq.genesis__Address_Line_1__c
                ,city__c=qq.genesis__City__c
                ,state__c=qq.genesis__State__c
                ,zip_code__c=qq.genesis__Postal_Code__c
                ,account__c = ac.id
                ,Bill_To_Usage__c = true
                );
      insert addr;
      
      
       clcommon__Asset_Class__c asset = new clcommon__Asset_Class__c();
        asset.Name   = 'Office Equipment';
        insert asset;
        
        clcommon__CL_Product__c prod = new clcommon__CL_Product__c();
        prod.clcommon__Product_Name__c = 'Finance Lease';
        prod.clcommon__Class__c        = 'Commercial';
        prod.clcommon__Asset_Class__c  = asset.id;
        insert prod;
        
        clcommon__Agreement__c agree = new clcommon__Agreement__c();
        agree.name                             = 'NewCo';
        agree.CL_Product__c                    = prod.id;
        agree.Approval_Validity__c             = '60';
        agree.Allowable_Condition__c           = 'Used';
        agree.Payment_Term__c                  = 'ARREARS';
        agree.clcommon__Payment_Frequency__c   = 'Monthly';
        agree.Minimum_Financed_Amount__c       = 1000;
        agree.Maximum_Financed_Amount__c       = 50000;
        agree.Minimum_Term__c                  = 12;
        agree.Insurance_Rate_Adder__c          = 0.0017900000;
        agree.Insurance_Flat_Fee__c            = 17.25;
        agree.Maximum_Term__c                  = 63;
        agree.Allowable_Soft_Cost__c           = 125;
        agree.clcommon__Interim_Rent__c        = 'NO';
        agree.Pass_Through_Eligibility__c      = true;
        agree.Evergreen_Eligible__c            = true;
        agree.Evergreen_Term__c                = '2';
        agree.Residual_Sharing__c              = 'NO';
        agree.Asset_Return_Cost__c             = 'Lessee';
        agree.Asset_Repair_Cost__c             = 'Lessee';
        insert agree;
    
        genesis__Applications__c gen = new genesis__Applications__c();
        gen.genesis__quick_quote__c             = qq.id;
        gen.genesis__Estimated_Selling_Price__c = 500;
        gen.genesis__Status__c                  = 'APPROVED - DOCUMENT CHECK';
        gen.genesis__Account__c                 = ac.id;
        gen.dealer_program__c                   = agree.id;
        gen.Billing_Address1__c                 = addr.id;
        gen.genesis__Payment_Amount__c          = 200;
        gen.genesis__Term__c                    = 36;
        insert gen;
        
      
        genesis__Equipment_Master__c equipmaster = new genesis__Equipment_Master__c();
        equipmaster.genesis__Model__c                    = 'M5170';
        equipmaster.genesis__Enabled__c                  = true;
        //equipmaster.Economic_Life__c                     = 64;
        equipmaster.MSRP__c                              = 3715;
        equipmaster.genesis__Available_To_Lease_Flag__c  = true;
        equipmaster.genesis__Status__c                   = 'Current';
        equipmaster.Object_Category_ID__c                = '800102';
        equipmaster.Object_Category_Name__c              = 'Printers';
        equipmaster.Master_Asset_Type_ID__c              = '107';
        equipmaster.Master_Asset_Type__c                 = 'Office Equipment';
        equipmaster.Asset_Type_ID__c                     = '40000670'; 
        equipmaster.Asset_Type_Name__c                   = 'B&W Printer';
        insert equipmaster;
        
        genesis__Application_Equipment__c  eq  = new genesis__Application_Equipment__c();
        eq.genesis__Estimated_Selling_Price__c = 2000;
        eq.Installation_Date__c                = date.newInstance(2016,1,1);
        eq.genesis__Application__c             = gen.id;
        //eq.Upfront_Tax_Amount__c               =  200;
        eq.genesis__Equipment__c               = equipmaster.id;
        insert eq;

        genesis__Application_Equipment__c  eq1  = new genesis__Application_Equipment__c();
        eq1.genesis__Estimated_Selling_Price__c = 5000;
        eq1.Installation_Date__c                = date.newInstance(2017,1,1);
        eq1.genesis__Application__c             = gen.id;
        //eq1.Upfront_Tax_Amount__c               = 200;
        eq1.genesis__Equipment__c               = equipmaster.id;
        insert eq1;
        
        genesis__Application_Pricing_Detail__c  pricing = new genesis__Application_Pricing_Detail__c();
        pricing.genesis__Maximum_Financed_Amount__c      = 50000;
        pricing.genesis__Rate_Factor_Based_On_Amount__c  = 1000;
        pricing.genesis__Rate_Factor__c                  = 0.01830000;
        pricing.genesis__Term__c                         = 60;
        pricing.genesis__Yield_Percent__c                = 5.94;
        pricing.genesis__Application__c                  = gen.id;
        //pricing.Up_Front_Tax_For_Payment__c              = 10;
        pricing.genesis__Payment_Amount_Derived__c       = 500;
        pricing.genesis__Selected__c                     = true;
        insert pricing;

        clcommon__Fee_Definition__c  fee      = new clcommon__Fee_Definition__c();
        fee.Name                              = 'Service Fees';
        fee.clcommon__Amount__c               = 0;
        fee.clcommon__Active__c               = true;
        fee.clcommon__Type__c                 = 'OTHERS FEES';
        fee.clcommon__Include_In_Dues__c      = true;
        fee.clcommon__Taxable__c              = true;
        fee.clcommon__Calculation_Method__c   = 'FIXED';
        Fee.clcommon__Class__c                = 'Income';
        //fee.clcommon__Fee_Type__c           = 
        fee.clcommon__Apply_Pre_Bill_Days__c  = 'Yes';
        fee.clcommon__Passthrough_Event__c    = 'On Partial Payment';
        fee.clcommon__Withhold_Basis__c       = 'Amount';
        insert fee;
        
        Application_Fee__c appfee = new Application_Fee__c();
        appfee.Application__c           = gen.id;
        appfee.Equipment__c             = eq.id;
        appfee.Escalate_Service_On__c   = 'Total Payment';
        appfee.Escalation_Frequency__c  = 'ANNUAL';
        appfee.Number_of_Payments__c    =  36;
        appfee.Escalation_Type__c       = 'Percent %';
        appfee.Escalation_Value__c      = 10;
        appfee.Fee__c                   = fee.id;
        appfee.Amount__c                =  50;
        appfee.Frequency__c             = 'MONTHLY';
        appfee.Parent_id__c             = null;
        appfee.Parent_Application_Fee__c= null;
        appfee.IsDelete__c              = false;
        //appfee.Number_of_Payments__c  = 36 
        appfee.Number_of_Terms__c       = 36;
        appfee.Prorate_Per_Asset__c     = false;
        appfee.Service_Escalate__c      = 'YES';
        insert appfee;
        
        Application_Fee_Payment__c AppPayment = new Application_Fee_Payment__c();
        AppPayment.Application__c     = gen.id;
        AppPayment.Application_Fee__c = appfee.id;
        insert AppPayment;
    }
     private static testMethod void TestMethod1()
    {
        
       List<Application_Fee__c> appfeelist = [SELECT id,Parent_id__c,Parent_Application_Fee__c,Number_of_Payments__c,Number_of_Terms__c FROM Application_Fee__c WHERE Application__r.genesis__Account__r.Name = 'TestAccountDLL1' limit 1];
       System.debug('***the appfeelist****'+appfeelist);
       
       System.Test.startTest();
           DeleteServiceCharge.invokeDeleteServiceFee(appfeelist);
       System.Test.stopTest();
     }
}