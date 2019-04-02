({
    // load or reload equipment associated with this application
    loadApplicationFees: function(component) {
        var action = component.get('c.getFees');
        action.setParams({
            applicationId: component.get('v.applicationId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set('v.fees', response.getReturnValue());
            } else if (state === 'ERROR') {
                let error = response.getError();
                if (error && error[0]) {
                    console.log(error[0].message);
                }
            }
        });
        $A.enqueueAction(action);
    },
    loadFieldOpts : function(component, field, opts){
        var action = component.get('c.getPicklistOptions');
        action.setParams({
            fieldName : field
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set(opts, response.getReturnValue());
            } else if (state === 'ERROR') {
                let error = response.getError();
                if (error && error[0]) {
                    console.log(error[0].message);
                }
            }
        });
        $A.enqueueAction(action);
    },
    // load or reload installation addresses for the application account
    loadPicklistOptions: function(component) {
        var helper = this;
        this.loadFieldOpts(component, 'Service_Escalate__c', 'v.serviceEscalateOpts');
        this.loadFieldOpts(component, 'Frequency__c', 'v.frequencyOpts');
        this.loadFieldOpts(component, 'Escalation_Frequency__c', 'v.escalateFreqOpts');
        this.loadFieldOpts(component, 'Escalate_Service_On__c', 'v.escalateOnOpts');
        this.loadFieldOpts(component, 'Escalation_Type__c', 'v.escalateTypeOpts');
        var action = component.get('c.getEquipmentOptions');
        action.setParams({
            applicationId : component.get('v.applicationId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set('v.equipmentOpts', response.getReturnValue());
            } else if (state === 'ERROR') {
                let error = response.getError();
                if (error && error[0]) {
                    console.log(error[0].message);
                }
            }
        });
        $A.enqueueAction(action);
    },
    addFees: function(component, feeId) {
        let applicationId = component.get('v.applicationId'),
            action = component.get('c.addFees');
            console.log('Application ID: '+applicationId);
        action.setParams({
            applicationId: applicationId,
            feeId: feeId
        });
        action.setCallback(this, function(response) {
            let state = response.getState(),
                onChangeAction = component.get('v.onchange');
            component.set('v.processing', false);
            if (state === 'SUCCESS') {
                let lookup = component.find('lookup');
                lookup.set('v.selection', []);
                this.loadApplicationFees(component);
                if (onChangeAction) {
                    $A.enqueueAction(onChangeAction);
                }
            } else if (state === 'ERROR') {
                console.log(response.getError());
            }
        });
        component.set('v.processing', true);
        $A.enqueueAction(action);
    },
    deleteFee: function(component, appFeeId) {
        let action = component.get('c.deleteFee');
        action.setParams({
            appFeeId: appFeeId
        });
        action.setCallback(this, function(response) {
            let state = response.getState(),
                onChangeAction = component.get('v.onchange');
            component.set('v.processing', false);
            if (state === 'SUCCESS') {
                this.loadApplicationFees(component);
                if (onChangeAction) {
                    $A.enqueueAction(onChangeAction);
                }
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
    updateFee: function (component, fee, changeType) {
//TODO: set error on field if update fails
        let action = component.get('c.updateFee');
        action.setParams({
            feeString: JSON.stringify(fee)
        });
        console.log('SETTING PARAMS');
        action.setCallback(this, function(response) {
            let state = response.getState(),
                onChangeAction = component.get('v.onchange');
            //component.set('v.processing', false);
            console.log('STATE: '+state);
            if (state === 'SUCCESS') {
                this.loadApplicationFees(component);
                if (onChangeAction) {
                    if (changeType) {
                        onChangeAction.setParam('changeType', changeType);
                    }
                    $A.enqueueAction(onChangeAction);
                }
            } else if (state === 'ERROR') {
                component.find('notifLib').showToast({
                    'variant': 'error',
                    'message': 'Changes Not Allowed on those Fields please Delete the Fee and Create New Fee',
                    'mode': 'sticky'
                });
                console.log(error[0].message);
            }
        });
        console.log('ABOUT TO ENQUEUE');
        //component.set('v.processing', true);
        $A.enqueueAction(action);
    },
    formatData: function(data) {
        //fail gracefully is data is malformed
        if(data['genesis__Equipment__r']) {
        	var manufacturer = data.genesis__Equipment__r.Manufacturer__c || '';
            var model = data.genesis__Equipment__r.genesis__Model__c || '';
            var serial = (!data.Serial_Number__c || data.Serial_Number__c == 'null') ? '':data.Serial_Number__c;
            return manufacturer + ' ' + model + ' (' + serial + ')';
        }
        return '';
    }
})