({
    doInit: function(component, event, helper) {
    	setTimeout(function() {
			let dismiss = $A.get('e.force:closeQuickAction');
			component.set('v.fired', true);
			dismiss.fire();
		});
    },
	closed: function(component, event, helper) {
		let recordId = component.get('v.recordId'),
			fired = component.get('v.fired');
		if (fired) {
			setTimeout(function () {
				let navEvent = $A.get('e.force:navigateToURL');
				navEvent.setParams({
					url: '/application-edit?id=' + recordId
				});
				navEvent.fire();
			}, 10);
		}
	}
})