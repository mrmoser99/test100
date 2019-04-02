public class AddressNonPageOverrideExtension {
	public AddressNonPageOverrideExtension(ApexPages.StandardController stdController) {
        PageRenderer = new EDQ.NonOverridePageRenderer(stdController, 'Address__c', touchpointNames);
    }
     public EDQ.NonOverridePageRenderer PageRenderer {get; private set; }
     private Set<string> touchpointNames = new Set<string> {};
}