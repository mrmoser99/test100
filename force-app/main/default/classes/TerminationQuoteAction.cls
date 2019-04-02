global with sharing class TerminationQuoteAction {
    
    List<cllease__Lease_Account__c> leaseAccounts;
    List<cllease__Contract_Equipment__c> equipmentsToUpdate;
    List<clcommon__Equipment_Detail__c> eqpDetailsToUpdate;
    List<cllease__Other_Transaction__c> terminationTxns;
    List<cllease__Other_Transaction__c> assetRet;
    List<cllease__Other_Transaction__c> assetSold;
    List<cllease__Lease_account_Due_Details__c> billsToCreate;
    List<cllease__Due_Detail_Lines__c> dueLinesToCreate;
    List<cllease__Charge__c>  chargesToCreate;
    List<cllease__Asset_Return__c> assetReturnList;   
    
    List<cllease__Payment_Stream__c> paymentStreamsToUpdate;
    List<cllease__Rental_Stream__c> rentalStreamsToUpdate;
    List<cllease__Amz_Stream__c> amzStreamsToUpdate;
    List<cllease__Rental_Accrual_Stream1__c> rentalAccualStreamsToUpdate;
    List<cllease__ResIdual_Stream__c> resIdualStreamsToUpdate;
    List<cllease__Initial_Direct_Cost_Stream__c> IdcStreamsToUpdate;
    List<cllease__Fee_Stream__c> feeStreamsToUpdate;
    List<cllease__SubsIdy_Stream__c> subsIdyStreamsToUpdate;
    List<cllease__Dep_Streams__c> depStreamsToUpdate;   
    List<cllease__Non_Cash_Account_Balance__c> nonCashAccountBalancesToUpdate;   
    
    Boolean isAPICall = false;
    // to be used while using an API call
    Boolean isBulkAPICAll = false;

    Id assetReturnRecordTypeId;
    Id assetSoldRecordTypeId;
    
    Map<String, Id> trxSubTypeMap;
    Map<Id, Id> txnSubTypeByFeeSchedule;
    Map<String, String> eqpDetailToEqpMapping;
    
    Map<String, cllease__Termination_Quote_Header__c> contractQuoteHeaderAPICallMap;
    Map<Id, cllease__Lease_Account__c> leaseAccountsToUpdate;
    Map<Id, cllease__Cash_Account_Balance__c> balToUpdate;   
    Map<String, cllease__Lease_account_Due_Details__c> uuIdMap = new Map<String, cllease__Lease_account_Due_Details__c>();
    Map<Id, cllease__Termination_Config__c> terminationConfigProductMap;
    
    Id terminationRecordTypeId;
    private mfiflexUtil.UnitOfWorkTransaction uowTransaction;
    
    String namespace;
    
    global TerminationQuoteAction() {
        terminationConfigProductMap = new Map<Id, cllease__Termination_Config__c>();
        trxSubTypeMap               = new Map<String, Id>();
        txnSubTypeByFeeSchedule     = new Map<Id, Id>();
        
        leaseAccountsToUpdate       = new Map<Id, cllease__Lease_Account__c>();
        equipmentsToUpdate          = new List<cllease__Contract_Equipment__c>();
        eqpDetailsToUpdate          = new List<clcommon__Equipment_Detail__c>();        
        billsToCreate               = new List<cllease__Lease_account_Due_Details__c>();
        dueLinesToCreate            = new List<cllease__Due_Detail_Lines__c>();
        chargesToCreate             = new List<cllease__Charge__c>();  
        balToUpdate                 = new Map<Id, cllease__Cash_Account_Balance__c>();        
        terminationTxns             = new List<cllease__Other_Transaction__c>();
        assetRet                    = new List<cllease__Other_Transaction__c>();   
        assetSold                   = new List<cllease__Other_Transaction__c>();
        assetReturnList             = new List<cllease__Asset_Return__c>();  
        
        paymentStreamsToUpdate      = new List<cllease__Payment_Stream__c>();
        rentalStreamsToUpdate       = new List<cllease__Rental_Stream__c>();
        amzStreamsToUpdate          = new List<cllease__Amz_Stream__c>();
        rentalAccualStreamsToUpdate = new List<cllease__Rental_Accrual_Stream1__c>();
        resIdualStreamsToUpdate     = new List<cllease__ResIdual_Stream__c>();
        IdcStreamsToUpdate          = new List<cllease__Initial_Direct_Cost_Stream__c>();
        feeStreamsToUpdate          = new List<cllease__Fee_Stream__c>();
        subsIdyStreamsToUpdate      = new List<cllease__SubsIdy_Stream__c>();
        depStreamsToUpdate          = new List<cllease__Dep_Streams__c>(); 
        nonCashAccountBalancesToUpdate = new List<cllease__Non_Cash_Account_Balance__c>();

        uowTransaction              = new mfiflexUtil.UnitOfWorkTransaction(new LeaseAccountObjectHierarchy());
        
        initialize();
    }
    
    global TerminationQuoteAction(List<cllease__Lease_Account__c> leaseAccounts) {
        this();
        this.leaseAccounts = leaseAccounts;
    }

    global TerminationQuoteAction(Map<cllease__Lease_Account__c, cllease__Termination_Quote_Header__c> quoteHeaderLeaseAccMap) {
        this();
        populateTerminationConfigProductMap(quoteHeaderLeaseAccMap);
        this.leaseAccounts = new List<cllease__Lease_Account__c>(quoteHeaderLeaseAccMap.keySet());
    }

    global TerminationQuoteAction(List<cllease__Lease_Account__c> leaseAccounts, Map<String, cllease__Termination_Quote_Header__c> contractHeaderMap) {
        this();
        this.leaseAccounts = leaseAccounts;
        this.contractQuoteHeaderAPICallMap = contractHeaderMap;
    }
    
    global void populateTerminationConfigProductMap(Map<cllease__Lease_Account__c, cllease__Termination_Quote_Header__c> quoteHeaderLeaseAccMap) {
        terminationConfigProductMap = new Map<Id, cllease__Termination_Config__c>();
        List<cllease__Termination_Config__c> terminationConfigs = Database.query(cllease.ProcessJobQueryUtil.getTerminationConfiguration(quoteHeaderLeaseAccMap));

        Boolean foundConfigflag = False;
        for(cllease__Lease_Account__c leaseAcc : quoteHeaderLeaseAccMap.keySet()) {
            Id productId = leaseAcc.cllease__Lease_Product_Name__c;
            foundConfigflag = False;
            cllease__Termination_Quote_Header__c quoteHeader = quoteHeaderLeaseAccMap.get(LeaseAcc);
            for(cllease__Termination_Config__c termConfig : terminationConfigs) {
                if(productId == termConfig.cllease__Lease_Product__c
                    && termConfig.cllease__Quote_Type__c == quoteHeader.cllease__Quote_Type__c
                    && termConfig.cllease__Quote_Reason__c == quoteHeader.cllease__Quote_Reason__c) {
                    terminationConfigProductMap.put(productId, termConfig);
                    foundConfigflag = True;
                    break;
                }
            }
            //If config match is not found, take default
            if(foundConfigflag == False) {
                for(cllease__Termination_Config__c termConfig : terminationConfigs) {
                    if(productId == termConfig.cllease__Lease_Product__c
                        && termConfig.cllease__Default__c == True) {
                        terminationConfigProductMap.put(productId, termConfig);
                        break;
                    }
                }
            }

        }

        System.debug(LoggingLevel.ERROR, '### terminationMap: '+terminationConfigProductMap);

    }
    
    global Static List<cllease__Lease_Account__c> queryContracts(Set<String> contractIds, set<String> equipIds) {
        List<cllease__Lease_Account__c> contracts;
        try {
            String fields = getTerminationLineFieldAPINames();
            contracts = Database.query(cllease.ProcessJobQueryUtil.getContractsForTermination(fields, contractIds, equipIds));
        } catch(Exception e){
            throw new CLSCustomException('Exception while querying contracts: '+e.getMessage()+ ' Line: '+e.getLineNumber());
        }
        return contracts;
    }
    
    private void initialize() {
        
        // Initializing org namespace
        namespace = 'cllease__';
        // 1. Initializing Termination Configuration to Map<ProductId, Termination Configuration>
        List<cllease__Termination_Config__c> terminationConfigs = Database.query(cllease.ProcessJobQueryUtil.getTerminationConfiguration());
        
        for(cllease__Termination_Config__c termConfig: terminationConfigs) {
            if(termConfig.cllease__Default__c) {
                terminationConfigProductMap.put(termConfig.cllease__Lease_Product__c, termConfig);
            }
        }
        System.debug(LoggingLevel.ERROR, '### terminationMap: '+terminationConfigProductMap);

        // 2. Initializing Transaction SubType Map
        // TODO: trxSubTypeMap = cllease.GlobalContext.INSTANCE.getTransactionSubTypesMap(null);

        // 3. Retrieving termination recordTypeID(Other Transction Record Type)
        List<RecordType> exlist = [SELECT Id, Name
                                   FROM RecordType
                                   WHERE Name IN ('Termination Record Type','Asset Return Record','Asset Sold Record')
                                        AND DeveloperName IN ('Termination_Record_Type','Asset_Sold_Record','Asset_Return_Record')
                                        AND SObjectType = 'cllease__Other_Transaction__c'];

        if(exList != null && exList.size() > 0) {
            for(RecordType exl : exlist){

                if(exl.Name == 'Termination Record Type'){
                terminationRecordTypeId = exl.ID;
                }
                else if(exl.Name == 'Asset Return Record'){
                assetReturnRecordTypeId = exl.ID;
                }
                else if(exl.Name == 'Asset Sold Record'){
                assetSoldRecordTypeId = exl.ID;
                }
            }
        }
    }

    global void process() {
        System.debug(LoggingLevel.ERROR,'#### inside process start:');
        ParentChildrenWrapper wrapper;
        List<ParentChildrenWrapper> terminationQuoteDetailsToUpdate = new List<ParentChildrenWrapper>();
        isAPICall = true;
        isBulkAPICall = true;
        try {
            for(cllease__Lease_Account__c leaseAccount: leaseAccounts){
                // Creating Equipment Unit Map
                List<Equipment> units = new List<Equipment>();
                for(cllease__Contract_Equipment__c equipmentUnit : leaseAccount.cllease__Contract_Equipments__r) {
                    Equipment unit = new Equipment(equipmentUnit);
                    unit.isSelected = true;
                    units.add(unit);
                }
                
                wrapper = createTerminationQuote(leaseAccount, units, null);
                processTerminationQuote(leaseAccount,
                            (cllease__Termination_Quote_Header__c)wrapper.parent,
                            (List<cllease__Termination_Quote_Line__c>)wrapper.getNewChildrenMap(),
                            (List<cllease__Termination_Quote_Equipment__c>)wrapper.getNewChildren2Map());
                terminationQuoteDetailsToUpdate.add(wrapper);
            }
            ParentChildrenWrapper.upsertWrappers(terminationQuoteDetailsToUpdate);
            updateAll();
        } Catch(Exception e){
            throw new CLSCustomException('Exception during process termination: '+e.getMessage()+' Stack: ' + 
                e.getStackTraceString() + ' line: '+e.getLineNumber());
        }

    }
    // used to perform full/partial termination of contracts via Webservice/ Global API 
    global void processTermination(Map<Id, List<cllease__Contract_Equipment__c>> contractEquipmentListMap) { }

    // used to perform full/partial termination of contracts via Webservice/ Global API 
    global void processTermination(Map<Id, List<Equipment>> contractEquipmentListMap, Boolean isEquipmentLevelTermination) {
        ParentChildrenWrapper wrapper;
        List<ParentChildrenWrapper> terminationQuoteDetailsToUpdate = new List<ParentChildrenWrapper>();
        System.debug(Logginglevel.ERROR, '-----------Started the processTermination --------');
        try {
            for(cllease__Lease_Account__c leaseAccount : leaseAccounts) {
                cllease__Termination_Config__c tempConfig = terminationConfigProductMap.get(leaseAccount.cllease__Lease_Product_Name__c);
                if (tempConfig == null) {
                    throw new CLSCustomException('TerminationConfig not found for Product : ' + leaseAccount.cllease__Lease_Product_Name__r.Name);
                }
                cllease__Termination_Quote_Header__c tempHeader = new cllease__Termination_Quote_Header__c();
                tempHeader.cllease__Quote_Reason__c = tempConfig.cllease__Quote_Reason__c;
                tempHeader.cllease__Quote_Type__c = tempConfig.cllease__Quote_Type__c;
                tempHeader.cllease__Is_Equipment_Termination__c = isEquipmentLevelTermination;
                List<Equipment> selectedUnits = contractEquipmentListMap.get(leaseAccount.Id);

                wrapper = createTerminationQuote(leaseAccount, selectedUnits, tempHeader);
                processTerminationQuote(leaseAccount,
                            (cllease__Termination_Quote_Header__c)wrapper.parent,
                            (List<cllease__Termination_Quote_Line__c>)wrapper.getNewChildrenMap(),
                            (List<cllease__Termination_Quote_Equipment__c>)wrapper.getNewChildren2Map());
                terminationQuoteDetailsToUpdate.add(wrapper);
            }
            ParentChildrenWrapper.upsertWrappers(terminationQuoteDetailsToUpdate);
            updateAll();
        } catch(Exception e) {
            throw new CLSCustomException('Exception during process termination: '+e.getMessage()+' Stack: ' + 
                e.getStackTraceString() + ' line: '+e.getLineNumber());       
        }
        System.debug(Logginglevel.ERROR, '-----------Completed the processTermination --------');

    }
    
    public ParentChildrenWrapper createTerminationQuote(cllease__Lease_Account__c leaseAccount, List<Equipment> termUnitList, cllease__Termination_Quote_Header__c quoteHeader){
        
        ParentChildrenWrapper wrapper;        
        try{
            // 1. Variables initialization
            Decimal selectedEquipCost =0 , selectedEquipResidual =0 , totalEquipCost =0 , totalQuoteAmount =0;
            Decimal TotalpurchaseAmount=0, linePurchaseAmount =0, feeAmount =0, mapvalue = 0, equipCost = 0, eqpResidual = 0;
            String  paymentKey, effectiveDateKey, mapkey;
            Date    paymentDate;
            
            List<cllease__Termination_Quote_Equipment__c> terminationEquipments = new List<cllease__Termination_Quote_Equipment__c>();
            List<cllease__Termination_Quote_Line__c> configQuoteLines = new List<cllease__Termination_Quote_Line__c>();
            
            Map<String, Decimal> BeginValueMap = new Map<String, Decimal>();
            Map<String, Decimal> EndValueMap   = new Map<String, Decimal>();
            Map<String, Date> PaymentMap    = new Map<String, Date>();
            
            
            // 2.Retrieving Termination configuration for Contract's Product.
            System.debug(LoggingLevel.ERROR, 'Contract Product Id: '+ leaseAccount.cllease__Lease_Product_Name__c);
            cllease__Termination_Config__c terminationConfig = terminationConfigProductMap.get(leaseAccount.cllease__Lease_Product_Name__c);
            
            // 3. QuoteHeader Initialization: Use quoteHeader from the map if it's a REST API call
            if(quoteHeader == null 
                    && contractQuoteHeaderAPICallMap != null
                    && isBulkAPICall ) {
                quoteHeader = contractQuoteHeaderAPICallMap.get(leaseAccount.name);
                isAPICall = false; // if quoteHeader map is passed then set isAPICall to false
            }
            
            // QuoteHeader == null can be possible in case of batch jobs and API calls
            if(quoteHeader == null) {
                quoteHeader = new cllease__Termination_Quote_Header__c();
                // if quoteHeader is null then this was not invoked through the REST API
                // set isBulkAPICall to false
                isBulkAPICall = false;
            }          
            
            // 4. Finding Rate Factor for selected Equipments/ Equipment Details to Total Units and creating Termination quote Equipments
            cllease__Termination_Quote_Equipment__c terminationEquipment;
            
            for(Equipment termUnit : termUnitList) {                
                terminationEquipment = new cllease__Termination_Quote_Equipment__c();                
                // a. For Contract Equipment Level Termination
                if(quoteHeader.cllease__Is_Equipment_Termination__c) {
                    cllease__Contract_Equipment__c eqp = termUnit.eqp;
                    if(eqp != null) {
                        terminationEquipment.cllease__Contract_Equipment__c = eqp.Id;
                        equipCost   = eqp.cllease__Equipment_Calculated_Cost__c;
                        eqpResidual = eqp.cllease__Residual_Amount__c;
                        if(equipCost == Null){
                            equipCost = eqp.cllease__Estimated_Selling_Price__c;
                        }
                    }                    
                    
                // b. For Equipment Detail Level Termination
                } else {      
                    //  Initializing Equipment Detail , Contract Equipment Field Mapping. 
                    //  This configuration valid only if Termination on Equipment detail level.
                    eqpDetailToEqpMapping = EquipmentDetailUtil.getEqptoEqpDetailFieldMap();              
                    clcommon__Equipment_Detail__c eqpDetail = termUnit.eqpDetail;
                    if(eqpDetail != null) {
                        terminationEquipment.cllease__Equipment_Detail__c = eqpDetail.Id;
                        // Extracting Equipment Detail Field API Names from Mapping
                        String eqpDetailEqpCostFieldName  = eqpDetailToEqpMapping.get(namespace +'cllease__Equipment_Calculated_Cost__c');
                        String eqpDetailInvoiceFieldName  = eqpDetailToEqpMapping.get(namespace +'cllease__Estimated_Selling_Price__c');
                        String eqpDetailResidualFieldName = eqpDetailToEqpMapping.get(namespace +'cllease__Residual_Amount__c');
                        // Extracting Required Values from Equipment Detail Object
                        System.debug(Logginglevel.DEBUG, 'eqpDetailEqpCostFieldName: '+eqpDetailEqpCostFieldName);
                        System.debug(Logginglevel.DEBUG, 'eqpDetailInvoiceFieldName: '+eqpDetailInvoiceFieldName);
                        System.debug(Logginglevel.DEBUG, 'eqpDetailResidualFieldName: '+eqpDetailResidualFieldName);
                        if(eqpDetailEqpCostFieldName != null
                            && eqpDetail.get(eqpDetailEqpCostFieldName) != null) {
                            equipCost = (Decimal) eqpDetail.get(eqpDetailEqpCostFieldName);
                        } else {
                            if(eqpDetailInvoiceFieldName != null
                                && eqpDetail.get(eqpDetailInvoiceFieldName) != null) {
                                equipCost =(Decimal) eqpDetail.get(eqpDetailInvoiceFieldName);
                            }                            
                        }

                        System.debug(Logginglevel.DEBUG, 'equipCost: '+equipCost);     
                        
                        if(eqpDetailResidualFieldName != null
                            && eqpDetail.get(eqpDetailResidualFieldName) != null) {
                            eqpResidual =(Decimal) eqpDetail.get(eqpDetailResidualFieldName);
                        }                     
                    }
                }
                // Calculating Total Equipment Cost and Residual.
                terminationEquipments.add(terminationEquipment);
                selectedEquipCost +=(equipCost != null ? equipCost : 0.00);
                selectedEquipResidual +=(eqpResidual != null ? eqpResidual : 0.00);
                
            }

            System.debug(LoggingLevel.INFO, 'Selected Equipment Cost : ' + selectedEquipCost);
            System.debug(LoggingLevel.INFO, 'Selected Equipment Residual : ' + selectedEquipResidual);
            /**2. Getting total Equipment Cost, following is a rollup field in Contract
             *   for all invoice price from contract equipments
             */

            
            // Calculating Total Equipment Cost for Equipment Level Termination
            if(quoteHeader.cllease__Is_Equipment_Termination__c) {
                for(cllease__Contract_Equipment__c equipment : leaseAccount.cllease__Contract_Equipments__r){
                    if(equipment.cllease__Status__c != cllease.LendingConstants.STATUS_TERMINATED){
                        Decimal eqpCost = equipment.cllease__Equipment_Calculated_Cost__c;
                        if(eqpCost == null){
                            eqpCost = (equipment.cllease__Estimated_Selling_Price__c != null ? equipment.cllease__Estimated_Selling_Price__c : 0.00);
                        }
                        totalEquipCost += eqpCost;
                    }
                }
    
            } else {   
                // Initializing Equipment Detail , Contract Equipment Field Mapping. 
                // This configuration valid only if Termination on Equipment detail level.
                eqpDetailToEqpMapping = EquipmentDetailUtil.getEqptoEqpDetailFieldMap();    

                Set<String> reqStatus = new Set<String>();
                reqStatus.add(cllease.LendingConstants.CONTRACT_EQUIPMENT_STATUS_TO_BE_TERMINATED);
                reqStatus.add(cllease.LendingConstants.MASTER_EQ_LEASED);
                
                Set<String> contractIds = new Set<String>{leaseAccount.Id};             
                Map<Id, Map<Id, clcommon__Equipment_Detail__c>> contractsToEqpDetailsMap
                    = EquipmentDetailUtil.getEquipmentDetailsMapForContracts(contractIds, reqStatus);
                
                String eqpDetailEqpCostFieldName  = eqpDetailToEqpMapping.get(namespace +'cllease__Equipment_Calculated_Cost__c');
                String eqpDetailInvoiceFieldName  = eqpDetailToEqpMapping.get(namespace +'cllease__Estimated_Selling_Price__c');
                        
                if(contractsToEqpDetailsMap != null && contractsToEqpDetailsMap.containsKey(leaseAccount.Id)) {
                    Map<Id, clcommon__Equipment_Detail__c> eqpDetailMap = contractsToEqpDetailsMap.get(leaseAccount.Id);
                    for(clcommon__Equipment_Detail__c eqpDetail : eqpDetailMap.values()) {
                        equipCost = 0;
                        // Extracting Required Values from Equipment Detail Object
                        if(eqpDetailEqpCostFieldName != null
                            && eqpDetail.get(eqpDetailEqpCostFieldName) != null) {
                            equipCost = (Decimal) eqpDetail.get(eqpDetailEqpCostFieldName);
                        } else {
                            if(eqpDetailInvoiceFieldName !=null
                                && eqpDetail.get(eqpDetailInvoiceFieldName) != null) {
                                equipCost = (Decimal) eqpDetail.get(eqpDetailInvoiceFieldName);
                            }                            
                        }

                        totalEquipCost += equipCost;    
                        System.debug(Logginglevel.DEBUG, 'totalEquipCost: '+totalEquipCost);                    
                    }
                }
            }
        
            // Incase of Bulk API Calls, Needs to take Rollup field on Equipment's Invoice Price
            if(isBulkAPICall) {
                totalEquipCost = leaseAccount.cllease__Equipment_Selling_Price__c;
            }
            
            System.debug(LoggingLevel.ERROR, 'Total Non-Terminated Equipment Cost: '+ totalEquipCost);

            Decimal rateFactor = 1;
            if(totalEquipCost > 0) {
                rateFactor = (selectedEquipCost/totalEquipCost);
            }
            
            System.debug(LoggingLevel.ERROR, 'Terminating Equipments Unit Rate Factor :'+ rateFactor);
            
            if(totalEquipCost == selectedEquipCost){
                quoteHeader.cllease__full_termination__c = true;
            }

            System.debug(LoggingLevel.ERROR, 'totalEquipCost:'+ totalEquipCost);
            System.debug(LoggingLevel.ERROR, 'selectedEquipCost:'+ selectedEquipCost);
            
            System.debug('quoteHeader.cllease__full_termination__c = ' + quoteHeader.cllease__full_termination__c);

            //3. Creating Begin and EndingValue Maps for dates and values
            for(cllease__Payment_Stream__c payment: leaseAccount.cllease__Payment_Streams__r) {
                paymentKey   = String.valueof(payment.cllease__Date__c.year()) + String.valueof(payment.cllease__Date__c.month()).leftpad(2).replace(' ', '0');
                paymentDate  = payment.cllease__Date__c;
                PaymentMap.put(paymentKey,paymentDate);
            }
            if(leaseAccount.cllease__Lease_Product_Name__r.cllease__Product_sub_type__C == cllease.LendingConstants.PRODUCT_SUB_TYPE_FN_LEASE) {
                for(cllease__Rental_Stream__c income: leaseAccount.cllease__Rental_streams__r) {
                    mapkey   = String.valueof(income.cllease__Date__c.year()) + String.valueof(income.cllease__Date__c.month()).leftpad(2).replace(' ', '0');
                    mapvalue = income.cllease__Beginning_Net_Book_Value__c; // Value for BeginValueMap
                    BeginValueMap.put(mapkey,mapvalue);
                    mapvalue = income.cllease__Ending_Net_Book_Value__c; // Value for EndValueMap
                    EndValueMap.put(mapkey,mapvalue);
                }
            } else if(leaseAccount.cllease__Lease_Product_Name__r.cllease__Product_sub_type__C == cllease.LendingConstants.PRODUCT_SUB_TYPE_OP_LEASE) {
                for(cllease__Dep_Streams__c dep: leaseAccount.cllease__Dep_Streams__r) {
                    mapkey   = String.valueof(dep.cllease__Date__c.year()) + String.valueof(dep.cllease__Date__c.month()).leftpad(2).replace(' ', '0');
                    mapvalue = dep.cllease__Beginning_Residual__c; // Value for BeginValueMap
                    BeginValueMap.put(mapkey,mapvalue);
                    mapvalue = dep.cllease__Ending_Residual__c; // Value for EndValueMap
                    EndValueMap.put(mapkey,mapvalue);
                }
            }
            /**
             * 4. Creating Termination Quote lines based on the Termination Configuration Lines
             */
            cllease__Termination_Quote_Line__c quote;
            if(terminationConfig ==null) {
                throw new CLSCustomException('No termination configuration found in product, please check ... ');
            }
            if(terminationConfig.cllease__Termination_Config_Lines__r.size() ==0) {
                throw new CLSCustomException('No Quote lines created for termination quote, please check termination configuration... ');
            }
            for(cllease__Termination_Config_Line__c configQuoteLine: terminationConfig.cllease__Termination_Config_Lines__r) {
                quote = new cllease__Termination_Quote_Line__c();
                quote.cllease__Amount_Type__c = 'LINE';
                quote.cllease__Billable__c    = configQuoteLine.cllease__Is_Billable__c;
                quote.cllease__Line_Type__c   = configQuoteLine.cllease__Quote_Line__c;
                quote.cllease__Account_Balance_Type__c  = configQuoteLine.cllease__Account_Balance_Type__c;
                quote.cllease__Is_Account_Balancable__c = configQuoteLine.cllease__Is_Account_Balancable__c;
                quote.cllease__Add_To_Quote_Amount__c   = configQuoteLine.cllease__Add_To_Quote_Amount__c;
                quote.cllease__Bill_Field_API_Name__c = configQuoteLine.cllease__Bill_Field_API_Name__c;
                if(configQuoteLine.cllease__Quote_Line__c == 'QUOTE UNBILLED RECEIVABLE'
                        || configQuoteLine.cllease__Quote_Line__c == 'BILLED NOT PAID - RENT'
                        || configQuoteLine.cllease__Quote_Line__c == 'BILLED NOT PAID - TAX'
                        || configQuoteLine.cllease__Quote_Line__c == 'BILLED NOT PAID - CHARGES'){
                    if(configQuoteLine.cllease__Field_API_Name__c == null) {
                        continue;
                    }    
                    Decimal amount =((Decimal)leaseAccount.get(configQuoteLine.cllease__Field_API_Name__c));
                    quote.cllease__Amount__c =(amount!=null?amount:0)*rateFactor;
                } else if(configQuoteLine.cllease__Quote_Line__c == 'QUOTE DISCOUNT') {
                    if(configQuoteLine.cllease__Field_API_Name__c==null) continue;
                    Decimal amount =((Decimal)leaseAccount.get(configQuoteLine.cllease__Field_API_Name__c));
                    quote.cllease__Amount__c = -1 *(amount!=null?amount:0)*rateFactor;
                } else if(configQuoteLine.cllease__Quote_Line__c == 'SECURITY DEPOSIT') {
                    if(quoteHeader.cllease__full_termination__c) {
                        quote.cllease__Amount__c =  -1 *((leaseAccount.cllease__Security_Deposit_Amount__c == null) ? 0 : leaseAccount.cllease__Security_Deposit_Amount__c);
                    } else {
                        continue;
                    }
                }else {
                    if(configQuoteLine.cllease__Field_API_Name__c==null) continue;
                    Decimal amount =((Decimal)leaseAccount.get(configQuoteLine.cllease__Field_API_Name__c));
                    quote.cllease__Amount__c =(amount!=null?amount:0)*rateFactor;
                }
                if(quote.cllease__Add_To_Quote_Amount__c) {
                    totalQuoteAmount +=(quote.cllease__Amount__c!=null?quote.cllease__Amount__c: 0);
                }
                configQuoteLines.add(quote);
                System.debug(LoggingLevel.ERROR, '### LINE: '+quote);
            }
            if(terminationConfig.cllease__Termination_With_Purchase__c) {
                quoteHeader.cllease__Termination_With_Purchase__c = true;
                quote = new cllease__Termination_Quote_Line__c();
                quote.cllease__Amount_Type__c = 'LINE';
                quote.cllease__Billable__c    = true;
                quote.cllease__Line_Type__c   = 'QUOTE PURCHASE AMOUNT';
                quote.cllease__Add_To_Quote_Amount__c   = true;
                quote.cllease__Bill_Field_API_Name__c = 'Purchase_Amount__c';
                if(isAPICall) {
                    quoteHeader.cllease__Quote_Type__c = 'TERMINATION WITH PURCHASE';
                    quoteHeader.cllease__Quote_Reason__c = 'CUSTOMER REQUESTED';
                }
                if(leaseAccount.cllease__Residual_Type__c == 'FMV' || leaseAccount.cllease__Residual_Type__c == null) {
                    quote.cllease__Amount__c =(selectedEquipResidual==null?0:selectedEquipResidual);
                } else {
                    effectiveDateKey = String.valueof(quoteHeader.cllease__effective_from__C.year()) + String.valueof(quoteHeader.cllease__effective_from__C.month()).leftpad(2).replace(' ', '0');
                    paymentDate = PaymentMap.get(effectiveDateKey);
                    if(leaseAccount.cllease__Lease_Product_Name__r.cllease__Product_sub_type__C == 'FINANCE LEASE') {
                        if(paymentDate > quoteHeader.cllease__effective_from__C) {
                            TotalpurchaseAmount  = BeginValueMap.get(effectiveDateKey);
                        } else {
                            TotalpurchaseAmount  = EndValueMap.get(effectiveDateKey);
                        }
                    }
                    quote.cllease__Amount__c =(TotalpurchaseAmount!=null?TotalpurchaseAmount:0) *rateFactor;
                }
                totalQuoteAmount += quote.cllease__Amount__c;
                configQuoteLines.add(quote);
            }     
            //DEPRECATE USE OF CASH ACC BALANCE FOR EXCESS

            // check if excess cash balance is present
            Decimal excessAmount = 0;
            excessAmount = leaseAccount.cllease__Excess__c;

            if(excessAmount > 0) {
                // create EXCESS Termination Quote Line
                cllease__Termination_Quote_Line__c excessLine = new cllease__Termination_Quote_Line__c();
                excessLine.cllease__Amount__c = -excessAmount; 
                excessLine.cllease__Line_Type__c = 'EXCESS';
                configQuoteLines.add(excessLine);
                totalQuoteAmount -= excessAmount;
            }
            
            /**
             * 5. Creating Termination Quote lines based on the Termination Configuration Fees
             */
            // a. checking for early termination
            Boolean earlyTermination;
            Integer quoteEffectiveDays =(Integer) leaseAccount.cllease__Lease_Product_Name__r.cllease__quote_effective_Days__c;
            quoteEffectiveDays         =(quoteEffectiveDays ==null ? 15 : quoteEffectiveDays); // Defualt Quote Effective Days
            Integer termLeadDays       =(Integer) leaseAccount.cllease__Lease_Product_Name__r.cllease__Termination_Lead_Days__c;
            termLeadDays               =(termLeadDays ==null? 15 : termLeadDays);  // Defualt Quote Lead Days

            if(quoteHeader.cllease__effective_from__c <= leaseAccount.cllease__Maturity_Date__c.addDays(-1*termLeadDays)) {
                earlyTermination = true;
            } else {
                earlyTermination = false;
            }
            // b. creating termination quote fees
            for(cllease__Termination_Config_Fee__c fee: terminationConfig.cllease__Termination_Config_Fees__r) {
                // EARLY TERMINATION CHECKS
                if((fee.cllease__Quote_Reason__c == quoteHeader.cllease__Quote_Reason__c)
                        &&(fee.cllease__Quote_Type__c   == quoteHeader.cllease__Quote_Type__c)
                        &&(fee.cllease__Termination_Type__c == 'EARLY TERMINATION'
                        && earlyTermination)
                    ||(fee.cllease__Quote_Reason__c == quoteHeader.cllease__Quote_Reason__c)
                        &&(fee.cllease__Quote_Type__c   == quoteHeader.cllease__Quote_Type__c)
                        &&(fee.cllease__Termination_Type__c == 'END OF TERM TERMINATION'
                        && !earlyTermination)) {
                    quote                     = new cllease__Termination_Quote_Line__c();
                    quote.cllease__Line_Type__c        = fee.cllease__Fee_Definition__r.Name;
                    quote.cllease__Amount__c           =(fee.cllease__Fee_Amount__c != null ? fee.cllease__Fee_Amount__c : 0.00);
                    quote.cllease__Fee_Definition__c   = fee.cllease__Fee_Definition__c;
                    quote.cllease__Amount_Type__c      = 'FEE';
                    quote.cllease__Billable__c         = true;
                    configQuoteLines.add(quote);
                    totalQuoteAmount          += quote.cllease__Amount__c;
               }
            }
            
            // Updating termination quote header
            quoteHeader.cllease__effective_from__C = cllease.SystemDateutil.getCurrentSystemDate();
            quoteHeader.cllease__contract__c = leaseAccount.Id;
            quoteHeader.cllease__status__c = 'GENERATED';
            quoteHeader.cllease__quote_amount__c = totalQuoteAmount;
            quoteHeader.cllease__effective_to__c = quoteHeader.cllease__effective_from__C.addDays((Integer)quoteEffectiveDays);
            quoteHeader.cllease__Early_Termination__c = earlyTermination;

            // adding parent: Termination Quote header ,
            //        childMap: Termination Quote Lines,
            //        childMap2: Termination Quote Equipment
            wrapper = new ParentChildrenWrapper(
                                                quoteHeader,
                                                new Map<List<sobject>, String>{configQuoteLines => 'cllease__Quote_Header__c'},
                                                new Map<List<sobject>, String>{terminationEquipments => 'cllease__Termination_Quote_Header__c'});
            // START: MultiCurrency Processing currencyISOCode assignment
            Map<Id, List<SObject>> objMap = new Map<Id, List<SObject>>();
            List<SObject> lis = new List<SObject>();
            lis.add((sObject)quoteHeader);
            lis.addAll((List<sObject>)configQuoteLines);
            lis.addAll((List<sObject>)terminationEquipments);
            objMap.put(leaseAccount.Id,lis);
            clcommon.MultiCurrencyUtil.setCurrencyCodes(objMap);
            // END: MultiCurrency Processing currencyISOCode assignment

        } catch(Exception e) {
            throw new CLSCustomException('Exception while creating termination quote: '+e.getMessage()+' stack:'+e.getStackTraceString());
        }
        return wrapper;
    }
    
    public cllease__Termination_Quote_Header__c processTerminationQuote(cllease__Lease_Account__c leaseAccount,
                    cllease__Termination_Quote_Header__c quoteHeader, 
                    List<cllease__Termination_Quote_Line__c> terminationLines,
                    List<cllease__Termination_Quote_Equipment__c> terminationEquipments){
        
        System.debug(LoggingLevel.ERROR, 'Quote Header : '+ quoteHeader);
        
        mfiflexUtil.UnitOfWork uow = uowTransaction.createUnitOfWork(leaseAccount.Name);        
        try {
            Decimal totalPrice=0, terminatedPrice=0, unBilledAmount=0, accruedDep=0, unAccruedIncome=0;
            Decimal totalunbilledAmount=0, totalAccruedDep=0, totalUnAccruedIncome = 0, selectedEquipResidual = 0;
            Decimal reductionFactor = 0, subventionReductionFactor = 0;
            Decimal totalSubventionAmount = 0, terminatedSubventionAmount = 0;
            Decimal residualReductionFactor = 0, totalResidual = 0;
            
            Set<Id> eqpIdsToTerminateSet = new Set<Id>();
            //Following two are for asset level fee only
            Map<Id, Decimal> billedAmountByFeeSchedule = new Map<Id, Decimal>();
            Map<Id, Decimal> accruedAmountByFeeSchedule = new Map<Id, Decimal>();
            Map<Id, Decimal> equipmentToPriceMap = new Map<Id, Decimal>();
            List<cllease__Asset_Return__c> assetReturnForContract = new List<cllease__Asset_Return__c>();
            Map<Id, cllease__Contract_Equipment__c> equipmentToTerminate = new Map<Id, cllease__Contract_Equipment__c>();
            Map<Id, Decimal> equippmentAmountToTerminate = new Map<Id, Decimal>();
            cllease__Asset_Return__c assetReturn;
            Map<Id, clcommon__Equipment_Detail__c> eqpDetailMap;
            Set<String> equipmentsToBeTerminateSet = new Set<String>();
    
            // Contract Equipment Level Termination
            if(quoteHeader.cllease__Is_Equipment_Termination__c) {
                // Loop through all Termination Quote Equipments to create Map for Equipments in process for termination
                for(cllease__Termination_Quote_Equipment__c termEquip: terminationEquipments) {
                    if(termEquip.cllease__Contract_Equipment__c != null) {
                        eqpIdsToTerminateSet.add(termEquip.cllease__Contract_Equipment__c);
                    }                   
                }
                // Loop through all Contract Equipments attached.
                for (cllease__Contract_Equipment__c equipment: leaseAccount.cllease__Contract_Equipments__r) {
                    if(equipment.cllease__Status__c != cllease.LendingConstants.STATUS_TERMINATED){
                        Decimal eqpCost = equipment.cllease__Equipment_Calculated_Cost__c;
                        if( eqpCost == null){
                            eqpCost = (equipment.cllease__Estimated_Selling_Price__c != null ? equipment.cllease__Estimated_Selling_Price__c : 0.00);
                        }

                        if(equipment.cllease__Residual_Amount__c != null) {
                            totalResidual += equipment.cllease__Residual_Amount__c;
                        }
                        
                        Decimal subventionAmt = (equipment.cllease__Subvention__c != null ? equipment.cllease__Subvention__c : 0.00);
                        
                        totalPrice += eqpCost;
                        totalSubventionAmount += subventionAmt;
                                                
                        // Processing Equipments which in process for termination
                        if(eqpIdsToTerminateSet.contains(equipment.Id)) {
                            terminatedPrice += eqpCost;
                            terminatedSubventionAmount += subventionAmt;
                            selectedEquipResidual += (equipment.cllease__Residual_Amount__c != null ? equipment.cllease__Residual_Amount__c : 0.00);
                        
                            equipmentsToUpdate.add(equipment);
                            equipmentToTerminate.put(equipment.Id, equipment);
                            equippmentAmountToTerminate.put(equipment.Id, eqpCost);
                            
                            // Asset Return Processing
                            assetReturn = new cllease__Asset_Return__c();
                            assetReturn.cllease__contract__c = leaseAccount.Id;
                            assetReturn.cllease__Contract_Equipment__c =  equipment.Id;
                            
                            if(!quoteHeader.cllease__Termination_With_Purchase__c) {
                                assetReturn.cllease__return_status__c = 'Scheduled for Return';
                            } else {
                                assetReturn.cllease__return_status__c = 'Sold';
                            }
                            
                            // wait for cash processing
                            if(!leaseAccount.cllease__Lease_Product_Name__r.cllease__wait_for_cash__c) {
                                equipment.cllease__status__c = 'TERMINATED';
                                equipmentsToBeTerminateSet.add(equipment.Id);
                                // Check for all its Equipment Details for Status update
                                
                                assetReturnForContract.add(assetReturn);
                                
                                if(!leaseAccountsToUpdate.containsKey(leaseAccount.Id)) {
                                    leaseAccountsToUpdate.put(leaseAccount.Id, leaseAccount);
                                }
                                //to skip calculation setups while updating equipments
                                //calculations will be skipped irrespective of product configuration
                                leaseAccountsToUpdate.get(leaseAccount.Id).cllease__enable_calculation_setup_logs__c = true;
                            }
                        }
                    }
                }
            
            // Equipment Detail Level Termination
            } else {
                // Initializing Equipment Detail , Contract Equipment Field Mapping. 
                // This configuration valid only if Termination on Equipment detail level.
                eqpDetailToEqpMapping = EquipmentDetailUtil.getEqptoEqpDetailFieldMap();    

                // Loop through all Termination Quote Equipments to create Map for Equipment Details in process for termination
                for(cllease__Termination_Quote_Equipment__c termEquip: terminationEquipments) {
                    if(termEquip.cllease__Equipment_Detail__c != null) {
                        eqpIdsToTerminateSet.add(termEquip.cllease__Equipment_Detail__c);
                    }                   
                }

                // Creating pre-defined equipment map for bill generation
                Map<Id, cllease__Contract_Equipment__c> equipmentMap = new Map<Id, cllease__Contract_Equipment__c>(leaseAccount.cllease__Contract_Equipments__r);
                Set<String> reqStatus = new Set<String>();
                reqStatus.add(cllease.LendingConstants.CONTRACT_EQUIPMENT_STATUS_TO_BE_TERMINATED);
                reqStatus.add(cllease.LendingConstants.MASTER_EQ_LEASED);
                Set<String> contractIds = new Set<String>{leaseAccount.Id};
                
                Map<Id, Map<Id, clcommon__Equipment_Detail__c>> contractToeqpDetailMap
                    = EquipmentDetailUtil.getEquipmentDetailsMapForContracts(contractIds, reqStatus);
                    
                eqpDetailMap = contractToeqpDetailMap.get(leaseAccount.Id);
                
                // Loop through all Contract Equipments attached.
                for (clcommon__Equipment_Detail__c eqpDetail: eqpDetailMap.values()) {   
                    // Extracting Equipment Detail Field API Names from Mapping
                    String eqpDetailEqpCostFieldName  = eqpDetailToEqpMapping.get('cllease__Equipment_Calculated_Cost__c');
                    String eqpDetailInvoiceFieldName  = eqpDetailToEqpMapping.get('cllease__Estimated_Selling_Price__c');
                    String eqpDetailResidualFieldName = eqpDetailToEqpMapping.get('cllease__Residual_Amount__c');
                    String eqpDetailsubventionFieldName = eqpDetailToEqpMapping.get('cllease__subvention__c');
                    
                    Decimal eqpCost = 0;
                    if(eqpDetailEqpCostFieldName != null
                        && eqpDetail.get(eqpDetailEqpCostFieldName) != null) {
                        eqpCost = (Decimal) eqpDetail.get(eqpDetailEqpCostFieldName);
                    } else {
                        if(eqpDetailInvoiceFieldName != null
                            && eqpDetail.get(eqpDetailInvoiceFieldName) != null) {
                            eqpCost =(Decimal) eqpDetail.get(eqpDetailInvoiceFieldName);
                        }                            
                    }

                    if(eqpDetailResidualFieldName != null
                        && eqpDetail.get(eqpDetailResidualFieldName) != null) {
                        totalResidual += (Decimal)eqpDetail.get(eqpDetailResidualFieldName);
                    }

                    
                    Decimal subventionAmt = 0;
                    if(eqpDetailsubventionFieldName != null
                        && eqpDetail.get(eqpDetailsubventionFieldName) != null) {
                        subventionAmt = (Decimal)eqpDetail.get(eqpDetailsubventionFieldName);
                    }
                    
                    totalPrice += eqpCost;
                    totalSubventionAmount += subventionAmt;
                                        
                    // Processing Equipments which in process for termination
                    if(eqpIdsToTerminateSet.contains(eqpDetail.Id)) {

                        Id contractEquipmentId = eqpDetail.cllease__Contract_Equipment__c;
                        cllease__Contract_Equipment__c contractEquipment = equipmentMap.get(eqpDetail.cllease__Contract_Equipment__c);
                        System.debug(Logginglevel.DEBUG, 'Linked Contract Equipment: '+contractEquipment);

                        equipmentToTerminate.put(contractEquipmentId, contractEquipment);
                        equippmentAmountToTerminate.put(contractEquipmentId, eqpCost);


                        terminatedPrice += eqpCost;
                        terminatedSubventionAmount += subventionAmt;
                        if(eqpDetailResidualFieldName != null
                            && eqpDetail.get(eqpDetailResidualFieldName) != null) {
                            selectedEquipResidual += (Decimal)eqpDetail.get(eqpDetailResidualFieldName);
                        }                        
                    
                        eqpDetailsToUpdate.add(eqpDetail);
                        
                        // Asset Return Processing
                        assetReturn = new cllease__Asset_Return__c();
                        assetReturn.cllease__contract__c = leaseAccount.Id;
                        assetReturn.cllease__Contract_Equipment__c   =  eqpDetail.cllease__Contract_Equipment__c;
                        assetReturn.cllease__Equipment_Detail__c     =  eqpDetail.Id;
                        
                        if(!quoteHeader.cllease__Termination_With_Purchase__c) {
                            assetReturn.cllease__return_status__c = 'Scheduled for Return';
                        } else {
                            assetReturn.cllease__return_status__c = 'Sold';
                        }
                        
                        // wait for cash processing
                        if(!leaseAccount.cllease__Lease_Product_Name__r.cllease__wait_for_cash__c) {
                            eqpDetail.clcommon__Status__c = 'TERMINATED';
                            assetReturnForContract.add(assetReturn);
                            
                            if(!leaseAccountsToUpdate.containsKey(leaseAccount.Id)) {
                                leaseAccountsToUpdate.put(leaseAccount.Id, leaseAccount);
                            }
                            //to skip calculation setups while updating equipments
                            //calculations will be skipped irrespective of product configuration
                            leaseAccountsToUpdate.get(leaseAccount.Id).cllease__enable_calculation_setup_logs__c = true;
                        }
                    }                   
                }           
            }

            // Check and update all equipment details incase of termination @Equipment level
            if(equipmentsToBeTerminateSet.size() > 0) {
                List<clcommon__Equipment_Detail__c> eqpDetails = EquipmentDetailUtil.getEquipmentDetails(equipmentsToBeTerminateSet, true);
                if(eqpDetails != null && eqpDetails.size() > 0) {
                    for(clcommon__Equipment_Detail__c eqpDetail : eqpDetails) {
                        eqpDetail.clcommon__Status__c = 'TERMINATED';
                        eqpDetailsToUpdate.add(eqpDetail);
                    }
                }
            }

            if (isBulkAPICall) {
                totalPrice = leaseAccount.cllease__Equipment_Selling_Price__c;
            }
           
            // Calculating the reduction Factor for Streams Calculation.
            System.debug(Logginglevel.ERROR, '----terminatedPrice: '+terminatedPrice);
            reductionFactor = 1;
            if(totalPrice > 0) {
                reductionFactor = (terminatedPrice/totalPrice);
            }

            residualReductionFactor = 1;
            if(totalResidual > 0) {
                residualReductionFactor = (selectedEquipResidual/totalResidual);            
            }

            // Checking for Subvention Enable
            ID subventionTxnSubTypeID;
            if(leaseAccount.cllease__Accrual_Streams__c != null 
                    && leaseAccount.cllease__Accrual_Streams__c.contains('Subvention')
                    && totalSubventionAmount > 0) {
                subventionTxnSubTypeID = trxSubTypeMap.get('SUBVENTION ACCRUAL');
                subventionReductionFactor = (terminatedSubventionAmount/totalSubventionAmount);
            }

            // Streams Processing for Calculating the Total Amounts and creating Termination Transaction
            for(cllease__Payment_Stream__c payStream:leaseAccount.cllease__Payment_Streams__r){
                if ((!payStream.cllease__Billed__c) && (payStream.cllease__Transaction_Sub_Type__c == trxSubTypeMap.get('PERIODIC RENT')))
                    totalunbilledAmount += payStream.cllease__Rental_Amount__c;
            }
            for(cllease__Dep_Streams__c depStream: leaseAccount.cllease__Dep_Streams__r) {
                if (depStream.cllease__Accrued__c)
                    totalAccruedDep += depStream.cllease__Dep_Expense__c;
            }
            if(LeaseAccount.cllease__Product_sub_type__C == cllease.LendingConstants.PRODUCT_SUB_TYPE_FN_LEASE){
                if(LeaseAccount.cllease__Calculation_Method__c == Null ||
                    LeaseAccount.cllease__Calculation_Method__c == 'IRR'){
                    for (cllease__Rental_Stream__c incomeStream: leaseAccount.cllease__Rental_streams__r){
                        if (!incomeStream.cllease__Accrued_Flag__c)
                            totalUnAccruedIncome += incomeStream.cllease__Lease_Income__c;
                            System.debug(Logginglevel.DEBUG, 'income cllease__Lease_Income__c: '+incomeStream.cllease__Lease_Income__c);
                        }
                    }
                else{
                    for (cllease__Amz_Stream__c amzStream: leaseAccount.cllease__Amz_Streams__r){
                        if (!amzStream.cllease__Accrued_Flag__c){
                            totalUnAccruedIncome += amzStream.cllease__Monthly_Earning__c;
                            System.debug(Logginglevel.DEBUG, 'amz cllease__Lease_Income__c: '+amzStream.cllease__Monthly_Earning__c);
                        }
                    }
                }
            }
            else{
                for (cllease__Rental_Accrual_Stream1__c rentalStream: leaseAccount.cllease__Rental_Accrual_Streams__r){
                    if (!rentalStream.cllease__Accrued__c){
                        totalUnAccruedIncome += rentalStream.cllease__Rental_Accrual__c;
                        System.debug(Logginglevel.DEBUG, 'rental cllease__Lease_Income__c: '+rentalStream.cllease__Rental_Accrual__c);
                    }
                }
            }

            Decimal totalUnAccruedSubventionAmount = 0, unAccruedSubventionAmount = 0;
            for(cllease__SubsIdy_Stream__c subventionStream : leaseAccount.cllease__subsidy_streams__r) {
                if (subventionStream.cllease__Accrued__c == false
                    && subventionTxnSubTypeID != null
                    && subventionStream.cllease__Transaction_Sub_Type__c == subventionTxnSubTypeID) {
                    totalUnAccruedSubventionAmount += subventionStream.cllease__Accrued_Amount__c;
                }
            }
            
            unBilledAmount  = cllease.ValueUtil.round(totalunbilledAmount * reductionFactor);
            accruedDep      = cllease.ValueUtil.round(totalAccruedDep * reductionFactor);
            unAccruedIncome = cllease.ValueUtil.round(totalUnAccruedIncome * reductionFactor);
            System.debug(Logginglevel.DEBUG, 'totalUnAccruedIncome: '+totalUnAccruedIncome);
            System.debug(Logginglevel.DEBUG, 'reductionFactor: '+reductionFactor);
            System.debug(Logginglevel.DEBUG, 'totalUnAccruedSubventionAmount: '+totalUnAccruedSubventionAmount);
            System.debug(Logginglevel.DEBUG, 'subventionReductionFactor: '+subventionReductionFactor);
            unAccruedSubventionAmount = cllease.ValueUtil.round(totalUnAccruedSubventionAmount * subventionReductionFactor);

            cllease__Other_Transaction__c termTrx = new cllease__Other_Transaction__c();
            termTrx.cllease__Equipment_Cost__c   = leaseAccount.cllease__Equipment_Selling_Price__c;
            termTrx.cllease__Lease_Account__c    =leaseAccount.id;
            termTrx.cllease__txn_Date__c         = cllease.SystemDateUtil.getCurrentSystemDate();
            termTrx.cllease__Transaction_Type__c = 'TERMINATION';
            termTrx.cllease__Unearned_Lease_Income_Amount__c = unAccruedIncome;
            termTrx.cllease__termination_profit__c   = 0;
            termTrx.cllease__unbilled_Rent__c        = unBilledAmount;
            termTrx.cllease__Accrue_Subvention__c    = unAccruedSubventionAmount;
            termTrx.cllease__Accum_Depreciation__c   = accruedDep;
            termTrx.cllease__Residual_Amount_New__c  = selectedEquipResidual;
            termTrx.cllease__Security_Deposit__c     = leaseAccount.cllease__Security_Deposit_Amount__c;
            termTrx.cllease__GL_Transaction_Flag__c  = true;
            termTrx.RecordTypeId            = terminationRecordTypeId;
            termTrx.cllease__Txn_Amt__c              = quoteHeader.cllease__quote_amount__c;
            terminationTxns.add(termTrx);

            for(cllease__Termination_Quote_Equipment__c equi : terminationEquipments) {
                cllease__Other_Transaction__c assetR = new cllease__Other_Transaction__c();
                assetR.cllease__Lease_Account__c     = leaseAccount.id;
                assetR.cllease__Txn_Date__c          = cllease.SystemDateUtil.getCurrentSystemDate();
                assetR.cllease__Security_Deposit__c     = leaseAccount.cllease__Security_Deposit_Amount__c;
                assetR.cllease__GL_Transaction_Flag__c  = true;
                assetR.cllease__Txn_Amt__c              = quoteHeader.cllease__quote_amount__c;

                if(quoteHeader.cllease__Is_Equipment_Termination__c) {
                    cllease__Contract_Equipment__c equip    = equipmentToTerminate.get(equi.cllease__Contract_Equipment__c);
                    assetR.cllease__Equipment_Cost__c       = equip.cllease__Estimated_Selling_Price__c;
                    assetR.cllease__Residual_Amount_New__c  = equip.cllease__Residual_Amount__c;
                    assetR.cllease__ContractEquipment__c    = equip.Id;
                } else {
                    // Initializing Equipment Detail , Contract Equipment Field Mapping. 
                    // This configuration valid only if Termination on Equipment detail level.
                    eqpDetailToEqpMapping = EquipmentDetailUtil.getEqptoEqpDetailFieldMap();    

                    clcommon__Equipment_Detail__c eqpDetail = eqpDetailMap.get(equi.cllease__Equipment_Detail__c);
                    assetR.cllease__Equipment_Detail__c      = eqpDetail.Id;
                    String eqpDetailEqpCostFieldName  = eqpDetailToEqpMapping.get('cllease__Equipment_Calculated_Cost__c');
                    String eqpDetailResidualFieldName = eqpDetailToEqpMapping.get('cllease__Residual_Amount__c');
                    
                    Decimal eqpCost = 0, eqpResidual = 0;
                    if(eqpDetailEqpCostFieldName != null
                        && eqpDetail.get(eqpDetailEqpCostFieldName) != null) {
                        eqpCost = (Decimal) eqpDetail.get(eqpDetailEqpCostFieldName);
                    } 

                    if(eqpDetailResidualFieldName != null
                        && eqpDetail.get(eqpDetailResidualFieldName) != null) {
                        eqpResidual += (Decimal)eqpDetail.get(eqpDetailResidualFieldName);
                    }

                    assetR.cllease__Equipment_Cost__c        = eqpCost;
                    assetR.cllease__Residual_Amount_New__c   = eqpResidual;
                }
                
                if(!quoteHeader.cllease__Termination_With_Purchase__c) {
                    assetR.cllease__Transaction_Type__c = 'ASSET RETURN';
                    assetR.RecordTypeId        =  assetReturnRecordTypeId;
                    assetRet.add(assetR);
                } else{
                    assetR.cllease__Transaction_Type__c = 'ASSET SOLD';
                    assetR.RecordTypeId        =  assetSoldRecordTypeId;
                    assetSold.add(assetR);
                }
            }

            // create bill and cash account balances
            createBillAndAccount(leaseAccount, quoteHeader, terminationLines, terminationEquipments, equipmentToTerminate, equippmentAmountToTerminate, terminatedPrice, uow);

            // update streams
            paymentStreamsToUpdate.addAll(updatePaymentStreams(leaseAccount, reductionFactor, QuoteHeader.cllease__full_termination__c, equipmentToTerminate.keySet(), billedAmountByFeeSchedule));
            if(leaseAccount.cllease__Product_sub_type__C == cllease.LendingConstants.PRODUCT_SUB_TYPE_FN_LEASE) {
                if(leaseAccount.cllease__Calculation_Method__c == null
                    || LeaseAccount.cllease__Calculation_Method__c == 'IRR') {
                    rentalStreamsToUpdate.addAll(updateRentalStreams(leaseAccount, reductionFactor, QuoteHeader.cllease__full_termination__c, QuoteHeader.cllease__Effective_From__c));
                } else {
                    amzStreamsToUpdate.addAll(updateAmzStreams(leaseAccount, reductionFactor, QuoteHeader.cllease__full_termination__c, QuoteHeader.cllease__Effective_From__c));
                }
                if(leaseAccount.cllease__Accrual_Streams__c != null 
                    && leaseAccount.cllease__Accrual_Streams__c.contains('Residual')) {
                    residualStreamsToUpdate.addAll(updateResidualStreams(leaseAccount, residualReductionFactor, QuoteHeader.cllease__full_termination__c));
                }
            } else if(leaseAccount.cllease__Product_sub_type__C == cllease.LendingConstants.PRODUCT_SUB_TYPE_OP_LEASE) {
                rentalAccualStreamsToUpdate.addAll(updateRentalAccrualStreams(leaseAccount, reductionFactor, QuoteHeader.cllease__full_termination__c));
                if(leaseAccount.cllease__Accrual_Streams__c != null 
                    && leaseAccount.cllease__Accrual_Streams__c.contains('Depreciation')) {
                    depStreamsToUpdate.addAll(updateDepreciationStreams(leaseAccount, reductionFactor, QuoteHeader.cllease__full_termination__c, QuoteHeader.cllease__Effective_From__c, terminatedPrice, selectedEquipResidual));
                }
            }

            idcStreamsToUpdate.addAll(updateIDCStreams(leaseAccount, reductionFactor, QuoteHeader.cllease__full_termination__c));
            feeStreamsToUpdate.addAll(updateFeeStreams(leaseAccount, quoteHeader.cllease__full_termination__c, equipmentToTerminate.keySet(), accruedAmountByFeeSchedule));

            nonCashAccountBalancesToUpdate.addAll(updateNonCashAccountBalances(leaseAccount, reductionFactor, residualReductionFactor, selectedEquipResidual));

            if(leaseAccount.cllease__Accrual_Streams__c != null 
                && leaseAccount.cllease__Accrual_Streams__c.contains('Subsidy')) {
                subsidyStreamsToUpdate.addAll(updateSubsidySubventionStreams(leaseAccount, reductionFactor, QuoteHeader.cllease__full_termination__c, trxSubTypeMap.get('SUBSIDY ACCRUAL')));
            }

            if(leaseAccount.cllease__Accrual_Streams__c != null 
                && leaseAccount.cllease__Accrual_Streams__c.contains('Subvention')) {
                subsidyStreamsToUpdate.addAll(updateSubsidySubventionStreams(leaseAccount, subventionReductionFactor, QuoteHeader.cllease__full_termination__c, trxSubTypeMap.get('SUBVENTION ACCRUAL')));
            }
            
            //process asset level fees for accelerated accrual 
            createAcceleratedAccruals(leaseAccount, billedAmountByFeeSchedule, accruedAmountByFeeSchedule, uow);
            
            if(leaseAccount.cllease__Lease_Product_Name__r.cllease__wait_for_cash__c) {
                quoteHeader.cllease__status__c = 'PROCESSED';
            }else {
                updateExcessCashBalances(leaseAccount, terminationLines);
                quoteHeader.cllease__status__c = 'TERMINATION PROCESSED';
            }

            if ((QuoteHeader.cllease__full_termination__c) && (!leaseAccount.cllease__Lease_Product_Name__r.cllease__wait_for_cash__c)) {
                leaseAccount.cllease__Lease_Status__c = 'TERMINATED';
                leaseAccount.cllease__Termination_Quote_accepted_flag__c = true;
                //to skip calculation setups while updating equipments
                //calculations will be skipped irrespective of product configuration
                leaseAccount.cllease__enable_calculation_setup_logs__c = true;
                leaseAccountsToUpdate.put(leaseAccount.Id, leaseAccount);
            }
            System.debug(LoggingLevel.ERROR, '### quoteheader1: '+quoteHeader);

            // START: MultiCurrency Processing currencyISOCode assignment
            Map<Id, List<SObject>> objMap = new Map<Id, List<SObject>>();
            List<SObject> lis = new List<SObject>();
            if(assetReturnForContract.size()>0) {
                lis.addAll((List<sObject>)assetReturnForContract);
            }
            lis.add((sObject)termTrx);
            objMap.put(leaseAccount.Id,lis);
            clcommon.MultiCurrencyUtil.setCurrencyCodes(objMap);
            // END: MultiCurrency Processing currencyISOCode assignment
        } catch(Exception e) {
            throw new CLSCustomException('Exception while Process termination quote: '+e.getMessage()+' stack:'+e.getStackTraceString());
        }
        return quoteHeader;
    }

    private List<cllease__Non_Cash_Account_Balance__c> updateNonCashAccountBalances(cllease__Lease_Account__c leaseAccount, Decimal adjustmentFactor, Decimal residualReductionFactor, Decimal selectedEquipResidual) {
        List<cllease__Non_Cash_Account_Balance__c> nonCashAccountBalanceList = new List<cllease__Non_Cash_Account_Balance__c>();
        List<String> pickListValuesList = getAllPickListValues('cllease__Non_Cash_Account_Balance__c', 'Balance_Type__c');
        System.debug(pickListValuesList);

        for(cllease__Non_Cash_Account_Balance__c nonCashAccountBalance : leaseAccount.cllease__Non_Cash_Account_Balances__r) {

                nonCashAccountBalance.cllease__Opening_Balance_Amount__c = (nonCashAccountBalance.cllease__Opening_Balance_Amount__c == null) ? 0 : nonCashAccountBalance.cllease__Opening_Balance_Amount__c;
                nonCashAccountBalance.cllease__Transactions_Amount__c = (nonCashAccountBalance.cllease__Transactions_Amount__c == null) ? 0 : nonCashAccountBalance.cllease__Transactions_Amount__c;

                if(nonCashAccountBalance.cllease__Balance_Type__c.containsIgnoreCase('Residual')) {
                    if(nonCashAccountBalance.cllease__Balance_Type__c.containsIgnoreCase('Receivable')) {
                        //RESIDUAL RECEIVABLE
                        nonCashAccountBalance.cllease__Opening_Balance_Amount__c = cllease.ValueUtil.round(nonCashAccountBalance.cllease__Opening_Balance_Amount__c - selectedEquipResidual);
                    }
                    else {
                        //UNEARNED RESIDUAL
                        nonCashAccountBalance.cllease__Opening_Balance_Amount__c = cllease.ValueUtil.round((nonCashAccountBalance.cllease__Opening_Balance_Amount__c - nonCashAccountBalance.cllease__Transactions_Amount__c) * (1-residualReductionFactor)) + nonCashAccountBalance.cllease__Transactions_Amount__c;
                    }
                }
                else {
                    nonCashAccountBalance.cllease__Opening_Balance_Amount__c = cllease.ValueUtil.round((nonCashAccountBalance.cllease__Opening_Balance_Amount__c - nonCashAccountBalance.cllease__Transactions_Amount__c) * (1-adjustmentFactor)) + nonCashAccountBalance.cllease__Transactions_Amount__c;
                }
                nonCashAccountBalance.cllease__Closing_Balance_Amount__c = nonCashAccountBalance.cllease__Opening_Balance_Amount__c - nonCashAccountBalance.cllease__Transactions_Amount__c;

                nonCashAccountBalanceList.add(nonCashAccountBalance);
        }
        return nonCashAccountBalanceList;
    }


    private void createBillAndAccount(cllease__Lease_Account__c leaseAccount,
                                        cllease__Termination_Quote_Header__c quoteHeader,
                                        List<cllease__Termination_Quote_Line__c> terminationLines,
                                        List<cllease__Termination_Quote_Equipment__c> terminationQuoteEqp,
                                        Map<Id, cllease__Contract_Equipment__c> equipmentToTerminate,
                                        Map<Id, Decimal> equippmentAmountToTerminate, 
                                        Decimal totalCostForTerminatedEqp,
                                        mfiflexUtil.UnitOfWork uow) {
        // Start creating bills
        try{
            cllease__Lease_account_Due_Details__c bill = new cllease__Lease_account_Due_Details__c();
            bill.cllease__Total_Due_Amount__c = 0;
            cllease__Charge__c  charge;
            List<cllease__Charge__c> chargesForContract = new List<cllease__Charge__c>();         
            List<cllease__Due_Detail_Lines__c> dueDetailsLines = new List<cllease__Due_Detail_Lines__c>();
            Decimal totalTaxableQuoteAmount = quoteHeader.cllease__Quote_Amount__c;                                 
            List<cllease__Termination_Quote_Line__c> linesList = terminationLines;
            for (cllease__Termination_Quote_Line__c line: linesList) {
                System.debug(Logginglevel.ERROR, '##### line: '+line);
                // creating bills or charges based on the setup.
                if ((line.cllease__Amount_Type__c == 'LINE') && (line.cllease__Billable__c)) {
                    bill.cllease__Total_Due_Amount__c += line.cllease__Amount__c;
                    if(line.cllease__Bill_Field_API_Name__c!=null) {
                        System.debug(Logginglevel.ERROR, '##### line: '+line.cllease__Line_Type__c+'   bill field:'+line.cllease__Bill_Field_API_Name__c);
                        Decimal sum = (Decimal)bill.get(line.cllease__Bill_Field_API_Name__c);
                        System.debug(Logginglevel.ERROR, '##### value: '+sum);
                        sum = (sum==null?0:sum) + (line.cllease__Amount__c==null?0:line.cllease__Amount__c);
                        bill.put(line.cllease__Bill_Field_API_Name__c, sum);
                    }
                } else if ((line.cllease__Amount_Type__c == 'FEE') 
                    && (line.cllease__Billable__c)
                    && line.cllease__Amount__c > 0) {
                    totalTaxableQuoteAmount         -= line.cllease__Amount__c;
                    charge                          = new cllease__Charge__c();
                    charge.cllease__Date__c                  = cllease.SystemDateUtil.getCurrentSystemDate();
                    charge.cllease__Original_Amount__c       = line.cllease__Amount__c;
                    charge.cllease__Fee_Definition__c        = line.cllease__Fee_Definition__c;
                    charge.cllease__GL_Transaction_Flag__c   = true;
                    charge.cllease__Transaction_Sub_Type__c  = trxSubTypeMap.get(line.cllease__Line_Type__c);
                    charge.cllease__Paid_Amount__c           = 0;
                    charge.cllease__Lease_Account__c         = leaseAccount.id;
                    charge.cllease__Quote_header__c          = line.cllease__Quote_Header__c;
                    charge.cllease__Lease_Account__c         = LeaseAccount.Id;
                    chargesForContract.add(charge);
                    System.debug(LoggingLevel.ERROR, '## charge: '+charge);
                }

                // creating cash balances based on the Termiantion config Line creation
                if(line.cllease__Is_Account_Balancable__c) {
                    for(cllease__Cash_Account_Balance__c balance: leaseAccount.cllease__Cash_Account_Balances__r) {
                        // compare cash account balance and balance subtypes of each line
                        if(balance.cllease__Balance_Type__c == line.cllease__Account_Balance_Type__c){
                            if(balToUpdate.containsKey(balance.Id)) {
                                balance = balToUpdate.get(balance.Id);
                            } else {
                                balToUpdate.put(balance.Id, balance);
                            }
                            balance.cllease__Posted_Amount__c += line.cllease__Amount__c;
                            balance.cllease__Closing_Balance_Amount__c -= line.cllease__Amount__c;
                        }
                    }
                }
            }

            // add all charges to global list
            if(chargesForContract.size() > 0) {
                chargesToCreate.addAll(chargesForContract);
            }            

            bill.cllease__Lease_Account__c       = leaseAccount.id;
            bill.cllease__Account__c             = leaseAccount.cllease__Account__c;
            bill.cllease__GL_Transaction_Flag__c = true;
            bill.cllease__Total_Paid_Amount__c   = 0;
            bill.cllease__Transaction_Date__c    = cllease.SystemDateUtil.getCurrentSystemDate();
            bill.cllease__Quote_header__c        = quoteHeader.Id;
            bill.cllease__Remarks__c             = 'Termination Quote Invoice';
            bill.cllease__Due_Date__c            = cllease.SystemDateUtil.getCurrentSystemDate();
            bill.cllease__Due_Type_Description__c= 'TERMINATION';
            bill.cllease__Tax_Due_Amount__c = 0;                                                  
            bill.cllease__Rental_Due_Amount__c = bill.cllease__Total_Due_Amount__c;
            bill.cllease__Status__c = 'Processed';                                               
            System.debug(LoggingLevel.ERROR, '## bill: '+bill);
            //bill.cllease__Id__c = UUIDUtil.generateUUID();
            uuidMap.put(bill.cllease__Id__c, bill);
            billsToCreate.add(bill);

            String taxSource = leaseAccount.cllease__Branch__r.cllease__Tax_Calculation_Source__c;  
            Boolean allTaxesProcessed = true;
            // create due lines
            Integer count = 0;
            Decimal billAmount = bill.cllease__Total_Due_Amount__c;
            //This is for avoiding rounding errors
            //cannot use totalRent field as in case of VAT inclusive
            //actual rent is total due amount on due detail line
            Decimal actualRent = 0;
            Decimal totalRent = 0;
            Decimal totalTax = 0;
            
            for(Id equipmentId : equipmentToTerminate.keySet()) {
                cllease__Contract_Equipment__c equipment = equipmentToTerminate.get(equipmentId);
                cllease__Due_Detail_Lines__c dueLine = new cllease__Due_Detail_Lines__c();                
                dueline.cllease__Remarks__c = 'termination rental due';
                Decimal equipmentCost = equippmentAmountToTerminate.get(equipment.Id);
                Decimal factor = 1;
                if(totalCostForTerminatedEqp > 0) {
                    factor = (equipmentCost/totalCostForTerminatedEqp);
                }
                
                if(count == (equipmentToTerminate.size() - 1)) {
                    dueLine.cllease__Rental_Due_Amount__c = billAmount - actualRent;
                } else {
                    dueLine.cllease__Rental_Due_Amount__c = billAmount * factor;
                }
                dueLine.cllease__Rental_Due_Amount__c = cllease.ValueUtil.round(dueLine.cllease__Rental_Due_Amount__c);
                actualRent += dueLine.cllease__Rental_Due_Amount__c;
                //dueline.cllease__Rental_Due_Amount__c = bill.cllease__Rental_Due_Amount__c * equipmentCost/;                
                dueline.cllease__Tax_Due_Amount__c = 0;
                dueline.cllease__Id__c = bill.cllease__Id__c;
                dueline.cllease__Due_Date__c = bill.cllease__Due_Date__c;
                dueline.cllease__Contract_Equipment__c  = equipmentId;
                
                //Currently code is duplicate in BillDetailGeneratorHandler and this class.  
                //calculate tax 
                //For Avalara,  Upfront tax and override tax are not permitted, so ignoring those in case of Avalara
                //For tax source other than avalara, tax exempted means we have processed the tax.
                if((equipment.cllease__Tax_exemption__c
                        || leaseAccount.cllease__Account__r.cllease__Tax_Exemption__c)
                        && (taxSource == null || taxSource != 'Avalara')) {
                    System.debug(LoggingLevel.FINE, 'Tax is exempted for equiment : ' + equipment.Id);
                    dueLine.cllease__Tax_Processed__c = true; 
                    dueLine.cllease__Remarks__c = 'TAX_IS_EXEMPTED_ON_THIS_CONTRACT_EQUIPMENT';                  
                } else if(taxSource != null && taxSource == 'Avalara') { //for avalara tax will be processed later 
                    dueLine.cllease__Tax_Processed__c = false;
                    dueLine.cllease__Remarks__c = 'Tax is not yet processed. Tax source is Avalara.';                  
                } else if(equipment.cllease__Override_Tax_Flag__c) { 
                    //null tax rate is considered as 0
                    if(equipment.cllease__Override_Tax_Rate__c != null && equipment.cllease__Override_Tax_Rate__c > 0) {                        
                        dueLine.cllease__Tax_Due_Amount__c = cllease.ValueUtil.round((equipment.cllease__Override_Tax_Rate__c / 100) * dueLine.cllease__Rental_Due_Amount__c);
                        dueLine.cllease__Remarks__c = ' Overriden Tax Rate :' + equipment.cllease__Override_Tax_Rate__c + ' Rent Amount  ' + cllease.ValueUtil.round(dueLine.cllease__Rental_Due_Amount__c);
                    } else if(equipment.cllease__Tax_Amount__c != null && equipment.cllease__Tax_Amount__c > 0) {
                        dueLine.cllease__Tax_Due_Amount__c = cllease.ValueUtil.round(equipment.cllease__Tax_Amount__c);
                        dueLine.cllease__Remarks__c = ' Overriden Tax Amount :' + equipment.cllease__Tax_Amount__c + ' Rent Amount  ' + cllease.ValueUtil.round(dueLine.cllease__Rental_Due_Amount__c);
                    }
                    dueLine.cllease__Tax_Processed__c = true; //even if null or 0, we have processed the tax 
                } else if(leaseAccount.cllease__Branch__r.cllease__Tax_Basis__c == 'VAT' && leaseAccount.cllease__Branch__r.cllease__Vat_Rate__c > 0) {
                    //Need to continue with earlier functionality
                    //Avalara takes first priority, Vat and then CL Lease (or null)
                    //Irrespective of inclusive or exclusive, we have the value on bill header
                    if(leaseAccount.cllease__Branch__r.cllease__Tax_Method__c == 'Inclusive') {                            
                        Decimal rent = cllease.ValueUtil.round(dueLine.cllease__Rental_Due_Amount__c/(1 + (leaseAccount.cllease__Branch__r.cllease__Vat_Rate__c/100)));
                        dueLine.cllease__Tax_Due_Amount__c = cllease.ValueUtil.round(dueLine.cllease__Rental_Due_Amount__c - rent);
                        dueLine.cllease__Rental_Due_Amount__c = cllease.ValueUtil.round(rent);                            
                    } else if(leaseAccount.cllease__Branch__r.cllease__Tax_Method__c == 'EXCLUSIVE')  {
                        dueLine.cllease__Tax_Due_Amount__c = cllease.ValueUtil.round((leaseAccount.cllease__Branch__r.cllease__Vat_Rate__c / 100) * dueLine.cllease__Rental_Due_Amount__c);
                    }  
                    dueLine.cllease__Tax_Processed__c = true;                      
                    dueLine.cllease__Remarks__c = ' VAT Rate : ' + leaseAccount.cllease__Branch__r.cllease__Vat_Rate__c + ' Rent Amount : ' + cllease.ValueUtil.round(dueLine.cllease__Rental_Due_Amount__c);
                } else if(taxSource == null || taxSource == 'CL Lease') {
                    if (equipment.cllease__Total_Tax_Rate_Derived__c > 0) {
                        dueLine.cllease__Tax_Due_Amount__c = cllease.ValueUtil.round(getTotalTax(equipment, dueLine));
                        dueLine.cllease__Remarks__c = 'Total tax Rate : ' + equipment.cllease__Total_Tax_Rate_Derived__c + ' Rent Amount : ' + cllease.ValueUtil.round(dueLine.cllease__Rental_Due_Amount__c) + 
                                                ' Surcharge is calulated separately on tax amount if applicable';                        
                    }
                    dueLine.cllease__Tax_Processed__c = true;
                    System.debug(LoggingLevel.FINE, 'Tax calculation complete');
                }
                if(!dueLine.cllease__Tax_Processed__c) {
                    allTaxesProcessed = false;
                }
                //uow.addToInsert(dueLine);
                //uow.addRelationshipAndResolve(dueLine, bill);
                count++;                    
                totalRent += dueLine.cllease__Rental_Due_Amount__c; 
                totalTax += dueLine.cllease__Tax_Due_Amount__c;
                dueline.cllease__Total_Due_Amount__c = cllease.ValueUtil.round(dueline.cllease__Rental_Due_Amount__c + dueline.cllease__Tax_Due_Amount__c, 2, 'Nearest');
                System.debug(Logginglevel.ERROR, '----dueline: '+dueline);
                dueLinesToCreate.add(dueLine);
                dueDetailsLines.add(dueLine);
            }
            bill.cllease__Tax_Due_Amount__c = totalTax;
            bill.cllease__Rental_Due_Amount__c = totalRent; //in case of vat inclusive rent amount is also recalculated           
            bill.cllease__Total_Due_Amount__c = cllease.ValueUtil.round(bill.cllease__Rental_Due_Amount__c + bill.cllease__Tax_Due_Amount__c, 2, 'Nearest');
            if(allTaxesProcessed) {                
                bill.cllease__Status__c = 'processed';               
            }

            System.debug(LoggingLevel.ERROR, '## termination bill after tax: '+bill);
            //uow.addToInsert(bill);                             
            // START: MultiCurrency Processing currencyISOCode assignment
            Map<Id, List<SObject>> objMap = new Map<Id, List<SObject>>();
            objMap.put(leaseAccount.Id, new List<SObject>());
            if(chargesForContract.size()>0) {
                objMap.get(leaseAccount.id).addAll((List<SObject>) chargesForContract);
            }
            objMap.get(leaseAccount.Id).add((sObject)bill);
            objMap.get(leaseAccount.Id).addAll((List<SObject>)dueDetailsLines);
            clcommon.MultiCurrencyUtil.setCurrencyCodes(objMap);
            // END: MultiCurrency Processing currencyISOCode assignment

        } catch(Exception e) {
            throw new CLSCustomException('Exception while creating TermiantionBill: '+e.getMessage()+' stack:'+e.getStackTraceString());
        }

    }
    
    private void createAcceleratedAccruals(cllease__Lease_Account__c leaseAccount, 
                                            Map<Id, Decimal> billedAmountByFeeSchedule,
                                            Map<Id, Decimal> accruedAmountByFeeSchedule,
                                            mfiflexUtil.UnitOfWork uow) {
        cllease__Lease_Trx_Header__c header = new cllease__Lease_Trx_Header__c();
        header.cllease__Contract__c = leaseAccount.Id;
        header.cllease__GL_Posted_Flag__c = FALSE;
        header.cllease__GL_Transaction_Flag__c = TRUE;
        header.cllease__Transaction_Type__c = 'ACCRUAL';
        header.cllease__Transaction_Date__c = cllease.SystemDateUtil.getCurrentSystemDate();
        header.cllease__Amount__c = 0;
        for(Id feeScheduleId : billedAmountByFeeSchedule.keySet()) {
            //fee schedule present in billedAmountByFeeSchedule may not be present in accruedAmountByFeeSchedule
            //as a fee may not always be amortized
            if(accruedAmountByFeeSchedule.containsKey(feeScheduleId)) {
                Decimal billedAmount = billedAmountByFeeSchedule.get(feeScheduleId);
                Decimal accruedAmount = accruedAmountByFeeSchedule.get(feeScheduleId);
                //if billed amount > accrued amount, we need to create accrual txn for the difference
                //as charges are already billed 
                if(billedAmount > accruedAmount) {
                    //need to create accrual txn
                    header.cllease__Amount__c += billedAmount - accruedAmount;
                    //create line
                    cllease__Lease_Trx_Lines__c line = new cllease__Lease_Trx_Lines__c();
                    line.cllease__Contract__c = leaseAccount.Id;
                    line.cllease__Transaction_Sub_Type__c = txnSubTypeByFeeSchedule.get(feeScheduleId);
                    line.cllease__Transaction_Date__c = cllease.SystemDateUtil.getCurrentSystemDate();
                    line.cllease__Amount__c = billedAmount - accruedAmount;
                    // TODO: cllease.GlobalContext.INSTANCE.addObjectForCurrencyUpdate(leaseAccount.Id, line);
                    uow.addToInsert(line);
                    //TODO: uow.addRelationshipAndResolve(line, header);
                } else if(billedAmount < accruedAmount) {
                    //do nothing
                }
                
            }
        }
        if(header.cllease__Amount__c > 0) {
            //TODO uow.addToInsert(header);
        }
    }
    
    private List <cllease__Payment_Stream__c> updatePaymentStreams(cllease__Lease_Account__c leaseAccount, 
                                                            Decimal adjustmentFactor, 
                                                            Boolean fullTerminaion,
                                                            Set<Id> equipmentsToBeTerminated,
                                                            Map<Id, Decimal> billedAmountByFeeSchedule) {

        System.debug(Logginglevel.ERROR, 'inside updatePaymentStreams: fullTerminaion: '+fullTerminaion);
        System.debug(Logginglevel.ERROR, 'equipmentsToBeTerminated: '+equipmentsToBeTerminated);
        List <cllease__Payment_Stream__c> payStreamList = new List <cllease__Payment_Stream__c>();
        //in case of full as well as partial termination we need to do this
        for(cllease__Payment_Stream__c paymentStream: leaseAccount.cllease__Payment_Streams__r) {
            if(paymentStream.cllease__Payment_Type__c == 'FEES'
                    && paymentStream.cllease__Contract_Fee__r.cllease__Contract_Equipment__c != null
                    && equipmentsToBeTerminated.contains(paymentStream.cllease__Contract_Fee__r.cllease__Contract_Equipment__c)) {
                System.debug(Logginglevel.ERROR, 'Processing paymentStream: '+paymentStream);
                if(paymentStream.cllease__Billed__c) { 
                    Decimal billedFeeAmount = 0;
                    if(billedAmountByFeeSchedule.containsKey(paymentStream.cllease__Contract_Fee__c)) {
                        billedFeeAmount = billedAmountByFeeSchedule.get(paymentStream.cllease__Contract_Fee__c);
                    } 
                    billedFeeAmount += paymentStream.cllease__Rental_Amount__c; 
                    billedAmountByFeeSchedule.put(paymentStream.cllease__Contract_Fee__c, billedFeeAmount);                    
                } else if(!fullTerminaion) {
                    paymentStream.cllease__Active__c = false;
                    payStreamList.add(paymentStream); 
                }
            }
        }
        // incase of fullTermination
        if(fullTerminaion) {
            // disabling all unbilled payment streams incase of full termination
            for (cllease__Payment_Stream__c payStream: leaseAccount.cllease__Payment_Streams__r) {
                if (!payStream.cllease__Billed__c) {
                    payStream.cllease__Active__c = false;
                    payStream.cllease__comment__c = 'Termination Quote Billing';
                    payStreamList.add(payStream);
                }
            }
        } else {
            Decimal beginningReceivable = 0, unbilledAmount = 0;
            Decimal originalPayAmount = 0, newPayAmount = 0;
            for (cllease__Payment_Stream__c paymentStream: leaseAccount.cllease__Payment_Streams__r){
                if((paymentStream.cllease__Billed__c == false) 
                        && (trxSubTypeMap.get('PERIODIC RENT')==paymentStream.cllease__Transaction_Sub_Type__c)) {
                    unbilledAmount += paymentStream.cllease__Rental_Amount__c;
                }
                
            }
            beginningReceivable = unbilledAmount - cllease.ValueUtil.round(unbilledAmount * adjustmentFactor);
            for (cllease__Payment_Stream__c payStream: leaseAccount.cllease__Payment_Streams__r) {
                if ((payStream.cllease__Billed__c == false) && (trxSubTypeMap.get('PERIODIC RENT')==payStream.cllease__Transaction_Sub_Type__c)){
                    originalPayAmount = paystream.cllease__Rental_Amount__c;
                    newPayAmount      =  originalPayAmount - cllease.ValueUtil.round(originalPayAmount * adjustmentFactor);
                    payStream.cllease__Rental_Amount__c = newPayAmount;
                    payStream.cllease__Beginning_Receivable__c = beginningReceivable;
                    payStream.cllease__Ending_Receivable__c    = beginningReceivable - newPayAmount ;
                    beginningReceivable = payStream.cllease__Ending_Receivable__c;
                    payStreamList.add(payStream);
                }
            }
        }
        
        return payStreamList;
    }

    /** 
     * Following helper method to update amz streams for partial and full termination of contract
     **/
    private List<cllease__Amz_Stream__c> updateAmzStreams(cllease__Lease_Account__c leaseAccount, Decimal adjustmentFactor, Boolean fullTerminaion, Date terminationStartDate) {
        List<cllease__Amz_Stream__c>  amzStreamsList = new List <cllease__Amz_Stream__c>();
        // Full termination process
        if(fullTerminaion) {
            for (cllease__Amz_Stream__c amzStream: leaseAccount.cllease__Amz_Streams__r) {
                if (!amzStream.cllease__Accrued_Flag__c){
                    amzStream.cllease__Active__c = false;
                    amzStream.cllease__Comment__c = 'Deactivated Streams During Full Termination Process';
                    amzStreamsList.add(amzStream);
                }
            }
        } else { // Partial termination process 
            // Applying Reduction factor on valid Amz Streams
            for (cllease__Amz_Stream__c newAccrual: leaseAccount.cllease__Amz_Streams__r){
                if (!newAccrual.cllease__Accrued_Flag__c && newAccrual.cllease__Date__c >= terminationStartDate) {
                    newAccrual.cllease__Monthly_Earning__c               = (newAccrual.cllease__Monthly_Earning__c - cllease.ValueUtil.round(newAccrual.cllease__Monthly_Earning__c * adjustmentFactor));
                    newAccrual.cllease__Unearned_Beginning_balance__c    = (newAccrual.cllease__Unearned_Beginning_balance__c - cllease.ValueUtil.round(newAccrual.cllease__Unearned_Beginning_balance__c * adjustmentFactor));
                    newAccrual.cllease__Unearned_Ending_balance__c       = (newAccrual.cllease__Unearned_Ending_balance__c - cllease.ValueUtil.round(newAccrual.cllease__Unearned_Ending_balance__c * adjustmentFactor));
                    newAccrual.cllease__Comment__c                       = 'Adjusted Streams During Partial Termination Process';
                    amzStreamsList.add(newAccrual);
               }
            }
        }
        return amzStreamsList;
    }

    private List<cllease__Rental_Stream__c> updateRentalStreams(cllease__Lease_Account__c leaseAccount, Decimal adjustmentFactor, Boolean fullTerminaion, Date terminationStartDate) {
        List<cllease__Rental_Stream__c>  rentalStreamList = new List <cllease__Rental_Stream__c>();
        if(fullTerminaion) {
            for (cllease__Rental_Stream__c RentalStream: leaseAccount.cllease__Rental_streams__r) {
                if (!RentalStream.cllease__Accrued_Flag__c){
                    RentalStream.cllease__Active__c = false;
                    RentalStream.cllease__comment__c = 'Termination Quote Accrual';
                    //rentStreamAmount += RentalStream.cllease__Lease_Income__c;
                    rentalStreamList.add(RentalStream);
                }
            }
        } else {
            Decimal originalAmount = 0,unAccruedAmount = 0,newAmount = 0,beginningNBV = 0;
            for (cllease__Rental_Stream__c newAccrual: leaseAccount.cllease__Rental_streams__r){
                newAccrual.cllease__Ending_Unearned_Income__c = newAccrual.cllease__Ending_Unearned_Income__c == null?0:newAccrual.cllease__Ending_Unearned_Income__c;
                if (!newAccrual.cllease__Accrued_Flag__c && newAccrual.cllease__Date__c >= terminationStartDate && newAccrual.cllease__Date__c > leaseAccount.cllease__Branch__r.cllease__Current_System_Date__c) {
                    newAccrual.cllease__Lease_Income__c = (newAccrual.cllease__Lease_Income__c - cllease.ValueUtil.round(newAccrual.cllease__Lease_Income__c * adjustmentFactor));
                    newAccrual.cllease__Beginning_Net_Book_Value__c = (newAccrual.cllease__Beginning_Net_Book_Value__c - cllease.ValueUtil.round(newAccrual.cllease__Beginning_Net_Book_Value__c * adjustmentFactor));
                    newAccrual.cllease__Ending_Net_Book_Value__c = (newAccrual.cllease__Ending_Net_Book_Value__c - cllease.ValueUtil.round(newAccrual.cllease__Ending_Net_Book_Value__c * adjustmentFactor));
                    newAccrual.cllease__Beginning_Net_Investment__c = (newAccrual.cllease__Beginning_Net_Investment__c - cllease.ValueUtil.round(newAccrual.cllease__Beginning_Net_Investment__c * adjustmentFactor));
                    newAccrual.cllease__Ending_Net_Investment__c = (newAccrual.cllease__Ending_Net_Investment__c - cllease.ValueUtil.round(newAccrual.cllease__Ending_Net_Investment__c * adjustmentFactor));
                    newAccrual.cllease__Beginning_Lease_Receivable__c = (newAccrual.cllease__Beginning_Lease_Receivable__c - cllease.ValueUtil.round(newAccrual.cllease__Beginning_Lease_Receivable__c * adjustmentFactor));
                    newAccrual.cllease__Ending_Lease_Receivable__c = (newAccrual.cllease__Ending_Lease_Receivable__c - cllease.ValueUtil.round(newAccrual.cllease__Ending_Lease_Receivable__c * adjustmentFactor));
                    newAccrual.cllease__Beginning_Unearned_Income__c = (newAccrual.cllease__Beginning_Unearned_Income__c - cllease.ValueUtil.round(newAccrual.cllease__Beginning_Unearned_Income__c * adjustmentFactor));
                    newAccrual.cllease__Ending_Unearned_Income__c = (newAccrual.cllease__Ending_Unearned_Income__c - cllease.ValueUtil.round(newAccrual.cllease__Ending_Unearned_Income__c * adjustmentFactor));
                    newAccrual.cllease__Capital_Recovery__c = (newAccrual.cllease__Capital_Recovery__c - cllease.ValueUtil.round(newAccrual.cllease__Capital_Recovery__c * adjustmentFactor));
                    newAccrual.cllease__Payment_Amount__c = (newAccrual.cllease__Payment_Amount__c - cllease.ValueUtil.round(newAccrual.cllease__Payment_Amount__c * adjustmentFactor));
                    rentalStreamList.add(newAccrual);
               }
            }
        }
        return rentalStreamList;
    }

    private List<cllease__Rental_Accrual_Stream1__c> updateRentalAccrualStreams(cllease__Lease_Account__c leaseAccount, Decimal adjustmentFactor, Boolean fullTerminaion) {
        List<cllease__Rental_Accrual_Stream1__c>  rentalAccualStreamList = new List <cllease__Rental_Accrual_Stream1__c>();
        if(fullTerminaion) {
            for (cllease__Rental_Accrual_Stream1__c rentalAcrStream: leaseAccount.cllease__Rental_Accrual_Streams__r){
                if (!rentalAcrStream.cllease__Accrued__c) {
                    rentalAcrStream.cllease__Active__C = false;
                    rentalAcrStream.cllease__comment__C = 'Termination Quote Accrual';
                    //rentalStreamAmount += rentalAcrStream.Rental_Accrual__c;
                    rentalAccualStreamList.add(rentalAcrStream);
                }
            }
        } else {
            Decimal originalAmount = 0,unAccruedAmount = 0,newAmount = 0,beginningNBV = 0;
            for (cllease__Rental_Accrual_Stream1__c accrual: leaseAccount.cllease__Rental_Accrual_Streams__r) {
                if (accrual.cllease__accrued__c == false)
                    unAccruedAmount += accrual.cllease__Rental_Accrual__c;
            }
            beginningNBV = unAccruedAmount - cllease.ValueUtil.round(unAccruedAmount * adjustmentFactor);
            for (cllease__Rental_Accrual_Stream1__c oldAccrual: leaseAccount.cllease__Rental_Accrual_Streams__r){
                if (!oldAccrual.cllease__Accrued__c) {
                    originalAmount = oldAccrual.cllease__Rental_Accrual__c;
                    newAmount = (originalAmount - cllease.ValueUtil.round(originalAmount * adjustmentFactor));
                    oldAccrual.cllease__Beginning_Net_Book_Value__c = beginningNBV;
                    oldAccrual.cllease__Rental_Accrual__c = newAmount;
                    oldAccrual.cllease__Ending_Net_Book_Value__c = beginningNBV - newAmount;
                    beginningNBV = oldAccrual.cllease__Ending_Net_Book_Value__c;
                    rentalAccualStreamList.add(oldAccrual);
                }
            }
        }
        return rentalAccualStreamList;
    }

    private List<cllease__ResIdual_Stream__c> updateResidualStreams(cllease__Lease_Account__c leaseAccount, Decimal adjustmentFactor, Boolean fullTerminaion) {
        List<cllease__ResIdual_Stream__c>  residualStreamList = new List <cllease__ResIdual_Stream__c>();
        if(fullTerminaion) {
            for (cllease__ResIdual_Stream__c ResidualStream: leaseAccount.cllease__Residual_Streams__r) {
                if (!ResidualStream.cllease__Accrued_Flag__c) {
                    ResidualStream.cllease__Active__c = false;
                    ResidualStream.cllease__comment__C = 'Termination Quote Accrual';
                    //ResStreamAmount += ResidualStream.Residual_Income__c;
                    residualStreamList.add(ResidualStream);
                }
            }
        } else {
            Decimal originalAmount = 0,unAccruedAmount = 0,newAmount = 0,beginningNBV = 0;
            for (cllease__ResIdual_Stream__c oldAccrual: leaseAccount.cllease__Residual_Streams__r) {
                if (!oldAccrual.cllease__Accrued_Flag__c  && oldAccrual.cllease__Date__c > leaseAccount.cllease__Branch__r.cllease__Current_System_Date__c) {
                    oldAccrual.cllease__Beginning_Lease_Residual__c = (oldAccrual.cllease__Beginning_Lease_Residual__c - cllease.ValueUtil.round(oldAccrual.cllease__Beginning_Lease_Residual__c * adjustmentFactor));
                    oldAccrual.cllease__Beginning_Residual_Net_Book_Value__c = (oldAccrual.cllease__Beginning_Residual_Net_Book_Value__c - cllease.ValueUtil.round(oldAccrual.cllease__Beginning_Residual_Net_Book_Value__c * adjustmentFactor));
                    oldAccrual.cllease__Beginning_Unearned_Residual_Income__c = (oldAccrual.cllease__Beginning_Unearned_Residual_Income__c - cllease.ValueUtil.round(oldAccrual.cllease__Beginning_Unearned_Residual_Income__c * adjustmentFactor));
                    oldAccrual.cllease__Ending_Net_Book_Value__c = (oldAccrual.cllease__Ending_Net_Book_Value__c - cllease.ValueUtil.round(oldAccrual.cllease__Ending_Net_Book_Value__c * adjustmentFactor));
                    oldAccrual.cllease__Ending_Lease_Residual__c = (oldAccrual.cllease__Ending_Lease_Residual__c - cllease.ValueUtil.round(oldAccrual.cllease__Ending_Lease_Residual__c * adjustmentFactor));
                    oldAccrual.cllease__Residual_Income__c = (oldAccrual.cllease__Residual_Income__c - cllease.ValueUtil.round(oldAccrual.cllease__Residual_Income__c * adjustmentFactor));
                    oldAccrual.cllease__Residual_Amount__c = (oldAccrual.cllease__Residual_Amount__c - cllease.ValueUtil.round(oldAccrual.cllease__Residual_Amount__c * adjustmentFactor));
                    residualStreamList.add(oldAccrual);
               }
            }
        }
        return residualStreamList;
    }

    private List<cllease__Initial_Direct_Cost_Stream__c> updateIDCStreams(cllease__Lease_Account__c leaseAccount, Decimal adjustmentFactor, Boolean fullTerminaion) {
        List<cllease__Initial_Direct_Cost_Stream__c>  idcStreamList = new List <cllease__Initial_Direct_Cost_Stream__c>();
        if(fullTerminaion) {
            for (cllease__Initial_Direct_Cost_Stream__c idcStream: leaseAccount.cllease__IDC_Stream__r){
                if (!idcStream.cllease__Accrued_Flag__c) {
                    idcStream.cllease__Accrued_Flag__c = true;
                    idcStream.cllease__comment__C = 'Termination Quote Accrual';
                    //idcStreamAmount += idcStream.Expense_Initial_Direct_Cost__c;
                    idcStreamList.add(idcStream);
                }
            }
        } else {
            Decimal originalAmount = 0,unAccruedAmount = 0,newAmount = 0,beginningNBV = 0;
            for (cllease__Initial_Direct_Cost_Stream__c accrual: leaseAccount.cllease__IDC_Stream__r){
                if (accrual.cllease__Accrued_Flag__c == false)
                    unAccruedAmount += accrual.cllease__Expense_Initial_Direct_Cost__c;
            }
            beginningNBV = unAccruedAmount - cllease.ValueUtil.round(unAccruedAmount * adjustmentFactor);
            for (cllease__Initial_Direct_Cost_Stream__c newAccrual: leaseAccount.cllease__IDC_Stream__r) {
                if(!newAccrual.cllease__Accrued_Flag__c){
                    originalAmount = newAccrual.cllease__Expense_Initial_Direct_Cost__c;
                    newAmount = (originalAmount - cllease.ValueUtil.round(originalAmount * adjustmentFactor));
                    newAccrual.cllease__Beginning_Initial_Direct_Cost__c = beginningNBV;
                    newAccrual.cllease__Expense_Initial_Direct_Cost__c = newAmount;
                    newAccrual.cllease__Ending_Initial_Direct_Cost__c = beginningNBV - newAmount;
                    beginningNBV = newAccrual.cllease__Ending_Initial_Direct_Cost__c;
                    idcStreamList.add(newAccrual);
               }
            }
        }
        return idcStreamList;
    }
    
    //In case of partial termination, if it is an asset level fees and asset is being terminated, we need to delete the streams 
    private List<cllease__Fee_Stream__c> updateFeeStreams(cllease__Lease_Account__c leaseAccount, 
                                                        Boolean fullTermination, 
                                                        Set<Id> equipmentsToBeTerminated,
                                                        Map<Id, Decimal> accruedAmountByFeeSchedule) {

        System.debug(Logginglevel.ERROR, 'Inside updateFeeStreams : fullTermination: '+fullTermination);
        List<cllease__Fee_Stream__c>  feeStreamList = new List <cllease__Fee_Stream__c>();
        Map<Id, Decimal> feeMap = new Map<Id, Decimal>();
        List <String> keys = new List<String>();
        //in case of full as well as partial we need to do this
        for(cllease__Fee_Stream__c feeStream : leaseAccount.cllease__Fee_Streams__r) {
            //if fee stream is not accrued and it was related to asset which is being terminated
            //we should delete the fee stream line
            if(feeStream.cllease__Contract_Fee__r.cllease__Contract_Equipment__c != null                         
                    && equipmentsToBeTerminated.contains(feeStream.cllease__Contract_Fee__r.cllease__Contract_Equipment__c)) {
                if(feeStream.cllease__Accrued__c) {
                    //check if we want to have a date 
                    Decimal accruedAmount = 0;
                    if(accruedAmountByFeeSchedule.containsKey(feeStream.cllease__Contract_Fee__c)) {
                       accruedAmount = accruedAmountByFeeSchedule.get(feeStream.cllease__Contract_Fee__c); 
                    }
                    accruedAmount += feeStream.cllease__Fee_Amount__c;
                    accruedAmountByFeeSchedule.put(feeStream.cllease__Contract_Fee__c, accruedAmount);
                    txnSubTypeByFeeSchedule.put(feeStream.cllease__Contract_Fee__c, feeStream.cllease__Transaction_Sub_Type__c);
                } else if(!fullTermination) {
                    feeStream.cllease__Active__c = false;
                    feeStreamList.add(feeStream);
                }
            }            
        }
        if(fullTermination) {
            for (cllease__Fee_Stream__c feeStream: leaseAccount.cllease__Fee_Streams__r){
                if (!feeStream.cllease__Accrued__c) {
                    if (!feeMap.containsKey(feeStream.cllease__Transaction_Sub_Type__c)){
                        feeMap.put(feeStream.cllease__Transaction_Sub_Type__c, 0);
                        keys.add(feeStream.cllease__Transaction_Sub_Type__c);
                    }
                    feeStream.cllease__Accrued__c = true;
                    feeStream.cllease__Date_Accrued__c = cllease.SystemDateUtil.getCurrentSystemDate();
                    feeStream.cllease__comment__C = 'Termination Quote Accrual';
                    //feeStreamAmount += feeStream.Fee_Amount__c;  //this is total amount for all Fees
                    feeMap.put(feeStream.cllease__Transaction_Sub_Type__c, feeMap.get(feeStream.cllease__Transaction_Sub_Type__c)+feeStream.cllease__Fee_Amount__c);
                    feeStreamList.add(feeStream);
                }
            }
        } 
        
        return feeStreamList;
    }

    private List<cllease__SubsIdy_Stream__c> updateSubsidySubventionStreams(cllease__Lease_Account__c leaseAccount, Decimal adjustmentFactor, Boolean fullTerminaion, ID transactionSubType) {
        List<cllease__SubsIdy_Stream__c>  subsidyStreamList = new List <cllease__SubsIdy_Stream__c>();
        if(fullTerminaion) {
            for (cllease__SubsIdy_Stream__c subsidyStream: leaseAccount.cllease__subsidy_streams__r) {
                if (!subsidyStream.cllease__Accrued__c 
                    && subsidyStream.cllease__Transaction_Sub_Type__c == transactionSubType) {
                    subsidyStream.cllease__Accrued__c = true;
                    subsidyStream.cllease__Date_Accrued__c = cllease.SystemDateUtil.getCurrentSystemDate();
                    subsidyStream.cllease__comment__C = 'Termination Quote Accrual';
                    subsidyStreamList.add(subsidyStream);
                }
            }
        } else {
            Decimal originalAmount = 0,unAccruedAmount = 0,newAmount = 0,beginningNBV = 0;
            for (cllease__SubsIdy_Stream__c accrual: leaseAccount.cllease__subsidy_streams__r){
                if (accrual.cllease__Accrued__c == false
                    && accrual.cllease__Transaction_Sub_Type__c == transactionSubType)
                    unAccruedAmount += accrual.cllease__Accrued_Amount__c;
            }
            beginningNBV = unAccruedAmount - cllease.ValueUtil.round(unAccruedAmount * adjustmentFactor);
            for (cllease__SubsIdy_Stream__c oldAccrual: leaseAccount.cllease__subsidy_streams__r){
                if (!oldAccrual.cllease__Accrued__c
                    && oldAccrual.cllease__Transaction_Sub_Type__c == transactionSubType){
                    originalAmount = oldAccrual.cllease__Accrued_Amount__c;
                    newAmount = (originalAmount - cllease.ValueUtil.round(originalAmount * adjustmentFactor));
                    oldAccrual.cllease__Beginning_Balance__c = beginningNBV;
                    oldAccrual.cllease__Accrued_Amount__c = newAmount;
                    oldAccrual.cllease__Ending_Balance__c = beginningNBV - newAmount;
                    beginningNBV = oldAccrual.cllease__Ending_Balance__c;
                    subsidyStreamList.add(oldAccrual);
               }
            }
        }
        return subsidyStreamList;
    }

    private List<cllease__Dep_Streams__c> updateDepreciationStreams(cllease__Lease_Account__c leaseAccount, Decimal adjustmentFactor, Boolean fullTerminaion, Date terminationStartDate, Decimal terminatedPrice, Decimal selectedEquipResidual) {
        List<cllease__Dep_Streams__c>  depreciationStreamList = new List <cllease__Dep_Streams__c>();
        if(fullTerminaion) {
            for (cllease__Dep_Streams__c DepAcrStream: leaseAccount.cllease__Dep_Streams__r) {
                if (!DepAcrStream.cllease__Accrued__c) {
                    DepAcrStream.cllease__Active__C = false;
                    DepAcrStream.cllease__comment__C = 'Termination Quote Accrual';
                    depreciationStreamList.add(DepAcrStream);
                }
            }
        } else {
            Decimal originalAmount = 0,unAccruedAmount = 0,newAmount = 0,beginningNBV = 0, lastEndingNBV = 0;
            Decimal endResidualValue = 0;
            Integer countOfStreams = 0, countOfUnaccruedStreams = 0;
            for (cllease__Dep_Streams__c accrual: leaseAccount.cllease__Dep_Streams__r) {
                if(accrual.cllease__Date__c <= terminationStartDate) {
                    countOfStreams += 1;
                    lastEndingNBV = accrual.cllease__Ending_Residual__c;
                    unAccruedAmount += accrual.cllease__Dep_Expense__c;
                }
                else{
                    countOfUnaccruedStreams += 1;
                }
            }
            if(countOfStreams < LeaseAccount.cllease__Dep_Streams__r.size()) {
                lastEndingNBV = leaseAccount.cllease__Dep_Streams__r[countOfStreams].cllease__Beginning_Residual__c;
            }
            endResidualValue = LeaseAccount.cllease__Dep_Streams__r[LeaseAccount.cllease__Dep_Streams__r.size()-1].cllease__Ending_Residual__c;
            system.debug(lastEndingNBV);
            system.debug(terminatedPrice);
            system.debug(terminationStartDate);

            //beginningNBV = lastEndingNBV - terminatedPrice;
            beginningNBV = lastEndingNBV;
            beginningNBV -= (beginningNBV * adjustmentFactor);
            system.debug(adjustmentFactor);
            system.debug(beginningNBV);
            //beginningNBV = unAccruedAmount - cllease.ValueUtil.round(unAccruedAmount * adjustmentFactor);
            //beginningNBV = beginningNBV - accruedAmount;
            newAmount = (beginningNBV - (endResidualValue - selectedEquipResidual)) / countOfUnaccruedStreams;

            for (cllease__Dep_Streams__c oldAccrual: leaseAccount.cllease__Dep_Streams__r) {
                if (!oldAccrual.cllease__Accrued__c) {
                    if(oldAccrual.cllease__Date__c > TerminationStartDate) {
                        if(beginningNBV <= 0) {
                            oldAccrual.cllease__Active__C = false;
                            oldAccrual.cllease__comment__C = 'Termination Quote Accrual';
                            oldAccrual.cllease__Beginning_Residual__c = null;
                            oldAccrual.cllease__Dep_Expense__c = null;
                            oldAccrual.cllease__Ending_Residual__c = null;
                            beginningNBV = beginningNBV - newAmount;
                        }
                        else {
                            oldAccrual.cllease__Beginning_Residual__c = beginningNBV;
                            oldAccrual.cllease__Dep_Expense__c = newAmount;
                            oldAccrual.cllease__Ending_Residual__c = beginningNBV - newAmount;
                            beginningNBV = oldAccrual.cllease__Ending_Residual__c;
                        }

                    }

                    depreciationStreamList.add(oldAccrual);
               }
            }
        }
        return depreciationStreamList;
    }

    public void updateExcessCashBalances(cllease__Lease_Account__c leaseAccount,
        List<cllease__Termination_Quote_Line__c> terminationLines) {

        //Like the way excess account balance was updated, update the excess field in leaseAccount as well
        if(leaseAccount.cllease__Excess__c != null && leaseAccount.cllease__Excess__c != 0) {
            for (cllease__Termination_Quote_Line__c quoteLine : terminationLines) {
                if (quoteLine.cllease__Line_Type__c == 'EXCESS') {
                  leaseAccount.cllease__Excess__c += quoteLine.cllease__Amount__c;
                }
            }
            System.debug(Logginglevel.ERROR, '^^^leaseAccount:' + leaseAccount);
        }

    }
    
    public void updateAll(){
        // TODO: check object permissions before DML operations
        SavePoint sp = Database.setSavePoint();
        try{
            uowTransaction.commitWork();
            if(assetReturnList.size()>0) {
                insert assetReturnList;
            } 

            System.debug(LoggingLevel.ERROR, '-----billsToCreate :'+billsToCreate);
            if(billsToCreate.size()>0)
                insert billsToCreate;
            
            if(eqpDetailsToUpdate.size() > 0) {
                // TODO cllease.EquipmentDetailOperations.upsertEquipmentDetails(eqpDetailsToUpdate);
            }

            if(dueLinesToCreate.size()>0) {
                for (cllease__Due_Detail_Lines__c lines : dueLinesToCreate) {
                    cllease__Lease_account_Due_Details__c ddt = uuidMap.get(lines.cllease__Id__c);
                    lines.cllease__Bill__c = ddt.Id;
                }
                insert dueLinesToCreate;
            }
            if(chargesToCreate.size()>0)
                insert chargesToCreate;
                
            //Lease accounts are updated with a flag which indicates that we should 
            //not use calculation setup
            //so the update statement of lease accounts should be before equipments
            if(leaseAccountsToUpdate.size() > 0) {
                update leaseAccountsToUpdate.values();
            }
            if(equipmentsToUpdate.size()>0) {
                /*//Hack to avoid calling equipment trigger where calculation is redone
                //Ideally we should have a field on contract to avoid recalculation
                RecursiveTriggerHelper.setAlreadyModified();*/
                cllease.EquipmentOperations.updateEquipment(equipmentsToUpdate);
            }
            //after equipments update we need to restrore the flag on contract which
            //has skipped calculation setups
            if(leaseAccountsToUpdate.size() > 0) {
                for(cllease__Lease_Account__c contract : leaseAccountsToUpdate.values()) {
                    contract.cllease__enable_calculation_setup_logs__c = false;
                }
                update leaseAccountsToUpdate.values();
            }
            if(terminationTxns.size()>0) {
                upsert terminationTxns;
            }
            if(assetRet.size()>0){
                upsert assetRet;
            }
            if(assetSold.size()>0){
                upsert assetSold;
            }
            if(paymentStreamsToUpdate.size()>0)
                update paymentStreamsToUpdate;
            if(rentalStreamsToUpdate.size()>0)
                update rentalStreamsToUpdate;
            if(amzStreamsToUpdate.size()>0)
                update amzStreamsToUpdate;
            if(rentalAccualStreamsToUpdate.size()>0)
                update rentalAccualStreamsToUpdate;
            if(residualStreamsToUpdate.size()>0)
                update residualStreamsToUpdate;
            if(idcStreamsToUpdate.size()>0)
                update idcStreamsToUpdate;
            if(feeStreamsToUpdate.size()>0)
                update feeStreamsToUpdate;
            if(subsidyStreamsToUpdate.size()>0)
                update subsidyStreamsToUpdate;
            if(depStreamsToUpdate.size()>0)
                update depStreamsToUpdate;
            if(balToUpdate.size()>0) {
                update balToUpdate.values();
            }   
            if(nonCashAccountBalancesToUpdate.size()>0) {
                update nonCashAccountBalancesToUpdate;         
            }
        }catch(Exception e) {
            Database.rollback(sp);
            throw new CLSCustomException('Exception while updating: '+e.getMessage()+' stack:'+e.getStackTraceString());
        }
    }
    
    private Decimal getTotalTax(cllease__Contract_Equipment__c equipment, cllease__Due_Detail_Lines__c dueLine) { 
        // Updating the Tax Details in Due Detail line after CL Lease Tax Setup Calculations.
        TaxWithSurcharge cityTax = new TaxWithSurcharge(dueLine.cllease__Rental_Due_Amount__c, equipment.cllease__City_Tax_Rate__c, equipment.cllease__County_Surcharge__c);
        dueLine.cllease__City_Tax__c = cityTax.tax;
        dueLine.cllease__County_Surcharge__c = cityTax.surcharge;
        
        TaxWithSurcharge countyTax = new TaxWithSurcharge(dueLine.cllease__Rental_Due_Amount__c, equipment.cllease__County_Tax_Rate__c, equipment.cllease__County_Surcharge__c);
        dueLine.cllease__County_Tax__c = countyTax.tax;
        dueLine.cllease__County_Surcharge__c = countyTax.surcharge;
        
        TaxWithSurcharge stateTax = new TaxWithSurcharge(dueLine.cllease__Rental_Due_Amount__c, equipment.cllease__State_Tax_Rate__c, equipment.cllease__State_Surcharge__c);
        dueLine.cllease__State_Tax__c = stateTax.tax;
        dueLine.cllease__State_Surcharge__c = stateTax.surcharge;
        
        return (cityTax.tax + cityTax.surcharge) + (countyTax.tax + countyTax.surcharge) + (stateTax.tax + stateTax.surcharge);
    }
    
    private class TaxWithSurcharge {
        Decimal tax;
        Decimal surcharge;
        TaxWithSurcharge(Decimal amount, Decimal rate, Decimal surchargeRate) {
            if(rate > 0) {
                tax = cllease.ValueUtil.round((rate/100) * amount);
                if(surchargeRate > 0) {
                    surcharge = cllease.ValueUtil.round((surchargeRate/100) * tax);
                }
            }
        }
    }
    
    public class Equipment {
        public boolean isSelected {get; set;}        
        public cllease__Contract_Equipment__c eqp {get; set;}
        public clcommon__Equipment_Detail__c eqpDetail {get; set;}
        public Equipment(cllease__Contract_Equipment__c equip) {
            this.eqp = equip;            
            this.isSelected = this.eqp.cllease__Status__c == cllease.LendingConstants.CONTRACT_EQUIPMENT_STATUS_TO_BE_TERMINATED  ? true : false;
        }
        public Equipment(clcommon__Equipment_Detail__c eqpDetail) {
            this.eqpDetail = eqpDetail;            
            this.isSelected = this.eqpDetail.clcommon__Status__c == cllease.LendingConstants.CONTRACT_EQUIPMENT_STATUS_TO_BE_TERMINATED  ? true : false;
        }
    }

    public static String getTerminationLineFieldAPINames() {
        Set<String> lineFieldAPINames = new Set<String>();
        List<cllease__Termination_Config__c> terminationConfigs =
            Database.query(cllease.ProcessJobQueryUtil.getTerminationConfiguration());
        for (cllease__Termination_Config__c termConfig : terminationConfigs) {
            for (cllease__Termination_Config_Line__c line : termConfig.cllease__Termination_Config_Lines__r) {
                if (line.cllease__Quote_Line__c == 'SECURITY DEPOSIT'
                        && (line.cllease__Field_API_Name__c == 'cllease__Security_Deposit_Amount__c'
                            || line.cllease__Field_API_Name__c == 'cllease__Security_Deposit_Amount__c'))
                    continue;
                if (line.cllease__Field_API_Name__c != null)
                    lineFieldAPINames.add(line.cllease__Field_API_Name__c);
            }
        }

        /*if(!isSafeObjectFields(new List<String>(lineFieldAPINames), 'cllease__Lease_Account__c'))
            return '';*/

        // converting to comma separated fields
        String fields = '';
        for (String field : lineFieldAPINames) {
            fields += field + ',';
        }

        return fields;
    }

    public static List<String> getAllPickListValues(String objectType, String columnName) {
        String nameSpace =  'cllease__';
        boolean nameSpaceExists = false;
        if ((nameSpace != null)
                && ((nameSpace.length() > 0))) {
            nameSpaceExists = true;
        }
        String newType = (nameSpaceExists) ? nameSpace + objectType : objectType;
        system.debug(logginglevel.ERROR, '#### newType from getAllPickListValues: ' + newType);
        Schema.sObjectType sObjectType = Schema.getGlobalDescribe().get(newType);
        Map<String, Schema.SObjectField> fieldsMap = sObjectType.getDescribe().fields.getMap();
        system.debug(logginglevel.ERROR, '#### column: ' + (nameSpaceExists ? nameSpace + columnName : columnName));
        Schema.sObjectField field = fieldsMap.get((nameSpaceExists) ? nameSpace + columnName : columnName);
        //system.debug(logginglevel.ERROR, '#### field: '+field);
        // system.debug(logginglevel.ERROR, '#### fieldsMap: '+fieldsMap);
        List<String> pickListValues = new List<String>();
        if (field != null) {
            Schema.DescribeFieldResult fieldResult = field.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for ( Schema.PicklistEntry f : ple) {
                pickListValues.add(f.getValue());
            }
        }
        return pickListValues;
    }
    
}