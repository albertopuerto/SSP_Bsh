/**
* @author       APB
* @description  FlowsMetadataUtil: Util class used to get flows status
*/
public with sharing class FlowsMetadataUtil {

    /**
	* @author       APB
	* @description  getStatusFlows method
	* @return		Map<String,Boolean>
	*/
    public static Map<String,Boolean> getStatusFlows(){

        Map<String,Boolean> statusFlowsMap = new Map<String,Boolean>();
        List<FlowDefinitionView> listFlows = [SELECT Id,IsActive,ApiName from FlowDefinitionView LIMIT 400];

        for(FlowDefinitionView flow : listFlows){
            statusFlowsMap.put(flow.ApiName,flow.IsActive);
        }

        return statusFlowsMap;
    }
}