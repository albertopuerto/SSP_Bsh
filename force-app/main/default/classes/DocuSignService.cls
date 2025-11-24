/**
	* @author       APB
	* @description  DocuSignService class
	*/
public with sharing class DocuSignService {
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
	* @description  DocuSignService constructor
	* @param		configName String
	*/
    public DocuSignService(String configName) {
        Docusign_Setting__mdt config = [SELECT clientId__c, userId__c, audience__c, certificateName__c, accountId__c, baseUrl__c FROM Docusign_Setting__mdt WHERE DeveloperName = :configName WITH USER_MODE LIMIT 1];
        this.clientId = config.clientId__c;
        this.userId = config.userId__c;
        this.audience = config.audience__c;
        this.certName = config.certificateName__c;
        this.accountId = config.accountId__c;
        this.baseUrl = config.baseUrl__c;
    }

    /**
	* @author       APB
	* @description  Method that gets the access token
	* @return		String
	*/
    public String getAccessToken() {
        Long now = DateTime.now().getTime() / 1000;

        if (cachedAccessToken != null && tokenExpirationEpoch != null && now < tokenExpirationEpoch - 60) {
            return cachedAccessToken;
        }

        Long exp = now + 3600;

        Map<String, Object> header = new Map<String, Object>{
            'alg' => 'RS256',
            'typ' => 'JWT'
        };

        Map<String, Object> claims = new Map<String, Object>{
            'iss' => clientId,
            'sub' => userId,
            'aud' => audience,
            'iat' => now,
            'exp' => exp,
            'scope' => 'signature impersonation'
        };

        String headerEncoded = encodeBase64Url(JSON.serialize(header));
        String claimsEncoded = encodeBase64Url(JSON.serialize(claims));
        String unsignedJWT = headerEncoded + '.' + claimsEncoded;

        Blob signature;

        if (!Test.isRunningTest()) {
            signature = Crypto.signWithCertificate('RSA-SHA256', Blob.valueOf(unsignedJWT), certName);
        } else {
            signature = Blob.valueOf('mock-signature');
        }
        String signedJWT = unsignedJWT + '.' + encodeBase64Url(signature);

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://account-d.docusign.com/oauth/token');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody('grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=' + signedJWT);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() != 200) {
            Logger.error('APX-INT-00006 - Failed when trying to get the access token - '+ res.getStatusCode() +'-'+res.getBody()).addTag('APX-INT');
            throw new CalloutException('Failed when trying to get the access token: ' + res.getBody());
        }

        Map<String, Object> jsonRes = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        cachedAccessToken = (String) jsonRes.get('access_token');
        tokenExpirationEpoch = now + ((Integer) jsonRes.get('expires_in'));

        return cachedAccessToken;
    }

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

        String endpoint = 'callout:docusignCredential/restapi/v2.1/accounts/ec94da4e-5b4e-4e5d-a3ac-35dac0b0f786/envelopes';

        Map<String, Object> envelopeDefinition = new Map<String, Object>{
            'emailSubject' => 'Por favor firme el documento adjunto',
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

        map <Id, list<Id>> mapIdDocs = new map<Id, list<Id>>();
        Set<Id> docIds = new Set<Id>();
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
            mapDocs.put(cd.Id, cd);
        }

        List<OutputVariables> retList = new List<OutputVariables>();
        for (Id recId : mapIdDocs.keySet()) {
            OutputVariables ov = new OutputVariables();
            ov.files = new List<ContentDocument>();
            for (Id docId : mapIdDocs.get(recId)) {
                if (mapDocs.containsKey(docId)) {
                    ov.files.add(mapDocs.get(docId));
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
    }
}