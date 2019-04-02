({
    doInit : function(component, event, helper) {
        var vfOrigin = $A.get("$Label.c.FMZ_Visualforce_Host");
        window.addEventListener("message", $A.getCallback(function(event) {
            if(event.origin == vfOrigin) {
                if(event.data.message == 'ADDRESS_DATA'){
                    var address = event.data.address;
                    var appEvent = $A.get("e.c:FMZ_NewCustomerAddress");

                    var addrLine1 = address.addressLine1;
                    var addrLine2 = address.addressLine2;
                    var city = address.city;
                    var state = address.state;
                    var county = address.county;
                    var zip = address.zipCode;
                    var country = address.country;
                    var status = status;

                    console.log('Made it here');
                    appEvent.setParams({
                        "addressLine1" : addrLine1,
                        "addressLine2" : addrLine2,
                        "city" : city,
                        "state" : state,
                        "county" : county,
                        "zipcode" : zip,
                        "country" : country,
                        "status" : status
                    });
                    appEvent.fire();
                    let dismiss = $A.get('e.force:closeQuickAction');
                    dismiss.fire();
                }
            }
        }), false);
    },
    doneLoading: function(component, event, helper){
        component.set("v.processing", false);
    },
    handleCreate: function(component, event, helper) {
        helper.sendCreateMessage(component, event, helper);
    },
    handleCancel: function(component, event, helper) {
        let dismiss = $A.get('e.force:closeQuickAction');
        dismiss.fire();
    }
})