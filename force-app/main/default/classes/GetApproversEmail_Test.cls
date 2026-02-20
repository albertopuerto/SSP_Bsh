/**
* @author       APB
* @description  GetApproversEmail_Test
*/
@isTest
public class GetApproversEmail_Test {

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
       
        
        GetApproversEmail.InputVariables inputVariables = new GetApproversEmail.InputVariables();
        inputVariables.approvalIds= listApprovals;
        List<GetApproversEmail.InputVariables> listInputVariables = new List<GetApproversEmail.InputVariables>();
        
        listInputVariables.add(inputVariables);
        
        User productManagerUser = [SELECT Id from User LIMIT 1];
  
        Test.startTest();
         List<GetApproversEmail.OutputParameters> listApprovers = GetApproversEmail.getApproverIds(listInputVariables);
        System.assertEquals(1, listApprovers[0].approverIds.size(),'The email should be sent to the user');
        
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
        
        GetApproversEmail.InputVariables inputVariables = new GetApproversEmail.InputVariables();
        inputVariables.approvalIds= listApprovals;
        List<GetApproversEmail.InputVariables> listInputVariables = new List<GetApproversEmail.InputVariables>();
        
        listInputVariables.add(inputVariables);
     
        List<GetApproversEmail.OutputParameters> listApprovers = GetApproversEmail.getApproverIds(listInputVariables);
        System.assertEquals(1, listApprovers[0].approverIds.size(),'The email should be sent to the approved by user');
        
        Test.stopTest();

    }

}