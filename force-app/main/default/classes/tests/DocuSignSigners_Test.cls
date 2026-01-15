@isTest
public class DocuSignSigners_Test {

   
    @testSetup
    public static void initRecords(){
        
        DocusignSettings__c settings = new DocusignSettings__c();
        settings.account_id__c= 'ec94da4e-5b4e-4e5d-a3ac-35dac0b0f786';
        insert settings;
            
        Account[] testAccountList = (Account[])TestFactory.createSObjectList(new Account(), 1);
        testAccountList[0].pkl_PaymentTerms__c= 'Due on receipt';
        insert testAccountList;

        Contact[] testContactList = (Contact[])TestFactory.createSObjectList(new Contact(), 1);
        testContactList[0].AccountId = testAccountList[0].Id;
        insert testContactList;
        
         SBQQ__Quote__c[] quoteList = (SBQQ__Quote__c [])TestFactory.createSObjectList(new SBQQ__Quote__c(),1);
        quoteList[0].SBQQ__Status__c = 'Draft';
        quoteList[0].SBQQ__Account__r = testAccountList[0];
        quoteList[0].lkp_BillToAccount__c= testAccountList[0].Id;
        insert quoteList;
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
        	linkList[0].LinkedEntityId = quoteList[0].Id;
        	linkList[0].ShareType = 'V'; // This should come from defaults, but set explicitly
        	insert linkList;
        
        	Signature__c signature = new Signature__c(
        	Envelope_Id__c = 'xxxxxxxx-xxxx-xxx',
        	Document_Id__c= contentDocumentId
        	);
        	insert signature;
        
    }
    
    @isTest
    public static void sendDocumentToSign(){
        User productManagerUser = createUser();
        
        StaticResource sr2 = [SELECT Body FROM StaticResource WHERE Name = 'getAccessTokenBody'];
		String tokenBody = sr2.Body.toString();

        StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = 'getSignedDocument'];
		String signedDocument = sr.Body.toString();

        HTTPMockGenerator res1 = new HTTPMockGenerator(200, signedDocument);
        HTTPMockGenerator res2 = new HTTPMockGenerator(200, tokenBody);

        HttpMultiRequestMockGenerator multiMock = new HttpMultiRequestMockGenerator();
        multiMock.putMock('https://account-d.docusign.com/oauth/token',res2);
		multiMock.putMock('callout:docusignCredential/restapi/v2.1/accounts/ec94da4e-5b4e-4e5d-a3ac-35dac0b0f786/envelopes',res1);
        
        Test.setMock(HttpCalloutMock.class, multiMock);
        List<DocuSignSigners.InputVariables> variables = new List<DocuSignSigners.InputVariables>();
        SBQQ__Quote__c quote= [Select id from SBQQ__Quote__c LIMIT 1];
        ContentVersion cv = [SELECT Id,VersionData from ContentVersion LIMIT 1];
        ContentDocument cd = [Select Id,Title from ContentDocument LIMIT 1];
        Contact cont = [Select Id,Email from Contact LIMIT 1];

        DocuSignSigners.InputVariables variable= new DocusignSigners.InputVariables();
        variable.document=cd;
        variable.signer= cont.Email;
        
        variables.add(variable);
      	Assert.areNotEqual(null,variable.document, 'The document is not null');
        Test.startTest();
            
        List<String> listDocuments = DocuSignSigners.sendToSign(variables);
        System.debug(listDocuments);
        System.assertEquals('1f2713d9-af87-8885-8159-a69d30b51125', listDocuments[0]);
        Test.stopTest();
    
    }

    static User createUser(){
        User productManagerUser = (User)TestFactory.createSObject(new User(), 'TestFactoryDefaults.ProductManagerUserDefaults', true);
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SalesBasic' LIMIT 1];
        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'DocusignUser' LIMIT 1];
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'CPQAdvancedApprovalsAdmin' LIMIT 1];
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
         PermissionSetAssignment psa3 = new PermissionSetAssignment(
            AssigneeId = productManagerUser.Id,
            PermissionSetId = ps3.Id
        );
        insert psa3;
        return productManagerUser;
    }
}