@isTest
public class TestICSResponse {
    	
     
   			
     static TestMethod void  test1() {
    
    	cllease__lease_account__c l = createContract();
	 	
	 	RecordType r = [SELECT ID 
	 						FROM RecordType 
	 						WHERE DeveloperName = 'Dealer'AND SobjectType = 'Account'
	 						AND IsActive = true limit 1];                                   
       
        Account a = new Account(name='Talentica');
        a.RecordTypeId=r.id;
        insert a;
        
        genesis__Quick_Quotes__c qq = new genesis__Quick_Quotes__c(
        			 Dealer__c=a.id
        			,genesis__Business_Name__c='test business name'
        			,genesis__Address_Line_1__c='85 milford road'
        			,genesis__City__c='Downingtown'
        			,genesis__State__c='PA'
        			,genesis__Postal_Code__c='19335'
        			,Estimated_Financed_Amount__c='10000'
        			,genesis__Status__c='NEW'
    				,ats_reference_number__c = '149dd399e2a24998e967d9569072871d'
    			
    				);
    	insert qq;  
    	
    	Address__c addr = new Address__c(
    						 address_line_1__c=qq.genesis__Address_Line_1__c
	  						,city__c=qq.genesis__City__c
	  						,state__c=qq.genesis__State__c
	  						,zip_code__c=qq.genesis__Postal_Code__c
	  						,account__c = a.id
	  						);
	  	insert addr;		   
    	
    	ICS_Application__c app = new ICS_Application__c(
    		quick_quote__c = qq.id
    		,message_id__c = qq.ats_reference_number__c
    	);
    	
    	insert app;
    	
    	genesis__Applications__c g = new genesis__Applications__c(
    		 genesis__quick_quote__c = qq.id
    	);
    	insert g;
    	
    	g = [select name from genesis__Applications__c where id = :g.id];
    	
    	system.debug('*****G is: ' + g);
    	l.application_number__c = g.name;
    	l.cllease__application_number__c = g.name;
    	l.cllease__account__c = a.id; 
    	update l;
    	
    	system.debug('***** L is: ' + l);
    	
    	ICS_External_Legal_Entity__c le = new ICS_External_Legal_Entity__c(
    		 ics_application_request__c = app.id
    		,agency_id__c = 'US_DNB'
    		,industry_code_value__c = '1234'
    		,industry_code_type__c = 'SIC_1234_US'
    	);
    	insert le;
    	
    	system.debug(l);
    	
    	ics_log__c log = new ics_log__c (quick_quote__c = qq.id, status__c = 'OK');
    	insert log;
	 	
	 	System.Test.startTest();
        
        ICSResponse.input i = new ICSResponse.input();
       
        /*
        Group g0 = new Group(name = 'Credit', developername = 'Credit', type = 'QUEUE');
        insert g0;
        
        Group g1 = new Group(name = 'Past Credit', developername = 'Past_Credit', type = 'QUEUE');
        insert g1;
        
        Group g2 = new Group(name = 'Waiting for Credit', developername = 'Waiting_for_Credit', type = 'QUEUE');
        insert g2;
        */
        
        qq = [select name from genesis__quick_quotes__c where id = :qq.id];
        
        ICSResponse.Input input = new ICSResponse.Input();
        Input.SearchDataResponse = null;
        Input.ObtainManualDecisionResponse = null;
        
        ICSResponse.ObtainDecisionResponse ObtainDecisionResponse = new ICSResponse.ObtainDecisionResponse();
        ICSResponse.Application Application = new ICSResponse.Application();
        Application.ApplicationId = qq.name;
        Application.AppliedEADTreatment = 'EX_ANTE';
        
        ICSResponse.SystemDecision SystemDecision = new ICSResponse.SystemDecision();
        SystemDecision.ScoreDecision = 'AA';
        SystemDecision.SystemDecision = 'AA';
      	SystemDecision.SystemDecisionDate = '2018-11-07T21:18:26.579+01:00';
      	SystemDecision.SystemApprovalLimit = '10000';
      	SystemDecision.PolicyRuleSetCode = 'NewCo Flow';
        
        
        ICSResponse.DecisionReason DecisionReason = new ICSResponse.DecisionReason();
        DecisionReason.ReasonCode = 'A004';
        DecisionReason.ReasonDesc = 'Scorecard Accept';
        
        ICSResponse.DecisionReasons DecisionReasons = new ICSResponse.DecisionReasons();
        DecisionReasons.DecisionReason = new List<ICSResponse.DecisionReason>();
        DecisionReasons.DecisionReason.add(DecisionReason);
        
        Application.SystemDecision = SystemDecision;
        
        
        ICSResponse.MultipleYearELItem MultipleYearELItem = new ICSResponse.MultipleYearELItem();
        MultipleYearELItem.Vintage = '1';
        MultipleyearELItem.Amount = '0.00';
        
        ICSResponse.MultipleYearEADItem MultipleYearEADItem = new ICSResponse.MultipleYearEADItem();
        MultipleYearEADItem.Vintage = '1';
        MultipleYearEADItem.Amount = '0.00';
        
        ICSResponse.MultipleYearLGDItem MultipleYearLGDItem = new ICSResponse.MultipleYearLGDItem();
        MultipleYearLGDItem.Vintage = '1';
        MultipleYearLGDItem.Percentage = '0.00';
        
		ICSResponse.MultipleYearLGD multipleYearLGD = new ICSResponse.MultipleYearLGD();
		MultipleYearLGD.MultipleYearLGDItem = new List<ICSResponse.MultipleYearLGDItem>();
		MultipleYearLGD.MultipleYearLGDItem.add(MultipleYearLGDItem);
		MultipleYearLGD = multipleYearLGD;
				
		ICSResponse.MultipleYearEL multipleYearEL = new ICSResponse.MultipleYearEL();
		MultipleYearEL.MultipleYearELItem = new List<ICSResponse.MultipleYearELItem>();
		MultipleYearEL.MultipleYearELItem.add(MultipleYearELItem);
		MultipleYearEL = multipleYearEL;
		
		ICSResponse.MultipleYearEAD multipleYearEAD = new ICSResponse.MultipleYearEAD();
		MultipleYearEAD.MultipleYearEADItem = new List<ICSResponse.MultipleYearEADItem>();
		MultipleYearEAD.MultipleYearEADItem.add(MultipleYearEADItem);
		MultipleYearEAD = multipleYearEAD;
		
    	ICSResponse.AdverseReason AdverseReason = new ICSResponse.AdverseReason();
    	AdverseReason.ScoreDeviation = '-150';
    	AdverseReason.AdverseReasonCode = 'AR37';
    	AdverseReason.AdverseReasonDesc = 'Behavioral Components';
    	
    	ICSResponse.AdverseReasons AdverseReasons = new ICSResponse.AdverseReasons();
    	AdverseReasons.AdverseReason = new List<ICSResponse.AdverseReason>();
    	AdverseReasons.AdverseReason.add(AdverseReason);
    	
    	ICSResponse.ScoreCardResult ScorecardResult = new ICSResponse.ScorecardResult();
   		ScorecardResult.ScorecardName = 'DBPUS2_0';
   		ScorecardResult.ScorecardForPDFlag = 'true';
   		ScorecardResult.ScorecardScore = '1316';
   		ScorecardResult.AdverseReasons = AdverseReasons;
   		
   		ICSResponse.ScorecardResults ScorecardResults = new ICSResponse.ScorecardResults();
   		ScorecardResults.ScorecardResult = new List<ICSResponse.ScorecardResult>();
   		ScorecardResults.ScorecardResult.add(ScorecardResult);
   		
   		ICSResponse.ScoreResult ScoreResult = new ICSResponse.ScoreResult();
   		ScoreResult.ScoreDate = '2018-11-07T21:18:25.318+01:00';
   		ScoreResult.ScorecardResults = ScorecardResults;
   		
   		Application.ScoreResult = ScoreResult;
   		
   		ICSResponse.Customer Customer = new ICSResponse.Customer();
   		
   		ICSResponse.DecisionData DecisionData = new ICSResponse.DecisionData();
   		 
   		ICSResponse.Field Field = new ICSResponse.Field();
   		Field.Name = 'DRVD.CMCL.EXTL.ORSK.KnowYourCustomerCode'; 
   		Field.Type = 'int';
   		Field.Value = 'Credit';
   		
   		ICSResponse.Fields Fields = new ICSREsponse.Fields();
   		Fields.Field = new List<ICSResponse.Field>();
   		
   		Fields.field.add(Field); 
   		DecisionData.Fields = Fields;
   		
   		Customer.DecisionData = DecisionData;
   		
   		ICSResponse.Address Address = new ICSResponse.Address();
   		Address.AddressLine = '85 Milford Road';
   		Address.City = 'Downingtown';
   		Address.StateprovinceCode = 'PA';
   		Address.PostalCode = '19335';
   		Address.CountryCode = 'US';
   		
   		ICSResponse.PhoneRecord PhoneRecord = new ICSResponse.PhoneRecord();
   		PhoneRecord.PhoneNumber = '8002221111';
   		PhoneRecord.PhoneType = 'OTHER';
   	
   		ICSResponse.PhoneRecords PhoneRecords = new ICSResponse.PhoneRecords();
   		PhoneRecords.PhoneRecord = new List<ICSResponse.PhoneRecord>(); 
   		PhoneRecords.PhoneRecord.add(PhoneRecord);
   		
   		ICSResponse.AgencyProduct AgencyProduct = new ICSResponse.AgencyProduct();
   		AgencyProduct.AgencyId = 'US_DNB';
   		AgencyProduct.AgencyProductId = 'TOOLKIT';
   		
   		ICSResponse.LocalIndustryCode LocalIndustryCode = new ICSResponse.LocalIndustryCode();
   		LocalIndustryCode.IndustryCodeType = 'SIC_1987_US';
   		LocalIndustryCode.IndustryCodeValue = '8748';
   		
   		ICSResponse.Organization Organization = new ICSResponse.Organization();
   		Organization.LegalName = 'Test Company';
   		Organization.EstablishedYear = '2019';
   		Organization.LocalIndustryCode = LocalIndustryCode;
   		
   		ICSResponse.ExternalId ExternalId = new ICSResponse.ExternalId();
   		ExternalId.ExternalIdType = 'DUNS';
   		ExternalId.ExternalIdvalue = '042903262';
   	
    	ICSResponse.ExternalIds ExternalIds = new ICSResponse.ExternalIds();
   		ExternalIds.ExternalId = new List<ICSResponse.ExternalId>();
   		ExternalIds.ExternalId.add(ExternalId);	
   	
   		ICSResponse.ExternalLegalEntity ExternalLegalEntity = new ICSResponse.ExternalLegalEntity();
   		ExternalLegalEntity.ExternalIds = ExternalIds;
   		ExternalLegalEntity.AgencyProduct = AgencyProduct; 
   		ExternalLegalEntity.Organization = Organization;
   		ExternalLegalEntity.Address = Address;
   		ExternalLegalEntity.PhoneRecords = PhoneRecords; 
   		ExternalLegalEntity.Fields = Fields;
   		
   		ICSResponse.ExternalLegalEntities ExternalLegalEntities = new ICSResponse.ExternalLegalEntities();
   		ExternalLegalEntities.ExternalLegalEntity = new List<ICSResponse.ExternalLegalEntity>();
   		ExternalLegalEntities.ExternalLegalEntity.add(ExternalLegalEntity);
   		
		Customer.ExternalLegalEntities = ExternalLegalEntities;
		
		ICSResponse.InternalLegalEntity InternalLegalEntity = new ICSResponse.InternalLegalEntity();
		InternalLegalEntity.Address = Address;
		
		ICSResponse.ApplicableRating ApplicableRating = new ICSResponse.ApplicableRating();
		ApplicableRating.CherryPickingFlag = 'false';
		ApplicableRating.PDLookupType = 'SCRD';
		ApplicableRating.PDPercentage = '0.0182699';
		ApplicableRating.PDRatingDate = '2018-11-07T12:00:00Z';
		ApplicableRating.PDRatingModel = 'DBPUS2_0';
		ApplicableRating.PDRatingScore = '1316';
		ApplicableRating.PDVintage = '1';
		ApplicableRating.PDPenaltyFlag = 'true';
		ApplicableRating.RabobankMasterscaleRating = 'R14';
		
		
		
		ICSResponse.MultiplePD MultiplePD = new ICSResponse.MultiplePD();
		MultiplePD.MultipleYearPDItem = new List<ICSResponse.MultipleYearPDItem>();
		ICSResponse.MultipleYearPDItem MultipleYearPDItem = new ICSResponse.MultipleYearPDItem();
		MultipleYearPDItem.Percentage = '0.0182688';
		MultipleYearPDItem.Vintage = '1';
	 	
		MultiplePD.MultipleYearPDItem.add(MultipleYearPDItem);
		
		ApplicableRating.MultiplePD = MultiplePD;
		
		InternalLegalEntity.ApplicableRating = ApplicableRating;
		InternalLegalEntity.CREStatus = 'NOT REQUIRED';
		 
		ICSResponse.Default_x Default_x = new ICSREsponse.Default_x();
		Default_x.CurrentlyInDefaultIndicator = 'false';
		
		InternalLegalEntity.Default_x = Default_x;
		InternalLegalEntity.ExposureClass = 'OTH';
		InternalLegalEntity.Fields = Fields;
		InternalLegalEntity.FinancedAmountinEuro = '200.00';
		InternalLegalEntity.PDTreatmentExposureAmountInEuro = '100.00';
		
		ICSResponse.Id_x Id_x = new ICSResponse.Id_x();
		Id_x.SourceSystem = 'ICV';
		Id_x.IDValue = '1523413486635405';
		Id_X.IDType = 'LE_ID';			
		
		ICSResponse.Ids Ids = new ICSResponse.Ids();
		Ids.Id_x = new List<ICSResponse.Id_x>();
		Ids.Id_x.add(Id_x);
		
		InternalLegalEntity.Ids = Ids;
		InternalLegalEntity.PDRequiredTreatment = 'SCRD';
		
		ICSResponse.Phone Phone = new ICSResponse.Phone();
		Phone.PhoneNumber = '8882221111';
		Phone.PhoneType = 'WORK';
		
		InternalLegalEntity.Phone = Phone;
		InternalLegalEntity.RiskGradeRating = 'C';
		
		ICSResponse.AdditionalAttributes AdditionalAttributes = new ICSResponse.AdditionalAttributes();
		AdditionalAttributes.Attribute = new List<ICSResponse.Attribute>();
	
		ICSResponse.Attribute Attribute = new ICSResponse.Attribute();
		Attribute.AttributeName = 'MESSAGE-ID';
		Attribute.AttributeValue = '149dd399e2a24998e967d9569072871d';
		AdditionalAttributes.Attribute.add(Attribute);
		
		ICSResponse.Attribute Attribute2 = new ICSResponse.Attribute();
		Attribute2.AttributeName = 'TRANSACTION-ID';
		Attribute2.AttributeValue = 'CLND-2018-11-07T15:18:10.073Z';
		AdditionalAttributes.Attribute.add(Attribute2);
		
		ICSResponse.Results Results = new ICSResponse.Results();
		Results.ReturnStatus = 'S';
		
			
		ICSResponse.Link Link = new ICSResponse.Link();
		Link.SourceSystem = 'ICV';
		Link.LinkType = 'Commitment';
		Link.LinkValue = 'http://icvcrp1.dll.corp:9080/360View/commitment.360?ss=CLND&sci=QT-000000914&ct=A';
		
		ICSResponse.Link Link1 = new ICSResponse.Link();
		Link1.SourceSystem = 'ICV';
		Link1.LinkType = 'Legal_Entity';
		Link1.LinkValue = 'http://icvcrp1.dll.corp:9080/360View/commitment.360?ss=CLND&sci=QT-000000914&ct=A';
		
		ICSResponse.Link Link2 = new ICSResponse.Link();
		Link2.SourceSystem = 'ICV';
		Link2.LinkType = 'Application & Scoring Details';
		Link2.LinkValue = 'http://icvcrp1.dll.corp:9080/360View/commitment.360?ss=CLND&sci=QT-000000914&ct=A';
		
		ICSResponse.Links Links = new ICSResponse.Links();
		Links.Link = new List<ICSResponse.Link>();
		Links.Link.add(Link);
		Links.Link.add(Link1);
		Links.Link.add(Link2);
		
		Application.Links = Links;
		Application.MultipleYearEAD = MultipleYearEAD;
		Application.MultipleYearEL = MultipleYearEL;
		Application.MultipleYearLGD = MultipleYearLGD;
		
		ObtainDecisionResponse.Application = Application;
		
		Customer.InternalLegalEntity = InternalLegalEntity;
		
		ObtainDecisionResponse.Customer = Customer;
		
  		Input.ObtainDecisionResponse = ObtainDecisionResponse;
  		Input.AdditionalAttributes = AdditionalAttributes;
  		Input.Results = Results;
	
		ICSResponse.SubmitICSResponse(Input);
		
		SystemDecision.SystemDecision = 'AD';
		ICSResponse.SubmitICSResponse(Input);
		
		SystemDecision.SystemDecision = 'R';	
		ICSResponse.SubmitICSResponse(Input);  		
   		
        System.Test.stopTest();
      	
     }	
     /*************************************************************************************************************
     
     TEST 2
     
     ***************************************************************************************************************/
          static TestMethod void  test2() {
    
    	cllease__lease_account__c l = createContract();
	 	
	 	RecordType r = [SELECT ID 
	 						FROM RecordType 
	 						WHERE DeveloperName = 'Dealer'AND SobjectType = 'Account'
	 						AND IsActive = true limit 1];                                   
       
        Account a = new Account(name='Talentica');
        a.RecordTypeId=r.id;
        insert a;
        
        genesis__Quick_Quotes__c qq = new genesis__Quick_Quotes__c(
        			 Dealer__c=a.id
        			,genesis__Business_Name__c='test business name'
        			,genesis__Address_Line_1__c='85 milford road'
        			,genesis__City__c='Downingtown'
        			,genesis__State__c='PA'
        			,genesis__Postal_Code__c='19335'
        			,Estimated_Financed_Amount__c='10000'
        			,genesis__Status__c='NEW'
    				,ats_reference_number__c = '149dd399e2a24998e967d9569072871d'
    			
    				);
    	insert qq;  
    	
    	Address__c addr = new Address__c(
    						 address_line_1__c=qq.genesis__Address_Line_1__c
	  						,city__c=qq.genesis__City__c
	  						,state__c=qq.genesis__State__c
	  						,zip_code__c=qq.genesis__Postal_Code__c
	  						,account__c = a.id
	  						);
	  	insert addr;		   
    	
    	ICS_Application__c app = new ICS_Application__c(
    		quick_quote__c = qq.id
    		,message_id__c = qq.ats_reference_number__c
    		,transaction_id__c = 'CLND-2018-11-07T15:18:10.073Z'
    	);
    	
    	insert app;
    	
    	genesis__Applications__c g = new genesis__Applications__c(
    		 genesis__quick_quote__c = qq.id
    	);
    	insert g;
    	
    	g = [select name from genesis__Applications__c where id = :g.id];
    	
    	system.debug('*****G is: ' + g);
    	l.application_number__c = g.name;
    	l.cllease__application_number__c = g.name;
    	l.cllease__account__c = a.id; 
    	update l;
    	
    	system.debug('***** L is: ' + l);
    	
    	ICS_External_Legal_Entity__c le = new ICS_External_Legal_Entity__c(
    		 ics_application_request__c = app.id
    		,agency_id__c = 'US_DNB'
    		,industry_code_value__c = '1234'
    		,industry_code_type__c = 'SIC_1234_US'
    	);
    	insert le;
    	
    	system.debug(l);
    	
    	ics_log__c log = new ics_log__c (quick_quote__c = qq.id, status__c = 'OK');
    	insert log;
	 	
	 	System.Test.startTest();
        
        ICSResponse.input i = new ICSResponse.input();
       
        /*
        Group g0 = new Group(name = 'Credit', developername = 'Credit', type = 'QUEUE');
        insert g0;
        
        Group g1 = new Group(name = 'Past Credit', developername = 'Past_Credit', type = 'QUEUE');
        insert g1;
        
        Group g2 = new Group(name = 'Waiting for Credit', developername = 'Waiting_for_Credit', type = 'QUEUE');
        insert g2;
        */
        
        qq = [select name from genesis__quick_quotes__c where id = :qq.id];
        
        ICSResponse.Input input = new ICSResponse.Input();
        Input.SearchDataResponse = null;
        Input.ObtainManualDecisionResponse = null;
        
        ICSResponse.ObtainDecisionResponse ObtainDecisionResponse = new ICSResponse.ObtainDecisionResponse();
        ICSResponse.Application Application = new ICSResponse.Application();
        Application.ApplicationId = qq.name;
        Application.AppliedEADTreatment = 'EX_ANTE';
        
        ICSResponse.SystemDecision SystemDecision = new ICSResponse.SystemDecision();
        SystemDecision.ScoreDecision = 'AA';
        SystemDecision.SystemDecision = 'AA';
      	SystemDecision.SystemDecisionDate = '2018-11-07T21:18:26.579+01:00';
      	SystemDecision.SystemApprovalLimit = '10000';
      	SystemDecision.PolicyRuleSetCode = 'NewCo Flow';
        
        
        ICSResponse.DecisionReason DecisionReason = new ICSResponse.DecisionReason();
        DecisionReason.ReasonCode = 'A004';
        DecisionReason.ReasonDesc = 'Scorecard Accept';
        
        ICSResponse.DecisionReasons DecisionReasons = new ICSResponse.DecisionReasons();
        DecisionReasons.DecisionReason = new List<ICSResponse.DecisionReason>();
        DecisionReasons.DecisionReason.add(DecisionReason);
        
        Application.SystemDecision = SystemDecision;
        
        
        ICSResponse.MultipleYearELItem MultipleYearELItem = new ICSResponse.MultipleYearELItem();
        MultipleYearELItem.Vintage = '1';
        MultipleyearELItem.Amount = '0.00';
        
        ICSResponse.MultipleYearEADItem MultipleYearEADItem = new ICSResponse.MultipleYearEADItem();
        MultipleYearEADItem.Vintage = '1';
        MultipleYearEADItem.Amount = '0.00';
        
        ICSResponse.MultipleYearLGDItem MultipleYearLGDItem = new ICSResponse.MultipleYearLGDItem();
        MultipleYearLGDItem.Vintage = '1';
        MultipleYearLGDItem.Percentage = '0.00';
        
		ICSResponse.MultipleYearLGD multipleYearLGD = new ICSResponse.MultipleYearLGD();
		MultipleYearLGD.MultipleYearLGDItem = new List<ICSResponse.MultipleYearLGDItem>();
		MultipleYearLGD.MultipleYearLGDItem.add(MultipleYearLGDItem);
		MultipleYearLGD = multipleYearLGD;
				
		ICSResponse.MultipleYearEL multipleYearEL = new ICSResponse.MultipleYearEL();
		MultipleYearEL.MultipleYearELItem = new List<ICSResponse.MultipleYearELItem>();
		MultipleYearEL.MultipleYearELItem.add(MultipleYearELItem);
		MultipleYearEL = multipleYearEL;
		
		ICSResponse.MultipleYearEAD multipleYearEAD = new ICSResponse.MultipleYearEAD();
		MultipleYearEAD.MultipleYearEADItem = new List<ICSResponse.MultipleYearEADItem>();
		MultipleYearEAD.MultipleYearEADItem.add(MultipleYearEADItem);
		MultipleYearEAD = multipleYearEAD;
		
    	ICSResponse.AdverseReason AdverseReason = new ICSResponse.AdverseReason();
    	AdverseReason.ScoreDeviation = '-150';
    	AdverseReason.AdverseReasonCode = 'AR37';
    	AdverseReason.AdverseReasonDesc = 'Behavioral Components';
    	
    	ICSResponse.AdverseReasons AdverseReasons = new ICSResponse.AdverseReasons();
    	AdverseReasons.AdverseReason = new List<ICSResponse.AdverseReason>();
    	AdverseReasons.AdverseReason.add(AdverseReason);
    	
    	ICSResponse.ScoreCardResult ScorecardResult = new ICSResponse.ScorecardResult();
   		ScorecardResult.ScorecardName = 'DBPUS2_0';
   		ScorecardResult.ScorecardForPDFlag = 'true';
   		ScorecardResult.ScorecardScore = '1316';
   		ScorecardResult.AdverseReasons = AdverseReasons;
   		
   		ICSResponse.ScorecardResults ScorecardResults = new ICSResponse.ScorecardResults();
   		ScorecardResults.ScorecardResult = new List<ICSResponse.ScorecardResult>();
   		ScorecardResults.ScorecardResult.add(ScorecardResult);
   		
   		ICSResponse.ScoreResult ScoreResult = new ICSResponse.ScoreResult();
   		ScoreResult.ScoreDate = '2018-11-07T21:18:25.318+01:00';
   		ScoreResult.ScorecardResults = ScorecardResults;
   		
   		Application.ScoreResult = ScoreResult;
   		
   		ICSResponse.Customer Customer = new ICSResponse.Customer();
   		
   		ICSResponse.DecisionData DecisionData = new ICSResponse.DecisionData();
   		 
   		ICSResponse.Field Field = new ICSResponse.Field();
   		Field.Name = 'DRVD.CMCL.EXTL.ORSK.KnowYourCustomerCode'; 
   		Field.Type = 'int';
   		Field.Value = 'Credit';
   		
   		ICSResponse.Fields Fields = new ICSREsponse.Fields();
   		Fields.Field = new List<ICSResponse.Field>();
   		
   		Fields.field.add(Field); 
   		DecisionData.Fields = Fields;
   		
   		Customer.DecisionData = DecisionData;
   		
   		ICSResponse.Address Address = new ICSResponse.Address();
   		Address.AddressLine = '85 Milford Road';
   		Address.City = 'Downingtown';
   		Address.StateprovinceCode = 'PA';
   		Address.PostalCode = '19335';
   		Address.CountryCode = 'US';
   		
   		ICSResponse.PhoneRecord PhoneRecord = new ICSResponse.PhoneRecord();
   		PhoneRecord.PhoneNumber = '8002221111';
   		PhoneRecord.PhoneType = 'OTHER';
   	
   		ICSResponse.PhoneRecords PhoneRecords = new ICSResponse.PhoneRecords();
   		PhoneRecords.PhoneRecord = new List<ICSResponse.PhoneRecord>(); 
   		PhoneRecords.PhoneRecord.add(PhoneRecord);
   		
   		ICSResponse.AgencyProduct AgencyProduct = new ICSResponse.AgencyProduct();
   		AgencyProduct.AgencyId = 'US_DNB';
   		AgencyProduct.AgencyProductId = 'TOOLKIT';
   		
   		ICSResponse.LocalIndustryCode LocalIndustryCode = new ICSResponse.LocalIndustryCode();
   		LocalIndustryCode.IndustryCodeType = 'SIC_1987_US';
   		LocalIndustryCode.IndustryCodeValue = '8748';
   		
   		ICSResponse.Organization Organization = new ICSResponse.Organization();
   		Organization.LegalName = 'Test Company';
   		Organization.EstablishedYear = '2019';
   		Organization.LocalIndustryCode = LocalIndustryCode;
   		
   		ICSResponse.ExternalId ExternalId = new ICSResponse.ExternalId();
   		ExternalId.ExternalIdType = 'DUNS';
   		ExternalId.ExternalIdvalue = '042903262';
   	
    	ICSResponse.ExternalIds ExternalIds = new ICSResponse.ExternalIds();
   		ExternalIds.ExternalId = new List<ICSResponse.ExternalId>();
   		ExternalIds.ExternalId.add(ExternalId);	
   	
   		ICSResponse.ExternalLegalEntity ExternalLegalEntity = new ICSResponse.ExternalLegalEntity();
   		ExternalLegalEntity.ExternalIds = ExternalIds;
   		ExternalLegalEntity.AgencyProduct = AgencyProduct; 
   		ExternalLegalEntity.Organization = Organization;
   		ExternalLegalEntity.Address = Address;
   		ExternalLegalEntity.PhoneRecords = PhoneRecords; 
   		ExternalLegalEntity.Fields = Fields;
   		
   		ICSResponse.ExternalLegalEntities ExternalLegalEntities = new ICSResponse.ExternalLegalEntities();
   		ExternalLegalEntities.ExternalLegalEntity = new List<ICSResponse.ExternalLegalEntity>();
   		ExternalLegalEntities.ExternalLegalEntity.add(ExternalLegalEntity);
   		
		Customer.ExternalLegalEntities = ExternalLegalEntities;
		
		ICSResponse.InternalLegalEntity InternalLegalEntity = new ICSResponse.InternalLegalEntity();
		InternalLegalEntity.Address = Address;
		
		ICSResponse.ApplicableRating ApplicableRating = new ICSResponse.ApplicableRating();
		ApplicableRating.CherryPickingFlag = 'false';
		ApplicableRating.PDLookupType = 'SCRD';
		ApplicableRating.PDPercentage = '0.0182699';
		ApplicableRating.PDRatingDate = '2018-11-07T12:00:00Z';
		ApplicableRating.PDRatingModel = 'DBPUS2_0';
		ApplicableRating.PDRatingScore = '1316';
		ApplicableRating.PDVintage = '1';
		ApplicableRating.PDPenaltyFlag = 'true';
		ApplicableRating.RabobankMasterscaleRating = 'R14';
		
		
		
		ICSResponse.MultiplePD MultiplePD = new ICSResponse.MultiplePD();
		MultiplePD.MultipleYearPDItem = new List<ICSResponse.MultipleYearPDItem>();
		ICSResponse.MultipleYearPDItem MultipleYearPDItem = new ICSResponse.MultipleYearPDItem();
		MultipleYearPDItem.Percentage = '0.0182688';
		MultipleYearPDItem.Vintage = '1';
	 	
		MultiplePD.MultipleYearPDItem.add(MultipleYearPDItem);
		
		ApplicableRating.MultiplePD = MultiplePD;
		
		InternalLegalEntity.ApplicableRating = ApplicableRating;
		InternalLegalEntity.CREStatus = 'NOT REQUIRED';
		 
		ICSResponse.Default_x Default_x = new ICSREsponse.Default_x();
		Default_x.CurrentlyInDefaultIndicator = 'false';
		
		InternalLegalEntity.Default_x = Default_x;
		InternalLegalEntity.ExposureClass = 'OTH';
		InternalLegalEntity.Fields = Fields;
		InternalLegalEntity.FinancedAmountinEuro = '200.00';
		InternalLegalEntity.PDTreatmentExposureAmountInEuro = '100.00';
		
		ICSResponse.Id_x Id_x = new ICSResponse.Id_x();
		Id_x.SourceSystem = 'ICV';
		Id_x.IDValue = '1523413486635405';
		Id_X.IDType = 'LE_ID';			
		
		ICSResponse.Ids Ids = new ICSResponse.Ids();
		Ids.Id_x = new List<ICSResponse.Id_x>();
		Ids.Id_x.add(Id_x);
		
		InternalLegalEntity.Ids = Ids;
		InternalLegalEntity.PDRequiredTreatment = 'SCRD';
		
		ICSResponse.Phone Phone = new ICSResponse.Phone();
		Phone.PhoneNumber = '8882221111';
		Phone.PhoneType = 'WORK';
		
		InternalLegalEntity.Phone = Phone;
		InternalLegalEntity.RiskGradeRating = 'C';
		
		ICSResponse.AdditionalAttributes AdditionalAttributes = new ICSResponse.AdditionalAttributes();
		AdditionalAttributes.Attribute = new List<ICSResponse.Attribute>();
	
		ICSResponse.Attribute Attribute = new ICSResponse.Attribute();
		Attribute.AttributeName = 'MESSAGE-ID';
		Attribute.AttributeValue = '149dd399e2a24998e967d9569072871d';
		AdditionalAttributes.Attribute.add(Attribute);
		
		ICSResponse.Attribute Attribute2 = new ICSResponse.Attribute();
		Attribute2.AttributeName = 'TRANSACTION-ID';
		Attribute2.AttributeValue = 'CLND-2018-11-07T15:18:10.073Z';
		AdditionalAttributes.Attribute.add(Attribute2);
		
		ICSResponse.Results Results = new ICSResponse.Results();
		Results.ReturnStatus = 'S';
		
			
		ICSResponse.Link Link = new ICSResponse.Link();
		Link.SourceSystem = 'ICV';
		Link.LinkType = 'Commitment';
		Link.LinkValue = 'http://icvcrp1.dll.corp:9080/360View/commitment.360?ss=CLND&sci=QT-000000914&ct=A';
		
		ICSResponse.Link Link1 = new ICSResponse.Link();
		Link1.SourceSystem = 'ICV';
		Link1.LinkType = 'Legal_Entity';
		Link1.LinkValue = 'http://icvcrp1.dll.corp:9080/360View/commitment.360?ss=CLND&sci=QT-000000914&ct=A';
		
		ICSResponse.Link Link2 = new ICSResponse.Link();
		Link2.SourceSystem = 'ICV';
		Link2.LinkType = 'Application & Scoring Details';
		Link2.LinkValue = 'http://icvcrp1.dll.corp:9080/360View/commitment.360?ss=CLND&sci=QT-000000914&ct=A';
		
		ICSResponse.Links Links = new ICSResponse.Links();
		Links.Link = new List<ICSResponse.Link>();
		Links.Link.add(Link);
		Links.Link.add(Link1);
		Links.Link.add(Link2);
		
		Application.Links = Links;
		Application.MultipleYearEAD = MultipleYearEAD;
		Application.MultipleYearEL = MultipleYearEL;
		Application.MultipleYearLGD = MultipleYearLGD;
		
		ObtainDecisionResponse.Application = Application;
		
		Customer.InternalLegalEntity = InternalLegalEntity;
		
		ObtainDecisionResponse.Customer = Customer;
		
  		ICSResponse.ObtainManualDecisionResponse ObtainManualDecisionResponse = new ICSResponse.ObtainManualDecisionResponse();
  		
  		ICSResponse.ManualApplication ManualApplication = new ICSResponse.ManualApplication();
  		ManualApplication.applicationId = Application.ApplicationId;
  		ManualApplication.MultipleYearLGD = Application.MultipleYearLGD;
  		ManualApplication.AppliedEADTreatment = 'dog';
  		ManualApplication.MultipleYearEAD = Application.MultipleYearEAD;
  		ManualApplication.MultipleYearEL = Application.MultipleYearEL;
  		ManualApplication.Links = Application.Links;
  		ManualApplication.ApplicationId = qq.name;
  		
  		ObtainManualDecisionResponse.Application = ManualApplication;
  	
   	
  		Input.ObtainDecisionResponse = null;
  		Input.SearchDataResponse = null;
  		Input.ObtainManualDecisionResponse = ObtainManualDecisionResponse;
  		Input.AdditionalAttributes = AdditionalAttributes;
  		Input.Results = Results;
	
		ICSResponse.SubmitICSResponse(Input);
		
		
   		
        System.Test.stopTest();
      	
     }	
     
