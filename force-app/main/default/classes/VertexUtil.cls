/**get
 * Author: Cloud Lending Solutions
 * Description: Following has utilities for vertex callouts
 **/
public class VertexUtil {

   // Default Hardcoded Values for Vertex Rest API Calls
    private static String transCodev        = 'INV';
    private static String upfronttransCodev = 'ORIG';
    private static String contrTypev        = 'FMV';
    //private static String upfrontcontrTypev='CSC';
    private static String taxPmtTypev= '';
    private static String dtaxPmtTypev= 'ST';
    private static String UpfronttaxPmtTypev= '';
    private static String leaseTypev        = 'A';
    //private static String upfrontleaseTypev = 'D';
    private static String titleTxfrv = 'I';        
    private static String taxBasisv  = 'N/A';
    //private static String upfronttaxBasisv  = 'Stream' ;
    private static String intDisclv  = 'N';            
    private static String vendPaidv  = 'N';            
    private static String alevTrue   = 'T';
    private static String alevFalse  = 'F';           
    private static String slbc       = 'F';            
    private static String reqReasonv = 'BILLING';
    private static String upfrontreqReasonv = 'BOOKING';
    private static String upTaxAmtv  = '0';            
    private static String cumulTaxv  = '0';            
    private static String slbPaidv   = '0';            
    private static String qtpCodev   = '0';            
    private static String qrsCodev   = '0';

    public static Map<String, String> taxValueFieldJurisdictionMap = new Map<String, String>{
        'APO'                           => 'Tax_APO__c',
        'BOROUGH'                       => 'Tax_BOROUGH__c',
        'CITY'                          => 'Tax_CITY__c',
        'COUNTRY'                       => 'Tax_COUNTRY__c',
        'COUNTY'                        => 'Tax_COUNTY__c',
        'DISTRICT'                      => 'Tax_DISTRICT__c',
        'FPO'                           => 'Tax_FPO__c',
        'LOCAL_IMPROVEMENT_DISTRICT'    => 'Tax_LOCAL_IMPROVEMENT_DISTRICT__c',
        'PARISH'                        => 'Tax_PARISH__c',
        'PROVINCE'                      => 'Tax_PROVINCE__c',
        'SPECIAL_PURPOSE_DISTRICT'      => 'Tax_SPECIAL_PURPOSE_DISTRICT__c',
        'STATE'                         => 'Tax_STATE__c',
        'TERRITORY'                     => 'Tax_TERRITORY__c',
        'TOWNSHIP'                      => 'Tax_TOWNSHIP__c',
        'TRADE_BLOCK'                   => 'Tax_TRADE_BLOCK__c',
        'TRANSIT_DISTRICT'              => 'Tax_TRANSIT_DISTRICT__c'
    };

    public static Map<String, String>  taxRateFieldJurisdictionMap = new Map<String, String>{
        'APO'                           => 'Tax_Rate_APO__c',
        'BOROUGH'                       => 'Tax_Rate_BOROUGH__c',
        'CITY'                          => 'Tax_Rate_CITY__c',
        'COUNTRY'                       => 'Tax_Rate_COUNTRY__c',
        'COUNTY'                        => 'Tax_Rate_COUNTY__c',
        'DISTRICT'                      => 'Tax_Rate_DISTRICT__c',
        'FPO'                           => 'Tax_Rate_FPO__c',
        'LOCAL_IMPROVEMENT_DISTRICT'    => 'Tax_Rate_LOCAL_IMPROVEMENT_DISTRICT__c',
        'PARISH'                        => 'Tax_Rate_PARISH__c',
        'PROVINCE'                      => 'Tax_Rate_PROVINCE__c',
        'SPECIAL_PURPOSE_DISTRICT'      => 'Tax_Rate_SPECIAL_PURPOSE_DISTRICT__c',
        'STATE'                         => 'Tax_Rate_STATE__c',
        'TERRITORY'                     => 'Tax_Rate_TERRITORY__c',
        'TOWNSHIP'                      => 'Tax_Rate_TOWNSHIP__c',
        'TRADE_BLOCK'                   => 'Tax_Rate_TRADE_BLOCK__c',
        'TRANSIT_DISTRICT'              => 'Tax_Rate_TRANSIT_DISTRICT__c'
    };

    public static Map<String, String> terminationDueDetailLineFieldAPIMap = new Map<String, String> {
        'QUOTE DISCOUNT'               =>       'Quote_Discount__c'                  ,
        'QUOTE PURCHASE AMOUNT'        =>       'Quote_Purchase_Amount__c'           ,
        'QUOTE PURCHASE PREMIUM AMOUNT'=>       'Quote_Purchase_Premium_Amount__c'   ,
        'QUOTE ROLLOVER INCENTIVE'     =>       'Quote_Rollover_Incentive__c'        ,
        'QUOTE SERVICE AND MAINTENANCE'=>       'Quote_Service_and_Maintainence__c'  ,
        'QUOTE UNBILLED RECEIVABLE'    =>       'Quote_Unbilled_Receivable__c'       

    };

