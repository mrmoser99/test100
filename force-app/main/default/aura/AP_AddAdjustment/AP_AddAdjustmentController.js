({
    
        doInit: function(component, event, helper) {
           var recordId = component.get('v.recordId');
          
            
       }, 
        handleSubmit: function(component,event,helper){
           var recordId = component.get('v.recordId');
           var action = component.get('c.addAdjustment'); 
           var invoiceId = component.get('v.invoiceId');
           //String recordId, String checkNumber, Decimal checkAmount Date paymentDate)
           action.setParams({
               invoiceId: component.get('v.invoiceId'),
               type:  component.find("typeIn").get("v.value"),
               debit: component.find("debitIn").get("v.value"),
               credit: component.find("creditIn").get("v.value")
           });
           console.log('hello world');
           action.setCallback(this,function(response) {
               var state = response.getState();
               var validationError = JSON.parse(response.getReturnValue());
               if (state == 'SUCCESS'){
                   if (validationError.Message){
                       component.find('notifLib').showToast({
                              'variant': 'error',
                              'message': validationError.Message,
                              'mode': 'pester'
                       });
                   }
                   else{
                       var msg='Adjustment Added!';
                       component.find('notifLib').showToast({
                              'variant': 'success',
                              'message': msg,
                              'mode': 'sticky'
                       });
                       
                       var navEvt = $A.get("e.force:navigateToSObject");
                       navEvt.setParams({
                           "recordId": invoiceId,
                           "slideDevName": "detail"
                       });
                       navEvt.fire();
                   }   
               }
               else if (state == 'ERROR'){
                   var errors = response.getError();
                   if (errors) {
                       if (errors[0] && errors[0].message) {
                           console.log("Error message: " +
                                    errors[0].message);
                           component.find('notifLib').showToast({
                              'variant': 'error',
                              'message':  errors[0].message,
                              'mode': 'pester'
                       });
                       }
                   } else {
                       console.log("Unknown error");
                   }
   
               }
   
           });
           component.set('v.processing', true);
           $A.enqueueAction(action);
        },
       handleCancel: function(component, event, helper) {
           let dismiss = $A.get('e.force:closeQuickAction');
           dismiss.fire();
       }
       
   
})
