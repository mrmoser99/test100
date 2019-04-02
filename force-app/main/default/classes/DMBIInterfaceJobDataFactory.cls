@isTest public class DMBIInterfaceJobDataFactory {
    public static int_agreement__c createagreement(){
        int_agreement__c agr= new int_agreement__c(
            Agreement_Source_System__c='CLCMUS',
            Agreement_Number__c=string.valueOf(integer.valueof(math.random()*10000000)),Arrears_Amount__c=123,Agreement_Rate__c = 11.35,Residual_Value_Booked__c = 123,Net_Principal_Amount__c=134,Hyperion_Base_Entity__c='BEQUS',Agreement_Activation_Date__c=system.today(),Agreement_Maturity_Date__c=system.today(),Payment_Frequency_Code__c='M',Payment_Type_Code__c='AR',Days_In_Arrears__c='90',Net_Principal_Balance_Amount__c=123,Deal_Date__c=system.today());
        insert agr;
        return agr;
    }
    public static Int_file_control__c createFilecontrol(){
        Int_file_control__c agrCls = new Int_file_control__c(File_Name__c='testFileName',Committed__c=true);
        insert agrcls;
        return agrCls;
    }
    public static Int_delivery_control__c createDeliverycontrol(){
        Int_delivery_control__c agrCls = new Int_delivery_control__c(Source_System__c='sstest',Committed__c=true,Reporting_Date__c=system.today());
        insert agrcls;
        return agrCls;
    }
    // 
    public static Int_Party_Feature__c createPartyFeature(int_agreement__c agr){
        //Int_Party_Feature__c agrCls = new Int_Party_Feature__c(Party_Source_System__c='clmns',Party_Number__c='12457',currencyisocode='USD',Committed__c=true);
        Int_Party_Feature__c agrCls = new Int_Party_Feature__c(Party_Source_System__c='clmns',Party_Number__c='12457',Committed__c=true);
        insert agrcls;
        return agrCls;
    }
    public static Int_Asset__c createAsset(){
        Int_Asset__c agrCls = new Int_Asset__c(Asset_Source_System__c='testss',Global_Master_Asset_Type_Code__c='tcode'
                                              ,Global_Master_Asset_Type__c='mst'
                                              ,Object_Category_Number__c='12345'
                                               ,Asset_Number__c = '1234'
                                               ,Committed__c=true
                                              );
        insert agrcls;
        return agrCls;
    }
    public static Int_Party__c createEParty(){
        Int_Party__c agrCls = new Int_Party__c(
        Party_Source_System__c='test',
            Party_Number__c = '4587',
            Committed__c=true
        );
        insert agrcls;
        return agrCls;
    }
    public static Int_Party_External_Reference__c createExernalRef(int_agreement__c agr){
        Int_Party_External_Reference__c agrCls = new Int_Party_External_Reference__c(
        Party_Source_System__c='test',
            Party_Number__c='5949'
            ,Committed__c =true,
            Party_Name__c = agr.Id
        );
        insert agrcls;
        return agrCls;
    }
    public static Int_Agreement_Payment_Schedule__c createpaymentShedule(int_agreement__c agr){
        Int_Agreement_Payment_Schedule__c agrCls = new Int_Agreement_Payment_Schedule__c(
        Agreement_Source_System__c='test',
            Schedule_Start_Date__c= system.today(),
            Agreement_Number__c='les19038028023',
            Agreement_Name__c=agr.Id,
            Committed__c=true
        );
        insert agrcls;
        return agrCls;
    }
    public static Int_Party_Street_Address__c createStreetAddress(int_agreement__c agr){
        Int_Party_Street_Address__c agrCls = new Int_Party_Street_Address__c(
        Party_Source_System__c='test',
            Party_Number__c='4875',
            Party_Name__c=agr.Id,
            Committed__c = true
        );
        insert agrcls;
        return agrCls;
    }
    
    public static Int_Agreement_Party__c createAgrParty(int_agreement__c agr){
        Int_Agreement_Party__c agrCls = new Int_Agreement_Party__c(
        Party_Role_Type_Code__c ='ffa',
            Agreement_Source_System__c='test',
            Agreement_Number__c='28sj92',
            Party_Number__c='5479562',
            Agreement_Name__c=agr.Id,
            Party_Source_System__c='pss',
            committed__c = true
        );
        insert agrcls;
        return agrCls;
    }
    
    public static Int_Agreement_Line_Asset__c createAgrlineAsset(int_agreement__c agr){
        Int_Agreement_Line_Asset__c agrCls = new Int_Agreement_Line_Asset__c();
        insert agrcls;
        return agrCls;
    }
    public static Int_Agreement_line_Feature__c createAgrlinefeature(int_agreement__c agr){
        Int_Agreement_line_Feature__c agrCls = new Int_Agreement_line_Feature__c(
            Agreement_Source_System__c='test',
            Agreement_number__c='24837',
            Agreement_Line_Number__c = 'skala',
            agreement_name__c=agr.Id,
            committed__c=true
        );
        insert agrcls;
        return agrCls;
    }
    public static Int_Agreement_Line__c createAgrLine(int_agreement__c agr){
        Int_Agreement_Line__c agrCls = new Int_Agreement_Line__c();
        insert agrcls;
        return agrCls;
    }
    public static Int_Agreement_Interest__c createAgrinterests(int_agreement__c agr){
        Int_Agreement_Interest__c agrCls = new Int_Agreement_Interest__c();
        insert agrcls;
        return agrCls;
    }
    public static Int_Delivery_control__c createAgrExposure(){
        Int_Delivery_control__c agrCls = new Int_Delivery_control__c();
        insert agrcls;
        return agrCls;
    }
    public static Int_Agreement_Exposure__c createAgrExposure(int_agreement__c agr){
        Int_Agreement_Exposure__c agrCls = new Int_Agreement_Exposure__c(
        Exposure_Type__c='sll',
            Exposure_Booked__c=123.45,
            Agreement_Source_System__c='test',
            Agreement_Number__c='teae',
            Agreement_Name__c=agr.Id,
            Committed__c=true
        );
        insert agrcls;
        return agrCls;
    }
    public static Int_Agreement_Classification__c createAgrClassification(int_agreement__c agr){
        Int_Agreement_Classification__c agrCls = new Int_Agreement_Classification__c(
        Agreement_Classification_Type_Code__c= 'fpst',
            Agreement_Classification_Code__c='mpfl',
            Agreement_Source_System__c='ssal',
            Agreement_Number__c='les374935703',
            Agreement_Name__c=agr.Id,
            Committed__c=true
        );
        insert agrcls;
        return agrCls;
    }
    Public static list<cllease__Lease_Account__c> createLeaseContract(integer NoOfRecords){
        //
        
        list<cllease__Lease_Account__c> LeaseContactList = new list<cllease__Lease_Account__c>();
        for (integer i = 0;i<NoOfRecords;i++){
            LeaseContactList.add(new cllease__Lease_Account__c( //cllease__Address__r,dealer_Program__r,cllease__Dealer__r,cllease__Account__r,Application__r
                cllease__Lease_Status__c = 'ACTIVE - GOOD STANDING'
                ,cllease__Product_Sub_Type__c = 'FINANCE LEASE'
                ,cllease__Address__c = CreateLeaseAddress().Id //parent id
                ,dealer_Program__c = createDealerProgram().Id //parent id
                ,cllease__Dealer__c = CreateAccount(Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId()).Id //parent id 
                //,cllease__Account__c = CreateAccount().Id //parent id
                ,Application__c = CreateApplication().Id//parent id
                ,cllease__Excess__c = 0
                ,cllease__Days_Convention__c = ''
                ,cllease__Payment_Amount__c = 0
                ,cllease__Down_Payment__c = 0
                ,DLL_Reference_Number__c = 'NWC-'+i
                ,cllease__Amort_Start_Date__c = system.today().adddays(-i)
                ,cllease__Days_Past_Due__c = 90+i
                ,cllease__Residual_Amount__c = 10+i
                ,cllease__Number_of_Pieces_of_Equipment__c = 0
                ,cllease__Currency_Code__c = ''
                ,cllease__Delinquent_Amount__c = 143+i
                ,cllease__Contract_Date__c = system.today().adddays(-i)
                ,cllease__Financed_Amount__c = 124+i
                ,Purchase_Option__c = 'Fair Market Value'
                ,Allowable_Soft_Cost__c = 125+i
                ,cllease__Payment_Frequency__c = 'MONTHLY'
                ,cllease__Security_Deposit_Amount__c = 0
                ,cllease__Maturity_Date__c = system.today().adddays(-i)
                ,Booking_Date__c = system.today().adddays(-i)
                ,cllease__Term__c = 60+i
                ,Cost_of_Funds__c = i
                ,cllease__Yield__c = i+ 0.12
                ,Termination_Date__c = system.today().adddays(-i)
            ));
        }
        if(!LeaseContactList.isEmpty()){
            Upsert LeaseContactList;
        }
        Return LeaseContactList;
    }
    
    //Rental streams
    Private static list<cllease__Rental_Stream__c> CreateRentalStreams(list<cllease__Lease_Account__c> ContractsList){
        list<cllease__Rental_Stream__c> RsList = new list<cllease__Rental_Stream__c>();
        for(cllease__Lease_Account__c cla : ContractsList){
            //cllease__Capital_Recovery__c,cllease__Date__c,cllease__Lease_Income__c,cllease__Accrued_Flag__c
            RsList.add(new cllease__Rental_Stream__c(cllease__Contract__c = cla.id,cllease__Capital_Recovery__c = 123,cllease__Date__c=system.today(),cllease__Lease_Income__c=123,cllease__Accrued_Flag__c= true)) ;
        }
        Return RsList;
    }
    //Residual streams.
    Private static list<cllease__Residual_Stream__c> CreateResidualStreams(list<cllease__Lease_Account__c> ContractsList){
        list<cllease__Residual_Stream__c> RsList = new list<cllease__Residual_Stream__c>();
        for(cllease__Lease_Account__c cla : ContractsList){
            RsList.add(new cllease__Residual_Stream__c(cllease__Beginning_Unearned_Residual_Income__c = 123));
        }
        Return RsList;
    }
    //Contract parites.
    Private static list<cllease__Contract_Parties__c> CreateContractParties(list<cllease__Lease_Account__c> ContractsList){
        list<cllease__Contract_Parties__c> ccpList = new list<cllease__Contract_Parties__c>();
        for(cllease__Lease_Account__c cla : ContractsList){
            //cllease__Party_Type__c,Name,cllease__Contract__r.name,cllease__Party_Account_Name__c
            ccpList.add(new cllease__Contract_Parties__c(cllease__Contract__c = cla.Id,cllease__Party_Type__c='DEALER',cllease__Party_Account_Name__c= CreateAccount(Schema.SObjectType.Account.getRecordTypeInfosByName().get('Lessee').getRecordTypeId()).id));
        }
        Return ccpList;
    }
    //Application records.
    Private static genesis__Applications__c CreateApplication(){
        genesis__Applications__c ga = new genesis__Applications__c(
            genesis__Account__c = CreateAccount(Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId()).Id,
            genesis__ID_Type__c='State ID Card',
            dealer_program__c  = createDealerProgram().id,
            Dealer_Invoice_Number__c='123456',Dealer_Invoice_Date__c=Date.today(),genesis__Term__c=12
        );
        insert ga;
        return ga;
    }
    //equipments records.
    Private static list<cllease__Contract_Equipment__c> CreateEquipments(list<cllease__Lease_Account__c> ContractsList){
    list<cllease__Contract_Equipment__c> Eqlist = new list<cllease__Contract_Equipment__c>();
        //c,cllease__Status__c,cllease__Estimated_Selling_Price__c,cllease__Equipment_Calculated_Cost__c
        for (cllease__Lease_Account__c cla :ContractsList){
            Eqlist.add(new cllease__Contract_Equipment__c(
            cllease__Contract__c = cla.Id,cllease__Residual_Amount__c=123,Master_Asset_Type__c='Test Asset Type',Object_Category_ID__c='Test category id',Object_Category_Name__c='Test catergory name',Asset_Type_ID__c = 'testAssetTypeId',Asset_Type_Name__c='Test type name',cllease__Make__c='tcm',Manufacturer__c='mn',cllease__Model__c = 'clmodel',cllease__Equipment_Serial_Number__c='clsn',cllease__Year__c='2018',cllease__Status__c='LEASED'
                          ,cllease__Estimated_Selling_Price__c=123  ,cllease__Equipment_Calculated_Cost__c=123
            ));
        }        
        insert Eqlist;
        return Eqlist;
    }
    //Dealer 
    Private static void CreateDealer(){
        //cllease__Dealer__c cd = new cllease__Dealer__c(name = 'Test Dealer');
        //return cd;
    }
    //Agreement in Common name space.
    Private static clcommon__Agreement__c createDealerProgram(){
        clcommon__Agreement__c dp = new clcommon__Agreement__c(name='newco');
        insert dp;
        return dp;
    }
    //Lease address
    private static clcommon__Address__c CreateLeaseAddress(){
        /*Address__c leaseAdress = new Address__c(
            Account__c = CreateAccount().id
            ,Zip_Code__c = '19152-2801'
            ,City__c = 'Philadelphia'
            ,State__c = 'PA'
        );*/
        clcommon__Address__c ccAddress = new clcommon__Address__c(clcommon__Zip_Code__c='19152-2801',clcommon__State_Province__c='PA',clcommon__City__c='Philadelphia');//clcommon__Account__c=CreateAccount().id,
        insert ccAddress;
        return ccAddress;
    }
    //Account
    Private static account CreateAccount(id Recordtypeid){
        account acc = new account(RecordTypeId = Recordtypeid,name ='testAcc'+string.valueof( integer.valueof( math.random()*1000000)*100),clcommon__Legal_Entity_Type__c = CreateLeagalEntity().Id);
        Insert acc;
        return acc;
    }
    //Legal entity
    Private static clcommon__Legal_Entity__c CreateLeagalEntity(){
        clcommon__Legal_Entity__c  le = new clcommon__Legal_Entity__c(name = 'Test Leagal Entity');
        insert le;
        return le;
    }
}