     /*************************************************************************************************************
     
     TEST 3
     
     ***************************************************************************************************************/
        static TestMethod void  test3() {
    
    	cllease__lease_account__c l = createContract();
	 	
	 	RecordType r = [SELECT ID 
	 						FROM RecordType 
	 						WHERE DeveloperName = 'Dealer'AND SobjectType = 'Account'
	 						AND IsActive = true limit 1];                                   
       
        Account a = new Account(name='Talentica');
        a.RecordTypeId=r.id;
        insert a;
        
        genesis__Quick_Quotes__c qq = new genesis__Quick_Quotes__c(
        			 Dealer__c=a.id
        			,genesis__Business_Name__c='test business name'
        			,genesis__Address_Line_1__c='85 milford road'
        			,genesis__City__c='Downingtown'
        			,genesis__State__c='PA'
        			,genesis__Postal_Code__c='19335'
        			,Estimated_Financed_Amount__c='10000'
        			,genesis__Status__c='NEW'
    				,ats_reference_number__c = '149dd399e2a24998e967d9569072871d'
    			
    				);
    	insert qq;  
    	
    	Address__c addr = new Address__c(
    						 address_line_1__c=qq.genesis__Address_Line_1__c
	  						,city__c=qq.genesis__City__c
	  						,state__c=qq.genesis__State__c
	  						,zip_code__c=qq.genesis__Postal_Code__c
	  						,account__c = a.id
	  						);
	  	insert addr;		   
    	
    	ICS_Application__c app = new ICS_Application__c(
    		quick_quote__c = qq.id
    		,message_id__c = qq.ats_reference_number__c
    	);
    	
    	insert app;
    	
    	genesis__Applications__c g = new genesis__Applications__c(
    		 genesis__quick_quote__c = qq.id
    	);
    	insert g;
    	
    	g = [select name from genesis__Applications__c where id = :g.id];
    	
    	system.debug('*****G is: ' + g);
    	l.application_number__c = g.name;
    	l.cllease__application_number__c = g.name;
    	l.cllease__account__c = a.id; 
    	update l;
    	
    	system.debug('***** L is: ' + l);
    	
    	ICS_External_Legal_Entity__c le = new ICS_External_Legal_Entity__c(
    		 ics_application_request__c = app.id
    		,agency_id__c = 'US_DNB'
    		,industry_code_value__c = '1234'
    		,industry_code_type__c = 'SIC_1234_US'
    	);
    	insert le;
    	
    	system.debug(l);
    	
    	ics_log__c log = new ics_log__c (quick_quote__c = qq.id, status__c = 'OK');
    	insert log;
	 	
	 	System.Test.startTest();
        
        ICSResponse.input i = new ICSResponse.input();
       
        /*
        Group g0 = new Group(name = 'Credit', developername = 'Credit', type = 'QUEUE');
        insert g0;
        
        Group g1 = new Group(name = 'Past Credit', developername = 'Past_Credit', type = 'QUEUE');
        insert g1;
        
        Group g2 = new Group(name = 'Waiting for Credit', developername = 'Waiting_for_Credit', type = 'QUEUE');
        insert g2;
        */
        
        qq = [select name from genesis__quick_quotes__c where id = :qq.id];
        
        ICSResponse.Input input = new ICSResponse.Input();
        Input.SearchDataResponse = null;
        Input.ObtainManualDecisionResponse = null;
        
        ICSResponse.ObtainDecisionResponse ObtainDecisionResponse = new ICSResponse.ObtainDecisionResponse();
        ICSResponse.Application Application = new ICSResponse.Application();
        Application.ApplicationId = qq.name;
        Application.AppliedEADTreatment = 'EX_ANTE';
        
        ICSResponse.SystemDecision SystemDecision = new ICSResponse.SystemDecision();
        SystemDecision.ScoreDecision = 'AA';
        SystemDecision.SystemDecision = 'AA';
      	SystemDecision.SystemDecisionDate = '2018-11-07T21:18:26.579+01:00';
      	SystemDecision.SystemApprovalLimit = '10000';
      	SystemDecision.PolicyRuleSetCode = 'NewCo Flow';
        
        
        ICSResponse.DecisionReason DecisionReason = new ICSResponse.DecisionReason();
        DecisionReason.ReasonCode = 'A004';
        DecisionReason.ReasonDesc = 'Scorecard Accept';
        
        ICSResponse.DecisionReasons DecisionReasons = new ICSResponse.DecisionReasons();
        DecisionReasons.DecisionReason = new List<ICSResponse.DecisionReason>();
        DecisionReasons.DecisionReason.add(DecisionReason);
        
        Application.SystemDecision = SystemDecision;
        
        
        ICSResponse.MultipleYearELItem MultipleYearELItem = new ICSResponse.MultipleYearELItem();
        MultipleYearELItem.Vintage = '1';
        MultipleyearELItem.Amount = '0.00';
        
        ICSResponse.MultipleYearEADItem MultipleYearEADItem = new ICSResponse.MultipleYearEADItem();
        MultipleYearEADItem.Vintage = '1';
        MultipleYearEADItem.Amount = '0.00';
        
        ICSResponse.MultipleYearLGDItem MultipleYearLGDItem = new ICSResponse.MultipleYearLGDItem();
        MultipleYearLGDItem.Vintage = '1';
        MultipleYearLGDItem.Percentage = '0.00';
        
		ICSResponse.MultipleYearLGD multipleYearLGD = new ICSResponse.MultipleYearLGD();
		MultipleYearLGD.MultipleYearLGDItem = new List<ICSResponse.MultipleYearLGDItem>();
		MultipleYearLGD.MultipleYearLGDItem.add(MultipleYearLGDItem);
		MultipleYearLGD = multipleYearLGD;
				
		ICSResponse.MultipleYearEL multipleYearEL = new ICSResponse.MultipleYearEL();
		MultipleYearEL.MultipleYearELItem = new List<ICSResponse.MultipleYearELItem>();
		MultipleYearEL.MultipleYearELItem.add(MultipleYearELItem);
		MultipleYearEL = multipleYearEL;
		
		ICSResponse.MultipleYearEAD multipleYearEAD = new ICSResponse.MultipleYearEAD();
		MultipleYearEAD.MultipleYearEADItem = new List<ICSResponse.MultipleYearEADItem>();
		MultipleYearEAD.MultipleYearEADItem.add(MultipleYearEADItem);
		MultipleYearEAD = multipleYearEAD;
		
    	ICSResponse.AdverseReason AdverseReason = new ICSResponse.AdverseReason();
    	AdverseReason.ScoreDeviation = '-150';
    	AdverseReason.AdverseReasonCode = 'AR37';
    	AdverseReason.AdverseReasonDesc = 'Behavioral Components';
    	
    	ICSResponse.AdverseReasons AdverseReasons = new ICSResponse.AdverseReasons();
    	AdverseReasons.AdverseReason = new List<ICSResponse.AdverseReason>();
    	AdverseReasons.AdverseReason.add(AdverseReason);
    	
    	ICSResponse.ScoreCardResult ScorecardResult = new ICSResponse.ScorecardResult();
   		ScorecardResult.ScorecardName = 'DBPUS2_0';
   		ScorecardResult.ScorecardForPDFlag = 'true';
   		ScorecardResult.ScorecardScore = '1316';
   		ScorecardResult.AdverseReasons = AdverseReasons;
   		
   		ICSResponse.ScorecardResults ScorecardResults = new ICSResponse.ScorecardResults();
   		ScorecardResults.ScorecardResult = new List<ICSResponse.ScorecardResult>();
   		ScorecardResults.ScorecardResult.add(ScorecardResult);
   		
   		ICSResponse.ScoreResult ScoreResult = new ICSResponse.ScoreResult();
   		ScoreResult.ScoreDate = '2018-11-07T21:18:25.318+01:00';
   		ScoreResult.ScorecardResults = ScorecardResults;
   		
   		Application.ScoreResult = ScoreResult;
   		
   		ICSResponse.Customer Customer = new ICSResponse.Customer();
   		
   		ICSResponse.DecisionData DecisionData = new ICSResponse.DecisionData();
   		 
   		ICSResponse.Field Field = new ICSResponse.Field();
   		Field.Name = 'DRVD.CMCL.EXTL.ORSK.KnowYourCustomerCode'; 
   		Field.Type = 'int';
   		Field.Value = 'Credit';
   		
   		ICSResponse.Fields Fields = new ICSREsponse.Fields();
   		Fields.Field = new List<ICSResponse.Field>();
   		
   		Fields.field.add(Field); 
   		DecisionData.Fields = Fields;
   		
   		Customer.DecisionData = DecisionData;
   		
   		ICSResponse.Address Address = new ICSResponse.Address();
   		Address.AddressLine = '85 Milford Road';
   		Address.City = 'Downingtown';
   		Address.StateprovinceCode = 'PA';
   		Address.PostalCode = '19335';
   		Address.CountryCode = 'US';
   		
   		ICSResponse.PhoneRecord PhoneRecord = new ICSResponse.PhoneRecord();
   		PhoneRecord.PhoneNumber = '8002221111';
   		PhoneRecord.PhoneType = 'OTHER';
   	
   		ICSResponse.PhoneRecords PhoneRecords = new ICSResponse.PhoneRecords();
   		PhoneRecords.PhoneRecord = new List<ICSResponse.PhoneRecord>(); 
   		PhoneRecords.PhoneRecord.add(PhoneRecord);
   		
   		ICSResponse.AgencyProduct AgencyProduct = new ICSResponse.AgencyProduct();
   		AgencyProduct.AgencyId = 'US_DNB';
   		AgencyProduct.AgencyProductId = 'TOOLKIT';
   		
   		ICSResponse.LocalIndustryCode LocalIndustryCode = new ICSResponse.LocalIndustryCode();
   		LocalIndustryCode.IndustryCodeType = 'SIC_1987_US';
   		LocalIndustryCode.IndustryCodeValue = '8748';
   		
   		ICSResponse.Organization Organization = new ICSResponse.Organization();
   		Organization.LegalName = 'Test Company';
   		Organization.EstablishedYear = '2019';
   		Organization.LocalIndustryCode = LocalIndustryCode;
   		
   		ICSResponse.ExternalId ExternalId = new ICSResponse.ExternalId();
   		ExternalId.ExternalIdType = 'DUNS';
   		ExternalId.ExternalIdvalue = '042903262';
   	
    	ICSResponse.ExternalIds ExternalIds = new ICSResponse.ExternalIds();
   		ExternalIds.ExternalId = new List<ICSResponse.ExternalId>();
   		ExternalIds.ExternalId.add(ExternalId);	
   	
   		ICSResponse.ExternalLegalEntity ExternalLegalEntity = new ICSResponse.ExternalLegalEntity();
   		ExternalLegalEntity.ExternalIds = ExternalIds;
   		ExternalLegalEntity.AgencyProduct = AgencyProduct; 
   		ExternalLegalEntity.Organization = Organization;
   		ExternalLegalEntity.Address = Address;
   		ExternalLegalEntity.PhoneRecords = PhoneRecords; 
   		ExternalLegalEntity.Fields = Fields;
   		
   		ICSResponse.ExternalLegalEntities ExternalLegalEntities = new ICSResponse.ExternalLegalEntities();
   		ExternalLegalEntities.ExternalLegalEntity = new List<ICSResponse.ExternalLegalEntity>();
   		ExternalLegalEntities.ExternalLegalEntity.add(ExternalLegalEntity);
   		
		Customer.ExternalLegalEntities = ExternalLegalEntities;
		
		ICSResponse.InternalLegalEntity InternalLegalEntity = new ICSResponse.InternalLegalEntity();
		InternalLegalEntity.Address = Address;
		
		ICSResponse.ApplicableRating ApplicableRating = new ICSResponse.ApplicableRating();
		ApplicableRating.CherryPickingFlag = 'false';
		ApplicableRating.PDLookupType = 'SCRD';
		ApplicableRating.PDPercentage = '0.0182699';
		ApplicableRating.PDRatingDate = '2018-11-07T12:00:00Z';
		ApplicableRating.PDRatingModel = 'DBPUS2_0';
		ApplicableRating.PDRatingScore = '1316';
		ApplicableRating.PDVintage = '1';
		ApplicableRating.PDPenaltyFlag = 'true';
		ApplicableRating.RabobankMasterscaleRating = 'R14';
		
		
		
		ICSResponse.MultiplePD MultiplePD = new ICSResponse.MultiplePD();
		MultiplePD.MultipleYearPDItem = new List<ICSResponse.MultipleYearPDItem>();
		ICSResponse.MultipleYearPDItem MultipleYearPDItem = new ICSResponse.MultipleYearPDItem();
		MultipleYearPDItem.Percentage = '0.0182688';
		MultipleYearPDItem.Vintage = '1';
	 	
		MultiplePD.MultipleYearPDItem.add(MultipleYearPDItem);
		
		ApplicableRating.MultiplePD = MultiplePD;
		
		InternalLegalEntity.ApplicableRating = ApplicableRating;
		InternalLegalEntity.CREStatus = 'NOT REQUIRED';
		 
		ICSResponse.Default_x Default_x = new ICSREsponse.Default_x();
		Default_x.CurrentlyInDefaultIndicator = 'false';
		
		InternalLegalEntity.Default_x = Default_x;
		InternalLegalEntity.ExposureClass = 'OTH';
		InternalLegalEntity.Fields = Fields;
		InternalLegalEntity.FinancedAmountinEuro = '200.00';
		InternalLegalEntity.PDTreatmentExposureAmountInEuro = '100.00';
		
		ICSResponse.Id_x Id_x = new ICSResponse.Id_x();
		Id_x.SourceSystem = 'ICV';
		Id_x.IDValue = '1523413486635405';
		Id_X.IDType = 'LE_ID';			
		
		ICSResponse.Ids Ids = new ICSResponse.Ids();
		Ids.Id_x = new List<ICSResponse.Id_x>();
		Ids.Id_x.add(Id_x);
		
		InternalLegalEntity.Ids = Ids;
		InternalLegalEntity.PDRequiredTreatment = 'SCRD';
		
		ICSResponse.Phone Phone = new ICSResponse.Phone();
		Phone.PhoneNumber = '8882221111';
		Phone.PhoneType = 'WORK';
		
		InternalLegalEntity.Phone = Phone;
		InternalLegalEntity.RiskGradeRating = 'C';
		
		ICSResponse.AdditionalAttributes AdditionalAttributes = new ICSResponse.AdditionalAttributes();
		AdditionalAttributes.Attribute = new List<ICSResponse.Attribute>();
	
		ICSResponse.Attribute Attribute = new ICSResponse.Attribute();
		Attribute.AttributeName = 'MESSAGE-ID';
		Attribute.AttributeValue = '149dd399e2a24998e967d9569072871d';
		AdditionalAttributes.Attribute.add(Attribute);
		
		ICSResponse.Attribute Attribute2 = new ICSResponse.Attribute();
		Attribute2.AttributeName = 'TRANSACTION-ID';
		Attribute2.AttributeValue = 'CLND-2018-11-07T15:18:10.073Z';
		AdditionalAttributes.Attribute.add(Attribute2);
		
		ICSResponse.Results Results = new ICSResponse.Results();
		Results.ReturnStatus = 'S';
		
			
		ICSResponse.Link Link = new ICSResponse.Link();
		Link.SourceSystem = 'ICV';
		Link.LinkType = 'Commitment';
		Link.LinkValue = 'http://icvcrp1.dll.corp:9080/360View/commitment.360?ss=CLND&sci=QT-000000914&ct=A';
		
		ICSResponse.Link Link1 = new ICSResponse.Link();
		Link1.SourceSystem = 'ICV';
		Link1.LinkType = 'Legal_Entity';
		Link1.LinkValue = 'http://icvcrp1.dll.corp:9080/360View/commitment.360?ss=CLND&sci=QT-000000914&ct=A';
		
		ICSResponse.Link Link2 = new ICSResponse.Link();
		Link2.SourceSystem = 'ICV';
		Link2.LinkType = 'Application & Scoring Details';
		Link2.LinkValue = 'http://icvcrp1.dll.corp:9080/360View/commitment.360?ss=CLND&sci=QT-000000914&ct=A';
		
		ICSResponse.Links Links = new ICSResponse.Links();
		Links.Link = new List<ICSResponse.Link>();
		Links.Link.add(Link);
		Links.Link.add(Link1);
		Links.Link.add(Link2);
		
		Application.Links = Links;
		Application.MultipleYearEAD = MultipleYearEAD;
		Application.MultipleYearEL = MultipleYearEL;
		Application.MultipleYearLGD = MultipleYearLGD;
		
		ObtainDecisionResponse.Application = Application;
		
		Customer.InternalLegalEntity = InternalLegalEntity;
		
		ObtainDecisionResponse.Customer = Customer;
		
  		Input.ObtainDecisionResponse = null;
  		ICSResponse.SearchDataResponse SearchDataResponse = new ICSResponse.SearchDataResponse();
  		Input.SearchDataResponse = SearchDataResponse;
  		SearchDataResponse.InternalLegalEntity = InternalLegalEntity;
  		SearchDataResponse.ExternalLegalEntities = ExternalLegalEntities;
  		
  		Input.AdditionalAttributes = AdditionalAttributes;
  		Input.Results = Results;
	
		ICSResponse.SubmitICSResponse(Input);
		
		
   		
        System.Test.stopTest();
      	
     }	
     
     
     /*************************************************************************************************************
     
     TEST 4
     
     ***************************************************************************************************************/
        static TestMethod void  test4() {
    
    	cllease__lease_account__c l = createContract();
	 	
	 	RecordType r = [SELECT ID 
	 						FROM RecordType 
	 						WHERE DeveloperName = 'Dealer'AND SobjectType = 'Account'
	 						AND IsActive = true limit 1];                                   
       
        Account a = new Account(name='Talentica');
        a.RecordTypeId=r.id;
        insert a;
        
        genesis__Quick_Quotes__c qq = new genesis__Quick_Quotes__c(
        			 Dealer__c=a.id
        			,genesis__Business_Name__c='test business name'
        			,genesis__Address_Line_1__c='85 milford road'
        			,genesis__City__c='Downingtown'
        			,genesis__State__c='PA'
        			,genesis__Postal_Code__c='19335'
        			,Estimated_Financed_Amount__c='10000'
        			,genesis__Status__c='NEW'
    				,ats_reference_number__c = '149dd399e2a24998e967d9569072871d'
    			
    				);
    	insert qq;  
    	
    	Address__c addr = new Address__c(
    						 address_line_1__c=qq.genesis__Address_Line_1__c
	  						,city__c=qq.genesis__City__c
	  						,state__c=qq.genesis__State__c
	  						,zip_code__c=qq.genesis__Postal_Code__c
	  						,account__c = a.id
	  						);
	  	insert addr;		   
    	
    	ICS_Application__c app = new ICS_Application__c(
    		quick_quote__c = qq.id
    		,message_id__c = qq.ats_reference_number__c
    		,transaction_id__c = 'CLND-2018-11-07T15:18:10.073Z'
    	);
    	
    	insert app;
    	
    	genesis__Applications__c g = new genesis__Applications__c(
    		 genesis__quick_quote__c = qq.id
    	);
    	insert g;
    	
    	g = [select name from genesis__Applications__c where id = :g.id];
    	
    	system.debug('*****G is: ' + g);
    	l.application_number__c = g.name;
    	l.cllease__application_number__c = g.name;
    	l.cllease__account__c = a.id; 
    	update l;
    	
    	system.debug('***** L is: ' + l);
    	
    	ICS_External_Legal_Entity__c le = new ICS_External_Legal_Entity__c(
    		 ics_application_request__c = app.id
    		,agency_id__c = 'US_DNB'
    		,industry_code_value__c = '1234'
    		,industry_code_type__c = 'SIC_1234_US'
    	);
    	insert le;
    	
    	system.debug(l);
    	
    	ics_log__c log = new ics_log__c (quick_quote__c = qq.id, status__c = 'OK');
    	insert log;
	 	
	 	System.Test.startTest();
        
        ICSResponse.input i = new ICSResponse.input();
       
        /*
        Group g0 = new Group(name = 'Credit', developername = 'Credit', type = 'QUEUE');
        insert g0;
        
        Group g1 = new Group(name = 'Past Credit', developername = 'Past_Credit', type = 'QUEUE');
        insert g1;
        
        Group g2 = new Group(name = 'Waiting for Credit', developername = 'Waiting_for_Credit', type = 'QUEUE');
        insert g2;
        */
        
        qq = [select name from genesis__quick_quotes__c where id = :qq.id];
        
        ICSResponse.Input input = new ICSResponse.Input();
        Input.SearchDataResponse = null;
        Input.ObtainManualDecisionResponse = null;
        
        ICSResponse.ObtainDecisionResponse ObtainDecisionResponse = new ICSResponse.ObtainDecisionResponse();
        ICSResponse.Application Application = new ICSResponse.Application();
        Application.ApplicationId = qq.name;
        Application.AppliedEADTreatment = 'EX_ANTE';
        
        ICSResponse.SystemDecision SystemDecision = new ICSResponse.SystemDecision();
        SystemDecision.ScoreDecision = 'AA';
        SystemDecision.SystemDecision = 'AA';
      	SystemDecision.SystemDecisionDate = '2018-11-07T21:18:26.579+01:00';
      	SystemDecision.SystemApprovalLimit = '10000';
      	SystemDecision.PolicyRuleSetCode = 'NewCo Flow';
        
        
        ICSResponse.DecisionReason DecisionReason = new ICSResponse.DecisionReason();
        DecisionReason.ReasonCode = 'A004';
        DecisionReason.ReasonDesc = 'Scorecard Accept';
        
        ICSResponse.DecisionReasons DecisionReasons = new ICSResponse.DecisionReasons();
        DecisionReasons.DecisionReason = new List<ICSResponse.DecisionReason>();
        DecisionReasons.DecisionReason.add(DecisionReason);
        
        Application.SystemDecision = SystemDecision;
        
        
        ICSResponse.MultipleYearELItem MultipleYearELItem = new ICSResponse.MultipleYearELItem();
        MultipleYearELItem.Vintage = '1';
        MultipleyearELItem.Amount = '0.00';
        
        ICSResponse.MultipleYearEADItem MultipleYearEADItem = new ICSResponse.MultipleYearEADItem();
        MultipleYearEADItem.Vintage = '1';
        MultipleYearEADItem.Amount = '0.00';
        
        ICSResponse.MultipleYearLGDItem MultipleYearLGDItem = new ICSResponse.MultipleYearLGDItem();
        MultipleYearLGDItem.Vintage = '1';
        MultipleYearLGDItem.Percentage = '0.00';
        
		ICSResponse.MultipleYearLGD multipleYearLGD = new ICSResponse.MultipleYearLGD();
		MultipleYearLGD.MultipleYearLGDItem = new List<ICSResponse.MultipleYearLGDItem>();
		MultipleYearLGD.MultipleYearLGDItem.add(MultipleYearLGDItem);
		MultipleYearLGD = multipleYearLGD;
				
		ICSResponse.MultipleYearEL multipleYearEL = new ICSResponse.MultipleYearEL();
		MultipleYearEL.MultipleYearELItem = new List<ICSResponse.MultipleYearELItem>();
		MultipleYearEL.MultipleYearELItem.add(MultipleYearELItem);
		MultipleYearEL = multipleYearEL;
		
		ICSResponse.MultipleYearEAD multipleYearEAD = new ICSResponse.MultipleYearEAD();
		MultipleYearEAD.MultipleYearEADItem = new List<ICSResponse.MultipleYearEADItem>();
		MultipleYearEAD.MultipleYearEADItem.add(MultipleYearEADItem);
		MultipleYearEAD = multipleYearEAD;
		
    	ICSResponse.AdverseReason AdverseReason = new ICSResponse.AdverseReason();
    	AdverseReason.ScoreDeviation = '-150';
    	AdverseReason.AdverseReasonCode = 'AR37';
    	AdverseReason.AdverseReasonDesc = 'Behavioral Components';
    	
    	ICSResponse.AdverseReasons AdverseReasons = new ICSResponse.AdverseReasons();
    	AdverseReasons.AdverseReason = new List<ICSResponse.AdverseReason>();
    	AdverseReasons.AdverseReason.add(AdverseReason);
    	
    	ICSResponse.ScoreCardResult ScorecardResult = new ICSResponse.ScorecardResult();
   		ScorecardResult.ScorecardName = 'DBPUS2_0';
   		ScorecardResult.ScorecardForPDFlag = 'true';
   		ScorecardResult.ScorecardScore = '1316';
   		ScorecardResult.AdverseReasons = AdverseReasons;
   		
   		ICSResponse.ScorecardResults ScorecardResults = new ICSResponse.ScorecardResults();
   		ScorecardResults.ScorecardResult = new List<ICSResponse.ScorecardResult>();
   		ScorecardResults.ScorecardResult.add(ScorecardResult);
   		
   		ICSResponse.ScoreResult ScoreResult = new ICSResponse.ScoreResult();
   		ScoreResult.ScoreDate = '2018-11-07T21:18:25.318+01:00';
   		ScoreResult.ScorecardResults = ScorecardResults;
   		
   		Application.ScoreResult = ScoreResult;
   		
   		ICSResponse.Customer Customer = new ICSResponse.Customer();
   		
   		ICSResponse.DecisionData DecisionData = new ICSResponse.DecisionData();
   		 
   		ICSResponse.Field Field = new ICSResponse.Field();
   		Field.Name = 'DRVD.CMCL.EXTL.ORSK.KnowYourCustomerCode'; 
   		Field.Type = 'int';
   		Field.Value = 'Credit';
   		
   		ICSResponse.Fields Fields = new ICSREsponse.Fields();
   		Fields.Field = new List<ICSResponse.Field>();
   		
   		Fields.field.add(Field); 
   		DecisionData.Fields = Fields;
   		
   		Customer.DecisionData = DecisionData;
   		
   		ICSResponse.Address Address = new ICSResponse.Address();
   		Address.AddressLine = '85 Milford Road';
   		Address.City = 'Downingtown';
   		Address.StateprovinceCode = 'PA';
   		Address.PostalCode = '19335';
   		Address.CountryCode = 'US';
   		
   		ICSResponse.PhoneRecord PhoneRecord = new ICSResponse.PhoneRecord();
   		PhoneRecord.PhoneNumber = '8002221111';
   		PhoneRecord.PhoneType = 'OTHER';
   	
   		ICSResponse.PhoneRecords PhoneRecords = new ICSResponse.PhoneRecords();
   		PhoneRecords.PhoneRecord = new List<ICSResponse.PhoneRecord>(); 
   		PhoneRecords.PhoneRecord.add(PhoneRecord);
   		
   		ICSResponse.AgencyProduct AgencyProduct = new ICSResponse.AgencyProduct();
   		AgencyProduct.AgencyId = 'US_DNB';
   		AgencyProduct.AgencyProductId = 'TOOLKIT';
   		
   		ICSResponse.LocalIndustryCode LocalIndustryCode = new ICSResponse.LocalIndustryCode();
   		LocalIndustryCode.IndustryCodeType = 'SIC_1987_US';
   		LocalIndustryCode.IndustryCodeValue = '8748';
   		
   		ICSResponse.Organization Organization = new ICSResponse.Organization();
   		Organization.LegalName = 'Test Company';
   		Organization.EstablishedYear = '2019';
   		Organization.LocalIndustryCode = LocalIndustryCode;
   		
   		ICSResponse.ExternalId ExternalId = new ICSResponse.ExternalId();
   		ExternalId.ExternalIdType = 'DUNS';
   		ExternalId.ExternalIdvalue = '042903262';
   	
    	ICSResponse.ExternalIds ExternalIds = new ICSResponse.ExternalIds();
   		ExternalIds.ExternalId = new List<ICSResponse.ExternalId>();
   		ExternalIds.ExternalId.add(ExternalId);	
   	
   		ICSResponse.ExternalLegalEntity ExternalLegalEntity = new ICSResponse.ExternalLegalEntity();
   		ExternalLegalEntity.ExternalIds = ExternalIds;
   		ExternalLegalEntity.AgencyProduct = AgencyProduct; 
   		ExternalLegalEntity.Organization = Organization;
   		ExternalLegalEntity.Address = Address;
   		ExternalLegalEntity.PhoneRecords = PhoneRecords; 
   		ExternalLegalEntity.Fields = Fields;
   		
   		ICSResponse.ExternalLegalEntities ExternalLegalEntities = new ICSResponse.ExternalLegalEntities();
   		ExternalLegalEntities.ExternalLegalEntity = new List<ICSResponse.ExternalLegalEntity>();
   		ExternalLegalEntities.ExternalLegalEntity.add(ExternalLegalEntity);
   		
		Customer.ExternalLegalEntities = ExternalLegalEntities;
		
		ICSResponse.InternalLegalEntity InternalLegalEntity = new ICSResponse.InternalLegalEntity();
		InternalLegalEntity.Address = Address;
		
		ICSResponse.ApplicableRating ApplicableRating = new ICSResponse.ApplicableRating();
		ApplicableRating.CherryPickingFlag = 'false';
		ApplicableRating.PDLookupType = 'SCRD';
		ApplicableRating.PDPercentage = '0.0182699';
		ApplicableRating.PDRatingDate = '2018-11-07T12:00:00Z';
		ApplicableRating.PDRatingModel = 'DBPUS2_0';
		ApplicableRating.PDRatingScore = '1316';
		ApplicableRating.PDVintage = '1';
		ApplicableRating.PDPenaltyFlag = 'true';
		ApplicableRating.RabobankMasterscaleRating = 'R14';
		
		
		
		ICSResponse.MultiplePD MultiplePD = new ICSResponse.MultiplePD();
		MultiplePD.MultipleYearPDItem = new List<ICSResponse.MultipleYearPDItem>();
		ICSResponse.MultipleYearPDItem MultipleYearPDItem = new ICSResponse.MultipleYearPDItem();
		MultipleYearPDItem.Percentage = '0.0182688';
		MultipleYearPDItem.Vintage = '1';
	 	
		MultiplePD.MultipleYearPDItem.add(MultipleYearPDItem);
		
		ApplicableRating.MultiplePD = MultiplePD;
		
		InternalLegalEntity.ApplicableRating = ApplicableRating;
		InternalLegalEntity.CREStatus = 'NOT REQUIRED';
		 
		ICSResponse.Default_x Default_x = new ICSREsponse.Default_x();
		Default_x.CurrentlyInDefaultIndicator = 'false';
		
		InternalLegalEntity.Default_x = Default_x;
		InternalLegalEntity.ExposureClass = 'OTH';
		InternalLegalEntity.Fields = Fields;
		InternalLegalEntity.FinancedAmountinEuro = '200.00';
		InternalLegalEntity.PDTreatmentExposureAmountInEuro = '100.00';
		
		ICSResponse.Id_x Id_x = new ICSResponse.Id_x();
		Id_x.SourceSystem = 'ICV';
		Id_x.IDValue = '1523413486635405';
		Id_X.IDType = 'LE_ID';			
		
		ICSResponse.Ids Ids = new ICSResponse.Ids();
		Ids.Id_x = new List<ICSResponse.Id_x>();
		Ids.Id_x.add(Id_x);
		
		InternalLegalEntity.Ids = Ids;
		InternalLegalEntity.PDRequiredTreatment = 'SCRD';
		
		ICSResponse.Phone Phone = new ICSResponse.Phone();
		Phone.PhoneNumber = '8882221111';
		Phone.PhoneType = 'WORK';
		
		InternalLegalEntity.Phone = Phone;
		InternalLegalEntity.RiskGradeRating = 'C';
		
		ICSResponse.AdditionalAttributes AdditionalAttributes = new ICSResponse.AdditionalAttributes();
		AdditionalAttributes.Attribute = new List<ICSResponse.Attribute>();
	
		ICSResponse.Attribute Attribute = new ICSResponse.Attribute();
		Attribute.AttributeName = 'MESSAGE-ID';
		Attribute.AttributeValue = '149dd399e2a24998e967d9569072871d';
		AdditionalAttributes.Attribute.add(Attribute);
		
		ICSResponse.Attribute Attribute2 = new ICSResponse.Attribute();
		Attribute2.AttributeName = 'TRANSACTION-ID';
		Attribute2.AttributeValue = 'CLND-2018-11-07T15:18:10.073Z';
		AdditionalAttributes.Attribute.add(Attribute2);
		
		ICSResponse.Results Results = new ICSResponse.Results();
		Results.ReturnStatus = 'S';
		
			
		ICSResponse.Link Link = new ICSResponse.Link();
		Link.SourceSystem = 'ICV';
		Link.LinkType = 'Commitment';
		Link.LinkValue = 'http://icvcrp1.dll.corp:9080/360View/commitment.360?ss=CLND&sci=QT-000000914&ct=A';
		
		ICSResponse.Link Link1 = new ICSResponse.Link();
		Link1.SourceSystem = 'ICV';
		Link1.LinkType = 'Legal_Entity';
		Link1.LinkValue = 'http://icvcrp1.dll.corp:9080/360View/commitment.360?ss=CLND&sci=QT-000000914&ct=A';
		
		ICSResponse.Link Link2 = new ICSResponse.Link();
		Link2.SourceSystem = 'ICV';
		Link2.LinkType = 'Application & Scoring Details';
		Link2.LinkValue = 'http://icvcrp1.dll.corp:9080/360View/commitment.360?ss=CLND&sci=QT-000000914&ct=A';
		
		ICSResponse.Links Links = new ICSResponse.Links();
		Links.Link = new List<ICSResponse.Link>();
		Links.Link.add(Link);
		Links.Link.add(Link1);
		Links.Link.add(Link2);
		
		Application.Links = Links;
		Application.MultipleYearEAD = MultipleYearEAD;
		Application.MultipleYearEL = MultipleYearEL;
		Application.MultipleYearLGD = MultipleYearLGD;
		
		ObtainDecisionResponse.Application = Application;
		
		Customer.InternalLegalEntity = InternalLegalEntity;
		
		ObtainDecisionResponse.Customer = Customer;
		
  		Input.ObtainDecisionResponse = null;
  		Input.ObtainManualDecisionResponse = null;
  		Input.SearchDataResponse = null;
  		
  		Input.AdditionalAttributes = AdditionalAttributes;
  		Input.Results = Results;
	
		ICSResponse.SubmitICSResponse(Input);
		
		Results.ReturnStatus = 'E';
		ICSResponse.SubmitICSResponse(Input);
		
		
   		
        System.Test.stopTest();
      	
     }	
     
    
     public static cllease__Lease_Account__c createContract() {
     	
     	cllease.TestHelper.createSeedDataForTesting();
     	
        // Setting Current System Date in Test Context
        Date currentSystemDate = Date.newInstance(2018, 03, 31);
        // 1. Pre-Setup
        clcommon__Fee_Definition__c  dummyFee   = cllease.Testhelper.createLeaseFee();
        clcommon__Fee_Set__c  dummyFeeSet       = cllease.Testhelper.createLeaseFeeSet();
        insert new clcommon__Fee_Junction__c( clcommon__Fee__c = dummyFee.ID, clcommon__Fee_Set__c  = dummyFeeSet.ID);

        clcommon__Fee_Definition__c  dummyFee2   = cllease.Testhelper.createLeaseFee();
        dummyFee2.clcommon__Type__c              = 'NSF Fees';
        dummyFee2.clcommon__Amount__c            = 25;
        update dummyFee2;

        insert new clcommon__Fee_Junction__c(clcommon__Fee__c = dummyFee2.ID, clcommon__Fee_Set__c  = dummyFeeSet.ID);
        insert new cllease__Transaction_Sub_Type__c(Name = 'NSF Fees');

        clcommon__Fee_Definition__c  latefee   = cllease.Testhelper.createLeaseFee();
        latefee.clcommon__Type__c              = 'Late Fees';
        latefee.clcommon__Calculation_Method__c= 'AMOUNT CALCULATED AS % OF RENT DUE';
        latefee.clcommon__Amount__c            = 25;
        update latefee;

        insert new clcommon__Fee_Junction__c(clcommon__Fee__c = latefee.ID, clcommon__Fee_Set__c  = dummyFeeSet.ID);
        insert new cllease__Transaction_Sub_Type__c(Name = 'Late Fees');



        cllease__Office_Name__c dummyOffice     = cllease.TestHelper.createOffice('Test Office', true);
        dummyOffice.cllease__Current_System_Date__c = currentSystemDate;
        dummyOffice.Dll_Seg1_Company__c         = '00101';
        dummyOffice.Dll_Seg2_Business_Unit__c   = '02';
        dummyOffice.Dll_Seg3_Department__c      = '3030';
        dummyOffice.Dll_Seg6__c                 = '00000';
        dummyOffice.Dll_Seg7__c                 = '0000';
        update dummyOffice;

        TestData.createPeriodsFor2018(dummyOffice.cllease__Calendar__c);

        Account dummyAccount = new Account(Name = 'Sample Account');
        insert dummyAccount;

        // 2. Creating Sample Product with rental and Dep Streams enabled
        cllease__Lease_Product__c dummyLP    = cllease.TestHelper.createLeaseProduct(dummyOffice, dummyFeeSet);
        dummyLP.cllease__Product_Sub_Type__c = cllease.LendingConstants.PRODUCT_SUB_TYPE_FN_LEASE;
        dummyLP.cllease__Use_Open_Acct_Period__c = true;
        update dummyLP;

        clcommon__Agreement__c dealerProgram =new clcommon__Agreement__c(Name='NewCo');
        insert dealerProgram;

        // 3.Creating Contract
        Date currentDate = Date.newInstance(2018, 01, 01);
        cllease__Lease_Account__c leaseAccount      = new cllease__Lease_Account__c();
        leaseaccount.cllease__Account__c            = dummyAccount.ID;
        leaseAccount.cllease__Lease_Product_Name__c = dummyLP.ID;
        leaseAccount.cllease__Contract_Date__c      = currentDate;
        leaseaccount.cllease__Financed_Amount__c    = 10000;
        //leaseaccount.cllease__Residual_Amount__c    = 1000;
        leaseAccount.cllease__Term__c               = 12;
        leaseaccount.Dealer_Program__c              = dealerProgram.Id;
 
        // 3.a Adding Equipments to Contract
        List<cllease__Contract_Equipment__c> contractEquipments = new List<cllease__Contract_Equipment__c>();
        contractEquipments.add(new cllease__Contract_Equipment__c(cllease__Estimated_Selling_Price__c = 10000,
                                        Evergreen_Depreciable_Cost__c = 950,
                                        Remaining_Evergreen_Depreciable_Cost__c = 950,
                                        Salvage_Value__c = 50,
                                        cllease__life_in_months__c = 14,
                                        cllease__Status__c = 'LEASED'));
      
        // 3.b Adding Payment Schedules to Contract
        List<cllease__Payment_Schedule__c> paymentDetails =  new List<cllease__Payment_Schedule__c>();
        paymentDetails.add(new cllease__Payment_Schedule__c(cllease__Sequence__c = 1, cllease__Number_Of_Payments__c = 12,
                           cllease__Frequency__c = cllease.LendingConstants.PAYMENT_FREQ_MONTHLY,
                           cllease__Payment_Amount__c = 1200, cllease__Payment_Date__c = currentDate,
                           cllease__Total_Payment__c = 1200));

        // 4. Calling ContractBuilder for Contract Creation
        cllease.ContractBuilder builder = new cllease.ContractBuilder(leaseAccount);
        builder.addChildObjects(contractEquipments);
        builder.addChildObjects(paymentDetails);
        String response = builder.createContract(cllease.LendingConstants.ContractCreateOption.ACTIVATECONTRACT);
        System.debug(LoggingLevel.ERROR, ' Response from Contract Creation: '+response);
        // Validating Contract Activation
        System.assert(response.containsIgnoreCase('Contract Creation Successful'));
        return builder.getContract();
     	
     }	
    
}