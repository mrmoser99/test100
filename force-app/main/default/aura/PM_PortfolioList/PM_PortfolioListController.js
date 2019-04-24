({
    init: function (component, event, helper) {
        component.set('v.page',0);

        component.set('v.columns', [
            {label: 'Account', fieldName: 'customerName', type: 'text', initialWidth: 250},
            {label: 'Lease', fieldName: 'contractNumber', type: 'text'},
            {label: 'Postal Code', fieldName: 'customerZipCode', type: 'text'},
            {label: 'Start', fieldName: 'contractStartDate', type: 'text'},
            {label: 'Term', fieldName: 'contractTerm', type: 'text'},
            {label: 'Remaining Payments', fieldName: 'numberOfRemainingPayments', type: 'text'},
            {label: 'Equipment', fieldName: 'equipmentDescription', type: 'text',  initialWidth: 250},
            {label: 'Cost', fieldName: 'contractOriginalCost', type: 'currency', typeAttributes: { currencyCode: 'USD'}},
            {label: 'Payment', fieldName: 'contractPayment', type: 'currency', typeAttributes: { currencyCode: 'USD'}},
            {label: 'Type', fieldName: 'contractType', type: 'text'},
            {label: 'Newco Ready?', fieldName: 'newcoReady', type: 'boolean'},
            {label: 'Action', type: 'button', initialWidth: 135, typeAttributes: { label: 'Quote', name: 'genQuote', title: 'Action'}}

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
        
    }
    
}) 
        