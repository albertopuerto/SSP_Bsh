public without sharing class GetApproversEmail {


    @InvocableMethod(label='Send email to approvers' description='Method used to get the ids of the approvers to send the notification')
    public static List<OutputParameters> getApproverIds(List<InputVariables> listApprovals) {
 
        Set<Id> approvalIds = new Set<Id>(listApprovals[0].approvalIds);

        List<sbaa__Approval__c> approvals = new ApprovalSelector().getApprovalApprovers(approvalIds);

        List<String> approverIds= new List<String>(); 
       
        for (sbaa__Approval__c approval : approvals) {
            if (approval.sbaa__Approver__r.sbaa__User__c != null) {
                approverIds.add(approval.sbaa__Approver__r.sbaa__User__c);
            } else if (approval.sbaa__Approver__r.sbaa__GroupId__c != null) {
                approverIds.add(approval.sbaa__ApprovedBy__c);
            }
        }

        List<OutputParameters> outputParameters = new List<OutputParameters>();
    
        OutputParameters outputParameter = new OutputParameters();
        outputParameter.approverIds= approverIds;

        outputParameters.add(outputParameter);
        return outputParameters;

    }

    public class InputVariables {
        @InvocableVariable(label='Approvals' description='List of approvals')
        public List<Id> approvalIds;
    }
    public class OutputParameters {
        @InvocableVariable(label='Approver Ids' description='List of approver Ids')
        public List<String> approverIds;
    }
}