/**
* @author       APB
* @description  AccountSelector: Selector class for accounts
*/
public with sharing class AccountSelector extends fflib_SObjectSelector {

    /**
	* @author       APB
	* @description  account getSObjectFieldList method
	* @return		List<Schema.SObjectField>
	*/
     public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Account.Name,
            Account.Description,
            Account.AnnualRevenue,
            Account.BillingCountry,
            Account.BillingCountryCode,
            Account.txt_AthenaUUID__c,
            Account.CurrencyIsoCode
        };
    }

    /**
	* @author       APB
	* @description  account getSObjectType method
	* @return		Schema.SObjectType
	*/
    public Schema.SObjectType getSObjectType() {
        return Account.sObjectType;
    }

    /**
	* @author       APB
	* @description  account selectById method
    * @param		idSet Set<ID>
	* @return		List<Account>
	*/
    public List<Account> selectById(Set<ID> idSet) {
        return (List<Account>) selectSObjectsById(idSet);
    }
}