({
    doInit: function(component, event, helper) {
        helper.loadLocations(component);
        helper.getAccountId(component);
    },

    // search for accounts (parties)
    lookupSearch: function(component, event, helper) {
        let lookup = component.find('lookup');
        // get the search server action
        const serverSearchAction = component.get('c.search');
        // pass the action to the Lookup component by its search method
        lookup.search(serverSearchAction);
        $A.util.removeClass(lookup, 'slds-has-error');
        component.set('v.error', null)
    },

    // add location
    handleAdd: function(component, event, helper) {
        var applicationId = component.get('v.applicationId'),
            lookup = component.find('lookup'),
            selection = lookup.get('v.selection');
        $A.util.removeClass(lookup, 'slds-has-error');
        component.set('v.error', null);
        helper.addLocation(component, selection[0].id);
    },

    handleNewAddress: function(component, event, helper){
        helper.loadLocations(component);
        helper.locationsHaveChanged();
    },

    // validate required fields and at least one install location
    saveAndValidate: function(component, event, helper) {
        let locations = component.get('v.locations'),
            lookup = component.find('lookup');
        try {
            if (!Boolean(locations) || locations.length === 0) {
                $A.util.addClass(lookup, 'slds-has-error');
                component.set('v.error', 'Please add an install location to the application.');
                return false;
            } else if (!helper.areLocationsValid(component)) {
                return false;
            } else {
                $A.util.removeClass(lookup, 'slds-has-error');
                component.set('v.error', null);
                return true;
            }
        } catch (e) {
            console.log(e);
        }
    },

    // mark components with location-changed css class
    handleChange: function(component, event, helper) {
        console.log('handle change');
        try {
            let inputControl = event.getSource();
            $A.util.addClass(inputControl, 'location-changed');
        } catch (e) {
            console.log(e);
        }
    },

    // do update on blur if the field is changed
    handleBlur: function(component, event, helper) {
        console.log('handle blur');
        try {
            let inputControl = event.getSource(),
                localId = inputControl.getLocalId(),
                isChanged = $A.util.hasClass(inputControl, 'location-changed')
                    || localId === 'install',
                globalId = inputControl.getGlobalId(),
                inputControls = component.find(localId),
                locations = component.get('v.locations'),
                newValue = inputControl.get('v.value'),
                question = 'If any equipment is using this address, the equipment address will be changed to blank. Would you like to continue?';

                if(!newValue && !confirm(question)){
                    inputControl.set('v.value', true);
                    return;
                }

                var validity = inputControl.get('v.validity'),
                isValid = Boolean(validity) ? validity.valid : true,
                addressId,
                addressUpdate = {},
                i;

            if (!isChanged || !isValid) {
                return;
            }

            if (Array.isArray(inputControls)) {
                for (i = 0; i < inputControls.length; i++) {
                    if (globalId === inputControls[i].getGlobalId()) {
                        addressId = locations[i].Id;
                        break;
                    }
                }
            } else {
                if (globalId === inputControls.getGlobalId()) {
                    addressId = locations[0].Id;
                }
            }

            if (!addressId) {
                return;
            }

            addressUpdate.Id = addressId;
            switch(localId) {
                case 'install':
                    addressUpdate.Install_At__c = newValue;
                    break;
                default:
                    return;
            }

            helper.updateLocation(component, addressUpdate, localId);

            $A.util.removeClass(inputControl, 'location-changed');

        } catch (e) {
            console.log(e);
        }
    }

})