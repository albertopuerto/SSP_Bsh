trigger SalesArealinkTrigger on SalesAreaLink__c (before insert) {
    SalesAreaLinkTriggerHandler.handleBeforeInsert(Trigger.New);	
}