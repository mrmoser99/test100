public with sharing class PM_Controller {
     
    @AuraEnabled
    public static String searchResults {get;set;} 
    /********************************************************************************************
   	* Search
   	* 
   	********************************************************************************************/
    @AuraEnabled
    public static String searchPortfolio(String customerName
                                    , String customerNumber
                                    , String assetSerialNumber
                                    , String choice
                                    , Integer size
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
    public static String getLeaseDetails(String leaseNumber){   
         
        return PMUtility.getLeaseDetails(leaseNumber);
    } 

    /********************************************************************************************
   	* Quote List - high level info about generated quotes.
   	* 
   	********************************************************************************************/
    @AuraEnabled
    public static String generateQuotes(String leaseNumber){   
        
        return PMUtility.generateQuotes(leaseNumber);
        
        
    } 

    /********************************************************************************************
   	* Quote Detail - detail inquiry information for a single quote
   	* 
   	********************************************************************************************/
    @AuraEnabled
    public static String getQuoteDetail(String quoteNumber){   
        
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