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

        DocuSignService service = new DocuSignService('Docusign_Service');

        ContentVersion cv = new ContentVersionSelector().selectContentVersion(contentVersionIds)[0];

        Blob myPdfBlob = cv.VersionData;
        String base64Doc = EncodingUtil.base64Encode(myPdfBlob);

        String result = service.sendEnvelope(
            input.Signer,
            input.Signer,
            base64Doc,
            input.document.Title
        );

        processDocuSignAsync(input.document.Id);
        return new List<String>{result};
    }

    /**
	* @author       APB
	* @description  processDocuSignAsync method
    * @param        documentId String
	*/
    @future(callout=true)
    public static void processDocuSignAsync(String documentId) {

        Set<Id> docIds = new Set<Id>();
        docIds.add(documentId);
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { ContentVersion.SObjectType});

        ContentDocument cd = new ContentDocumentSelector().selectById(docIds)[0];
        ContentVersion lastCv = new ContentVersionSelector().selectLastContentVersion(docIds)[0];
        if (cd != null) {
            ContentVersion cv = new ContentVersion();
            cv.Title =  cd.Title;
            cv.PathOnClient = cd.Title + '.pdf';
            cv.VersionData = lastCv.VersionData;
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