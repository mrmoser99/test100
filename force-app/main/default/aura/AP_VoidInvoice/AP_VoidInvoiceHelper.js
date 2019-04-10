({
    fetchAccounts : function(component, event, offSetCount) {
       
        console.log('hello');
        var action = component.get("c.getCharges");
        var recordId = component.get('v.recordId');
       

        action.setParams({
            "invoiceId": recordId,
            "intOffset" : offSetCount

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
        
 },
 fetchAdjustments : function(component, event, offSetCount) {
       
    console.log('hello');
    var action = component.get("c.getAdjustments");
    var recordId = component.get('v.recordId');
   

    action.setParams({
        "invoiceId": recordId,
        "intOffset" : offSetCount

    }); 

    action.setCallback(this, function(response) {
        
        var state = response.getState();
        if (state === "SUCCESS") {
            var records = response.getReturnValue();
            component.set('v.adjList', records);
        }
       
        
    });
    
    $A.enqueueAction(action);
    
}
})
