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
            var rows = response.getReturnValue();
            for (var i = 0; i < rows.length; i++) { 
                var row = rows[i]; 
                //as data columns with relationship __r can not be displayed directly in data table, so generating dynamic columns 
                if (row.Charge__r) { 
                    row.ChargeName = row.Charge__r.Name; 
                } 
                if (row.Due_Detail_Line__r)
                    row.DueName = row.Due_Detail_Line__r.Name;
            } 
            component.set('v.adjList', rows);
        }
       
        
    });
    
    $A.enqueueAction(action);
    
}
})