    /**
     * Following method helps in forming xml for DueDetail Lines
     * if ( Bill type = Termination bill type, xml will be created for all quote types
     *  else it runs for all 
     **/
    public static Dom.Document getBillsXml(List<cllease__Due_Detail_Lines__c> dueDetailLines) {
           
        // Getting Vertex API Configuration from customerom settings & Validating
        VertexApi__c vertexConfig = CLSCustomUtil.getVertexConfiguration();
        validateVertexConfig(vertexConfig);

        System.debug(LoggingLevel.ERROR, ' Vertex Configuration: ' + vertexConfig);        

        String soapNS  = (vertexConfig.soapNS__c != null ? vertexConfig.soapNS__c : 'http://schemas.xmlsoap.org/soap/envelope/');
        String xsi     = (vertexConfig.XSI__c != null ? vertexConfig.XSI__c : 'urn:vertexinc:o-series:tps:8:0');

        DateTime currentSystemDate  =   cllease.SystemDateUtil.getCurrentSystemDate();
        String currentSystemDateStr =   formatDate(currentSystemDate);
        
            
        //Creating XML Formation Starts here
        String ApplNumber, contractDate, contractTerm, contractType, transactionCode, taxPaymentType; 
        String dueAmount, assetNumber, lineItemId;

        // Creating DOM for XML
        Dom.Document scdoc = new Dom.Document();
        Dom.XmlNode envelope = scdoc.createRootElement('Envelope', soapNS, 'soapenv');
        envelope.setNamespace('urn', xsi);
        
        Dom.XmlNode header = envelope.addChildElement('Header', soapNS, null);
        
        Dom.XmlNode body = envelope.addChildElement('Body', soapNS, null);
        Dom.XmlNode vertexEnvelope = body.addChildElement('urn:VertexEnvelope',xsi,'');
        vertexEnvelope.setNamespace('xsi','http://www.w3.org/2001/XMLSchema-instance');
            
        Dom.XmlNode login =  vertexEnvelope.addChildElement('urn:Login', null,null);
        Dom.XmlNode uid =   login.addChildElement('urn:UserName',null,null).addTextNode(vertexConfig.Username__c);
        Dom.XmlNode pwd =   login.addChildElement('urn:Password', null,null).addTextNode(vertexConfig.Password__c);
            
        Dom.XmlNode invoiceRequest = vertexEnvelope.addChildElement('urn:InvoiceRequest',null,null);
        invoiceRequest.setattribute('documentDate',currentSystemDateStr);
        invoiceRequest.setattribute('transactionType','LEASE');
            
        Dom.XmlNode seller  =  invoiceRequest.addChildElement('urn:Seller',null,null);
        seller.addChildElement('urn:Company',null,null).addTextNode(vertexConfig.Company__c);
        seller.addChildElement('urn:Division',null,null).addTextNode(vertexConfig.Division__c);
        
        Date startDate, endDate;
        Integer lengthOfContract;
        // Entering Due Detail lines details    
        for(cllease__Due_Detail_Lines__c dueDetailLine : dueDetailLines) {

            // Creating due types for all types, it loops as many times as quote lines in case of TERMINATION Bill.
            List<String> quoteLinesList;
        
            if(dueDetailLine.cllease__Bill__r.cllease__Due_Type_Description__c == 'TERMINATION') {
                quoteLinesList = new List<String>{
                    'QUOTE DISCOUNT',
                    'QUOTE PURCHASE AMOUNT',
                    'QUOTE PURCHASE PREMIUM AMOUNT',
                    'QUOTE ROLLOVER INCENTIVE',
                    'QUOTE SERVICE AND MAINTENANCE',
                    'QUOTE UNBILLED RECEIVABLE'
                };

            } else {
                String duetype = (dueDetailLine.cllease__Bill__r.cllease__Due_Type_Description__c != null ? dueDetailLine.cllease__Bill__r.cllease__Due_Type_Description__c : 'VALUE IS BLANK');
                quoteLinesList = new List<String>{ duetype };
            }
            
            // Calculating the Length of Contract from first payment date to maturity date
            //startDate = dueDetailLine.cllease__Bill__r.cllease__Lease_Account__r.cllease__First_Payment_Date__c;
            //endDate   = dueDetailLine.cllease__Bill__r.cllease__Lease_Account__r.cllease__Maturity_Date__c;
            //lengthOfContract = startDate.daysBetween(endDate);
            // Added new code  by jagadeesh on 04022019
            startDate = dueDetailLine.cllease__Bill__r.cllease__Lease_Account__r.cllease__First_Payment_Date__c;

			Date appFirstPmtDate = dueDetailLine.cllease__Bill__r.cllease__Lease_Account__r.cllease__Contract_Date__c;
			String pmtFrequency = dueDetailLine.cllease__Bill__r.cllease__Lease_Account__r.cllease__Payment_Frequency__c;
			Decimal term = dueDetailLine.cllease__Bill__r.cllease__Lease_Account__r.cllease__Term__c;
			endDate = cllease.DateUtil.getNextCycleDate(appFirstPmtDate,
                                                           appFirstPmtDate.day(),
                                                           pmtFrequency,
                                                           (Integer)term, true);
			
            system.debug('appFirstPmtDate: '+appFirstPmtDate) ;	
            system.debug('appFirstPmtDate.day(): '+appFirstPmtDate.day()) ;
            system.debug('pmtFrequency: '+pmtFrequency) ;										   
			system.debug('term: '+term) ;
            system.debug('end date: '+endDate) ;
			lengthOfContract = appFirstPmtDate.daysBetween(endDate);
			system.debug('length in days'+lengthOfContract);

            // Creating the LineItems for all Due Type Lines
            for(String quoteLineType : quoteLinesList) {
                // Extracting the fieldAPI name for quick Quote
                String fieldAPIName = terminationDueDetailLineFieldAPIMap.get(quoteLineType);
                fieldAPIName = (fieldAPIName != null ? fieldAPIName : 'cllease__Rental_Due_Amount__c');

                // Line XML File Creation
                lineItemId = (dueDetailLine.Name != null ? dueDetailLine.Name : 'VALUE IS BLANK');
                Dom.XmlNode lineItem = invoiceRequest.addChildElement('urn:LineItem', null, null);
                lineItem.setattribute('lineItemId', lineItemId);
                // Start: Customer Tag
                Dom.XmlNode customer = lineItem.addChildElement('urn:Customer',null,null);
                // Tax Exempt Check
                Boolean isTaxExempted = false;
                // 1. Always check for Tax Exemption from Account , if not exempted check for equipment
                if(dueDetailLine.cllease__Bill__c != null
                    && dueDetailLine.cllease__Bill__r.cllease__Lease_Account__c != null
                    && dueDetailLine.cllease__Bill__r.cllease__Lease_Account__r.cllease__Account__c != null)  {
                    // TODO: Needs to change Salesforce only support 3 levels for pulling values
                    isTaxExempted = dueDetailLine.cllease__Bill__r.cllease__Lease_Account__r.cllease__Account__r.Tax_Exempt__c;
                    system.debug('AccountTax Exemption :'+ isTaxExempted);
                } 
                // 2. Check for Equipment's Tax Exempt only if Account is not Exempted
                if(isTaxExempted == false 
                    && dueDetailLine.cllease__Contract_Equipment__c != null){
                    isTaxExempted = dueDetailLine.cllease__Contract_Equipment__r.cllease__Tax_exemption__c;
                    system.debug('contract Tax Exemption: '+isTaxExempted);
                }
                
                if(isTaxExempted) {
                    customer.setattribute('isTaxExempt','true');
                    customer.setattribute('exemptionReasonCode','MISS');
                } else {
                    customer.setattribute('isTaxExempt','false');
                }

                // Adding Destination details
                Dom.XmlNode destination = customer.addChildElement('urn:Destination', null, null);
                String cityValue    = (dueDetailLine.DestinationCity__c != null ? dueDetailLine.DestinationCity__c : 'VALUE IS BLANK');
                Dom.XmlNode city    = destination.addChildElement('urn:City',null,null);
                city.addTextNode(cityValue);

                String mainDivisionValue = (dueDetailLine.Destinationstate__c != null ? dueDetailLine.Destinationstate__c : 'VALUE IS BLANK');
                Dom.XmlNode mainDivision = destination.addChildElement('urn:MainDivision',null,null);
                mainDivision.addTextNode(mainDivisionValue);

                String zipCodeValue  = (dueDetailLine.DestinationzipCode__c != null ? dueDetailLine.DestinationzipCode__c : 'VALUE IS BLANK');
                Dom.XmlNode zipCode  = destination.addChildElement('urn:PostalCode',null,null);
                zipCode.addTextNode(zipCodeValue);
                // End: Customer Tag

                // Product Tag
                String productValue = (dueDetailLine.cllease__Contract_Equipment__r.GARD__c!=null?dueDetailLine.cllease__Contract_Equipment__r.GARD__c:'VALUE IS BLANK');
                lineItem.addChildElement('urn:Product',null,null).addTextNode(productValue);
                
                // ExtendedPrice Tag
                Decimal ddlAmount = (Decimal)dueDetailLine.get(fieldAPIName) ;
                ddlAmount = cllease.ValueUtil.round(ddlAmount != null ? ddlAmount : 0.00, 2 , 'Nearest');
                String extdPrice = String.valueof(ddlAmount);
                lineItem.addChildElement('urn:ExtendedPrice',null,null).addTextNode(extdPrice);
            
                // Start: FlexibleFields Tag
                // Start: FlexibleCodeField Tag
                Dom.XmlNode FFields =  lineItem.addChildElement('urn:FlexibleFields',null,null);
                Dom.XmlNode ffield1 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                ffield1.setattribute('fieldId','1');
                ffield1.addTextNode(transCodev);
                Dom.XmlNode ffield2 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                ffield2.setattribute('fieldId','2');
                ffield2.addTextNode(contrTypev);
                Dom.XmlNode ffield3 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                ffield3.setattribute('fieldId','3');
                ffield3.addTextNode(taxPmtTypev);
                Dom.XmlNode ffield4 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                ffield4.setattribute('fieldId','4');
                ffield4.addTextNode(leaseTypev);
                Dom.XmlNode ffield5 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                ffield5.setattribute('fieldId','5');
                ffield5.addTextNode(titleTxfrv);
                Dom.XmlNode ffield6 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                ffield6.setattribute('fieldId','6');
                ffield6.addTextNode(taxBasisv);
                Dom.XmlNode ffield7 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                ffield7.setattribute('fieldId','7');
                ffield7.addTextNode(intDisclv);
                Dom.XmlNode ffield8 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                ffield8.setattribute('fieldId','8');
                ffield8.addTextNode(vendPaidv);
                Dom.XmlNode ffield9 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                ffield9.setattribute('fieldId','9');
                ffield9.addTextNode('CLS-cllease__Due_Detail_Lines__c');
                assetNumber = (dueDetailLine.cllease__Contract_Equipment__r.Application_Equipment_Number__c != null ? dueDetailLine.cllease__Contract_Equipment__r.Application_Equipment_Number__c :'VALUE IS BLANK');
                Dom.XmlNode ffield10 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                ffield10.setattribute('fieldId','10');
                ffield10.addTextNode(assetNumber);
                Dom.XmlNode ffield11 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                ffield11.setattribute('fieldId','11');
                ffield11.addTextNode('0');
                Dom.XmlNode ffield12 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                ffield12.setattribute('fieldId','12');
                ffield12.addTextNode('0');
                if(dueDetailLine.cllease__Bill__r.cllease__Lease_Account__r.cllease__Lease_Status__c == 'EVERGREEN'){
                        Dom.XmlNode ffield13 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                        ffield13.setattribute('fieldId','13');
                        ffield13.addTextNode(alevTrue);
                }
                else
                {
                        Dom.XmlNode ffield13 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                        ffield13.setattribute('fieldId','13');
                        ffield13.addTextNode(alevFalse);
                }    
                Dom.XmlNode ffield14 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                ffield14.setattribute('fieldId','14');
                ffield14.addTextNode(slbc);
             	Dom.XmlNode ffield15 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                ffield15.setattribute('fieldId','15');
                ffield15.addTextNode(quoteLineType);
                Dom.XmlNode ffield16 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                ffield16.setattribute('fieldId','16');
                ffield16.addTextNode(reqReasonv);
                ApplNumber = (dueDetailLine.cllease__Bill__r.cllease__Lease_Account__r.cllease__application_number__c != null ? dueDetailLine.cllease__Bill__r.cllease__Lease_Account__r.cllease__application_number__c : 'VALUE IS BLANK');
           		Dom.XmlNode ffield17 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            	ffield17.setattribute('fieldId','17');
            	ffield17.addTextNode(ApplNumber);
                Dom.XmlNode ffield18 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                ffield18.setattribute('fieldId','18');
                ffield18.addTextNode(upTaxAmtv);
                // End: FlexibleCodeField Tag

                // Start: FlexibleNumericField Tag
                Dom.XmlNode ffield21 = FFields.addChildElement('urn:FlexibleNumericField',null,null);
                ffield21.setattribute('fieldId','1');
                ffield21.addTextNode(String.valueOf(lengthOfContract));
                Dom.XmlNode ffield22 = FFields.addChildElement('urn:FlexibleNumericField',null,null);
                ffield22.setattribute('fieldId','2');
                ffield22.addTextNode(cumulTaxv);
                Dom.XmlNode ffield23 = FFields.addChildElement('urn:FlexibleNumericField',null,null);
                ffield23.setattribute('fieldId','3');
                ffield23.addTextNode(slbPaidv);
                Dom.XmlNode ffield24 = FFields.addChildElement('urn:FlexibleNumericField',null,null);
                ffield24.setattribute('fieldId','4');
                ffield24.addTextNode(qtpCodev);
                Dom.XmlNode ffield25 = FFields.addChildElement('urn:FlexibleNumericField',null,null);
                ffield25.setattribute('fieldId','5');
                ffield25.addTextNode(qrsCodev);
                // End: FlexibleNumericField Tag

                // FlexibleDateField Tag
                DateTime contracDate = (dueDetailLine.cllease__Bill__r.cllease__Lease_Account__r.cllease__Contract_Date__c!=null ? dueDetailLine.cllease__Bill__r.cllease__Lease_Account__r.cllease__Contract_Date__c :currentSystemDate);
            	String cdate = formatDate(contracDate);
            	Dom.XmlNode ffield31 = FFields.addChildElement('urn:FlexibleDateField',null,null);
            	ffield31.setattribute('fieldId','1');
            	ffield31.addTextNode(cdate);

            }   
        }

        String req = scdoc.toXmlString();
        System.debug(LoggingLevel.ERROR, ' Request Str for DueDetailLine: '+ req);

        return scdoc;
    }
        
