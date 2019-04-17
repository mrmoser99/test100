public with sharing class PM_Controller {
     
    @AuraEnabled
    public static List<PMUtility.resultLine> searchResults {get;set;} 
    /********************************************************************************************
   	* Search
   	* 
   	********************************************************************************************/
    @AuraEnabled
    public static String searchPortfolio(String customerName
                                    , String customerNumber
                                    , String assetSerialNumber
                                    , String choice
                                    , String size
                                    , String sortOrder
                                    , Boolean assetDetail
                                    , Integer intOffSet){   
        
        return PMUtility.searchPortfolio(customerName
                                        ,customerNumber
                                        ,assetSerialNumber
                                        ,choice
                                        ,size
                                        ,sortOrder
                                        ,assetDetail
                                        ,intOffSet);
        
    }

    /********************************************************************************************
   	* Lease details for a single lease
   	* 
   	********************************************************************************************/
    @AuraEnabled
    public static PMUtility.leaseDetail getLeaseDetails(String leaseNumber){   
         
        return PMUtility.getLeaseDetails(leaseNumber);
    } 

    /********************************************************************************************
   	* Quote List - high leve info about generated quotes.
   	* 
   	********************************************************************************************/
    @AuraEnabled
    public static List<PMUtility.quoteSummary> generateQuotes(String leaseNumber){   
        
        return PMUtility.generateQuotes(leaseNumber);
        
        
    } 

    /********************************************************************************************
   	* Quote Detail - detail inquiry information for a single quote
   	* 
   	********************************************************************************************/
    @AuraEnabled
    public static PMUtility.quoteDetail getQuoteDetail(String quoteNumber){   
        
        return PMUtility.getQuoteDetail(quoteNumber);
    } 

    /********************************************************************************************
   	* Book Lease - calls the olm book lease process
   	* 
   	********************************************************************************************/
    @AuraEnabled
    public static boolean processOLMBooking(String leaseNumber, String quoteNumber, Decimal amount) {   
        
        return PMUtility.processOLMBooking(leaseNumber,quoteNumber,amount);
         
    } 

    
}