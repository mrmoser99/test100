({
    getApplicationInfo: function(component, showUpdate) {
        let action = component.get('c.getApplicationInfo');
        action.setParams({
            applicationId: component.get('v.applicationId')
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            component.set('v.recalculating', false);
            if (state === 'SUCCESS') {
                var application = response.getReturnValue();
                component.set('v.application', application);
                if (showUpdate) {
                    $A.util.addClass(component, 'new-item');
                }
            }
        });
        $A.util.removeClass(component, 'new-item');
        $A.enqueueAction(action);
    },
    getApprovalInfo: function(component, showUpdate) {
        let action = component.get('c.getApprovalInfo');
        action.setParams({
            applicationId: component.get('v.applicationId')
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === 'SUCCESS') {
                var approval = response.getReturnValue();
                component.set('v.approval', approval);
            }
        });
        $A.enqueueAction(action);
    },
    getLocations: function(component) {
        let action = component.get('c.getInstallLocations');
        action.setParams({
            applicationId: component.get('v.applicationId')
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === 'SUCCESS') {
                var locations = response.getReturnValue();
                component.set('v.locations', locations);
            }
        });
        $A.enqueueAction(action);

        let billAction = component.get('c.getBillingAddress');
        billAction.setParams({
            applicationId: component.get('v.applicationId')
        });
        billAction.setCallback(this, function (response) {
            let state = response.getState();
            if (state === 'SUCCESS') {
                var billing = response.getReturnValue();
                component.set('v.billing', billing);
            }
        });
        $A.enqueueAction(billAction);
    }
})