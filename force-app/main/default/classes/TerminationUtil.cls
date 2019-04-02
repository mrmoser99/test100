/**
 * Author: Cloud Lending Solutions
 * Description: Following has utilities for Termination Quote Processes.
 **/
public class TerminationUtil {

    @Future(callout=true)
    public static void updateVertexTax(String quoteHeaderId) {

        // Retrieving the Quote details with equipment Quote
        cllease__Termination_Quote_Header__c quoteHeader = [SELECT Id, Name, cllease__Contract__r.Name,
                                                                    cllease__Contract__r.cllease__First_Payment_Date__c,
                                                                    cllease__Contract__r.cllease__Maturity_Date__c,
                                                                (SELECT Id, Name,
                                                                    cllease__Amount__c,
                                                                    cllease__Line_Type__c,
                                                                    cllease__Add_To_Quote_Amount__c,
                                                                    cllease__Amount_Type__c
                                                                FROM cllease__Termination_Quote_Lines__r),
                                                                (SELECT Id, Name,
                                                                    Amount__c,
                                                                    Tax_Exempt__c,
                                                                    Termination_Quote_Line__c,
                                                                    Termination_Quote_Line__r.cllease__Amount__c,
                                                                    Termination_Quote_Line__r.cllease__Line_Type__c,
                                                                    Termination_Quote_Line__r.cllease__Add_To_Quote_Amount__c,
                                                                    Termination_Quote_Equipment__c,
                                                                    Termination_Quote_Equipment__r.cllease__Contract_Equipment__r.Name,
                                                                    DestinationCity__c,
                                                                    DestinationCounty__c,
                                                                    DestinationState__c,
                                                                    DestinationZipCode__c
                                                                FROM Termination_Equipment_Quotes__r )
                                                            FROM cllease__Termination_Quote_Header__c
                                                            WHERE Id = :quoteHeaderId];
        
        // Limitation: Currently This trigger handles quote line tax calculation for single quote at a time
        getTerminationQuoteTax(quoteHeader);

    }
    
    /**
     * Following method helps in Calculating the Tax for Termination Quote
     **/
    public static void getTerminationQuoteTax(cllease__Termination_Quote_Header__c quoteHeader) {

        VertexApi__c vertexConfig = CLSCustomUtil.getVertexConfiguration();
        Vertex_Log__c vertexLog = new Vertex_Log__c();
        cllease__Termination_Quote_Line__c vertexTaxQuoteLine;

        HttpResponse res;
        Integer responseCode = 0; 
        try {

            // Getting Termination Quote Field API Map
            Set<String> terminationQuoteLinesTypes = VertexUtil.terminationDueDetailLineFieldAPIMap.keySet();

            // Validation on Quote Lines
            // 2. Create XML Request
            Map<String, Termination_Equipment_Quote__c> quoteLinesToProcessForTaxMap = new Map<String, Termination_Equipment_Quote__c>();
            Map<String, Termination_Equipment_Quote__c> quoteLinesMap = new Map<String, Termination_Equipment_Quote__c>();
            
            for(Termination_Equipment_Quote__c eqpQuoteLine : quoteHeader.Termination_Equipment_Quotes__r) {
                if(eqpQuoteLine.Termination_Quote_Line__r.cllease__Line_Type__c == DLLNewCoConstants.QUOTE_ESTIMATED_SALES_TAX) {
                    vertexTaxQuoteLine = new cllease__Termination_Quote_Line__c(Id = eqpQuoteLine.Termination_Quote_Line__c);
                } else if(terminationQuoteLinesTypes.contains(eqpQuoteLine.Termination_Quote_Line__r.cllease__Line_Type__c)) {
                    quoteLinesToProcessForTaxMap.put(eqpQuoteLine.Name, eqpQuoteLine);
                    quoteLinesMap.put(eqpQuoteLine.Termination_Quote_Line__r.cllease__Line_Type__c, eqpQuoteLine);
                }
            }
            System.debug(LoggingLevel.ERROR, '--- quoteLinesToProcessForTaxMap: '+quoteLinesToProcessForTaxMap.values());

            // 3. Send HTTP Rquest 
            Dom.document methoddoc = VertexUtil.getTerminationQuoteReqXml(quoteHeader, quoteLinesToProcessForTaxMap.values());
            System.debug(LoggingLevel.ERROR, '=================================');
            System.debug(LoggingLevel.ERROR,'request: '+methoddoc.toXmlString());
            System.debug(LoggingLevel.ERROR, '=================================');

            // B.1 Creating Http Request
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
                //res = VertexHttpResponseGenerator.vertexBillHTTPResponse(dueDetailLines);
            }
            System.debug(LoggingLevel.ERROR, ' Response Code: '+res.getStatusCode());
            responseCode = res.getStatusCode();

            // Recording Vertex Request XML & Response XML
            if(!System.Test.isRunningTest() && vertexConfig.Enable_Vertex_Xml_Logging__c) {
                vertexLog.Request_XML__c  = methoddoc.toXMlString();
                vertexLog.Response_XML__c = res.getBody();
            }
        } catch(Exception e) {
            // A. Insert batch process log for exceptions
            insert new cllease__Batch_Process_Log__c(Name='Termination Quote Request: ', cllease__Date__c=system.today(), 
            cllease__Message__c='Error is '+e.getmessage() +' in line number: '+ e.getlinenumber());
            // C. Skip the process in case of any exception during initial Callout Exception
            return; 

        } finally {
            // Logging the Vertex Request
            if(!System.Test.isRunningTest() && vertexConfig.Enable_Vertex_Xml_Logging__c
                && vertexLog.Request_XML__c != null && vertexLog.Response_XML__c != null) {
                vertexLog.Contract_Names__c = CLSCustomUtil.getStringsFromList(new List<String> {quoteHeader.cllease__Contract__r.Name});
                vertexLog.Category__c = 'TERMINATION QUOTE-VERTEX TAX CALL';
                insert vertexLog;
            }
        }

