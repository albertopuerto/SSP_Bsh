/**
* @Name: APTS_MergeEventTriggerHandler
* @Author: Apttus
* @CreateDate: 30-July-2019
* @Description: Handler class for APTS_MergeEventTrigger. 
--------------------------------------------------------------------------------------------------------
* @LastModifiedBy: <LastModifiedBy>
* @LastModifiedDate: <LastModifiedDate>
* @ChangeDescription: <ChangeDescription>
    ---------------------------------------------------------------------------------------------
    MODIFY:
    07/21/22: Not needed for the Accelerator offering.
**/
public class APTS_MergeEventTriggerHandler {
    /*
    public static Boolean executeTrigger = true;
    public static void onAfterInsert(List<Apttus__MergeEvent__c> listMergeEventNew, Map<id, Apttus__MergeEvent__c> mapMergeEventOld) {
        try {
            if (executeTrigger) {
                executeTrigger = false;
                 APTS_MergeEventTriggerHelper.updateApprovalStatus(listMergeEventNew);
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, '[APTS_MergeEventTriggerHandler] Exception: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, '[APTS_MergeEventTriggerHandler] Exception: ' + e.getStackTraceString());          
        }

    }
    public static void onAfterUpdate(List<Apttus__MergeEvent__c> listMergeEventNew, Map<id, Apttus__MergeEvent__c> mapMergeEventOld) {
        try {
            executeTrigger = true;
            if (executeTrigger) {
                executeTrigger = false;
                APTS_MergeEventTriggerHelper.updateApprovalStatus(listMergeEventNew);
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, '[APTS_MergeEventTriggerHandler] Exception: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, '[APTS_MergeEventTriggerHandler] Exception: ' + e.getStackTraceString());         
        }

    }
   
*/
}