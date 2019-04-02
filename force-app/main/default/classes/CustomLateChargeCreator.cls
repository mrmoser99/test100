/**
 * Following helper class helps in late charges creation
 **/
public class CustomLateChargeCreator {
    private Date dateOfCharge;
    private Map<Id, cllease__Lease_Account_Due_Details__c> lstDuesToUpdate;
    private Map<Id, List<clcommon__Fee_Definition__c>> feeSetToFee; 
    private map<String, Id> txnSubType = new map<String,Id>();
    private List<cllease__Charge__c> chargesToCommit;
    private Map<Id, cllease__Cash_Account_Balance__c> cashBalancesToUpdate;
    
    // Every child object will have contract ID,
    // For easy accessing Lease Accounts with ID, needs of Map <Contract ID, ContractObject>
    private Map<Id, cllease__Lease_Account__c> leaseContractsMap;
    private Map<Id, Map<Id, cllease__Expense_Fees__c>> feeContractFeeMap;

    
   
    public CustomLateChargeCreator(Set<Id> contractIds, Date dateOfCharge) {
        //super(new Set<String>{ 'LATE FEES' });
        this.dateOfCharge 	 	= (dateOfCharge != null ? dateOfCharge : cllease.SystemDateUtil.getCurrentSystemDate());
        lstDuesToUpdate 		  = new Map<Id, cllease__Lease_Account_Due_Details__c>();
        chargesToCommit 		  = new List<cllease__Charge__c>();
        cashBalancesToUpdate 	= new Map<Id, cllease__Cash_Account_Balance__c>();
        leaseContractsMap    	= new Map<Id, cllease__Lease_Account__c>(); 

        // Transaction Sub type pull
        for (cllease__Transaction_Sub_Type__c ts : [SELECT Id, Name FROM cllease__Transaction_Sub_Type__c LIMIT 1000]) {
            txnSubType.put(ts.Name, ts.Id);
        }

        Set<Id> feeSets = new Set<Id>();
        
        List<cllease__Lease_Account__c> leaseContracts =  getRecords(contractIds); 

        for (cllease__Lease_Account__c leaseContract : leaseContracts) {
            leaseContractsMap.put(leaseContract.Id, leaseContract);
            feeSets.add(leaseContract.cllease__Fee_Set1__c);            
        }

        feeContractFeeMap 	= getcontractIdtofeeDefIdToContractFeeConfigMapMap(leaseContractsMap.keySet(), null);
        feeSetToFee 		= cllease.LeaseFeeUtil.getFeesInFeeSets(new List<Id>(feeSets), new Set<String>{'LATE FEES'});
               
    }

    public void chargeLeases() {
        try {
              // Creating Charges for all contracts
              for (cllease__Lease_Account__c l : leaseContractsMap.values()) {
                  if (isChargeApplicable(l)) {
                      List<cllease__Charge__c> charges = doCreateCharge(l);
                      chargesToCommit.addAll(charges);
           			  // skipping multi currency check updates here
                  }
              }
              updateCashBalanaces();
              // Update to DB
              commitToDB();
          } catch(Exception e) {
                system.debug(LoggingLevel.ERROR, 'Charge Creator- ChargeLeases() Exception:' + e.getMessage()+' Line:'+e.getLineNumber()+' StackTrace:'+e.getStackTraceString());
                //LogUtil.INSTANCE.log(e, 'Charge Creator- ChargeLeases() Exception:');
          }
    }

