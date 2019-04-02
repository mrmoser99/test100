public with sharing class DisplayRecordHandlerr1 {
    
    public static List<cllease__Lease_account_Due_Details__c> billsToUpdate;
    public static List<cllease__Charge__c> chargesToUpdate;
    public static string ACHflagUpdate;

    // Following method helps in creating the Blob for the csv content
    public static String doCreateCSV(Set<Id> contractIds) {

        // Extracting the current system date and change the format.
        Datetime currentCLLeaseDate = cllease.SystemDateUtil.getCurrentSystemDate();
        String currentSystemDateStr = currentCLLeaseDate.format('dd/MM/yyyy');

        List<BillAndChargeCSVRecord> csvRecords = new List<BillAndChargeCSVRecord>();
        List<cllease__Lease_Account__c> contracts = getRecords(contractIds);
        
        System.debug('Contract details: '+contracts);

        // Initializing the bills and charge list for updates.
        billsToUpdate   = new List<cllease__Lease_account_Due_Details__c>();
        chargesToUpdate = new List<cllease__Charge__c>();

        for(cllease__Lease_Account__c leaseContract : contracts) {

            System.debug('Contract due details: '+leaseContract.cllease__Dues_Details__r);
            // looping through Bills
            for(cllease__Lease_account_Due_Details__c bill : leaseContract.cllease__Dues_Details__r) {
                Date dueDate = bill.cllease__Due_Date__c;
                Account acct = bill.cllease__Account__r;
                cllease__Lease_Account__c contract = bill.cllease__Lease_Account__r;
                //code added to Update the ACH_Flag__c on Bills based on the ACH Setup on Contract
                //ACHflagUpdate = (bill.ACH_Flag__c == null|| bill.ACH_Flag__c == false) ? 'false' : 'true';
                System.debug('*****checkthe billAchFlag on the bill level******'+ACHflagUpdate);
                //System.debug(leaseContract.ACH_Configured__c);
                //System.debug(bill.ACH_Flag__c);
                //if(leaseContract.ACH_Configured__c){
                    
                    //bill.ACH_Flag__c = true;
                    //ACHflagUpdate  = 'true';
               // }
                //else if(!leaseContract.ACH_Configured__c){
                    
                  //  bill.ACH_Flag__c = false;
                   // ACHflagUpdate = 'false';
                //}

                cllease__Branch_Location__c location;
                if(bill.cllease__Lease_Account__r != null 
                    && bill.cllease__Lease_Account__r.cllease__Branch__r != null
                    && bill.cllease__Lease_Account__r.cllease__Branch__r.cllease__Office_Location__r != null) {
                    location = bill.cllease__Lease_Account__r.cllease__Branch__r.cllease__Office_Location__r;
                }
                String AccName;
                if(acct.Name != null){
                    AccName = acct.Name.replaceAll(',',' ');
                }
                // Creating Bill CSV Line
                BillAndChargeCSVRecord csvRecord = new BillAndChargeCSVRecord();
                 //csvRecord.name                  = ((acct != null && acct.End_User_Account_No__c != null) ? (acct.End_User_Account_No__c + '-' + currentSystemDateStr) : 'NA');
                //csvRecord.accountNumber         = ((acct != null && acct.End_User_Account_No__c != null) ? acct.End_User_Account_No__c : 'NA');
                csvRecord.accountName           = (acct != null ? AccName : 'NA');
                csvRecord.leaseAccountName      = ((contract != null && contract.Name != null) ? contract.Name : 'NA');
             //   csvRecord.leaseDescription      = ((contract != null && contract.Lease_Description__c != null ) ? contract.Lease_Description__c : 'NA');
                csvRecord.remmitanceAddress1    = ((location != null && location.cllease__Address_Line_1__c != null) ? location.cllease__Address_Line_1__c : 'NA' );
                csvRecord.remmitanceCity        = ((location != null && location.cllease__City__c != null) ? location.cllease__City__c : 'NA' );
                csvRecord.remmitanceState       = ((location != null && location.cllease__State__c != null) ? location.cllease__State__c : 'NA' );
                csvRecord.remmitanceZip         = ((location != null && location.cllease__Zip_Code__c != null) ? String.valueOf(location.cllease__Zip_Code__c) : 'NA' );
              //  csvRecord.billingAddress        = ((contract != null && contract.Billing_Street_Address__c != null) ? contract.Billing_Street_Address__c : 'NA' );
              //  csvRecord.billingCity           = ((contract != null && contract.Billing_City__c != null ) ? contract.Billing_City__c : 'NA' );
               // csvRecord.billingState          = ((contract != null && contract.Billing_State__c!= null ) ? contract.Billing_State__c : 'NA' );
               // csvRecord.billingPostal         = ((contract != null && contract.Billing_Zip_Code__c != null ) ? contract.Billing_Zip_Code__c : 'NA' );
                csvRecord.dueId                 = bill.Name;
                csvRecord.dueType               = bill.cllease__Due_Type_Description__c;
                csvRecord.dueDate               = (dueDate != null ? (DateTime.newInstance(dueDate.year(),dueDate.month(),dueDate.day()).format('MM/dd/YYYY')) : 'NA');
                csvRecord.totalDueAmount        = String.valueOf(bill.cllease__Rental_Due_Amount__c!= null ? bill.cllease__Rental_Due_Amount__c: 0);
                csvRecord.taxDueAmount          = String.valueOf(bill.cllease__Tax_Due_Amount__c != null ? bill.cllease__Tax_Due_Amount__c : 0);
                //csvRecord.achFlag               = (bill.ACH_Flag__c == null|| bill.ACH_Flag__c == false) ? 'false' : 'true';
                csvRecord.achFlag               = ACHflagUpdate;
                csvRecord.totalPrincipalAmount  = String.valueOf(bill.cllease__Total_Due_Amount__c != null ? bill.cllease__Total_Due_Amount__c : 0);

                System.debug('****Bill csvRecord.achFlag******'+csvRecord.achFlag);
                csvRecords.add(csvRecord);
                billsToUpdate.add(bill);
            }

            // Looping through Charges
            for(cllease__Charge__c charge : leaseContract.cllease__Charges__r) {
                System.debug('Contract ccharge details: '+leaseContract.cllease__Charges__r);
            
                Date dueDate = charge.cllease__Date__c;
                Account acct;
                if(charge.cllease__Lease_Account__r != null
                    && charge.cllease__Lease_Account__r.cllease__Account__r != null) {
                    acct = charge.cllease__Lease_Account__r.cllease__Account__r;
                }
                String AccName;
                if(acct.Name != null){
                     AccName = acct.Name.replaceAll(',',' ');
                     
                    //AccName=acct.Name.replaceAll('[^a-zA-Z0-9]','\'');
                }
                cllease__Lease_Account__c contract = charge.cllease__Lease_Account__r;

                cllease__Branch_Location__c location;
                if(charge.cllease__Lease_Account__r != null 
                    && charge.cllease__Lease_Account__r.cllease__Branch__r != null
                    && charge.cllease__Lease_Account__r.cllease__Branch__r.cllease__Office_Location__r != null) {
                    location = charge.cllease__Lease_Account__r.cllease__Branch__r.cllease__Office_Location__r;
                }
                //code added to Update the ACH_Flag__c on Charges based on the ACH Setup on Contract
                //ACHflagUpdate = (charge.ACH_Flag__c == null|| charge.ACH_Flag__c == false) ? 'false' : 'true';
                System.debug('*****checkthe ChargeAchFlag on the Charge level******'+ACHflagUpdate);
                //if(leaseContract.ACH_Configured__c){
                    
                    //charge.ACH_Flag__c = true;
                   // ACHflagUpdate  = 'true';
               // }
               // else if(!leaseContract.ACH_Configured__c){
                    
                    //charge.ACH_Flag__c = false;
                   // ACHflagUpdate = 'false';
               // }

                // Creating Charge CSV Line
                BillAndChargeCSVRecord csvRecord = new BillAndChargeCSVRecord();
                //csvRecord.name                  = ((acct != null && acct.End_User_Account_No__c != null )? (acct.End_User_Account_No__c + '-' + currentSystemDateStr) : 'NA');
                //csvRecord.accountNumber         = ((acct != null && acct.End_User_Account_No__c != null) ? acct.End_User_Account_No__c : 'NA');
                csvRecord.accountName           = (acct != null ? AccName : 'NA');
                csvRecord.leaseAccountName      = (contract != null ? contract.Name : 'NA');
                //csvRecord.leaseDescription      = ((contract != null && contract.Lease_Description__c != null) ? contract.Lease_Description__c : 'NA');
                csvRecord.remmitanceAddress1    = ((location != null && location.cllease__Address_Line_1__c != null ) ? location.cllease__Address_Line_1__c : 'NA' );
                csvRecord.remmitanceCity        = ((location != null && location.cllease__City__c != null ) ? location.cllease__City__c : 'NA' );
                csvRecord.remmitanceState       = ((location != null && location.cllease__State__c != null ) ? location.cllease__State__c : 'NA' );
                csvRecord.remmitanceZip         = ((location != null && location.cllease__Zip_Code__c != null ) ? String.valueOf(location.cllease__Zip_Code__c) : 'NA' );
                //csvRecord.billingAddress        = ((contract != null && contract.Billing_Street_Address__c != null) ? contract.Billing_Street_Address__c : 'NA' );
               // csvRecord.billingCity           = ((contract != null && contract.Billing_City__c != null) ? contract.Billing_City__c : 'NA' );
                //csvRecord.billingState          = ((contract != null && contract.Billing_State__c != null) ? contract.Billing_State__c : 'NA' );
                //csvRecord.billingPostal         = ((contract != null && contract.Billing_Zip_Code__c != null) ? contract.Billing_Zip_Code__c : 'NA' );
                csvRecord.dueId                 = charge.Name;
                csvRecord.dueType               = (charge.cllease__Fee_Definition__r != null ? charge.cllease__Fee_Definition__r.Name : 'NA');
                csvRecord.dueDate               = (dueDate != null ? (DateTime.newInstance(dueDate.year(),dueDate.month(),dueDate.day()).format('MM/dd/YYYY')) : 'NA');
                csvRecord.totalDueAmount        = String.valueOf(charge.cllease__Principal_Due__c!= null ? charge.cllease__Principal_Due__c: 0);
                csvRecord.taxDueAmount          = String.valueOf(charge.cllease__Tax_Due__c != null ? charge.cllease__Tax_Due__c : 0);
                //csvRecord.achFlag               = (charge.ACH_Flag__c == null|| charge.ACH_Flag__c == false) ? 'false' : 'true';
                csvRecord.achFlag               = ACHflagUpdate;
                csvRecord.totalPrincipalAmount  = String.valueOf(charge.cllease__Total_Due_Amount__c != null ? charge.cllease__Total_Due_Amount__c : 0);
                System.debug('****charge csvRecord.achFlag******'+csvRecord.achFlag);
                csvRecords.add(csvRecord);
                chargesToUpdate.add(charge);
            }

        }
    
        //Adding csv headers data to create csv file.
         String header = getABillAndChargeCSVFileHeader();
        // 2. CSV Records: Extracting Avalara Records to send request
        String billAndChargeCSVString = '';
        for(BillAndChargeCSVRecord csvRecord : csvRecords) {
            billAndChargeCSVString += csvRecord.getBillAndChargeCSVRecord();
        }
        // Returning the Blob content for csv file creation.
        return billAndChargeCSVString;
    }

    public static List<cllease__Lease_Account__c> getRecords(Set<Id> contractIds) {
    
        // Querying the Bills and Charges for Specified Contracts
        List<cllease__Lease_Account__c> contracts 
                    = [SELECT Id, Name,
                            (SELECT Id, Name,
                                cllease__Tax_Due_Amount__c,
                                cllease__Total_Due_Amount__c,
                                cllease__Rental_Due_Amount__c,
                                cllease__Due_Date__c,
                                //invoice_report__c, 
                                cllease__Lease_Account__r.Name,
                                cllease__Account__r.Name,
                                cllease__Account__r.AccountNumber,
                                //cllease__Lease_Account__r.Billing_Street_Address__c,
                                //cllease__Lease_Account__r.Billing_City__c,
                               //cllease__Lease_Account__r.Billing_State__c,
                               // cllease__Lease_Account__r.Billing_Zip_Code__c,
                                cllease__Lease_Account__r.cllease__Branch__r.cllease__Office_Location__r.cllease__Address_Line_1__c, 
                                cllease__Lease_Account__r.cllease__Branch__r.cllease__Office_Location__r.cllease__State__c,
                                cllease__Lease_Account__r.cllease__Branch__r.cllease__Office_Location__r.cllease__Zip_Code__c,
                                cllease__Lease_Account__r.cllease__Branch__r.cllease__Office_Location__r.cllease__City__c,
                                //cllease__Lease_Account__r.Lease_Description__c,
                                cllease__Due_Type_Description__c
                            FROM cllease__Dues_Details__r 
                            WHERE cllease__Payment_Satisfied__c = false),
                                //AND invoice_report__c = null)
                            (SELECT Id, Name,
                                cllease__Tax_Due__c,
                                cllease__Total_Due_Amount__c,
                                cllease__Principal_Due__c,
                                cllease__Date__c,
                                //invoice_report__c,
                                cllease__Lease_Account__r.Name,
                                cllease__Lease_Account__r.cllease__Account__r.Name,
                                cllease__Lease_Account__r.cllease__Account__r.AccountNumber,
                                //cllease__Lease_Account__r.Billing_Street_Address__c,
                                //cllease__Lease_Account__r.Billing_City__c,
                               // cllease__Lease_Account__r.Billing_State__c,
                                //cllease__Lease_Account__r.Billing_Zip_Code__c,
                                cllease__Lease_Account__r.cllease__Branch__r.cllease__Office_Location__r.cllease__Address_Line_1__c, 
                                cllease__Lease_Account__r.cllease__Branch__r.cllease__Office_Location__r.cllease__State__c,
                                cllease__Lease_Account__r.cllease__Branch__r.cllease__Office_Location__r.cllease__Zip_Code__c,
                                cllease__Lease_Account__r.cllease__Branch__r.cllease__Office_Location__r.cllease__City__c,
                                //cllease__Lease_Account__r.Lease_Description__c,
                                cllease__Fee_Definition__r.Name
                            FROM cllease__Charges__r
                            WHERE cllease__Paid__c = false
                            AND cllease__Waive__c = false)
                                //AND invoice_report__c = null)
                        FROM cllease__Lease_Account__c
                        WHERE cllease__Active_Flag__c = true 
                            AND Id = :contractIds ];

        return contracts;
    }

    public class BillAndChargeCSVRecord {
        public String   name;
        public String   accountNumber;
        public String   accountName;
        public String   leaseAccountName;
        public String   leaseDescription;
        public String   remmitanceAddress1;
        public String   remmitanceCity;
        public String   remmitanceState;
        public String   remmitanceZip;
        public String   billingAddress;
        public String   billingCity;
        public String   billingState;
        public String   billingPostal;
        public String   dueId;
        public String   dueType;
        public String   dueDate;
        public String   totalPrincipalAmount;
        public String   totalDueAmount;
        public String   taxDueAmount;
        public String   achFlag;

        public String getBillAndChargeCSVRecord() {
            return name +','+ accountNumber +','+ accountName +','+ leaseAccountName +','+ leaseDescription +','+ remmitanceAddress1 +','+ 
                remmitanceCity +','+ remmitanceState +','+ remmitanceZip +','+ billingAddress +','+ billingCity +
                ','+ billingState +','+ billingPostal +','+ dueId +','+ dueType +','+ dueDate +','+ totalDueAmount +','+ taxDueAmount +','+ totalPrincipalAmount +','+ achFlag +'\n';
    
        }
    }


    public static String getABillAndChargeCSVFileHeader() {
        return 'Sequence Number,Account Number,Account Name,Lending Account ID,Lease Description,Contract Remittance Address,'+
                'Contract Remittance City,Contract Remittance State,Contract Remittance Zip,Account Billing Address,Account Billing City,'+
                'Account Billing State,Account Billing Postal,Due ID,Due Type,Due Date,Principal Amount,Tax Amount,Total Due Amount,ACH Flag\n';
    }


}