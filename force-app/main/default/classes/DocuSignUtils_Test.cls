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
        User productManagerUser = (User)TestFactory.createSObject(new User(), 'TestFactoryDefaults.ProductManagerUserDefaults', true);
       PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SalesBasic' LIMIT 1];
       PermissionSetLicense psl = [SELECT Id from PermissionSetLicense WHERE DeveloperName = 'SalesforceCPQ_CPQStandardPerm' ];

       PermissionSetLicenseAssign pslassignment = new PermissionSetLicenseAssign(
            PermissionSetLicenseId = psl.Id,
            AssigneeId = productManagerUser.Id
        );
        insert pslassignment;

        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = productManagerUser.Id,
            PermissionSetId = ps.Id
        );
        insert psa;
        return productManagerUser;
    }
}