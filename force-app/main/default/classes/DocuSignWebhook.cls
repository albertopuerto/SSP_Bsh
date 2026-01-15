/**
 * @description       : restResource to be notified once the event is fired in docusign app
 *                        
 * @author            : APC
**/
@RestResource(urlMapping='/docusignWebhook/*')
global without sharing class DocuSignWebhook {

    public static final String prefixAttach = '00P';

    /**
	* @author       APB
	* @description  handleWebhook method
	*/
    @HttpPost
    global static void handleWebhook() {
        RestRequest req = RestContext.request;
        RestResponse response = RestContext.response;
        ResponseWrapper responseWrap = new ResponseWrapper();
        String body = req.requestBody.toString();

        Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(body);
        String event = (String) payload.get('event');
        Map<String, Object> data = (Map<String, Object>) payload.get('data');

        String envelopeId = (String) data.get('envelopeId');
        Map<String, Object> envelopeSummary = (Map<String, Object>) data.get('envelopeSummary');
        String status = (String) envelopeSummary.get('status');
        status = status.capitalize();

        if (event == 'recipient-sent' || event == 'recipient-delivered' || status == 'Completed' || status == 'declined') {
            try {
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { Signature__c.SObjectType});
                Signature__c sig = [SELECT Id, Name, Docusign_Status__c, Document_Id__c FROM Signature__c WHERE Envelope_Id__c = :envelopeId WITH USER_MODE LIMIT 1];
                if (sig != null) {
                    processWebhookAsync(envelopeId, sig.Document_Id__c,status);
                    sig.Docusign_Status__c = status;
                    uow.registerDirty(sig);
                    uow.commitWork();
                    responseWrap.responseCode= 200;
		            responseWrap.responseBody= 'OK - succesful processing of the docusign webhook';
                }else{
                    responseWrap.responseBody= 'Signature not found';
                    responseWrap.responseCode= 404;
                }
            } catch (Exception e) {
                Logger.error('APX-EXC-00003 - Error processing the docusign webhook - - '+ e.getMessage()).addTag('APX-EXC');
                responseWrap.responseBody= 'INTERNAL_SERVER_ERROR - Error processing the docusign webhook'+ e.getMessage();
                responseWrap.responseCode= 500;
            }finally{
                response.statusCode = responseWrap.responseCode;
            	response.responseBody = responseWrap.responseBody != null ? blob.valueOf(responseWrap.responseBody) : null;
            }
        }else{
            responseWrap.responseBody= 'BAD_REQUEST - Event not allowed';
            responseWrap.responseCode= 400;

            response.statusCode = responseWrap.responseCode;
            response.responseBody = responseWrap.responseBody != null ? blob.valueOf(responseWrap.responseBody) : null;
        }
    }

    /**
	* @author       APB
	* @description  processWebhookAsync method
    * @param        envelopeId String
    * @param        documentId String
    * @param        status String
	*/
    @future(callout=true)
    global static void processWebhookAsync(String envelopeId, String documentId,String status) {

        DocuSignService service = new DocuSignService();
        Set<Id> docIds = new Set<Id>();
        docIds.add(documentId);
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { ContentVersion.SObjectType});
        // String accessToken = service.getAccessToken();

        Blob signedDocument = service.getSignedDocument(envelopeId, 'combined');
        String prefixRecord = documentId.left(3);
    
        if (prefixRecord != prefixAttach) {
            ContentDocument cd = new ContentDocumentSelector().selectById(docIds)[0];
            ContentVersion cv = new ContentVersion();
            cv.Title =  cd.Title;
            cv.PathOnClient = cd.Title + '.pdf';
            cv.VersionData = signedDocument;
            cv.ContentDocumentId = cd.Id;
            cv.pkl_Status__c= status;
            uow.registerNew(cv);
            uow.commitWork();
        }else if(prefixRecord == prefixAttach && status == 'completed'){

                Attachment oldAttachment= [SELECT Id, Name, Body, ContentType, ParentId FROM Attachment WHERE Id =:documentId];
                Attachment att = new Attachment();
                if (att != null) {
                    att.Body = signedDocument;
                    att.ParentId= oldAttachment.ParentId;
                    att.Name= oldAttachment.Name.substringBefore('.') +'_signed.pdf';
                }

                insert att;
        }

    }
    public class ResponseWrapper {
        public String responseBody;
        public Integer responseCode;
    }
}