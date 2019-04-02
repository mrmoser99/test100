/*******************************************************************************************************************
*   ICS UTILITY
*
* 
*	Change Log: 
*	8/28/18 - MRM Created
*
*   execute anonomys script - 

Map<ID,String> quickQuoteMap = new Map<ID,String>();
quickQuoteMap.put('a1S0v0000006DMt','Hello');
ICSUtility.sendRequest(quickQuoteMap,false,false) ;

* 
********************************************************************************************************************/
public with sharing class ICSUtility {

   	/********************************************************************************************
   	* Send Request to ICS
   	* 
   	********************************************************************************************/
   	public static boolean sendRequest(Map<ID,String> quickQuoteMap
   		, Boolean cacheOverrideFlag
   		, Boolean forcePartyHitlistFlag
   		, String messageId
   		, String transactionId) { 
     	
     	
     	system.debug('**************** starting sendRequest ***********************');
     	String endPoint;
     	String soapAction;	 	
    	String xmlOutput = '';
    	String applicationRequestId;
		
		System.HttpResponse response;
		genesis__Quick_Quotes__c q;
		 
		try{
			q = new genesis__Quick_Quotes__c();
    		q = [Select id
    			,name  
    			,genesis__State__c
    			,genesis__Last_Name__c
    			,genesis__First_Name__c
    			,genesis__Business_Name__c
    			,genesis__Address_Line_1__c
    			,genesis__City__c
    			,genesis__Postal_Code__c
    			,Dealer__r.Name
    			,Dealer__r.Id
    			,dealer__r.account_number__c
    			,genesis__account__r.account_Number__c
    			,genesis__account__c
    			,Primary_Phone_number__c
    			,Estimated_Financed_Amount__c
    			,genesis__Account__r.Id 
    			,ATS_Reference_Number__c
    			From genesis__Quick_Quotes__c c
    			where id in :quickQuoteMap.keySet()
    		];
    	
			//xmlOutput = ICSUtility.writeXml(q);
			//String messageId = ICVUtility.getMessageId();
   	 		System.HttpRequest request = new System.HttpRequest();
   	 		request.setTimeout(120000);
    		request.setEndpoint(System.Label.ICS_Endpoint); 
    		
    		endPoint = System.label.ICS_Endpoint;
    		soapAction = 'urn:SubmitICSRequest';
    		messageId = q.ats_reference_number__c;
							
    		request.setHeader('Content-Type', 'text/xml'); 
    		request.setHeader('SOAPAction', 'urn:SubmitICSRequest');
    		request.setHeader('Authorization', 'Bearer '+ ICVUtility.getAccessToken());
    		request.setMethod('POST');
    		String myISODateTime = datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''); 
    		 
   			xmlOutput = 	'<?xml version="1.0"?>' +
							'<soapenv:Envelope xmlns:ns="http://schemas.delagelanden.com/service/ics/1.0" ' +
							'xmlns:xsi="http://www.w3.org/2001/XMLSchemainstance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
							'<soapenv:Header>' + 
						
							'<ns1:To xmlns:ns1="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns="http://schemas.xmlsoap.org/ws/2004/08/addressing">' +  
							'https://' + System.Label.ICVDomain + '.dllgroup.com/Submit-ICS</ns1:To>'; 
							
							//code to start running after 5pm on 12/6
							/*
							DateTime myDateTime = DateTime.newInstance(2018, 12, 6, 17, 3, 0);

							if (system.now() > mydateTime){
								xmlOutput += ' <ns1:From xmlns:ns1="http://schemas.xmlsoap.org/ws/2004/08/addressing">' + 
                     						'<ns1:Address>' + System.Label.Environment + '</ns1:Address>' + 
              								'</ns1:From> ';
							}
							*/
							xmlOutput += '<ns1:Action xmlns:ns1="http://schemas.xmlsoap.org/ws/2004/08/addressing">SubmitICSRequest</ns1:Action>' + 
							'<ns1:ReplyTo xmlns:ns1="http://schemas.xmlsoap.org/ws/2004/08/addressing">' + 
								'<ns1:Address>' + System.Label.ICS_Reply_To + '</ns1:Address>' + 
							'</ns1:ReplyTo>' + 
							'<ns1:TransactionID xmlns:ns1="http://schemas.delagelanden.com/model/soapdllheader/1.0" xmlns="http://schemas.delagelanden.com/model/soapdllheader/1.0">' + 
								transactionId + 
							'</ns1:TransactionID>' +
							'<ns1:MessageID xmlns:ns1="http://schemas.xmlsoap.org/ws/2004/08/addressing">' +
							messageId +
							'</ns1:MessageID>' + 
						
							
							'</soapenv:Header>' + 
							'<soapenv:Body>' + 
							'<ns2:SubmitICSRequest xmlns:ns1="http://schemas.delagelanden.com/common" xmlns:ns2="http://schemas.delagelanden.com/service/ics/1.0">' + 
							'<ns2:Authorize>' + 
							'<ns1:User_ID>999999999</ns1:User_ID>' + 
							'<ns1:User_Type>I</ns1:User_Type>' + 
							'<ns1:Responsibility_ID>999999999</ns1:Responsibility_ID>' + 
							'<ns1:Application_ID>999999999</ns1:Application_ID>' + 
							//'<ns1:UserLanguage xmlns="http://schemas.delagelanden.com/common">ENG</ns1:UserLanguage>' + 
							'<ns1:UserCountry>US</ns1:UserCountry><ns1:UserCurrency>USD</ns1:UserCurrency>' +
							'<ns1:Source_System_ID>CLND</ns1:Source_System_ID>' + 
							'<ns1:UserLanguage>ENG</ns1:UserLanguage>' + 
							'</ns2:Authorize>' + 
							'<ns2:SearchDataRequest>' + 
							
							
							'<ns1:Application xmlns:ns1="http://schemas.delagelanden.com/service/ics/1.0" xmlns:ns2="http://schemas.delagelanden.com/common">' + 
							'<ns1:GeneralInfo>' + 
							'<ns1:SourceSystemId>' + System.Label.ICS_Source_System + '</ns1:SourceSystemId>' + 
							'<ns1:ApplicationId>' + q.name  + '</ns1:ApplicationId>' + 
							'<ns1:HyperionBasedEntity>' + System.Label.ICS_Hyperion_Based_Entity + '</ns1:HyperionBasedEntity>' + 
							'<ns1:ActiveInterestRate>0.031</ns1:ActiveInterestRate>' + 
							'<ns1:ApplicationCurrencyCode>USD</ns1:ApplicationCurrencyCode>' + 
							'<ns1:ApplicationEntryDate>' + myISODateTime + '</ns1:ApplicationEntryDate>' + 
							'<ns1:ApplicationTypeCode>' + System.label.ICS_Application_Type_Code + '</ns1:ApplicationTypeCode>' + 
							'<ns1:CacheOverrideFlag>' + cacheOverrideFlag + '</ns1:CacheOverrideFlag>' + 
							'<ns1:CountryCodeOfContract>US</ns1:CountryCodeOfContract>' + 
							'<ns1:ForcePartyHitlistFlag>' + forcePartyHitListFlag + '</ns1:ForcePartyHitlistFlag>' + 
							'<ns1:LGDLookupType>' + System.label.ICS_LGD_Lookup_Type + '</ns1:LGDLookupType>' + 
							'<ns1:LineOfBusiness>' + System.label.ICS_Line_Of_Business + '</ns1:LineOfBusiness>' + 
							'<ns1:FinancialProductTypeCode>' + System.label.ICS_Financial_Product_Type_Code + '</ns1:FinancialProductTypeCode>' + 
							'</ns1:GeneralInfo>' + 
							'<ns1:LeaseApplication>' + 
							'<ns1:FinancedAmount>' + q.Estimated_Financed_Amount__c + '</ns1:FinancedAmount>' + 
							'<ns1:ContractTerm>60</ns1:ContractTerm>' +   
							'<ns1:Assets>' + 
							'<ns1:Asset>' + 
							'<ns1:AssetId>1</ns1:AssetId>' + 
							'<ns1:MasterAssetType>00100</ns1:MasterAssetType>' + 
							'</ns1:Asset>' + 
							'</ns1:Assets>' + 
							'</ns1:LeaseApplication>' + 
							'<ns1:Partner>' + 
							'<ns1:Ids>' + 
							'<ns1:Id>' + 
							'<ns1:SourceSystem>CLND</ns1:SourceSystem>' + 
							'<ns1:IDType>VENDOR_ID</ns1:IDType>' + 
							'<ns1:IDValue>' + q.Dealer__r.account_Number__c + '</ns1:IDValue>' + 
							'</ns1:Id>' + 
							'</ns1:Ids>' + 
							'<ns1:PartnerName>' + q.Dealer__r.Name + '</ns1:PartnerName>' + 
							'<ns1:PartnerType>VENDOR</ns1:PartnerType>' + 
							'</ns1:Partner>' + 
							'<ns1:Program>' + 
							'<ns1:Ids>' + 
							'<ns1:Id>' + 
							'<ns1:SourceSystem>' + System.Label.ICS_Source_System + '</ns1:SourceSystem>' + 
							'<ns1:IDType>PROGRAM_ID</ns1:IDType>' + 
							'<ns1:IDValue>UNKNOWN</ns1:IDValue>' + 
							'</ns1:Id>' + 
							'</ns1:Ids>' + 
							'<ns1:ProgramName>OE_VEND</ns1:ProgramName>' + 
							'</ns1:Program>' + 
							'<ns1:RequestorScoringData>' + 
							'<ns1:CustomerEntity>' + 
							'<ns1:IDs>' + 
							'<ns1:Id>' + 
							'<ns1:SourceSystem>CLND</ns1:SourceSystem>' + 
							'<ns1:IDType>APPLICANT_ID</ns1:IDType>' + 
							'<ns1:IDValue>' + q.name + '</ns1:IDValue>' +  //no account is created yet.
							'</ns1:Id>' + 
							'</ns1:IDs>' + 
							'<ns1:Organization>' + 
							'<ns1:OrganizationName>' + 
							'<ns1:LegalName>' + escapexml(q.genesis__Business_Name__c) + '</ns1:LegalName>' + 
							'</ns1:OrganizationName>' + 
							'</ns1:Organization>' + 
							'<ns1:PhoneNumbers>' + 
							'<ns1:Phone>' + 
							'<ns1:PhoneType>BTEL</ns1:PhoneType>' + 
							'<ns1:PhoneValue>' + q.Primary_Phone_number__c + '</ns1:PhoneValue>' + 
							'</ns1:Phone>' + 
							'</ns1:PhoneNumbers>' + 
							'<ns1:Address>' + 
							'<ns1:Address1>' + 	q.genesis__Address_Line_1__c + '</ns1:Address1>' + 
							'<ns1:City>' + q.genesis__City__c + '</ns1:City>' + 
							'<ns1:ZipPostal>' + q.genesis__Postal_Code__c + '</ns1:ZipPostal>' + 
							'<ns1:Country>US</ns1:Country>' + 
							'<ns1:StateProvince>' + q.genesis__State__c  + '</ns1:StateProvince>' + 
							'</ns1:Address>' + 
							'<ns1:Attributes>' + 
							'<ns1:CountryOfResidence>US</ns1:CountryOfResidence>' + 
							'<ns1:CountryOfRisk>US</ns1:CountryOfRisk>' + 
							'</ns1:Attributes>' + 
							'</ns1:CustomerEntity>' + 
							'</ns1:RequestorScoringData>' +							 
							'<ns1:Fields>' + 
							'<ns2:Field type="numeric" name="CMCL.INTL.GENL.FieldAuditScore">80</ns2:Field>' + 
							'</ns1:Fields>' + 
							'</ns1:Application>' + 
							'</ns2:SearchDataRequest>' + 
							'<ns2:AdditionalAttributes>' + 
            				
            				'<ns2:Attribute>' +
               				'<ns2:AttributeName>MESSAGE-ID</ns2:AttributeName>' +
               				'<ns2:AttributeValue>' + messageId + '</ns2:AttributeValue>' +
            				'</ns2:Attribute>' +
            				
            				'<ns2:Attribute>' +
            				'<ns2:AttributeName>TRANSACTION-ID</ns2:AttributeName>' +
               				'<ns2:AttributeValue>' + transactionId + '</ns2:AttributeValue>' +
            				'</ns2:Attribute>' +
            				
            				'<ns2:Attribute>' +
            				'<ns2:AttributeName>CONSUMER-ENVIRONMENT</ns2:AttributeName>' +
               				'<ns2:AttributeValue>' + System.Label.Environment + '</ns2:AttributeValue>' +
            				'</ns2:Attribute>' +
            				
            				
            				'</ns2:AdditionalAttributes>' + 
							'</ns2:SubmitICSRequest>' + 
							'</soapenv:Body>' + 
							'</soapenv:Envelope>';
							
			system.debug('Sendinig this: ' + xmlOutput);				
    		request.setBody(xmlOutput); 
    		response = new System.Http().send(request); 
    	
   		 	system.debug('Got result :' + response.getBody());
			
			
			List<Group> gList = [Select Id
								,developername
								 From
								 Group g 
								 where type = 'QUEUE' and developerName in ('Credit','Past_Credit','Waiting_for_Credit')
								 ];
			Map<String,ID> gMap = new Map<String,ID>();
			for (Group g:gList)
				gMap.put(g.developername, g.id);	
				
			
			
			if (response.getStatusCode() == 202) {		//202 = OK
				ICS_Log__c log = new ICS_Log__c(xml__c = xmloutput,xml_result__c = response.getBody(),caller__c = 'ICSUtility.sendRequest',status__c = 'OK',ok_return_code__c = '202',soapaction__c = soapAction,end_point__c = endPoint,quick_quote__c = q.id);
				insert log;
				if (q.genesis__account__c != null){
					q.ats_reference_number__c = messageId;
					q.with_account__c = true;
					update q;
				}
				return true;
			}
			else{ 
				ICS_Log__c log = new ICS_Log__c(xml__c = xmloutput,xml_result__c = response.getStatus() + ' - ' + response.getStatusCode(),status__c = string.valueOf(response.getStatusCode()),soapaction__c = soapAction,ok_return_code__c = '202',end_point__c = endPoint,caller__c = 'ICSUtility.sendRequest',quick_quote__c = q.id);
				q.genesis__status__c = 'CREDIT REFERRED';
				update q;
				insert log;
			
				
			}
		}catch (Exception e){
			
			q.genesis__status__c = 'CREDIT REFERRED';
			ICS_Log__c log = new ICS_Log__c(xml__c = xmloutput,soapaction__c = soapAction,ok_return_code__c = '202',end_point__c = endPoint,caller__c = 'ICSUtility.sendRequest',xml_result__c = string.valueOf(e),status__c = 'Callout Failure',quick_quote__c = q.id);
			update q;
			insert log;
			 
		}
		
		return false;
   	}
   	
   	/********************************************************************************************
   	*
   	* Auto Credit Approval
   	* 
   	********************************************************************************************/
   	public static void autoCreditApproval(String applicationRequestId, String commitmentId){
   		
   		map<String,String> requestInfoMap = new Map<String,String>();
		requestInfoMap.put('TransactionID',ICVUtility.getMessageId());
		requestInfoMap.put('SourceCommitmentID',commitmentId);
		requestInfoMap.put('SourceCommitmentType','A');
		String myISODateTime = string.valueOf(json.serialize(datetime.now()));
	    requestInfoMap.put('SourceSystemTimestamp', myISODateTime.substring(1,20));
	    ICVUtility.updateCommitmentFuture(requestInfoMap,applicationRequestId,'Approved','ANB');
   		
   	}
   	
   	/********************************************************************************************
   	*
   	* manualDescion paramters
   	*
   	********************************************************************************************/
   	public class manualDecision {
	 	public String decision;
		public String decisionDate;		
		public String decisionAmount;	
		public String decisionReasonCode;
		public String decisionReasonDesc;
		public String decisionReasonUserName;	
	} 
   	/********************************************************************************************
   	*
   	* updateICSManualICSDecision - this calls ICS with the users choice:
   	*
   	*	approve
   	*	decline
   	*	decline los 
   	* 
   	********************************************************************************************/
   	@future (callout=true) 
   	public static void updateICSManualDecision(String applicationRequestId, Map<String,String>  manualDecisionMap){
   		
   		system.debug('Update ICS Manual Decision');
   		
   		genesis__Quick_Quotes__c q;
   		ICS_Application__c a;
   		System.HttpResponse response;
   		String xmlOutput;
   		String endPoint;
   		String soapAction;
   		String messageId = + ICSUtility.genICSMessageId();
							
   		try{
   			a = [select id 
   					,quick_quote__c
   					,message_id__c
   					,transaction_id__c
   				from ICS_Application__c
   				where id = :applicationRequestId
				];		
		
			q = [Select id
    			,name  
    			,genesis__State__c
    			,genesis__Last_Name__c
    			,genesis__First_Name__c
    			,genesis__Business_Name__c
    			,genesis__Address_Line_1__c
    			,genesis__City__c
    			,genesis__Postal_Code__c
    			,Dealer__r.Name
    			,Dealer__r.Id
    			,dealer__r.account_number__c
    			,genesis__account__r.account_Number__c
    			,genesis__account__c
    			,Primary_Phone_number__c
    			,Estimated_Financed_Amount__c
    			,genesis__Account__r.Id 
    			From genesis__Quick_Quotes__c c
    			where id = :a.quick_quote__c
    		];
    	
   			System.HttpRequest request = new System.HttpRequest();
    		request.setEndpoint(System.Label.ICS_Endpoint); 
    		
    		endPoint = system.label.ics_endpoint;
     		soapAction = 'urn:SubmitICSRequest';	 	
    		request.setHeader('Content-Type', 'text/xml'); 
    		request.setHeader('SOAPAction', 'urn:SubmitICSRequest');
    		request.setHeader('Authorization', 'Bearer '+ ICVUtility.getAccessToken());
    		request.setTimeout(120000);
    		request.setMethod('POST');
    		String myISODateTime = datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''); 
							    		 
   			xmlOutput = 	'<?xml version="1.0"?>' +
							'<soapenv:Envelope xmlns:ns="http://schemas.delagelanden.com/service/ics/1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchemainstance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
							'<soapenv:Header>' +
    						'<ns1:To xmlns:ns1="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns="http://schemas.xmlsoap.org/ws/2004/08/addressing">https://apiacc.dllgroup.com/Submit-ICS</ns1:To>';
    						
    						//code to start running after 5pm on 12/6
							/*
							DateTime myDateTime = DateTime.newInstance(2018, 12, 6, 17, 3, 0);

							if (system.now() > mydateTime){
								xmlOutput += ' <ns1:From xmlns:ns1="http://schemas.xmlsoap.org/ws/2004/08/addressing">' + 
                     						'<ns1:Address>' + System.Label.Environment + '</ns1:Address>' + 
              								'</ns1:From> ';
							}
    						*/
             				xmlOutput += '<ns1:Action xmlns:ns1="http://schemas.xmlsoap.org/ws/2004/08/addressing">SubmitICSRequest</ns1:Action>' +
              				'<ns1:ReplyTo xmlns:ns1="http://schemas.xmlsoap.org/ws/2004/08/addressing">' +
                     		'<ns1:Address>' + System.Label.ICS_Reply_To + '</ns1:Address>' +
              				'</ns1:ReplyTo>' +
              				'<ns1:TransactionID xmlns:ns1="http://schemas.delagelanden.com/model/soapdllheader/1.0" xmlns="http://schemas.delagelanden.com/model/soapdllheader/1.0">' + a.transaction_id__c + '</ns1:TransactionID>' +
              				'<ns1:MessageID xmlns:ns1="http://schemas.xmlsoap.org/ws/2004/08/addressing">'  +
              				messageId +
							'</ns1:MessageID>' +
							'</soapenv:Header>' +
							
							
							'<soapenv:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">' +
							'<SubmitICSRequest xmlns="http://schemas.delagelanden.com/service/ics/1.0">' +
							'<Authorize>' +
    							'<User_ID xmlns="http://schemas.delagelanden.com/common">999999999</User_ID>' +
    							'<User_Type xmlns="http://schemas.delagelanden.com/common">I</User_Type>' +
			    				'<Responsibility_ID xmlns="http://schemas.delagelanden.com/common">999999999</Responsibility_ID>' +
				    			'<Application_ID xmlns="http://schemas.delagelanden.com/common">999999999</Application_ID>' +
    							'<UserCountry xmlns="http://schemas.delagelanden.com/common">US</UserCountry>' +
    							'<UserCurrency xmlns="http://schemas.delagelanden.com/common">USD</UserCurrency>' +
   								'<Source_System_ID xmlns="http://schemas.delagelanden.com/common">CLND</Source_System_ID>' +
   								'<UserLanguage xmlns="http://schemas.delagelanden.com/common">ENG</UserLanguage>' +
							'</Authorize>' + 
							
							'<ObtainManualDecisionRequest>' +
							'<Application>' +
								'<SourceSystemId>CLND</SourceSystemId>' +
						    	'<ApplicationId>' + q.name + '</ApplicationId>' +
								'<ActiveInterestRate>0.00</ActiveInterestRate>' +
								'<ApplicationCurrencyCode>USD</ApplicationCurrencyCode>' +
								'<LGDLookupType>GENERIC</LGDLookupType>' +
								'<LineOfBusiness>OT</LineOfBusiness>' +
								'<LineOfBusinessSubCode/>' +
								'<FinancialProductTypeCode>LEASING</FinancialProductTypeCode>' +
								'<PrivateLabel>0</PrivateLabel>' +
								'<LeaseApplication>' +
									'<FinancedAmount>' + q.Estimated_Financed_Amount__c + '</FinancedAmount>' +
									'<Assets>' +
										'<Asset>' +
											'<AssetId>1</AssetId>' +
											'<MasterAssetType>00100</MasterAssetType>' +
											'</Asset>' +
									'</Assets>' +
								'</LeaseApplication>' +
								'<ApplicationExposure>' +
									'<DLLContractAmount>' + q.Estimated_Financed_Amount__c + '</DLLContractAmount>' +
								'</ApplicationExposure>' +
								'<ManualDecision>' +
								'<ManualDecision>' + manualDecisionMap.get('decision') + '</ManualDecision>' +
								'<ManualDecisionDate>' + manualDecisionMap.get('decisionDate').replace('"','') + '</ManualDecisionDate>' +
								'<ManualApproveLimit>' + manualDecisionMap.get('decisionAmount') + '</ManualApproveLimit>' +
								'<ManualDecisionReasonCode>' + manualDecisionMap.get('decisionReasonCode') + '</ManualDecisionReasonCode>' +
								'<ManualDecisionReasonDesc>' + manualDecisionMap.get('decisionReasonDesc') + '</ManualDecisionReasonDesc>' +
								'<ManualDecisionReasonUsername>' + manualDecisionMap.get('decisionReasonUserName') + '</ManualDecisionReasonUsername>' +
								'</ManualDecision>' +
								'<RequestorDecisionData>' +
								'<CustomerEntity>' +
								'<Attributes>' +
								'<CountryOfResidence>US</CountryOfResidence>' +
								'<CountryOfRisk>US</CountryOfRisk>' +
								'<LegalEntitySize>S</LegalEntitySize>' +
								'</Attributes>' +
								'<Exposure>' +
								'<AmountApprovedDLL>' + q.Estimated_Financed_Amount__c + '</AmountApprovedDLL>' +
								'</Exposure>' +
								'</CustomerEntity>' +
								'</RequestorDecisionData>' +
								'<Fields>' +
								'<Field name="PDTreatmentOverrideFlag" type="boolean" xmlns="http://schemas.delagelanden.com/common">false</Field>' +
								'</Fields>' +
								'</Application>' +
								'</ObtainManualDecisionRequest>' +
							 
								'<AdditionalAttributes>' +
								
								
								'<Attribute>' +
               						'<AttributeName>MESSAGE-ID</AttributeName>' +
               						'<AttributeValue>' + messageId + '</AttributeValue>' +
            					'</Attribute>' +
            				
								'<Attribute>' +
            						'<AttributeName>TRANSACTION-ID</AttributeName>' +
               						'<AttributeValue>' +a.transaction_id__c + '</AttributeValue>' +
            					'</Attribute>' +
            					
            					'<Attribute>' +
            						'<AttributeName>CONSUMER-ENVIRONMENT</AttributeName>' +
               						'<AttributeValue>' + System.Label.Environment + '</AttributeValue>' +
            					'</Attribute>' +
            				
								'</AdditionalAttributes>' +
							 
								'</SubmitICSRequest>' + 
							
							'</soapenv:Body>' + 
							'</soapenv:Envelope>';
							
			system.debug('Sending this: ' + xmlOutput);				
    		request.setBody(xmlOutput); 
    		response = new System.Http().send(request); 
    	
   		 	system.debug('Got result :' + response.getBody());
   		 	
   		 	if (response.getStatusCode() == 202) {	
   		 		ICS_Log__c log = new ICS_Log__c(xml__c = xmloutput,end_point__c = endPoint,soapaction__c = soapAction,ok_return_code__c = '202',caller__c = 'updateICSManualDescion',xml_result__c = string.valueOf(response),status__c = 'OK',quick_quote__c = q.id);
				insert log;
   		 	}
   		 	else {
   		 		ICS_Log__c log = new ICS_Log__c(xml__c = xmloutput,end_point__c = endPoint,soapaction__c = soapAction,ok_return_code__c = '202',caller__c = 'updateICSManualDescion',xml_result__c = string.valueOf(response),status__c = 'Failed',quick_quote__c = q.id);
				insert log;
   		 	}
   		}
   		catch (exception e){
   			ICS_Log__c log = new ICS_Log__c(xml__c = xmloutput,end_point__c = endPoint,soapaction__c = soapAction,ok_return_code__c = '202',caller__c = 'updateICSManualDescion',xml_result__c = string.valueOf(response),status__c = 'Error',quick_quote__c = q.id);
			insert log;
   		}	
   	}
   	
   	/********************************************************************************************
   	*
   	* Manual Credit Approval
   	* 
   	********************************************************************************************/
   	public static void manualCreditApproval(String applicationRequestId){
   		
   		ICS_Application__c a = [select id
   								,quick_quote__c
   								,quick_quote__r.name
   								,score_decision__c
   								,system_decision__c
   								,transaction_id__c
   								from ICS_Application__c
   								where id = :applicationRequestId
   								];
   								
   		map<String,String> requestInfoMap = new Map<String,String>();
		requestInfoMap.put('TransactionID',ICVUtility.getMessageId());
		requestInfoMap.put('SourceCommitmentID',a.quick_quote__r.name);
		requestInfoMap.put('SourceCommitmentType','A');
		String myISODateTime = string.valueOf(json.serialize(datetime.now()));
	    requestInfoMap.put('SourceSystemTimestamp', myISODateTime.substring(1,20));
	    ICVUtility.updateCommitmentFuture(requestInfoMap,a.id,'Approved','ANB');
   	}
   	
   	
   	/********************************************************************************************
   	*
   	* Score  action = 'Score' or 'Re-Score' or 'Re-scoreLOS'
 	* 
   	********************************************************************************************/
   	public static void score(genesis__Quick_Quotes__c Cred_App_obj,String action,String transactionId){
   		
   		  
		List<RecordType> rList = [select id
								  ,developername 
								  from RecordType 
								  where developerName = 'Decision'
								  and sObjectType = 'ICS_Application__c'];
		
		Map<String,String> rMap = new Map<String,String>();
		for (RecordType r:rList)
			rMap.put(r.developername, r.id);
   		 
   		List<Group> gList = [Select Id
								,developername
								 From
								 Group g 
								 where type = 'QUEUE' and developerName in ('Credit','Past_Credit','Waiting_for_Credit')
								 ]; 
		Map<String,ID> gMap = new Map<String,ID>();
		for (Group g:gList)
			gMap.put(g.developername, g.id);
			
		List<ICS_Application__c> aList = [select 
											 id
											,name
										 from ICS_Application__c 
										 where quick_quote__c = :Cred_App_obj.id
										 and (ownerId = :gmap.get('Credit') 
										 or ownerId = :gmap.get('Waiting_for_Credit'))
										 ];	
											  
		for (ICS_Application__c a:aList){
			a.ownerId = gmap.get('Past_Credit');
			a.status__c = 'Past Credit Request'; 
		}
				 					 
		update aList; 
		
		
					
        ICS_Application__c a = new ICS_Application__c();
		a.quick_quote__c = Cred_App_obj.id;
		a.recordtypeid = rmap.get('Decision');
		if (action == 'Re-score' || action == 'Score'){
			a.transaction_id__c = ICSUtility.genTransId();
		}
		else{ //Re-scoredLOS
			a.transaction_id__c = transactionId;
		}
			 
		a.message_id__c = ICSUtility.genICSMessageId();
		a.status__c = 'Waiting for Credit';
		a.ownerid = gMap.get('Waiting_for_Credit');
		a.manual_approval_limit__c = decimal.valueOf(Cred_App_obj.estimated_financed_amount__c);
		if (Cred_App_obj.genesis__account__c != null){
			Cred_App_obj.with_account__c = true;
		}
		Cred_App_obj.ATS_Reference_Number__c = a.message_Id__c;
		insert a;  
        
        Cred_App_obj.genesis__Status__c = 'CREDIT SUBMITTED';
        update Cred_App_obj;
            
            
        if (!Test.IsRunningTest()){    
        	ICVAsyncCreditApproval job = new ICVAsyncCreditApproval(a.id,a.message_id__c,action);
        	System.enqueueJob(job);   
        }
   	}
   	
   	/********************************************************************************************
   	*
   	* acceptLOS
   	*
   	*  need to call getdatarequest with external id from chosen le.
   	*
   	********************************************************************************************/
    @future (callout=true) 
   	public static void acceptLOS(String quoteId, String applicationId, String leId){
   		System.HttpResponse response;
   		String xmlOutput;
   		String endPoint;
   		String soapAction;
   		ICS_Application__c a; 
   		String messageid = ICSUtility.genICSMessageId();
						
   		try {
   			 
   			a = [select id
   				,transaction_id__c
   				,quick_quote__c
   				,message_id__c
   				,quick_quote__r.name
   				from ICS_Application__c
   				where id = :applicationId
   				];
   			
   			List<ICS_External_Id__c> eList = [select type__c
   											  ,value__c
   											  from ICS_External_Id__c
   											  where ICS_External_Legal_Entity__c = :leid
   											  ];
   											  
   		   	System.HttpRequest request = new System.HttpRequest();
    		request.setEndpoint(System.Label.ICS_Endpoint); 
    		
    		request.setHeader('Content-Type', 'text/xml'); 
    		request.setHeader('SOAPAction', 'urn:SubmitICSRequest');
    		soapAction = 'urn:SubmitICSRequest';
    		request.setHeader('Authorization', 'Bearer '+ ICVUtility.getAccessToken());
    		request.setMethod('POST');
    		request.setTimeout(120000);
    		String myISODateTime = datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''); 
			endPoint = system.label.ics_endpoint;		    		 
   			xmlOutput = 	'<?xml version="1.0"?>' +
							'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ics="http://schemas.delagelanden.com/service/ics/1.0" xmlns:cmn="http://schemas.delagelanden.com/common">' +
							'<soapenv:Header>' +
							'<h:ServiceID Version="1.0" xmlns:h="http://schemas.delagelanden.com/model/soapdllheader/1.0" xmlns="http://schemas.delagelanden.com/model/soapdllheader/1.0">SubmitICSRequest</h:ServiceID>' +
							'<h:TransactionID xmlns:h="http://schemas.delagelanden.com/model/soapdllheader/1.0" xmlns="http://schemas.delagelanden.com/model/soapdllheader/1.0">' + a.transaction_id__c + '</h:TransactionID>' +
							'<h:Action xmlns:h="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns="http://schemas.xmlsoap.org/ws/2004/08/addressing">SubmitICSRequest</h:Action>' +
							'<h:MessageID xmlns:h="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns="http://schemas.xmlsoap.org/ws/2004/08/addressing">' +
							 messageId +
							 '</h:MessageID>' +
							'<h:ReplyTo xmlns:h="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns="http://schemas.xmlsoap.org/ws/2004/08/addressing">' +
								'<Address>' +  System.Label.ICS_Reply_To + '</Address>' +
							'</h:ReplyTo>' +
							'<h:To xmlns:h="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns="http://schemas.xmlsoap.org/ws/2004/08/addressing">' + system.label.ics_endpoint + '</h:To>';
							
								
    						//code to start running after 5pm on 12/6
							/*				
							DateTime myDateTime = DateTime.newInstance(2018, 12, 6, 17, 3, 0);

							if (system.now() > mydateTime){
								xmlOutput += ' <ns1:From xmlns:ns1="http://schemas.xmlsoap.org/ws/2004/08/addressing">' + 
                     						'<ns1:Address>' + System.Label.Environment + '</ns1:Address>' + 
              								'</ns1:From> ';
							}
    						*/
							
							xmlOutput += '</soapenv:Header>' + 	
   			
							'<soapenv:Body>' + 
	
							'<ics:SubmitICSRequest>' +
	
							'<ics:Authorize>' +
    							'<cmn:User_ID xmlns="http://schemas.delagelanden.com/common">999999999</cmn:User_ID>' +
    							'<cmn:User_Type xmlns="http://schemas.delagelanden.com/common">I</cmn:User_Type>' +
			    				'<cmn:Responsibility_ID xmlns="http://schemas.delagelanden.com/common">999999999</cmn:Responsibility_ID>' +
				    			'<cmn:Application_ID xmlns="http://schemas.delagelanden.com/common">999999999</cmn:Application_ID>' +
    							'<cmn:UserCountry xmlns="http://schemas.delagelanden.com/common">US</cmn:UserCountry>' +
    							'<cmn:UserCurrency xmlns="http://schemas.delagelanden.com/common">USD</cmn:UserCurrency>' +
   								'<cmn:Source_System_ID xmlns="http://schemas.delagelanden.com/common">CLND</cmn:Source_System_ID>' +
   								'<cmn:UserLanguage xmlns="http://schemas.delagelanden.com/common">ENG</cmn:UserLanguage>' +
							'</ics:Authorize>' + 
							
							'<ics:GetDataRequest>' + 
								'<ics:SourceSystemId>CLND</ics:SourceSystemId>' +
								'<ics:ApplicationId>' + a.quick_quote__r.name + '</ics:ApplicationId>' +
								'<ics:ExternalLegalEntity>' +
								'<ics:ExternalIds>' +
									'<ics:ExternalId>' +
										'<ics:ExternalIdType>' + elist[0].type__c.trim() + '</ics:ExternalIdType>' +
										'<ics:ExternalIdValue>' + eList[0].value__c.trim() + '</ics:ExternalIdValue>' +
									'</ics:ExternalId>' +
								'</ics:ExternalIds>' +
								'</ics:ExternalLegalEntity>' +
							'</ics:GetDataRequest>' +
	
							'<ics:AdditionalAttributes>' +
								'<ics:Attribute>' +
            						'<ics:AttributeName>TRANSACTION-ID</ics:AttributeName>' +
               						'<ics:AttributeValue>' +a.transaction_id__c + '</ics:AttributeValue>' +
            					'</ics:Attribute>' +
            					'<ics:Attribute>' +
            						'<ics:AttributeName>MESSAGE-ID</ics:AttributeName>' +
               						'<ics:AttributeValue>' +a.message_id__c + '</ics:AttributeValue>' +
            					'</ics:Attribute>' +
            					
            					'<ics:Attribute>' +
            						'<ics:AttributeName>CONSUMER-ENVIRONMENT</ics:AttributeName>' +
               						'<ics:AttributeValue>' + System.Label.Environment + '</ics:AttributeValue>' +
            					'</ics:Attribute>' +
            				
            				
							'</ics:AdditionalAttributes>' +
	
							'</ics:SubmitICSRequest>' +
							'</soapenv:Body>' +
							'</soapenv:Envelope>';
   			
   			
			system.debug('Sending this: ' + xmlOutput);				
    		request.setBody(xmlOutput); 
    		response = new System.Http().send(request); 
    	
   		 	system.debug('Got result :' + response.getBody());
   		 	
   		 	if (response.getStatusCode() == 202) {	
   		 		ICS_Log__c log = new ICS_Log__c(xml__c = xmloutput,caller__c = 'getDataRequest LOS picked',ok_return_code__c = '202',soapaction__c = soapAction,end_point__c = endPoint,xml_result__c = string.valueOf(response),status__c = 'OK',quick_quote__c = a.quick_quote__c);
				
				insert log;
   		 	}
   		 	else {
   		 		ICS_Log__c log = new ICS_Log__c(xml__c = xmloutput,caller__c = 'getDataRequest LOS Picked',ok_return_code__c = '202',soapaction__c = soapAction,end_point__c = endPoint,xml_result__c = string.valueOf(response),status__c = 'Failed',quick_quote__c = a.quick_quote__c);
				insert log;
   		 	}
   		}
   		catch (exception e){
   			ICS_Log__c log = new ICS_Log__c(xml__c = xmloutput,caller__c = 'getDataRequest LOS Picked',ok_return_code__c = '202',soapaction__c = soapAction,end_point__c = endPoint,xml_result__c = string.valueOf(response),status__c = 'Error',quick_quote__c = a.quick_quote__c);
			insert log;
   		}				
   	}
   	/********************************************************************************************
   	*
   	* rejectLOS
   	*
   	*  
   	*
   	********************************************************************************************/
   	@future (callout=true)
   	public static void rejectLOS(String applicationRequestId){
   		System.HttpResponse response;
   		String xmlOutput;
   		String endPoint;
   		String soapAction;
   		ICS_Application__c a;
   	 
   		try {
   			 
   			a = [Select id
    			,quick_quote__r.name  
    			,quick_quote__c
    			,transaction_id__c
    			,message_id__c
    			From ics_application__c
    			where id = :applicationRequestId
    			];
   									
   											  
   		   	System.HttpRequest request = new System.HttpRequest();
    		request.setEndpoint(System.Label.ICS_Endpoint); 
    		
    		request.setHeader('Content-Type', 'text/xml'); 
    		request.setHeader('SOAPAction', 'urn:SubmitICSRequest');
    		soapAction = 'urn:SubmitICSRequest';
    		request.setHeader('Authorization', 'Bearer '+ ICVUtility.getAccessToken());
    		request.setMethod('POST');
    		request.setTimeout(120000);
    		String myISODateTime = datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''); 
			endPoint = system.label.ics_endpoint;		    		 
   			xmlOutput = 	'<?xml version="1.0"?>' +
							'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ics="http://schemas.delagelanden.com/service/ics/1.0" xmlns:cmn="http://schemas.delagelanden.com/common">' +
							'<soapenv:Header>' +
							'<h:ServiceID Version="1.0" xmlns:h="http://schemas.delagelanden.com/model/soapdllheader/1.0" xmlns="http://schemas.delagelanden.com/model/soapdllheader/1.0">SubmitICSRequest</h:ServiceID>' +
							'<h:TransactionID xmlns:h="http://schemas.delagelanden.com/model/soapdllheader/1.0" xmlns="http://schemas.delagelanden.com/model/soapdllheader/1.0">' + a.transaction_Id__c + '</h:TransactionID>' +
							'<h:Action xmlns:h="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns="http://schemas.xmlsoap.org/ws/2004/08/addressing">SubmitICSRequest</h:Action>' +
							'<h:MessageID xmlns:h="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns="http://schemas.xmlsoap.org/ws/2004/08/addressing">' +
							 a.message_Id__c +
							 '</h:MessageID>' +
							'<h:ReplyTo xmlns:h="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns="http://schemas.xmlsoap.org/ws/2004/08/addressing">' +
								'<Address>' +  System.Label.ICS_Reply_To + '</Address>' +
							'</h:ReplyTo>' +
							'<h:To xmlns:h="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns="http://schemas.xmlsoap.org/ws/2004/08/addressing">' + system.label.ics_endpoint + '</h:To>';
							
								
    						//code to start running after 5pm on 12/6
							/*				
							DateTime myDateTime = DateTime.newInstance(2018, 12, 6, 17, 3, 0);

							if (system.now() > mydateTime){
								xmlOutput += ' <ns1:From xmlns:ns1="http://schemas.xmlsoap.org/ws/2004/08/addressing">' + 
                     						'<ns1:Address>' + System.Label.Environment + '</ns1:Address>' + 
              								'</ns1:From> ';
							}
    						*/
							
							xmlOutput += '</soapenv:Header>' + 	
   			
							'<soapenv:Body>' + 
	
							'<ics:SubmitICSRequest>' +
	
							'<ics:Authorize>' +
    							'<cmn:User_ID xmlns="http://schemas.delagelanden.com/common">999999999</cmn:User_ID>' +
    							'<cmn:User_Type xmlns="http://schemas.delagelanden.com/common">I</cmn:User_Type>' +
			    				'<cmn:Responsibility_ID xmlns="http://schemas.delagelanden.com/common">999999999</cmn:Responsibility_ID>' +
				    			'<cmn:Application_ID xmlns="http://schemas.delagelanden.com/common">999999999</cmn:Application_ID>' +
    							'<cmn:UserCountry xmlns="http://schemas.delagelanden.com/common">US</cmn:UserCountry>' +
    							'<cmn:UserCurrency xmlns="http://schemas.delagelanden.com/common">USD</cmn:UserCurrency>' +
   								'<cmn:Source_System_ID xmlns="http://schemas.delagelanden.com/common">CLND</cmn:Source_System_ID>' +
   								'<cmn:UserLanguage xmlns="http://schemas.delagelanden.com/common">ENG</cmn:UserLanguage>' +
							'</ics:Authorize>' + 
							
							'<ics:GetDataRequest>' + 
								'<ics:SourceSystemId>CLND</ics:SourceSystemId>' +
								'<ics:ApplicationId>' + a.quick_quote__r.name + '</ics:ApplicationId>' +
							'</ics:GetDataRequest>' +
	
							'<ics:AdditionalAttributes>' +
								'<ics:Attribute>' +
            						'<ics:AttributeName>TRANSACTION-ID</ics:AttributeName>' +
               						'<ics:AttributeValue>' + a.transaction_Id__c + '</ics:AttributeValue>' +
            					'</ics:Attribute>' +
            					'<ics:Attribute>' +
            						'<ics:AttributeName>MESSAGE-ID</ics:AttributeName>' +
               						'<ics:AttributeValue>' + a.message_Id__c + '</ics:AttributeValue>' +
            					'</ics:Attribute>' +
            					
            					'<ics:Attribute>' +
            						'<ics:AttributeName>CONSUMER-ENVIRONMENT</ics:AttributeName>' +
               						'<ics:AttributeValue>' + System.Label.Environment + '</ics:AttributeValue>' +
            					'</ics:Attribute>' +
            				
            				
							'</ics:AdditionalAttributes>' +
	
							'</ics:SubmitICSRequest>' +
							'</soapenv:Body>' +
							'</soapenv:Envelope>';
   			
   			
			system.debug('Sending this: ' + xmlOutput);				
    		request.setBody(xmlOutput); 
    		response = new System.Http().send(request); 
    	
   		 	system.debug('Got result :' + response.getBody());
   		 	
   		 	if (response.getStatusCode() == 202) {	
   		 		ICS_Log__c log = new ICS_Log__c(xml__c = xmloutput,caller__c = 'rejectLOS',ok_return_code__c = '202',soapaction__c = soapAction,end_point__c = endPoint,xml_result__c = string.valueOf(response),status__c = 'OK',quick_quote__c = a.quick_quote__c );
				
				insert log;
   		 	}
   		 	else {
   		 		ICS_Log__c log = new ICS_Log__c(xml__c = xmloutput,caller__c = 'rejectLOS',ok_return_code__c = '202',soapaction__c = soapAction,end_point__c = endPoint,xml_result__c = string.valueOf(response),status__c = 'Failed',quick_quote__c = a.quick_quote__c);
				insert log;
   		 	}
   		}
   		catch (exception e){
   			ICS_Log__c log = new ICS_Log__c(xml__c = xmloutput,caller__c = 'rejectLOS',ok_return_code__c = '202',soapaction__c = soapAction,end_point__c = endPoint,xml_result__c = string.valueOf(response),status__c = 'Error',quick_quote__c = a.quick_quote__c );
			insert log;
   		}				
   	}
   	
   	
   	/********************************************************************************************
   	*
   	* GENERATE TRANSACTION ID
   	*
   	********************************************************************************************/
  
   	public static String genTransId(){
   		
   		return 'CLND-' + system.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
   		
   	}
   	
   	/********************************************************************************************
   	*
   	* GENERATE ICS MessageId
   	* ICSUtility.getICSMessageId()
   	********************************************************************************************/
  
   	public static String genICSMessageId(){ 
   		
   		return 'CLND-MSG' + system.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
   		
   	}
   	
   	    /* workaround callouts for test class */
    
     /*************************************************************************************************
    * 
    * ICV Replace Special Characters  
	*	
    *************************************************************************************************/
   
    public static String escapeXML(String inbound){
    
    	String result; 
    	
    	result = inbound.replaceAll('>','&gt;');
    	result = result.replaceAll('<','&lt;');
    	result = result.replaceAll('&','&amp;');
    	result = result.replaceAll('"','&quot;');
     	result = result.replace('\'','&apos;');
		 
		return result;
    }
 
}