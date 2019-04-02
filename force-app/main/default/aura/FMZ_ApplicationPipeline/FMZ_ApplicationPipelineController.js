({
    doInit : function(component, event, helper){
        helper.initialize(component);

        component.set('v.columns', [
                    {label: 'Name', fieldName: 'View_Record__c', type: 'url', typeAttributes: {label: { fieldName: 'Name'}, target: '_top'},sortable:false},
                   	{label: 'Bank Name', fieldName: 'genesis__Bank_Name__c', type: 'text',sortable:false},
                   	{label: 'Status', fieldName: 'genesis__Status__c', type: 'text',sortable:false}
                ]);
    },
    handleStageSelect : function(component, event, helper){
        var stage = event.getParams().stage;
        var selectedStage = component.get("v.selectedStage");

        if(!selectedStage){
            component.set("v.showValues", true);
        }else if(stage.label == selectedStage.label){
            component.set("v.showValues", ! component.get("v.showValues"));
        }else{
            component.set("v.showValues", true);
        }

        component.set("v.selectedStage", stage);
        component.set("v.allData", stage.values);
        component.set("v.current", component.get("v.listMaxCount"));
        component.set("v.data", stage.values.slice(0, component.get("v.listMaxCount")));
    },
    handleClose : function(component, event, helper){
        component.set("v.showValues", false);
    },
    handleFirstPage: function(component, event, helper){
        var max = component.get("v.listMaxCount");
        component.set("v.current", max);
        component.set("v.data", component.get("v.allData").slice(0, max));
    },
    handlePreviousPage: function(component, event, helper){
        var max = component.get("v.listMaxCount");
        var current = component.get("v.current");
        if(current != max){
            current -= max;
            component.set("v.data", component.get("v.allData").slice(current-max, current));
            component.set("v.current", current);
        }
    },
    handleNextPage: function(component, event, helper){
        var max = component.get("v.listMaxCount");
        var current = component.get("v.current");
        if(current < component.get("v.allData").length){
            component.set("v.data", component.get("v.allData").slice(current, current+max));
            current += max;
            component.set("v.current", current);
        }
    },
    handleLastPage: function(component, event, helper){
        var max = component.get("v.listMaxCount");
        var newCurrent = 0;
        var count = component.get("v.allData").length;
        while((newCurrent) < count){
            newCurrent += max;
        }
        component.set("v.data", component.get("v.allData").slice(newCurrent-max, newCurrent));
        component.set("v.current",newCurrent);

    }
})