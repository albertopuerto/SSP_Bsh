/**
 * @description Test class for ApprovalTrigger and ApprocalHandler class
 * @author SNV1SF
 * @date 2025
 */

@isTest
private class ApprovalTriggerTest {
   
    @TestSetup
    static void setupTestData() {
 
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        // Create creator user
        User creator = (User)TestFactory.CreateSobject(new User(), 'TestFactoryDefaults.SalesReadUserDefaults', false);
        creator.Alias = 'creator';
        creator.Email = 'creator@example.com';
        creator.LastName = 'Creator';
        creator.FederationIdentifier = 'creator@etasbosch.com' + system.currentTimeMillis();
        creator.Username = 'creator@etasbosch.com' + system.currentTimeMillis();
        insert creator;
        
        // Create approver user
        User approver = (User)TestFactory.CreateSobject(new User(), 'TestFactoryDefaults.SalesReadUserDefaults', false);
        approver.Alias = 'approver';
        approver.Email = 'approver@example.com';
        approver.LastName = 'Approver';
        approver.FederationIdentifier = 'approver@etasbosch.com' + system.currentTimeMillis();
        approver.Username = 'approver@etasbosch.com' + system.currentTimeMillis();
        insert approver;        
        
        User approver2 = (User)TestFactory.CreateSobject(new User(), 'TestFactoryDefaults.SalesReadUserDefaults', false);
        approver2.Alias = 'approv2';
        approver2.Email = 'approver2@example.com';
        approver2.LastName = 'Approver2';
        approver2.FederationIdentifier = 'approver2@etasbosch.com' + system.currentTimeMillis();
        approver2.Username = 'approver2@etasbosch.com' + system.currentTimeMillis();
        insert approver2;
       
        // Create New Owner user
        User newOwner = (User)TestFactory.CreateSobject(new User(), 'TestFactoryDefaults.SalesReadUserDefaults', false);
        newOwner.Alias = 'newowner';
        newOwner.Email = 'newowner@example.com';
        newOwner.LastName = 'NewOwner';
        newOwner.FederationIdentifier = 'newowner@etasbosch.com' + system.currentTimeMillis();
        newOwner.Username = 'newowner@etasbosch.com' + system.currentTimeMillis();
        newowner.isActive = true;
        insert newOwner;       
        
        // Create Public Group
        Group grp = new Group();
        grp.Name = 'Approvers Group';
        grp.DeveloperName = 'ApproversGroup';
        grp.Type ='Regular';
        insert grp;

        // Create Account
        Account account = (Account)TestFactory.createSObject(new Account(),'TestFactoryDefaults.AccountDefaults', true);  
        
        //Create Sales Area
        SalesArea__c salesArea = (SalesArea__c)TestFactory.createSObject(new SalesArea__c(),'TestFactoryDefaults.SalesAreaDefaults', true);
        
        //Create Sales Data Customer
        SalesAreaLink__c salesAreaLink = (SalesAreaLink__c)TestFactory.createSObject(new SalesAreaLink__c(),'TestFactoryDefaults.SalesAreaLinkDefaults', false);
        salesAreaLink.mdr_Account__c = account.Id;
        salesAreaLink.mdr_SalesArea__c = salesArea.Id;
        insert salesAreaLink;
        
        // Create Opportunity
        Opportunity opp = (Opportunity)TestFactory.createSObject(new Opportunity(),'TestFactoryDefaults.OpportunityDefaults', false);
        opp.Name ='Test Opportunity for quote approval';
        opp.AccountId = account.Id;
        opp.lkp_SalesDataCustomer__c = salesAreaLink.Id;
        insert opp;    

        // Create Quote
        SBQQ__Quote__c quote = (SBQQ__Quote__c)TestFactory.createSObject(new SBQQ__Quote__c(),'TestFactoryDefaults.QuoteDefaults', false);
        quote.SBQQ__Status__c = 'In Review';
        quote.SBQQ__Account__c = account.Id;
        quote.SBQQ__Opportunity2__c = opp.Id; 
        insert quote;
 
    }
    
