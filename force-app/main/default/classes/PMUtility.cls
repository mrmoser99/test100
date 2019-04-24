/*******************************************************************************************************************
*   Portfolio Manager Utility
*
* 
*	Change Log: 
*	3/15/19 - MRM Created
*   4/17/19 - Started mapping for all services
*
********************************************************************************************************************/
public with sharing class PMUtility {
    
    //wrapper classs or search results

    
    public class ServiceContractData{

        @AuraEnabled public Common common;
        @AuraEnabled public List<Data> data;
        
    }

    public class Common{

         @AuraEnabled public Links links;
         @AuraEnabled public Meta meta;
    }

     public class Links{
 
        @AuraEnabled public String self;
        @AuraEnabled public String first;
        @AuraEnabled public String prev;
        @AuraEnabled public String next;
        @AuraEnabled public String last;
    
    }

    public class Meta{

         @AuraEnabled public Integer itemTotal;
         @AuraEnabled public Integer size;
         @AuraEnabled public Integer page;
         @AuraEnabled public Integer pageTotal;
         @AuraEnabled public List<String> sortableFields;

    }

     

    public class Data{
        
        @AuraEnabled public String contractNumber;
        @AuraEnabled public String contractType;
        @AuraEnabled public String contractTerm;
        @AuraEnabled public String contractPeriodicity;
        @AuraEnabled public String contractPurchaseOption;
        @AuraEnabled public String contractProgramId;
        @AuraEnabled public String contractProgramName;
        @AuraEnabled public String contractStartDate;
        @AuraEnabled public String contractExpireDate;
        @AuraEnabled public String contractOriginalCost;
        @AuraEnabled public String contractPayment;
        @AuraEnabled public String contractAverageDaysToPay;
        @AuraEnabled public String contractSigner;
        @AuraEnabled public String contractSignerTitle;
        @AuraEnabled public String equipmentDescription;
        @AuraEnabled public String leaseSignerTitle;
        @AuraEnabled public String numberOfRemainingPayments;
        @AuraEnabled public String lastPaymentReceivedDate;
        @AuraEnabled public String businessSegment;
        @AuraEnabled public String subBusinessSegment;
        @AuraEnabled public String customerName;
        @AuraEnabled public String customerNumber;
        @AuraEnabled public String customerAddressLine1;
        @AuraEnabled public String customerAddressline2;
        @AuraEnabled public String customerCity;
        @AuraEnabled public String customerState;
        @AuraEnabled public String customerZipCode;
        @AuraEnabled public String billingAddressLine1;
        @AuraEnabled public String billingAddresslilne2;
        @AuraEnabled public String billingCity;
        @AuraEnabled public String billingState;
        @AuraEnabled public String billingZipCode;
        @AuraEnabled public String vendorSiteCode;
        @AuraEnabled public String vendorNumber1;
        @AuraEnabled public String vendorNumber2;
        @AuraEnabled public String vendorNumber3;
        @AuraEnabled public String vendorName;
        @AuraEnabled public String vendorAddressLine1;
        @AuraEnabled public String vendorAddressLine2;
        @AuraEnabled public String vendorCity;
        @AuraEnabled public String vendorState;
        @AuraEnabled public String vendorZipCode;
        @AuraEnabled public Boolean newcoReady;


        @AuraEnabled public List<assetDetail> assetDetail;

       
    }
    

     //wrapper classs for detail of a single asset

    public class assetDetail{

        @AuraEnabled public Integer assetSequenceNumber;
        @AuraEnabled public String assetDescription;
        @AuraEnabled public String assetManufacturer;
        @AuraEnabled public String assetMake;
        @AuraEnabled public String assetModel;
        @AuraEnabled public String assetSerialNumber;
        @AuraEnabled public String assetAddressLine1;
        @AuraEnabled public String assetAddressLine2;
        @AuraEnabled public String assetCity;
        @AuraEnabled public String assetState;
        @AuraEnabled public String assetZipCode;
        @AuraEnabled public Decimal assetPayment;

    }




    //wrapper classs for detail of a single quote

    public class quoteDetail{
        @AuraEnabled public String quoteNumber;
        @AuraEnabled public String type;
        @AuraEnabled public String quoteAmount;
         /* 
        field 1
        field 2
        field 3
        ...
        field n
        */


        public quoteDetail(String quoteNumber){
            this.quoteNumber = quoteNumber;
        }

    }

     //wrapper classs for detail of a single quote

    public class quoteSummary{
        @AuraEnabled public String quoteNumber;
        @AuraEnabled public String type;
        @AuraEnabled public String amount;
        

        public quoteSummary(String quoteNumber){
            
            this.quoteNumber = quoteNumber;
           

        }

    }

    /************************************************************************************************************************************************************
    *
    *   Calls to return data from api's 
    *
    *    size
    *        Specifies the maximum number of items to be returned in the result collection. Default if not specified: 20
    *    sortOrder
    *        Specifies the sorting order of the asset-level collection. 
    *        Standard sorting prefix "-" indicates descending order. Multiple fields may be specified as a comma-delimited list. Valid field names: customerName, contractNumber, numberOfRemainingPayments, customerZipCode. Default sort order is: customerName, contractNumber
    *    assetDetail
    *       A boolean that specifies whether Asset Detail is to be included in the response for each returned contract.   
    *
    *    Customer Name Search Examples
    *    ABC* matches value that begins with ABC
    *    *ABC matches value that ends with ABC
    *    *ABC* matches value that contains ABC
    *    *ABC*DEF* Matches value containing ABC anywhere in the value followed by DEF anywhere in the value
    *    ABC*DEF Matches value ABC\*DEF exactly
    *
    *
    *************************************************************************************************************************************************************/

    public static ServiceContractData searchPortfolio(String customerName
                                    , String customerNumber
                                    , String assetSerialNumber
                                    , Integer size
                                    , String sortOrder
                                    , Boolean assetDetail
                                    , Integer page){
        
        Integer offset = page * size;

        String searchCustomerName = '%' + customerName + '%';
        String searchCustomerNumber = '%' + customerNumber + '%';
        
        List<Portfolio_Equipment__c> eList = new List<Portfolio_Equipment__c>();
        List<Portfolio_Contract__c> clist = new  List<Portfolio_Contract__c>();
        
        Map<ID,List<Portfolio_Equipment__c>> eMap = new Map<ID,List<Portfolio_Equipment__c>>();
        Set<ID> contractSet = new Set<ID>();

        if (assetSerialNumber != ''){
            
            eList = [select  Portfolio_Contract__c
                            ,assetDescription__c
                            ,assetMake__c
                            ,assetManufacturer__c
                            ,assetModel__c
                            ,assetPayment__c
                            ,assetSequenceNumber__c
                            ,assetSerialNumber__c
                            ,assetState__c
                            ,assetZipCode__c
                    from Portfolio_Equipment__c
                    where assetSerialNumber__c = :assetSerialNumber
                    ];
            
            if (!elist.isEmpty()){
                eMap.put(eList[0].portfolio_contract__c,eList);

                clist = [SELECT billingAddressLine1__c
                                            ,billingAddressLine2__c,billingCity__c,billingState__c,billingZipCode__c,businessSegment__c,contractAverageDaysToPay__c              ,contractExpireDate__c
                                            ,contractNumber__c,contractOriginalCost__c,contractPayment__c,contractPeriodicity__c,contractProgramId__c,contractProgramName__c
                                            ,contractPurchaseOption__c,contractSignerTitle__c,contractSigner__c,contractStartDate__c,contractTerm__c                            ,contractType__c
                                            ,CreatedById,CreatedDate,customerAddressLine1__c,customerAddressline2__c,customerCity__c,customerName__c,customerNumber__c
                                            ,customerState__c,customerZipCode__c,lastPaymentReceivedDate__c,leaseSignerTitle__c,Name,nbrOfAssets__c,numberOfRemainingPayments__c
                                            ,phone__c,subBusinessSegment__c,vendorAddressLine1__c,vendorAddressLine2__c,vendorCity__c,vendorName__c,vendorNumber1__c
                                            ,vendorNumber2__c,vendorNumber3__c,vendorSiteCode__c,vendorState__c,vendorZipCode__c                                             FROM Portfolio_Contract__c  
                                            where id in :emap.keySet()
                                            limit 50
                                            ];  
            }      
        }
        else{
        if (customerName != '' || customerNumber != ''){
             clist = [SELECT billingAddressLine1__c
                                             ,billingAddressLine2__c,billingCity__c,billingState__c,billingZipCode__c,businessSegment__c,contractAverageDaysToPay__c              ,contractExpireDate__c
                                            ,contractNumber__c,contractOriginalCost__c,contractPayment__c,contractPeriodicity__c,contractProgramId__c,contractProgramName__c
                                            ,contractPurchaseOption__c,contractSignerTitle__c,contractSigner__c,contractStartDate__c,contractTerm__c                            ,contractType__c
                                            ,CreatedById,CreatedDate,customerAddressLine1__c,customerAddressline2__c,customerCity__c,customerName__c,customerNumber__c
                                            ,customerState__c,customerZipCode__c,lastPaymentReceivedDate__c,leaseSignerTitle__c,Name,nbrOfAssets__c,numberOfRemainingPayments__c
                                            ,phone__c,subBusinessSegment__c,vendorAddressLine1__c,vendorAddressLine2__c,vendorCity__c,vendorName__c,vendorNumber1__c
                                            ,vendorNumber2__c,vendorNumber3__c,vendorSiteCode__c,vendorState__c,vendorZipCode__c    
                                            FROM Portfolio_Contract__c  
                                            where customerName__c like :searchCustomerName
                                            and
                                            customerNumber__c like: searchCustomerNumber
                                            limit 50
                                            ];           
        
        }
        else{
            clist = [SELECT billingAddressLine1__c
                                             ,billingAddressLine2__c,billingCity__c,billingState__c,billingZipCode__c,businessSegment__c,contractAverageDaysToPay__c              ,contractExpireDate__c
                                            ,contractNumber__c,contractOriginalCost__c,contractPayment__c,contractPeriodicity__c,contractProgramId__c,contractProgramName__c
                                            ,contractPurchaseOption__c,contractSignerTitle__c,contractSigner__c,contractStartDate__c,contractTerm__c                            ,contractType__c
                                            ,CreatedById,CreatedDate,customerAddressLine1__c,customerAddressline2__c,customerCity__c,customerName__c,customerNumber__c
                                            ,customerState__c,customerZipCode__c,lastPaymentReceivedDate__c,leaseSignerTitle__c,Name,nbrOfAssets__c,numberOfRemainingPayments__c
                                            ,phone__c,subBusinessSegment__c,vendorAddressLine1__c,vendorAddressLine2__c,vendorCity__c,vendorName__c,vendorNumber1__c
                                            ,vendorNumber2__c,vendorNumber3__c,vendorSiteCode__c,vendorState__c,vendorZipCode__c    
                                            FROM Portfolio_Contract__c  
                                            limit :size OFFSET : integer.valueOf(offset)
                                            ];           
        
            }
            for (Portfolio_Contract__c  c:cList)
                contractSet.add(c.id);


            eList = [select Portfolio_Contract__c
                            ,assetDescription__c
                            ,assetMake__c
                            ,assetManufacturer__c
                            ,assetModel__c
                            ,assetPayment__c
                            ,assetSequenceNumber__c
                            ,assetSerialNumber__c
                            ,assetState__c
                            ,assetZipCode__c
                    from Portfolio_Equipment__c
                    where Portfolio_Contract__c in :contractSet
            ];
            
            for (Portfolio_Equipment__c e:eList){
                List<Portfolio_Equipment__c> temp = new List<Portfolio_Equipment__c>();

                if (eMap.get(e.portfolio_contract__c) == null){
                    temp.add(e);
                }
                else{
                    temp = eMap.get(e.portfolio_contract__c);
                    temp.add(e);
                }
                eMap.put(e.portfolio_contract__c,temp);
            }


        } //end else
        
        
        List<Data> dList = new List<Data>();
        ServiceContractData response = new ServiceContractData();

        Meta m = new Meta();
        m.itemTotal = 50;
        m.size = 50;
        m.page = page;
        m.pageTotal = 0;
        m.sortableFields = null;

        Common cm = new Common();
        cm.meta = m;

        for (Portfolio_Contract__c c:cList){

            Data d = new Data();
            d.contractNumber = c.contractNumber__c;
            d.customerName = c.customerName__c;
            d.customerZipCode = c.billingZipCode__c;
            d.contractStartDate = c.contractStartDate__c;
            d.contractTerm = c.contractTerm__c;
            d.numberOfRemainingPayments = c.numberOfRemainingPayments__c;
            d.equipmentDescription = '?';
            d.contractOriginalCost = c.contractOriginalCost__c;
            d.contractPayment = c.contractPayment__c;
            d.contractType = c.contractType__c;
            d.newcoReady = true;
            d.equipmentDescription = 'Equipment Count: ' + c.nbrOfAssets__c;


            List<assetDetail> aList = new List<assetDetail>();
            
            List<Portfolio_Equipment__c> contractEquipmentList = eMap.get(c.id);
            if (!contractEquipmentList.isEmpty()){

                assetDetail a = new assetDetail();
                for (Portfolio_Equipment__c e: eMap.get(c.id)){
                    a = new assetDetail();
                    a.assetSequenceNumber = integer.valueOf(e.assetSequenceNumber__c);
                    a.assetDescription = e.assetDescription__c;
                    a.assetManufacturer = e.assetManufacturer__c;
                    a.assetMake = e.assetMake__c;
                    a.assetModel = e.assetModel__c;
                    a.assetSerialNumber = e.assetSerialNumber__c;
                    a.assetAddressLine1 = null;
                    a.assetAddressLine2 = null;
                    a.assetCity = null;
                    a.assetState = e.assetState__c;
                    a.assetZipCode = e.assetZipCode__c;
                    a.assetPayment =null;
                   
                    aList.add(a);
                }
                
            }

            d.assetDetail = aList;

            dList.add(d);

        }
        
        response.common = cm;  
        response.data = dList;
        
        return response;

        
    }

    /************************************************************************************************************************************************************
    *   getLeaseDetails
    *************************************************************************************************************************************************************/

    public static String getLeaseDetails(String leaseNumber){
        
        String response;

        return JSON.serialize(response); 

    }
     /************************************************************************************************************************************************************
    *   generateQuotes
    *************************************************************************************************************************************************************/

    public static String generateQuotes(String leaseNumber){
        
        String response; 

        List<quoteSummary> qsList = new List<quoteSummary>();

        return JSON.serialize(response);  

    }
    
    /************************************************************************************************************************************************************
    *   getQuotes
    *************************************************************************************************************************************************************/

    public static String getQuoteDetail(String quoteNumber){
        
        String response;

        quoteDetail qd = new quoteDetail(quoteNumber);
        
        return JSON.serialize(response);  

    }

    /************************************************************************************************************************************************************
    *   processOLMBooking
    *************************************************************************************************************************************************************/

    public static boolean processOLMBooking(String leaseNumber, String quoteNumber, Decimal amount){
        
       return true;

    }
}