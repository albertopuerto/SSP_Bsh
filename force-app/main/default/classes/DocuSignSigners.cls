/**
 * @description       : Methods to send documents to be signed via DocuSign. PoC implementation.
 * @author            : APC
**/
public with sharing class DocuSignSigners {
    @InvocableMethod(label='Send documents' description='Send Documents related to the sign')
    public static List<String> sendToSign(List<InputVariables> signatures) {
        InputVariables input = signatures[0];

        DocuSignService service = new DocuSignService('APC_Test');

        system.debug('input.document.Id ' + input.document.Id);
        ContentVersion cv = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId = :input.document.Id LIMIT 1];
        Blob myPdfBlob = cv.VersionData;
        String base64Doc = EncodingUtil.base64Encode(myPdfBlob);


        String result = service.sendEnvelope(
            input.Signer,
            input.Signer,
            base64Doc,
            input.document.Title
        );
        
        system.debug('Result: ' + result);
        return new List<String>{result};
    }

    public class InputVariables {
        @InvocableVariable(label='Document' description='Document to be signed')
        public ContentDocument document;
        @InvocableVariable(label='signer' description='leMail of the signer')
        public String signer;
    }
}