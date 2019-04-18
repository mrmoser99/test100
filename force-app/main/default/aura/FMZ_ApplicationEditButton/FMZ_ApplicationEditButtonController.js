({
    doInit: function(component, event, helper) {
		let recordId = component.get('v.recordId');
        try {
            let action = component.get('c.getApplication');
            action.setParams({
                applicationId: recordId
            });
            action.setCallback(this, function (response) {
                let state = response.getState();
                let application = response.getReturnValue();
                if (state === 'SUCCESS') {
                    if(application.genesis__Status__c != 'APPROVED - CONVERTED TO CONTRACT' && application.Lease_Number__c == null){
                        let navEvent = $A.get('e.force:navigateToURL');
                        navEvent.setParams({
                            url: '/application-edit?id=' + recordId
                        });
                        navEvent.fire();
                    }else{
                        component.find('notifLib').showToast({
                            'variant': 'error',
                            'message': 'This Application has already been converted, and is not available to edit.',
                            'mode': 'dismissible',
                            'duration': '5000'
                        });
                    }
                } else if (state === 'ERROR') {
                    let error = response.getError();
                    if (error && error[0].message) {
                        console.log(error[0].message);
                    }
                }
                let dismiss = $A.get('e.force:closeQuickAction');
                component.set('v.fired', true);
                dismiss.fire();
            });
            $A.enqueueAction(action);
        } catch(e) {
            console.log(e);
        }
    },
	closed: function(component, event, helper) {

	}
})