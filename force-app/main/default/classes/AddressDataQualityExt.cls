public with sharing class AddressDataQualityExt {
    public AddressDataQualityExt(ApexPages.StandardController stdController) {
     this.PageRenderer = new EDQ.PageRenderer(stdController, 'Address__c'); 
    }
    public EDQ.PageRenderer PageRenderer { get; private set; }
}