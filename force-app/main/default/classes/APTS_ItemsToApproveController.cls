public With Sharing class APTS_ItemsToApproveController {

 @AuraEnabled
    public static List<Apttus_Approval__Approval_Request__c> getAllApprovalRequests(String appName){
        System.debug('##### : '+appName);
        Set<String> objectNames = New Set<String>();
        if(appName == 'CLM_Home'){
            objectNames.add('Apttus__APTS_Agreement__c');
            objectNames.add('Apttus__Agreement_Clause__c');
            objectNames.add('Apttus__Agreement_Term_Exception__c');
        }
        else if(appName == 'CPQ_Home'){
            objectNames.add('Apttus_Proposal__Proposal__c');
            objectNames.add('Apttus_Config2__ProductConfiguration__c');
            objectNames.add('Apttus_Config2__LineItem__c');
        }
        else{
            objectNames.add('Apttus__APTS_Agreement__c');
            objectNames.add('Apttus__Agreement_Clause__c');
            objectNames.add('Apttus__Agreement_Term_Exception__c');
            objectNames.add('Apttus_Proposal__Proposal__c');
            objectNames.add('Apttus_Config2__ProductConfiguration__c');
            objectNames.add('Apttus_Config2__LineItem__c');
        }
        return [SELECT id,Apttus_Approval__Object_Id__c,Apttus_Approval__Object_Id_Link__c,Apttus_Approval__Object_Name__c
                ,Apttus_Approval__Object_Type__c,Apttus_Approval__Request_Comments__c,Apttus_Approval__SubmissionComment1__c,
                Apttus_Approval__DateAssigned__c,Apttus_Approval__Approval_Status__c
                FROM Apttus_Approval__Approval_Request__c
                WHERE (Apttus_Approval__Approval_Status__c = 'Assigned' OR Apttus_Approval__Approval_Status__c = 'Reassigned')
                AND Apttus_Approval__Assigned_To_Id__c =: UserInfo.getUserId()
                AND Apttus_Approval__Object_Type__c IN : objectNames
                ORDER BY Apttus_Approval__DateAssigned__c
               ];
    }
   
     @AuraEnabled
    public static Integer getApprovalRequestsCount(String appName){
       List<Apttus_Approval__Approval_Request__c> approvalReqList = getAllApprovalRequests(appName);
        return approvalReqList.size();
    }
   
}