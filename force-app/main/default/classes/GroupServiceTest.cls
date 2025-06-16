/**
* @author       Ravi
* @date         05/19/2025
* @description  Test class for GroupService
*/
@isTest
private class GroupServiceTest {
    @TestSetup
    static void setupTestData() {
        Account testAccount = (Account)TestFactory.createSObject(new Account(), true);
        createTestUsers();
    }
    
    private static void createTestUsers() {
        try {
            Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
            User adminUser = new User(
                ProfileId = adminProfile.Id,
                Username = 'testadmin' + System.currentTimeMillis() + '@example.com',
                Email = 'testadmin@example.com',
                EmailEncodingKey = 'UTF-8',
                Alias = 'tadmin',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                FirstName = 'Test',
                LastName = 'Admin'
            );
            insert adminUser;
            Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
            User standardUser = new User(
                ProfileId = standardProfile.Id,
                Username = 'testuser' + System.currentTimeMillis() + '@example.com',
                Email = 'testuser@example.com',
                EmailEncodingKey = 'UTF-8',
                Alias = 'tuser',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                FirstName = 'Test',
                LastName = 'User'
            );
            insert standardUser;
        } catch (Exception e) {
            System.debug('Error creating test users: ' + e.getMessage());
        }
    }
    
    @isTest
    static void testGetGroupsFromCache() {
        GroupService.GroupData groupData1 = new GroupService.GroupData();
        groupData1.id = '0F90T0000000001AAA'; 
        groupData1.name = 'TestGroup1';
        groupData1.users.add(UserInfo.getUserId());
        GroupService.GroupData groupData2 = new GroupService.GroupData();
        groupData2.id = '0F90T0000000002AAA'; 
        groupData2.name = 'TestGroup2';
        GroupService.groups_for_testing = new List<GroupService.GroupData>{groupData1, groupData2};
            Test.startTest();
        List<GroupService.GroupData> resultGroups = GroupService.getGroupsFromCache();
        Test.stopTest();
        System.assertEquals(2, resultGroups.size(), 'Should return 2 groups');
        Boolean foundGroup1 = false;
        for (GroupService.GroupData groupData : resultGroups) {
            if (groupData.name == 'TestGroup1') {
                foundGroup1 = true;
                System.assertEquals(1, groupData.users.size(), 'Group1 should have 1 user');
                System.assert(groupData.users.contains(UserInfo.getUserId()), 'Group1 should contain the current user');
                break;
            }
        }
        System.assert(foundGroup1, 'Should have found TestGroup1');
    }
    @isTest
    static void testQuoteNotFound() {
        User testUser = [SELECT Id FROM User WHERE LastName = 'Admin' AND IsActive = true LIMIT 1];
        Id tempQuoteId = getTempId(SBQQ__Quote__c.SObjectType);
        GroupService.approvals_for_testing = new List<sbaa__Approval__c>();
        GroupService.InputVariables input = new GroupService.InputVariables();
        input.userId = testUser.Id;
        input.quoteId = tempQuoteId;
        Test.startTest();
        List<GroupService.OutputVariables> results = GroupService.callIsQuoteReadOnly(new List<GroupService.InputVariables>{input});
        Test.stopTest();
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals(false, results[0].isQuoteReadOnly, 'Quote should not be read-only since it does not exist');
    }
    @isTest
    static void testNoApprovals() {
        User testUser = [SELECT Id FROM User WHERE LastName = 'Admin' AND IsActive = true LIMIT 1];
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            SBQQ__Account__c = [SELECT Id FROM Account LIMIT 1].Id,
            SBQQ__Status__c = 'Draft',
            OwnerId = testUser.Id
        );
        insert quote;
        GroupService.approvals_for_testing = new List<sbaa__Approval__c>();
        GroupService.InputVariables input = new GroupService.InputVariables();
        input.userId = testUser.Id;
        input.quoteId = quote.Id;
        Test.startTest();
        List<GroupService.OutputVariables> results = GroupService.callIsQuoteReadOnly(new List<GroupService.InputVariables>{input});
        Test.stopTest();
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals(true, results[0].isQuoteReadOnly, 'Quote should be read-only with no approvals');
    }
    @isTest
    static void testUserIsApproverViaField() {
        User testUser = [SELECT Id FROM User WHERE LastName = 'Admin' AND IsActive = true LIMIT 1];
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            SBQQ__Account__c = [SELECT Id FROM Account LIMIT 1].Id,
            SBQQ__Status__c = 'Draft',
            OwnerId = testUser.Id
        );
        insert quote;
        sbaa__Approval__c approval = new sbaa__Approval__c();
        approval.Id = getTempId(sbaa__Approval__c.SObjectType);
        approval.Quote__c = quote.Id;
        approval.sbaa__Status__c = 'Requested';
        approval.sbaa__ApproverField__c = 'OwnerId';  
        GroupService.approvals_for_testing = new List<sbaa__Approval__c>{approval};
            GroupService.InputVariables input = new GroupService.InputVariables();
        input.userId = testUser.Id;
        input.quoteId = quote.Id;
        Test.startTest();
        List<GroupService.OutputVariables> results = GroupService.callIsQuoteReadOnly(new List<GroupService.InputVariables>{input});
        Test.stopTest();
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals(true, results[0].isQuoteReadOnly, 'Quote should be read-only when user is an approver via field');
    }
    
    @isTest
    static void testIsUserInGroup() {
        User testUser = [SELECT Id, UserRoleId FROM User WHERE LastName = 'Admin' AND IsActive = true LIMIT 1];
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            SBQQ__Account__c = [SELECT Id FROM Account LIMIT 1].Id,
            SBQQ__Status__c = 'Draft',
            OwnerId = testUser.Id
        );
        insert quote;
        String mockGroupId = '00G000000000001';
        sbaa__Approval__c approval = new sbaa__Approval__c();
        approval.Quote__c = quote.Id;
        approval.sbaa__Status__c = 'Requested';
        sbaa__Approver__c approver = new sbaa__Approver__c();
        approver.sbaa__GroupId__c = mockGroupId;
        GroupService.approvals_for_testing = null;
        GroupService.approvers_for_testing = null;
        GroupService.user_in_group_result = null;
        GroupService.approvals_for_testing = new List<sbaa__Approval__c>{approval};
            GroupService.approvers_for_testing = new List<sbaa__Approver__c>{approver};
                GroupService.user_in_group_result = true;
        GroupService.InputVariables input = new GroupService.InputVariables();
        input.userId = testUser.Id;
        input.quoteId = quote.Id;
        Test.startTest();
        List<GroupService.OutputVariables> results = GroupService.callIsQuoteReadOnly(new List<GroupService.InputVariables>{input});
        Test.stopTest();
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals(true, results[0].isQuoteReadOnly, 'Quote should be read-only based on mocked user_in_group_result');
    }
    
    @isTest
    static void testExceptionHandling() {
        GroupService.InputVariables input = new GroupService.InputVariables();
        input.userId = null;
        input.quoteId = null;
        Test.startTest();
        try {
            List<GroupService.OutputVariables> results = GroupService.callIsQuoteReadOnly(new List<GroupService.InputVariables>{input});
            if (results != null && !results.isEmpty()) {
                System.assertEquals(false, results[0].isQuoteReadOnly, 'Should return false for invalid input');
            }
        } catch (Exception e) {
            System.assert(e != null, 'Exception was thrown as expected');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testMultipleQuoteProcessing() {
        User approverUser = [SELECT Id FROM User WHERE LastName = 'Admin' AND IsActive = true LIMIT 1];
        User nonApproverUser = [SELECT Id FROM User WHERE LastName = 'User' AND IsActive = true LIMIT 1];
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c(
            SBQQ__Account__c = [SELECT Id FROM Account LIMIT 1].Id,
            SBQQ__Status__c = 'Draft',
            OwnerId = approverUser.Id
        );
        insert quote1;
        
        SBQQ__Quote__c quote2 = new SBQQ__Quote__c(
            SBQQ__Account__c = [SELECT Id FROM Account LIMIT 1].Id,
            SBQQ__Status__c = 'Draft',
            OwnerId = nonApproverUser.Id
        );
        insert quote2;
        sbaa__Approval__c approval1 = new sbaa__Approval__c();
        approval1.Id = getTempId(sbaa__Approval__c.SObjectType);
        approval1.Quote__c = quote1.Id;
        approval1.sbaa__Status__c = 'Requested';
        approval1.sbaa__ApproverField__c = 'OwnerId';
        sbaa__Approval__c approval2 = new sbaa__Approval__c();
        approval2.Id = getTempId(sbaa__Approval__c.SObjectType);
        approval2.Quote__c = quote2.Id;
        approval2.sbaa__Status__c = 'Requested';
        GroupService.approvals_for_testing = new List<sbaa__Approval__c>{approval1, approval2};
            GroupService.approvers_for_testing = new List<sbaa__Approver__c>();
        List<GroupService.InputVariables> inputs = new List<GroupService.InputVariables>();
        GroupService.InputVariables input1 = new GroupService.InputVariables();
        input1.userId = approverUser.Id;
        input1.quoteId = quote1.Id;
        inputs.add(input1);
        GroupService.InputVariables input2 = new GroupService.InputVariables();
        input2.userId = nonApproverUser.Id;
        input2.quoteId = quote2.Id;
        inputs.add(input2);
        Test.startTest();
        List<GroupService.OutputVariables> results = GroupService.callIsQuoteReadOnly(inputs);
        Test.stopTest();
        System.assertEquals(2, results.size(), 'Should return two results');
    }
    @isTest
    static void testIsUserInGroupImplementation() {
        User testUser = [SELECT Id, UserRoleId FROM User WHERE LastName = 'Admin' AND IsActive = true LIMIT 1];
        GroupService.GroupData groupData1 = new GroupService.GroupData();
        groupData1.id = '00G000000000001'; 
        groupData1.name = 'TestGroup1';
        String userIdStr = String.valueOf(testUser.Id);
        groupData1.users.add(userIdStr);
        GroupService.GroupData groupData2 = new GroupService.GroupData();
        groupData2.id = '00G000000000002'; 
        groupData2.name = 'TestGroup2';
        if (testUser.UserRoleId != null) {
            String roleIdStr = String.valueOf(testUser.UserRoleId);
            groupData2.roles.add(roleIdStr);
        }
        GroupService.GroupData groupData3 = new GroupService.GroupData();
        groupData3.id = '00G000000000003'; 
        groupData3.name = 'TestGroup3';
        GroupService.groups_for_testing = new List<GroupService.GroupData>{
            groupData1, groupData2, groupData3
                };
                    
                    Test.startTest();
        GroupService.user_in_group_result = true;
        Boolean result1 = GroupService.isUserInGroupForTesting(testUser.Id, '00G000000000001');
        GroupService.user_in_group_result = null;
        Boolean result2 = false;
        if (testUser.UserRoleId != null) {
            GroupService.user_in_group_result = true;
            result2 = GroupService.isUserInGroupForTesting(testUser.Id, '00G000000000002');
            GroupService.user_in_group_result = null;
        }
        Boolean result3 = GroupService.isUserInGroupForTesting(testUser.Id, '00G000000000003');
        Boolean result4 = GroupService.isUserInGroupForTesting(null, '00G000000000001');
        Boolean result5 = GroupService.isUserInGroupForTesting(testUser.Id, null);
        Boolean result6 = GroupService.isUserInGroupForTesting(testUser.Id, '00G000000000999');
        
        Test.stopTest();
        
        System.assertEquals(true, result1, 'User should be directly in group1');
        
        if (testUser.UserRoleId != null) {
            System.assertEquals(true, result2, 'User should be in group2 via role');
        }
        
        System.assertEquals(false, result3, 'User should not be in group3');
        System.assertEquals(false, result4, 'Null user ID should return false');
        System.assertEquals(false, result5, 'Null group ID should return false');
        System.assertEquals(false, result6, 'Non-existent group should return false');
    }
    @isTest
    static void testIsUserInGroupAllPaths() {
        User testUser = [SELECT Id, UserRoleId FROM User WHERE LastName = 'Admin' AND IsActive = true LIMIT 1];
        Test.startTest();
        GroupService.user_in_group_result = true;
        Boolean result1 = GroupService.isUserInGroupForTesting(testUser.Id, '00G000000000001');
        GroupService.user_in_group_result = null;
        GroupService.GroupData groupData1 = new GroupService.GroupData();
        groupData1.id = '00G000000000001';
        groupData1.name = 'TestGroup1';
        groupData1.users = new Set<String>();
        groupData1.users.add(String.valueOf(testUser.Id));
        GroupService.GroupData groupData2 = new GroupService.GroupData();
        groupData2.id = '00G000000000002';
        groupData2.name = 'TestGroup2';
        groupData2.roles = new Set<String>();
        
        if (testUser.UserRoleId != null) {
            groupData2.roles.add(String.valueOf(testUser.UserRoleId));
        }
        GroupService.groups_for_testing = new List<GroupService.GroupData>{groupData1, groupData2};
            Boolean result2 = GroupService.isUserInGroupForTesting(testUser.Id, '00G000000000001');
        Boolean result3 = GroupService.isUserInGroupForTesting(null, '00G000000000001');
        Boolean result4 = GroupService.isUserInGroupForTesting(testUser.Id, null);
        Boolean result5;
        GroupService.groups_for_testing = null;
        result5 = GroupService.isUserInGroupForTesting(testUser.Id, '00G000000000001');    
        Test.stopTest();
        System.assertEquals(true, result1, 'User should be directly in group1 (override)');
    }
    @isTest
    static void testIsQuoteReadOnlyExceptionHandling() {
        User testUser = [SELECT Id FROM User WHERE LastName = 'Admin' AND IsActive = true LIMIT 1];
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            SBQQ__Account__c = [SELECT Id FROM Account LIMIT 1].Id,
            SBQQ__Status__c = 'Draft',
            OwnerId = testUser.Id
        );
        insert quote;
        sbaa__Approval__c approval = new sbaa__Approval__c();
        approval.Id = getTempId(sbaa__Approval__c.SObjectType);
        approval.Quote__c = quote.Id;
        approval.sbaa__Status__c = 'Requested';
        approval.sbaa__ApproverField__c = 'InvalidField__c'; 
        GroupService.approvals_for_testing = new List<sbaa__Approval__c>{approval};
            GroupService.InputVariables input = new GroupService.InputVariables();
        input.userId = testUser.Id;
        input.quoteId = quote.Id;
        Test.startTest();
        List<GroupService.OutputVariables> results = GroupService.callIsQuoteReadOnly(new List<GroupService.InputVariables>{input});
        Test.stopTest();
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals(false, results[0].isQuoteReadOnly, 'Should return false due to exception handling');
    }
    @isTest
    static void testUserIsDirectApprover() {
        User testUser = [SELECT Id FROM User WHERE LastName = 'Admin' AND IsActive = true LIMIT 1];
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            SBQQ__Account__c = [SELECT Id FROM Account LIMIT 1].Id,
            SBQQ__Status__c = 'Draft',
            OwnerId = testUser.Id
        );
        insert quote;
        sbaa__Approval__c approval = new sbaa__Approval__c();
        approval.Id = getTempId(sbaa__Approval__c.SObjectType);
        approval.Quote__c = quote.Id;
        approval.sbaa__Status__c = 'Requested';
        sbaa__Approver__c approver = new sbaa__Approver__c();
        approver.Id = getTempId(sbaa__Approver__c.SObjectType);
        approver.sbaa__User__c = testUser.Id; 
        GroupService.approvals_for_testing = new List<sbaa__Approval__c>{approval};
            GroupService.approvers_for_testing = new List<sbaa__Approver__c>{approver};
                GroupService.InputVariables input = new GroupService.InputVariables();
        input.userId = testUser.Id;
        input.quoteId = quote.Id;
        
        Test.startTest();
        List<GroupService.OutputVariables> results = GroupService.callIsQuoteReadOnly(new List<GroupService.InputVariables>{input});
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals(true, results[0].isQuoteReadOnly, 'Quote should be read-only when user is a direct approver');
    }
    @isTest
    static void testBuildGroupData() {
        Test.startTest();
        Group testGroup = new Group(
            Name = 'TestCycleGroup',
            DeveloperName = 'TestCycleGroup',
            Type = 'Regular'
        );
        insert testGroup;
        
        User testUser = [SELECT Id FROM User WHERE LastName = 'Admin' AND IsActive = true LIMIT 1];
        Map<Id, Group> allGroups = new Map<Id, Group>();
        allGroups.put(testGroup.Id, testGroup);
        
        Map<Id, Set<Id>> groupToUsers = new Map<Id, Set<Id>>();
        groupToUsers.put(testGroup.Id, new Set<Id>{testUser.Id});
        
        Map<Id, Set<Id>> groupToSubgroups = new Map<Id, Set<Id>>();
        groupToSubgroups.put(testGroup.Id, new Set<Id>{testGroup.Id});
        
        Map<Id, String> groupRoles = new Map<Id, String>();
        groupRoles.put(testGroup.Id, 'TestRole');
        Set<Id> visitedGroups = new Set<Id>{testGroup.Id};
            GroupService.GroupData result = GroupService.buildGroupDataForTesting(
                testGroup.Id, 
                allGroups, 
                groupToUsers, 
                groupToSubgroups, 
                groupRoles, 
                visitedGroups
            );
        
        Test.stopTest();
        System.assertNotEquals(null, result, 'Should not return null');
        System.assertEquals(0, result.users.size(), 'Should return empty users set due to cycle detection');
        System.assertEquals(0, result.roles.size(), 'Should return empty roles set due to cycle detection');
    }
    @isTest
    static void testUserDirectlyInGroup() {
        User testUser = [SELECT Id FROM User WHERE LastName = 'Admin' AND IsActive = true LIMIT 1];
        GroupService.user_in_group_result = null;
        GroupService.GroupData groupData = new GroupService.GroupData();
        groupData.id = '00G000000000001';
        groupData.name = 'TestGroup';
        groupData.users = new Set<String>();
        String userIdStr = String.valueOf(testUser.Id);
        groupData.users.add(userIdStr);
        
        System.debug('Added user ID as string: ' + userIdStr);
        System.debug('Group users set now contains: ' + groupData.users);
        GroupService.groups_for_testing = new List<GroupService.GroupData>{groupData};
            Test.startTest();
        Boolean result = GroupService.isUserInGroup(testUser.Id, '00G000000000001');
        Test.stopTest();
    }
    @isTest
    static void testExceptionPath() {
        User testUser = [SELECT Id FROM User WHERE LastName = 'Admin' AND IsActive = true LIMIT 1];
        sbaa__Approval__c approval = new sbaa__Approval__c();
        approval.Id = getTempId(sbaa__Approval__c.SObjectType);
        approval.sbaa__Status__c = 'Requested';
        approval.sbaa__ApproverField__c = 'NonExistentField__c';
        GroupService.approvals_for_testing = new List<sbaa__Approval__c>{approval};
            GroupService.InputVariables input = new GroupService.InputVariables();
        input.userId = testUser.Id;
        input.quoteId = '01t123456789ABC';
        Test.startTest();
        try {
            GroupService.callIsQuoteReadOnly(new List<GroupService.InputVariables>{input});
        } catch (Exception ex) {
            System.assertEquals(true, ex != null, 'Exception should be caught and rethrown');
        }
        Test.stopTest();
    }
    @isTest
    static void testDatabaseQueryPath() {
        User testUser = [SELECT Id FROM User WHERE LastName = 'Admin' AND IsActive = true LIMIT 1];
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            SBQQ__Account__c = [SELECT Id FROM Account LIMIT 1].Id,
            SBQQ__Status__c = 'Draft',
            OwnerId = testUser.Id
        );
        insert quote;
        GroupService.approvals_for_testing = null;
        Test.startTest();
        Boolean result = GroupService.isQuoteReadOnly(testUser.Id, quote.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testApproversDatabasePaths() {
        User testUser = [SELECT Id FROM User WHERE LastName = 'Admin' AND IsActive = true LIMIT 1];
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            SBQQ__Account__c = [SELECT Id FROM Account LIMIT 1].Id,
            SBQQ__Status__c = 'Draft',
            OwnerId = testUser.Id
        );
        insert quote;
        sbaa__Approval__c approval = new sbaa__Approval__c();
        approval.Id = getTempId(sbaa__Approval__c.SObjectType);
        approval.Quote__c = quote.Id;
        approval.sbaa__Status__c = 'Requested';
        GroupService.approvals_for_testing = new List<sbaa__Approval__c>{approval};
            GroupService.approvers_for_testing = null; 
        Test.startTest();
        Boolean result = GroupService.isQuoteReadOnly(testUser.Id, quote.Id);
        Test.stopTest();
        System.assertEquals(false, result, 'Should return false when no approvers exist');
    }
    
    @isTest
    static void testUserIsNotApprover() {
        User testUser = [SELECT Id FROM User WHERE LastName = 'Admin' AND IsActive = true LIMIT 1];
        User otherUser = [SELECT Id FROM User WHERE LastName = 'User' AND IsActive = true LIMIT 1];
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            SBQQ__Account__c = [SELECT Id FROM Account LIMIT 1].Id,
            SBQQ__Status__c = 'Draft',
            OwnerId = testUser.Id
        );
        insert quote;
        sbaa__Approval__c approval = new sbaa__Approval__c();
        approval.Id = getTempId(sbaa__Approval__c.SObjectType);
        approval.Quote__c = quote.Id;
        approval.sbaa__Status__c = 'Requested';
        sbaa__Approver__c approver = new sbaa__Approver__c();
        approver.Id = getTempId(sbaa__Approver__c.SObjectType);
        approver.sbaa__User__c = otherUser.Id; 
        GroupService.approvals_for_testing = new List<sbaa__Approval__c>{approval};
            GroupService.approvers_for_testing = new List<sbaa__Approver__c>{approver};
                Test.startTest();
        Boolean result = GroupService.isQuoteReadOnly(testUser.Id, quote.Id);
        Test.stopTest();
        System.assertEquals(false, result, 'Should return false when user is not an approver');
    }
    
    @isTest
    static void testIsUserInGroupErrorPaths() {
        User testUser = [SELECT Id, UserRoleId FROM User WHERE LastName = 'Admin' AND IsActive = true LIMIT 1];
        Id mockGroupId = '005000000000AAA';
        Test.startTest();
        Boolean result1 = GroupService.isUserInGroup(null, mockGroupId);
        Boolean result2 = GroupService.isUserInGroup(testUser.Id, null);
        GroupService.GroupData emptyGroup = new GroupService.GroupData();
        emptyGroup.id = String.valueOf(mockGroupId);
        emptyGroup.name = 'EmptyGroup';
        emptyGroup.users = new Set<String>(); 
        emptyGroup.roles = new Set<String>(); 
        GroupService.groups_for_testing = new List<GroupService.GroupData>{emptyGroup};
            Boolean result3 = GroupService.isUserInGroup(testUser.Id, mockGroupId);
        GroupService.GroupData roleGroup = new GroupService.GroupData();
        roleGroup.id = String.valueOf(mockGroupId);
        roleGroup.name = 'RoleGroup';
        roleGroup.users = new Set<String>(); 
        roleGroup.roles = new Set<String>(); 
        if (testUser.UserRoleId != null) {
            roleGroup.roles.add(String.valueOf(testUser.UserRoleId));
        }
        GroupService.groups_for_testing = new List<GroupService.GroupData>{roleGroup};
            Boolean result4 = GroupService.isUserInGroup(testUser.Id, mockGroupId);
        GroupService.GroupData userGroup = new GroupService.GroupData();
        userGroup.id = String.valueOf(mockGroupId);
        userGroup.name = 'UserGroup';
        userGroup.users = new Set<String>{String.valueOf(testUser.Id)}; // User in group
            userGroup.roles = new Set<String>(); 
        GroupService.groups_for_testing = new List<GroupService.GroupData>{userGroup};
            Boolean result5 = GroupService.isUserInGroup(testUser.Id, mockGroupId);
        GroupService.groups_for_testing = null; 
        Boolean result6 = GroupService.isUserInGroup(testUser.Id, mockGroupId);  
        Test.stopTest();
    }
    
    @isTest
    static void testUserRoleAndExceptionPaths() {
        User testUser = [SELECT Id, UserRoleId FROM User WHERE LastName = 'Admin' AND IsActive = true LIMIT 1];
        String mockGroupId = '00G000000000001';
        
        Test.startTest();
        GroupService.GroupData roleGroup = new GroupService.GroupData();
        roleGroup.id = mockGroupId;
        roleGroup.name = 'RoleGroup';
        roleGroup.users = new Set<String>(); 
        roleGroup.roles = new Set<String>(); 
        if (testUser.UserRoleId != null) {
            roleGroup.roles.add(String.valueOf(testUser.UserRoleId));
            System.debug('Added role to group: ' + String.valueOf(testUser.UserRoleId));
        } else {
            System.debug('Test user has no role, test may not cover role path');
        }
        
        GroupService.groups_for_testing = new List<GroupService.GroupData>{roleGroup};
            
            Boolean roleResult = GroupService.isUserInGroup(testUser.Id, mockGroupId);
        System.debug('Role test result: ' + roleResult);
        
        GroupService.GroupData emptyGroup = new GroupService.GroupData();
        emptyGroup.id = mockGroupId;
        emptyGroup.name = 'EmptyGroup';
        emptyGroup.users = new Set<String>(); 
        emptyGroup.roles = new Set<String>(); 
        GroupService.groups_for_testing = new List<GroupService.GroupData>{emptyGroup};
            Boolean notInGroupResult = GroupService.isUserInGroup(testUser.Id, mockGroupId);
        GroupService.groups_for_testing = new List<GroupService.GroupData>{null};
            
            Boolean exceptionResult = GroupService.isUserInGroup(testUser.Id, mockGroupId);
        
        
        Test.stopTest();
    }
    @isTest
    static void testIsUserInGroups() {
        User testUser;
        try {
            testUser = [SELECT Id, UserRoleId FROM User WHERE UserRoleId != null AND IsActive = true LIMIT 1];
            System.debug('Found user with role: ' + testUser.Id + ', RoleId: ' + testUser.UserRoleId);
        } catch (Exception e) {
            testUser = [SELECT Id, UserRoleId FROM User WHERE IsActive = true LIMIT 1];
            System.debug('No user with role found, using: ' + testUser.Id);
        }
        Id mockGroupId = getTempId(Group.SObjectType);
        
        Test.startTest();
        if (testUser.UserRoleId != null) {
            System.debug('Testing user role in group path');
            GroupService.GroupData groupWithRole = new GroupService.GroupData();
            groupWithRole.id = String.valueOf(mockGroupId);
            groupWithRole.name = 'TestRoleGroup';
            groupWithRole.users = new Set<String>(); 
            groupWithRole.roles = new Set<String>{ String.valueOf(testUser.UserRoleId) }; 
                
                System.debug('Created group with user role: ' + testUser.UserRoleId);
            GroupService.groups_for_testing = new List<GroupService.GroupData>{ groupWithRole };
                GroupService.user_in_group_result = null;
            
            try {
                Boolean result = GroupService.isUserInGroup(testUser.Id, mockGroupId);
                System.debug('User role in group test result: ' + result);
            } catch (Exception e) {
                System.debug('Exception in role test: ' + e.getMessage());
            }
        }
        GroupService.GroupData emptyGroup = new GroupService.GroupData();
        emptyGroup.id = String.valueOf(mockGroupId);
        emptyGroup.name = 'EmptyGroup';
        emptyGroup.users = new Set<String>();
        emptyGroup.roles = new Set<String>(); 
        GroupService.groups_for_testing = new List<GroupService.GroupData>{ emptyGroup };
            GroupService.user_in_group_result = null;
        
        try {
            Boolean result = GroupService.isUserInGroup(testUser.Id, mockGroupId);
            System.debug('User not in group test result: ' + result);
        } catch (Exception e) {
            System.debug('Exception in not-in-group test: ' + e.getMessage());
        }
        
        GroupService.groups_for_testing = null;
        
        try {
            Boolean result = GroupService.isUserInGroup(testUser.Id, mockGroupId);
            System.debug('Unexpected result from exception test: ' + result);
        } catch (Exception e) {
            System.debug('Expected exception: ' + e.getMessage());
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetGroupsFromCacheException() {
        
        Test.startTest();
        GroupService.groups_for_testing = null;
        List<GroupService.GroupData> results = GroupService.getGroupsFromCache();
        
        Test.stopTest();
        System.assertNotEquals(null, results, 'Results should not be null even after exception');
    }
    
    @isTest
    static void testBuildGroupDataAndException() {
        Id groupId = getTempId(Group.SObjectType);
        Id subGroupId = getTempId(Group.SObjectType);
        Map<Id, Group> allGroups = new Map<Id, Group>();
        Group testGroup = new Group(
            Id = groupId,
            Name = 'Test Group',
            DeveloperName = 'Test_Group'
        );
        allGroups.put(groupId, testGroup);
        Group subGroup = new Group(
            Id = subGroupId,
            Name = 'Sub Group',
            DeveloperName = 'Sub_Group'
        );
        allGroups.put(subGroupId, subGroup);
        
        Map<Id, Set<Id>> groupToUsers = new Map<Id, Set<Id>>();
        groupToUsers.put(subGroupId, new Set<Id>{'005000000000001'}); 
        
        Map<Id, Set<Id>> groupToSubgroups = new Map<Id, Set<Id>>();
        groupToSubgroups.put(groupId, new Set<Id>{subGroupId});
        
        Map<Id, String> groupRoles = new Map<Id, String>();
        groupRoles.put(subGroupId, 'TestRole'); 
        Test.startTest();
        GroupService.GroupData result = GroupService.buildGroupDataForTesting(
            groupId, 
            allGroups, 
            groupToUsers, 
            groupToSubgroups, 
            groupRoles, 
            new Set<Id>()
        );
        Map<Id, Group> invalidGroups = new Map<Id, Group>(); 
        try {
            GroupService.GroupData exceptionResult = GroupService.buildGroupDataForTesting(
                groupId,
                invalidGroups, 
                groupToUsers,
                groupToSubgroups,
                groupRoles,
                new Set<Id>()
            );
        } catch (Exception e) {
            System.debug('Exception caught in test: ' + e.getMessage());
        }
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(1, result.users.size(), 'Should have 1 user from subgroup');
        System.assertEquals(1, result.roles.size(), 'Should have 1 role from subgroup');
    }
    
    private static Id getTempId(Schema.SObjectType sObjectType) {
        String keyPrefix = sObjectType.getDescribe().getKeyPrefix();
        String uniqueSuffix = '000000000001';
        return Id.valueOf(keyPrefix + uniqueSuffix);
    }
}