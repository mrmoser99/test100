({
    initialize : function(component){
        var action = component.get('c.getStages');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set('v.stages', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})