   @future   
   public static void insertGroupMembers(){
        
       // Create Approver Group Member
        User member1 = (User)TestFactory.CreateSobject(new User(), 'TestFactoryDefaults.SalesReadUserDefaults', false);
        member1.Alias = 'member1';
        member1.Email = 'member1@example.com';
        member1.LastName = 'Member1';
        member1.FederationIdentifier = 'member1@etasbosch.com' + system.currentTimeMillis();
        member1.Username = 'member1@etasbosch.com' + system.currentTimeMillis();
        insert member1;

        Group grpRecord = [SELECT Id FROM Group WHERE DeveloperName = 'ApproversGroup' LIMIT 1];
        List<GroupMember> listMembers = new List<GroupMember>();
        GroupMember grpMember1 = new GroupMember();
        grpMember1.GroupId = grpRecord.Id;
        grpMember1.UserOrGroupId = member1.Id;
        listMembers.add(grpMember1); 
  }
    
    @future  
    public static void setPermissions(){
   
      User newOwner = [SELECT Id FROM User WHERE Alias = 'newowner' LIMIT 1];
               
      // Assign Permission Set Licenses and Permission Sets  
      PermissionSetLicense cpqLicense = [SELECT Id FROM permissionSetLicense WHERE DeveloperName = 'SalesforceCPQ_CPQStandardPerm' LIMIT 1];
      PermissionSetLicenseAssign cpqPSL = new PermissionSetLicenseAssign();
      cpqPSL.AssigneeId = newOwner.Id;
      cpqPSL.PermissionSetLicenseId = cpqLicense.Id;
      insert cpqPSL;

      PermissionSet cpqPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'CPQEnhancedUser' LIMIT 1];
      PermissionSetAssignment cpqPSAssign = new PermissionSetAssignment();
      cpqPSAssign.PermissionSetId = cpqPS.Id;
      cpqPSAssign.AssigneeId = newOwner.Id;
      insert cpqPSAssign;
      
      PermissionSetLicense aprLicense = [SELECT Id FROM permissionSetLicense WHERE DeveloperName =  'SalesforceCPQ_CPQAAPerm' LIMIT 1];
      PermissionSetLicenseAssign pslAdAppr = new PermissionSetLicenseAssign();
      pslAdAppr.AssigneeId = newOwner.Id;
      pslAdAppr.PermissionSetLicenseId = aprLicense.Id;
      insert pslAdAppr;
      
