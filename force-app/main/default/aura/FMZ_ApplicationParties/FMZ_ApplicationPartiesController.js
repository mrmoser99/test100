({
    doInit: function(component, event, helper) {
        helper.loadLocations(component);
        helper.loadPartyTypes(component);
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

    // add party
    handleAdd: function(component, event, helper) {
        var applicationId = component.get('v.applicationId'),
            lookup = component.find('lookup'),
            selection = lookup.get('v.selection');
        $A.util.removeClass(lookup, 'slds-has-error');
        component.set('v.error', null);
        helper.addLocation(component, selection[0].id);
//TODO: default to customer
    },

    // delete party
    handleDelete: function(component, event, helper) {
        let deleteBtn = event.getSource().getGlobalId(),
            deleteButtons = component.find('deleteBtn'),
            parties = component.get('v.parties'),
            i;
        try {
            if (Array.isArray(deleteButtons)) {
                for (i = 0; i < deleteButtons.length; i++) {
                    if (deleteBtn === deleteButtons[i].getGlobalId()) {
                        helper.deleteLocation(component, parties[i].Id);
                        break;
                    }
                }
            } else {
                if (deleteBtn === deleteButtons.getGlobalId()) {
                    helper.deleteLocation(component, parties[0].Id)
                }
            }
        } catch(e) {
            console.log(e);
        }
    },

    // validate required fields and at least one party
    saveAndValidate: function(component, event, helper) {
        let parties = component.get('v.parties'),
            lookup = component.find('lookup');
        try {
            if (!Boolean(parties) || parties.length === 0) {
                $A.util.addClass(lookup, 'slds-has-error');
                component.set('v.error', 'Please add customer to the application.');
                return false;
            } else if (!helper.arePartiesValid(component)) {
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

    // mark components with party-changed css class
    handleChange: function(component, event, helper) {
        console.log('handle change');
        try {
            let inputControl = event.getSource();
            $A.util.addClass(inputControl, 'party-changed');
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
                isChanged = $A.util.hasClass(inputControl, 'party-changed')
                    || localId === 'partyType',
                globalId = inputControl.getGlobalId(),
                inputControls = component.find(localId),
                parties = component.get('v.parties'),
                newValue = inputControl.get('v.value'),
                validity = inputControl.get('v.validity'),
                isValid = Boolean(validity) ? validity.valid : true,
                partyId,
                partyUpdate = {},
                i;

            if (!isChanged || !isValid) {
                return;
            }

            if (Array.isArray(inputControls)) {
                for (i = 0; i < inputControls.length; i++) {
                    if (globalId === inputControls[i].getGlobalId()) {
                        partyId = parties[i].Id;
                        break;
                    }
                }
            } else {
                if (globalId === inputControls.getGlobalId()) {
                    partyId = parties[0].Id;
                }
            }

            if (!partyId) {
                return;
            }

            partyUpdate.Id = partyId;

            switch(localId) {
                case 'partyType':
                    partyUpdate.genesis__Party_Type__c = newValue;
                    break;
                default:
                    return;
            }

            helper.updateLocation(component, partyUpdate, localId);

            $A.util.removeClass(inputControl, 'party-changed');

        } catch (e) {
            console.log(e);
        }
    }

})