    /**
     *  Following method helps in forming xml for Charge Details
     **/  
    public static Dom.Document getChargesXml(List<cllease__Charge__c> charges) {
          
        // Getting Vertex API Configuration from customerom settings
        VertexApi__c vertexConfig = CLSCustomUtil.getVertexConfiguration();
        validateVertexConfig(vertexConfig);

        System.debug(LoggingLevel.ERROR, ' Vertex Configuration: ' + vertexConfig);

        String soapNS  = (vertexConfig.soapNS__c != null ? vertexConfig.soapNS__c : 'http://schemas.xmlsoap.org/soap/envelope/');
        String xsi     = (vertexConfig.XSI__c != null ? vertexConfig.XSI__c : 'urn:vertexinc:o-series:tps:8:0');

        DateTime currentSystemDate  =   cllease.SystemDateUtil.getCurrentSystemDate();
        String currentSystemDateStr =   formatDate(currentSystemDate);

        //Creating XML Formation Starts here
        String ApplNumber, contractDate, contractTerm, contractType, transactionCode, taxPaymentType; 
        String dueAmount, assetNumber, lineItemId;

        Dom.Document scdoc = new Dom.Document();
        Dom.XmlNode envelope = scdoc.createRootElement('Envelope', soapNS, 'soapenv');
        envelope.setNamespace('urn', xsi);
            
        Dom.XmlNode header = envelope.addChildElement('Header', soapNS, null);
            
        Dom.XmlNode body = envelope.addChildElement('Body', soapNS, null);
        Dom.XmlNode vertexEnvelope = body.addChildElement('urn:VertexEnvelope', xsi, '');
        vertexEnvelope.setNamespace('xsi','http://www.w3.org/2001/XMLSchema-instance');

        Dom.XmlNode login =  vertexEnvelope.addChildElement('urn:Login', null,null);
        Dom.XmlNode uid =   login.addChildElement('urn:UserName',null,null).addTextNode(vertexConfig.Username__c);
        Dom.XmlNode pwd =   login.addChildElement('urn:Password', null,null).addTextNode(vertexConfig.Password__c);
            
        Dom.XmlNode invoiceRequest = vertexEnvelope.addChildElement('urn:InvoiceRequest',null,null);
        invoiceRequest.setattribute('documentDate',currentSystemDateStr);
        invoiceRequest.setattribute('transactionType','LEASE');
            
        Dom.XmlNode seller  =  invoiceRequest.addChildElement('urn:Seller',null,null);
        seller.addChildElement('urn:Company',null,null).addTextNode(vertexConfig.Company__c);
        seller.addChildElement('urn:Division',null,null).addTextNode(vertexConfig.Division__c);

        Date startDate, endDate;
        Integer lengthOfContract;

        for(cllease__Charge__c charge : charges){
            // Calculating Length of contract
            //startDate = charge.cllease__Lease_Account__r.cllease__First_Payment_Date__c;
            //endDate   = charge.cllease__Lease_Account__r.cllease__Maturity_Date__c;
            //lengthOfContract = startDate.daysBetween(endDate);
            startDate = charge.cllease__Lease_Account__r.cllease__First_Payment_Date__c;
			system.debug('start date'+startDate) ;
			Date appFirstPmtDate = charge.cllease__Lease_Account__r.cllease__Contract_Date__c;
			String pmtFrequency = charge.cllease__Lease_Account__r.cllease__Payment_Frequency__c;
			Decimal term = charge.cllease__Lease_Account__r.cllease__Term__c;
			endDate = cllease.DateUtil.getNextCycleDate(appFirstPmtDate,
                                                           appFirstPmtDate.day(),
                                                           pmtFrequency,
                                                           (Integer)term, true);
														   
			system.debug('emd date'+endDate) ;
			lengthOfContract = appFirstPmtDate.daysBetween(endDate);
			system.debug('length in days'+lengthOfContract);



            lineItemId= (charge.Name!=null?charge.Name:'VALUE IS BLANK');
            Dom.XmlNode lineItem   =   invoiceRequest.addChildElement('urn:LineItem',null,null);
            lineItem.setattribute('lineItemId',lineItemId);
                                                     
            // Start: Customer Tag      
            Dom.XmlNode customer    =   lineItem.addChildElement('urn:Customer',null,null);

            // Tax Exempt Check
            Boolean isTaxExempted = false;
            // 1. Always check for Tax Exemption from Account , if not exempted check for equipment
            if(charge.cllease__Lease_Account__c != null
                && charge.cllease__Lease_Account__r.cllease__Account__c != null)  {
                // TODO: Needs to change Salesforce only support 3 levels for pulling values
                isTaxExempted = charge.cllease__Lease_Account__r.cllease__Account__r.Tax_Exempt__c;
                system.debug('Charge AccountTax Exemption :'+ isTaxExempted);
            } 
            // 2. Check for Equipment's Tax Exempt only if Account is not Exempted
            if(isTaxExempted == false
                && charge.cllease__Contract_Equipment__c != null){
                isTaxExempted = charge.cllease__Contract_Equipment__r.cllease__Tax_exemption__c;
                system.debug('Charge contract Tax Exemption: '+isTaxExempted);
            }
            
            if(isTaxExempted) {
                customer.setattribute('isTaxExempt','true');
                customer.setattribute('exemptionReasonCode','MISS');
            } else {
                customer.setattribute('isTaxExempt','false');
            }

            Dom.XmlNode destination = customer.addChildElement('urn:Destination', null, null);
            String cityValue    = (charge.DestinationCity__c != null ? charge.DestinationCity__c : 'VALUE IS BLANK');
            Dom.XmlNode city    = destination.addChildElement('urn:City',null,null);
            city.addTextNode(cityValue);

            String mainDivisionValue = (charge.Destinationstate__c != null ? charge.Destinationstate__c : 'VALUE IS BLANK');
            Dom.XmlNode mainDivision = destination.addChildElement('urn:MainDivision',null,null);
            mainDivision.addTextNode(mainDivisionValue);

            String zipCodeValue  = (charge.DestinationZipCode__c != null ? charge.DestinationZipCode__c : 'VALUE IS BLANK');
            Dom.XmlNode zipCode  = destination.addChildElement('urn:PostalCode',null,null);
            zipCode.addTextNode(zipCodeValue);
            // End: Customer Tag

            // Product Tag
            String productValue = (charge.cllease__Contract_Equipment__r.GARD__c != null ? charge.cllease__Contract_Equipment__r.GARD__c : 'VALUE IS BLANK');
            lineItem.addChildElement('urn:Product',null,null).addTextNode(productValue);

            // ExtendedPrice Tag
            Decimal chargeAmount = (charge.cllease__Original_Amount__c !=null ? charge.cllease__Original_Amount__c : 0.00);
            chargeAmount = cllease.ValueUtil.round(chargeAmount, 2 , 'Nearest');
            String extdPrice = String.valueof(chargeAmount);
            lineItem.addChildElement('urn:ExtendedPrice',null,null).addTextNode(extdPrice);

            // Start: FlexibleFields Tag
            // Start: FlexibleCodeField Tag
            Dom.XmlNode FFields =  lineItem.addChildElement('urn:FlexibleFields',null,null);
            Dom.XmlNode ffield1 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield1.setattribute('fieldId','1');
            ffield1.addTextNode(transCodev);
            Dom.XmlNode ffield2 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield2.setattribute('fieldId','2');
            ffield2.addTextNode(contrTypev);
            Dom.XmlNode ffield3 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield3.setattribute('fieldId','3');
            ffield3.addTextNode(taxPmtTypev);
            Dom.XmlNode ffield4 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield4.setattribute('fieldId','4');
            ffield4.addTextNode(leaseTypev);
            Dom.XmlNode ffield5 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield5.setattribute('fieldId','5');
            ffield5.addTextNode(titleTxfrv);
            Dom.XmlNode ffield6 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield6.setattribute('fieldId','6');
            ffield6.addTextNode(taxBasisv);
            Dom.XmlNode ffield7 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield7.setattribute('fieldId','7');
            ffield7.addTextNode(intDisclv);
            Dom.XmlNode ffield8 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield8.setattribute('fieldId','8');
            ffield8.addTextNode(vendPaidv);
            Dom.XmlNode ffield9 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield9.setattribute('fieldId','9');
            ffield9.addTextNode('CLS-cllease__Charge__c');
            assetNumber = (charge.cllease__Contract_Equipment__r.Application_Equipment_Number__c != null ? charge.cllease__Contract_Equipment__r.Application_Equipment_Number__c : 'VALUE IS BLANK');
            Dom.XmlNode ffield10 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield10.setattribute('fieldId','10');
            ffield10.addTextNode(assetNumber);
            Dom.XmlNode ffield11 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield11.setattribute('fieldId','11');
            ffield11.addTextNode('0');
            Dom.XmlNode ffield12 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield12.setattribute('fieldId','12');
            ffield12.addTextNode('0');
           if(charge.cllease__Lease_Account__r.cllease__Lease_Status__c == 'EVERGREEN'){
            Dom.XmlNode ffield13 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield13.setattribute('fieldId','13');
            ffield13.addTextNode(alevTrue);
            }
            else
            {
            Dom.XmlNode ffield13 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield13.setattribute('fieldId','13');
            ffield13.addTextNode(alevFalse);
            } 
            Dom.XmlNode ffield14 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield14.setattribute('fieldId','14');
            ffield14.addTextNode(slbc);
            String txnService = (charge.cllease__Fee_Definition__r.Name != null ? charge.cllease__Fee_Definition__r.name : 'VALUE IS BLANK');
            Dom.XmlNode ffield15 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield15.setattribute('fieldId','15');
            ffield15.addTextNode(txnService);
            Dom.XmlNode ffield16 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield16.setattribute('fieldId','16');
            ffield16.addTextNode(reqReasonv);
             ApplNumber = (charge.cllease__Lease_Account__r.cllease__application_number__c != null? charge.cllease__Lease_Account__r.cllease__application_number__c :'VALUE IS BLANK');
            Dom.XmlNode ffield17 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield17.setattribute('fieldId','17');
            ffield17.addTextNode(ApplNumber);
            Dom.XmlNode ffield18 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield18.setattribute('fieldId','18');
            ffield18.addTextNode(upTaxAmtv);
            // End: FlexibleCodeField Tag

            // Start: FlexibleNumericField Tag
            Dom.XmlNode ffield21 = FFields.addChildElement('urn:FlexibleNumericField',null,null);
            ffield21.setattribute('fieldId','1');
            ffield21.addTextNode(String.valueOf(lengthOfContract));
            Dom.XmlNode ffield22 = FFields.addChildElement('urn:FlexibleNumericField',null,null);
            ffield22.setattribute('fieldId','2');
            ffield22.addTextNode(cumulTaxv);
            Dom.XmlNode ffield23 = FFields.addChildElement('urn:FlexibleNumericField',null,null);
            ffield23.setattribute('fieldId','3');
            ffield23.addTextNode(slbPaidv);
            Dom.XmlNode ffield24 = FFields.addChildElement('urn:FlexibleNumericField',null,null);
            ffield24.setattribute('fieldId','4');
            ffield24.addTextNode(qtpCodev);
            Dom.XmlNode ffield25 = FFields.addChildElement('urn:FlexibleNumericField',null,null);
            ffield25.setattribute('fieldId','5');
            ffield25.addTextNode(qrsCodev);
            // End: FlexibleNumericField Tag

            // FlexibleDateField Tag
            DateTime contracDate = (charge.cllease__Lease_Account__r.cllease__Contract_Date__c!=null ? charge.cllease__Lease_Account__r.cllease__Contract_Date__c :currentSystemDate);
            String cdate = formatDate(contracDate);
            Dom.XmlNode ffield31 = FFields.addChildElement('urn:FlexibleDateField',null,null);
            ffield31.setattribute('fieldId','1');
            ffield31.addTextNode(cdate);
        }
        String req = scdoc.toXmlString();
        System.debug(LoggingLevel.ERROR, ' Request Str for Charge: '+ req);

        return scdoc;
    } 

