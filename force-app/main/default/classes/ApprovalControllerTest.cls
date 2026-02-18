/**
* @File Name : ApprovalControllerTest.cls
* @Description : Test class for ApprovalController
* @Author :
* @Last Modified By :
* @Last Modified On : November 4, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | November 4, 2025 |   | Initial Version
**/

@isTest
private class ApprovalControllerTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test users and group in a separate context
        User testUser1;
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Create test users
            
            Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
            
            testUser1 = (User)TestFactory.createSObject(new User(), 'TestFactoryDefaults.ProductManagerUserDefaults');
            testUser1.ProfileId = p.Id;
            testUser1.LastName = 'TestUser1';
            testUser1.Alias = 'tuser1';
            insert testUser1;
            
        }
        
        // Now create non-setup objects
        // Create Account (required for Quote)
        Account[] accountList = (Account[])TestFactory.createSObjectList(new Account(), 1);
        accountList[0].Name = 'TestAccount1'; 
        insert accountList;

        //Create Sales Area
         SalesArea__c sArea = (SalesArea__c)TestFactory.createSObject(new SalesArea__c());
            sArea.pkl_SalesOrg__c = 'DEM5';
            sArea.pkl_DistributionChannel__c ='	A1'; 
            sArea.pkl_Division__c = '01';
        insert sArea;
        
        //Create Sales Data Customer
        SalesAreaLink__c salesAreaLink = (SalesAreaLink__c)TestFactory.createSObject(new SalesAreaLink__c(),'TestFactoryDefaults.SalesAreaLinkDefaults', false);
        salesAreaLink.mdr_Account__c = accountList[0].Id;
        salesAreaLink.mdr_SalesArea__c = sArea.Id;
        insert salesAreaLink;
        
        //Create Opportunity (required for Quote)
        Opportunity opp = (Opportunity)TestFactory.createSObject(new Opportunity());
            opp.Name = 'Test Opportunity';
            opp.AccountId = accountList[0].Id;
            opp.StageName = 'Prospecting';
            opp.CloseDate = Date.today().addDays(30);
            opp.pklLeadingSolutionField__c = 'DEV';
            opp.pklTypeOfOpportunity__c = 'LTA';
            opp.pklTypeOfOffering__c = 'SW';
            opp.lkp_SalesDataCustomer__c = salesAreaLink.Id;
            insert opp;
        
        // Create Quote
        SBQQ__Quote__c[] quoteList = (SBQQ__Quote__c[])TestFactory.createSObjectList(new SBQQ__Quote__c(), 1);
            quoteList[0].SBQQ__Opportunity2__c = opp.Id;
            quoteList[0].SBQQ__Account__c = accountList[0].Id;
        insert quoteList;
        
        // Re-query users to get their Ids
        testUser1 = [SELECT Id FROM User WHERE LastName = 'TestUser1' LIMIT 1];
        
        // Create Approvers
        sbaa__Approver__c approver1 = new sbaa__Approver__c(
            sbaa__User__c = testUser1.Id,
            Name = 'Test Approver 1'
        );
        insert approver1;
        
        // Create Approvals with different statuses
        List<sbaa__Approval__c> approvals = new List<sbaa__Approval__c>();
        
        // Pending approval for user approver
        approvals.add(new sbaa__Approval__c(
            sbaa__AssignedTo__c = testUser1.Id,
            sbaa__Approver__c = approver1.Id,
            sbaa__Status__c = 'Pending',
            sbaa__ApprovalStep__c = 1,
            sbaa__RecordField__c = 'Status',
            Quote__c = quoteList[0].Id
        ));        
        insert approvals;
        
        // update approval by approving
        sbaa__Approval__c updateApp = new sbaa__Approval__c();
        updateApp.Id = approvals[0].Id;
        updateApp.sbaa__Status__c = 'Approved';
        updateApp.sbaa__ApprovedBy__c = testUser1.Id;
        updateApp.sbaa__CommentsLong__c= 'This is approved';
        update updateApp;
    }
        
    @isTest
    static void testGetMyApprovals_UserApprover() {
        User testUser1 = [SELECT Id FROM User WHERE LastName = 'TestUser1' LIMIT 1];
        
        System.runAs(testUser1) {
            Test.startTest();
            List<sbaa__Approval__c> results = ApprovalController.getMyApprovals();
            Test.stopTest();
            
            // Should return only pending approvals (not approved/rejected)
            // User has 2 pending approvals (1 direct, 1 through group)
            System.assertEquals(0, results.size(), 'Should return 0 pending approvals');
            
            // Verify excluded statuses are not returned
            for (sbaa__Approval__c approval : results) {
                System.assertNotEquals('Approved', approval.sbaa__Status__c, 'Should not return approved');
                System.assertNotEquals('Rejected', approval.sbaa__Status__c, 'Should not return rejected');
            }
        }
    }
    
    @isTest
    static void testGetMyHistoryApprovals() {
        User testUser1 = [SELECT Id FROM User WHERE LastName = 'TestUser1' LIMIT 1];
        
        System.runAs(testUser1) {
            Test.startTest();
            List<sbaa__Approval__c> results = ApprovalController.getMyHistoryApprovals();
            Test.stopTest();
            
            // Should return 2 approvals (1 approved, 1 rejected by testUser1)
            System.assertEquals(1, results.size(), 'Should return 0 historical approvals');
            
            // Verify each approval has either approved or rejected by this user
            for (sbaa__Approval__c approval : results) {
                Boolean isApprovedByUser = (approval.sbaa__ApprovedBy__c == testUser1.Id);
                Boolean isRejectedByUser = (approval.sbaa__RejectedBy__c == testUser1.Id);
                System.assert(
                    isApprovedByUser || isRejectedByUser,
                    'Approval should be approved or rejected by current user'
                );
            }
        }
    }
}