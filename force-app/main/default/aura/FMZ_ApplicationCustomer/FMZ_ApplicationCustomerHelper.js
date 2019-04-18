({
	loadAccount: function(component) {
		let applicationId = component.get('v.applicationId'),
			action = component.get('c.getAccount');
		action.setParams({
			applicationId: applicationId
		});
		action.setCallback(this, function (response) {
			let state = response.getState();
			if (state === 'SUCCESS') {
				component.set('v.customer', response.getReturnValue());
			} else if (state === 'ERROR') {
				let error = response.getError();
				if (error && error[0]) {
					console.log(error[0].message);
				}
			}
		});
		$A.enqueueAction(action);
	},
	isInputValid: function(component) {
		let inputFields = component.find('inputField'),
		    inputFieldsPhone = component.find('inputFieldPhone'),
		    inputFieldsEIN = component.find('inputFieldEIN'),
			inputFieldsValid = true;
		if (inputFields) {
			if(!Array.isArray(inputFields)){
				inputFields = [inputFields, inputFieldsEIN, inputFieldsPhone];
			}else{
			    inputFields.push(inputFieldsPhone);
			}
			inputFieldsValid = inputFields.reduce(function (validFields, inputCmp) {
				inputCmp.showHelpMessageIfInvalid();
				return validFields && inputCmp.get('v.validity').valid;
			}, true);
		}
		return inputFieldsValid;
	},
	updateAccount: function(component) {
		let account = component.get('v.customer'),
		    appId = component.get('v.applicationId'),
			action = component.get('c.updateAccount');
		console.log('!!!APP ID: '+appId);
		action.setParams({
			acct: account,
			applicationId: appId
		});
		action.setCallback(this, function (response) {
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
	}
})