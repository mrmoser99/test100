/**
 * Created by samuelmeyers on 11/9/18.
 */
({
    doInit : function(component, event, helper){
        var action = component.get('c.getSections');
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === 'SUCCESS') {
                var sections = response.getReturnValue();
                console.log(sections);
                component.set('v.sections', sections);

                for(var y in sections){
                    sections[y].columns = [
                        {label: sections[y].linkColTitle, fieldName: 'link', type: 'url', typeAttributes: {label: { fieldName: 'name'}},sortable:false},
                        {label: sections[y].infoColTitle, fieldName: 'info', type: 'text',sortable:false},
                        {label: 'Action', fieldName: 'temp', type: 'text',sortable:false}
                    ];
                }
                component.set('v.processing', false);
            } else {
                component.set('v.processing', false);
            }
        });

        component.set('v.processing', true);

        $A.enqueueAction(action);
    },
    onRender : function(component, event, helper){
//        var sections = component.get('v.sections');
//        var activeSection = '';
//        for(var x in sections){
//            if(sections[x].items.length > 0){
//                activeSection = sections[x].name;
//                break;
//            }
//        }
//        component.find("accordion").set('v.activeSectionName', activeSection);
    }
})