@isTest
public class EtasCoreUtilsTest {
    
    @TestSetup
    static void setupTestData() {
        // Create a test user
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser' + DateTime.now().getTime() + '@example.com',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = p.Id,
            Alias = 'tuser',
            IsActive = true
        );
        insert testUser;
        
        // Get the Permission Set containing our custom permission
        // Note: This assumes a permission set with the custom permission already exists
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'EditAgreements' LIMIT 1];
        
        // Assign the Permission Set to the test user
        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = testUser.Id,
            PermissionSetId = ps.Id
        );
        insert psa;
    }
    
    @isTest
    static void testHasCustomPermission_PermissionExists() {
        
        User testUser = [SELECT Id FROM User WHERE LastName = 'User' AND FirstName = 'Test' LIMIT 1];
        String permissionName = 'CreateNewAgreement';
        System.runAs(testUser) {       
            
            Test.startTest();
            Boolean hasPermission = EtasCoreUtils.hasCustomPermission(permissionName);
            Test.stopTest();
            
            // Verify the result
            System.assertEquals(true, hasPermission, 'User should have the custom permission');
        }
    }
    
    @isTest
    static void testHasCustomPermission_PermissionDoesNotExist() {
        // Set up test data
        String permissionName = 'NonExistentPermission';
        Test.startTest();
        
        // Call the method to test
        Boolean hasPermission = EtasCoreUtils.hasCustomPermission(permissionName);
        Test.stopTest();
        
        // Verify the result
        System.assertEquals(false, hasPermission, 'User should not have the custom permission');
    }
}