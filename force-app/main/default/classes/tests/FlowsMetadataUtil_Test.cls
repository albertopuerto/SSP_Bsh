/**
* @author       APB
* @description  FlowsMetadataUtil_Test: Class used to test the class FlowsMetadataUtils
*/
@IsTest
public class FlowsMetadataUtil_Test {

@IsTest
    public static void detectionOfFlowStatus(){

        Boolean isFlowActive = FlowsMetadataUtil.isFlowActive('flw_propagate_main_contact_role');
        if(isFlowActive==true){
           Assert.areEqual(true, isFlowActive, 'The flow should be active');
        }else{
             Assert.areEqual(false, isFlowActive, 'The flow should not be active');
        }
        
    }
    
}