/**
 * Author: Cloud Lending Solutions
 * Description: Following class is used to generate termination Quoate documents  
 **/
global class CongaTerminationQuote
{
    public boolean selectedcheck{set;get;}
    static string version = DLLNewCoConstants.SOAP_VERSION;
    static string partnerUrl = Url.getSalesforceBaseUrl().toExternalForm() + version + UserInfo.getOrganizationId().subString(0, 15);
    static string congaUrl;
    public string redirectURL{get;set;}
    public string Message{get;set;}
    private string Terminationid{get;set;}
    public string TerminationType{set;get;}
  
    public List<wrapQuote> wrapQuoteList {get; set;}
    public List<cllease__Termination_Quote_Header__c> selectedquote{get;set;}
    
    public String QuoteEquipment      = CongaURL_Settings__c.getInstance().Quote_Equipment__c;
    public String QuoteHeader         = CongaURL_Settings__c.getInstance().Quote_Header__c;
    public String SummaryQuote        = CongaURL_Settings__c.getInstance().Summary_Quote__c;
    public String SumwithTempID       = CongaURL_Settings__c.getInstance().SumwithTempID__c;
    public String SumwithoutTempID    = CongaURL_Settings__c.getInstance().SumwithoutTempID__c;
    public String DetailwithTempId    = CongaURL_Settings__c.getInstance().DetailwithTempId__c;
    public String DetailwithoutTempId = CongaURL_Settings__c.getInstance().DetailwithoutTempId__c;

   
    public CongaTerminationQuote(){
      String cid= apexpages.currentpage().getparameters().get('id');
      system.debug('iddddddd'+cid);
       if(wrapQuoteList == null) {
            wrapQuoteList = new List<wrapQuote>();
            for(cllease__Termination_Quote_Header__c q: [select name,cllease__Quote_Amount__c,cllease__Effective_From__C,cllease__effective_to__c,cllease__Quote_reason__C,cllease__Quote_Type__C,cllease__status__c from cllease__Termination_Quote_Header__c where cllease__Contract__r.id=:cid ]){
            wrapQuoteList.add(new wrapQuote(q));
        
            }  
      }    
      

    }



    public class wrapQuote {
        public cllease__Termination_Quote_Header__c acc {get; set;}
        public Boolean selected {get; set;}
 
        public wrapQuote(cllease__Termination_Quote_Header__c a) {
            acc=a;
            selected = false;
        }
    }
    
   public void renderedTerminationbuttons()
    {
        TerminationType = '';
        system.debug('Terminationid::::'+Terminationid);
       // cllease__Termination_Quote_Header__c termQH = [select id,cllease__Quote_Type__c from cllease__Termination_Quote_Header__c where id=:Terminationid];
       // TerminationType = termQH.cllease__Quote_Type__c ;
        System.debug('TerminationType'+TerminationType);
        
             selectedquote = new List<cllease__Termination_Quote_Header__c>();
 
        for(wrapQuote wrapAccountObj : wrapQuoteList) {
             system.debug('wrapAccountObj.selected  ---------'+wrapAccountObj.selected);

            if(wrapAccountObj.selected == true) {
                selectedquote.add(wrapAccountObj.acc);
            }
            else
                wrapAccountObj.selected = false ;

        }
         
          If(selectedquote.size()>0){
        system.debug('selectedWrapperList size ---------'+selectedquote.size());
        system.debug('Quote id ---------'+selectedquote[0].id);
        
        String recordId = selectedquote[0].id;
        
        cllease__Termination_Quote_Header__c termQH = [select id,cllease__Quote_Type__c from cllease__Termination_Quote_Header__c where id=:recordId];
        TerminationType = termQH.cllease__Quote_Type__c ;
        system.debug('TerminationType ::::'+TerminationType); 
        system.debug('Selected Quote ID'+recordId);
        }
    }

    public void summaryWithPurchase() {
       boolean flag = true;
         selectedquote = new List<cllease__Termination_Quote_Header__c>();
 
        for(wrapQuote wrapAccountObj : wrapQuoteList) {
             system.debug('wrapAccountObj.selected  ---------'+wrapAccountObj.selected);

            if(wrapAccountObj.selected == true) {
                selectedquote.add(wrapAccountObj.acc);
            }
        }
        If(selectedquote.size()>0){
        system.debug('selectedWrapperList size ---------'+selectedquote.size());
        system.debug('Quote id ---------'+selectedquote[0].id);
        
        String recordId = selectedquote[0].id;
         
        system.debug('Record ID'+recordId);
        
        cllease__Termination_Quote_Header__c tqh = [select id, cllease__Contract__r.id from cllease__Termination_Quote_Header__c where id =:recordId]; 
        string contractId = tqh.cllease__Contract__r.id;
        system.debug('ContractID...'+contractId);
        
        congaUrl = Label.Conga_URL+userinfo.getsessionId()+'&serverUrl='+ partnerUrl+'&QueryId=[SP]'+QuoteHeader+',[SQ]'+SummaryQuote+
                  '?pv0='+contractId+',[TQE]'+QuoteEquipment+'?pv0='+recordId+'&TemplateId='+SumwithTempID+'&AttachmentParentID='+contractId+'&DS7=1&OFN=Summarywithpurchase&Id='+recordId.subString(0, 15);
        
        system.debug('Conga URL...'+congaUrl);
         Message = getCalloutToConga(congaUrl); 
        }
        
        
        else {
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select the Termination Quote'));
        }
        
    
       }
    public void summaryWithOutPurchase() {
         selectedquote = new List<cllease__Termination_Quote_Header__c>();
 
        for(wrapQuote wrapAccountObj : wrapQuoteList) {
             system.debug('wrapAccountObj.selected  ---------'+wrapAccountObj.selected);

            if(wrapAccountObj.selected == true) {
                selectedquote.add(wrapAccountObj.acc);
            }
        }
        If(selectedquote.size()>0){
        system.debug('selectedWrapperList size ---------'+selectedquote.size());
        system.debug('Quote id ---------'+selectedquote[0].id);
        
        String recordId = selectedquote[0].id;
         
        system.debug('Record ID'+recordId);
        
        cllease__Termination_Quote_Header__c tqh = [select id, cllease__Contract__r.id from cllease__Termination_Quote_Header__c where id =:recordId]; 
        string contractId = tqh.cllease__Contract__r.id;
        system.debug('ContractID...'+contractId);
        congaUrl = Label.Conga_URL+userinfo.getsessionId()+'&serverUrl='+ partnerUrl+'&QueryId=[SP]'+QuoteHeader+',[SQ]'+SummaryQuote+
                  '?pv0='+contractId+',[TQE]'+QuoteEquipment+'?pv0='+recordId+'&TemplateId='+SumwithoutTempID+'&AttachmentParentID='+contractId+'&DS7=1&OFN=Summarywitouthpurchase&Id='+recordId.subString(0, 15);
        system.debug('Conga URL...'+congaUrl);
         Message = getCalloutToConga(congaUrl); 
        //system.debug('Message...'+Message);
       }
        else {
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select the Termination Quote'));
        }
    }
    public void detailWithPurchase() {
    
         selectedquote = new List<cllease__Termination_Quote_Header__c>();
 
        for(wrapQuote wrapAccountObj : wrapQuoteList) {
             system.debug('wrapAccountObj.selected  ---------'+wrapAccountObj.selected);

            if(wrapAccountObj.selected == true) {
                selectedquote.add(wrapAccountObj.acc);
            }
        }
        If(selectedquote.size()>0){
        system.debug('selectedWrapperList size ---------'+selectedquote.size());
        system.debug('Quote id ---------'+selectedquote[0].id);
        
        String recordId = selectedquote[0].id;
         
        system.debug('Record ID'+recordId);
        
        cllease__Termination_Quote_Header__c tqh = [select id, cllease__Contract__r.id from cllease__Termination_Quote_Header__c where id =:recordId]; 
        string contractId = tqh.cllease__Contract__r.id;
        system.debug('ContractID...'+contractId);
        congaUrl = Label.Conga_URL+userinfo.getsessionId()+'&serverUrl='+ partnerUrl+'&QueryId=[SP]'+QuoteHeader+',[SQ]'+SummaryQuote+
                  '?pv0='+contractId+',[TQE]'+QuoteEquipment+'?pv0='+recordId+'&TemplateId='+DetailwithTempId+'&AttachmentParentID='+contractId+'&DS7=1&OFN=Detailwithpurchase&Id='+recordId.subString(0, 15);
        system.debug('Conga URL...'+congaUrl);
         Message = getCalloutToConga(congaUrl); 
        

       }
        else {
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select the Termination Quote'));
        }
    }
    public void detailWithOutPurchase() {
         selectedquote = new List<cllease__Termination_Quote_Header__c>();
 
        for(wrapQuote wrapAccountObj : wrapQuoteList) {
             system.debug('wrapAccountObj.selected  ---------'+wrapAccountObj.selected);

            if(wrapAccountObj.selected == true) {
                selectedquote.add(wrapAccountObj.acc);
            }
            }
        If(selectedquote.size()>0){
        system.debug('selectedWrapperList size ---------'+selectedquote.size());
        system.debug('Quote id ---------'+selectedquote[0].id);
        
        String recordId = selectedquote[0].id;
         
        system.debug('Record ID'+recordId);
        
        cllease__Termination_Quote_Header__c tqh = [select id, cllease__Contract__r.id from cllease__Termination_Quote_Header__c where id =:recordId]; 
        string contractId = tqh.cllease__Contract__r.id;
        system.debug('ContractID...'+contractId);
        congaUrl = Label.Conga_URL+userinfo.getsessionId()+'&serverUrl='+ partnerUrl+'&QueryId=[SP]'+QuoteHeader+',[SQ]'+SummaryQuote+
                  '?pv0='+contractId+',[TQE]'+QuoteEquipment+'?pv0='+recordId+'&TemplateId='+DetailwithoutTempId+'&AttachmentParentID='+contractId+'&DS7=1&OFN=Detailwithoutpurchase&Id='+recordId.subString(0, 15);
        system.debug('Conga URL...'+congaUrl);
        Message = getCalloutToConga(congaUrl); 
       
         }
          else {
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select the Termination Quote'));
        }
         
    
    }
    
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
        system.debug('Message Body....'+res.getBody());
            return res.getBody();
        }
        
        if(res.getBody()!='')
            return 'Success';
        else
            return 'fail';     
    }
    
}