public without sharing class FMZ_ApplicationDocumentsController {
	public static String CONGA_SUCCESS_MESSAGE = 'SUCCESS';
	public static String LEASE_AGREEMENT_CATEGORY = 'Lease Documents';

	@AuraEnabled
	public static genesis__Applications__c getApplication(Id applicationId) {

		genesis__Applications__c result = [
			SELECT Id, Contract_Signer__c, Contract_Signer_Last_Name__c,
				Contract_Signer_Title__c, Dealer_Invoice_Number__c, Dealer_Invoice_Date__c
			FROM genesis__Applications__c
			WHERE Id = :applicationId
		];

		return result;

	}

	@AuraEnabled
	public static List<Attachment> getDocuments(Id applicationId) {

		List<clcommon__Category_Attachment_Association__c> categorizedDocuments = [
			SELECT Id, clcommon__Attachment_Id__c, clcommon__Document_Category__r.clcommon__Category_Name__c
			FROM clcommon__Category_Attachment_Association__c
			WHERE clcommon__Document_Category__r.genesis__Application__c = :applicationId
		];

		List<Attachment> documents = [
			SELECT Id, Name, CreatedDate, Description
			FROM Attachment
			WHERE ParentId = :applicationId
			ORDER BY CreatedDate DESC
		];

		Map<Id, Attachment> docMap = new Map<Id, Attachment>(documents);

		for (clcommon__Category_Attachment_Association__c c : categorizedDocuments) {
			if (String.isNotBlank(c.clcommon__Attachment_Id__c)
				&& String.isNotBLank(c.clcommon__Document_Category__r.clcommon__Category_Name__c)) {
				Attachment doc = docMap.get(c.clcommon__Attachment_Id__c);
				if (doc != null) {
					doc.Description = c.clcommon__Document_Category__r.clcommon__Category_Name__c;
				}
			}
		}

		return documents;

	}

	@AuraEnabled
	public static void updateApplication(genesis__Applications__c app) {
		update app;
	}

	@AuraEnabled
	public static String generateLeaseDocument(Id applicationId) {

		Id communityId = Network.getNetworkId();
		String url = Network.getLoginUrl(communityId);
		System.debug(url);

		return /* CongaImpl. */ generateLeaseDocument2(applicationId);
	}

	//https://dev-newcodev.cs66.force.com/services/Soap/u/39.0/00D0v000000D3bK&

	static string version = DLLNewCoConstants.SOAP_VERSION;
	//static string partnerUrl = Url.getSalesforceBaseUrl().toExternalForm() + version + UserInfo.getOrganizationId().subString(0, 15);
	static String partnerUrl = 'https://dev-newcodev.cs66.force.com/dealer/services/Soap/u/39.0/00D0v000000D3bK';
	static string congaUrl;

	public static string generateLeaseDocument2(string recordId) {
		// getting conga query and templet URL id's from custom settings
		string LeaseQryID = CongaURL_Settings__c.getInstance().LeaseQryID__c;
		string LeaseEQID = CongaURL_Settings__c.getInstance().LeaseEQID__c;
		string LeaseTmpID = CongaURL_Settings__c.getInstance().LeaseTmpID__c;

		congaUrl = Label.Conga_URL + userinfo.getsessionId() + '&serverUrl=' + partnerUrl + '&QueryId=[LeaseAgreement]' +
			LeaseQryID + ',[EQ]' + LeaseEQID + '%3Fpv0%3D' + recordId + '&TemplateId=' + LeaseTmpID +
			'&DS7=1&OFN=LeaseAgreement&id=' + recordId.subString(0, 15);

		System.debug('congaUrl' + congaUrl);
		return getCalloutToConga(congaUrl);
	}
	public static string getCalloutToConga(string url) {
		// Instantiate a new http object
		Http h = new Http();
		// Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
		HttpRequest req = new HttpRequest();
		req.setEndpoint(url);
		req.setMethod('GET');
		req.setTimeout(60000);
		// Send the request, and return a response
		HttpResponse res = h.send(req);
		if (res.getStatusCode() != 200) {
			return res.getStatus();
		} else if (!Pattern.matches('[a-zA-Z0-9]{18}', res.getBody())) {
			return res.getBody();
		}
		return 'Document Created successfully!!';


	}
}