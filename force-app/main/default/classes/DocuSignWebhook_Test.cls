@IsTest
public class DocuSignWebhook_Test {

    @testSetup
    public static void initRecords(){
        Account[] testAccountList = (Account[])TestFactory.createSObjectList(new Account(), 1);
        insert testAccountList;

        Contact[] testContactList = (Contact[])TestFactory.createSObjectList(new Contact(), 1);
        testContactList[0].AccountId = testAccountList[0].Id;
        testContactList[0].mpkl_RoleMainAccount__c = '0001';
        testContactList[0].pkl_Language__c = 'English';
        testContactList[0].pkl_Status__c = 'Active';
        testContactList[0].Email = 'testEmail@invalid.com';
        testContactList[0].pkl_AccountGroup__c = 'ETDE Contact ETCN Contact';

        insert testContactList;
        
        ContentVersion[] contentVersionList = (ContentVersion[])TestFactory.createSObjectList(new ContentVersion(), 1);
        contentVersionList[0].IsMajorVersion = true; 
        insert contentVersionList;
        ContentVersion contentVersion = contentVersionList[0];
        
        // Get the ContentDocumentId - same as original
        contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1];
        Id contentDocumentId = contentVersion.ContentDocumentId;
        
        // Create ContentDocumentLink using TestFactory
        // This should use ContentDocumentLinkDefaults from your TestFactoryDefaults class
        ContentDocumentLink[] linkList = (ContentDocumentLink[])TestFactory.createSObjectList(new ContentDocumentLink(), 1);
        linkList[0].ContentDocumentId = contentDocumentId; // Set the dynamic fields
        linkList[0].LinkedEntityId = testAccountList[0].Id;
        linkList[0].ShareType = 'V'; // This should come from defaults, but set explicitly
        insert linkList;
        
        Signature__c signature = new Signature__c(
        Envelope_Id__c = 'xxxxxxxx-xxxx-xxx',
        Document_Id__c= contentDocumentId
        );
        insert signature;
    }
    @IsTest
    static void testReceiveData() {
        // Step 1: Create mock JSON payload
        StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = 'getAccessTokenBody'];
		String tokenBody = sr.Body.toString();

        HTTPMockGenerator res2 = new HTTPMockGenerator(200, tokenBody);

        Test.setMock(HttpCalloutMock.class, res2);
        
        StaticResource sr2 = [SELECT Body FROM StaticResource WHERE Name = 'documentSignWebhookRequest'];
		String mockJson = sr2.Body.toString();
        
        // Step 2: Set up mock RestRequest
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(mockJson);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/docusignWebhook/*';
 
        RestContext.request = req;
       // RestContext.response = new RestResponse();
 
        // Step 3: Call the method
        Test.startTest();
        DocuSignWebhook.handleWebhook();
        Test.stopTest();
 
        // Step 4: Assert expected outcomes (e.g., record creation, field values)
        // Example: check if a record was created
        // List<Account> accounts = [SELECT Name FROM Account WHERE Name = 'Test Name'];
        // System.assertEquals(1, accounts.size());
    }
}