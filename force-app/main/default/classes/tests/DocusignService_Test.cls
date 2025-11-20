@isTest
public class DocusignService_Test {

    @testSetup
    public static void initRecords(){
        
        Account[] testAccountList = (Account[])TestFactory.createSObjectList(new Account(), 1);
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
        
    }
    
    @isTest
    public static void sendEnvelope(){
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
        System.assertEquals('1f2713d9-af87-8885-8159-a69d30b51125', result);
        System.debug(result);
        Test.stopTest();
    }
    
    @isTest
    public static void getSignedDocument(){
        
        Docusign_Setting__mdt config = [SELECT clientId__c, userId__c, audience__c, certificateName__c,DeveloperName, accountId__c, baseUrl__c FROM Docusign_Setting__mdt WITH USER_MODE LIMIT 1];
        StaticResource sr2 = [SELECT Body FROM StaticResource WHERE Name = 'getAccessTokenBody'];
		String tokenBody = sr2.Body.toString();
       
        HTTPMockGenerator res2 = new HTTPMockGenerator(200, tokenBody);
        Test.setMock(HttpCalloutMock.class, res2);
        DocuSignService service = new DocuSignService('Docusign_Service');
     	ContentDocument cd = [Select Id,Title from ContentDocument LIMIT 1];
        Test.startTest();
        Blob document = service.getSignedDocument('2131232312434546', 'combined');
        System.debug(document);
        Assert.areNotEqual(null, document, 'The document is not null');
        Blob expectedBlob = Blob.valueOf('PDFDATA');
    	System.assert(document.size() > 0, 'The document should contain data');
        
        Test.stopTest();
    }
    
    @isTest
    public static void getDocumentsById(){
        List<Id> listDocumentIds= new List<Id>();
        ContentDocument cd = [Select Id,Title from ContentDocument LIMIT 1];
        SBQQ__Quote__c quote= [Select id from SBQQ__Quote__c LIMIT 1];
     	ContentVersion cv = [SELECT Id,VersionData,ContentDocumentId from ContentVersion LIMIT 1];
        ContentDocumentLink cdl = [SELECT Id,ContentDocumentId,LinkedEntityId,ShareType from ContentDocumentLink WHERE ContentDocumentId=: cd.Id LIMIT 1];
        listDocumentIds.add(quote.Id);
        Assert.areNotEqual(null, listDocumentIds, 'The list of documents is not null');
        Test.startTest();
        List<DocusignService.OutputVariables> documentsRetrieved= DocuSignService.getDocumentsbyId(listDocumentIds);
        System.assertEquals(1, documentsRetrieved[0].files.size());
        System.assertEquals('Test Document 0', documentsRetrieved[0].files[0].Title);
        System.debug(documentsRetrieved);
        Test.stopTest();
    }
}