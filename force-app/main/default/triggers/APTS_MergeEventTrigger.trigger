/**
* @Name: APTS_MergeEventTrigger
* @Author: Apttus
* @CreateDate: 30-July-2019
* @Description: Trigger on MergeEvent object. 
-----------------------------------------------------------------------------------------------
* @LastModifiedBy: <LastModifiedBy>
* @LastModifiedDate: <LastModifiedDate>
* @ChangeDescription: <ChangeDescription>
---------------------------------------------------------------------------------------------
    MODIFY:
    07/21/22: Not needed for the Accelerator offering.
**/
trigger APTS_MergeEventTrigger on Apttus__MergeEvent__c (before insert, before update, before delete, after insert, after update, after delete) {
    /*
    if (Trigger.isInsert && Trigger.isAfter) {
        APTS_MergeEventTriggerHandler.onAfterInsert(Trigger.new, Trigger.oldMap);
    }
    
    if (Trigger.isUpdate && Trigger.isAfter) {
        APTS_MergeEventTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
    }
   */

}