      PermissionSet aprPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'CPQAdvancedApprovalsUser' LIMIT 1];
      PermissionSetAssignment psa = new PermissionSetAssignment();
      psa.PermissionSetId = aprPS.Id;
      psa.AssigneeId = newOwner.Id;
      insert psa;
   
   }      
    
 @isTest
    static void validateSharingRecordAfterInsert() {
        
       // Get test data from setup
       Account acc = [SELECT Id FROM Account LIMIT 1];
       Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
       SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];     
       User approver = [SELECT Id FROM User WHERE Alias = 'approver' LIMIT 1];
       User creator = [SELECT Id FROM User WHERE Alias = 'creator' LIMIT 1];
     
       System.runAs(creator){

          // Create approval record 
          sbaa__Approval__c appr = new sbaa__Approval__c();
          appr.sbaa__Status__c = 'Requested';
          appr.Quote__c = quote.Id;
          appr.OwnerId = creator.Id;
          appr.sbaa__RecordField__c = 'Quote__c';
          appr.sbaa__ApprovalStep__c = 1;     
          appr.sbaa__AssignedTo__c = approver.Id; 
                               
          Test.startTest();     
               Database.SaveResult result = Database.insert(appr, false);
          Test.stopTest();
           
          Assert.areEqual(true, result.isSuccess(), 'Insert should succeed');

          // Get Share record 
          List<sbaa__Approval__Share> sharedRecs = [SELECT ParentId, AccessLevel, UserOrGroupId FROM sbaa__Approval__Share WHERE ParentId =:appr.Id AND AccessLevel = 'Edit'];
         
          Assert.areEqual(1, sharedRecs.size(), 'Exactly one share record should be created for approver');     
          Assert.areEqual('Edit', sharedRecs[0].AccessLevel, 'Approver should have Edit access');
          Assert.areEqual(appr.sbaa__AssignedTo__c, sharedRecs[0].UserOrGroupId, 'User Id should match');                  

    }
        
    }
  
 @isTest
    static void validateSharingRecordAfterInsertAsCreator() {
        
       // Get test data from setup
       Account acc = [SELECT Id FROM Account LIMIT 1];
       Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
       SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1]; 
       User creator = [SELECT Id FROM User WHERE Alias = 'creator' LIMIT 1];
     
       System.runAs(creator){

          // Create approval record 
          sbaa__Approval__c appr = new sbaa__Approval__c();
          appr.sbaa__Status__c = 'Requested';
          appr.Quote__c = quote.Id;
          appr.OwnerId = creator.Id;
          appr.sbaa__RecordField__c = 'Quote__c';
          appr.sbaa__ApprovalStep__c = 1;     
          appr.sbaa__AssignedTo__c = creator.Id; 
                               
          Test.startTest();     
               Database.SaveResult result = Database.insert(appr, false);
          Test.stopTest();
           
          Assert.areEqual(true, result.isSuccess(), 'Insert should succeed');

          // Get Share record 
          List<sbaa__Approval__Share> sharedRecs = [SELECT ParentId, AccessLevel, UserOrGroupId FROM sbaa__Approval__Share WHERE ParentId =:appr.Id];
         
          Assert.areEqual(1, sharedRecs.size(), 'Only one Share record should exist for the creator');                   

    }            
        
  } 
   
    
@isTest
   static void validateSharingRecordsAfterInsertMultipleApprovals() {
        
       // Get test data from setup
       Account acc = [SELECT Id FROM Account LIMIT 1];
       Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
       SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];     
       User approver = [SELECT Id FROM User WHERE Alias = 'approver' LIMIT 1];
       User approver2 = [SELECT Id FROM User WHERE Alias = 'approv2' LIMIT 1];
       User creator = [SELECT Id FROM User WHERE Alias = 'creator' LIMIT 1];
     
       System.runAs(creator){
           
          // Create approval records 
          List<sbaa__Approval__c> listApprovals = new List<sbaa__Approval__c>();
          sbaa__Approval__c appr = new sbaa__Approval__c();
          appr.sbaa__Status__c = 'Requested';
          appr.Quote__c = quote.Id;
          appr.OwnerId = creator.Id;
          appr.sbaa__RecordField__c = 'Quote__c';
          appr.sbaa__ApprovalStep__c = 1;     
          appr.sbaa__AssignedTo__c = approver.Id; 
          listApprovals.add(appr);
           
          sbaa__Approval__c appr2 = new sbaa__Approval__c();
          appr2.sbaa__Status__c = 'Requested';
          appr2.Quote__c = quote.Id;
          appr2.OwnerId = creator.Id;
          appr2.sbaa__RecordField__c = 'Quote__c';
          appr2.sbaa__ApprovalStep__c = 1;     
          appr2.sbaa__AssignedTo__c = approver2.Id;  
          listApprovals.add(appr2); 
                               
          Test.startTest();     
               List<Database.SaveResult> results = Database.insert(listApprovals, false);  
          Test.stopTest();
           
          Assert.areEqual(2, results.size(), 'Two approval records should be inserted');

          // Get Share records
          List<sbaa__Approval__Share> sharedRecs = [SELECT ParentId, AccessLevel, UserOrGroupId FROM sbaa__Approval__Share WHERE ParentId IN (:appr.Id, :appr2.Id) AND AccessLevel = 'Edit'];
         
          Assert.areEqual(2, sharedRecs.size(), 'Exactly two share records should be created - one per each approver');     
          Assert.areEqual('Edit', sharedRecs[0].AccessLevel, 'Approver should have Edit access');
          Assert.areEqual('Edit', sharedRecs[1].AccessLevel, 'Approver2 should have Edit access');
          Assert.areEqual(appr.sbaa__AssignedTo__c, sharedRecs[0].UserOrGroupId, 'User Id should match');    
          Assert.areEqual(appr2.sbaa__AssignedTo__c, sharedRecs[1].UserOrGroupId, 'User Id should match');
          Assert.areNotEqual(sharedRecs[0].UserOrGroupId, sharedRecs[1].UserOrGroupId, 'User Ids should be different'); 

    }
        
 }
    
   
   
