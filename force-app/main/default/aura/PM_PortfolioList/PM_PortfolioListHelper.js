({
    fetchAccounts : function(component, event, offSetCount) {
       
        var action = component.get("c.searchPortfolio");
        action.setParams({
            "customerName": '%',
            "customerAccountNumber" : '11111',
            "equipmentSerialNumber" : '20202',
            "choice" : '1',
            "size" : '20',
            "sortOrder" : 'customerName',
            "assetDetail" : true,
            "intOffSet" : offSetCount

        }); 
       
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var records = response.getReturnValue();
                var currentData = component.get('v.data');                
                component.set('v.data', currentData.concat(records));
            }
           
            
        });
        
        $A.enqueueAction(action);
        
 }
})