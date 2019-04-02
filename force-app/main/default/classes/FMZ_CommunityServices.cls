public without sharing class FMZ_CommunityServices {

    // get wrapped field set information for lightning
    public static List<FMZ_CommunityServices.FieldSetMember> getFieldSetMembers(String sObjectName, String fieldSetName) {

        List<Schema.DescribeSObjectResult> describes = Schema.describeSObjects(new List<String> { sObjectName });
        Schema.FieldSet fieldset = describes[0].fieldsets.getMap().get(fieldSetName);

        List<FMZ_CommunityServices.FieldSetMember> result = new List<FMZ_CommunityServices.FieldSetMember>();
        for (Schema.FieldSetMember member : fieldset.getFields()) {
            result.add(new FieldSetMember(member));
        }

        return result;

    }

    public static List<PicklistOption> getPicklistOptions(String sObjectName, String fieldName){
        List<PicklistOption> options = new List<PicklistOption>();

        List<Schema.DescribeSObjectResult> describes = Schema.describeSObjects(new List<String> { sObjectName });
        Schema.DescribeFieldResult field = describes[0].fields.getMap().get(fieldName).getDescribe();

        List<Schema.PicklistEntry> entries = field.getPicklistValues();
        for(Schema.PicklistEntry entry : entries){
            if(entry.isActive()){
                System.debug('!!!'+entry.getLabel());
                options.add(new PicklistOption(entry.getLabel(), entry.getValue()));
            }
        }

        return options;
    }

    public class PicklistOption{
        public PicklistOption(String label, String value){
            this.label = label;
            this.value = value;
        }
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }

    public class FieldSetMember {
        public FieldSetMember(Schema.FieldSetMember field) {
            this.fieldPath = field.getFieldPath();
            this.required = field.getRequired();
        }
        @AuraEnabled public String fieldPath;
        @AuraEnabled public Boolean required;
    }

    public class Stage {
        @AuraEnabled public String objectName;
        @AuraEnabled public String iconName;
        @AuraEnabled public String label;
        @AuraEnabled public List<sObject> values;
        @AuraEnabled public String variant;

        public Stage(String objectName, String label, List<sObject> values, String variant, String iconName){
            this.objectName = objectName;
            this.iconName = iconName;
            this.label = label;
            this.values = values;
            this.variant = variant;
        }
    }

}