/**
 * Created by samuelmeyers on 11/20/18.
 */
({
    handleSelect: function(component, event, helper){
        var ctarget = event.currentTarget;
        var id_str = ctarget.dataset.value;
        var selectedId = component.get('v.selectedId');
        if(id_str == selectedId){
            component.set('v.selectedId', null);
        }else{
            component.set('v.selectedId', id_str);
        }
    },
    handleSelectButton: function(component, event, helper){
        let dismiss = $A.get('e.force:closeQuickAction');
        dismiss.fire();
    },
    handleCancelButton: function(component, event, helper){
        component.set('v.selectedId', null); 
        let dismiss = $A.get('e.force:closeQuickAction');
        dismiss.fire();
    }
})