@isTest
   static void validateSharingRecordAfterInsertGroupApprover() {

      // Get test data from setup
      Account acc = [SELECT Id FROM Account LIMIT 1];
      Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
      SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];      
      Group grpApprover = [SELECT Id FROM Group WHERE DeveloperName = 'ApproversGroup' LIMIT 1 ];
      User creator = [SELECT Id FROM User WHERE Alias = 'creator' LIMIT 1];
     
      System.runAs(creator){
           // Create approval record for Approver group
           sbaa__Approval__c appr = new sbaa__Approval__c();
           appr.sbaa__Status__c = 'Requested';
           appr.Quote__c = quote.Id;
           appr.sbaa__RecordField__c = 'Quote__c';
           appr.sbaa__ApprovalStep__c = 1;
           appr.sbaa__AssignedGroupId__c = grpApprover.Id;       
             

           Test.startTest();   
                Database.SaveResult result = Database.insert(appr, false);
           Test.stopTest();
           
           Assert.areEqual(true, result.isSuccess(), 'Insert should succeed');
           
          // Get Share record for Approver group   
           List<sbaa__Approval__Share> sharedRecs = [SELECT ParentId, AccessLevel, UserOrGroupId FROM sbaa__Approval__Share WHERE ParentId =:appr.Id AND AccessLevel = 'Edit'];

           Assert.areEqual(1, sharedRecs.size(), 'Exactly one share record should be created for group');
           Assert.areEqual('Edit', sharedRecs[0].AccessLevel, 'Approver should have Edit access');
           Assert.areEqual(appr.sbaa__AssignedGroupId__c, sharedRecs[0].UserOrGroupId, 'Group Id should match');       
                
       }                            
            
  } 
    
@isTest
    static void validateSharingRecordsAfterInsertMixedApprovals() {
        
       // Get test data from setup
       Account acc = [SELECT Id FROM Account LIMIT 1];
       Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
       SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];     
       User approver = [SELECT Id FROM User WHERE Alias = 'approver' LIMIT 1];
       Group grpApprover = [SELECT Id FROM Group WHERE DeveloperName = 'ApproversGroup' LIMIT 1 ];
       User creator = [SELECT Id FROM User WHERE Alias = 'creator' LIMIT 1];
     
        System.runAs(creator){
            
          // Create approval records
          List<sbaa__Approval__c> listApprovals = new List<sbaa__Approval__c>();
          sbaa__Approval__c appr = new sbaa__Approval__c();
          appr.sbaa__Status__c = 'Requested';
          appr.Quote__c = quote.Id;
          appr.OwnerId = creator.Id;
          appr.sbaa__RecordField__c = 'Quote__c';
          appr.sbaa__ApprovalStep__c = 1;     
          appr.sbaa__AssignedTo__c = approver.Id; 
          listApprovals.add(appr);
          
          sbaa__Approval__c appr2 = new sbaa__Approval__c();
          appr2.sbaa__Status__c = 'Requested';
          appr2.Quote__c = quote.Id;
          appr2.OwnerId = creator.Id;
          appr2.sbaa__RecordField__c = 'Quote__c';
          appr2.sbaa__ApprovalStep__c = 1;     
          appr2.sbaa__AssignedGroupId__c = grpApprover.Id;
          listApprovals.add(appr2); 
                              
          Test.startTest();     
               List<Database.SaveResult> results = Database.insert(listApprovals, false);
          Test.stopTest();
           
          Assert.areEqual(2, results.size(), 'Two approval records should be inserted');

          // Get Share records
          List<sbaa__Approval__Share> sharedRecs = [SELECT ParentId, AccessLevel, UserOrGroupId FROM sbaa__Approval__Share WHERE ParentId IN (:appr.Id, :appr2.Id) AND AccessLevel = 'Edit'];
         
          Assert.areEqual(2, sharedRecs.size(), 'Exactly two share records should be created - one per approver and one per approver group');     
          Assert.areEqual('Edit', sharedRecs[0].AccessLevel, 'Approver should have Edit access');
          Assert.areEqual('Edit', sharedRecs[1].AccessLevel, 'Approver group should have Edit access');
          Assert.areEqual(appr.sbaa__AssignedTo__c, sharedRecs[0].UserOrGroupId, 'User Id should match');    
          Assert.areEqual(appr2.sbaa__AssignedGroupId__c, sharedRecs[1].UserOrGroupId, 'Group Id should match');
          Assert.areNotEqual(sharedRecs[0].UserOrGroupId, sharedRecs[1].UserOrGroupId, 'Ids should be different'); 

    }
        
    }    
        
