public without sharing class FMZ_CreditApprovalDataQualityExt {
    public EDQ.PageRenderer PageRenderer { get; private set; }
    public transient Component.Apex.PageBlock PageBody {get; set;}

    private List<String> outputFields = new List<String>();

    public FMZ_CreditApprovalDataQualityExt(ApexPages.StandardController stdController) {
        this.PageRenderer = new EDQ.PageRenderer(stdController, 'genesis__Quick_Quotes__c');
        this.PageBody = PageRenderer.GetPageBody();

        List<FMZ_CommunityServices.FieldSetMember> fields = FMZ_CommunityServices.getFieldSetMembers('genesis__Quick_Quotes__c', 'FMZ_AddressFields');

        for (FMZ_CommunityServices.FieldSetMember fsm : fields) {
            this.outputFields.add('{!genesis__Quick_Quotes__c.' + fsm.fieldPath + '}');
        }

        for (Integer a = 0; a < this.PageBody.childComponents.size(); a++) {
            System.debug('!!![a]'+this.PageBody.childComponents[a]);
            for (Integer b = 0; b < this.PageBody.childComponents[a].childComponents.size(); b++) {
                System.debug('!!![a][b]'+this.PageBody.childComponents[a].childComponents[b]);
                for (Integer c = 0; c < this.PageBody.childComponents[a].childComponents[b].childComponents.size(); /* No Action*/) {
                    try {
                        System.debug('!!![a][b][c]'+this.PageBody.childComponents[a].childComponents[b].childComponents[c]);
                        Component.Apex.InputField field = (Component.Apex.InputField) this.PageBody.childComponents[a].childComponents[b].childComponents[c];
                        if (outputFields.contains(field.expressions.value)) {
                            System.debug('!!! Field Required: '+field.expressions.required);
                            c++;
                        } else {
                            System.debug('!!! Field Required: '+field.expressions.required);
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