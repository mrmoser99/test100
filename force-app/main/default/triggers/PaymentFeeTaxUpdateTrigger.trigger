trigger PaymentFeeTaxUpdateTrigger on cllease__Fee_Payment__c (after insert) {

	/*
	Savepoint sp = database.setsavepoint();
	try {
		// 1. Collect all FeePaymentIds and do query again to get details with charges & payments
		Map<Id, cllease__Fee_Payment__c> feePaymentIdMap = new Map<Id, cllease__Fee_Payment__c>();
		Set<Id> paymentIds = new Set<Id>();
		for(cllease__Fee_Payment__c feePayment : trigger.new) {
			if(feePayment.cllease__Lease_Payment_Transaction__c != null
				&& feePayment.cllease__Charge__c != null) {
				feePaymentIdMap.put(feePayment.Id, feePayment);
				paymentIds.add(feePayment.cllease__Lease_Payment_Transaction__c);
			}
		}

		if(feePaymentIdMap.size() > 0 && paymentIds.size() > 0) {

			// Querying Transction SubTypes
			Map<String, Id> txnSubTypeMap = new Map<String, Id>();
	        for(cllease__Transaction_Sub_Type__c txnSubType : [SELECT Id, Name FROM cllease__Transaction_Sub_Type__c LIMIT 1000]) {
	            txnSubTypeMap.put(txnSubType.Name, txnSubType.Id);
	        }

	        // Querying All Fee Definition's Transaction Subtypes to deleting Lease Payment  Details
	        List<clcommon__Fee_Definition__c> feeDefs = [SELECT Id, Name From clcommon__Fee_Definition__c];
	        Set<Id> feeTxnSubTypes = new Set<Id>();
			for(clcommon__Fee_Definition__c feeDef : feeDefs) {
				feeTxnSubTypes.add(txnSubTypeMap.get(feeDef.Name));
			}

			// Deleting Lease Payment Detail Lines related to existing fee types for newly created Payments
			List<cllease__Lease_Payment_Detail__c> existingFeeLeasePmtDetails = 
							[SELECT Id, Name
							 FROM cllease__Lease_Payment_Detail__c
							 WHERE cllease__Payment_Transaction__c IN :paymentIds
							 AND cllease__Transaction_Sub_Type__c IN :feeTxnSubTypes];

			if(existingFeeLeasePmtDetails.size() > 0) {
				//delete existingFeeLeasePmtDetails;
			}

	        // Requerying Fee Payments for more details
			List<cllease__Fee_Payment__c> feePaymentsList = [ SELECT Id, Name,
																cllease__Transaction_Amount__c, 
																cllease__Transaction_Date__c,
																cllease__Lease_Payment_Transaction__c,
																cllease__Lease_Payment_Transaction__r.cllease__Contract__c,
																cllease__Charge__c,
																cllease__Charge__r.Name,
																cllease__Charge__r.cllease__Lease_Account__c,
																cllease__Charge__r.cllease__Fee_Due__c,
																cllease__Charge__r.cllease__Tax_Due__c,
																cllease__Charge__r.Fee_Paid__c, 
																cllease__Charge__r.Tax_Paid__c,
																cllease__Charge__r.cllease__Fee_Definition__c,
																cllease__Charge__r.cllease__Fee_Definition__r.Name,
																cllease__Charge__r.cllease__Transaction_Sub_Type__c
															FROM cllease__Fee_Payment__c
															WHERE Id IN :feePaymentIdMap.keySet()];

			// Creating Lease_Payment_Detail__c for all charge related amounts on related to payments.
			List<cllease__Lease_Payment_Detail__c> leasePaymentDetailsToInsert = new List<cllease__Lease_Payment_Detail__c>();
			List<cllease__Charge__c> chargesToUpdate = new List<cllease__Charge__c>();

			for(cllease__Fee_Payment__c feePayment : feePaymentsList) {
				if(feePayment.cllease__Charge__c != null && feePayment.cllease__Lease_Payment_Transaction__c != null) {
					Decimal currentPayment = (feePayment.cllease__Transaction_Amount__c != null ? feePayment.cllease__Transaction_Amount__c : 0);
					Decimal taxAmountSpread = 0, feeAmountSpread = 0;

					System.debug(LoggingLevel.ERROR, '--- feePayment: '+feePayment);
					System.debug(LoggingLevel.ERROR, '--- feePayment.cllease__Charge__r: '+feePayment.cllease__Charge__r);
					// Spreading the Fee Payment's Amount to Charge's Tax and Fee Amount

					// 1. Spreading amount over Fee Amount first
					Decimal feeDue = (feePayment.cllease__Charge__r.cllease__Fee_Due__c !=null ? feePayment.cllease__Charge__r.cllease__Fee_Due__c : 0);
					Decimal remainingFeeAmount = feeDue - feePayment.cllease__Charge__r.Fee_Paid__c;
					if(remainingFeeAmount >= currentPayment) {
						feeAmountSpread = currentPayment;
					} else {
						feeAmountSpread = remainingFeeAmount;
						taxAmountSpread = currentPayment - remainingFeeAmount;
					}
				
					if(feePayment.cllease__Charge__r.cllease__Fee_Definition__c == null) {
						throw new CLSCustomException('No Fee Linked to Charge, Please verify: '+feePayment.cllease__Charge__r.Name);
					}

					String feeTxnSubType = feePayment.cllease__Charge__r.cllease__Fee_Definition__r.Name;
					if(!txnSubTypeMap.containsKey(feeTxnSubType)) {
						throw new CLSCustomException('Transcation SubType Not available: '+feeTxnSubType);
					}

					String feeTaxTxnSubType = feePayment.cllease__Charge__r.cllease__Fee_Definition__r.Name + ' - Tax';
					if(!txnSubTypeMap.containsKey(feeTaxTxnSubType)) {
						throw new CLSCustomException('Transcation SubType Not available: '+feeTaxTxnSubType);
					}

					// Creating Lease Payment Details for Charge's Fee only If TaxAmountSpread > 0
					if(taxAmountSpread > 0) {
						leasePaymentDetailsToInsert.add(
									new cllease__Lease_Payment_Detail__c(
										cllease__Contract__c = feePayment.cllease__Lease_Payment_Transaction__r.cllease__Contract__c,
										cllease__Transaction_Date__c 		= feePayment.cllease__Transaction_Date__c,
										cllease__Transaction_Sub_Type__c 	= txnSubTypeMap.get(feeTaxTxnSubType),
										cllease__Payment_Transaction__c 	= feePayment.cllease__Lease_Payment_Transaction__c,
										cllease__GL_Transaction_Flag__c 	= true,
										cllease__Amount__c 					= taxAmountSpread));
					}

					// Creating Lease Payment Details for Charge's Fee only If feeAmountSpread > 0
					if(feeAmountSpread > 0) {
						leasePaymentDetailsToInsert.add(
									new cllease__Lease_Payment_Detail__c(
										cllease__Contract__c = feePayment.cllease__Lease_Payment_Transaction__r.cllease__Contract__c,
										cllease__Transaction_Date__c 		= feePayment.cllease__Transaction_Date__c,
										cllease__Transaction_Sub_Type__c 	= txnSubTypeMap.get(feeTxnSubType),
										cllease__Payment_Transaction__c 	= feePayment.cllease__Lease_Payment_Transaction__c,
										cllease__GL_Transaction_Flag__c 	= true,
										cllease__Amount__c 					= feeAmountSpread));
					}

					cllease__Charge__c charge = new cllease__Charge__c( Id = feePayment.cllease__Charge__c,
																Current_Fee_Paid__c = feeAmountSpread,
																Current_Tax_Paid__c = taxAmountSpread);
					// updating fee payment's passthrough field as true in case if there is no fee amount
					// To skip the disbursement transction creation during passthrough batch job run.
					if(feeAmountSpread == 0 && taxAmountSpread > 0) {
						charge.cllease__Remarks__c = 'marking charge as passthrough paid as only tax amount remaining';
						charge.cllease__Passthrough_Paid__c = true;
					}

					chargesToUpdate.add(charge);
				}
			}

			// Create new Payment Details only incase of list size > 0
			if(leasePaymentDetailsToInsert.size() > 0) {
				insert leasePaymentDetailsToInsert;
			}

			if(chargesToUpdate.size() > 0) {
				update chargesToUpdate;
			}
		}
	} catch(exception e){           
       	database.rollback(sp);   
       	System.debug(LoggingLevel.ERROR, 'Exception: '+e.getMessage());    
       	System.debug(LoggingLevel.ERROR, 'Exception Stack: '+e.getStackTraceString());      
       	//insert batch process log for exceptions
       	insert new cllease__Batch_Process_Log__c(Name='PaymentFeeTaxUpdateTrigger: ',
        cllease__Date__c=system.today(), cllease__Message__c='Error is '+e.getmessage()
        +' in line number: '+ e.getlinenumber());
    }
    */
}