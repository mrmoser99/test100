({
    fetchData : function(component, event, offSetCount) {
       
        
        var action = component.get("c.getCharges");
        var recordId = component.get('v.recordId');
        console.log('rec id hre is:' + recordId);

        action.setParams({
            "recordId": recordId
        }); 

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var results = response.getReturnValue();
                component.set('v.dataDue', results);
            }
        });
        
        $A.enqueueAction(action);
        
 },
 fetchDataAdj : function(component, event, offSetCount) {
       
        
    var action = component.get("c.getAdjustments");
    var recordId = component.get('v.recordId');
    console.log('rec id hre is:' + recordId);

    action.setParams({
        "recordId": recordId
    }); 

    action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
            
            var results = response.getReturnValue();
            component.set('v.dataAdjustments', results);
        }
    });
    
    $A.enqueueAction(action);
    
},
fetchDataNewBillsAndCharges : function(component, event, offSetCount) {
       
        
    var action = component.get("c.getNewBillsAndCharges");
    var recordId = component.get('v.recordId');
    console.log('rec id hre is:' + recordId);

    action.setParams({
        "recordId": recordId
    }); 

    action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
            
            var results = response.getReturnValue();
            component.set('v.dataAdjustments', results);
        }
    });
    
    $A.enqueueAction(action);
    
}
})

 