    /**
     * Following helps in creating the xml for Termination Request for the Termination Quote.
     **/
    public static Dom.Document getTerminationQuoteReqXml(cllease__Termination_Quote_Header__c quoteHeader, List<Termination_Equipment_Quote__c> eqpQuoteLines) {
        // Getting Vertex API Configuration from customerom settings
        VertexApi__c vertexConfig = CLSCustomUtil.getVertexConfiguration();
        validateVertexConfig(vertexConfig);

        System.debug(LoggingLevel.ERROR, ' Vertex Configuration: ' + vertexConfig);

        String soapNS  = (vertexConfig.soapNS__c != null ? vertexConfig.soapNS__c : 'http://schemas.xmlsoap.org/soap/envelope/');
        String xsi     = (vertexConfig.XSI__c != null ? vertexConfig.XSI__c : 'urn:vertexinc:o-series:tps:8:0');

        DateTime currentSystemDate  =   cllease.SystemDateUtil.getCurrentSystemDate();
        String currentSystemDateStr =   formatDate(currentSystemDate);

        //Creating XML Formation Starts here
        String contractName, contractDate, contractTerm, contractType, transactionCode, taxPaymentType; 
        String dueAmount, lineItemId;

        Dom.Document scdoc = new Dom.Document();
        Dom.XmlNode envelope = scdoc.createRootElement('Envelope', soapNS, 'soapenv');
        envelope.setNamespace('urn', xsi);
            
        Dom.XmlNode header = envelope.addChildElement('Header', soapNS, null);
            
        Dom.XmlNode body = envelope.addChildElement('Body', soapNS, null);
        Dom.XmlNode vertexEnvelope = body.addChildElement('urn:VertexEnvelope', xsi, '');
        vertexEnvelope.setNamespace('xsi','http://www.w3.org/2001/XMLSchema-instance');

        Dom.XmlNode login =  vertexEnvelope.addChildElement('urn:Login', null,null);
        Dom.XmlNode uid =   login.addChildElement('urn:UserName',null,null).addTextNode(vertexConfig.Username__c);
        Dom.XmlNode pwd =   login.addChildElement('urn:Password', null,null).addTextNode(vertexConfig.Password__c);
            
        Dom.XmlNode quotationRequest = vertexEnvelope.addChildElement('urn:QuotationRequest',null,null);
        quotationRequest.setattribute('documentDate',currentSystemDateStr);
        quotationRequest.setattribute('transactionType','LEASE');
            
        Dom.XmlNode seller  =  quotationRequest.addChildElement('urn:Seller',null,null);
        seller.addChildElement('urn:Company',null,null).addTextNode(vertexConfig.Company__c);
        seller.addChildElement('urn:Division',null,null).addTextNode(vertexConfig.Division__c);

        Date startDate, endDate;
        Integer lengthOfContract;
        startDate = quoteHeader.cllease__Contract__r.cllease__First_Payment_Date__c;
        endDate   = quoteHeader.cllease__Contract__r.cllease__Maturity_Date__c;
        lengthOfContract = startDate.daysBetween(endDate);

        String productValue  = 'VALUE IS BLANK';
        String assetNumber   = 'VALUE IS BLANK';

        contractName = (quoteHeader.cllease__Contract__r.Name != null? quoteHeader.cllease__Contract__r.Name :'VALUE IS BLANK');
            
        for(Termination_Equipment_Quote__c eqpQuoteLine: eqpQuoteLines){
            // Calculating Length of contract
            /**/
            // Tax Exempt Check
            String quoteCity     = eqpQuoteLine.DestinationCity__c;
            String quoteState    = eqpQuoteLine.DestinationState__c;
            String quoteZipCode  = eqpQuoteLine.DestinationZipCode__c;
        

            lineItemId = (eqpQuoteLine.Name != null ? eqpQuoteLine.Name : 'VALUE IS BLANK');
            Dom.XmlNode lineItem   =   quotationRequest.addChildElement('urn:LineItem',null,null);
            lineItem.setattribute('lineItemId',lineItemId);
                                                     
            // Start: Customer Tag      
            Dom.XmlNode customer    =   lineItem.addChildElement('urn:Customer',null,null);

            String quoteLineType = (eqpQuoteLine.Termination_Quote_Line__r.cllease__Line_Type__c != null ? eqpQuoteLine.Termination_Quote_Line__r.cllease__Line_Type__c : 'VALUE IS BLANK');
            
            // 1. Always check for Tax Exemption from Account , if not exempted check for equipment
            // Tax Exempt Check
            Boolean isTaxExempted = eqpQuoteLine.Tax_Exempt__c;
            
            if(isTaxExempted) {
                customer.setattribute('isTaxExempt','true');
                customer.setattribute('exemptionReasonCode','MISS');
            } else {
                customer.setattribute('isTaxExempt','false');
            }

            Dom.XmlNode destination = customer.addChildElement('urn:Destination', null, null);
            Dom.XmlNode city    = destination.addChildElement('urn:City',null,null);
            city.addTextNode(quoteCity);

            Dom.XmlNode mainDivision = destination.addChildElement('urn:MainDivision',null,null);
            mainDivision.addTextNode(quoteState);

            Dom.XmlNode zipCode  = destination.addChildElement('urn:PostalCode',null,null);
            zipCode.addTextNode(quoteZipCode);
            // End: Customer Tag

            // Product Tag
            lineItem.addChildElement('urn:Product',null,null).addTextNode(quoteLineType);

            // ExtendedPrice Tag
            Decimal lineAmount = (eqpQuoteLine.Amount__c !=null ? eqpQuoteLine.Amount__c : 0.00);
            lineAmount = cllease.ValueUtil.round(lineAmount, 2 , 'Nearest');
            String extdPrice = String.valueof(lineAmount);
            lineItem.addChildElement('urn:ExtendedPrice',null,null).addTextNode(extdPrice);

            // Start: FlexibleFields Tag
            // Start: FlexibleCodeField Tag
            Dom.XmlNode FFields =  lineItem.addChildElement('urn:FlexibleFields',null,null);
            Dom.XmlNode ffield1 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield1.setattribute('fieldId','1');
            ffield1.addTextNode(transCodev);
            Dom.XmlNode ffield2 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield2.setattribute('fieldId','2');
            ffield2.addTextNode(contrTypev);
            Dom.XmlNode ffield3 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield3.setattribute('fieldId','3');
            ffield3.addTextNode(taxPmtTypev);
            Dom.XmlNode ffield4 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield4.setattribute('fieldId','4');
            ffield4.addTextNode(leaseTypev);
            Dom.XmlNode ffield5 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield5.setattribute('fieldId','5');
            ffield5.addTextNode(titleTxfrv);
            //Dom.XmlNode ffield6 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            //ffield6.setattribute('fieldId','6');
            //ffield6.addTextNode(taxBasisv);
            Dom.XmlNode ffield7 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield7.setattribute('fieldId','7');
            ffield7.addTextNode(intDisclv);
            //Dom.XmlNode ffield8 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            //ffield8.setattribute('fieldId','8');
            //ffield8.addTextNode(vendPaidv);
            Dom.XmlNode ffield9 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield9.setattribute('fieldId','9');
            ffield9.addTextNode('CLS-cllease__Termination_Quote_Header__c');
            assetNumber = (eqpQuoteLine.Termination_Quote_Equipment__r.cllease__Contract_Equipment__r.Name != null ? eqpQuoteLine.Termination_Quote_Equipment__r.cllease__Contract_Equipment__r.Name : 'VALUE IS BLANK');
            Dom.XmlNode ffield10 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield10.setattribute('fieldId','10');
            ffield10.addTextNode(assetNumber);
            Dom.XmlNode ffield11 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield11.setattribute('fieldId','11');
            ffield11.addTextNode('0');
            Dom.XmlNode ffield12 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield12.setattribute('fieldId','12');
            ffield12.addTextNode('0');
            //Dom.XmlNode ffield13 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            //ffield13.setattribute('fieldId','13');
            //ffield13.addTextNode(alev);
            //Dom.XmlNode ffield14 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            //ffield14.setattribute('fieldId','14');
            //ffield14.addTextNode(slbc);
            Dom.XmlNode ffield15 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield15.setattribute('fieldId','15');
            ffield15.addTextNode(quoteLineType);
            //Dom.XmlNode ffield16 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            //ffield16.setattribute('fieldId','16');
            //ffield16.addTextNode(reqReasonv);
            Dom.XmlNode ffield17 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield17.setattribute('fieldId','17');
            ffield17.addTextNode(contractName);
            //Dom.XmlNode ffield18 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            //ffield18.setattribute('fieldId','18');
            //ffield18.addTextNode(upTaxAmtv);
            // End: FlexibleCodeField Tag

            // Start: FlexibleNumericField Tag
            Dom.XmlNode ffield21 = FFields.addChildElement('urn:FlexibleNumericField',null,null);
            ffield21.setattribute('fieldId','1');
            ffield21.addTextNode(String.valueOf(lengthOfContract));
            Dom.XmlNode ffield22 = FFields.addChildElement('urn:FlexibleNumericField',null,null);
            ffield22.setattribute('fieldId','2');
            ffield22.addTextNode(cumulTaxv);
            //Dom.XmlNode ffield23 = FFields.addChildElement('urn:FlexibleNumericField',null,null);
            //ffield23.setattribute('fieldId','3');
            //ffield23.addTextNode(slbPaidv);
            Dom.XmlNode ffield24 = FFields.addChildElement('urn:FlexibleNumericField',null,null);
            ffield24.setattribute('fieldId','4');
            ffield24.addTextNode(qtpCodev);
            Dom.XmlNode ffield25 = FFields.addChildElement('urn:FlexibleNumericField',null,null);
            ffield25.setattribute('fieldId','5');
            ffield25.addTextNode(qrsCodev);
            // End: FlexibleNumericField Tag

            // FlexibleDateField Tag
            Dom.XmlNode ffield31 = FFields.addChildElement('urn:FlexibleDateField',null,null);
            ffield31.setattribute('fieldId','1');
            ffield31.addTextNode(currentSystemDateStr);
        }
        String req = scdoc.toXmlString();
        System.debug(LoggingLevel.ERROR, ' Request Str for Charge: '+ req);

        return scdoc;
    }

