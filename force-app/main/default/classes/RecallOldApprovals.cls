/**
 * @description       : Methods that sends an email to the user or group
 * @author            : APB
**/
public without sharing class RecallOldApprovals {
    /**
	* @author       APB
	* @description  Method that send the email to the users
	* @param		signatures List<InputVariables>
	* @return		List<String>
	*/
    @InvocableMethod(label='Recall approvals' description='Method used to recall the approvals sending an email to the user')
    public static void sendEmailToApprovers(List<InputVariables> listApprovals) {

        Map<Id,User> mapUsers = new Map<Id,User>();
        Map<sbaa__Approval__c,String> mapApprovalGroups = new Map<sbaa__Approval__c,String>();
        Map<String,List<User> > mapGroupUsers = new Map<String,List<User>>();
        Set<Id> approverUserIds = new Set<Id>();

        Set<Id>approvalIds= new Set<Id>();
        for(Id approvalId: listApprovals[0].approvalIds){
            approvalIds.add(approvalId);
        }

        List<sbaa__Approval__c> approvals =new ApprovalSelector().getApprovalApprovers(approvalIds);
        
        for(sbaa__Approval__c approval : approvals){
            approverUserIds.add(approval.sbaa__Approver__r.sbaa__User__c);
        }
        List<User> listUsers = [SELECT Id,Email FROM User where isActive=true AND Id IN: approverUserIds ];
        for(User user : listUsers){
            mapUsers.put(user.Id,user);
        }

        for(sbaa__Approval__c approval : approvals){
            System.debug(approval.sbaa__Approver__r.sbaa__User__c);
            System.debug(approval.sbaa__Approver__c);
            System.debug(approval);
            if(approval.sbaa__Approver__r.sbaa__User__c != null){
                sendEmail(mapUsers.get(approval.sbaa__Approver__r.sbaa__User__c),approval);
            }else if(approval.sbaa__Approver__r.sbaa__GroupId__c != null){
                mapApprovalGroups.put(approval,approval.sbaa__Approver__r.sbaa__GroupId__c);
            }
        }

        List<GroupMember> listGroupMembers = [SELECT Id, GroupId, UserOrGroupId,UserOrGroup.Email,  SystemModstamp FROM GroupMember where UserOrGroup.Email != null];
        for(GroupMember groupMember : listGroupMembers){
            if (!mapGroupUsers.containsKey(groupMember.GroupId)) {
                mapGroupUsers.put(groupMember.GroupId, new List<User>());
            }
            mapGroupUsers.get(groupMember.GroupId).add(groupMember.UserOrGroup);
        }

        for(sbaa__Approval__c approval : approvals){
            List<User> listUserApproval =mapGroupUsers.get(mapApprovalGroups.get(approval));
            if(listUserApproval != null){
                for(User user : listUserApproval){
                    sendEmail(user,approval);
                }
            }
        }
    }

    public static void sendEmail(User user,sbaa__Approval__c approval){
        EmailTemplate template = [SELECT Id, Name, DeveloperName, Markup FROM EmailTemplate where DeveloperName ='eml_ApprovalRequestTemplate'];

        
        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(String.valueOf(template.Id), String.valueOf(user.Id), String.valueOf(approval.Id));
        mail.setSaveAsActivity(false);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    /**
	* @author       APB
	* @description  InputVariables class has the approvals
	*/
    public class InputVariables {
        @InvocableVariable(label='Approvals' description='List of approvals')
        public List<Id> approvalIds;
    }
}