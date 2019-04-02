Global Class CongaInvoiceGeneration{
   
 static String version = DLLNewCoConstants.SOAP_VERSION;
 static String partnerUrl = Url.getSalesforceBaseUrl().toExternalForm()+version+UserInfo.getOrganizationId().subString(0,15);  
 static String congaUrl;
 
   // this  method is used to generate Credit Approval Document
  Webservice static string generateInvoiceDocument(string recordId){
 
      try{
      cllease__Lease_Account__c DueDetails = [select Id,(select Id,Name from cllease__Dues_Details__r where cllease__Due_Date__c = This_month and cllease__Due_Date__c=This_Year) from cllease__Lease_Account__c WHERE Id =: recordId];
      
      string DueDetailsId = '';
      if(DueDetails.cllease__Dues_Details__r.size()>0)
      {
      system.debug('Due Details ID'+DueDetails.cllease__Dues_Details__r[0].Id);
       DueDetailsId = DueDetails.cllease__Dues_Details__r[0].Id;
       congaUrl='https://composer.congamerge.com/composer8/index.html?SolMgr=1&APIMode=1&sessionId='+userinfo.getsessionId()+'&serverUrl='+partnerUrl+'&QueryId=[GIV]a300t00000002q4,[DueDetailsLines]a300t00000003Ce?pv0='+DueDetailsId+'&TemplateId=a380t00000001Ox&DS7=1&OFN=InvoiceStatement&id='+recordId.subString(0,15);
       return getCalloutToConga(congaUrl);
      }
      else{
       return 'There is no bill for current month';

      }
      
      }
      
      catch(exception e){
      return e.getmessage();
      }
      
       
   }
    public static String getCalloutToConga(String url) {

    // Instantiate a new http object
    Http h = new Http();

    // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
    HttpRequest req = new HttpRequest();
    req.setEndpoint(url);
    req.setMethod('GET');
    req.setTimeout(60000);
    // Send the request, and return a response
    HttpResponse res = h.send(req);
     if(res.getStatusCode() != 200){
                return res.getStatus();
     }else if(!Pattern.matches('[a-zA-Z0-9]{18}',res.getBody())){
                return res.getBody();
      }
     return 'Document generated successfully'; 
    }  

   }