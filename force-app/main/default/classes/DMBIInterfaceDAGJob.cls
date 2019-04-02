/**
 * Following job helps in cleaning up the DMBI table records 
 * Which runs through multiple instances 
 **/

 global class DMBIInterfaceDAGJob extends clcommon.DynamicJob {

    private static String query;
    private static final String JOB_NAME = 'DMBI Interface DAG Job';
    //query String
    public static Map<String,String> intCodeMapping  = new Map<String, String>();
    public static Set<String> dataObjSet;
    public Map<String, integer> sobjectCountMap      = new Map<String, Integer>();
    global Map<string,List<Integer>> sobjectHashMap  = new Map<string, List<Integer>>();
    public Boolean isSuccess = true;
    public Datetime batchStartTime = System.now();  
    public Map<String, Int_Party__c> insertedPartiesMap = new Map<String, Int_Party__c>();  
    public Decimal ScheduleAmount=0;
    public Decimal ExposureBooked=0;
    public Decimal InterestAmount=0;
    public Decimal ResidualValueBooked = 0;
    public Decimal NetPrincipleBalanceAmount = 0;
    public Decimal ArrearsAmount = 0;
    
    global DMBIInterfaceDAGJob() {
        super(JOB_NAME, initialize());
        doInitialize();
    }
    
    global virtual override String getRuntimeQuery() {
        System.debug(LoggingLevel.ERROR, 'DMBIInterfaceDAGJob in getRuntimeQuery : ' + query);
        return query; 
    }
    
    public static String initialize() {
        // Retrieving the Mapping 
        intCodeMapping  = DMBIInterfaceRecordUtil.getIntMapping();
        // initializing the data sets
        dataObjSet      = DMBIConstants.dataObjectSet;
        // Constructing query for job
        query = DMBIConstants.DMBIQueryStr;

        System.debug(LoggingLevel.ERROR, 'DMBIInterfaceDAGJob query in initialize : ' + query);
        return query;
    }
    
    /**
     * Following method helps in running the batches for batch job
     **/
    public override void doExecute(Database.BatchableContext bc, List<sObject> scope) {
 		//isSuccess = true;
        List<cllease__Lease_Account__c> contracts = (List<cllease__Lease_Account__c>)scope;
        List<sobject> agreementsToInsert = new List<sobject>();
        List<sobject> agreementsToInsert1 = new List<sobject>();
        List<sobject> agreementsToInsert2 = new List<sobject>();
        List<sobject> agreementsToInsert3 = new List<sobject>();
        List<sobject> agreementsToInsert4 = new List<sobject>();
        List<sobject> agreementsToInsert5 = new List<sobject>();
        List<sobject> agreementsToInsert6 = new List<sobject>();
        List<sobject> agreementsToInsert7 = new List<sobject>();
        //List<sobject> agreementsToInsert8 = new List<sobject>();
        Savepoint sp = database.setsavepoint();        
        try {
            //system.debug('contracts-->'+contracts);
            if(!scope.isEmpty()){
                
                //Creating AGREEMENTS report 
                List<Int_Agreement__c> agreementRecords = DMBIInterfaceRecordUtil.CreateAgreements(contracts, IntCodeMapping);
                constructControlMap('Int_Agreement__c', DMBIInterfaceRecordUtil.CountInsertedRecords(agreementRecords));
                
                if(!agreementRecords.isEmpty()){
                    calculateHashcodeFields((List<sObject>)agreementRecords);

                    List<Int_Asset__c> AssetRecords = DMBIInterfaceRecordUtil.CreateAssets(contracts,IntCodeMapping);
                    constructControlMap('Int_Asset__c',DMBIInterfaceRecordUtil.CountInsertedRecords(AssetRecords));                    
                    if(!AssetRecords.isEmpty()){ 

                        List<Int_Agreement_Line__c> agreementLinesList = DMBIInterfaceRecordUtil.CreateAgreementlines(agreementRecords, contracts, IntCodeMapping); 
                        if(!agreementLinesList.isEmpty()){
                            Database.Insert(AgreementLinesList, false);
                            constructControlMap('Int_Agreement_Line__c',DMBIInterfaceRecordUtil.CountInsertedRecords(agreementLinesList));                            
                            List<sobject> AgrLineAssetsAndCollateralsList = DMBIInterfaceRecordUtil.CreateAgrLineAssetsAndCollaterals(agreementLinesList, contracts, AssetRecords);
                            calculateObjectCount(AgrLineAssetsAndCollateralsList);
                        }
                    }
                }

                if (!agreementRecords.IsEmpty() && !contracts.IsEmpty()){
                    //PARTIES
                    List<Int_Party__c> IntParties = DMBIInterfaceRecordUtil.CreateParties(contracts,insertedPartiesMap.keyset(),IntCodeMapping);
                    //system.debug('IntParties.size()--->'+IntParties.size());
                    if(!IntParties.isEmpty()){
                        constructControlMap('Int_Party__c',DMBIInterfaceRecordUtil.CountInsertedRecords(IntParties));//  
                        UpdateInsertedParties(IntParties);  
                    }
                    
                    agreementsToInsert.AddAll(DMBIInterfaceRecordUtil.CreateIntAgreementPaymentSchedules(agreementRecords,contracts,IntCodeMapping));
                    if(!agreementsToInsert.isEmpty()){
                        calculateObjectCount(agreementsToInsert); 
                        calculateHashcodeFields(agreementsToInsert);     
                    }
                    
                    agreementsToInsert1.AddAll(DMBIInterfaceRecordUtil.CreateIntAgreementPartyStreetAddressDetails(IntParties,contracts,IntCodeMapping));

                    agreementsToInsert2.AddAll(DMBIInterfaceRecordUtil.CreateIntAgreementParties(agreementRecords,contracts,IntParties,insertedPartiesMap.values(),IntCodeMapping));
                    
                    agreementsToInsert3.AddAll(DMBIInterfaceRecordUtil.CreateAgreementInterests(agreementRecords,contracts));
                    if(!agreementsToInsert3.isEmpty()){
                        calculateObjectCount(agreementsToInsert3);  
                        calculateHashcodeFields(agreementsToInsert3);     
                    }
                    agreementsToInsert4.AddAll(DMBIInterfaceRecordUtil.CreateAgreementFeatures(agreementRecords,contracts,IntCodeMapping));
                    if(!agreementsToInsert4.isEmpty()){
                        calculateObjectCount(agreementsToInsert4);    
                    }

                    agreementsToInsert5.AddAll(DMBIInterfaceRecordUtil.CreateIntAgreementPartyExternalReferences(IntParties,contracts,IntCodeMapping));
                    if(!agreementsToInsert5.isEmpty()){
                        calculateHashcodeFields(agreementsToInsert5); 
                    }

                    agreementsToInsert6.AddAll(DMBIInterfaceRecordUtil.CreateAgreementClassifications(agreementRecords,contracts,IntCodeMapping));
                    if(!agreementsToInsert6.isEmpty()){
                        calculateObjectCount(agreementsToInsert6);    
                    }

                    agreementsToInsert7.AddAll(DMBIInterfaceRecordUtil.CreateAgreementExposures(agreementRecords,contracts,IntCodeMapping));                 
                    if(!agreementsToInsert7.isEmpty()){
                        calculateObjectCount(agreementsToInsert7);  
                        calculateHashcodeFields(agreementsToInsert7);     
                    }
                }
            }

            if(!agreementsToInsert.isEmpty()){
                Insert agreementsToInsert;
                //system.debug('agreementsToInsert--->'+agreementsToInsert.size());
            }
            if(!agreementsToInsert1.isEmpty()){
                //Insert agreementsToInsert1;
                Database.insert(agreementsToInsert1, false);
                constructControlMap('Int_Party_Street_Address__c',DMBIInterfaceRecordUtil.CountInsertedRecords(agreementsToInsert1));//    
                //system.debug('agreementsToInsert1--->'+agreementsToInsert1.size());
            }
            if(!agreementsToInsert2.isEmpty()){
                Insert agreementsToInsert2;
                //Database.Insert(agreementsToInsert2,false);
                constructControlMap('Int_Agreement_Party__c',DMBIInterfaceRecordUtil.CountInsertedRecords(agreementsToInsert2));//    
                //system.debug('agreementsToInsert2--->'+agreementsToInsert2.size());
            }
            if(!agreementsToInsert3.isEmpty()){
                //Insert agreementsToInsert3;
                database.insert(agreementsToInsert3,false);
                //system.debug('agreementsToInsert3--->'+agreementsToInsert3.size());
            }
            if(!agreementsToInsert4.isEmpty()){
                Insert agreementsToInsert4;
                //system.debug('agreementsToInsert4--->'+agreementsToInsert4.size());
            }
            if(!agreementsToInsert5.isEmpty()){
                //Insert agreementsToInsert5;
                Database.insert(agreementsToInsert5, false);
                constructControlMap('Int_Party_External_Reference__c',DMBIInterfaceRecordUtil.CountInsertedRecords(agreementsToInsert5));
                //system.debug('agreementsToInsert4--->'+agreementsToInsert4.size());
            }
            if(!agreementsToInsert6.isEmpty()){
                Insert agreementsToInsert6;
                //system.debug('agreementsToInsert4--->'+agreementsToInsert4.size());
            }
            if(!agreementsToInsert7.isEmpty()){
                Insert agreementsToInsert7;
                //system.debug('agreementsToInsert4--->'+agreementsToInsert4.size());
            }

        } catch(exception e){
            database.rollback(sp);
            if(!e.getMessage().contains('Party number')){
                isSuccess = false;
            }
            System.debug(LoggingLevel.ERROR, 'DMBIInterfaceDAGJob Exception in execute method : '+e.getMessage());
            System.debug(LoggingLevel.ERROR, 'DMBIInterfaceDAGJob Exception in linenumber : '+e.getLineNumber());
            //insert batch process log for exceptions
            insert new cllease__Batch_Process_Log__c(Name='DMBIInterfaceDAGJob execute() : ', cllease__Date__c = System.today(), 
            cllease__Message__c='Error is '+ ( e.getmessage().length()>255 ? e.getMessage().subString(0,255) : e.getMessage())
            +' in line number: '+ e.getlinenumber());
        }
    }
    
    private void constructControlMap(String ObjectName, integer sizeOfList){
        if(sobjectCountMap.containskey(ObjectName)){
            sobjectCountMap.put(ObjectName, sobjectCountMap.get(ObjectName)+sizeOfList);    
        }
        else{
            sobjectCountMap.put(ObjectName, sizeOfList);
        }
    }
    
    public void calculateObjectCount(List<sobject> SobjectList){
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
                constructControlMap(ObjName,CountMap.get(ObjName));
            }
        }
    }

    //Update insertedPartiesMap
    public void UpdateInsertedParties(List<Int_Party__c> Parties){
        If(!Parties.isEmpty()){
            for(Int_Party__c party: Parties){
                If(party.Id != Null){
                    insertedPartiesMap.put(party.Party_Number__c,party);   
                }    
            }    
        } 
    }

    //Calculate Hashtotal1 for file control
    public void calculateHashcodeFields(List<sobject> SobjectList){
        Map<string,string> HashMap = new Map<string,string>();
        
        for(sobject obj:SobjectList){
            string objname = string.valueof(obj.getSObjectType()); 
            if (objname == 'Int_Agreement_Payment_Schedule__c') {
                ScheduleAmount = ScheduleAmount + Integer.valueOf(obj.get('Schedule_Amount__c')); 
            }
            else if (objname == 'Int_Agreement_Exposure__c') {   
                ExposureBooked = ExposureBooked + Integer.valueOf(obj.get('Exposure_Booked__c'));
            }    
            else if (objname == 'Int_Agreement_Interest__c'){    
                InterestAmount = InterestAmount + Integer.valueOf(obj.get('Interest_Amount__c')); 
            }     
            else if (objname == 'Int_Agreement__c')  {  
                ResidualValueBooked = ResidualValueBooked + Integer.valueOf(obj.get('Residual_Value_Booked__c')); 
                NetPrincipleBalanceAmount = NetPrincipleBalanceAmount + Integer.valueOf(obj.get('Net_Principal_Balance_Amount__c'));
                ArrearsAmount = ArrearsAmount + Integer.valueOf(obj.get('Arrears_Amount__c'));
            }       
        } 
    } 

    public void PrepareHashmap(){           
        if (!SobjectHashMap.containskey('Int_Agreement_Payment_Schedule__c')) {
            SobjectHashMap.put('Int_Agreement_Payment_Schedule__c',new List<Integer>{system.hashcode(ScheduleAmount),0,0});
        }                        
        if (!SobjectHashMap.containskey('Int_Agreement_Exposure__c')) {
            SobjectHashMap.put('Int_Agreement_Exposure__c',new List<Integer>{system.hashcode(ExposureBooked),0,0});
        }
        if (!SobjectHashMap.containskey('Int_Agreement_Interest__c')) {
            SobjectHashMap.put('Int_Agreement_Interest__c',new List<Integer>{system.hashcode(InterestAmount),0,0});
        }
        if (!SobjectHashMap.containskey('Int_Agreement__c')) {
            SobjectHashMap.put('Int_Agreement__c',new List<Integer>{system.hashcode(ResidualValueBooked),system.hashcode(NetPrincipleBalanceAmount),system.hashcode(ArrearsAmount)});
        }
    }
    
    public override void doInitialize() { }
    public override void doStart(Database.BatchableContext bc) { }

	public override void doFinish(Database.BatchableContext bc) {
        try{
            if(isSuccess ){
                system.debug('SobjectCountMap----####--->'+SobjectCountMap.size()+' '+ SobjectCountMap);
                Datetime BatchEndTime = system.now();
                PrepareHashmap();
                SobjectCountMap.put('Int_Delivery_Control__c',      1);
              //SobjectCountMap.put('Int_File_Control__c',28);
                SobjectCountMap.put('Int_Facility__c',              0);
                SobjectCountMap.put('Int_Agreement_Non_IFRS__c',    0);  
                SobjectCountMap.put('Int_Agreement_Provision__c',   0); 
                SobjectCountMap.put('Int_Asset_Feature__c',         0);   
                SobjectCountMap.put('Int_Asset_Usage__c',           0);                     
                SobjectCountMap.put('Int_Facility_Feature__c',      0);    
                SobjectCountMap.put('Int_Facility_Party__c',        0);  
                SobjectCountMap.put('Int_Party_Feature__c',         0);   
                SobjectCountMap.put('Int_Risk_Costs_Movements__c',  0);   
                SobjectCountMap.put('Int_Agreement_Line_Feature__c',0);
                for(String obj: DataObjSet){
                    If(!SobjectCountMap.containskey(obj)){
                        SobjectCountMap.put(obj,0);
                    }
                }
                if(!SobjectCountMap.isEmpty()){
                    List<sobject> controlObjectsToInsert = new List<sobject>();
                    for(string ObjectName : SobjectCountMap.keySet()){
                        //Create file control objects here
                        controlObjectsToInsert.add(DMBIInterfaceRecordUtil.createFileControlObjects(ObjectName,SobjectCountMap.get(ObjectName),SobjectHashMap,BatchstartTime,BatchEndTime,IntCodeMapping));
                        //system.debug('**filename***' + controlObjectsToInsert.get(0).get('File_Name__c'));
                    }
                    //Create delivery control objects here
                    controlObjectsToInsert.add(DMBIInterfaceRecordUtil.createDeliveryControlObjects(BatchstartTime,IntCodeMapping));
                    if(!controlObjectsToInsert.isEmpty()){
                        Insert controlObjectsToInsert; 
                    }
                }
            }
        } catch(exception e){
            System.debug(LoggingLevel.ERROR, 'Exception while processing batch finish method: '+e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Exception StackTrace: '+e.getStackTraceString()+ ' '+e.getLineNumber());
            
            insert new cllease__Batch_Process_Log__c(Name='DMBIInterfaceDAGJob finish() : ', cllease__Date__c = System.today(), 
            cllease__Message__c='Error is '+ ( e.getmessage().length()>255 ? e.getMessage().subString(0,255) : e.getMessage())
            +' in line number: '+ e.getlinenumber());
        }
    }
}