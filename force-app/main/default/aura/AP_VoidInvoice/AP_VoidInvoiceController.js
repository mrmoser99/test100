({
    doInit: function(component, event, helper) {
       var recordId = component.get('v.recordId');
       var actions = [
            { label: 'Delete', name: 'delete' }
        ];
       
       component.set('v.columns', [
        {label: 'Charge/Bill Id', fieldName: 'chargeId', type: 'text'},
        {label: 'Type', fieldName: 'fee', type: 'text'},
        {label: 'Amount Due', fieldName: 'feeAmount', type: 'decimal'},
        {label: 'Tax Due', fieldName: 'taxAmount', type: 'decimal'},
        ]);


        component.set('v.columnsA', [
            {label: 'Type', fieldName: 'Adjustment_Category__c', type: 'text'}, 
            {label: 'Debit', fieldName: 'Debit__c', type: 'currency', cellAttributes: { alignment: 'left' }},
            {label: 'Credit', initialWidth:120, fieldName: 'Credit__c', type: 'currency', cellAttributes: { alignment: 'left' } },
            {label: 'Tax Amount', fieldName: 'Tax_Amount__c', type: 'currency', cellAttributes: { alignment: 'left' } },
            { type: 'action', typeAttributes: { rowActions: actions } }
            ]);
    

        helper.fetchAccounts(component,event, 0);
        
        helper.fetchAdjustments(component,event, 0);
   }, 
    handleSubmit: function(component,event,helper){
       var recordId = component.get('v.recordId');
       var action = component.get('c.void'); 
      
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
   },
   
    loadMoreData: function (component, event, helper) {
        console.log('loading more' + component.get('v.data').length);
        helper.fetchAccounts(component, event, component.get('v.data').length);
    },

    handleShowModal: function(component, evt, helper) {
        console.log('hey there');
        let modalBody;
        var recordId = component.get('v.recordId');
        $A.createComponent('c:AP_AddAdjustment', {invoiceId :recordId},
            function(content, status, errorMessage) {
                if (status === 'SUCCESS') {
                    modalBody = content;
                    component.find('overlayLib').showCustomModal({
                        body: modalBody,
                        showCloseButton: true,
                        cssClass: 'mymodal',
                        closeCallback: function() {
                            //alert('You closed the alert!');
                        }
                    })
                } else if (status === 'ERROR') {
                    let toast = $A.get('e.force:showToast');
                    toast.setParams({
                        title: 'Error',
                        message: errorMessage,
                        type: 'error'
                    });
                    toast.fire();
                }
            }
        );
    },
    handleRowAction: function (component, event, hleper) {
      
        var rows = component.get('v.adjList');
        var action = component.get("c.deleteAdj");
        var row = event.getParam('row');
        var rowIndex = rows.indexOf(row);
        rows.splice(rowIndex, 1);
        component.set('v.adjList', rows);
        
        action.setParams({
          "toDelete": row
        });

        action.setCallback(this, function(response) {
           
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var msg='Adjustment Deleted!';
                component.find('notifLib').showToast({
                              'variant': 'success',
                              'message': msg,
                              'mode': 'sticky'
                });
            }
           
            
        });
        
        
        $A.enqueueAction(action);
    }     
   
})