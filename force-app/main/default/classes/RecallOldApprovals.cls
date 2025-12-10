public without sharing class RecallOldApprovals {

    public static final EmailTemplate TEMPLATE = [
        SELECT Id 
        FROM EmailTemplate 
        WHERE DeveloperName ='eml_ApprovalRequestTemplate'
        LIMIT 1
    ];

    @InvocableMethod(label='Recall approvals' description='Method used to recall the approvals sending an email to the user')
    public static void sendEmailToApprovers(List<InputVariables> listApprovals) {

        Set<Id> approvalIds = new Set<Id>(listApprovals[0].approvalIds);

        List<sbaa__Approval__c> approvals = new ApprovalSelector().getApprovalApprovers(approvalIds);

        Set<Id> approverUserIds = new Set<Id>();
        Set<Id> approverGroupIds = new Set<Id>();
        for (sbaa__Approval__c approval : approvals) {
            if (approval.sbaa__Approver__r.sbaa__User__c != null) {
                approverUserIds.add(approval.sbaa__Approver__r.sbaa__User__c);
            } else if (approval.sbaa__Approver__r.sbaa__GroupId__c != null) {
                approverGroupIds.add(approval.sbaa__Approver__r.sbaa__GroupId__c);
            }
        }

        Map<Id, User> mapUsers = new Map<Id, User>(
            [SELECT Id, Email FROM User WHERE isActive = true AND Id IN :approverUserIds]
        );

        Map<Id, List<User>> mapGroupUsers = new Map<Id, List<User>>();
        for (GroupMember gm : [
            SELECT GroupId, UserOrGroupId, UserOrGroup.Email 
            FROM GroupMember 
            WHERE UserOrGroup.Email != null AND GroupId IN :approverGroupIds
        ]) {
            if (!mapGroupUsers.containsKey(gm.GroupId)) {
                mapGroupUsers.put(gm.GroupId, new List<User>());
            }
            mapGroupUsers.get(gm.GroupId).add((User)gm.UserOrGroup);
        }

        List<Messaging.SingleEmailMessage> listEmails = new List<Messaging.SingleEmailMessage>();
        for (sbaa__Approval__c approval : approvals) {
            if (approval.sbaa__Approver__r.sbaa__User__c != null) {
                listEmails.add(buildEmail(mapUsers.get(approval.sbaa__Approver__r.sbaa__User__c).Id, approval.Id));
            } else if (approval.sbaa__Approver__r.sbaa__GroupId__c != null) {
                for (User u : mapGroupUsers.get(approval.sbaa__Approver__r.sbaa__GroupId__c)) {
                    listEmails.add(buildEmail(u.Id, approval.Id));
                }
            }
        }

        Messaging.sendEmail(listEmails);
    }

    private static Messaging.SingleEmailMessage buildEmail(Id userId, Id approvalId) {
        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(
            String.valueOf(TEMPLATE.Id),
            String.valueOf(userId),
            String.valueOf(approvalId)
        );
        mail.setSaveAsActivity(false);
        return mail;
    }

    public class InputVariables {
        @InvocableVariable(label='Approvals' description='List of approvals')
        public List<Id> approvalIds;
    }
}