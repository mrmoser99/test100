/*******************************************************************************************************************
*   Portfolio Manager Utility
*
* 
*	Change Log: 
*	3/15/19 - MRM Created
*   4/17/19 - 
*
********************************************************************************************************************/
public with sharing class PMUtility {
    
    //wrapper classs or search results

    
    public class ServiceContractResponse{

        @AuraEnabled public Common common;
        @AuraEnabled public Data data;
        
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

    //wrapper classs for detail of a single lease

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
 
    public static String searchPortfolio(String customerName
                                    , String customerNumber
                                    , String assetSerialNumber
                                    , String choice
                                    , Integer size
                                    , String sortOrder
                                    , Boolean assetDetail
                                    , Integer intOffSet){
       
        ServiceContractResponse response = new ServiceContractResponse();
        //intOffSet = 0;

        //List<Account> alist = [select id, name, Account_Number__c from Portfoli_Contract__c where name like :customerName  limit 20 OFFSET : intOffSet];  
         
        
        //for (Account a: aList){ 
         
        //}

        return JSON.serialize(response);  
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

    public static List<quoteSummary> generateQuotes(String leaseNumber){
        
        String quoteNumber1; 

        List<quoteSummary> qsList = new List<quoteSummary>();

        return qsLIst;

    }
    
    /************************************************************************************************************************************************************
    *   getQuotes
    *************************************************************************************************************************************************************/

    public static quoteDetail getQuoteDetail(String quoteNumber){
        
        quoteDetail qd = new quoteDetail(quoteNumber);
        
        return qd;

    }

    /************************************************************************************************************************************************************
    *   processOLMBooking
    *************************************************************************************************************************************************************/

    public static boolean processOLMBooking(String leaseNumber, String quoteNumber, Decimal amount){
        
       return true;

    }
}