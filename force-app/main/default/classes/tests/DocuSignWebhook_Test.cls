@IsTest
public class DocuSignWebhook_Test {

    @testSetup
    public static void initRecords(){
        Account[] testAccountList = (Account[])TestFactory.createSObjectList(new Account(), 1);
        insert testAccountList;

        Contact[] testContactList = (Contact[])TestFactory.createSObjectList(new Contact(), 1);
        testContactList[0].AccountId = testAccountList[0].Id;
        insert testContactList;

        ContentVersion[] contentVersionList = (ContentVersion[])TestFactory.createSObjectList(new ContentVersion(), 1);
        contentVersionList[0].IsMajorVersion = true; 
        insert contentVersionList;
        ContentVersion contentVersion = contentVersionList[0];
        contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1];
        Id contentDocumentId = contentVersion.ContentDocumentId;
        
        ContentDocumentLink[] linkList = (ContentDocumentLink[])TestFactory.createSObjectList(new ContentDocumentLink(), 1);
        linkList[0].ContentDocumentId = contentDocumentId; 
        linkList[0].LinkedEntityId = testAccountList[0].Id;
        linkList[0].ShareType = 'V'; 
        insert linkList;
        Signature__c signature = new Signature__c(
        Envelope_Id__c = '517967bf-a80a-42e6-ba59-b01e37d8b54a',
        Document_Id__c= contentDocumentId
        );
        insert signature;
    }
    @IsTest
    static void testReceivesentData() {
        Docusign_Setting__mdt config = [SELECT clientId__c, userId__c, audience__c, certificateName__c,DeveloperName, accountId__c, baseUrl__c FROM Docusign_Setting__mdt WITH USER_MODE LIMIT 1];
        User productManagerUser = createUser();
        StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = 'getAccessTokenBody'];
		String tokenBody = sr.Body.toString();

        HTTPMockGenerator res2 = new HTTPMockGenerator(200, tokenBody);

        Test.setMock(HttpCalloutMock.class, res2);
        
        StaticResource sr2 = [SELECT Body FROM StaticResource WHERE Name = 'documentSignWebhookRequest'];
		String mockJson = sr2.Body.toString();
         Assert.areNotEqual(null, sr2.Body, 'The static resource is not null');
        
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(mockJson);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/docusignWebhook/*';
 
        RestContext.request = req;
        Test.startTest();
            System.runAs(productManagerUser){
                DocuSignWebhook.handleWebhook();
            }
        Test.stopTest();
        List<ContentVersion> versions = [SELECT Title, ContentDocumentId, pkl_Status__c FROM ContentVersion];
		
        System.assertEquals(2, versions.size());
        System.assertEquals('sent', versions[0].pkl_Status__c);
    }

    @IsTest
    static void testReceiveDeliveredData() {
        Docusign_Setting__mdt config = [SELECT clientId__c, userId__c, audience__c, certificateName__c,DeveloperName, accountId__c, baseUrl__c FROM Docusign_Setting__mdt WITH USER_MODE LIMIT 1];
        User productManagerUser = createUser();
        StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = 'getAccessTokenBody'];
		String tokenBody = sr.Body.toString();

        HTTPMockGenerator res2 = new HTTPMockGenerator(200, tokenBody);

        Test.setMock(HttpCalloutMock.class, res2);
        
        StaticResource sr2 = [SELECT Body FROM StaticResource WHERE Name = 'documentSignWebhookRequestDelivered'];
		String mockJson = sr2.Body.toString();
         Assert.areNotEqual(null, sr2.Body, 'The static resource is not null');
        
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(mockJson);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/docusignWebhook/*';
 
        RestContext.request = req;
        Test.startTest();
            System.runAs(productManagerUser){
                DocuSignWebhook.handleWebhook();
            }
        Test.stopTest();
        List<ContentVersion> versions = [SELECT Title, ContentDocumentId, pkl_Status__c FROM ContentVersion];
		
        System.assertEquals(2, versions.size());
        System.assertEquals('delivered', versions[0].pkl_Status__c);
    }

    @IsTest
    static void testReceiveData() {

        User productManagerUser = createUser();
        Docusign_Setting__mdt config = [SELECT clientId__c, userId__c, audience__c, certificateName__c,DeveloperName, accountId__c, baseUrl__c FROM Docusign_Setting__mdt WITH USER_MODE LIMIT 1];
        // Step 1: Create mock JSON payload
        StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = 'getAccessTokenBody'];
		String tokenBody = sr.Body.toString();

        HTTPMockGenerator res2 = new HTTPMockGenerator(200, tokenBody);

        Test.setMock(HttpCalloutMock.class, res2);
        
        StaticResource sr2 = [SELECT Body FROM StaticResource WHERE Name = 'documentSignWebhookRequestCompleted'];
		String mockJson = sr2.Body.toString();
         Assert.areNotEqual(null, sr2.Body, 'The static resource is not null');
        // Step 2: Set up mock RestRequest
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(mockJson);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/docusignWebhook/*';
 
        RestContext.request = req;
        Test.startTest();
            System.runAs(productManagerUser){
                DocuSignWebhook.handleWebhook();
            }
        Test.stopTest();
        List<ContentVersion> versions = [SELECT Title, ContentDocumentId, pkl_Status__c FROM ContentVersion];
		
        System.assertEquals(2, versions.size());
        System.assertEquals('completed', versions[0].pkl_Status__c);
    }

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
}