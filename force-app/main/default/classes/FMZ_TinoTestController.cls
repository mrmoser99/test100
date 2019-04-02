public without sharing class FMZ_TinoTestController {

	public EDQ.PageRenderer PageRenderer { get; private set; }
	public transient Component.Apex.PageBlock PageBody {get; set;}

	private List<String> outputFields = new List<String>();

	public List<String> components { get; private set; }

	public FMZ_TinoTestController(ApexPages.StandardController stdController) {
		try {
			components = new List<String>();

			this.PageRenderer = new EDQ.PageRenderer(stdController, 'genesis__Quick_Quotes__c');
			components.add(String.valueOf(this.PageRenderer));

if (Network.getNetworkId() == null) {
			this.PageBody = PageRenderer.GetPageBody();

			List<FMZ_CommunityServices.FieldSetMember> fields = FMZ_CommunityServices.getFieldSetMembers('genesis__Quick_Quotes__c', 'FMZ_AddressFields');

			for (FMZ_CommunityServices.FieldSetMember fsm : fields) {
				this.outputFields.add('{!genesis__Quick_Quotes__c.' + fsm.fieldPath + '}');
			}

			components.add(String.valueOf(this.PageBody));

			for (Integer a = 0; a < this.PageBody.childComponents.size(); a++) {
				components.add('----' + String.valueOf(this.PageBody.childComponents[a]) + ' ' + PageBody.childComponents[a].id);
				for (Integer b = 0; b < this.PageBody.childComponents[a].childComponents.size(); b++) {
					components.add('--------' + String.valueOf(this.PageBody.childComponents[a].childComponents[b]) + ' ' + this.PageBody.childComponents[a].childComponents[b].id);
					for (Integer c = 0; c < this.PageBody.childComponents[a].childComponents[b].childComponents.size(); ) {
						try {
							components.add('------------' + String.valueOf(this.PageBody.childComponents[a].childComponents[b].childComponents[c])
								+ ' ' + this.PageBody.childComponents[a].childComponents[b].childComponents[c].id);
							Component.Apex.InputField field = (Component.Apex.InputField) this.PageBody.childComponents[a].childComponents[b].childComponents[c];
components.add(field.expressions.value);
components.add(field.expressions.required);
components.add(field.expressions.styleClass);
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
			/*
			PageBody = new Component.Apex.PageBlock();

			PageBody.childComponents.add(new Component.Apex.PageBlockSection());

			Component.Apex.InputField addressLine = new Component.Apex.InputField();
			addressLine.id = 'genesis__Address_Line_1__c';
			addressLine.expressions.value = '{!genesis__Quick_Quotes__c.genesis__Address_Line_1__c}';
			PageBody.childComponents[0].childComponents.add(addressLine); */

		} catch (Exception e) {
			ApexPages.addMessages(e);
			System.debug(e.getStackTraceString());
		}
	}
}