    /**
     *  Following method helps in sending vertex call for termination bill
     **/
    public static Dom.Document getTerminationBillXml(Map<Id, List<cllease__Due_Detail_Lines__c>> contractTerminationdueDetailLinesMap) {
        // Getting Vertex API Configuration from customerom settings & Validating
        VertexApi__c vertexConfig = CLSCustomUtil.getVertexConfiguration();
        validateVertexConfig(vertexConfig);

        System.debug(LoggingLevel.ERROR, ' Vertex Configuration: ' + vertexConfig);        

        String soapNS  = (vertexConfig.soapNS__c != null ? vertexConfig.soapNS__c : 'http://schemas.xmlsoap.org/soap/envelope/');
        String xsi     = (vertexConfig.XSI__c != null ? vertexConfig.XSI__c : 'urn:vertexinc:o-series:tps:8:0');

        DateTime currentSystemDate  =   cllease.SystemDateUtil.getCurrentSystemDate();
        String currentSystemDateStr =   formatDate(currentSystemDate);
        
            
        //Creating XML Formation Starts here
        String contractName, contractDate, contractTerm, contractType, transactionCode, taxPaymentType; 
        String dueAmount, assetNumber, lineItemId;

        // Creating DOM for XML
        Dom.Document scdoc = new Dom.Document();
        Dom.XmlNode envelope = scdoc.createRootElement('Envelope', soapNS, 'soapenv');
        envelope.setNamespace('urn', xsi);
        
        Dom.XmlNode header = envelope.addChildElement('Header', soapNS, null);
        
        Dom.XmlNode body = envelope.addChildElement('Body', soapNS, null);
        Dom.XmlNode vertexEnvelope = body.addChildElement('urn:VertexEnvelope',xsi,'');
        vertexEnvelope.setNamespace('xsi','http://www.w3.org/2001/XMLSchema-instance');
            
        Dom.XmlNode login =  vertexEnvelope.addChildElement('urn:Login', null,null);
        Dom.XmlNode uid =   login.addChildElement('urn:UserName',null,null).addTextNode(vertexConfig.Username__c);
        Dom.XmlNode pwd =   login.addChildElement('urn:Password', null,null).addTextNode(vertexConfig.Password__c);
            
        Dom.XmlNode invoiceRequest = vertexEnvelope.addChildElement('urn:InvoiceRequest',null,null);
        invoiceRequest.setattribute('documentDate',currentSystemDateStr);
        invoiceRequest.setattribute('transactionType','LEASE');
            
        Dom.XmlNode seller  =  invoiceRequest.addChildElement('urn:Seller',null,null);
        seller.addChildElement('urn:Company',null,null).addTextNode(vertexConfig.Company__c);
        seller.addChildElement('urn:Division',null,null).addTextNode(vertexConfig.Division__c);
        
        Date startDate, endDate;
        Integer lengthOfContract;
        // looping through contract for requests
        for(Id contractId : contractTerminationdueDetailLinesMap.keySet()) {
            List<cllease__Due_Detail_Lines__c> dueDetailLines = contractTerminationdueDetailLinesMap.get(contractId);
            // Entering Due Detail lines details    
            for(cllease__Due_Detail_Lines__c dueDetailLine : dueDetailLines) {
                // Calculating the Length of Contract from first payment date to maturity date
                startDate = dueDetailLine.cllease__Bill__r.cllease__Lease_Account__r.cllease__First_Payment_Date__c;
                endDate   = dueDetailLine.cllease__Bill__r.cllease__Lease_Account__r.cllease__Maturity_Date__c;
                lengthOfContract = startDate.daysBetween(endDate);

                lineItemId = (dueDetailLine.Name != null ? dueDetailLine.Name : 'VALUE IS BLANK');
                Dom.XmlNode lineItem = invoiceRequest.addChildElement('urn:LineItem', null, null);
                lineItem.setattribute('lineItemId', lineItemId);
                // Start: Customer Tag
                Dom.XmlNode customer = lineItem.addChildElement('urn:Customer',null,null);
                // Tax Exempt Check
                Boolean isTaxExempted = false;
                // 1. Always check for Tax Exemption from Account , if not exempted check for equipment
                if(dueDetailLine.cllease__Bill__c != null
                    && dueDetailLine.cllease__Bill__r.cllease__Lease_Account__c != null
                    && dueDetailLine.cllease__Bill__r.cllease__Lease_Account__r.cllease__Account__c != null)  {
                    // TODO: Needs to change Salesforce only support 3 levels for pulling values
                    isTaxExempted = dueDetailLine.cllease__Bill__r.cllease__Lease_Account__r.cllease__Account__r.Tax_Exempt__c;
                    system.debug('AccountTax Exemption :'+ isTaxExempted);
                } 
                // 2. Check for Equipment's Tax Exempt only if Account is not Exempted
                if(isTaxExempted == false 
                    && dueDetailLine.cllease__Contract_Equipment__c != null){
                    isTaxExempted = dueDetailLine.cllease__Contract_Equipment__r.cllease__Tax_exemption__c;
                    system.debug('contract Tax Exemption: '+isTaxExempted);
                }
                
                if(isTaxExempted) {
                    customer.setattribute('isTaxExempt','true');
                    customer.setattribute('exemptionReasonCode','MISS');
                } else {
                    customer.setattribute('isTaxExempt','false');
                }

                Dom.XmlNode destination = customer.addChildElement('urn:Destination', null, null);
                String cityValue    = (dueDetailLine.DestinationCity__c != null ? dueDetailLine.DestinationCity__c : 'VALUE IS BLANK');
                Dom.XmlNode city    = destination.addChildElement('urn:City',null,null);
                city.addTextNode(cityValue);

                String mainDivisionValue = (dueDetailLine.Destinationstate__c != null ? dueDetailLine.Destinationstate__c : 'VALUE IS BLANK');
                Dom.XmlNode mainDivision = destination.addChildElement('urn:MainDivision',null,null);
                mainDivision.addTextNode(mainDivisionValue);

                String zipCodeValue  = (dueDetailLine.DestinationzipCode__c != null ? dueDetailLine.DestinationzipCode__c : 'VALUE IS BLANK');
                Dom.XmlNode zipCode  = destination.addChildElement('urn:PostalCode',null,null);
                zipCode.addTextNode(zipCodeValue);
                // End: Customer Tag

                // Product Tag
                String productValue = (dueDetailLine.cllease__Contract_Equipment__r.GARD__c!=null?dueDetailLine.cllease__Contract_Equipment__r.GARD__c:'VALUE IS BLANK');
                lineItem.addChildElement('urn:Product',null,null).addTextNode(productValue);
                
                // ExtendedPrice Tag
                Decimal ddlAmount = (dueDetailLine.cllease__Rental_Due_Amount__c !=null ? dueDetailLine.cllease__Rental_Due_Amount__c : 0.00);
                ddlAmount = cllease.ValueUtil.round(ddlAmount, 2 , 'Nearest');
                String extdPrice = String.valueof(ddlAmount);
                lineItem.addChildElement('urn:ExtendedPrice',null,null).addTextNode(extdPrice);
                
                // Start: FlexibleFields Tag
                // Start: FlexibleCodeField Tag
                Dom.XmlNode FFields =  lineItem.addChildElement('urn:FlexibleFields',null,null);
                Dom.XmlNode ffield1 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                ffield1.setattribute('fieldId','1');
                ffield1.addTextNode(transCodev);
                Dom.XmlNode ffield2 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                ffield2.setattribute('fieldId','2');
                ffield2.addTextNode(contrTypev);
                Dom.XmlNode ffield3 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                ffield3.setattribute('fieldId','3');
                ffield3.addTextNode(taxPmtTypev);
                Dom.XmlNode ffield4 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                ffield4.setattribute('fieldId','4');
                ffield4.addTextNode(leaseTypev);
                Dom.XmlNode ffield5 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                ffield5.setattribute('fieldId','5');
                ffield5.addTextNode(titleTxfrv);
                Dom.XmlNode ffield6 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                ffield6.setattribute('fieldId','6');
                ffield6.addTextNode(taxBasisv);
                Dom.XmlNode ffield7 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                ffield7.setattribute('fieldId','7');
                ffield7.addTextNode(intDisclv);
                Dom.XmlNode ffield8 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                ffield8.setattribute('fieldId','8');
                ffield8.addTextNode(vendPaidv);
                Dom.XmlNode ffield9 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                ffield9.setattribute('fieldId','9');
                ffield9.addTextNode('CLS-cllease__Due_Detail_Lines__c');
                assetNumber = (dueDetailLine.cllease__Contract_Equipment__c != null ? dueDetailLine.cllease__Contract_Equipment__r.Name :'VALUE IS BLANK');
                Dom.XmlNode ffield10 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                ffield10.setattribute('fieldId','10');
                ffield10.addTextNode(assetNumber);
                Dom.XmlNode ffield11 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                ffield11.setattribute('fieldId','11');
                ffield11.addTextNode('0');
                Dom.XmlNode ffield12 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                ffield12.setattribute('fieldId','12');
                ffield12.addTextNode('0');
                Dom.XmlNode ffield13 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                ffield13.setattribute('fieldId','13');
                ffield13.addTextNode(alevFalse);
                Dom.XmlNode ffield14 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                ffield14.setattribute('fieldId','14');
                ffield14.addTextNode(slbc);
                String duetype = (dueDetailLine.cllease__Bill__r.cllease__Due_Type_Description__c != null ? dueDetailLine.cllease__Bill__r.cllease__Due_Type_Description__c : 'VALUE IS BLANK');
                Dom.XmlNode ffield15 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                ffield15.setattribute('fieldId','15');
                ffield15.addTextNode(duetype);
                Dom.XmlNode ffield16 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                ffield16.setattribute('fieldId','16');
                ffield16.addTextNode(reqReasonv);
                contractName = (dueDetailLine.cllease__Bill__r.cllease__Lease_Account__r.Name != null ? dueDetailLine.cllease__Bill__r.cllease__Lease_Account__r.Name : 'VALUE IS BLANK');
                Dom.XmlNode ffield17 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                ffield17.setattribute('fieldId','17');
                ffield17.addTextNode(contractName);
                Dom.XmlNode ffield18 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                ffield18.setattribute('fieldId','18');
                ffield18.addTextNode(upTaxAmtv);
                // End: FlexibleCodeField Tag

                // Start: FlexibleNumericField Tag
                Dom.XmlNode ffield21 = FFields.addChildElement('urn:FlexibleNumericField',null,null);
                ffield21.setattribute('fieldId','1');
                ffield21.addTextNode(String.valueOf(lengthOfContract));
                Dom.XmlNode ffield22 = FFields.addChildElement('urn:FlexibleNumericField',null,null);
                ffield22.setattribute('fieldId','2');
                ffield22.addTextNode(cumulTaxv);
                Dom.XmlNode ffield23 = FFields.addChildElement('urn:FlexibleNumericField',null,null);
                ffield23.setattribute('fieldId','3');
                ffield23.addTextNode(slbPaidv);
                Dom.XmlNode ffield24 = FFields.addChildElement('urn:FlexibleNumericField',null,null);
                ffield24.setattribute('fieldId','4');
                ffield24.addTextNode(qtpCodev);
                Dom.XmlNode ffield25 = FFields.addChildElement('urn:FlexibleNumericField',null,null);
                ffield25.setattribute('fieldId','5');
                ffield25.addTextNode(qrsCodev);
                // End: FlexibleNumericField Tag

                // FlexibleDateField Tag
                Dom.XmlNode ffield31 = FFields.addChildElement('urn:FlexibleDateField',null,null);
                ffield31.setattribute('fieldId','1');
                ffield31.addTextNode(currentSystemDateStr);
                
            }
        }
        

        String req = scdoc.toXmlString();
        System.debug(LoggingLevel.ERROR, ' Request Str for Termination Bill: '+ req);

        return scdoc;
    }
    
