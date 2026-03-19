/**
* @author       APB
* @description  OrderSelector: Selector class for orders
*/
public with sharing class OrderSelector extends fflib_SObjectSelector {

    /**
	* @author       APB
	* @description  order getSObjectFieldList method
	* @return		List<Schema.SObjectField>
	*/
     public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
           SBQQ__Quote__c.SBQQ__Status__c,
           SBQQ__Quote__c.cur_Current_Credit_Limit_including_VAT__c,
           SBQQ__Quote__c.Bill_To_Country__c,
           SBQQ__Quote__c.SBQQ__NetAmount__c,
           SBQQ__Quote__c.CurrencyIsoCode
        };
    }

    /**
	* @author       APB
	* @description  order selectOrderInfo method
    * @param		idSet Set<ID>
	* @return		List<Order>
	*/
    public List<Order> selectOrderInfo(Set<Id> idSet) {
    List<Order> orders = new List<Order>();
    for(Order order : Database.query(
            newQueryFactory(false)
                .selectField(Order.Status)
                .selectField(Order.AccountId)
                .selectField(Order.cur_Current_Credit_Limit_including_VAT__c)
                .selectField(Order.TotalAmount)
                .selectField(Order.CurrencyIsoCode)
                .selectField('Account.txt_AthenaUUID__c')
                .selectField('Account.BillingCountry')
                .selectField('Account.BillingCountryCode')
                .setCondition('id in :idSet')
                .toSOQL()))
    {
        orders.add(order);
    }
        return orders;
    }

    /**
	* @author       APB
	* @description  order getSObjectType method
	* @return		Schema.SObjectType
	*/
    public Schema.SObjectType getSObjectType() {
        return Order.sObjectType;
    }

    /**
	* @author       APB
	* @description  order selectById method
    * @param		idSet Set<ID>
	* @return		List<Order>
	*/
    public List<Order> selectById(Set<ID> idSet) {
        return (List<Order>) selectSObjectsById(idSet);
    }
}