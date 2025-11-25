/**
* @author       APB
* @description  FlowsMetadataUtil: Util class used to get flows status
*/
public with sharing class FlowsMetadataUtil {

    private static Map<String,Boolean> mapFlowStatus = new Map<String,Boolean>();
    /**
	* @author       APB
	* @description  getMapFlowStatusFiltered method
	* @return		Map<String,Boolean>
	*/
    public static Map<String,Boolean> getMapFlowStatusFiltered(String apiClause){

        if(mapFlowStatus.isEmpty()){
            List<FlowDefinitionView> listFlows = [SELECT Id,IsActive,ApiName from FlowDefinitionView WHERE ApiName =:apiClause WITH SYSTEM_MODE];

            if(!listFlows.isEmpty()){
                for(FlowDefinitionView flow : listFlows){
                    mapFlowStatus.put(flow.ApiName,flow.IsActive);
                }
            }
        }

        return mapFlowStatus;
    }

    public static Boolean isFlowActive(String apiName){
        if(mapFlowStatus.isEmpty()) {
            getMapFlowStatusFiltered(apiName);
        }

        return mapFlowStatus.get(apiName);
    }


}