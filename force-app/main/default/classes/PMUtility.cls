/*******************************************************************************************************************
*   Portfolio Manager Utility
*
* 
*	Change Log: 
*	3/15/19 - MRM Created
*   4/17/19 - Started mapping for all services
*
********************************************************************************************************************/
public without sharing class PMUtility {
    
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
        
        /* portfolio */

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
        @AuraEnabled public String daysPastDue; //next sprint
        @AuraEnabled public String equipmentDescription;
        @AuraEnabled public Integer nbrOfAssets;
        @AuraEnabled public String leaseSignerTitle;
        @AuraEnabled public String numberOfRemainingPayments;
        @AuraEnabled public String lastPaymentReceivedDate;
        @AuraEnabled public String businessSegment;
        @AuraEnabled public String subBusinessSegment;
        @AuraEnabled public String customerName;
        @AuraEnabled public String olmCustomerNumber;  //next sprint
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
        
        
        /* Contract Inquiry */

        @AuraEnabled public String Arrears;
        @AuraEnabled public String Assignable_Yn;
        @AuraEnabled public String Bank_Account_Num;
        @AuraEnabled public String Billing_Group_Id;
        @AuraEnabled public String Billing_Group_Name;
        @AuraEnabled public String Billing_Group_Number;
        @AuraEnabled public String Code_Sales_Rep;
        @AuraEnabled public String Contract_Number;
        @AuraEnabled public String Contract_Status;
        @AuraEnabled public String x_Currency;
        @AuraEnabled public String Cust_Address;
        @AuraEnabled public String Cust_City;
        @AuraEnabled public String Cust_Country;
        @AuraEnabled public String Cust_County;
        @AuraEnabled public String Cust_First_Name;
        @AuraEnabled public String Cust_Last_Name;
        @AuraEnabled public String Cust_Legal_Name;
        @AuraEnabled public String Cust_Middle_Name;
        @AuraEnabled public String Cust_Postal_Code;
        @AuraEnabled public String Cust_State;
        @AuraEnabled public String Cust_Title;
        @AuraEnabled public String Customer_Id;
        @AuraEnabled public String Customer_Name;
        @AuraEnabled public String Customer_Number;
        @AuraEnabled public String Description;
        @AuraEnabled public String Discount_Rate;
        @AuraEnabled public String Effective_Date;
        @AuraEnabled public String Email_Address;
        @AuraEnabled public String End_Date;
        @AuraEnabled public String External_Contract_Number;
        @AuraEnabled public String Implicit_Rate;
        @AuraEnabled public String Lp_Program;
        @AuraEnabled public String Maximum_Due_Date;
        @AuraEnabled public String Number_Unbilled_Streams;
        @AuraEnabled public String Olm_Program;
        @AuraEnabled public String Op_Unit;
        @AuraEnabled public String Party_Id;
        @AuraEnabled public String Passive_Rate;
        @AuraEnabled public String Payment_Method;
        @AuraEnabled public String Periodicity;
        @AuraEnabled public String Print_Lead_Days;
        @AuraEnabled public String Product;
        @AuraEnabled public String Reference_Lessee;
        @AuraEnabled public String Remaining_Pymnts;
        @AuraEnabled public String Sb_Unit;
        @AuraEnabled public String Start_Date;
        @AuraEnabled public String Syndicated_Flag;
        @AuraEnabled public String Term;
        @AuraEnabled public String Termination_Date;
        @AuraEnabled public String Total_Fin_Amnt;

        /* general contract info call  can be merged into contract select with ecs in source system */

        @AuraEnabled public String Financialproduct;
        @AuraEnabled public String Purchaseoption;
        @AuraEnabled public String Numberofassets;
        @AuraEnabled public String Statetax;
        @AuraEnabled public String Countytax;
        @AuraEnabled public String Citytax;
        @AuraEnabled public String Districttax;
        @AuraEnabled public String Totalassetpayment;
        @AuraEnabled public String Paymentfrequency;
        @AuraEnabled public String Dayspastdue;


        /* end contract Extension */

        /* contract search */
        @AuraEnabled public String PaymentReceivedDate;
        @AuraEnabled public String PaymentAmountReceived;
        @AuraEnabled public String PaymentNumber;  //check number


        /* end contract search */

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

        /* contract select  */
        @AuraEnabled public String Asset_Category;
        @AuraEnabled public String Asset_Cndtn;
        @AuraEnabled public String Asset_Number;
        @AuraEnabled public String Asset_Status;
        @AuraEnabled public String Billing_City;
        @AuraEnabled public String Billing_Country;
        @AuraEnabled public String Billing_County;
        @AuraEnabled public String Billing_Group_Id;
        @AuraEnabled public String Billing_Location;
        @AuraEnabled public String Billing_State;
        @AuraEnabled public String Billing_Zip;
        @AuraEnabled public String Calc_Residual_Amnt;
        @AuraEnabled public String Calc_Residual_Prcnt;
        @AuraEnabled public String Cost_Center;
        @AuraEnabled public String Description;
        @AuraEnabled public String First_Payment_Date;
        @AuraEnabled public String Guaranteed_Amount;
        @AuraEnabled public String Guarantor_Name;
        @AuraEnabled public String Install_City;
        @AuraEnabled public String Install_Country;
        @AuraEnabled public String Install_County;
        @AuraEnabled public String Install_Date;
        @AuraEnabled public String Install_Location;
        @AuraEnabled public String Install_Site_Id;
        @AuraEnabled public String Install_State;
        @AuraEnabled public String Install_Zip;
        @AuraEnabled public String Inventory_Item_Id;
        @AuraEnabled public String Item;
        @AuraEnabled public String Licence_Number;
        @AuraEnabled public String Manufacturer;
        @AuraEnabled public String Modal;
        @AuraEnabled public String Mtp_Rep_Ven_Site;
        @AuraEnabled public String Mtp_Rep_Vendor;
        @AuraEnabled public String Number_Of_Assets;
        @AuraEnabled public String Organization_Id;
        @AuraEnabled public String Parent_Asset_Num;
        @AuraEnabled public String Payment_Amount;
        @AuraEnabled public String Po_Number;
        @AuraEnabled public String Residual_Amnt;
        @AuraEnabled public String Residual_Prcnt;
        @AuraEnabled public String Uba_Flag;
        @AuraEnabled public String Unit_Cost;
        @AuraEnabled public String Units;

        /* end asset extension */

    }

     public class TerminationQuoteResponse{

        @AuraEnabled public String partnerTransactionReference;
        @AuraEnabled public String contractNumber;
        @AuraEnabled public List<Quote> quotes;
    }


    //wrapper classs for detail of a single quote

    public class Quote{

        @AuraEnabled public String terminationQuoteType;
        @AuraEnabled public String quoteValidityDate;
        @AuraEnabled public String quoteMessage;
        @AuraEnabled public String quoteNumber;
        @AuraEnabled public String quoteCalculationDescription;
        @AuraEnabled public Decimal remainingRentalPayments;
        @AuraEnabled public Decimal discount;
        @AuraEnabled public Decimal equipmentPrice;
        @AuraEnabled public Decimal salesTax;
        @AuraEnabled public Decimal propertyTax;
        @AuraEnabled public Decimal leaseCharges;
        @AuraEnabled public Decimal securityDeposit;
        @AuraEnabled public Decimal pastDueService;
        @AuraEnabled public Decimal amount;
        
    }


    public class Receivables {
        /* receivables */
        @AuraEnabled public String Assetnumber;
        @AuraEnabled public String Receivabletype;
        @AuraEnabled public String Arconsolidatedinvoicenumber;
        @AuraEnabled public String Duedate;
        @AuraEnabled public String Amountdue;
        @AuraEnabled public String Amountreceived;
        @AuraEnabled public String Latechargesdue;
        @AuraEnabled public String Latechargesreceived;
        @AuraEnabled public String Financechargesdue;
        @AuraEnabled public String Financechargesreceived;
        @AuraEnabled public String Balancedue;
        @AuraEnabled public String Adjustment;

        
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
                            ,assetAddressLine1__c
                            ,assetAddressLine2__c
                            ,assetCity__c

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
                            ,assetAddressLine1__c
                            ,assetAddressLine2__c
                            ,assetCity__c
                    from Portfolio_Equipment__c
                    where Portfolio_Contract__c in :contractSet
                    order by assetSequenceNumber__c
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
            d.nbrOfAssets = integer.valueOf(c.nbrOfAssets__c);
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
                    a.assetAddressLine1 = e.assetAddressLine1__c;
                    a.assetAddressLine2 = e.assetAddressLine2__c;
                    a.assetCity = e.assetCity__c;
                    a.assetState = e.assetState__c;
                    a.assetZipCode = e.assetZipCode__c;
                    a.assetPayment = 121.12;
                   
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
    *   generateQuotes - message format
    *************************************************************************************************************************************************************/
    public static TerminationQuoteResponse generateQuotes(String leaseNumber){
        
        TerminationQuoteResponse response = new TerminationQuoteResponse(); 
       
        List<Lease_OLM_Quote__c> newQuotes = new List<Lease_OLM_Quote__c>();

        List<Quote> qList = new List<Quote>();

        response.partnerTransactionReference = string.valueOf(system.now());
        response.contractNumber = leaseNumber;
        
        Quote q = new Quote();
        q.quoteCalculationDescription = 'Trade-up Quote';
        Integer randomNumber = Integer.valueof((Math.random() * 10000000));
        q.quoteNumber = 'QT-' + randomNumber;
        q.terminationQuoteType = 'MRMType2';
        q.quoteValidityDate = '2019-10-31';
        q.quoteMessage = 'Hello2';
        q.remainingRentalPayments = 9;
        q.discount = 0.00;
        q.equipmentPrice = 564.88;
        q.salesTax = 50.01;
        q.propertyTax = 5.00;
        q.leaseCharges = 13003.11;
        q.securityDeposit = 100.00;
        q.amount = randomNumber * .76;
        qList.add(q);

        Lease_OLM_Quote__c lq = new Lease_OLM_Quote__c();
        lq.quote_calculation_description__c = q.quoteCalculationDescription;
        lq.name = q.quoteNumber;
        lq.termination_quote_type__c = q.terminationQuoteType;
        lq.quote_validity_date__c = date.valueOf(q.quoteValidityDate);
        lq.quote_message__c = q.quoteMessage;
        lq.remaining_rental_payments__c = q.remainingRentalPayments;
        lq.discount__c = q.discount;
        lq.equipment_price__c = q.equipmentPrice;
        lq.sales_tax__c = q.salesTax;
        lq.property_tax__c = q.propertyTax;      
        lq.lease_charges__c = q.leaseCharges;
        lq.security_deposit__c = q.securityDeposit;
        lq.amount__c = q.amount;
        lq.contract_number__c = response.contractNumber;
        newQuotes.add(lq);

        q = new Quote();
        q.quoteCalculationDescription = 'Trade-up with Return Quote';
        randomNumber = Integer.valueof((Math.random() * 10000000));
        q.quoteNumber = 'QT-' + randomNumber;
        q.terminationQuoteType = 'MRMType3';
        q.quoteValidityDate = '2019-10-31';
        q.quoteMessage = 'Hello 3';
        q.remainingRentalPayments = 9;
        q.discount = 0.00;
        q.equipmentPrice = 64.88;
        q.salesTax = 5.01;
        q.propertyTax = 1.00;
        q.leaseCharges = 133.11;
        q.securityDeposit = 10.00;
        q.amount = randomNumber * .56;
        qList.add(q);

        
        lq = new Lease_OLM_Quote__c();
        lq.quote_calculation_description__c = q.quoteCalculationDescription;
        lq.name = q.quoteNumber;
        lq.termination_quote_type__c = q.terminationQuoteType;
        lq.quote_validity_date__c = date.valueOf(q.quoteValidityDate);
        lq.quote_message__c = q.quoteMessage;
        lq.remaining_rental_payments__c = q.remainingRentalPayments;
        lq.discount__c = q.discount;
        lq.equipment_price__c = q.equipmentPrice;
        lq.sales_tax__c = q.salesTax;
        lq.property_tax__c = q.propertyTax;      
        lq.lease_charges__c = q.leaseCharges;
        lq.security_deposit__c = q.securityDeposit;
        lq.amount__c = q.amount;
        lq.contract_number__c = response.contractNumber;
        newQuotes.add(lq);
 
        insert newQuotes;

        response.quotes = qList;
        
        return response;  

    }

    /************************************************************************************************************************************************************
    *   generateQuotes - message format
    *************************************************************************************************************************************************************/
    public static List<Lease_OLM_Quote__c> generateQuotesSOQL(String leaseNumber){
        
        TerminationQuoteResponse response = new TerminationQuoteResponse(); 
       
        List<Lease_OLM_Quote__c> newQuotes = new List<Lease_OLM_Quote__c>();
        List<Lease_OLM_Quote__c> newQuoteResponse = new List<Lease_OLM_Quote__c>();

        List<Quote> qList = new List<Quote>();

        response.partnerTransactionReference = string.valueOf(system.now());
        response.contractNumber = leaseNumber;
        
        Quote q = new Quote();
        q.quoteCalculationDescription = 'Trade-up Quote';
        Integer randomNumber = Integer.valueof((Math.random() * 10000000));
        q.quoteNumber = 'QT-' + randomNumber;
        q.terminationQuoteType = 'MRMType2';
        q.quoteValidityDate = '2019-10-31';
        q.quoteMessage = 'Hello2';
        q.remainingRentalPayments = 9;
        q.discount = 0.00;
        q.equipmentPrice = 564.88;
        q.salesTax = 50.01;
        q.propertyTax = 5.00;
        q.leaseCharges = 13003.11;
        q.securityDeposit = 100.00;
        q.amount = randomNumber * .76;
        qList.add(q);

        Lease_OLM_Quote__c lq = new Lease_OLM_Quote__c();
        lq.quote_calculation_description__c = q.quoteCalculationDescription;
        lq.name = q.quoteNumber;
        lq.termination_quote_type__c = q.terminationQuoteType;
        lq.quote_validity_date__c = date.valueOf(q.quoteValidityDate);
        lq.quote_message__c = q.quoteMessage;
        lq.remaining_rental_payments__c = q.remainingRentalPayments;
        lq.discount__c = q.discount;
        lq.equipment_price__c = q.equipmentPrice;
        lq.sales_tax__c = q.salesTax;
        lq.property_tax__c = q.propertyTax;      
        lq.lease_charges__c = q.leaseCharges;
        lq.security_deposit__c = q.securityDeposit;
        lq.amount__c = q.amount;
        lq.contract_number__c = response.contractNumber;
        newQuotes.add(lq);

        q = new Quote();
        q.quoteCalculationDescription = 'Trade-up with Return Quote';
        randomNumber = Integer.valueof((Math.random() * 10000000));
        q.quoteNumber = 'QT-' + randomNumber;
        q.terminationQuoteType = 'MRMType3';
        q.quoteValidityDate = '2019-10-31';
        q.quoteMessage = 'Hello 3';
        q.remainingRentalPayments = 9;
        q.discount = 0.00;
        q.equipmentPrice = 64.88;
        q.salesTax = 5.01;
        q.propertyTax = 1.00;
        q.leaseCharges = 133.11;
        q.securityDeposit = 10.00;
        q.amount = randomNumber * .56;
        qList.add(q);

        
        lq = new Lease_OLM_Quote__c();
        lq.quote_calculation_description__c = q.quoteCalculationDescription;
        lq.name = q.quoteNumber;
        lq.termination_quote_type__c = q.terminationQuoteType;
        lq.quote_validity_date__c = date.valueOf(q.quoteValidityDate);
        lq.quote_message__c = q.quoteMessage;
        lq.remaining_rental_payments__c = q.remainingRentalPayments;
        lq.discount__c = q.discount;
        lq.equipment_price__c = q.equipmentPrice;
        lq.sales_tax__c = q.salesTax;
        lq.property_tax__c = q.propertyTax;      
        lq.lease_charges__c = q.leaseCharges;
        lq.security_deposit__c = q.securityDeposit;
        lq.amount__c = q.amount;
        lq.contract_number__c = response.contractNumber;
        newQuotes.add(lq);
 
        insert newQuotes;
        Set<ID> newQuoteSet = new Set<ID>();

        for (Lease_OLM_Quote__c l:newQuotes){
            newQuoteSet.add(l.id);
        }

        response.quotes = qList;
        
        newQuoteResponse = [SELECT Amount__c,Contract_Number__c,CreatedById,CreatedDate,Discount__c,Equipment_Price__c
                            ,Id,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Lease_Charges__c,LS_Contract__c,Name,OwnerId,Past_Due_Service__c,Property_Tax__c,Quote_Calculation_Description__c,Quote_Message__c,Quote_Validity_Date__c,Remaining_Rental_Payments__c,Sales_Tax__c,Security_Deposit__c,SystemModstamp,Termination_Quote_Type__c 
                            FROM Lease_OLM_Quote__c
                            where id in :newQuoteSet
        ];

        return newQuoteResponse;  

    }
    
    
    /************************************************************************************************************************************************************
    *   getQuotes
    *************************************************************************************************************************************************************/

    public static Lease_OLM_Quote__c getQuoteDetail(String quoteNumber){
        
        Lease_OLM_Quote__c q = [SELECT 
                                 Amount__c
                                ,Contract_Number__c
                                ,CreatedById
                                ,CreatedDate
                                ,Discount__c
                                ,Equipment_Price__c
                                ,Id
                                ,IsDeleted
                                ,LastActivityDate
                                ,LastModifiedById
                                ,LastModifiedDate
                                ,LastReferencedDate
                                ,LastViewedDate
                                ,Lease_Charges__c
                                ,LS_Contract__c
                                ,Name
                                ,OwnerId
                                ,Past_Due_Service__c
                                ,Property_Tax__c
                                ,Quote_Calculation_Description__c
                                ,Quote_Message__c
                                ,Quote_Validity_Date__c
                                ,Remaining_Rental_Payments__c
                                ,Sales_Tax__c
                                ,Security_Deposit__c
                                ,SystemModstamp
                                ,Termination_Quote_Type__c 
                                FROM Lease_OLM_Quote__c
                                where name = :quoteNumber
                                ];

        return q;  

    }

    /************************************************************************************************************************************************************
    *   processOLMBooking
    *************************************************************************************************************************************************************/

    public static boolean processOLMBooking(String leaseNumber, String quoteNumber, Decimal amount){
        
       return true;

    }
}