        // 2. Processing Vertex Response SOAP only incase No HTTP Failures from 1.
        Savepoint sp = Database.setsavepoint();
        try {
            // Process Successful Response
            Dom.Document responseDom = new Dom.Document();
            responseDom.load(res.getbody());

            System.debug(LoggingLevel.ERROR, '=================================');
            System.debug(LoggingLevel.ERROR,'response: '+responseDom.toXmlString());
            System.debug(LoggingLevel.ERROR, '=================================');

            // Processing Vertex Response SOAP
            if(responseCode == 200) {
                DOM.XMLNode root = responseDom.getRootElement();
                Boolean foundProduct = false, foundTotalTax = false;
                String lineType; 
                Decimal taxAmount = 0;
                // 4. Process the response and update the tax amounts in Quote Line.
                for(Dom.XMLNode soapBodyChild : root.getChildren()) {
                    //System.debug(LoggingLevel.ERROR, ' processing node: '+soapBodyChild.getName());
                    if(soapBodyChild.getName() == 'Body') {
                        for(Dom.XMLNode vertexEnvelope : soapBodyChild.getChildren()) {
                            if(vertexEnvelope.getName() == 'VertexEnvelope') {
                                System.debug(LoggingLevel.ERROR, ' inside processing vertexEnvelope');
                                // Process the Vertex Envelope
                                for(DOM.XMLNode child1 : vertexEnvelope.getChildren()) {
                                    if(child1.getName() == 'QuotationResponse') {
                                        System.debug(LoggingLevel.ERROR, ' inside processing QuotationResponse');
                                        /*for(DOM.XMLNode child2 :child1.getChildren()) {
                                            // Resetting the flag for each item iteration
                                            //foundProduct = false;
                                            foundTotalTax = false;
                                            if(child2.getName() == 'LineItem') {
                                                for(DOM.XMLNode child3 :child2.getChildren()) {
                                                    // Check for Product and Tax Amounts from Node.

                                                    if(child3.getName() == 'TotalTax') {
                                                        taxAmount = Decimal.valueOf(child3.getText());

                                                        //foundTotalTax = true;
                                                    }
                                                }
                                            }

                                        }*/

                                        // Getting Total Estimated Tax for Quote level
                                        for(DOM.XMLNode child2 :child1.getChildren()) {
                                            if(child2.getName() == 'TotalTax') {
                                                taxAmount = Decimal.valueOf(child2.getText());
                                                //foundTotalTax = true;
                                            }
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                } 

                System.debug(LoggingLevel.ERROR, ' Updated Vertex QUoteline record:taxAmount  '+taxAmount);
                // Updating the Tax Amount in VERTEX TAX quote line
                vertexTaxQuoteLine.cllease__Amount__c =  taxAmount;
                update vertexTaxQuoteLine;

                 // Updating the Termination Quote Amount
                Decimal totalAmount = 0;

                // adding Tax Value 
                totalAmount = taxAmount;
                // Update the QUote Header value including the Tax Value
                for(cllease__Termination_Quote_Line__c eqpQuoteLine : quoteHeader.cllease__Termination_Quote_Lines__r) {
                    if(eqpQuoteLine.cllease__Add_To_Quote_Amount__c || eqpQuoteLine.cllease__Amount_Type__c == 'FEE' ) {
                        totalAmount += eqpQuoteLine.cllease__Amount__c;
                    }
                }

                quoteHeader.cllease__Quote_Amount__c = totalAmount;
                update quoteHeader;


                // ReSetting Vertex calculated flag = false after processing
                TerminationUtil.updateQuoteVertexFlag(quoteHeader.Id, false);

            } else if(responseCode == 500){
                // Process the response for Error message
                responseDom.load(res.getbody());
                DOM.XMLNode root = responseDom.getRootElement();
                for(Dom.XMLNode soapBodyChild : root.getChildren()) {
                    System.debug(LoggingLevel.ERROR, ' processing node: '+soapBodyChild.getName());
                    if(soapBodyChild.getName() == 'Body') {
                        for(Dom.XMLNode fault : soapBodyChild.getChildren()) {
                            if(fault.getName() == 'Fault') {
                                for(Dom.XMLNode faultString : fault.getChildren()) {
                                    if(faultString.getName() == 'faultstring') {
                                        throw new CLSCustomException(faultString.getText().trim());
                                    }
                                }
                            }
                        }
                    }
                }

            } else {
                // For any other responses apart from 200, 500
                throw new CLSCustomException('Unknown Vertex API Response Code: '+responseCode +' Please check with Vertex.');
            
            }
            
        } catch(exception e){           
            Database.rollback(sp);   
            insert new cllease__Batch_Process_Log__c(Name='Termination Quote Request: ', cllease__Date__c=system.today(), 
            cllease__Message__c='Error is '+e.getmessage() +' in line number: '+ e.getlinenumber());
       }  

    }


    /**
     * Following method helps in Creating Termination Equipment Quotes
     **/
    public static void createTerminationEqpQuoteObjects(String terminationQuoteId) {

        System.debug(LoggingLevel.ERROR, 'Started Processing the Termination Equipment Quote Creation...');
        
        // 1. Query Existing TEmination Quote Equipment Quote Junction Objects
        String query = ' SELECT Id, Name, cllease__Contract__c, Quote_Vertex_Call_Completed__c, ' +
                        '   (SELECT Id, cllease__Contract_Equipment__c, cllease__Contract_Equipment__r.cllease__Estimated_Selling_Price__c FROM cllease__Termination_Quote_Equipments__r ), ' +
                        '   (SELECT Id, cllease__Amount__c, cllease__Add_To_Quote_Amount__c, cllease__Line_Type__c FROM cllease__Termination_Quote_Lines__r ), ' +
                        '   (SELECT Id FROM Termination_Equipment_Quotes__r ) ' +
                        ' FROM cllease__Termination_Quote_Header__c ' +
                        ' WHERE ID =: terminationQuoteId ';

        System.debug(LoggingLevel.ERROR, ' Query on TerminationUtil: '+query);

        List<cllease__Termination_Quote_Header__c> quoteHeaders = Database.query(query);  
        cllease__Termination_Quote_Header__c quoteHeader;
        List<Termination_Equipment_Quote__c> eqpQuoteLines;

        if(quoteHeaders.size() > 1 || quoteHeaders.size() == 0) {
            throw new CLSCustomException('Invalid no of Termination Quotes created...');
        }       

        quoteHeader = quoteHeaders.get(0);

        // Skipping the process incase 
        /*if(quoteHeader.Quote_Vertex_Call_Completed__c) {
            return;
        }*/

        System.debug(LoggingLevel.ERROR, ' quoteHeader eqps: '+quoteHeader.cllease__Termination_Quote_Equipments__r);
        System.debug(LoggingLevel.ERROR, ' quoteHeader lines: '+quoteHeader.cllease__Termination_Quote_Lines__r);
        
        // Delete existing termination Equipmennt Quotes and create new ones for changed amounts
        if(quoteHeader != null && quoteHeader.Termination_Equipment_Quotes__r != null) {
            delete quoteHeader.Termination_Equipment_Quotes__r;
        }
        
        // Calculate Prorated amounts for Termination Equipment Quotes and calculate tax per Equipment level in Termination.

        Decimal totalEquipmentCost = 0;
        for(cllease__Termination_Quote_Equipment__c quoteEqp : quoteHeader.cllease__Termination_Quote_Equipments__r) {
            totalEquipmentCost += quoteEqp.cllease__Contract_Equipment__r.cllease__Estimated_Selling_Price__c;
        }

        System.debug(LoggingLevel.ERROR, ' totalEquipmentCost: '+totalEquipmentCost);
        
        // 2. Calculate the Proration for each Equipments for amount split up for Contract Level
        String contractId = quoteHeader.cllease__Contract__c;
        
        // Create Map of Payment Streams of FEES type with Equipments
        AggregateResult[] unEarnedChargesList = [SELECT sum(cllease__Rental_Amount__c) unbilledCharge, cllease__Contract_Equipment__c equipId
                                                    FROM  cllease__Payment_Stream__c
                                                    WHERE cllease__Payment_Type__c = 'FEES' 
                                                       AND cllease__Contract__c = :contractId
                                                       AND cllease__Contract_Equipment__c != null
                                                       AND cllease__Active__c = true
                                                       AND cllease__Billed__c = false
                                                    GROUP BY cllease__Contract_Equipment__c];

        Map<Id, Decimal> eqpToUnbilledChargesMap = new Map<Id, Decimal>();
        Decimal totalQuoteServiceAmount = 0;

        for (AggregateResult r : unEarnedChargesList) {
            Decimal amount  = (Decimal)r.get('unbilledCharge');
            Id eqpId    = (Id)r.get('equipId');
            eqpToUnbilledChargesMap.put(eqpId, amount);
            totalQuoteServiceAmount += amount;
        }

        System.debug(LoggingLevel.ERROR, ' totalQuoteServiceAmount: '+totalQuoteServiceAmount);

        System.debug(LoggingLevel.ERROR, ' eqpToUnbilledChargesMap: '+eqpToUnbilledChargesMap);

        cllease__Termination_Quote_Line__c serviceQuoteLine;

        // Create Termination Equipment Quotes
        if(quoteHeader != null) {
            
            eqpQuoteLines = new List<Termination_Equipment_Quote__c>();
            // Looping through QUote Equipments
            for(cllease__Termination_Quote_Equipment__c quoteEqp : quoteHeader.cllease__Termination_Quote_Equipments__r) {
                Decimal prorated = (quoteEqp.cllease__Contract_Equipment__r.cllease__Estimated_Selling_Price__c) / totalEquipmentCost;
                // Looping through Quote Lines
                for(cllease__Termination_Quote_Line__c quoteLine : quoteHeader.cllease__Termination_Quote_Lines__r) {
                    System.debug(LoggingLevel.ERROR, ' processing quote Line '+ quoteLine.cllease__Line_Type__c);
                    // Creating junction object
                    Termination_Equipment_Quote__c termEqpQuote = new Termination_Equipment_Quote__c(Termination_Quote__c = quoteHeader.Id,
                                                                            Termination_Quote_Equipment__c = quoteEqp.Id,
                                                                            Termination_Quote_Line__c = quoteLine.Id);

                    if(quoteLine.cllease__Line_Type__c == 'QUOTE SERVICE AND MAINTENANCE') {
                        serviceQuoteLine = new cllease__Termination_Quote_Line__c(Id = quoteLine.Id);
                        termEqpQuote.Amount__c = (Decimal)eqpToUnbilledChargesMap.get(quoteEqp.cllease__Contract_Equipment__c);
                    } else {
                        Decimal amountSplit = prorated * quoteLine.cllease__Amount__c;
                        termEqpQuote.Amount__c = amountSplit;
                    }
                    eqpQuoteLines.add(termEqpQuote);
                }
            }
            
        }

        // Updating the Service & Estimate Quote amount.
        serviceQuoteLine.cllease__Amount__c = totalQuoteServiceAmount;

        update serviceQuoteLine;

        System.debug(LoggingLevel.ERROR, ' Equipment Quote lines created: '+eqpQuoteLines);
        // 2. If no records available, create new records for Equipments and Quotes and return.
        insert eqpQuoteLines;
    }

    /**
     * Following method helps in updating Vertex Calculated flag in QUote Header
     **/
    public static void updateQuoteVertexFlag(String quoteHeaderId, Boolean vertexFlag) {
        cllease__Termination_Quote_Header__c quoteHeader = [SELECT Id, Name, Quote_Vertex_Call_Completed__c
                                                            FROM cllease__Termination_Quote_Header__c
                                                            WHERE Id = :quoteHeaderId];

        // updatign the flag // if true: vertex calculation is completed , false : not completed.
        quoteHeader.Quote_Vertex_Call_Completed__c = (vertexFlag != null ? vertexFlag : false);
        System.debug(LoggingLevel.ERROR, ' Checking for update value; '+quoteHeader.Quote_Vertex_Call_Completed__c);
        update quoteHeader;
    }

    /**
     * Following method the value of Vertex Calculated flag from QUote Header
     **/
    public static Boolean getQuoteVertexFlag(String quoteHeaderId) {
        cllease__Termination_Quote_Header__c quoteHeader = [SELECT Id, Name, Quote_Vertex_Call_Completed__c
                                                            FROM cllease__Termination_Quote_Header__c
                                                            WHERE Id = :quoteHeaderId];

        return (quoteHeader.Quote_Vertex_Call_Completed__c != null ? quoteHeader.Quote_Vertex_Call_Completed__c : false);
    }

}