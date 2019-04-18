({
    onInit: function(component, event, helper) {
        helper.getApplicationInfo(component, false);
        helper.getApprovalInfo(component);
        helper.getLocations(component);
    },
    updateView: function(component, event, helper) {
        helper.getApplicationInfo(component, true);
        helper.getLocations(component);
    }
})