/**
* @author       APB
* @description  QuoteLineItemSelector: Selector class for quote line items
*/
public with sharing class QuoteLineItemSelector extends fflib_SObjectSelector {

    /**
	* @author       APB
	* @description  SBQQ__QuoteLine__c getSObjectFieldList method
	* @return		List<Schema.SObjectField>
	*/
     public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
           SBQQ__QuoteLine__c.Id
        };
    }

    /**
	* @author       APB
	* @description  SBQQ__QuoteLine__c selectQuoteLineItem method
    * @param		idSet Set<ID>
	* @return		List<SBQQ__QuoteLine__c>
	*/
    public List<SBQQ__QuoteLine__c> selectQuoteLineItems(Set<Id> idSet) {
    List<SBQQ__QuoteLine__c> quoteLineItems = new List<SBQQ__QuoteLine__c>();
    for(SBQQ__QuoteLine__c quoteLineItem : Database.query(
        newQueryFactory(false)
        .selectField(SBQQ__QuoteLine__c.Id)
        .selectField('SBQQ__Product__r.pkl_MaterialType__c')
        .setCondition('SBQQ__Quote__c in :idSet')
        .toSOQL()))
    {
        quoteLineItems.add(quoteLineItem);
    }
        return quoteLineItems;
    }

    /**
	* @author       APB
	* @description  SBQQ__QuoteLine__c getSObjectType method
	* @return		Schema.SObjectType
	*/
    public Schema.SObjectType getSObjectType() {
        return SBQQ__QuoteLine__c.sObjectType;
    }
}