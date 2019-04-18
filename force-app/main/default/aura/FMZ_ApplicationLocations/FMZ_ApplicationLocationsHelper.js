({
    // load or reload locations associated with this application
    loadLocations: function(component) {
        let action = component.get('c.getLocations');
        action.setParams({
            applicationId: component.get('v.applicationId')
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === 'SUCCESS') {
                component.set('v.locations', response.getReturnValue());
            } else if (state === 'ERROR') {
                let error = response.getError();
                if (error && error[0]) {
                    console.log(error[0].message);
                }
            }
        });
        $A.enqueueAction(action);
    },
    getAccountId: function(component){
        let action = component.get('c.getAppAccount');
        action.setParams({
            applicationId: component.get('v.applicationId')
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === 'SUCCESS') {
                component.set('v.accountId', response.getReturnValue());
            } else if (state === 'ERROR') {
                let error = response.getError();
                if (error && error[0]) {
                    console.log(error[0].message);
                }
            }
        });
        $A.enqueueAction(action);
    },
    deleteLocation: function(component, addressId) {
        let action = component.get('c.deleteLocation');
        action.setParams({
            addressId: addressId
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
    updateLocation: function (component, address) {
        console.log('update location');
        let action = component.get('c.updateLocation');
        action.setParams({
            addressString: JSON.stringify(address)
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            console.log(state);
            if (state === 'SUCCESS') {
                this.locationsHaveChanged();
            } else if (state === 'ERROR') {
                let error = response.getError();
                if (error && error[0]) {
                    console.log(error[0].message);
                }
            }
        });
        $A.enqueueAction(action);
    },
    areLocationsValid: function(component) {
        let installs = component.find('install');
        if (Array.isArray(installs)) {
            let installsCount = installs.reduce(function (count, inputCmp) {
                return count + (inputCmp.get('v.checked') ? 1 : 0);
            }, 0);
            console.log('!!!installCount: '+installsCount);
            component.set('v.error', 'There must be at lease one Install Location checked.');
            return installsCount > 0;
        } else {
            console.log('!!!installs.checked: '+installs.get('v.checked'));
            component.set('v.error', 'There must be at lease one Install Location checked.');
            return installs.get('v.checked');
        }
    },
    locationsHaveChanged: function() {
        var evt = $A.get('e.c:FMZ_Application_Refresh');
        evt.setParams({
            source: 'FMZ_ApplicationLocations'
        });
        evt.fire();
    }

})