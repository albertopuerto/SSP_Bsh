/**
* @author       APB
* @description  RecallOldApprovals_Test
*/
@isTest
public class RecallOldApprovals_Test {

    /**
    * @author       APB
    * @description  Method used to create the records
    */
    @testSetup
    public static void createRecords(){

    Group groupTest=new Group();
    groupTest.Name= 'test group';
    insert groupTest;
    User productManagerUser = (User)TestFactory.createSObject(new User(), 'TestFactoryDefaults.ProductManagerUserDefaults', true);
    sbaa__Approver__c userApprover= new sbaa__Approver__c();
    userApprover.sbaa__User__c = productManagerUser.Id;
    userApprover.Name= 'product manager user';
    insert userApprover;    
    
    sbaa__Approver__c groupApprover= new sbaa__Approver__c();
    groupApprover.sbaa__GroupId__c = groupTest.Id;
    groupApprover.Name= 'group Approver';
    insert groupApprover;
        
    sbaa__Approval__c userApproval= new sbaa__Approval__c();
    userApproval.sbaa__RecordField__c='Quote__c';
    userApproval.sbaa__Status__c= 'Requested';
    userApproval.sbaa__ApprovalStep__c= 1;
    userApproval.sbaa__Approver__c= userApprover.Id;
    insert userApproval;
    
    sbaa__Approval__c groupApproval= new sbaa__Approval__c();
   	groupApproval.sbaa__RecordField__c='Quote__c';
   	groupApproval.sbaa__Status__c= 'Requested';
    groupApproval.sbaa__ApprovalStep__c= 2;
    groupApproval.sbaa__Approver__c= groupApprover.Id;
    insert groupApproval;
   
    }

    @IsTest
    public static void sendRecallEmailToAnUser(){
        List<Id> listApprovals= new List<Id>(); 
        
       	sbaa__Approval__c userApproval = [Select Id from sbaa__Approval__c where sbaa__ApprovalStep__c= 1];
        listApprovals.add(userApproval.Id);
       
        
        RecallOldApprovals.InputVariables inputVariables = new RecallOldApprovals.InputVariables();
        inputVariables.approvalIds= listApprovals;
        List<RecallOldApprovals.InputVariables> listInputVariables = new List<RecallOldApprovals.InputVariables>();
        
        listInputVariables.add(inputVariables);
        
        User productManagerUser = [SELECT Id from User LIMIT 1];
  
        Test.startTest();
        RecallOldApprovals.sendEmailToApprovers(listInputVariables);
        
        System.assertEquals(1, Limits.getEmailInvocations(),'One email should have been invoked');
   		Test.stopTest();
    }
    
    @IsTest
    public static void sendRecallEmailToAGroup(){
        List<Id> listApprovals= new List<Id>();
            
        Group groupTest= [Select id from Group where Name ='test group'];
    	User productManagerUser = [SELECT Id from User LIMIT 1];
    	
        Test.startTest();
      
        sbaa__Approval__c groupApproval= [Select Id from sbaa__Approval__c where sbaa__ApprovalStep__c= 2];
        GroupMember grMember = new GroupMember();
    	grMember.UserOrGroupId= productManagerUser.Id;
    	grMember.GroupId= groupTest.Id;
    	insert grMember;
        listApprovals.add(groupApproval.Id);
        
        RecallOldApprovals.InputVariables inputVariables = new RecallOldApprovals.InputVariables();
        inputVariables.approvalIds= listApprovals;
        List<RecallOldApprovals.InputVariables> listInputVariables = new List<RecallOldApprovals.InputVariables>();
        
        listInputVariables.add(inputVariables);
     
        RecallOldApprovals.sendEmailToApprovers(listInputVariables);
        System.assertEquals(1, Limits.getEmailInvocations(),'One email should have been invoked');
        Test.stopTest();

    }

}