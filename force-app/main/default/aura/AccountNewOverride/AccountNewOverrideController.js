({
    init: function(component) {
        component.find("flowData").startFlow("flw_OnboardButton_OnboardAccount");
    },
    
    handleStatusChange: function(component, event) {
        var status = event.getParam("status");
        
        if (status === "FINISHED") {
            var outputVariables = event.getParam("outputVariables");
            var newAccountId = null;
            
            if (outputVariables) {
                outputVariables.forEach(function(outputVar) {
                    if (outputVar.name === "recordId" || outputVar.name === "AccountId") {
                        newAccountId = outputVar.value;
                    }
                });
            }
            
            var navService = component.find("navService");
            var pageRef = newAccountId ? {
                type: "standard__recordPage",
                attributes: {
                    recordId: newAccountId,
                    objectApiName: "Account",
                    actionName: "view"
                }
            } : {
                type: "standard__objectPage",
                attributes: {
                    objectApiName: "Account",
                    actionName: "list"
                }
            };
            navService.navigate(pageRef);
        }
    }
})