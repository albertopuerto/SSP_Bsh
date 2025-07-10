/**
 * @description Trigger to prevent modifications to quotes in final statuses - fflib pattern
 * @author TLQ1KOR
 * @date 2025
 */
trigger QuoteLockTrigger on SBQQ__Quote__c (
    before insert, before update, before delete,
    after insert, after update, after delete, after undelete) {
    
    fflib_SObjectDomain.triggerHandler(QuoteLock.class);
}