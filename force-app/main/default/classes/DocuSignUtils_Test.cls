@isTest
public class DocuSignUtils_Test {

    @isTest
    public static void getSignerUsers(){
        
        User productManagerUser = createUser();
        
        Test.startTest();
        	System.runAs(productManagerUser){
            	DocuSignUtils.getGroupMemberEmails();
            }
        Test.stopTest();
        
    }
    
    static User createUser(){
        User productManagerUser = (User)TestFactory.createSObject(new User(), 'TestFactoryDefaults.AdminUserDefaults', true);
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SalesBasic' LIMIT 1];
        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'DocusignUser' LIMIT 1];
        PermissionSetLicense psl = [SELECT Id from PermissionSetLicense WHERE DeveloperName = 'SalesforceCPQ_CPQStandardPerm' ];

        PermissionSetLicenseAssign pslassignment = new PermissionSetLicenseAssign(
            PermissionSetLicenseId = psl.Id,
            AssigneeId = productManagerUser.Id
        );
        insert pslassignment;

        // Assign the Permission Set to the test user
        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = productManagerUser.Id,
            PermissionSetId = ps.Id
        );
        insert psa;

         PermissionSetAssignment psa2 = new PermissionSetAssignment(
            AssigneeId = productManagerUser.Id,
            PermissionSetId = ps2.Id
        );
        insert psa2;
        return productManagerUser;
    }
}