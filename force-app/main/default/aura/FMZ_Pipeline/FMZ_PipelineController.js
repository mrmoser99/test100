({
    stageSelected: function(component, event, helper){
        var ctarget = event.currentTarget;
        var stageLabel = ctarget.dataset.value;
        var stages = component.get("v.stages");
        var stage;
        for(var s in stages){
            if(stages[s].label == stageLabel){
                stage = stages[s];
            }
        }
        var compEvent = component.getEvent("stageSelect");
        compEvent.setParams({"stage" : stage });
        compEvent.fire();
    }
})