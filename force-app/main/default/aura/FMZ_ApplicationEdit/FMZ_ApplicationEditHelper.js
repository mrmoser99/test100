({
    loadApplicationId: function(component) {
        try {
            let search = decodeURIComponent(window.location.search.substring(1)),
                searchParams = search.split('&');
            for (let i = 0; i < searchParams.length; i++) {
                let param = searchParams[i].split('=');
                if (param[0] === 'id') {
                    component.set('v.applicationId', param[1]);
                    break;
                }
            }
        } catch (e) {
            console.log(e);
        }
    },

    getApplicationInfo: function(component) {
        try {
            let action = component.get('c.getApplicationInfo');
            action.setParams({
                applicationId: component.get('v.applicationId')
            });
            action.setCallback(this, function (response) {
                let state = response.getState(),
					dismiss = $A.get('e.force:closeQuickAction');
                if (state === 'SUCCESS') {
                    let application = response.getReturnValue();
                    component.set('v.application', application);
                } else if (state === 'ERROR') {
                    let error = response.getError();
                    if (error && error[0]) {
                        console.log(error[0].message);
                    }
                }
				dismiss.fire();
            });
            $A.util.removeClass(component, 'new-item');
            $A.enqueueAction(action);
        } catch (e) {
            console.log(e);
        }
    }

})