@isTest
public class DocusignService_Test {

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
    public static void sendEnvelope(){
        Docusign_Setting__mdt config = [SELECT clientId__c, userId__c, audience__c, certificateName__c,DeveloperName, accountId__c, baseUrl__c FROM Docusign_Setting__mdt WITH USER_MODE LIMIT 1];
        
        StaticResource sr2 = [SELECT Body FROM StaticResource WHERE Name = 'getAccessTokenBody'];
		String tokenBody = sr2.Body.toString();

        HTTPMockGenerator res2 = new HTTPMockGenerator(200, tokenBody);

        Test.setMock(HttpCalloutMock.class, res2);
        DocusignService docusignService= new DocuSignService(config.DeveloperName);
        
        ContentVersion cv = [SELECT Id,VersionData from ContentVersion LIMIT 1];
        ContentDocument cd = [Select Id,Title from ContentDocument LIMIT 1];
        Contact cont = [Select Id,Email from Contact LIMIT 1];

        Assert.areNotEqual(null, cd, 'The document is not null');
        Blob myPdfBlob = cv.VersionData;
        String base64Doc = EncodingUtil.base64Encode(myPdfBlob);
        Test.startTest();
        String result = docusignService.sendEnvelope(
            cont.Email,
            cont.Email,
            base64Doc,
            cd.Title
        );
        Test.stopTest();
    }
    
    @isTest
    public static void getSignedDocument(){
        
        StaticResource sr2 = [SELECT Body FROM StaticResource WHERE Name = 'getAccessTokenBody'];
		String tokenBody = sr2.Body.toString();

        HTTPMockGenerator res2 = new HTTPMockGenerator(200, tokenBody);

        Test.setMock(HttpCalloutMock.class, res2);
        DocuSignService service = new DocuSignService('Docusign_Service');
     	ContentDocument cd = [Select Id,Title from ContentDocument LIMIT 1];
        Test.startTest();
        Blob document = service.getSignedDocument('2131232312434546', 'combined');
        Assert.areNotEqual(null, document, 'The document is not null');
        Test.stopTest();
    }
    
    @isTest
    public static void getDocumentsById(){
        List<Id> listDocumentIds= new List<Id>();
        ContentDocument cd = [Select Id,Title from ContentDocument LIMIT 1];
     	ContentVersion cv = [SELECT Id,VersionData,ContentDocumentId from ContentVersion LIMIT 1];
        ContentDocumentLink cdl = [SELECT Id,ContentDocumentId,LinkedEntityId,ShareType from ContentDocumentLink WHERE ContentDocumentId=: cd.Id LIMIT 1];
        listDocumentIds.add(cdl.Id);
        Assert.areNotEqual(null, listDocumentIds, 'The list of documents is not null');
        Test.startTest();
        DocuSignService.getDocumentsbyId(listDocumentIds);
        Test.stopTest();
    }
}