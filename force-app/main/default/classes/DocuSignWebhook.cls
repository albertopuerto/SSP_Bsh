@RestResource(urlMapping='/docusignWebhook/*')
global with sharing class DocuSignWebhook {

    @HttpPost
    global static void handleWebhook() {
        RestRequest req = RestContext.request;
        String body = req.requestBody.toString();

        System.debug('Webhook body: ' + body);

        Task a = new Task();
        a.Subject = 'DocuSign Webhook received';
        a.Description = body;
        insert a;

        // Suponiendo que el webhook envía JSON
        Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(body);
        System.debug('Payload: ' + payload);
        String event = (String) payload.get('event');
        Map<String, Object> data = (Map<String, Object>) payload.get('data');

        String envelopeId = (String) data.get('envelopeId');
        Map<String, Object> envelopeSummary = (Map<String, Object>) data.get('envelopeSummary');
        String status = (String) envelopeSummary.get('status');



        if (event == 'recipient-sent' || status == 'completed') {
            try {
                Signature__c sig = [SELECT Id, Name, Docusign_Status__c, Document_Id__c FROM Signature__c WHERE Envelope_Id__c = :envelopeId LIMIT 1];
                if (sig != null) {
                    processWebhookAsync(envelopeId, sig.Document_Id__c);
                    sig.Docusign_Status__c = 'Signed';
                    update sig; 
                }
            } catch (Exception e) {
                Task a2 = new Task();
                a2.Subject = 'DocuSign Webhook Error';
                a2.Description = 'Error processing webhook: ' + e.getMessage();
                insert a2;
            }
        }
    }

    @future(callout=true)
    global static void processWebhookAsync(String envelopeId, String documentId) {
            DocuSignService service = new DocuSignService('FSJ_Test');
            String accessToken = service.getAccessToken();

            Blob signedDocument = service.getSignedDocument(envelopeId, 'combined');

            ContentDocument cd = [SELECT Id, Title FROM ContentDocument WHERE Id = :documentId LIMIT 1];
            if (cd != null) {
                ContentVersion cv = new ContentVersion();
                cv.Title = 'Signed_' + cd.Title;
                cv.PathOnClient = 'Signed_' + cd.Title + '.pdf';
                cv.VersionData = signedDocument;
                cv.ContentDocumentId = cd.Id;
                insert cv;
            }

            /*if (res.getStatusCode() == 200) {
                Blob pdfBlob = res.getBodyAsBlob();

                ContentVersion content = new ContentVersion();
                content.Title = 'DocuSign firmado';
                content.PathOnClient = 'documento_firmado.pdf';
                content.VersionData = pdfBlob;
                insert content;

                Task a4 = new Task();
                a4.Subject = 'DocuSign Document Created';
                a4.Description = 'DocuSign Document Created: ' + content.Id;
                insert a4;

                // Si el recordId viene en el webhook (como campo personalizado):
                // String recordId = (String) envelopeStatus.get('customField');

                // ContentDocumentLink cdl = new ContentDocumentLink();
                // cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :content.Id LIMIT 1].ContentDocumentId;
                // cdl.LinkedEntityId = recordId;
                // cdl.ShareType = 'V';
                // cdl.Visibility = 'AllUsers';
                // insert cdl;
            } else {
                System.debug('Error al obtener documento: ' + res.getBody());
            }*/

    }
}