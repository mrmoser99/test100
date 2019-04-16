({
    doInit: function(component, event, helper) {
       var recordId = component.get('v.recordId');
       var actions = [
            { label: 'Delete', name: 'delete' }
        ];

        var actions2 = [
            { label: 'Adjust', name: 'adjust' }
        ];
       
       component.set('v.columns', [
        {label: 'Equipment', fieldName: 'equipmentName', type: 'text', initialWidth : 200},
        {label: 'Charge/Bill Id', fieldName: 'chargeId',  initialWidth : 200, type: 'url',sortable: true,typeAttributes: {label:{ fieldName: 'name'}}},
        {label: 'Description', fieldName: 'fee', type: 'text', initialWidth : 200},
        {label: 'Amount Due', fieldName: 'feeAmount', type: 'decimal'},
        {label: 'Tax Due', fieldName: 'taxAmount', type: 'decimal'},
        { type: 'action', typeAttributes: { rowActions: actions2 } }
        ]);


        component.set('v.columnsA', [
            {label: 'Equipment', fieldName: 'Equipment__c', type: 'text', initialWidth : 200},
            {label: 'Charge Id', fieldName: 'ChargeName', type: 'text'}, 
            {label: 'Bill Id', fieldName: 'DueName', type: 'text'}, 
            {label: 'Description', fieldName: 'Adjustment_Type__c', type: 'text'}, 
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
        $A.createComponent('c:AP_AddAdjustment', {invoiceId :recordId, chargeId : chargeId},
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
    handleRowActionAdd: function (component, event, helper) {
        console.log('hey there');
        let modalBody;
        var recordId = component.get('v.recordId');
        var row = event.getParam('row');
        console.log('you' + recordId);
        //alert(JSON.stringify(row));
        //alert(row.id);
        $A.createComponent('c:AP_AddAdjustment', {recordId :recordId, rowId :row.id, fee: row.fee, amountDue: row.feeAmount},
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