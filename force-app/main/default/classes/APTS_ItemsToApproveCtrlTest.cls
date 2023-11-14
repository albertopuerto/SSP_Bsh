/*************************************************************
@Name: APTS_ItemsToApproveCtrlTest
@Author:Apttus
@Description: Tests APTS_ItemsToApproveController

******************************************************************/
@isTest
private class APTS_ItemsToApproveCtrlTest {
    static testMethod void myUnitTest() {
    
    List<Apttus_Approval__Approval_Request__c> approvalRequestList = new List<Apttus_Approval__Approval_Request__c>();
    
    Apttus_Approval__Approval_Request__c approvalRequest = new Apttus_Approval__Approval_Request__c();
    approvalRequest.Apttus_Approval__Object_Type__c = 'Apttus__APTS_Agreement__c';
    approvalRequest.Apttus_Approval__Approval_Status__c = 'Assigned';
    approvalRequest.Apttus_Approval__Assigned_To_Id__c = UserInfo.getUserId();
    approvalRequestList.add(approvalRequest);
    
    Apttus_Approval__Approval_Request__c approvalRequest1 = new Apttus_Approval__Approval_Request__c();
    approvalRequest1.Apttus_Approval__Object_Type__c = 'Apttus_Proposal__Proposal__c';
    approvalRequest1.Apttus_Approval__Approval_Status__c = 'Reassigned';
    approvalRequest1.Apttus_Approval__Assigned_To_Id__c = UserInfo.getUserId();
    approvalRequestList.add(approvalRequest1); 
        
    insert approvalRequestList;
        
      Test.startTest();
        
        String appName = 'CLM_Home';
       	APTS_ItemsToApproveController.getApprovalRequestsCount(appName);
        String appName1 = 'CPQ_Home';
        APTS_ItemsToApproveController.getApprovalRequestsCount(appName1);
        String appName2 = '';
        APTS_ItemsToApproveController.getApprovalRequestsCount(appName2);
      Test.stopTest();
     
    }

}