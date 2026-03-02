({    
    closeComponent: function(component, event, helper) {
        
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})