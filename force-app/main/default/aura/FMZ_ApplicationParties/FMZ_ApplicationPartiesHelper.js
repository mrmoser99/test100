({
    // load or reload equipment associated with this application
    loadLocations: function(component) {
        var action = component.get('c.getParties');
        action.setParams({
            applicationId: component.get('v.applicationId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set('v.parties', response.getReturnValue());
            } else if (state === 'ERROR') {
                let error = response.getError();
                if (error && error[0]) {
                    console.log(error[0].message);
                }
            }
        });
        $A.enqueueAction(action);
    },
    loadPartyTypes: function(component) {
        var action = component.get('c.getPicklistOptions');
        action.setParams({
            fieldName: 'genesis__Party_Type__c'
        });
        action.setStorable();
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set('v.partyTypes', response.getReturnValue());
            } else if (state === 'ERROR') {
                let error = response.getError();
                if (error && error[0]) {
                    console.log(error[0].message);
                }
            }
        });
        $A.enqueueAction(action);
    },
    addLocation: function(component, accountId) {
        let applicationId = component.get('v.applicationId'),
            action = component.get('c.addParty');
        action.setParams({
            applicationId: applicationId,
            accountId: accountId
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            component.set('v.processing', false);
            if (state === 'SUCCESS') {
                let lookup = component.find('lookup');
                lookup.set('v.selection', []);
                this.loadLocations(component);
            } else if (state === 'ERROR') {
                console.log(response.getError());
            }
        });
        component.set('v.processing', true);
        $A.enqueueAction(action);
    },
    deleteLocation: function(component, appPartyId) {
        let action = component.get('c.deleteParty');
        action.setParams({
            appPartyId: appPartyId
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            component.set('v.processing', false);
            if (state === 'SUCCESS') {
                this.loadLocations(component);
            } else if (state === 'ERROR') {
                let error = response.getError();
                if (error && error[0]) {
                    console.log(error[0].message);
                }
            }
        });
        component.set('v.processing', true);
        $A.enqueueAction(action);
    },
    updateLocation: function (component, appParty, changeType) {
        console.log('update party');
        let action = component.get('c.updateParty');
        action.setParams({
            appPartyString: JSON.stringify(appParty)
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === 'SUCCESS') {
            } else if (state === 'ERROR') {
                let error = response.getError();
                if (error && error[0]) {
                    console.log(error[0].message);
                }
            }
        });
        $A.enqueueAction(action);
    },
    arePartiesValid: function(component) {
        let partyTypes = component.find('partyType');
        if (Array.isArray(partyTypes)) {
            let partyTypesValid = component.find('partyType').reduce(function (validFields, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validFields && inputCmp.get('v.validity').valid;
            }, true);
            return partyTypesValid;
        } else {
            return partyTypes.get('v.validity').valid;
        }
    }

})