/**
 * @description Trigger class for Approval (SBAA__Approval__c) - handles approval locking logic
 * @author SNV1SF
 * @date 2025
 */

trigger ApprovalTrigger on sbaa__Approval__c (before insert, before update, after insert, after update) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            ApprovalTriggerHandler.handleBeforeInsert(Trigger.new);
        }
        else if (Trigger.isUpdate) {
            ApprovalTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            ApprovalTriggerHandler.handleAfterInsert(Trigger.new);
        }
         else if (Trigger.isUpdate) {
            ApprovalTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }

}