@isTest
  static void validateSharingRecordAfterUpdate(){
      
      // Get test data from setup
      Account acc = [SELECT Id FROM Account LIMIT 1];
      Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
      SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
      User approver = [SELECT Id FROM User WHERE Alias = 'approver' LIMIT 1];
      User creator = [SELECT Id FROM User WHERE Alias = 'creator' LIMIT 1];
      User newOwner = [SELECT Id FROM User WHERE Alias = 'newowner' LIMIT 1];

      // Create approval record
      sbaa__Approval__c appr = new sbaa__Approval__c();
      appr.sbaa__Status__c = 'Requested';
      appr.Quote__c = quote.Id;
      appr.OwnerId = newOwner.Id;
      appr.sbaa__RecordField__c = 'Quote__c';
      appr.sbaa__ApprovalStep__c = 1;     
      appr.sbaa__AssignedTo__c = approver.Id; 
    
      Test.startTest();
         Database.SaveResult result = Database.insert(appr, false);
         Assert.areEqual(true, result.isSuccess(), 'Insert should succeed');

         // Get Share record   
         sbaa__Approval__Share initShare = [SELECT Id, ParentId, AccessLevel, UserOrGroupId FROM sbaa__Approval__Share WHERE ParentId =:appr.Id AND AccessLevel = 'Edit' LIMIT 1];
       
         Assert.areEqual('Edit', initShare.AccessLevel, 'The approver should have Edit access in the inital share');
         Assert.areEqual(appr.sbaa__AssignedTo__c, initShare.UserOrGroupId, 'Initial share should target AssignedTo user');
      
         // Delete Share record
         delete initShare;

         sbaa__Approval__c savedAppr = [SELECT Id, OwnerId, sbaa__AssignedTo__c, sbaa__Status__c, Quote__c, sbaa__RecordField__c, sbaa__ApprovalStep__c,sbaa__AssignedGroupId__c
                                             FROM sbaa__Approval__c WHERE Id = :appr.Id];
          
          // Assign permissions
          ApprovalTriggerTest.setPermissions();
          savedAppr.OwnerId = newOwner.Id;
      
        System.runAs(newOwner){
            
          //Change approval owner
          Database.SaveResult updResult = Database.update( savedAppr, false);
          Assert.areEqual(true, result.isSuccess(), 'Update should succeed');

          //Create new Share record  
          sbaa__Approval__Share newShare = new sbaa__Approval__Share();
          newShare.ParentId = appr.Id;  
          newShare.AccessLevel = 'Edit';
          newshare.UserOrGroupId = appr.sbaa__AssignedTo__c;
  
          Database.SaveResult insResult = Database.insert(newShare, false);    
          Assert.areEqual(true, result.isSuccess(), 'Insert should succeed');

          //Get new Share record  
          sbaa__Approval__Share latestShare = [SELECT Id, ParentId, AccessLevel, UserOrGroupId FROM sbaa__Approval__Share 
                                            WHERE ParentId = :appr.Id AND AccessLevel = 'Edit' LIMIT 1];
 
          Assert.areNotEqual(latestShare.Id, initShare.Id, 'A NEW share record must be inserted after owner change'); 
          Assert.areEqual('Edit', latestShare.AccessLevel, 'Approver should have Edit access');
          Assert.areEqual(appr.sbaa__AssignedTo__c, latestShare.UserOrGroupId, 'User Id should match');     
      }
      
      Test.stopTest();

  }  
     
    
