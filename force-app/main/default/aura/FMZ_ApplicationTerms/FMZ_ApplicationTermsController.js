({
    doInit: function(component, event, helper) {
        helper.loadApplicationTerms(component);
    },

    // mark components with equipment-changed css class
    handleChange: function(component, event, helper) {
        console.log('handle change');
        try {
            let inputControl = event.getSource();
            $A.util.addClass(inputControl, 'terms-changed');
        } catch (e) {
            console.log(e);
        }
    },

    // validate required fields and at least one piece of equipment
    saveAndValidate: function(component, event, helper) {
        try {
            let application = component.get('v.application'),
                term = component.find('term');
                if((Number(term.get('v.value')) % 12) > 0){
                    term.setCustomValidity("Term must be a multiple of 12");
                    term.reportValidity();
                }else{
                    term.setCustomValidity("");
                    term.reportValidity();
                }
            term.showHelpMessageIfInvalid();
            if(!term.get('v.validity').valid) {
                return false;
            } else {
                if ($A.util.hasClass(term, 'terms-changed')) {
                    helper.updateTerms(component, application);
                }
                return true;
            }
        } catch (e) {
            console.log(e);
        }
    }

})