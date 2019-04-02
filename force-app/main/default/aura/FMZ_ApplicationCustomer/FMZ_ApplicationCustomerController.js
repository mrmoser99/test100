({
	doInit: function(component, event, helper) {
		helper.loadAccount(component);
	},
	saveAndValidate: function(component, event, helper) {
		try {
			if (!helper.isInputValid(component)) {
				return false;
			} else {
				helper.updateAccount(component);
				return true;
			}
		} catch (e) {
			console.log(e);
		}
	},
    navToAccount: function(component, event, helper){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": '/detail/'+component.get('v.customer').Id,
          "isredirect": true
        });
        urlEvent.fire();
    }
})