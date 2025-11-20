@isTest
public class DocuSignSigners_Test {

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
    
    @isTest
    public static void sendDocumentToSign(){
        Docusign_Setting__mdt config = [SELECT clientId__c, userId__c, audience__c, certificateName__c,DeveloperName, accountId__c, baseUrl__c FROM Docusign_Setting__mdt WITH USER_MODE LIMIT 1];
        StaticResource sr2 = [SELECT Body FROM StaticResource WHERE Name = 'getAccessTokenBody'];
		String tokenBody = sr2.Body.toString();

        StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = 'getSignedDocument'];
		String signedDocument = sr.Body.toString();

        HTTPMockGenerator res1 = new HTTPMockGenerator(200, signedDocument);
        HTTPMockGenerator res2 = new HTTPMockGenerator(200, tokenBody);

        HttpMultiRequestMockGenerator multiMock = new HttpMultiRequestMockGenerator();
        multiMock.putMock('https://account-d.docusign.com/oauth/token',res2);
		multiMock.putMock('https://demo.docusign.net/restapi/v2.1/accounts/ec94da4e-5b4e-4e5d-a3ac-35dac0b0f786/envelopes',res1);
        
        Test.setMock(HttpCalloutMock.class, multiMock);
        List<DocuSignSigners.InputVariables> variables = new List<DocuSignSigners.InputVariables>(); 
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
}