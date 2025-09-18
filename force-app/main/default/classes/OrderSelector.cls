public with sharing class OrderSelector extends fflib_SObjectSelector {
     public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
           SBQQ__Quote__c.SBQQ__Status__c,
           SBQQ__Quote__c.Current_Credit_Limit_including_VAT__c, 
           SBQQ__Quote__c.Bill_To_Country__c,
           SBQQ__Quote__c.SBQQ__NetAmount__c,
           SBQQ__Quote__c.CurrencyIsoCode
            
        };
    
    }

    public List<Order> selectOrderInfo(Set<Id> idSet) {
    List<Order> orders = new List<Order>();
    for(Order order : Database.query(
            newQueryFactory(false)
                .selectField(Order.Status)
                .selectField(Order.AccountId)
                .selectField(Order.Current_Credit_Limit_including_VAT__c)
                .selectField(Order.TotalAmount)
                .selectField(Order.CurrencyIsoCode)
                .selectField('Account.txt_AthenaUUID__c')
                .selectField('Account.BillingCountry')
                .setCondition('id in :idSet')
                .toSOQL()))
    {
        orders.add(order);
    }
        return orders;
    }

    public Schema.SObjectType getSObjectType() {
        return Order.sObjectType;
    }
    public List<Order> selectById(Set<ID> idSet) {
        return (List<Order>) selectSObjectsById(idSet);
    }
   
}