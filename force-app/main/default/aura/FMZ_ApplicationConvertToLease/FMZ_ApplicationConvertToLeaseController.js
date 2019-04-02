({
	doInit: function(component, event, helper) {
		let applicationId = component.get('v.recordId');
		helper.convertToLease(component, applicationId)
			.then($A.getCallback(function(result) {
				return helper.getLeaseId(component, applicationId);
			}))
			.then($A.getCallback(function(result) {
				return new Promise($A.getCallback(function(resolve, reject) {
					try {
						component.find('notifLib').showToast({
							'variant': 'success',
							'message': 'Funding request successfully created',
							'mode': 'dismissible',
							'duration': '10000'
						});
						let navEvent = $A.get("e.force:navigateToSObject");
						navEvent.setParams({
							recordId: result,
							slideDevName: 'detail'
						});
						navEvent.fire();
						let dismiss = $A.get('e.force:closeQuickAction');
						dismiss.fire();
						resolve();
					} catch (e) {
						reject(e);
					}
				}));
			}))
			.catch($A.getCallback(function(error) {
console.log(error);
				let message = 'Unknown Error';
				if (typeof error == 'string') {
					message = error;
				} else if (error && error[0]) {
					message = error[0].message;
				}
				component.find('notifLib').showToast({
					'variant': 'error',
					'message': message,
					'mode': 'dismissable',
					'duration': '10000'
				});
				let dismiss = $A.get('e.force:closeQuickAction');
				dismiss.fire();
			}))
	}
})