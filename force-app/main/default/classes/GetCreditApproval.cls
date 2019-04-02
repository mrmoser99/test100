/**
 *  Author: Cloud Lending Solutions
 *  Summary: Following webservice helps in sending the Quick Quote details 
 *           to DLL-ATS system for credit check
 *
 *  Change Log:
 *  8/29/18 - MRM Added call to ICV if credit engine is ICV
 **/
global class GetCreditApproval {

    /** 
     * Following webservice will be called from Credit Approval page "Submit for Approval" 
     * to send the request to DLL-ATS for credit approval details.
     **/
    webservice static String func_getcreditapproval(genesis__Quick_Quotes__c Cred_App_obj){
        System.debug('!!! Cred_App_obj: '+Cred_App_obj);
        /**** ICS CREDIT ENGINE CALL ********/
        if (System.Label.Credit_Engine == 'ICS'){	 
        	ICSUtility.score(Cred_App_obj,'Score',null);	   
            return 'Credit Application Submitted!';
        }
        /************* END OF ICS CREDIT CALL *****************/
        /* temp to allow fortimize to continiue */
       // return 'Credit Application Submitted!';
        // result message 
        String responseMsg;
        cllease__Batch_Process_Log__c log;
        String message;
        //Savepoint sp = database.setsavepoint();
        try {
            System.debug(LoggingLevel.ERROR, ' Starting the Credit Details Sending to DLL-ATS...');
            //getting credit approval record details
            genesis__Quick_Quotes__c creditApproval = [SELECT Id, Name,
                                                            genesis__Business_Name__c, 
                                                            Estimated_Financed_Amount__c,
                                                            Estimated_Monthly_Payment__c,
                                                            genesis__Address_Line_1__c,
                                                            genesis__City__c,
                                                            genesis__State__c,
                                                            genesis__Postal_Code__c,
                                                            Primary_Phone_number__c ,
                                                            Dealer__r.ATS_ID__c
                                                        FROM genesis__Quick_Quotes__c 
                                                        WHERE Id = :Cred_App_obj.Id];
            
            //to store the auth token received from first call        
            String token_str;
            //to store the credit approval record number
            String cred_app_num = creditApproval.name;
            //to store the dealer id, need to have field on Credit Approval record
            String dealer_id    = (creditApproval.Dealer__r.ATS_ID__c != null ? creditApproval.Dealer__r.ATS_ID__c : 'Y318');

            //to store the Business legal name, address details, need to have fields on Credit Approval record
            String addr_line1   = creditApproval.genesis__Address_Line_1__c;
            String legal_name   = creditApproval.genesis__Business_Name__c;
            String city         = creditApproval.genesis__City__c;
            String state        = creditApproval.genesis__State__c;
            String postalCode   = creditApproval.genesis__Postal_Code__c;
            String phoneNum     = creditApproval.Primary_Phone_number__c;

            //getting custom setting values for ATS integration
            ATS_Integration_setup__c ATS_cust_set = ATS_Integration_setup__c.getinstance();

            //getting local transmission datetime
            String trans_time = system.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');            
            Decimal est_financed_amount = Decimal.valueOf(creditApproval.Estimated_Financed_Amount__c);            
            Decimal estimatedMonthlyPayment = creditApproval.Estimated_Monthly_Payment__c;            
            
            httpresponse res = new HttpResponse();
            
            if(!system.Test.isrunningtest())
                res = get_token();         
            else{
                //set response for test method
                //access token and refreshtoken values for test methods
                String accessToken = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJbaW52YWxpZCBmaWVsZF0iLCJzY3AiOiJjcmVhdGVfYW5kX21hbmFnZV9maW5hbmNpYWxfY29udHJhY3RzIiwidmVyIjoiMS4wIiwiaXNzIjoiZXh0ZXJuYWxnYXRld2F5LmRsbC5jb3JwIiwib2lkIjoiW2ludmFsaWQgZmllbGRdIiwiZ2l2ZW5fbmFtZSI6Ik5vIExEQVAiLCJ0aWQiOiJbaW52YWxpZCBmaWVsZF0iLCJhdWQiOiJbaW52YWxpZCBmaWVsZF0iLCJhY3IiOiIxIiwidXBuIjoiTm8gTERBUCIsInVuaXF1ZV9uYW1lIjoiTm8gTERBUCIsIm5iZiI6MTUxODM1MTA1MywiYXBwaWRhY3IiOiIwIiwiYXBwaWQiOiJkYWJiNzAyZC1jNTlhLTQ5YTMtOTMwZi1iZjc1Zjg5NWYwYjQiLCJleHAiOjE1MTg5NTU4NTMsImlhdCI6MTUxODM1MTA1MywiZmFtaWx5X25hbWUiOiJObyBMREFQIn0.erqVtqqUdzIfnwBAJ_b-eYzun0ahJCCtM3NAwJV_bv5Yd1qP7lhSMsDxVtPupGYGfLgc0DlyIAJrRaMlJ1OxSTL1SbNoJZjeF0Z-W60JywnjdGsPP-mg-ARyPN0jKL0whcehfE6PjAkEfjW8_HkzFAZ6qn1ls-rhTvmyQQIto-hJcZ7VQAyQs8k6YjYIw42iEB-TBDzjuPiYV5_dftEDMdCr5apCUZoZAaOWGg6Y-7NZoahWEcVASvQtW7QkrOGGrhAp9ZXLoKBav-GLJWUDP-gfyxzl7hqAhzZQgTWtHw9xvE-a_s6i-5NAoJeTwRbG3NuB0blsvD9Q9noc0FDLhw';
                String refreshToken = '3pd4KvkxkV51l5T9lCQGDlJnqsstack8M8oItEZFUK6p5y';
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"access_token": '+ accessToken +
                ',"token_type": "Bearer", "expires_in": "604800","expires_on": "1518955853","resource": "DLL corp","refresh_token": '+
                refreshToken +',"scope": '+ATS_cust_set.Scope_for_token_call__c+'}');
                res.setStatusCode(200);
            }   
            
            // processing the initial Request for access token
            JSONParser parser = JSON.createParser(res.getBody());
            
            while (parser.nextToken() != null) {
                if (parser.getCurrentName() == 'access_token') {
                    token_str = parser.getText();
                    system.debug(parser.getText());
                }
            }
            
            // Sending 2nd Request to pass the actual quick quote details for approval
            HttpRequest reqAPI = new HttpRequest();
            
            //need to populate the Dealer ID, once finalized
            reqAPI.setEndpoint(ATS_cust_set.Endpoint_for_ATS_call__c+cred_app_num+':'+ATS_cust_set.sandbox_name__c+'?dealerId='+dealer_id);
            reqAPI.setMethod('POST');        
            reqAPI.setHeader('Authorization', 'Bearer '+token_str);
            reqAPI.setHeader('content-type', 'application/json');
            reqAPI.setHeader('Accept', 'application/json');
            
        
            //need to pass values from credit approval record here
            ATS_util.address address    = new ATS_util.address(addr_line1,city,state,postalCode);
            //need to pass phone number from credit approval record here
            ATS_util.lessee lessee      = new ATS_util.lessee(legal_name,phoneNum,address);                
            List<ATS_util.cost> costs   = new List<ATS_util.cost>();
            costs.add(new ATS_util.cost('EQUIPMENT',est_financed_amount));
            
            List<ATS_util.asset> assets = new List<ATS_util.asset>();
            assets.add(new ATS_util.asset('Office Equipment',1,'N/A',costs));
            
            ATS_util.structure structure = new ATS_util.structure('FAIRMARKETVALUE',60,'MONTHLY', est_financed_amount , 0.0307,estimatedMonthlyPayment);
            
            JSONGenerator gen = JSON.createGenerator(true);
            // Write data to the JSON String.
            gen.writeStartObject();
            
            gen.writeStringField('localTransmissionDate', trans_time);
            gen.writeStringField('partnerOrderId', cred_app_num+':'+ATS_cust_set.sandbox_name__c);

            gen.writeStringField('contactEmail', ATS_cust_set.Email_service_alias__c);
            
            gen.writeFieldName('lessee');        
            gen.writeObject(lessee);            

            gen.writeFieldName('assets');        
            gen.writeObject(assets);
            
            gen.writeFieldName('structure');        
            gen.writeObject(structure);
    
            gen.writeEndObject();
            
            // Get the JSON String.
            String json_req = gen.getAsString();
        
            system.debug(json_req);            
            reqAPI.setBody(json_req);                  
           
            HTTPResponse res1 = new HTTPResponse();
           
            if(!system.Test.isrunningtest())
                res1 = get_response(reqAPI);
            else{
                //setting response for testmethods
                res1.setHeader('Content-Type', 'application/json');
                res1.setBody('{"id": "5dfc1a9e-4cb3-4dd0-8c1e-6aa514048f5d","title": "success","message": "Credit application successfully received for partnerOrderId: bd8df8c2-815e-400b-ba4d-0a7fd4f14014"}');
                res1.setStatusCode(200);
            }
            
            System.debug(res1.getBody());
            JSONParser parser2 = JSON.createParser(res1.getBody());
            
            while (parser2.nextToken() != null) {                
                if (parser2.getCurrentName() == 'message' && parser2.getText().contains('success')) {
                    responseMsg = parser2.getText();
                    system.debug(parser2.getText());
                }
                
                if (parser2.getCurrentName() == 'message' && parser2.getText().contains('error')) {
                    parser2.nextToken();
                    parser2.nextToken();
                    parser2.nextToken();
                    responseMsg = parser2.getText();
                    system.debug(parser2.getText());
                }
            }
            
            if(responseMsg.contains('success')) {
                creditApproval.genesis__Status__c = 'CREDIT SUBMITTED';
                update creditApproval;
            }
            message = 'Credit Approval: '+ creditApproval.Name +' Submitted Successful...';
            System.debug(LoggingLevel.ERROR, ' Ending the Credit Details Sending to DLL-ATS...');

        } catch(exception e){
            //database.rollback(sp);   
            System.debug(LoggingLevel.ERROR, 'GetCreditApproval Exception: '+e.getMessage());    
            System.debug(LoggingLevel.ERROR, 'GetCreditApproval Exception Stack: '+e.getStackTraceString());      
            //insert batch process log for exceptions
            message = 'Credit Approval:'+Cred_App_obj.Name+' failed with error: '
                    + e.getmessage() +' in line number: '+ e.getlinenumber();
            responseMsg = 'Exception in Credit check request, error is: '+ e.getmessage();
        } finally {
            insert new cllease__Batch_Process_Log__c(Name='GetCreditApproval ',
            cllease__Date__c=System.today(), cllease__Message__c = message+' time: '+System.now());
        }
        return responseMsg;
    }
     

    public static HttpResponse get_token(){    
        ATS_Integration_setup__c ATS_cust_set = ATS_Integration_setup__c.getinstance();
        HttpRequest req_token = new HttpRequest();        
        req_token.setEndpoint(ATS_cust_set.Endpoint_for_Token__c);
        req_token.setMethod('POST');        
        req_token.setHeader('content-type', 'application/x-www-form-urlencoded');
        req_token.setHeader('cache-control', 'no-cache');        
        req_token.setBody('client_id='+ATS_cust_set.client_id__c+'&client_secret='+ATS_cust_set.client_secret__c+'&grant_type=client_credentials&scope='+ATS_cust_set.Scope_for_token_call__c);
      
        Http http = new Http();
        HTTPResponse res = http.send(req_token);
        System.debug(res.getBody());
        return res;
    }
    
    public static HttpResponse get_response(httprequest reqAPI){    
        Http http1 = new Http();
        HTTPResponse res = http1.send(reqAPI);            
        return res;
    }
    
}