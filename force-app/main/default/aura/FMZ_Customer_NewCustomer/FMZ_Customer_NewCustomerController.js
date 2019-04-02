({
    doInit: function(component, event, helper) {
        helper.loadFields(component); 
    },
    handleLoad: function(component, event, helper) {
        //var recordUi = event.getParam('recordUi');
        $A.util.addClass(component, 'is-loaded');
    },
    handleSubmit: function(component, event, helper) {
        var fields = event.getParam('fields'),
            isValid = helper.isValid(component);
        component.set('v.isInvalid', !isValid);
        if (!isValid) {
            return;
        }
        event.preventDefault();
        var action = component.get('c.submitAccount');
        component.set("v.account", fields);
        action.setParams({
            acc: fields,
            address: component.get("v.address")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var accId = response.getReturnValue();
                var appEvent = $A.get("e.c:FMZ_NewCustomer");
                 appEvent.setParams({
                     "id" : accId,
                     "name" : fields['Name']
                 });
                 appEvent.fire();
                 let dismiss = $A.get('e.force:closeQuickAction');
                 dismiss.fire();
            }
        });
        $A.enqueueAction(action);
         ////component.find('addressForm').submit(fields);
    },
    handleSuccess: function(component, event, helper) {
        var record = event.getParam('response');
        helper.submitForApproval(component, record.id);
    },
    handleError: function(component, event, helper) {

        component.set('v.isInvalid', false);

        if (event.getName() === 'error') {

            var error = event.getParam('error');

            console.log(error.message);

            // top level error messages
            error.data.output.errors.forEach(
                function(msg) { console.log(msg.errorCode);
                    console.log(msg.message); }
            );

            // field specific error messages
            Object.keys(error.data.output.fieldErrors).forEach(function(field) {
                error.data.output.fieldErrors[field].forEach(
                    function(msg) { console.log(msg.fieldName);
                        console.log(msg.errorCode);
                        console.log(msg.message); }
                )
            });
        }
    },
    handleCancel: function(component, event, helper) {
        let dismiss = $A.get('e.force:closeQuickAction');
        dismiss.fire();
    },
    handleNewAddress: function(component, event, helper) {
        console.log('Handling new Address');
        helper.newAddress(component, event, helper);
    }
})