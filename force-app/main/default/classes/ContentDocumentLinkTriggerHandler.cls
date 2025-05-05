public class ContentDocumentLinkTriggerHandler {
    
    public static void handleAfterInsert(List<ContentDocumentLink> newRecords) {
        List<SBQQ__RelatedContent__c> relatedContentList = new List<SBQQ__RelatedContent__c>();
        List<Id> contentDocumentIds = new List<Id>();

        for (ContentDocumentLink cdl : newRecords) {
            try {
                if (cdl.LinkedEntityId.getSObjectType() == SBQQ__Quote__c.SObjectType) {
                    SBQQ__RelatedContent__c relatedContent = new SBQQ__RelatedContent__c();
                    relatedContent.SBQQ__ExternalId__c = cdl.ContentDocumentId;
                    relatedContent.SBQQ__Quote__c = cdl.LinkedEntityId;
                    relatedContentList.add(relatedContent);
                    contentDocumentIds.add(cdl.ContentDocumentId);
                }
            } catch (Exception e) {
                System.debug('Error processing ContentDocumentLink: ' + e.getMessage());
                // Consider logging error using the error logging framework
            }
        }

        if (!relatedContentList.isEmpty()) {
            Map<Id, ContentDocument> contentDocumentMap = new Map<Id, ContentDocument>([SELECT Id, Title FROM ContentDocument WHERE Id IN :contentDocumentIds]);
            for (SBQQ__RelatedContent__c rcd : relatedContentList) {
                if (contentDocumentMap.containsKey(rcd.SBQQ__ExternalId__c)){
                    ContentDocument cDoc = contentDocumentMap.get(rcd.SBQQ__ExternalId__c);
                    rcd.Name = cDoc.Title;
                }
            }
            try {
                insert relatedContentList;
            } catch (DmlException dmlEx) {
                System.debug('DML Error inserting SBQQ__RelatedContent__c records: ' + dmlEx.getMessage());
                // Consider logging error using the error logging framework
            }
        }
    }
}