    /**
     * Following private method helps in getting All Lease Contracts for specified ContractIds
     **/
    private List<cllease__Lease_Account__c> getRecords(Set<Id> contractIds) {
        List<String> balanceTypes = new List<String> {cllease.LendingConstants.LEASE_CASHBAL_FEES, cllease.LendingConstants.CASH_ACC_BAL_TYPE_TAX};
        String BILL_STATUS_TAX_PROCESSED = 'Tax Calculated';
        List<cllease__Lease_Account__c> records = [SELECT Id,
                                                 Name,
                                                 cllease__Grace_Period_for_Repayments__c,
                                                 cllease__Lease_Product_Name__r.cllease__Grace_Period_Duration__c,
                                                 cllease__Lease_Product_Name__r.cllease__Minimum_Amount_Due__c,
                                                 cllease__Lease_Product_Name__r.cllease__Minimum_Amount_Due_Type__c,
                                                 cllease__Branch__r.cllease__Tax_Basis__c,
                                                 cllease__Branch__r.cllease__Tax_Method__c,
                                                 cllease__Branch__r.cllease__Vat_Rate__c,
                                                 cllease__Fee_Set1__c ,
                                                 AutoCaluclate_Late_Charge_Grace_Days__c,
                                                 (SELECT Id, Name, 
                                                         cllease__Late_Charge_Applied__c,
                                                         cllease__Due_Date__c,
                                                         cllease__Tolerance__c,
                                                         cllease__Transaction_Date__c,
                                                         cllease__Total_Paid_Amount__c,
                                                         cllease__Rental_Due_Amount__c,
                                                         cllease__Total_Due_Amount__c
                                                    FROM cllease__Dues_Details__r
                                                   WHERE cllease__Payment_Satisfied__c = false
                                                     AND cllease__Late_Charge_Applied__c = false
                                                     AND cllease__Status__c = :BILL_STATUS_TAX_PROCESSED),
                                                 (SELECT Id, Name, cllease__Posted_Amount__c,
                                                         cllease__Closing_Balance_Amount__c,
                                                         cllease__Paid_Amount__c,
                                                         cllease__Contract__c,
                                                         cllease__Balance_Type__c,
                                                         cllease__Opening_Balance_Amount__c,
                                                         cllease__Adjusted_Positive_Amount__c,
                                                         cllease__Adjusted_Negative_Amount__c,
                                                         cllease__Waived_Amount__c
                                                    FROM cllease__Cash_Account_Balances__r
                                                   WHERE cllease__Balance_Type__c IN :balanceTypes)
                                              FROM  cllease__Lease_Account__c
                                           WHERE Id IN :contractIds];

        return records;
    }

