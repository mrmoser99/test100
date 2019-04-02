public class WaiveFeesChargesUtil {
   
    @Future(callout=true)
    Public static void DistributedTaxCall(String ChargeId)
    {
        
        HttpResponse res;
        Integer responseCode = 0;
        cllease__Charge__c Charge = [select id,name,cllease__Remarks__c,cllease__Lease_Account__r.cllease__First_Payment_Date__c,cllease__Lease_Account__r.cllease__Maturity_Date__c,
		cllease__Lease_Account__c,cllease__Lease_Account__r.cllease__Account__c,cllease__Lease_Account__r.cllease__Account__r.Tax_Exempt__c,
		cllease__Contract_Equipment__r.cllease__Tax_exemption__c,DestinationCity__c,Destinationstate__c,DestinationZipCode__c,
		cllease__Contract_Equipment__r.GARD__c,cllease__Original_Amount__c,cllease__Contract_Equipment__r.Name,
	    cllease__Lease_Account__r.cllease__application_number__c,cllease__Lease_Account__r.cllease__Contract_Date__c From cllease__Charge__c where id =:chargeId limit 1];
        VertexApi__c vertexConfig = CLSCustomUtil.getVertexConfiguration();
        // Logging Vertex Request and Response XML Files
        Vertex_Log__c vertexLog = new Vertex_Log__c();
        // 1. Creating http request for the Due Detail Lines & Do Callout 
        try{
            if(Charge!= NULL){
            Dom.document methoddoc = VertexUtil.getDistributedTaxAdjustmentXml(Charge);
            VertexUtil.validateVertexConfig(vertexConfig);

            ////System.debug(LoggingLevel.ERROR, '=================================');
            System.debug(LoggingLevel.ERROR,'methoddoccc'+methoddoc.toXmlString());
            ////System.debug(LoggingLevel.ERROR, '=================================');
            // 1.a Creating Http Request
                HttpRequest req = new HttpRequest();
                req.setMethod('POST');
                req.setEndpoint(vertexConfig.End_Point__c);
                req.setHeader('Content-Type', 'text/xml');
                req.setBody(methoddoc.toXMlString());

                Http http = new Http();
                // if (actual response ) else (test mock response)
                if(!System.Test.isRunningTest()) {
                    res = http.send(req);
                } else {
                    res = VertexHttpResponseGenerator.vertexAdjustChargeHTTPResponse(Charge);
                    
                }  ////System.debug(LoggingLevel.ERROR, ' Response Code: '+res.getStatusCode());
                responseCode = res.getStatusCode();
                System.debug('responseeee'+res.getBody());
                // Recording Vertex Request XML & Response XML
                if(!System.Test.isRunningTest() && vertexConfig.Enable_Vertex_Xml_Logging__c) {
                    vertexLog.Request_XML__c  = methoddoc.toXMlString();
                    vertexLog.Response_XML__c = res.getBody();
                }
                if(responseCode == 200) {
                // Process Successful Response
                Dom.Document responseDom = new Dom.Document();
                responseDom.load(res.getbody());
                DOM.XMLNode root = responseDom.getRootElement();
                }

            } else {
                // incase of no valid Due Detail Lines, throw exception to check valid address linked.
                throw new CLSCustomException('Address (City/State/Zipcode) is not valid. Skipping Vertex Tax Computation...');
            
            }        
            
        }catch(Exception e) {
            // A. Insert batch process log for exceptions
            insert new cllease__Batch_Process_Log__c(Name='DistributedTaxAdjustment: ',
            cllease__Date__c=system.today(), cllease__Message__c='Error is '+e.getmessage()
            +' in line number: '+ e.getlinenumber());

            // B. Updating All DueDetails lines for failure
                charge.cllease__Remarks__c = 'Distributed tax failed. Please Check Batch log for more details';
        }finally {
            // Logging the Distributed tax Request
            if(!System.Test.isRunningTest() && vertexConfig.Enable_Vertex_Xml_Logging__c
                && vertexLog.Request_XML__c != null && vertexLog.Response_XML__c != null) {
                vertexLog.Contract_Names__c = Charge.Name;
                vertexLog.Category__c = 'CHARGE-VERTEX TAX ADJUSTMENT CALL';
                insert vertexLog;
            }
            
             
        }
                
    }     
    public static void reverseGLAccountEntries()
    {
        
    }   
    public static void paymentReversal(cllease__Charge__c  reversePay)
    {
        List<cllease__Fee_Payment__c> feepay = [select id,name,cllease__Charge__c,cllease__Transaction_Amount__c,cllease__Lease_Payment_Transaction__r.name,cllease__Transaction_Date__c from cllease__Fee_Payment__c where cllease__Charge__c =: reversePay.id ];
        // reverse payment transaction: cllease__Repayment_Transaction_Adjustment__c
        List<cllease__Repayment_Transaction_Adjustment__c> updaterevTrans = new List<cllease__Repayment_Transaction_Adjustment__c>();
        
        for(cllease__Fee_Payment__c fPay:feepay){
        cllease__Repayment_Transaction_Adjustment__c revTrans = new cllease__Repayment_Transaction_Adjustment__c();
        revTrans.cllease__LS_Contract__c= reversePay.cllease__Lease_Account__c;
        revTrans.cllease__Lease_Payment_Transaction__c=fPay.cllease__Lease_Payment_Transaction__r.name;
        revTrans.cllease__Adjusted_Amount__c=fpay.cllease__Transaction_Amount__c;
        revTrans.cllease__Cleared__c=true;
        revTrans.cllease__Reason_Code__c='Human Error';
        updaterevTrans.add(revTrans);
        
        }
        
        insert updaterevTrans;
        
    }
       
}