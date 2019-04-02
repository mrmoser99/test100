public with sharing class FMZ_AddressDataQualityExt {
    public EDQ.PageRenderer PageRenderer { get; private set; }
    public transient Component.Apex.PageBlock PageBody {get; set;}

    @testVisible
    private List<String> outputFields = new List<String>{
            '{!Address__c.Address_Line_1__c}',
            '{!Address__c.Address_Line_2__c}',
            '{!Address__c.City__c}',
            '{!Address__c.State__c}',
            '{!Address__c.County__c}',
            '{!Address__c.Zip_Code__c}',
            '{!Address__c.Country__c}',
            '{!Address__c.Validation_Status__c}',
            '{!Address__c.Install_At__c}'
    };

    public FMZ_AddressDataQualityExt(ApexPages.StandardController stdController) {
        this.PageRenderer = new EDQ.PageRenderer(stdController, 'Address__c');
        this.PageBody = PageRenderer.GetPageBody();

        for (Integer a = 0; a < this.PageBody.childComponents.size(); a++) {
            for (Integer b = 0; b < this.PageBody.childComponents[a].childComponents.size(); b++) {
                for (Integer c = 0; c < this.PageBody.childComponents[a].childComponents[b].childComponents.size(); /* No Action*/) {
                    try {
                        Component.Apex.InputField field = (Component.Apex.InputField) this.PageBody.childComponents[a].childComponents[b].childComponents[c];
                        if (outputFields.contains(field.expressions.value)) {
                            System.debug('!!! Field Required: ' + field.expressions.required);
                            c++;
                        } else {
                            System.debug('!!! Field Required: ' + field.expressions.required);
                            this.PageBody.childComponents[a].childComponents[b].childComponents.remove(c);
                        }
                    } catch (exception e) {
                        c++;
                    }

                }
            }
        }
    }
}