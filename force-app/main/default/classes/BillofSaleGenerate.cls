global class BillofSaleGenerate {
    static String version = DLLNewCoConstants.SOAP_VERSION;
    static String partnerUrl = Url.getSalesforceBaseUrl().toExternalForm()+version+UserInfo.getOrganizationId().subString(0,15);  
    static String congaUrl;
    static string bqueryId;
    static String accId;
    static String ADD;
    static string BillTempId;
     Webservice static string generateBillofSaleDocument(string recordId){
    
    List<cllease__Asset_workbench__c> assetw=[SELECT Id,Sale_Price__c,Date_Sold__c,Sold_To__r.name,Sold_To__r.Primary_Address__r.City__C,cllease__Contract_Equipment__r.name,cllease__Contract_Equipment__r.Serial_Number__c,cllease__Contract__r.name FROM cllease__Asset_workbench__c where cllease__Contract_Equipment__r.id=:recordId Limit 1];
    list<Address__c> addrs = [SELECT Account__c, Address_Line_1__c, Address_Line_2__c, City__c, Country__c, County__c, State__c, Zip_Code__c FROM Address__c WHERE Account__c =: assetw[0].Sold_To__c AND Ship_To__c=true];    
    accId=assetw[0].Sold_To__r.id;     
    ADD=CongaURL_Settings__c.getInstance().BoSAdd__c;     
    bqueryId=CongaURL_Settings__c.getInstance().BillofSale__c;
    BillTempId=CongaURL_Settings__c.getInstance().BillofSaleTemplate__c;
         if(assetw.size()>0){
             congaUrl=Label.Conga_URL+userinfo.getsessionId()+'&serverUrl='+partnerUrl+'&QueryId=[BILL]'+bqueryId+'&QueryId=[ADD]'+ADD+'?pv0='+accId+'&TemplateId='+BillTempId+'&DS7=1&id='+recordId.subString(0,15);
             System.debug('Conga Urlllllllllllllll'+congaUrl);
             return CongaGenerateInvoice.getCalloutToConga(congaUrl);
         }else{
             return 'Bill of Sale will generate only when Contract Equipment status is SOLD';
         }
  
    }
  
}