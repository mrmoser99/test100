public with sharing class AddressDataQualityExt {
    public AddressDataQualityExt(ApexPages.StandardController stdController) {
        this.PageRenderer = new EDQ.PageRenderer(stdController, 'Address__c');
        System.debug('*** PageRenderer: '+PageRenderer);
        System.debug('*** PageRenderer.PageBody: '+PageRenderer.GetPageBody());
        System.debug('*** PageRenderer.PageBody.childComponents: '+PageRenderer.GetPageBody().childComponents);
        System.debug('*** PageRenderer.PageBody.expressions: '+PageRenderer.GetPageBody().expressions);
        System.debug('*** PageRenderer.PageBody.facets: '+PageRenderer.GetPageBody().facets);
    }
    public EDQ.PageRenderer PageRenderer { get; private set; } 
}