@isTest
  static void validateSharingRecordAfterUpdateGroupApprover(){
      
       // Get test data from setup 
       Account acc = [SELECT Id FROM Account LIMIT 1];
       Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
       SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
       Group grpApprover = [SELECT Id FROM Group WHERE DeveloperName = 'ApproversGroup' LIMIT 1 ];
       User creator = [SELECT Id FROM User WHERE Alias = 'creator' LIMIT 1];
       User newOwner = [SELECT Id FROM User WHERE Alias = 'newowner' LIMIT 1];

       // Create approval record for Approver Group
       sbaa__Approval__c appr = new sbaa__Approval__c();
       appr.sbaa__Status__c = 'Requested';
       appr.Quote__c = quote.Id;
       appr.OwnerId = creator.Id;
       appr.sbaa__RecordField__c = 'Quote__c';
       appr.sbaa__ApprovalStep__c = 1;
       appr.sbaa__AssignedGroupId__c = grpApprover.Id;   
      
  Test.startTest();
       ApprovalTriggerTest.setPermissions();
  Test.stopTest();
      
        Database.SaveResult result = Database.insert(appr, false);
        Assert.areEqual(true, result.isSuccess(), 'Insert should succeed');    
      
        // Get Share record for Approver Group
        sbaa__Approval__Share initShare = [SELECT Id, ParentId, AccessLevel, UserOrGroupId FROM sbaa__Approval__Share WHERE ParentId =:appr.Id AND AccessLevel = 'Edit' LIMIT 1];
        Assert.areEqual('Edit', initShare.AccessLevel, 'The Approver group should have Edit access in the inital share');
        Assert.areEqual(appr.sbaa__AssignedGroupId__c, initShare.UserOrGroupId, 'Initial share should target group approvers');
     
        //Delete Share record for Approver Group
        delete initShare;
      
        // Get approval record
        sbaa__Approval__c savedApprGroup = [SELECT Id, OwnerId, sbaa__AssignedTo__c, sbaa__Status__c, Quote__c, sbaa__RecordField__c, sbaa__ApprovalStep__c, sbaa__AssignedGroupId__c
                                            FROM sbaa__Approval__c WHERE Id = :appr.Id];
  
        savedApprGroup.OwnerId = newOwner.Id;
      
        // Change approval owner
        Database.SaveResult updResult = Database.update(savedApprGroup, false);
        Assert.areEqual(true, result.isSuccess(), 'Update should succeed');
      
      System.runAs(newOwner){  

        // Create new Share record for Approver Group
        sbaa__Approval__Share newShare = new sbaa__Approval__Share();
        newShare.ParentId = appr.Id;  
        newShare.AccessLevel = 'Edit';
        newshare.UserOrGroupId = appr.sbaa__AssignedGroupId__c;
  
        Database.SaveResult insResult = Database.insert(newShare, false);    
        Assert.areEqual(true, result.isSuccess(), 'Insert should succeed');
               
        // Get new Share record for Approver Group
        sbaa__Approval__Share latestShare = [SELECT Id, ParentId, AccessLevel, UserOrGroupId FROM sbaa__Approval__Share 
                                            WHERE ParentId = :appr.Id AND AccessLevel = 'Edit' LIMIT 1];

        Assert.areNotEqual(latestShare.Id, initShare.Id, 'A NEW share record must be inserted after owner change'); 
        Assert.areEqual('Edit', latestShare.AccessLevel, 'Approver should have Edit access');
        Assert.areEqual(appr.sbaa__AssignedGroupId__c, latestShare.UserOrGroupId, 'User Id should match');     
      }

  } 
                
 @isTest
   static void validateSharingRecordBeforeInsertError(){
       
       // Get test data from setup
       Account acc = [SELECT Id FROM Account LIMIT 1];
       Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];      
       SBQQ__Quote__c quote = new SBQQ__Quote__c();     
       User approver = [SELECT Id FROM User WHERE Alias = 'approver' LIMIT 1];
       User creator = [SELECT Id FROM User WHERE Alias = 'creator' LIMIT 1];
          
       System.runAs(creator){
      
           // Create approval record where creator is approver
           sbaa__Approval__c appr = new sbaa__Approval__c();
           appr.sbaa__Status__c = 'Approved';
           appr.Quote__c = quote.Id;
           appr.OwnerId = creator.Id;
           appr.sbaa__RecordField__c = 'Quote__c';
           appr.sbaa__ApprovalStep__c = 1; 
           appr.sbaa__AssignedTo__c = creator.Id; 
           appr.sbaa__CommentsLong__c = 'Yes';
           appr.sbaa__ApprovedBy__c = creator.Id;
                
           Test.startTest();                        
              Database.SaveResult result = Database.insert(appr, false);
           Test.stopTest();
    
          Assert.areEqual(false, result.isSuccess(), 'Expected insert to fail, because ApprovedBy = CreatedBy');
          Assert.isTrue(result.getErrors()[0].getMessage().contains(Label.ApprovalCreatorCannotApprove),
          'Expected error message to contain the label ApprovalCreatorCannotApprove' );  
       }
                  
    }   

 @isTest
 static void validateSharingRecordBeforeInsertGroupApproverError(){
     
       // Get test data from setup   
       Account acc = [SELECT Id FROM Account LIMIT 1];
       Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
       SBQQ__Quote__c quote = new SBQQ__Quote__c();
       Group grpApprover = [SELECT Id FROM Group WHERE DeveloperName = 'ApproversGroup' LIMIT 1 ];
       User creator = [SELECT Id FROM User WHERE Alias = 'creator' LIMIT 1];
       List<GroupMember> members = [SELECT Id, UserOrGroupId FROM GroupMember WHERE GroupId =:grpApprover.Id];
            
       if(members.size() > 0) {
           
            // Create approval record where creator is Approver group member 
            for (GroupMember member : members){                 
               System.runAs(new User(Id = member.UserOrGroupId)){
    
                 sbaa__Approval__c appr = new sbaa__Approval__c();
                 appr.sbaa__Status__c = 'Approved';
                 appr.Quote__c = quote.Id;
                 appr.OwnerId = creator.Id;
                 appr.sbaa__RecordField__c = 'Quote__c';
                 appr.sbaa__ApprovalStep__c = 1;     
                 appr.sbaa__AssignedGroupId__c = grpApprover.Id;  
                 appr.sbaa__CommentsLong__c = 'Yes';
                 appr.sbaa__ApprovedBy__c = creator.Id;
       
             Test.startTest();           
                  Database.SaveResult result = Database.insert(appr, false);
             Test.stopTest();   
      
              Assert.areEqual(false, result.isSuccess(), 'Expected insert to fail, because ApprovedBy = CreatedBy');
              Assert.isTrue(result.getErrors()[0].getMessage().contains(Label.ApprovalCreatorCannotApprove),
              'Expected error message to contain the label ApprovalCreatorCannotApprove');  
           }   
       }
    }
 } 
  
