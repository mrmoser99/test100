/*
Author: CLS

11/8/2018 - T.Mattheou (Fortimize) - changed version and partnerUrl to public for newco portal

Summary: This class is created to call conga composer in order to generate Creditpull, D&A and Lease Agreement Templets
*/
global class CongaImpl
{
    public static string version = DLLNewCoConstants.SOAP_VERSION;
    public static string partnerUrl = Url.getSalesforceBaseUrl().toExternalForm() + version + UserInfo.getOrganizationId().subString(0, 15);
    static string congaUrl;
    // this  method is used to generate Credit Approval Document
   /* webservice static string generateCreditApprovalDocument(string recordId)
    {
        // getting conga query and templet URL id's from custom settings
        string CreditQryID = CongaURL_Settings__c.getInstance().CreditQryID__c;
        string CreditTmpID = CongaURL_Settings__c.getInstance().CreditTmpID__c;
        System.debug('HirarCreditQryID... ' + CreditQryID);
        
        congaUrl = Label.Conga_URL + userinfo.getsessionId() + '&serverUrl=' + partnerUrl + '&QueryId=[CAQ]' + CreditQryID 
                                  + '&TemplateId=' + CreditTmpID + '&DS7=1&OFN=CreditApproval&id=' + recordId.subString(0, 15);
                                  
        return getCalloutToConga(congaUrl);
    }*/
    // this  method is used to generate Credit Lease Agreement Document
    webservice static string generateLeaseDocument(string recordId)
    {
        // getting conga query and templet URL id's from custom settings
        string LeaseQryID = CongaURL_Settings__c.getInstance().LeaseQryID__c;
        string LeaseEQID = CongaURL_Settings__c.getInstance().LeaseEQID__c;
        string LeaseTmpID = CongaURL_Settings__c.getInstance().LeaseTmpID__c;
        
        congaUrl = Label.Conga_URL + userinfo.getsessionId() + '&serverUrl=' + partnerUrl + '&QueryId=[LeaseAgreement]' + 
                                  LeaseQryID + ',[EQ]' + LeaseEQID + '%3Fpv0%3D' + recordId + '&TemplateId=' + LeaseTmpID + 
                                  '&DS7=1&OFN=LeaseAgreement&id=' + recordId.subString(0, 15);
                                  
        System.debug('congaUrl' + congaUrl);
        return getCalloutToConga(congaUrl);
    }
    // this  method is used to generate DandA Document  
   /* webservice static string generateDandADocument(string recordId)
    {
        // getting conga query and templet URL id's from custom settings
        string DandAQryID = CongaURL_Settings__c.getInstance().DandAQryID__c;
        string DandAEQID = CongaURL_Settings__c.getInstance().DandAEQID__c;
        string DandATmpID = CongaURL_Settings__c.getInstance().DandATmpID__c;
        
        congaUrl = Label.Conga_URL + userinfo.getsessionId() + '&serverUrl=' + partnerUrl + '&QueryId=[DA]' + DandAQryID 
                                   + ',[EQ]' + DandAEQID + '%3Fpv0%3D' + recordId + '&TemplateId=' + DandATmpID + 
                                  '&DS7=1&OFN=DandA+Document&id=' + recordId.subString(0, 15);
                                  
        System.debug('congaUrl' + congaUrl);
        return getCalloutToConga(congaUrl);
    }*/
    public static string getCalloutToConga(string url)
    {
        // Instantiate a new http object
        Http h = new  Http();
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new  HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setTimeout(60000);
        // Send the request, and return a response
        HttpResponse res = h.send(req);
        if(res.getStatusCode() != 200)
        {
            return res.getStatus();
        }
        else if(!Pattern.matches('[a-zA-Z0-9]{18}', res.getBody()))
        {
            return res.getBody();
        }
        return 'Document Created successfully!!';
    }
}