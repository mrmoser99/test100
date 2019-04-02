/**
*  Author: Cloud Lending Solutions
*  Description: Object Wrapper for verterx response 
*
**/
public class VertexAPI {
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
                                        Public static Dom.Document getUpfrontXml(VertexRequestObject vro){
                                            
                                            // Getting Vertex API Configuration from customerom settings & Validating
                                            VertexApi__c vertexConfig = CLSCustomUtil.getVertexConfiguration();
                                            vertexUtil.validateVertexConfig(vertexConfig);
                                            String soapNS  = (vertexConfig.soapNS__c != null ? vertexConfig.soapNS__c : 'http://schemas.xmlsoap.org/soap/envelope/');
                                            String xsi     = (vertexConfig.XSI__c != null ? vertexConfig.XSI__c : 'urn:vertexinc:o-series:tps:8:0');
                                            
                                            DateTime currentSystemDate  =   cllease.SystemDateUtil.getCurrentSystemDate();
                                            String currentSystemDateStr =   formatDate(currentSystemDate);
                                            
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
                                            invoiceRequest.setattribute('documentDate',currentSystemDateStr);
                                            invoiceRequest.setattribute('transactionType','LEASE');
                                            
                                            Dom.XmlNode seller  =  invoiceRequest.addChildElement('urn:Seller',null,null);
                                            seller.addChildElement('urn:Company',null,null).addTextNode(vertexConfig.Company__c);
                                            seller.addChildElement('urn:Division',null,null).addTextNode(vertexConfig.Division__c);
                                            
                                            Date startDate, endDate;
                                            Integer lengthOfContract;
                                            //for(VertexRequestObject vro: RequestList){
                                            
                                            // Calculating the Length of Contract from first payment date to maturity date
                                            startDate = Date.valueof(vro.startDate);
                                            //system.debug('start date'+startDate) ;
                                            endDate   = Date.valueof(vro.endDate);
                                            //system.debug('emd date'+endDate) ;
                                            lengthOfContract = startDate.daysBetween(endDate);
                                            //system.debug('length in days'+lengthOfContract);
                                            
                                            lineItemId = (vro.id != null ? vro.id : 'VALUE IS BLANK');
                                            Dom.XmlNode lineItem = invoiceRequest.addChildElement('urn:LineItem', null, null);
                                            lineItem.setattribute('lineItemId', lineItemId);
                                            // Start: Customer Tag
                                            Dom.XmlNode customer = lineItem.addChildElement('urn:Customer',null,null);
                                            customer.setattribute('isTaxExempt','false');
                                            
                                            Dom.XmlNode destination = customer.addChildElement('urn:Destination', null, null);
                                            String cityValue    =  (vro.City != null ? vro.City : 'VALUE IS BLANK');
                                            Dom.XmlNode city    = destination.addChildElement('urn:City',null,null);
                                            city.addTextNode(cityValue);
                                            
                                            String mainDivisionValue = (vro.State != null ? vro.State : 'VALUE IS BLANK');
                                            Dom.XmlNode mainDivision = destination.addChildElement('urn:MainDivision',null,null);
                                            mainDivision.addTextNode(mainDivisionValue);
                                            
                                            String zipCodeValue  = (vro.ZipCode != null ? vro.ZipCode : 'VALUE IS BLANK');
                                            Dom.XmlNode zipCode  = destination.addChildElement('urn:PostalCode',null,null);
                                            zipCode.addTextNode(zipCodeValue);
                                            // End: Customer Tag
                                            
                                            // Product Tag
                                            String productValue = (vro.name != null ? vro.name : 'VALUE IS BLANK');
                                            lineItem.addChildElement('urn:Product',null,null).addTextNode(productValue);
                                            
                                            // ExtendedPrice Tag
                                            Decimal ddlAmount = (Decimal.valueof(vro.sellingPrice) !=null ? Decimal.valueof(vro.sellingPrice) : 0.00);
                                            ddlAmount = cllease.ValueUtil.round(ddlAmount, 2 , 'Nearest');
                                            String extdPrice = String.valueof(ddlAmount);
                                            lineItem.addChildElement('urn:ExtendedPrice',null,null).addTextNode(extdPrice);
                                            
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
                                            assetNumber = (vro.serialnumber != null ? vro.serialnumber :'VALUE IS BLANK');
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
                                            String duetype = (vro.name != null ? vro.name : 'VALUE IS BLANK');
                                            Dom.XmlNode ffield15 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                                            ffield15.setattribute('fieldId','15');
                                            ffield15.addTextNode(duetype);
                                            Dom.XmlNode ffield16 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                                            ffield16.setattribute('fieldId','16');
                                            ffield16.addTextNode(upfrontreqReasonv);
                                            AppliNumber = 'VALUE IS BLANK';//(vro.AppName != null ? vro.AppName : 'VALUE IS BLANK');
                                            Dom.XmlNode ffield17 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                                            ffield17.setattribute('fieldId','17');
                                            ffield17.addTextNode(AppliNumber);
                                            Dom.XmlNode ffield18 = FFields.addChildElement('urn:FlexibleCodeField',null,null);
                                            ffield18.setattribute('fieldId','18');
                                            ffield18.addTextNode(upTaxAmtv);
                                            // End: FlexibleCodeField Tag
                                            
                                            // Start: FlexibleNumericField Tag
                                            Integer LengthofAppContract ;
                                            Date sdate=Date.valueof(vro.StartDate);
                                            //('starttttt date'+sdate); 
                                            Date mdate=Date.valueOf(vro.EndDate); 
                                            //system.debug('Closeeee date'+sdate); 
                                            LengthofAppContract = sdate.daysBetween(Date.valueOf(mdate));
                                            //System.debug('lengthhhhhhhh of contract'+LengthofAppContract) ;
                                            
                                            Dom.XmlNode ffield21 = FFields.addChildElement('urn:FlexibleNumericField',null,null);
                                            ffield21.setattribute('fieldId','1');
                                            ffield21.addTextNode(String.valueOf(LengthofAppContract));
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
                                            
                                            system.debug('scdoc--->'+scdoc.toXmlString());
                                            return scdoc;
                                        }
    // formate the Date to String
    private static String formatDate(DateTime d) {
        return d.year() + '-' + d.month() + '-' + d.day();
    } 
    Public Void upfrontTaxCalcualtion(List<id> ApplicationIdSet){
        //list<genesis__Application_Equipment__c> Applications = [Select id,name,Install_Address1__r.City__c,Install_Address1__r.State__c,Install_Address1__r.Zip_Code__c,genesis__Estimated_Selling_Price__c from genesis__Application_Equipment__c where id IN :ApplicationIdSet];
        List<VertexRequestObject> ROList = new list<VertexRequestObject>();
        list<Dom.Document> DDList = new list<Dom.Document>();
        for(genesis__Application_Equipment__c gae : [Select id,genesis__Application__r.genesis__Expected_Close_Date__c,genesis__Application__r.genesis__Expected_Start_Date__c,Serial_Number__c,name,genesis__Application__r.Name,Install_Address1__r.City__c,Install_Address1__r.State__c,Install_Address1__r.Zip_Code__c,genesis__Estimated_Selling_Price__c from genesis__Application_Equipment__c where genesis__Application__c IN :ApplicationIdSet limit 1]){
            VertexRequestObject vro = new VertexRequestObject();
            vro.id = gae.id;
            vro.Name = gae.Name;
            vro.AppName = gae.genesis__Application__r.Name;
            vro.city = gae.Install_Address1__r.City__c;
            vro.state = gae.Install_Address1__r.State__c;
            vro.zipcode = gae.Install_Address1__r.Zip_Code__c;
            vro.sellingPrice =  String.valueof(gae.genesis__Estimated_Selling_Price__c);
            vro.serialnumber = gae.Serial_Number__c;
            vro.StartDate = String.valueof(gae.genesis__Application__r.genesis__Expected_Start_Date__c);
            vro.EndDate = String.valueof(gae.genesis__Application__r.genesis__Expected_Close_Date__c);
            ROList.add(vro);
        }
        if(!ROList.isEmpty()){
            for(VertexRequestObject vro: ROList){
                DDList.add(getUpfrontXml(vro));    
            }
        }
        if(!DDList.isEmpty()){
            //multiple call outs
            for(dom.Document dd : DDList){
                VertexApi__c vertexConfig = CLSCustomUtil.getVertexConfiguration(); 
                VertexUtil.validateVertexConfig(vertexConfig);
                //System.debug(LoggingLevel.ERROR, '=================================');
                //System.debug(LoggingLevel.ERROR,'methoddoccc'+methoddoc.toXmlString());
                //System.debug(LoggingLevel.ERROR, '=================================');                
                // B.1 Creating Http Request
                HttpRequest req = new HttpRequest();
                HttpResponse res = new HttpResponse(); 
                req.setMethod('POST');
                req.setEndpoint(vertexConfig.End_Point__c);
                req.setHeader('Content-Type', 'text/xml');
                req.setBody(dd.toXMlString());
                
                Http http = new Http();
                // if (actual response ) else (test mock response)
                res = http.send(req);
                System.debug(LoggingLevel.ERROR, ' Response body: '+res.getbody());
                //string responseCode = res.getStatusCode();
                /**** ***/
                //Make callout
            }
        }
    }
}