@isTest
   static void validateSharingRecordBeforeUpdateError(){
         
      // Get test data from setup 
      Account acc = [SELECT Id FROM Account LIMIT 1];
      Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
      SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];        
      User approver = [SELECT Id FROM User WHERE Alias = 'approver' LIMIT 1];
      User creator = [SELECT Id FROM User WHERE Alias = 'creator' LIMIT 1];
          
      System.runAs(creator){
            
           // Create approval record where creator is approver
           sbaa__Approval__c appr = new sbaa__Approval__c();
           appr.sbaa__Status__c = 'Requested';
           appr.OwnerId = creator.Id;
           appr.Quote__c = quote.Id;
           appr.sbaa__RecordField__c = 'Quote__c';
           appr.sbaa__ApprovalStep__c = 1;     
           appr.sbaa__AssignedTo__c = approver.Id; 
           insert appr;

           // Get approval record
           Map<Id, sbaa__Approval__c> oldMap = new Map<Id, sbaa__Approval__c>([SELECT Id, OwnerId, sbaa__ApprovedBy__c FROM sbaa__Approval__c WHERE Id = :appr.Id]);
 
            // Approve as creator
            appr.sbaa__ApprovedBy__c = creator.Id;
            appr.sbaa__CommentsLong__c = 'Yes';
            appr.sbaa__Status__c = 'Approved';

    Test.startTest();           
            Database.SaveResult result = Database.update(appr, false);
     Test.stopTest();         

      Assert.areEqual(false, result.isSuccess(), 'Expected update to fail because ApprovedBy = CreatedBy');
      Assert.isTrue(result.getErrors().size() > 0,'Expected error on update when ApprovedBy = CreatedBy');       
      Assert.isTrue(result.getErrors()[0].getMessage().contains(Label.ApprovalCreatorCannotApprove),
            'Error message should contain ApprovalCreatorCannotApprove');  
        } 
   }
                  
