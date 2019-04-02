({
	convertToLease: function(component, applicationId) {
		try {
			let p = new Promise($A.getCallback(function(resolve, reject) {
				let action = component.get('c.convert');
				action.setParams({
					applicationId: applicationId
				});
				action.setCallback(this, function (response) {
					let state = response.getState();
					if (state === 'SUCCESS') {
						let result = response.getReturnValue();
						if (result === 'Application is converted to contract successfully') {
							resolve(result);
						} else {
							reject(result);
						}
					} else if (state === 'ERROR') {
						let error = response.getError();
						if (error && error[0].message) {
							console.log(error[0].message);
						}
						reject(error);
					}
				});
				$A.enqueueAction(action);
			}));
			return p;
		} catch(e) {
			console.log(e);
		}
	},
	getLeaseId: function(component, applicationId) {
		try {
			let p = new Promise($A.getCallback(function(resolve, reject) {
				let action = component.get('c.getApplication');
				action.setParams({
					applicationId: applicationId
				});
				action.setCallback(this, function (response) {
					let state = response.getState();
					if (state === 'SUCCESS') {
						let app = response.getReturnValue();
						resolve(app.Lease_Number__c);
					} else if (state === 'ERROR') {
						let error = response.getError();
						if (error && error[0].message) {
							console.log(error[0].message);
						}
						reject(error);
					}
				});
				$A.enqueueAction(action);
			}));
			return p;
		} catch(e) {
			console.log(e);
		}
	}
})