/*******************************************************************************************************************
*   Portfolio Manager Utility
*
* 
*	Change Log: 
*	3/15/19 - MRM Created
*
********************************************************************************************************************/
public with sharing class PMUtility {
    
    //wrapper classs or search results

    public class resultLine{

        @AuraEnabled public String customerName;
        @AuraEnabled public String leaseNumber;
        @AuraEnabled public String postalCode;
        @AuraEnabled public Date contractStartDate;
        @AuraEnabled public String term;
        @AuraEnabled public String remainingPayments;
        @AuraEnabled public String equipmentDescription;
        @AuraEnabled public Decimal originalCost;
        @AuraEnabled public Decimal basePayment;
        @AuraEnabled public String type;
        @AuraEnabled public Boolean newcoReady;
        
        public resultLine(String customerName, String leaseNumber, String postalCode, Date contractStartDate, String term, String remainingPayments, String equipmentDescription,Decimal originalCost, Decimal  basePayment, String type, Boolean newcoReady){
            this.customerName = customerName;
            this.leaseNumber = leaseNumber;
            this.postalCode = postalCode;
            this.contractStartDate = contractStartDate;
            this.term = term; 
            this.remainingPayments = remainingPayments;
            this.equipmentDescription = equipmentDescription;
            this.originalCost = originalCost;
            this.basePayment = basePayment;
            this.type = type;
            this.newcoReady = newcoReady;

        }

    }

    //wrapper classs for detail of a single lease

    public class leaseDetail{
        
        @AuraEnabled public List<assetDetail> assetDetail;
        @AuraEnabled public String billingAddresslilne2;
        @AuraEnabled public String billingAddressLine1;
        @AuraEnabled public String billingCity;
        @AuraEnabled public String billingState;
        @AuraEnabled public String billingZipCode;
        @AuraEnabled public String businessSegment;
        @AuraEnabled public Integer contractAverageDaysToPay;
        @AuraEnabled public String contractExpireDate;
        @AuraEnabled public String contractNumber;
        @AuraEnabled public Decimal contractOriginalCost;
        @AuraEnabled public Decimal contractPayment;
        @AuraEnabled public String contractPeriodicity;
        @AuraEnabled public String contractProgramId;
        @AuraEnabled public String contractProgramName;
        @AuraEnabled public String contractPurchaseOption;
        @AuraEnabled public String contractSigner;
        @AuraEnabled public String contractSignerTitle;
        @AuraEnabled public String contractStartDate;
        @AuraEnabled public Integer contractTerm;
        @AuraEnabled public String contractType;
        @AuraEnabled public String customerAddressLine1;
        @AuraEnabled public String customerAddressline2;
        @AuraEnabled public String customerCity;
        @AuraEnabled public String customerName;
        @AuraEnabled public String customerNumber;
        @AuraEnabled public String customerState;
        @AuraEnabled public String customerZipCode;
        @AuraEnabled public String lastPaymentReceivedDate;
        @AuraEnabled public String leaseSignerTitle;
        @AuraEnabled public Integer numberOfRemainingPayments;
        @AuraEnabled public String subBusinessSegment;
        @AuraEnabled public String vendorAddressLine1;
        @AuraEnabled public String vendorAddressLine2;
        @AuraEnabled public String vendorCity;
        @AuraEnabled public String vendorName;
        @AuraEnabled public String vendorNumber1;
        @AuraEnabled public String vendorNumber2;
        @AuraEnabled public String vendorNumber3;
        @AuraEnabled public String vendorSiteCode;
        @AuraEnabled public String vendorState;
        @AuraEnabled public String vendorZipCode;
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
    *************************************************************************************************************************************************************/

    public static List<resultLine> searchPortfolio(String customerName
                                    , String customerNumber
                                    , String assetSerialNumber
                                    , String choice
                                    , String size
                                    , String sortOrder
                                    , Boolean assetDetail
                                    , Integer intOffSet){
       
        List<PMUtility.resultLine> searchResults = new List<PMUtility.resultLine>();
        //intOffSet = 0;

        List<Account> alist = [select id, name, Account_Number__c from Account where name like :customerName  limit 20 OFFSET : intOffSet];  
        Integer i = 19887;
        /*
        String customerName
        String leaseNumber
        String postalCode
        Date contractStartDate
        Integer term
        Integer remainingPayments
        String equipmentDescription
        Decimal originalCost
        Decimal  basePayment
        String type
        Boolean newcoReady
        */
        for (Account a: aList){ 
            i++;
            searchResults.add(new PMUtility.resultLine(a.name, a.account_number__c,string.valueOf(i),date.today(),'60','43','Equipment',i*100/12.2,i/33.22,'STD',true));
        }
        return searchResults;  
    }

    /************************************************************************************************************************************************************
    *   getLeaseDetails
    *************************************************************************************************************************************************************/

    public static leaseDetail getLeaseDetails(String leaseNumber){
        
        leaseDetail ld = new leaseDetail();

        return ld;

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