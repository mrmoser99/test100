({
    doInit : function(component, event, helper) {
        component.set('v.processing', false);
    },
    findMatchingAddresses : function(component, event, helper){
        var action = component.get('c.getMatches');
        var addressSearchString = component.find('addressLine1').get('v.value');
        action.setParams({
            'addressString': addressSearchString
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var matches = response.getReturnValue();
                component.set('v.matches', matches);
                var cmpTarget = component.find('matchesOverlay');
                $A.util.removeClass(cmpTarget, 'slds-hidden');
            }
        });
        $A.enqueueAction(action);
    },
    selectMatch : function(component, event, helper) {
        var cmpTarget = component.find('matchesOverlay');
        $A.util.addClass(cmpTarget, 'slds-hidden');
        var ctarget = event.currentTarget;
        var formatUrl = ctarget.dataset.value;

        var action = component.get('c.getFormat');
        action.setParams({
            'formatUrl': formatUrl
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === 'SUCCESS') {
                var formattedAddress = response.getReturnValue();
                helper.populateAddressFields(component, formattedAddress);
            }
        });
        $A.enqueueAction(action);
    },
    handleCreate: function(component, event, helper) {
        var address = {
            'Account__c': component.get('v.addressId'),
            'Address_Line_1__c': component.find('addressLine1').get('v.value'),
            'City__c': component.find('city').get('v.value'),
            'County__c': component.find('county').get('v.value'),
            'State__c': component.find('state').get('v.value'),
            'Zip_Code__c': component.find('postalCode').get('v.value'),
            'Country__c': component.find('country').get('v.value'),
            'Validation_Status__c': component.find('validStatus').get('v.value'),
            'Validation_Time_Stamp__c': component.find('validTime').get('v.value')
        };

        var isValid = helper.isValid(address);

        if(isValid){
            var action = component.get('c.createAddress');
            action.setParams({
                'address': address
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log(state);
                if (state === 'SUCCESS') {
                    var appEvent = $A.get("e.c:FMZ_NewCustomerAddress");
                    appEvent.fire();
                    let dismiss = $A.get('e.force:closeQuickAction');
                    dismiss.fire();
                }
            });
            $A.enqueueAction(action);
        }else{
            component.set('v.isInvalid', true);
        }

    },
    handleCancel: function(component, event, helper) {
        let dismiss = $A.get('e.force:closeQuickAction');
        dismiss.fire();
    }
})