public with sharing class FMZ_QQ_Convert_Test {

    //Use @AuraEnabled to enable client- and server-side access to the method
    @AuraEnabled
    public static String convertQuickQuoteToApplication() {
       genesis__Quick_Quotes__c quickQuoteObject = [SELECT 
                                                    Id, Name, genesis__No_Of_Payments_Required_Upfront__c, ATS_Reference_Number__c, genesis__Account__c, 
                                                    genesis__Additional_cash_required__c, genesis__Address_Line_1__c, genesis__Application__c, Approved_Credit_Amount__c, 
                                                    Billing_Address__c, Business_Contacts__c, genesis__Business_Name__c, CL_Product__c, genesis__Cap_Reduction__c, 
                                                    genesis__Cash_Collected_By_Dealer__c, genesis__City__c, genesis__Collateral_Value__c, genesis__Company__c, 
                                                    genesis__Contact__c, genesis__Country__c, County__c, Credit_Approval__c, Credit_Approval_Date__c, Credit_Approval_Expiration_Date__c, 
                                                    genesis__Customer_cash_available__c, genesis__Customer_Cash_Used_For__c, Days_Convention__c, Dealer__c, genesis__Fees_Amount__c, 
                                                    Dealer_Name__c, genesis__Documentation_charges__c, genesis__Down_Payment__c, Email_Address__c, Equipment_Description__c, 
                                                    Estimated_Financed_Amount__c, Estimated_Monthly_Payment__c, genesis__Estimated_Selling_Price__c, genesis__Expected_Start_Date__c, 
                                                    genesis__Financed_Amount__c, genesis__First_Name__c, genesis__Last_Name__c, Legal_Entity__c, genesis__Lending_Product__c, 
                                                    genesis__Minimum_cash_Required__c, genesis__Next_Step__c, genesis__Number_of_Pieces_of_Equipment__c, genesis__Other_Financed_Fees__c, 
                                                    genesis__Total_Dealer_Payable__c, genesis__Payment_Amount__c, genesis__Payment_Frequency__c, genesis__Postal_Code__c, genesis__Pricing_Method__c, 
                                                    Primary_Phone_number__c, genesis__Product_Type__c, genesis__Total_Customer_Cash_Required__c, Sales_Division__c, 
                                                    genesis__Selected_Pricing_Option_Id__c, genesis__Social_Security_Number__c, genesis__Source__c, genesis__State__c, 
                                                    genesis__Status__c, Status_Text__c, genesis__Tax_Amount__c, genesis__Terms_Selected__c, Time_Trigger_05__c, 
                                                    genesis__Total_Cash_Due_from_Customer__c, genesis__Total_Dealer_Price__c, genesis__Total_Upfront_Payments__c, genesis__Valid_Pricing_Flag__c, 
                                                    Validation_Status__c, Validation_Time_Stamp__c, genesis__Warranty_Amount__c
                                                    FROM genesis__Quick_Quotes__c WHERE Id = 'a1S0v00000067tv'][0];
       return genesis.QuickQuoteController.convertQuickQuoteToApplication(quickQuoteObject);//TEST TEST TEST
    }
    //test
    
}