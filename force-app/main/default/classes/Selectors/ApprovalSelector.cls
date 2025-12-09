/**
* @author       APB
* @description  ApprovalSelector: Selector class for approvals
*/
public with sharing class ApprovalSelector extends fflib_SObjectSelector {

    /**
	* @author       APB
	* @description  approval getSObjectFieldList method
	* @return		List<Schema.SObjectField>
	*/
     public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
           
        };
    }

    /**
	* @author       APB
	* @description  approval getApprovalApprovers method
    * @param		idSet Set<ID>
	* @return		List<sbaa__Approval__c>
	*/
    public List<sbaa__Approval__c> getApprovalApprovers(Set<Id> idSet) {
    List<sbaa__Approval__c> approvals = new List<sbaa__Approval__c>();
    for(sbaa__Approval__c approval : Database.query(
            newQueryFactory(false)
                .selectField('sbaa__Approver__r.sbaa__User__c')
                .selectField('sbaa__Approver__r.sbaa__GroupId__c')
                .setCondition('id in :idSet')
                .toSOQL()))
    {
        approvals.add(approval);
    }
        return approvals;
    }

    /**
	* @author       APB
	* @description  approval getSObjectType method
	* @return		Schema.SObjectType
	*/
    public Schema.SObjectType getSObjectType() {
        return sbaa__Approval__c.sObjectType;
    }

    /**
	* @author       APB
	* @description  approval selectById method
    * @param		idSet Set<ID>
	* @return		List<sbaa__Approval__c>
	*/
    public List<sbaa__Approval__c> selectById(Set<ID> idSet) {
        return (List<sbaa__Approval__c>) selectSObjectsById(idSet);
    }
}