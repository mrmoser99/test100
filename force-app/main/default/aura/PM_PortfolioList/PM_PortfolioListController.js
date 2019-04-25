({
    init: function (component, event, helper) {
        component.set('v.page',0);

        var actions = [
            { label: 'Get Quote', name: 'quote' }
        ];

        component.set('v.columns', [
            {label: 'Account', fieldName: 'customerName', type: 'text', initialWidth: 220},
            {label: 'Lease', fieldName: 'contractNumber', type: 'text'},
            {label: 'Postal Code', fieldName: 'customerZipCode', type: 'text'},
            {label: 'Start', fieldName: 'contractStartDate', type: 'text'},
            {label: 'Term', fieldName: 'contractTerm', type: 'text'},
            {label: 'Remaining Payments', fieldName: 'numberOfRemainingPayments', type: 'text'},
            {label: 'Equipment', fieldName: 'equipmentDescription', type: 'text',  initialWidth: 225},
            {label: 'Cost', fieldName: 'contractOriginalCost', type: 'currency', typeAttributes: { currencyCode: 'USD'}},
            {label: 'Payment', fieldName: 'contractPayment', type: 'currency', typeAttributes: { currencyCode: 'USD'}},
            {label: 'Type', fieldName: 'contractType', type: 'text'},
            {label: 'Newco Ready?', fieldName: 'newcoReady', type: 'boolean'},
            {type: 'action', typeAttributes: { rowActions: actions } }
           

        ]);


        component.set('v.quoteColumns', [
            {label: 'Type', fieldName: 'quoteCalculationDescription', type: 'text', initialWidth: 250},
            {label: 'Quote Amount', fieldName: 'amount',  initialWidth: 150, type: 'currency', typeAttributes: { currencyCode: 'USD'}},
            {label: 'Quote Number', fieldName: 'quoteNumber', type: 'text', initialWidth: 150}

        ]);

   
    },
    
    loadMoreData: function (component, event, helper) {
        
        event.getSource().set("v.isLoading", true);        
        component.set('v.loadMoreStatus', 'Loading');

        var page = component.get('v.page');
        page = page + 1;
        component.set('v.page',page);
       
        helper.fetchRecords(component, event, page);
    },
    
    handleSearch: function (component, event, helper) {

        component.set('v.data',[]);
        helper.fetchRecords(component, event, 0);
        
    },
   

    handleRowAction: function (component, event, helper) {
        
        var rowAction = event.getParam('action');
        var row = event.getParam('row');
        component.set('v.quoteData',[]);
        
        switch (rowAction.name) {
            case 'quote':
                var action = component.get("c.generateQuotes");
                
                action.setParams({
                  "leaseNumber": row.contractNumber
                });
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var records = response.getReturnValue();
                        console.log(records.quotes);
                        
                        component.set('v.quoteData', records.quotes);

                        var msg='Quotes Generated!';
                        component.find('notifLib').showToast({
                                      'variant': 'success',
                                      'message': msg,
                                      'mode': 'sticky'
                        });
                        //$A.get('e.force:refreshView').fire();  
                    }
                    
                    //$A.get('e.force:refreshView').fire();
                });
                
                $A.enqueueAction(action);
                
        }
    }     
    
}) 
        