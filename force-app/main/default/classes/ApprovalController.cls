/**
* @File Name : ApprovalController.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : October 30, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | October 30, 2025 |   | Initial Version
**/

public with sharing class ApprovalController {
    @AuraEnabled(cacheable=true)
    public static List<sbaa__Approval__c> getMyApprovals() {
        List<String> excludedStatuses = new List<String>{'Rejected', 'Approved'};
        Id userId = UserInfo.getUserId();
		Set<Id> userGroupIds = new Set<Id>();
    	for (GroupMember gm : [
        	SELECT GroupId 
        	FROM GroupMember 
        	WHERE UserOrGroupId = :userId
    	]) {
        	userGroupIds.add(gm.GroupId);
    	}

	    Set<Id> approverIds = new Set<Id>();
	    for (sbaa__Approver__c approver : [
    	    SELECT Id 
	        FROM sbaa__Approver__c 
	        WHERE sbaa__User__c = :userId 
			OR sbaa__GroupId__c IN :userGroupIds
    	]) {
        	approverIds.add(approver.Id);
    	}       
    	return [
        	SELECT Id, Name, sbaa__Status__c, Quote__c, Quote__r.Name, CreatedDate
        	FROM sbaa__Approval__c
        	WHERE sbaa__Approver__c IN :approverIds
        	AND sbaa__Status__c NOT IN :excludedStatuses
        	ORDER BY CreatedDate DESC
    	];
    }

	@AuraEnabled(cacheable=true)
    public static List<sbaa__Approval__c> getMyHistoryApprovals() {
        Id userId = UserInfo.getUserId();
        return [
            SELECT Id, Name, sbaa__Status__c, LastModifiedDate,
                   sbaa__ApprovedBy__r.Name,
                   sbaa__RejectedBy__r.Name,
                   Quote__r.Name,
                   flink_Opportunity__c
            FROM sbaa__Approval__c
            WHERE sbaa__ApprovedBy__c = :userId
               OR sbaa__RejectedBy__c = :userId
            ORDER BY LastModifiedDate DESC
        ];
    }
}