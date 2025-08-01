public without sharing class SalesAreaLinkTriggerHandler {
    
    public static void handleBeforeInsert(List<SalesAreaLink__c> newRecords) {
        checkForDuplicates(newRecords);
    }
    
    public static void checkForDuplicates(List<SalesAreaLink__c> newRecords){
        Set<Id> accountIds = new Set<Id>();
        Map<Id,SalesAreaLink__c> accountSDCMap = new Map<Id,SalesAreaLink__c>();
        
        for(SalesAreaLink__c sal : newRecords){
            if(sal.mdr_Account__c != null)
                accountIds.add(sal.mdr_Account__c);
        }
        
        List<SalesAreaLink__c> existingSDCustomers = [Select Id,mdr_Account__c,ftxt_DistributionChannel__c,ftxt_Division__c,mdr_SalesArea__c
                                                      from SalesAreaLink__c where mdr_Account__c IN : accountIds];
        
        for(SalesAreaLink__c existing : existingSDCustomers){
            accountSDCMap.put(existing.mdr_Account__c,existing);
        }
        
        for(SalesAreaLink__c newSDCustomer : newRecords){
            if(accountSDCMap.keySet().contains(newSDCustomer.mdr_Account__c)){
                if(accountSDCMap.get(newSDCustomer.mdr_Account__c).mdr_SalesArea__c == newSDCustomer.mdr_SalesArea__c &&
                   accountSDCMap.get(newSDCustomer.mdr_Account__c).ftxt_DistributionChannel__c == newSDCustomer.ftxt_DistributionChannel__c &&
                   accountSDCMap.get(newSDCustomer.mdr_Account__c).ftxt_Division__c == newSDCustomer.ftxt_Division__c) {
                       newSDCustomer.addError('Sales Data Customer record already exist for combination of: Sales Organization, Distribution Channel and Division');
                   }
            }
        }
    }
}