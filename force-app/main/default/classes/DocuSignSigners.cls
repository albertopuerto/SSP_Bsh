/**
 * @description       : Methods to send documents to be signed via DocuSign. PoC implementation.
 * @author            : APC
**/
public with sharing class DocuSignSigners {
    /**
	* @author       APB
	* @description  Method that send the documents to sign
	* @param		signatures List<InputVariables>
	* @return		List<String>
	*/
    @InvocableMethod(label='Send documents' description='Send Documents related to the sign')
    public static List<String> sendToSign(List<InputVariables> signatures) {
        InputVariables input = signatures[0];

        Set<Id> contentVersionIds = new Set<Id>();
        contentVersionIds.add(input.document.Id);

        DocuSignService service = new DocuSignService('APC_Test');

        system.debug('input.document.Id ' + input.document.Id);
        ContentVersion cv = new ContentVersionSelector().selectContentVersion(contentVersionIds)[0];

        Blob myPdfBlob = cv.VersionData;
        String base64Doc = EncodingUtil.base64Encode(myPdfBlob);

        Signature__c sig = [SELECT Id, Name, Docusign_Status__c,Envelope_Id__c, Document_Id__c FROM Signature__c WHERE Document_Id__c = :input.document.id LIMIT 1];
        
        String result = service.sendEnvelope(
            input.Signer,
            input.Signer,
            base64Doc,
            input.document.Title
        );

        processDocuSignAsync(sig.Envelope_Id__c,input.document.Id);
        system.debug('Result: ' + result);
        return new List<String>{result};
    }

    /**
	* @author       APB
	* @description  processDocuSignAsync method
    * @param        envelopeId String
    * @param        documentId String
	*/
    @future(callout=true)
    public static void processDocuSignAsync(String envelopeId, String documentId) {

        DocuSignService service = new DocuSignService('APC_Test');
        Set<Id> docIds = new Set<Id>();
        docIds.add(documentId);
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { ContentVersion.SObjectType});
        // String accessToken = service.getAccessToken();


        Blob signedDocument = service.getSignedDocument(envelopeId, 'combined');

        ContentDocument cd = new ContentDocumentSelector().selectById(docIds)[0];
        if (cd != null) {
            ContentVersion cv = new ContentVersion();
            cv.Title =  cd.Title;
            cv.PathOnClient = cd.Title + '.pdf';
            cv.VersionData = signedDocument;
            cv.ContentDocumentId = cd.Id;
            cv.pkl_Status__c= 'init';
            uow.registerNew(cv);
            uow.commitWork();
        }

    }

    /**
	* @author       APB
	* @description  InputVariables class has the document to sign and the email of the signer
	*/
    public class InputVariables {
        @InvocableVariable(label='Document' description='Document to be signed')
        public ContentDocument document;
        @InvocableVariable(label='signer' description='leMail of the signer')
        public String signer;
    }
}