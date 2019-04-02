/**
 * Created by samuelmeyers on 12/11/18.
 */
({
    doInit : function(component, event, helper){
        var action = component.get('c.getWelcomeMessage');
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === 'SUCCESS') {
                component.set('v.content', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})