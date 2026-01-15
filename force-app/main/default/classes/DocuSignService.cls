/**
	* @author       APB
	* @description  DocuSignService class
	*/
public without sharing class DocuSignService {
    private String clientId;
    private String userId;
    private String audience;
    private String certName;
    private String accountId;
    private String baseUrl;

    private static String cachedAccessToken;
    private static Long tokenExpirationEpoch;

    /**
	* @author       APB
	* @description  Method that send the email
	* @param		recipientEmail String
    * @param		recipientName String
    * @param		documentBase64 String
    * @param		documentName String
	* @return		String
	*/
    public String sendEnvelope(String recipientEmail, String recipientName, String documentBase64, String documentName) {

        DocusignSettings__c	settings = [Select account_id__c from DocusignSettings__c Limit 1];
        String endpoint = 'callout:docusignCredential/restapi/v2.1/accounts/'+settings.account_id__c+'/envelopes';

        Map<String, Object> envelopeDefinition = new Map<String, Object>{
            'emailSubject' => 'Please sign the attached document',
            'documents' => new List<Object>{
                new Map<String, Object>{
                    'documentBase64' => documentBase64,
                    'name' => documentName,
                    'fileExtension' => 'pdf',
                    'documentId' => '1'
                }
            },
            'recipients' => new Map<String, Object>{
                'signers' => new List<Object>{
                    new Map<String, Object>{
                        'email' => recipientEmail,
                        'name' => recipientName,
                        'recipientId' => '1',
                        'routingOrder' => '1',
                        'tabs' => new Map<String, Object>{
                            'signHereTabs' => new List<Object>{
                                new Map<String, Object>{
                                    'anchorString' => '/firma/',
                                    'anchorYOffset' => '0',
                                    'anchorUnits' => 'pixels',
                                    'anchorXOffset' => '0'
                                }
                            }
                        }
                    }
                }
            },
            'status' => 'sent'
        };

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
		req.setTimeout(120000);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(envelopeDefinition));
        Http http = new Http();
        HttpResponse res = http.send(req);
        Map<String, Object> resMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        String envelopeId = (String) resMap.get('envelopeId');

        if (res.getStatusCode() != 201 && res.getStatusCode() != 200 ) {
            Logger.error('APX-INT-00008 - Failed when sending the envelope - '+ res.getStatusCode() +'-'+res.getBody()).addTag('APX-INT');
            throw new CalloutException('Failed to send envelope: ' + res.getBody());
        }

        return envelopeId;
    }

    /**
	* @author       APB
	* @description  Method that download the signed document
	* @param		envelopeId String
    * @param		documentId String
	* @return		Blob
	*/
    public Blob getSignedDocument(String envelopeId, String documentId) {
        String endpoint = 'callout:docusignCredential/restapi/v2.1/accounts/ec94da4e-5b4e-4e5d-a3ac-35dac0b0f786/envelopes/'+ envelopeId + '/documents/' + documentId;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');

        req.setHeader('Accept', 'application/pdf');

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() != 200) {
            Logger.error('APX-INT-00009 - Failed to download the signed document - '+ res.getStatusCode() +'-'+res.getBody()).addTag('APX-INT');
            throw new CalloutException('Failed to download signed document: ' + res.getBody());
        }

        return res.getBodyAsBlob();
    }

    private static String encodeBase64Url(String input) {
        return EncodingUtil.base64Encode(Blob.valueOf(input)).replace('+', '-').replace('/', '_').replace('=', '');
    }

    private static String encodeBase64Url(Blob input) {
        return EncodingUtil.base64Encode(input).replace('+', '-').replace('/', '_').replace('=', '');
    }

    /**
	* @author       APB
	* @description  Method that get the documents related to the record given
	* @param		recordIds List<Id>
	* @return		List<OutputVariables>
	*/
    @InvocableMethod(label='Get documents' description='Get Documents related to the recordId')
    public static List<OutputVariables> getDocumentsbyId(List<Id> recordIds) {
        Set<Id> contentVersionIds = new Set<Id>();
        for(String recordId : recordIds){
            contentVersionIds.add(recordId);
        }
        List<ContentDocumentLink> contentVersions = new ContentDocumentLinkSelector().selectContentDocumentLink(contentVersionIds);

        List<Attachment> attachments= [SELECT Id, Name,ContentType, ParentId FROM Attachment WHERE ParentId IN :recordIds];

        map <Id, list<Id>> mapIdDocs = new map<Id, list<Id>>();
        map<Id, List<Attachment>> mapAttachments = new map<Id, List<Attachment>>();
        
        Set<Id> docIds = new Set<Id>();

        for (Attachment attachment : attachments) {
            if (!mapAttachments.containsKey(attachment.ParentId)) {
                mapAttachments.put(attachment.ParentId, new List<Attachment>());
            }
            mapAttachments.get(attachment.ParentId).add(attachment);
        }

        for (ContentDocumentLink cdl : contentVersions) {
            if (!mapIdDocs.containsKey(cdl.LinkedEntityId)) {
                mapIdDocs.put(cdl.LinkedEntityId, new List<Id>());
            }
            mapIdDocs.get(cdl.LinkedEntityId).add(cdl.ContentDocumentId);
            docIds.add(cdl.ContentDocumentId);
        }

        List<ContentDocument> docs = new ContentDocumentSelector().selectById(docIds);
        map<Id, ContentDocument> mapDocs = new map<Id, ContentDocument>();
        for (ContentDocument cd : docs) {
            if(cd.FileExtension == 'pdf'){
                mapDocs.put(cd.Id, cd);
            }
        }


        List<OutputVariables> retList = new List<OutputVariables>();
        for (Id recId : mapIdDocs.keySet()) {
            OutputVariables ov = new OutputVariables();
            ov.files = new List<ContentDocument>();
            ov.attachments= new List<Attachment>();

            for (Id docId : mapIdDocs.get(recId)) {
                if (mapDocs.containsKey(docId)) {
                    ov.files.add(mapDocs.get(docId));
                }
            }
            if(!mapAttachments.isEmpty()){
            for (Attachment attch : mapAttachments.get(recId)) {

                ov.attachments.add(attch);
            }
            }
            retList.add(ov);
        }

        return retList;
    }

    /**
	* @author       APB
	* @description  OutputVariables class has the list of files to be signed
	*/
    public class OutputVariables {
        @InvocableVariable(label='files' description='list of files')
        public List<ContentDocument> files;
        @InvocableVariable(label='attachments' description='list of attachments')
        public List<Attachment> attachments;
    }
}