    // formate the Date to String
    private static String formatDate(DateTime d) {
        return d.year() + '-' + d.month() + '-' + d.day();
    } 
    
  // This method newly added for calculating Vertex Upfront tax by Jagadeesh
    public static Dom.Document getUpfrontXml(list<genesis__Application_Equipment__c> eupApp) { 
           
        // Getting Vertex API Configuration from customerom settings & Validating
        VertexApi__c vertexConfig = CLSCustomUtil.getVertexConfiguration();
        validateVertexConfig(vertexConfig);

        System.debug(LoggingLevel.ERROR, ' Vertex Configuration: ' + vertexConfig);        

        String soapNS  = (vertexConfig.soapNS__c != null ? vertexConfig.soapNS__c : 'http://schemas.xmlsoap.org/soap/envelope/');
        String xsi     = (vertexConfig.XSI__c != null ? vertexConfig.XSI__c : 'urn:vertexinc:o-series:tps:8:0');

       // DateTime currentSystemDate  =   cllease.SystemDateUtil.getCurrentSystemDate();
        DateTime Commencementdate  = eupApp[0].genesis__Application__r.genesis__Expected_Start_Date__c;
        String CommencementdateStr =   formatDate(Commencementdate);
            
        //Creating XML Formation Starts here
        String AppliNumber, contractDate, contractTerm, contractType, transactionCode, taxPaymentType; 
        String dueAmount, assetNumber, lineItemId;

        // Creating DOM for XML
        Dom.Document scdoc = new Dom.Document();
        Dom.XmlNode envelope = scdoc.createRootElement('Envelope', soapNS, 'soapenv');
        envelope.setNamespace('urn', xsi);
        
        Dom.XmlNode header = envelope.addChildElement('Header', soapNS, null);
        
        Dom.XmlNode body = envelope.addChildElement('Body', soapNS, null);
        Dom.XmlNode vertexEnvelope = body.addChildElement('urn:VertexEnvelope',xsi,'');
        vertexEnvelope.setNamespace('xsi','http://www.w3.org/2001/XMLSchema-instance');
            
        Dom.XmlNode login =  vertexEnvelope.addChildElement('urn:Login', null,null);
        Dom.XmlNode uid =   login.addChildElement('urn:UserName',null,null).addTextNode(vertexConfig.Username__c);
        Dom.XmlNode pwd =   login.addChildElement('urn:Password', null,null).addTextNode(vertexConfig.Password__c);
            
        Dom.XmlNode invoiceRequest = vertexEnvelope.addChildElement('urn:InvoiceRequest',null,null);
        invoiceRequest.setattribute('documentDate',CommencementdateStr);
        invoiceRequest.setattribute('transactionType','LEASE');
            
        Dom.XmlNode seller  =  invoiceRequest.addChildElement('urn:Seller',null,null);
        seller.addChildElement('urn:Company',null,null).addTextNode(vertexConfig.Company__c);
        seller.addChildElement('urn:Division',null,null).addTextNode(vertexConfig.Division__c);
        
        Date startDate, endDate;
        Integer lengthOfContract;
        // Entering Application Equipment details    
         list<genesis__Application_Equipment__c> equpmentlist = new list<genesis__Application_Equipment__c>();
         for(genesis__Application_Equipment__c app : eupApp) {
             
            // Calculating the Length of Contract from first payment date to maturity date
            //startDate =app.genesis__Application__r.genesis__Expected_Start_Date__c;
            //system.debug('start date'+startDate) ;
            //endDate   = app.genesis__Application__r.genesis__Expected_Close_Date__c;
            // end date going to check calculation
            // DateTime currentSystemDate  =   cllease.SystemDateUtil.getCurrentSystemDate();
            System.debug('*****appFirstPAYEMNTDATE'+app.genesis__Application__r.genesis__Expected_Start_Date__c);
            Date appFirstPmtDate = app.genesis__Application__r.genesis__Expected_Start_Date__c;
            System.debug('****pmtFrequency********'+app.genesis__Application__r.genesis__Payment_Frequency__c);
            String pmtFrequency = app.genesis__Application__r.genesis__Payment_Frequency__c;
            System.debug('****genesisterm'+app.genesis__Application__r.genesis__Term__c);
            Decimal term = app.genesis__Application__r.genesis__Term__c;

            endDate = cllease.DateUtil.getNextCycleDate(appFirstPmtDate,
                                                           appFirstPmtDate.day(),
                                                           pmtFrequency,
                                                           (Integer)term, true);
            system.debug('emd date'+endDate) ;
            lengthOfContract = appFirstPmtDate.daysBetween(endDate);
            system.debug('length in days'+lengthOfContract);

            lineItemId = (app.id != null ? app.id : 'VALUE IS BLANK');
            Dom.XmlNode lineItem = invoiceRequest.addChildElement('urn:LineItem', null, null);
            lineItem.setattribute('lineItemId', lineItemId);
            // Start: Customer Tag
            Dom.XmlNode customer = lineItem.addChildElement('urn:Customer',null,null);
            customer.setattribute('isTaxExempt','false');
           
            Dom.XmlNode destination = customer.addChildElement('urn:Destination', null, null);
            String cityValue    =  (app.Install_Address1__r.City__c != null ? app.Install_Address1__r.City__c : 'VALUE IS BLANK');
            Dom.XmlNode city    = destination.addChildElement('urn:City',null,null);
            city.addTextNode(cityValue);

            String mainDivisionValue = (app.Install_Address1__r.State__c != null ? app.Install_Address1__r.State__c : 'VALUE IS BLANK');
            Dom.XmlNode mainDivision = destination.addChildElement('urn:MainDivision',null,null);
            mainDivision.addTextNode(mainDivisionValue);

            String zipCodeValue  = (app.Install_Address1__r.Zip_Code__c != null ? app.Install_Address1__r.Zip_Code__c : 'VALUE IS BLANK');
            Dom.XmlNode zipCode  = destination.addChildElement('urn:PostalCode',null,null);
            zipCode.addTextNode(zipCodeValue);
            // End: Customer Tag

            // Product name value is GARD__c value in application equipment
            String productValue = (app.GARD__c != null ? app.GARD__c : 'VALUE IS BLANK');
            lineItem.addChildElement('urn:Product',null,null).addTextNode(productValue);
            
            // ExtendedPrice Tag
            Decimal ddlAmount = (app.genesis__Estimated_Selling_Price__c !=null ? app.genesis__Estimated_Selling_Price__c : 0.00);
            ddlAmount = cllease.ValueUtil.round(ddlAmount, 2 , 'Nearest');
            String extdPrice = String.valueof(ddlAmount);
            lineItem.addChildElement('urn:ExtendedPrice',null,null).addTextNode(extdPrice);
            lineItem.addChildElement('urn:Cost',null,null).addTextNode(extdPrice);
            
            // Start: FlexibleCodeField Tag
            Dom.XmlNode FFields =  lineItem.addChildElement('urn:FlexibleFields',null,null);
            Dom.XmlNode ffield1 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield1.setattribute('fieldId','1');
            ffield1.addTextNode(upfronttransCodev);
            Dom.XmlNode ffield2 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield2.setattribute('fieldId','2');
             ffield2.addTextNode(contrTypev);
            Dom.XmlNode ffield3 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield3.setattribute('fieldId','3');
            ffield3.addTextNode(UpfronttaxPmtTypev);
            Dom.XmlNode ffield4 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield4.setattribute('fieldId','4');
            ffield4.addTextNode(leaseTypev);
            Dom.XmlNode ffield5 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield5.setattribute('fieldId','5');
            ffield5.addTextNode(titleTxfrv);
            Dom.XmlNode ffield6 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield6.setattribute('fieldId','6');
            ffield6.addTextNode(taxBasisv);
            Dom.XmlNode ffield7 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield7.setattribute('fieldId','7');
            ffield7.addTextNode(intDisclv);
            Dom.XmlNode ffield8 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield8.setattribute('fieldId','8');
            ffield8.addTextNode(vendPaidv);
            Dom.XmlNode ffield9 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield9.setattribute('fieldId','9');
            ffield9.addTextNode('CLS-genesis__Application_Equipment__c');
            assetNumber = (app.Name != null ? app.Name :'VALUE IS BLANK');
            Dom.XmlNode ffield10 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield10.setattribute('fieldId','10');
            ffield10.addTextNode(assetNumber);
            Dom.XmlNode ffield11 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield11.setattribute('fieldId','11');
            ffield11.addTextNode('0');
            Dom.XmlNode ffield12 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield12.setattribute('fieldId','12');
            ffield12.addTextNode('0');
            Dom.XmlNode ffield13 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield13.setattribute('fieldId','13');
            ffield13.addTextNode(alevFalse);
            Dom.XmlNode ffield14 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield14.setattribute('fieldId','14');
            ffield14.addTextNode(slbc);
            String duetype = (app.name != null ? app.name : 'VALUE IS BLANK');
            Dom.XmlNode ffield15 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield15.setattribute('fieldId','15');
            ffield15.addTextNode(duetype);
            Dom.XmlNode ffield16 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield16.setattribute('fieldId','16');
            ffield16.addTextNode(upfrontreqReasonv);
            AppliNumber = (app.genesis__Application__r.Name != null ? app.genesis__Application__r.Name : 'VALUE IS BLANK');
            Dom.XmlNode ffield17 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield17.setattribute('fieldId','17');
            ffield17.addTextNode(AppliNumber);
            Dom.XmlNode ffield18 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
            ffield18.setattribute('fieldId','18');
            ffield18.addTextNode(upTaxAmtv);
            // End: FlexibleCodeField Tag

            // Start: FlexibleNumericField Tag
            /*Integer LengthofAppContract ;
            Date sdate=app.genesis__Application__r.genesis__Expected_Start_Date__c;
            system.debug('starttttt date'+sdate); 
            Date mdate=app.genesis__Application__r.genesis__Expected_Close_Date__c; 
            system.debug('Closeeee date'+sdate); 
            LengthofAppContract = sdate.daysBetween(Date.valueOf(mdate));
            System.debug('lengthhhhhhhh of contract'+LengthofAppContract) ;*/

            Date sdate=app.genesis__Application__r.genesis__Expected_Start_Date__c;
            
            Dom.XmlNode ffield21 = FFields.addChildElement('urn:FlexibleNumericField',null,null);
            ffield21.setattribute('fieldId','1');
            ffield21.addTextNode(String.valueOf(lengthOfContract));
            Dom.XmlNode ffield22 = FFields.addChildElement('urn:FlexibleNumericField',null,null);
            ffield22.setattribute('fieldId','2');
            ffield22.addTextNode(cumulTaxv);
            Dom.XmlNode ffield23 = FFields.addChildElement('urn:FlexibleNumericField',null,null);
            ffield23.setattribute('fieldId','3');
            ffield23.addTextNode(slbPaidv);
            Dom.XmlNode ffield24 = FFields.addChildElement('urn:FlexibleNumericField',null,null);
            ffield24.setattribute('fieldId','4');
            ffield24.addTextNode(qtpCodev);
            Dom.XmlNode ffield25 = FFields.addChildElement('urn:FlexibleNumericField',null,null);
            ffield25.setattribute('fieldId','5');
            ffield25.addTextNode(qrsCodev);
            // End: FlexibleNumericField Tag

            // FlexibleDateField Tag
            string appsdate = formatDate(sdate);
            Dom.XmlNode ffield31 = FFields.addChildElement('urn:FlexibleDateField',null,null);
            ffield31.setattribute('fieldId','1');
            ffield31.addTextNode(appsdate);
            
        }

        String req = scdoc.toXmlString();
        System.debug(LoggingLevel.ERROR, ' Request Str for Application Equipment: '+ req);

        return scdoc;
    }  
    // End
        /**
     *  Following method helps in forming Self Adjustment xml for Charge Details
     **/  
    public static Dom.Document getDistributedTaxAdjustmentXml(cllease__Charge__c charge) {
        Dom.Document scdoc = new Dom.Document();
        
        if(Charge != NULL)
        {
			// Getting Vertex API Configuration from customerom settings
			VertexApi__c vertexConfig = CLSCustomUtil.getVertexConfiguration();
			validateVertexConfig(vertexConfig);

			System.debug(LoggingLevel.ERROR, ' Vertex Configuration: ' + vertexConfig);

			String soapNS  = (vertexConfig.soapNS__c != null ? vertexConfig.soapNS__c : 'http://schemas.xmlsoap.org/soap/envelope/');
			String xsi     = (vertexConfig.XSI__c != null ? vertexConfig.XSI__c : 'urn:vertexinc:o-series:tps:8:0');

			DateTime currentSystemDate  =   cllease.SystemDateUtil.getCurrentSystemDate();
			String currentSystemDateStr =   formatDate(currentSystemDate);

			//Creating XML Formation Starts here
			String ApplNumber, contractDate, contractTerm, contractType, transactionCode, taxPaymentType; 
			String dueAmount, assetNumber, lineItemId;

			Dom.XmlNode envelope = scdoc.createRootElement('Envelope', soapNS, 'soapenv');
			envelope.setNamespace('urn', xsi);
				
			Dom.XmlNode header = envelope.addChildElement('Header', soapNS, null);
				
			Dom.XmlNode body = envelope.addChildElement('Body', soapNS, null);
			Dom.XmlNode vertexEnvelope = body.addChildElement('urn:VertexEnvelope', xsi, '');
			vertexEnvelope.setNamespace('xsi','http://www.w3.org/2001/XMLSchema-instance');

			Dom.XmlNode login =  vertexEnvelope.addChildElement('urn:Login', null,null);
			Dom.XmlNode uid =   login.addChildElement('urn:UserName',null,null).addTextNode(vertexConfig.Username__c);
			Dom.XmlNode pwd =   login.addChildElement('urn:Password', null,null).addTextNode(vertexConfig.Password__c);
				
			Dom.XmlNode distributedRequest = vertexEnvelope.addChildElement('urn:DistributeTaxRequest',null,null);
			distributedRequest.setAttribute('returnAssistedParametersIndicator', 'true');
			distributedRequest.setattribute('documentDate',currentSystemDateStr);
			distributedRequest.setAttribute('postingDate', currentSystemDateStr);
			//String dnumber = "ADJUST_" + "12345";
			distributedRequest.setAttribute('documentNumber', 'ADJUST_12345'); 
			distributedRequest.setattribute('transactionType','LEASE');
			Dom.XmlNode curency  =  distributedRequest.addChildElement('urn:Currency',null,null);
			curency.setAttribute('isoCurrencyCodeAlpha', 'USD');
			
			Dom.XmlNode seller  =  distributedRequest.addChildElement('urn:Seller',null,null);
			seller.addChildElement('urn:Company',null,null).addTextNode(vertexConfig.Company__c);
			seller.addChildElement('urn:Division',null,null).addTextNode(vertexConfig.Division__c);

			Date startDate, endDate;
			Integer lengthOfContract;

		   
				// Calculating Length of contract
				startDate = charge.cllease__Lease_Account__r.cllease__First_Payment_Date__c;
				endDate   = charge.cllease__Lease_Account__r.cllease__Maturity_Date__c;
				lengthOfContract = startDate.daysBetween(endDate);


				lineItemId= (charge.Name!=null?charge.Name:'VALUE IS BLANK');
				Dom.XmlNode lineItem   =   distributedRequest.addChildElement('urn:LineItem',null,null);
				lineItem.setattribute('lineItemId',lineItemId);
				lineItem.setAttribute('lineItemNumber', lineItemId);
				lineItem.setAttribute('taxDate',currentSystemDateStr);
				lineItem.setAttribute('transactionType', 'LEASE') ;
														 
				// Start: Customer Tag      
				Dom.XmlNode customer    =   lineItem.addChildElement('urn:Customer',null,null);

				// Tax Exempt Check
				Boolean isTaxExempted = false;
				// 1. Always check for Tax Exemption from Account , if not exempted check for equipment
				if(charge.cllease__Lease_Account__c != null
					&& charge.cllease__Lease_Account__r.cllease__Account__c != null)
				{
					// TODO: Needs to change Salesforce only support 3 levels for pulling values
					isTaxExempted = charge.cllease__Lease_Account__r.cllease__Account__r.Tax_Exempt__c;
					system.debug('Charge AccountTax Exemption :'+ isTaxExempted);
				} 
				// 2. Check for Equipment's Tax Exempt only if Account is not Exempted
				if(isTaxExempted == false
					&& charge.cllease__Contract_Equipment__c != null)
				{
					isTaxExempted = charge.cllease__Contract_Equipment__r.cllease__Tax_exemption__c;
					system.debug('Charge contract Tax Exemption: '+isTaxExempted);
				}
				
				if(isTaxExempted) 
				{
					customer.setattribute('isTaxExempt','true');
					customer.setattribute('exemptionReasonCode','MISS');
				} else 
				{
					customer.setattribute('isTaxExempt','false');
				}

				Dom.XmlNode destination = customer.addChildElement('urn:Destination', null, null);
				String cityValue    = (charge.DestinationCity__c != null ? charge.DestinationCity__c : 'VALUE IS BLANK');
				Dom.XmlNode city    = destination.addChildElement('urn:City',null,null);
				city.addTextNode(cityValue);

				String mainDivisionValue = (charge.Destinationstate__c != null ? charge.Destinationstate__c : 'VALUE IS BLANK');
				Dom.XmlNode mainDivision = destination.addChildElement('urn:MainDivision',null,null);
				mainDivision.addTextNode(mainDivisionValue);

				String zipCodeValue  = (charge.DestinationZipCode__c != null ? charge.DestinationZipCode__c : 'VALUE IS BLANK');
				Dom.XmlNode zipCode  = destination.addChildElement('urn:PostalCode',null,null);
				zipCode.addTextNode(zipCodeValue);
				// End: Customer Tag

				// Product Tag
				String productValue = (charge.cllease__Contract_Equipment__r.GARD__c != null ? charge.cllease__Contract_Equipment__r.GARD__c : 'VALUE IS BLANK');
				lineItem.addChildElement('urn:Product',null,null).addTextNode(productValue);

				// ExtendedPrice Tag
				Decimal chargeAmount = (charge.cllease__Original_Amount__c !=null ? charge.cllease__Original_Amount__c : 0.00);
				chargeAmount = cllease.ValueUtil.round(chargeAmount, 2 , 'Nearest');
				chargeAmount = chargeAmount * -1;
				String extdPrice = String.valueof(chargeAmount);
				lineItem.addChildElement('urn:InputTotalTax',null,null).addTextNode(extdPrice);

				// Start: FlexibleFields Tag
				// Start: FlexibleCodeField Tag
				Dom.XmlNode FFields =  lineItem.addChildElement('urn:FlexibleFields',null,null);
				Dom.XmlNode ffield1 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
				ffield1.setattribute('fieldId','1');
				ffield1.addTextNode(transCodev);
				Dom.XmlNode ffield2 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
				ffield2.setattribute('fieldId','2');
				ffield2.addTextNode(contrTypev);
				Dom.XmlNode ffield3 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
				ffield3.setattribute('fieldId','3');
				ffield3.addTextNode(dtaxPmtTypev);
				Dom.XmlNode ffield4 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
				ffield4.setattribute('fieldId','4');
				ffield4.addTextNode(leaseTypev);
				Dom.XmlNode ffield5 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
				ffield5.setattribute('fieldId','5');
				ffield5.addTextNode(titleTxfrv);
				Dom.XmlNode ffield9 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
				ffield9.setattribute('fieldId','9');
				ffield9.addTextNode('CLS-cllease__Charge__c');
				assetNumber = (charge.cllease__Contract_Equipment__r.Name != null ? charge.cllease__Contract_Equipment__r.Name : 'VALUE IS BLANK');
				Dom.XmlNode ffield10 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
				ffield10.setattribute('fieldId','10');
				ffield10.addTextNode(assetNumber);
				Dom.XmlNode ffield11 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
				ffield11.setattribute('fieldId','11');
				ffield11.addTextNode('0');
				Dom.XmlNode ffield12 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
				ffield12.setattribute('fieldId','12');
				ffield12.addTextNode('0');
				ApplNumber = (charge.cllease__Lease_Account__r.cllease__application_number__c != null? charge.cllease__Lease_Account__r.cllease__application_number__c :'VALUE IS BLANK');
				Dom.XmlNode ffield17 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
				ffield17.setattribute('fieldId','17');
				ffield17.addTextNode(ApplNumber);
				// End: FlexibleCodeField Tag

				// Start: FlexibleNumericField Tag
				Dom.XmlNode ffield21 = FFields.addChildElement('urn:FlexibleNumericField',null,null);
				ffield21.setattribute('fieldId','1');
				ffield21.addTextNode(String.valueOf(lengthOfContract));
				Dom.XmlNode ffield22 = FFields.addChildElement('urn:FlexibleNumericField',null,null);
				ffield22.setattribute('fieldId','2');
				ffield22.addTextNode(cumulTaxv);
				// End: FlexibleNumericField Tag

				// FlexibleDateField Tag
				DateTime contracDate = (charge.cllease__Lease_Account__r.cllease__Contract_Date__c!=null ? charge.cllease__Lease_Account__r.cllease__Contract_Date__c :currentSystemDate);
				String cdate = formatDate(contracDate);
				Dom.XmlNode ffield31 = FFields.addChildElement('urn:FlexibleDateField',null,null);
				ffield31.setattribute('fieldId','1');
				ffield31.addTextNode(cdate);
			
			String req = scdoc.toXmlString();
			System.debug(LoggingLevel.ERROR, ' Request Str for Tax Adjustment: '+ req);
            return scdoc;
	    }
        return scdoc;
    } 

    // Validating Vertex Configuration
    public static void validateVertexConfig(VertexApi__c vertexConfig) {
        // Do Validation on Vertex API Configuration
        if(vertexConfig.Username__c == null || vertexConfig.Username__c == '') {
            throw new CLSCustomException('Vertex UserName missing from Vertex API Custom Settings...');
        }

        if(vertexConfig.Password__c == null || vertexConfig.Password__c == '') {
            throw new CLSCustomException('Vertex Password missing from Vertex API Custom Settings...');
        }

        if(vertexConfig.Company__c == null || vertexConfig.Company__c == '') {
            throw new CLSCustomException('Vertex Company missing from Vertex API Custom Settings...');
        }

        if(vertexConfig.Division__c == null || vertexConfig.Division__c == '') {
            throw new CLSCustomException('Vertex Division missing from Vertex API Custom Settings...');
        }

        if(vertexConfig.End_point__c == null || vertexConfig.End_point__c == '') {
            throw new CLSCustomException('Vertex End Point missing from Vertex API Custom Settings...');
        }
    }

}