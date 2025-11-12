/**
 * @description       : PoC restResource to be notified once the event is fired in docusign app 
 *                          complete webservice and clean code and update description
 * @author            : APC
**/
@RestResource(urlMapping='/docusignWebhook/*')
global with sharing class DocuSignWebhook {

    /**
	* @author       APB
	* @description  handleWebhook method
	*/
    @HttpPost
    global static void handleWebhook() {
        RestRequest req = RestContext.request;
        String body = req.requestBody.toString();

        System.debug('Webhook body: ' + body);

        /*
        Task a = new Task();
        a.Subject = 'DocuSign Webhook received';
        a.Description = body;
        insert a;*/

        Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(body);
        System.debug('Payload: ' + payload);
        String event = (String) payload.get('event');
        System.debug('event : ' + event );
        Map<String, Object> data = (Map<String, Object>) payload.get('data');

        String envelopeId = (String) data.get('envelopeId');
        Map<String, Object> envelopeSummary = (Map<String, Object>) data.get('envelopeSummary');
        String status = (String) envelopeSummary.get('status');
        System.debug('status : ' + status );


        if (event == 'recipient-sent' || event == 'recipient-delivered' || status == 'completed' || status == 'declined') {
            try {
                Signature__c sig = [SELECT Id, Name, Docusign_Status__c, Document_Id__c FROM Signature__c WHERE Envelope_Id__c = :envelopeId LIMIT 1];
                if (sig != null) {
                    processWebhookAsync(envelopeId, sig.Document_Id__c,status);
                    sig.Docusign_Status__c = 'Signed';
                    update sig; 
                }
            } catch (Exception e) {
                Logger.error('APX-EXC-00003 - Error processing the docusign webhook - - '+ e.getMessage()).addTag('APX-EXC');
            }
        }
    }

    /**
	* @author       APB
	* @description  processWebhookAsync method
    * @param        envelopeId String
    * @param        documentId String
	*/
    @future(callout=true)
    global static void processWebhookAsync(String envelopeId, String documentId,String status) {

        DocuSignService service = new DocuSignService('Docusign_Service');
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
            cv.pkl_Status__c= status;
            uow.registerNew(cv);
            uow.commitWork();
        }

    }
}