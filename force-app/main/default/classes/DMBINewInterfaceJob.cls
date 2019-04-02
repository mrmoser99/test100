//batch apex 
global with sharing class DMBINewInterfaceJob extends clcommon.DynamicJob {
    //query string
    global static String query;
    public map<string,string> IntCodeMapping = new map<string,string>();
    global map<string,integer> SobjectCountMap = new map<string,integer>();//{'Int_Delivery_controle__c'=>1,'Int_file_controle__c'=>28,'Int_facility__c'=>0,'Int_agreement_non_IFRS__c'=>0,'Int_agreement_provision'=>0,'Int_Asset_feature__c'=>0,'Int_Asset_Usage__c'=>0,'Int_Collateral__c'=>0,'Int_collateral_Agreement__c'=>0,'Int_Collateral_Party__c'=>0,'Int_Facility_Feature__c'=>0,'Int_Facility_Party__c'=>0,'Int_Party_feature__c'=>0,'Int_Risk_Costs_Movements__c'=>0};
    global set<String> DataObjSet = new set<String>{'Int_Agreement__c','Int_Agreement_Classification__c','Int_Agreement_Exposure__c','Int_Agreement_Feature__c','Int_Agreement_Interest__c','Int_Agreement_Line__c','Int_Agreement_Line_Asset__c','Int_Agreement_Party__c','Int_Agreement_Payment_Schedule__c','Int_Asset__c','Int_Party__c','Int_Party_External_Reference__c','Int_Party_Street_Address__c','Int_Collateral__c','Int_Collateral_Party__c','Int_Collateral_Agreement__c'};
    global map<string,string> SobjectHashMap = new map<string,string>();
    global boolean isSuccess = true;
    global datetime BatchstartTime = system.now();  
    global map<String,Int_Party__c> insertedPartiesMap = new map<String,Int_Party__c>();
    //private static String query;
    private String openPeriodEndDate;
    private Date currentSystemDate;
    private Date yearStartDate;
    private Date monthStartDate;
    private String currentSystemDateStr;
    private cllease__Period_Status__c openPeriod;
    private static final String JOB_NAME = 'DMBI New Interface Job';  
    
    global DMBINewInterfaceJob() {
        super(JOB_NAME, initialize(null));
    }
    
    global DMBINewInterfaceJob(List<String> contractNames, Date dateToRun) {
        super(JOB_NAME, initialize(contractNames));
        currentSystemDate   = dateToRun;
        //openPeriod       = periodToRun;
    }
    
    global virtual override String getRuntimeQuery() {
        System.debug(LoggingLevel.ERROR, 'DMBINewInterfaceJob query in getRuntimeQuery : ' + query);
        return query; 
    }
    
    global static String initialize(List<String> contractNames) {     
    
        
        query = DMBIInterfaceRecordGeneratorJob.ConstructQuery() ;
        if(contractNames!=null && contractNames.size() > 0) {
                String contractNamesStr = '';
                for (String contractName : contractNames) {
                  contractNamesStr = contractNamesStr + '\'' + String.escapeSingleQuotes(contractName) + '\'' + ',';
                }
                contractNamesStr = contractNamesStr.substring(0, contractNamesStr.length() - 1);
                query += ' AND Name in ('+ contractNamesStr + ') ';
         }

        query += ' ORDER BY Name';
        
        System.debug(LoggingLevel.ERROR, 'DMBINewInterfaceJob query in initialize : ' + query);
        return query;
    }
    
    
     public override void doInitialize() { }
     public override void doStart(Database.BatchableContext bc) {
        IntCodeMapping = DMBIInterfaceRecordGeneratorJob.getIntMapping(); 
        //0. Checking for unfinished transactions in interface table.
        //   Incase of any unfinished transactions, job should not run till all txns commited to DLL
        //Throw exception and skip the job run in case of any unfinished transactions
        //    uncommittedInterfaceRecordsExist = true for all interface records not processed
        //                               = false for all interface records  processed 
        Boolean uncommittedInterfaceRecordsExist 
            = InterfaceTablesUnfinishedTxnsCheck.checkUnfinishedTxnsForNetInvestmentReport();
        
        if(uncommittedInterfaceRecordsExist) {
            throw new CLSCustomException('Net Investment Interface table(Int_OLMN_Net_Investment__c) has unfinished transactions. '+
                    'Please commit all transactions from Interface table and run Job again...');
        }
     }   
    //Execute method 
    public override void doExecute(Database.BatchableContext BC, List<sObject> scope){
        //isSuccess = true;
        List<cllease__Lease_Account__c> contracts = (List<cllease__Lease_Account__c>)scope;
        List<sobject> AgreementsToInsert = new list<sobject>();
        List<sobject> AgreementsToInsert1 = new list<sobject>();
        List<sobject> AgreementsToInsert2 = new list<sobject>();
        List<sobject> AgreementsToInsert3 = new list<sobject>();
        List<sobject> AgreementsToInsert4 = new list<sobject>();
        List<sobject> AgreementsToInsert5 = new list<sobject>();
        List<sobject> AgreementsToInsert6 = new list<sobject>();
        List<sobject> AgreementsToInsert7 = new list<sobject>();
        //List<sobject> AgreementsToInsert8 = new list<sobject>();
        Savepoint sp = database.setsavepoint();        
        try {
                     if(currentSystemDate == null) {
          currentSystemDate   = cllease.SystemDateUtil.getCurrentSystemDate();
        }

            // Retrieving Period for which date report runs
            List<cllease__Period_Status__c> openPeriods = [SELECT Id, Name,
                                                            cllease__Start_Date__c,
                                                            cllease__End_Date__c,
                                                            cllease__Period_Year__c
                                                        FROM cllease__Period_Status__c
                                                        WHERE cllease__Status__c = 'Open'
                                                        ORDER BY cllease__End_Date__c DESC];

            // Taking the last open period for which needed to run Net Investment Report
            if(openPeriods.size() > 0) {
                openPeriod = openPeriods[0];
            }
            if(openPeriod == null) {
                throw new CLSCustomException('No Open Period available, Open period to proceed...');
            }

        System.debug(LoggingLevel.ERROR, ' currentSystemDate: '+currentSystemDate);

            // Issue: While converting DateTime to String format, it always giving 1 day less so adding up 1 day to cover up.
            Datetime periodEndDate      = openPeriod.cllease__End_Date__c;
            Datetime currentSystemNow   = System.now();

            periodEndDate = periodEndDate.addHours(currentSystemNow.hour());
            periodEndDate = periodEndDate.addMinutes(currentSystemNow.minute());
            periodEndDate = periodEndDate.addSeconds(currentSystemNow.second());

          openPeriodEndDate      = periodEndDate.format('yyyyMMdd'); 
          //currentSystemDateStr    = ((Datetime)currentSystemDate).format('yyyyMMdd');
        yearStartDate       = Date.newInstance(currentSystemDate.year(), 1, 1);
        monthStartDate      = Date.newInstance(currentSystemDate.year(), currentSystemDate.month(), 1); 
            //system.debug('contracts-->'+contracts);
            if(!scope.isEmpty()){
                //AGREEMENTS
                list<Int_Agreement__c> AgreementRecords = DMBIInterfaceRecordGeneratorJob.CreateAgreements(contracts,IntCodeMapping);
                ConstructControlMap('Int_Agreement__c',DMBIInterfaceRecordGeneratorJob.CountInsertedRecords(AgreementRecords));
                if(!AgreementRecords.isEmpty()){
                    list<Int_Asset__c> AssetRecords = DMBIInterfaceRecordGeneratorJob.CreateAssets(contracts,IntCodeMapping);
                    ConstructControlMap('Int_Asset__c',DMBIInterfaceRecordGeneratorJob.CountInsertedRecords(AssetRecords));                    
                    if(!AssetRecords.isEmpty()){                                              
                        list<Int_Agreement_Line__c> AgreementLinesList = DMBIInterfaceRecordGeneratorJob.CreateAgreementlines(AgreementRecords,contracts,IntCodeMapping);                           
                        if(!AgreementLinesList.isEmpty()){
                            Database.Insert(AgreementLinesList,false);
                            ConstructControlMap('Int_Agreement_Line__c',DMBIInterfaceRecordGeneratorJob.CountInsertedRecords(AgreementLinesList));                            
                            list<sobject> AgrLineAssetsAndCollateralsList = DMBIInterfaceRecordGeneratorJob.CreateAgrLineAssetsAndCollaterals(AgreementLinesList,contracts,AssetRecords);
                            CalculateObjectCount(AgrLineAssetsAndCollateralsList);
                        }
                    }
                }
                if (!AgreementRecords.IsEmpty() && !contracts.IsEmpty()){
                    //PARTIES
                    list<Int_Party__c> IntParties = DMBIInterfaceRecordGeneratorJob.CreateParties(contracts,insertedPartiesMap.keyset(),IntCodeMapping);
                    //system.debug('IntParties.size()--->'+IntParties.size());
                    if(!IntParties.isEmpty()){
                        ConstructControlMap('Int_Party__c',DMBIInterfaceRecordGeneratorJob.CountInsertedRecords(IntParties));//  
                        UpdateInsertedParties(IntParties);  
                    }
                    AgreementsToInsert.AddAll(DMBIInterfaceRecordGeneratorJob.CreateIntAgreementPaymentSchedules(AgreementRecords,contracts,IntCodeMapping));
                    if(!AgreementsToInsert.isEmpty()){
                        CalculateObjectCount(AgreementsToInsert); 
                        CalculateHashCode(AgreementsToInsert);     
                    }
                    AgreementsToInsert5.AddAll(DMBIInterfaceRecordGeneratorJob.CreateIntAgreementPartyExternalReferences(IntParties,contracts,IntCodeMapping));
                    if(!AgreementsToInsert5.isEmpty()){
                        CalculateHashCode(AgreementsToInsert5); 
                    }
                    
                    AgreementsToInsert1.AddAll(DMBIInterfaceRecordGeneratorJob.CreateIntAgreementPartyStreetAddressDetails(IntParties,contracts,IntCodeMapping));

                    AgreementsToInsert2.AddAll(DMBIInterfaceRecordGeneratorJob.CreateIntAgreementParties(AgreementRecords,contracts,IntParties,insertedPartiesMap.values(),IntCodeMapping));

                    AgreementsToInsert6.AddAll(DMBIInterfaceRecordGeneratorJob.CreateAgreementClassifications(AgreementRecords,contracts,IntCodeMapping));
                    if(!AgreementsToInsert6.isEmpty()){
                        CalculateObjectCount(AgreementsToInsert6);    
                    }
                    AgreementsToInsert7.AddAll(DMBIInterfaceRecordGeneratorJob.CreateAgreementExposures(AgreementRecords,contracts,IntCodeMapping));                 
                    if(!AgreementsToInsert7.isEmpty()){
                        CalculateObjectCount(AgreementsToInsert7);  
                        CalculateHashCode(AgreementsToInsert7);     
                    }
                    AgreementsToInsert3.AddAll(DMBIInterfaceRecordGeneratorJob.CreateAgreementInterests(AgreementRecords,contracts));
                    if(!AgreementsToInsert3.isEmpty()){
                        CalculateObjectCount(AgreementsToInsert3);  
                        CalculateHashCode(AgreementsToInsert3);     
                    }
                    AgreementsToInsert4.AddAll(DMBIInterfaceRecordGeneratorJob.CreateAgreementFeatures(AgreementRecords,contracts,IntCodeMapping));
                    if(!AgreementsToInsert4.isEmpty()){
                        CalculateObjectCount(AgreementsToInsert4);    
                    }
                }
            }
            if(!AgreementsToInsert.isEmpty()){
                Insert AgreementsToInsert;
                //system.debug('AgreementsToInsert--->'+AgreementsToInsert.size());
            }
            if(!AgreementsToInsert1.isEmpty()){
                //Insert AgreementsToInsert1;
                Database.insert(AgreementsToInsert1,False);
                ConstructControlMap('Int_Party_Street_Address__c',DMBIInterfaceRecordGeneratorJob.CountInsertedRecords(AgreementsToInsert1));//    
                //system.debug('AgreementsToInsert1--->'+AgreementsToInsert1.size());
            }
            if(!AgreementsToInsert2.isEmpty()){
                Insert AgreementsToInsert2;
                //Database.Insert(AgreementsToInsert2,false);
                ConstructControlMap('Int_Agreement_Party__c',DMBIInterfaceRecordGeneratorJob.CountInsertedRecords(AgreementsToInsert2));//    
                //system.debug('AgreementsToInsert2--->'+AgreementsToInsert2.size());
            }
            if(!AgreementsToInsert3.isEmpty()){
                //Insert AgreementsToInsert3;
                database.insert(AgreementsToInsert3,false);
                //system.debug('AgreementsToInsert3--->'+AgreementsToInsert3.size());
            }
            if(!AgreementsToInsert4.isEmpty()){
                Insert AgreementsToInsert4;
                //system.debug('AgreementsToInsert4--->'+AgreementsToInsert4.size());
            }
            if(!AgreementsToInsert5.isEmpty()){
                //Insert AgreementsToInsert5;
                Database.insert(AgreementsToInsert5, false);
                ConstructControlMap('Int_Party_External_Reference__c',DMBIInterfaceRecordGeneratorJob.CountInsertedRecords(AgreementsToInsert5));
                //system.debug('AgreementsToInsert4--->'+AgreementsToInsert4.size());
            }
            if(!AgreementsToInsert6.isEmpty()){
                Insert AgreementsToInsert6;
                //system.debug('AgreementsToInsert4--->'+AgreementsToInsert4.size());
            }
            if(!AgreementsToInsert7.isEmpty()){
                Insert AgreementsToInsert7;
                //system.debug('AgreementsToInsert4--->'+AgreementsToInsert4.size());
            }
        }
        Catch(exception e){
            database.rollback(sp);
            if(!e.getMessage().contains('Party number')){
                isSuccess = false;
            }
            System.debug(LoggingLevel.ERROR, 'Exception while processing DMBINewInterfaceJob: '+e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Exception StackTrace: '+e.getStackTraceString());
            //insert batch process log for exceptions
            insert new cllease__Batch_Process_Log__c(Name='DMBINewInterfaceJob ',
            cllease__Date__c=system.today(), cllease__Message__c='Error is '+e.getmessage()
            +' in line number: '+ e.getlinenumber());
        }
    }
    public void ConstructControlMap(string ObjectName, integer sizeOfList){
        if(SobjectCountMap.containskey(ObjectName)){
            SobjectCountMap.put(ObjectName, SobjectCountMap.get(ObjectName)+sizeOfList);    
        }
        else{
            SobjectCountMap.put(ObjectName, sizeOfList);
        }
    }
    Public void CalculateObjectCount(list<sobject> SobjectList){
        Map<string,integer> CountMap = new Map<string,integer>();
        //string objname = string.valueof(obj.getSObjectType());
        for(sobject obj:SobjectList){
            if(obj!=Null){
                string objname = string.valueof(obj.getSObjectType()); 
                if(!countMap.containskey(objname)){
                    CountMap.put(objname,1);
                }
                else{
                    CountMap.put(objname,CountMap.get(objname)+1);
                }
            }   
        }
        if(!CountMap.isEmpty()){
            for(string ObjName : CountMap.keyset()){
                ConstructControlMap(ObjName,CountMap.get(ObjName));
            }
        }
    }
    //Update insertedPartiesMap
    Public void UpdateInsertedParties(List<Int_Party__c> Parties){
        If(!Parties.isEmpty()){
            for(Int_Party__c party: Parties){
                If(party.Id != Null){
                    insertedPartiesMap.put(party.Party_Number__c,party);   
                }    
            }    
        } 
    }
    //Calculate Hashtotal1 for file control
    Public void CalculateHashCode(list<sobject> SobjectList){
        Map<string,string> HashMap = new Map<string,string>();
        Decimal ScheduleAmount=0;
        Decimal ExposureBooked=0;
        Decimal InterestAmount=0;
        for(sobject obj:SobjectList){
            string objname = string.valueof(obj.getSObjectType()); 
            if (objname == 'Int_Agreement_Payment_Schedule__c') {
                ScheduleAmount = ScheduleAmount + Integer.valueOf(obj.get('Schedule_Amount__c')); }
            else if (objname == 'Int_Agreement_Exposure__c')    
                ExposureBooked = ExposureBooked + Integer.valueOf(obj.get('Exposure_Booked__c'));
            else if (objname == 'Int_Agreement_Interest__c')    
                InterestAmount = InterestAmount + Integer.valueOf(obj.get('Interest_Amount__c'));     
        }        
        if (!SobjectHashMap.containskey('Int_Agreement_Payment_Schedule__c') && ScheduleAmount > 0) {
            SobjectHashMap.put('Int_Agreement_Payment_Schedule__c',String.valueOf(system.hashcode(ScheduleAmount)));
        }                        
        if (!SobjectHashMap.containskey('Int_Agreement_Exposure__c') && ExposureBooked > 0) {
            SobjectHashMap.put('Int_Agreement_Exposure__c',String.valueOf(system.hashcode(ExposureBooked)));
        }
        if (!SobjectHashMap.containskey('Int_Agreement_Interest__c') && InterestAmount > 0) {
            SobjectHashMap.put('Int_Agreement_Interest__c',String.valueOf(system.hashcode(InterestAmount)));
        }
    }
    //Finish method
    public override void doFinish(Database.BatchableContext BC){
        try{
            if(isSuccess ){
                system.debug('SobjectCountMap----####--->'+SobjectCountMap.size()+' '+ SobjectCountMap);
                Datetime BatchEndTime = system.now();
                SobjectCountMap.put('Int_Delivery_Control__c',1);
              //SobjectCountMap.put('Int_File_Control__c',28);
                SobjectCountMap.put('Int_Facility__c',0);
                SobjectCountMap.put('Int_Agreement_Non_IFRS__c',0);  
                SobjectCountMap.put('Int_Agreement_Provision__c',0); 
                SobjectCountMap.put('Int_Asset_Feature__c',0);   
                SobjectCountMap.put('Int_Asset_Usage__c',0);                     
                SobjectCountMap.put('Int_Facility_Feature__c',0);    
                SobjectCountMap.put('Int_Facility_Party__c',0);  
                SobjectCountMap.put('Int_Party_Feature__c',0);   
                SobjectCountMap.put('Int_Risk_Costs_Movements__c',0);   
                SobjectCountMap.put('Int_Agreement_Line_Feature__c',0);
                for(String obj: DataObjSet){
                    If(!SobjectCountMap.containskey(obj)){
                        SobjectCountMap.put(obj,0);
                    }
                }
                if(!SobjectCountMap.isEmpty()){
                    list<sobject> ControlObjectsToInsert = new list<sobject>();
                    for(string ObjectName : SobjectCountMap.keySet()){
                        //Create file control objects here
                        ControlObjectsToInsert.add(DMBIInterfaceRecordGeneratorJob.createFileControlObjects(ObjectName,SobjectCountMap.get(ObjectName),SobjectHashMap,BatchstartTime,BatchEndTime,IntCodeMapping));
                        //system.debug('**filename***' + ControlObjectsToInsert.get(0).get('File_Name__c'));
                    }
                    //Create delivery control objects here
                    ControlObjectsToInsert.add(DMBIInterfaceRecordGeneratorJob.createDeliveryControlObjects(BatchstartTime,IntCodeMapping));
                    if(!ControlObjectsToInsert.isEmpty()){
                        Insert ControlObjectsToInsert; 
                    }
                }
            }
        }
        catch(exception e){
            System.debug(LoggingLevel.ERROR, 'Exception while processing batch finish method: '+e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Exception StackTrace: '+e.getStackTraceString()+ ' '+e.getLineNumber());
        }
    }
}