({
    init: function (component, event, helper) {
       
        //helper.initHelper(component, event, helper);   

        component.set('v.columns', [
            {label: 'Account', fieldName: 'customerName', type: 'text'},
            {label: 'Lease', fieldName: 'leaseNumber', type: 'text'},
            {label: 'Postal Code', fieldName: 'postalCode', type: 'text'},
            {label: 'Start', fieldName: 'contractStartDate', type: 'date'},
            {label: 'Term', fieldName: 'term', type: 'text'},
            {label: 'Remaining Payments', fieldName: 'remainingPayments', type: 'text'},
            {label: 'Equipment', fieldName: 'equipmentDescription', type: 'text'},
            {label: 'Cost', fieldName: 'originalCost', type: 'currency'},
            {label: 'Payment', fieldName: 'basePayment', type: 'currency'},
            {label: 'Type', fieldName: 'type', type: 'text'},
            {label: 'Newco Ready?', fieldName: 'newcoReady', type: 'boolean'},
            {label: 'Action', type: 'button', initialWidth: 135, typeAttributes: { label: 'Quote', name: 'genQuote', title: 'Action'}},

        ]);

        helper.fetchAccounts(component,event, 0);
   
    },
    
    loadMoreData: function (component, event, helper) {
       
        helper.fetchAccounts(component, event, component.get('v.data').length);
    }
})