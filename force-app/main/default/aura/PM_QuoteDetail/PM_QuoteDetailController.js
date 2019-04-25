({
	doInit : function(component, event, helper) {
        
        var myRecords = component.get('v.records');
      
        console.log(myRecords.quotes);
      
        var selectedQuoteNumber = component.get('v.selectedQuoteNumber');
		
        for (var i in myRecords.quotes){
            if (myRecords.quotes[i].quoteNumber == selectedQuoteNumber){
                component.set('v.remainingRentalPayments', myRecords.quotes[i].remainingRentalPayments);
                component.set('v.discount', myRecords.quotes[i].discount);
                component.set('v.equipmentPrice', myRecords.quotes[i].equipmentPrice);
                component.set('v.salesTax', myRecords.quotes[i].salesTax);
                component.set('v.propertyTax', myRecords.quotes[i].propertyTax);
                component.set('v.pastDueService', myRecords.quotes[i].pastDueService);
                component.set('v.leaseCharges', myRecords.quotes[i].leaseCharges);
                component.set('v.securityDeposit', myRecords.quotes[i].securityDeposit);
                component.set('v.amount', myRecords.quotes[i].amount);
                component.set('v.pastDueService', myRecords.quotes[i].pastDueService);
                component.set('v.quoteCalculationDescription', myRecords.quotes[i].quoteCalculationDescription);
                component.set('v.quoteMessage', myRecords.quotes[i].quoteMessage);
                component.set('v.terminationQuoteType', myRecords.quotes[i].terminationQuoteType);
                component.set('v.quoteValidityDate', myRecords.quotes[i].quoteValidityDate);

            }
        }
	}
})