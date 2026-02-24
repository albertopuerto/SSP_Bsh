@IsTest
public class DocuSignSignatureResendController_Test {

      static User createUser(){
        User productManagerUser = (User)TestFactory.createSObject(new User(), 'TestFactoryDefaults.ProductManagerUserDefaults', true);
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

    @TestSetup
    static void setupData() {
        // Settings
        insert new DocusignSettings__c(account_id__c = 'ec94da4e-5b4e-4e5d-a3ac-35dac0b0f786');

        Signature__c sig = new Signature__c();
        sig.Name = 'Test Signature';
        sig.Docusign_Status__c = 'Sent';
        sig.Envelope_Id__c = 'TEST-ENVELOPE-ID';
        insert sig;
    }

    @IsTest
    static void resendSuccessUpdatesStatus() {
        // Arrange
        User u = createUser();

        // Token mock
        String tokenBody = [SELECT Body FROM StaticResource WHERE Name = 'getAccessTokenBody']
            .Body.toString();

        HTTPMockGenerator tokenMock  = new HTTPMockGenerator(200, tokenBody);
        HTTPMockGenerator resendMock = new HTTPMockGenerator(200, '{}');

        HttpMultiRequestMockGenerator multiMock = new HttpMultiRequestMockGenerator();
        multiMock.putMock('https://account-d.docusign.com/oauth/token', tokenMock);

        multiMock.putMock(
            'callout:docusignCredential/restapi/v2.1/accounts/'
            + 'ec94da4e-5b4e-4e5d-a3ac-35dac0b0f786'
            + '/envelopes/TEST-ENVELOPE-ID?resend_envelope=true',
            resendMock
        );

        Test.setMock(HttpCalloutMock.class, multiMock);

        Signature__c sig = [SELECT Id, Docusign_Status__c FROM Signature__c LIMIT 1];

        // Act
        Test.startTest();
        System.runAs(u) {

            DocuSignSignatureResendController.resend(new List<Id>{ sig.Id });
        }
        Test.stopTest();

        // Assert
        Signature__c updated = [SELECT Docusign_Status__c FROM Signature__c WHERE Id = :sig.Id];
        System.assertEquals('Resent', updated.Docusign_Status__c, 'Status should be Resent after successful resend.');
    }

}