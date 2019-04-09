({
    doInit: function(component, event, helper) {
       var recordId = component.get('v.recordId');
        
   }, 
    handleSubmit: function(component,event,helper){
       var recordId = component.get('v.recordId');
       var action = component.get('c.void'); 
       console.log('hell');
       action.setParams({
           recordId: recordId
       });
      
       action.setCallback(this,function(response) {
           var state = response.getState();
           console.log(state);
           var validationError = JSON.parse(response.getReturnValue());
           console.log(validationError);
           if (state == 'SUCCESS'){
               if (validationError.Message){
                   component.find('notifLib').showToast({
                          'variant': 'error',
                          'message': validationError.Message,
                          'mode': 'pester'
                   });
               }
               else{
                   var msg='Void Submittted!';
                   component.find('notifLib').showToast({
                          'variant': 'success',
                          'message': msg,
                          'mode': 'sticky'
                   });
                   
                   var navEvt = $A.get("e.force:navigateToSObject");
                   navEvt.setParams({
                       "recordId": recordId,
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