    /**
     * Following method helps in idenfiying the contract is eligible for Charges generation 
     **/
    public Boolean isChargeApplicable(cllease__Lease_Account__c leaseAccount) {
        List<cllease__Lease_Account_Due_Details__c> dues = leaseAccount.cllease__Dues_Details__r;

        for (cllease__Lease_Account_Due_Details__c due : dues) {
            if (isChargeApplicableOnDue(leaseAccount, due)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Following method is helper method for  isChargeApplicable(...)
     **/
    private Boolean isChargeApplicableOnDue(cllease__Lease_Account__c leaseAccount, cllease__Lease_Account_Due_Details__c due) {
        Integer grace = leaseAccount.AutoCaluclate_Late_Charge_Grace_Days__c != null ? leaseAccount.AutoCaluclate_Late_Charge_Grace_Days__c.intValue() : 0;

        Date dueDate = due.cllease__Due_Date__c.addDays(grace);
        Integer diff = dateOfCharge.daysBetween(dueDate);

        // Checking for difference in days 
        if (diff < 0) {
            // Late charge amount should be limit for generating
            if (leaseAccount.cllease__Lease_Product_Name__r.cllease__Minimum_Amount_Due__c != null && leaseAccount.cllease__Lease_Product_Name__r.cllease__Minimum_Amount_Due__c > 0) {
                if (leaseAccount.cllease__Lease_Product_Name__r.cllease__Minimum_Amount_Due_Type__c == cllease.LeaseConstants.LEASE_PROD_MINIMUM_DUE_PERCENT) {
                    if (due.cllease__Total_Paid_Amount__c >= ((due.cllease__Total_Due_Amount__c * leaseAccount.cllease__Lease_Product_Name__r.cllease__Minimum_Amount_Due__c)/100)) {
                        return false;
                    } else {
                        return true;
                    }
                } else if (leaseAccount.cllease__Lease_Product_Name__r.cllease__Minimum_Amount_Due_Type__c == cllease.LeaseConstants.LEASE_PROD_MINIMUM_DUE_FIXED_AMOUNT) {
                    if (due.cllease__Total_Paid_Amount__c >= leaseAccount.cllease__Lease_Product_Name__r.cllease__Minimum_Amount_Due__c) {
                        return false;
                    } else{
                        return true;
                    }
                } else {
                    return true;
                }
            } else {
                return true;
            }
        }

        return false;
    }

    // Update Charge cash balances
    private void updateCashBalanaces() {
        // Looping all charges for updating cash balances
        for(cllease__Charge__c charge : chargesToCommit) {
            Id contractId = charge.cllease__Lease_Account__c;
            if(leaseContractsMap.containsKey(contractId)) {
                System.debug(LoggingLevel.DEBUG, 'Processing contract: '+leaseContractsMap.get(contractId).name);
                for(cllease__Cash_Account_Balance__c cashBalance : leaseContractsMap.get(contractId).cllease__Cash_Account_Balances__r) {
                    // Update Fees and Tax Cash balances records
                    System.debug(LoggingLevel.DEBUG, 'Processing cashBalance: '+cashBalance);
                    if(cashBalance.cllease__Balance_type__c == cllease.LendingConstants.LEASE_CASHBAL_FEES) {
                        // reset Cash balances field to 0 incase of null
                        // update correct values
                        cashBalance.cllease__Posted_Amount__c += charge.cllease__Principal_Due__c;
                        cashBalance.cllease__Closing_Balance_Amount__c += cashBalance.cllease__Posted_Amount__c;
                        // Update cash balances in Map
                        cashBalancesToUpdate.put(cashBalance.Id, cashBalance);
                    }
                }
            }            
        }
    }

    /**
     * Following method Create all charges applicable to Lease Account.
     **/
    private List<cllease__Charge__c> doCreateCharge(cllease__Lease_Account__c leaseAccount) {
        List<cllease__Charge__c> retVal = new List<cllease__Charge__c>();
        List<clcommon__Fee_Definition__c> lateFees = feesetToFee.get(leaseAccount.cllease__Fee_Set1__c);

        // Looping all Bills for Late Charges generation
        if (leaseAccount.cllease__Dues_Details__r != null 
             && !leaseAccount.cllease__Dues_Details__r.isEmpty()
             && lateFees != null) {     
            for (clcommon__Fee_Definition__c lateFee : lateFees) {
                for (cllease__Lease_Account_Due_Details__c due : leaseAccount.cllease__Dues_Details__r) {
                    if (isChargeApplicableOnDue(leaseAccount, due)) {
                        // Creating Late charges for applicable Dues
                        cllease__Charge__c charge = new cllease__Charge__c();
        				        charge.cllease__Lease_Account__c = leaseAccount.Id;
        				        charge.cllease__Charge_Type__c   = 'LATE FEES';
        				        charge.cllease__Date__c          = dateOfCharge;
        				        charge.cllease__GL_Transaction_Flag__c   = true;
        				        charge.cllease__Paid_Amount__c   = 0.0; // at the time of creation the amount paid is 0
        				        charge.cllease__Tax_Due__c       = 0.0;
                        
        				        if (lateFee != null) {
        				            charge.cllease__Fee_Definition__c = lateFee.Id;
        				            charge.cllease__Transaction_Sub_Type__c = txnSubType.get(lateFee.name);
        				            // Updating Contract Fee (Expense_Fee__c) while creating Charge
        				            if(feeContractFeeMap != null && feeContractFeeMap.containsKey(leaseAccount.Id)) {
        				                Map<Id, cllease__Expense_Fees__c> contractFeeMap = feeContractFeeMap.get(leaseAccount.Id);
        				                if(contractFeeMap!=null && contractFeeMap.containsKey(lateFee.Id)) {
        				                    charge.cllease__Expense_Fee__c = contractFeeMap.get(lateFee.Id).Id;
        				                }
        				            }
        				        }

                        charge.cllease__Dues_Details__c = due.Id;
                        if (latefee.clcommon__Calculation_Method__c == 'AMOUNT CALCULATED AS % OF RENT DUE') {
                          /* LD-1555 Late fee shoud be calculated based on rent amount without tax
                          If calculated late fee amount is less than the minimum fee amount from the fee definition then 
                          late fee should be applied. 
                          If calculated amount is greater than max fee amount then max fee amount should be applied.
                          In all the other cases calculated fee amount should be applied.
                          e.g
                          If rent is 5000 and % at fee definition is 10, maximimum amount = 100 and minimum fee amount is 50
                          then calculated fee amount is 500 which is 50(Min) < 500 > 100(Max) then 100 should be applied

                          In another case if rent is 400. 400 * 10% then 40 < 50(Min) < 100(Max) then 50 should be applied.
                          */
                          Decimal minFeeAmt = latefee.clcommon__Minimum_Amount__c == null ? 0:latefee.clcommon__Minimum_Amount__c;
                          Decimal maxFeeAmt = latefee.clcommon__Maximum_Amount__c == null ? 0:latefee.clcommon__Maximum_Amount__c;
                          Decimal outStandingRentAmount = due.cllease__Rental_Due_Amount__c == null ? 0 : due.cllease__Rental_Due_Amount__c;
                          Decimal chargeAmt;
                          if(outStandingRentAmount == 0){
                            continue; 
                          }
                          else{
                            chargeAmt = cllease.ValueUtil.round((lateFee.clcommon__Amount__c / 100) * outStandingRentAmount);
                            charge.cllease__Original_Amount__c = chargeAmt;
                            if(chargeAmt < minFeeAmt){
                              charge.cllease__Original_Amount__c = minFeeAmt;  
                            }
                            else if(chargeAmt > maxFeeAmt){
                              charge.cllease__Original_Amount__c = maxFeeAmt;
                            }
                          }
                        }
                        else if (latefee.clcommon__Calculation_Method__c == 'AMOUNT CALCULATED AS % OF OUTSTANDING BALANCE') {
                            Decimal outStandingAmount = due.cllease__Total_Due_Amount__c == null ? 0 : due.cllease__Total_Due_Amount__c;
                            // LD-713 Skipping the late charge creation incase of bill amount == 0
                            if (outStandingAmount == 0) {
                                continue;
                            }
                            charge.cllease__Original_Amount__c = cllease.ValueUtil.round((lateFee.clcommon__Amount__c / 100) * outStandingAmount);
                        } else if (latefee.clcommon__Calculation_Method__c == 'FIXED') {
                            charge.cllease__Original_Amount__c = lateFee.clcommon__Amount__c;
                        }

                        charge.cllease__Principal_Due__c = charge.cllease__Original_Amount__c;

                        retVal.add(charge);
                        due.cllease__Late_Charge_Applied__c = true;
                        lstDuesToUpdate.put(due.Id, due);
                    }
                }
            }
        }
        return retVal;
    }

   /**
	  * Retrieves and creates Map << FeeDefinition => ContractFee >> per Contract and returns.
	  **/
	 public static Map<Id, Map<Id, cllease__Expense_Fees__c>> getcontractIdtofeeDefIdToContractFeeConfigMapMap(Set<Id> contractIDs, Date txnDate) {

      // Validations
		  if(contractIDs ==null || contractIDs.size() ==0) {
			   return null;
		  }

		  // Validating ContractIds for null values
  		for(Id contractId : contractIDs) {
  			 if(contractID == null) {
  				  contractIDs.remove(contractID);
  			 }
  		}

		  if(contractIDs.size() == 0) {
		  	return null;
		  }

		  // Retrieving all Contract Fees which link to specific contract and creating Map for easy use.
		  // Using Util library to retrieve records to maintain consistency accross code
		  mfiflexUtil.ExecutionContext ec = mfiflexUtil.ExecutionContext.getExecContext();
		  mfiflexUtil.ObjectCache feeConfig = ec.getObject('feeConfig');
		  String nsPrefix = 'cllease__'; // hard coding the namespace with underscore
		  if (feeConfig != null) {
		      ec.deleteObject('feeConfig');
		  }
		  feeConfig = ec.createObject('feeConfig', nsPrefix + 'Expense_Fees__c');
  
		  feeConfig.addFields(  'Id, Name, ' + 
		                      nsPrefix + 'Withhold_Basis__c, ' +
		                      nsPrefix + 'Withhold_Value__c, ' +
		                      nsPrefix + 'Contract__c, ' +
		                      nsPrefix + 'Fee_Definition__c, ' +
		                      nsPrefix + 'Payment_Method__c, ' +
		                      nsPrefix + 'Type__c');
		  feeConfig.addNamedParameter('contractIds', contractIds);
		  feeConfig.setWhereClause(nsPrefix + 'Contract__c in :contractIds');
  
		  // Adding SubQuery only if txnDate is not null which is only required during Processing Passthrough
		  if(txnDate != null) {
		      mfiflexUtil.ObjectCache contractFeePayment = ec.createRelationship(nsPrefix + 'Contract_Fee_Payments__r')
		          .addFields('Id, Name, ' +
		              nsPrefix + 'Pay_To__r.' + nsPrefix + 'Party_Account_Name__c ');
		      
		      contractFeePayment.addNamedParameter('txnDate', txnDate);
		      contractFeePayment.setWhereClause('('+ nsPrefix +'Start_Date__c <= :txnDate AND '+ nsPrefix +'End_Date__c >= :txnDate) '+
		                                        ' OR ('+ nsPrefix +'Start_Date__c = null AND '+ nsPrefix +'End_Date__c = null)');
		      feeConfig.addRelationship(contractFeePayment);
		  }
		  // Running Query
		  feeConfig.executeQuery();
		  // Assigning queried records to Contract Fee List for further processing
		  List<cllease__Expense_Fees__c> contractFees = (List<cllease__Expense_Fees__c>) feeConfig.getRecords();
  
		  Map<Id, Map<Id, cllease__Expense_Fees__c>> feeToPassthroughConfigMap = new Map<Id, Map<Id, cllease__Expense_Fees__c>>();
		  // Creating Map<ContractID, Map<FeeDefinitionID, ContractFee>>
		  if(contractFees.size()==0) {
		  	 return null;
		  }
		  for(cllease__Expense_Fees__c contractFee : contractFees) {
		  	  if(feeToPassthroughConfigMap.containsKey(contractFee.cllease__Contract__c)) {
		  		    Map<Id, cllease__Expense_Fees__c> feeContractFeeMap = feeToPassthroughConfigMap.get(contractFee.cllease__Contract__c);
		  		    if(feeContractFeeMap==null) {
		  			     feeContractFeeMap = new Map<Id, cllease__Expense_Fees__c> {contractFee.cllease__Fee_Definition__c => contractFee};
		  		    } else if(!feeContractFeeMap.containsKey(contractFee.cllease__Fee_Definition__c)){
		  			     feeContractFeeMap.put(contractFee.cllease__Fee_Definition__c, contractFee);
		  		    }
		  		    feeToPassthroughConfigMap.put(contractFee.cllease__Contract__c, feeContractFeeMap);
		  	  } else {
		  		    feeToPassthroughConfigMap.put(contractFee.cllease__Contract__c, 
		  			   new Map<Id, cllease__Expense_Fees__c> {contractFee.cllease__Fee_Definition__c => contractFee});
		  	  }
		  }
		  return feeToPassthroughConfigMap;
	  }

    public void commitToDb() {
        Savepoint sp = Database.setSavepoint();
        try {
            insert chargesToCommit;

            if(cashBalancesToUpdate!=null && cashBalancesToUpdate.size()>0) {
                update cashBalancesToUpdate.values() ;
            }

            update lstDuesToUpdate.values();
            System.debug(LoggingLevel.ERROR, '----lstDuesToUpdate: '+lstDuesToUpdate);
        } catch (Exception e) {
            Database.rollback(sp);System.debug(LoggingLevel.ERROR, 'Exception while processing CustomLateChargeCreator: '+e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Exception StackTrace: '+e.getStackTraceString());
            //insert batch process log for exceptions
            insert new cllease__Batch_Process_Log__c(Name=' CustomLateChargeCreator ', cllease__Date__c = System.today(), 
              cllease__Message__c = 'Error is '+e.getmessage() +' in line number: '+ e.getlinenumber());
        }
        
    }

}