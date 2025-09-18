public with sharing class QuoteSelector extends fflib_SObjectSelector {
     public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
           SBQQ__Quote__c.SBQQ__Status__c,
           SBQQ__Quote__c.Current_Credit_Limit_including_VAT__c, 
           SBQQ__Quote__c.Bill_To_Country__c,
           SBQQ__Quote__c.SBQQ__NetAmount__c,
           SBQQ__Quote__c.CurrencyIsoCode
            
        };
    
    }

    public List<SBQQ__Quote__c> selectQuoteInfo(Set<Id> idSet) {
    List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
    for(SBQQ__Quote__c quote : Database.query(
            newQueryFactory(false)
                .selectField(SBQQ__Quote__c.SBQQ__Status__c)
                .selectField(SBQQ__Quote__c.SBQQ__Account__c)
                .selectField(SBQQ__Quote__c.Current_Credit_Limit_including_VAT__c)
                .selectField(SBQQ__Quote__c.Bill_To_Country__c)
                .selectField(SBQQ__Quote__c.SBQQ__NetAmount__c)
                .selectField(SBQQ__Quote__c.CurrencyIsoCode)
                .selectField('SBQQ__Account__r.BillingCountry')
                .selectField('SBQQ__Account__r.txt_AthenaUUID__c')
                .setCondition('id in :idSet')
                .toSOQL()))
    {
        quotes.add(quote);
    }
        return quotes;
    }

    public Schema.SObjectType getSObjectType() {
        return SBQQ__Quote__c.sObjectType;
    }
    public List<SBQQ__Quote__c> selectById(Set<ID> idSet) {
        return (List<SBQQ__Quote__c>) selectSObjectsById(idSet);
    }
   
}