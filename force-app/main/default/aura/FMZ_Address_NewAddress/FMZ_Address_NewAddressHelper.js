({
    sendCreateMessage : function(component, event, helper) {
        var message = {'message' : 'CREATE'};
        this.sendMessageToVF(component, message);
    },
    sendMessageToVF : function(component, message) {
        var vfOrigin = $A.get("$Label.c.FMZ_Visualforce_Host");
        console.log('vfOrigin: '+vfOrigin);
        var vfWindow = component.find("AddressValidationFrame").getElement().contentWindow;
        vfWindow.postMessage(message, vfOrigin);
    }
})