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
		    inputFieldsEIN = component.find('inputFieldEIN'),
		    inputFieldsPhone = component.find('inputFieldPhone'),
			inputFieldsValid = true;
		if (inputFields) {
			if(!Array.isArray(inputFields)){
				inputFields = [inputFields, inputFieldsEIN, inputFieldsPhone];
			}else{
			    inputFields.push(inputFieldsPhone);
			    inputFields.push(inputFieldsEIN);
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
			action = component.get('c.updateAccount');
		action.setParams({
			acct: account
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