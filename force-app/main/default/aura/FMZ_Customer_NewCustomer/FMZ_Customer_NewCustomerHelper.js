({
    // load fields from the field set
    loadFields: function(component) {
console.log('loadFields');
        var action = component.get('c.getCustomerFields');
        action.setParams({
            fieldsetName: 'FMZ_NewCustomer'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set('v.fields', response.getReturnValue());
                component.set('v.processing', false);
            }
        });

        component.set('v.processing', true);

        $A.enqueueAction(action);
    },

    // check for required fields
    isValid: function(component) {
        var result = true,
            fields = component.get('v.fields'),
            inputField = component.find('inputField');
        for (var i = 0; i < fields.length; i++) {
            if (fields[i].required && !Boolean(inputField[i].get('v.value'))) {
                $A.util.addClass(inputField[i], 'slds-has-error');
                result = false;
            }
        }
        component.set('v.isInvalid', !result);
        return result;
    },

    newAddress: function(component, event, helper){
        var params = event.getParams();
        var address = {
            "Address_Line_1__c" : params.addressLine1,
            "Address_Line_2__c" : params.addressLine2,
            "City__c" : params.city,
            "State__c" : params.state,
            "County__c" : params.county,
            "Zip_Code__c" : params.zipcode,
            "Country__c" : params.country
        };
        var format = address.Address_Line_1__c + '\n';
        if(address.Address_Line_2__c != null && address.Address_Line_2__c != ''){
            format += address.Address_Line_2__c + '\n';
        }
        format += address.City__c+', '+address.State__c+' '+address.Zip_Code__c;

        console.log(format);
        console.log(address);
        component.set("v.formattedAddress", format);
        component.set("v.address", address);
    }
})