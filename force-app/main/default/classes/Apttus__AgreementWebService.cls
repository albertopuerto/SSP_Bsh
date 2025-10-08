/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global abstract class AgreementWebService {
    global AgreementWebService() {

    }
    webService static Boolean activateAgreement(Id agreementId, List<Id> selectedDocIds, List<Id> removableDocIds) {
        return null;
    }
    webService static Boolean afterAmend(Id originalId, Id amendmentId) {
        return null;
    }
    webService static Boolean afterClone(Id originalId, Id cloneId) {
        return null;
    }
    webService static Boolean afterRenew(Id originalId, Id renewalId) {
        return null;
    }
    webService static Apttus__APTS_Agreement__c amendAgreement(Id originalId) {
        return null;
    }
    webService static Boolean cancelAgreement(Id agreementId) {
        return null;
    }
    webService static Apttus__APTS_Agreement__c cloneAgreement(Id originalId) {
        return null;
    }
    webService static Boolean expireAgreement(Id agreementId) {
        return null;
    }
    webService static Boolean finalizeClausesForSendForSignature(Id agreementId, List<Id> documentVersionIds) {
        return null;
    }
    webService static String getProtectionLevel(Id profileId, String actionName) {
        return null;
    }
    webService static Boolean publishToChatterRepository(Id agreementId, Id attachmentId) {
        return null;
    }
    webService static Boolean publishToDocumentRepository(Id agreementId, Id attachmentId) {
        return null;
    }
    webService static Boolean publishToExternalRepository(Id agreementId, Id attachmentId) {
        return null;
    }
    webService static Apttus__APTS_Agreement__c renewAgreement(Id originalId) {
        return null;
    }
    webService static Apttus__APTS_Template__c selectFirstTemplateForSObject(Id sObjectId, String templateType, String queryTemplateType) {
        return null;
    }
    webService static Id selectFirstTemplateIdForAgreement(Id agreementId) {
        return null;
    }
    webService static Boolean sendForReview(Id agreementId, Id emailTemplateId, List<String> lstEmailTo, List<String> lstEmailCc, List<String> lstEmailBcc, List<Id> lstFileIds, Boolean isProtect, String protectionLevel) {
        return null;
    }
    webService static Boolean sendForSignature(Id primaryContactID, List<String> emailCc, List<String> emailBcc, List<String> emailAdditionalTo, Id emailTemplateId, Id agreementId, List<Id> attachmentIds) {
        return null;
    }
    webService static Boolean submitRequestToQueue(Id agreementId) {
        return null;
    }
    webService static Boolean terminateAgreement(Id agreementId) {
        return null;
    }
    webService static Id terminateAgreementsAsync(List<Id> agreementIds) {
        return null;
    }
    webService static String updateSmartFieldsOnAgreementDocument(Id agreementId, Id documentId) {
        return null;
    }
}
