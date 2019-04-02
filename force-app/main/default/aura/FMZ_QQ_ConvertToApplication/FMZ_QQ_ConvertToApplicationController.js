({
    doInit: function(component, event, helper) {
        var recId = component.get("v.recordId");
        var action = component.get('c.convertToApplication');
        action.setParams({
            quoteId: recId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === 'SUCCESS') {
                console.log(response.getReturnValue());
                var convertResponse = JSON.parse(response.getReturnValue());
                console.log('convertResponse: '+convertResponse);
                console.log('HERE');
                if(convertResponse.Status){
                    console.log('Status: '+convertResponse.Status);
                    if(convertResponse.Status == "ERROR"){
                        component.find('notifLib').showToast({
                            'variant': 'error',
                            'message': convertResponse.Message,
                            'mode': 'sticky'
                        });
                    }else{
                        component.find('notifLib').showToast({
                            'variant': 'success',
                            'message': 'Successfully Converted to Application!',
                            'mode': 'dismissible',
                            'duration': '10000'
                        });
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": '/application-edit?id='+convertResponse.Status
                        });
                        urlEvent.fire();
                        let dismiss = $A.get('e.force:closeQuickAction');
                        dismiss.fire();
                    }
                }
                else if(convertResponse.status){
                    console.log('status: '+convertResponse.status);
                    if(convertResponse.status == "ERROR"){
                        component.find('notifLib').showToast({
                            'variant': 'error',
                            'message': convertResponse.errorMessage,
                            'mode': 'sticky'
                        });
                    }
                }
                let dismiss = $A.get('e.force:closeQuickAction');
                dismiss.fire();
            }else{
                component.find('notifLib').showToast({
                    'variant': 'error',
                    'message': 'ERROR: An error has occurred processing your request. Try again later, or report this issue to a System Administrator.',
                    'mode': 'sticky'
                });
                let dismiss = $A.get('e.force:closeQuickAction');
                dismiss.fire();
            }
        });
        $A.enqueueAction(action);
    }
})