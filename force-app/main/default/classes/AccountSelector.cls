public with sharing class AccountSelector extends fflib_SObjectSelector {
     public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Account.Name,
            Account.Description,
            Account.AnnualRevenue,
            Account.BillingCountry,
            Account.txt_AthenaUUID__c,
            Account.CurrencyIsoCode
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Account.sObjectType;
    }
    public List<Account> selectById(Set<ID> idSet) {
        return (List<Account>) selectSObjectsById(idSet);
    }
   
}