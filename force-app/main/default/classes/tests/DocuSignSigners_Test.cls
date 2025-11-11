@isTest
public class DocuSignSigners_Test {

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
    }
    
    @isTest
    public static void sendDocumentToSign(){
        StaticResource sr2 = [SELECT Body FROM StaticResource WHERE Name = 'getAccessTokenBody'];
		String tokenBody = sr2.Body.toString();

        HTTPMockGenerator res2 = new HTTPMockGenerator(200, tokenBody);

        Test.setMock(HttpCalloutMock.class, res2);
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
        DocuSignSigners.sendToSign(variables);
        Test.stopTest();
    }
}