@isTest
    static void validateSharingRecordBeforeUpdateGroupApproverError(){
        
       
       // Get test data from setup  
       Account acc = [SELECT Id FROM Account LIMIT 1];
       Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
       SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1]; 
       Group grpApprover = [SELECT Id FROM Group WHERE DeveloperName = 'ApproversGroup' LIMIT 1 ];
       User creator = [SELECT Id FROM User WHERE Alias = 'creator' LIMIT 1];
       List<GroupMember> members = [SELECT Id, UserOrGroupId, GroupId FROM GroupMember WHERE GroupId = :grpApprover.Id];

        GroupMember member2 = new GroupMember();
        member2.GroupId = grpApprover.Id;
        member2.UserOrGroupId = creator.Id;
        members.add(member2);
        insert members;
    
        if(members.size() > 0) {        
   
         // Create approval record where creator is member of Approval group  
         for (GroupMember member : members){     
           System.runAs(new User(Id = member.UserOrGroupId)){    
                                      
            sbaa__Approval__c appr = new sbaa__Approval__c();
            appr.sbaa__Status__c = 'Requested';
            appr.OwnerId = creator.Id;
            appr.Quote__c = quote.Id;
            appr.sbaa__RecordField__c = 'Quote__c';
            appr.sbaa__ApprovalStep__c = 1; 
            appr.sbaa__AssignedGroupId__c = grpApprover.Id; 
            insert appr;

            // Get approval record   
            Map<Id, sbaa__Approval__c> oldMap = new Map<Id, sbaa__Approval__c>([SELECT Id, OwnerId, sbaa__ApprovedBy__c FROM sbaa__Approval__c WHERE Id = :appr.Id]);
 
            // Approve as creator
            appr.sbaa__ApprovedBy__c = member2.UserOrGroupId;
            appr.sbaa__CommentsLong__c = 'Yes';
            appr.sbaa__Status__c = 'Approved';
            
     Test.startTest();           
            Database.SaveResult result = Database.update(appr, false);  
     Test.stopTest();                  
       
       Assert.areEqual(false, result.isSuccess(),'Expected update to fail because approver is the creator');
       Assert.isTrue(result.getErrors().size() > 0, 'Expected an error when approver is the creator');
       Assert.isTrue(result.getErrors()[0].getMessage().contains(Label.ApprovalCreatorCannotApprove),
            'Error message should contain ApprovalCreatorCannotApprove');
            }
         }   
      }
   } 
}