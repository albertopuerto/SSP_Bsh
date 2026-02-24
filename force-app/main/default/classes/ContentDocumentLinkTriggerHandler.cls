public class ContentDocumentLinkTriggerHandler {
    
    public static void handleAfterInsert(List<ContentDocumentLink> newRecords) {
        List<SBQQ__RelatedContent__c> relatedContentList = new List<SBQQ__RelatedContent__c>();
        List<Id> contentDocumentIds = new List<Id>();

        for (ContentDocumentLink cdl : newRecords) {
            try {
                if (cdl.LinkedEntityId.getSObjectType() == SBQQ__Quote__c.SObjectType) {
                    contentDocumentIds.add(cdl.ContentDocumentId);
                }
            } catch (Exception e) {
                Logger.error('Error collecting ContentDocumentIds from ContentDocumentLink records',e);
                    throw e;
            }finally {
            Logger.saveLog();
        	}
        }

        if (!contentDocumentIds.isEmpty()) {
            Map<Id, ContentDocument> contentDocumentMap = new Map<Id, ContentDocument>(
                [SELECT Id, Title, FileExtension FROM ContentDocument WHERE Id IN :contentDocumentIds]
            );

            for (ContentDocumentLink cdl : newRecords) {
                try {
                    if (cdl.LinkedEntityId.getSObjectType() == SBQQ__Quote__c.SObjectType) {

                        // PDF validation
                        ContentDocument cDoc = contentDocumentMap.get(cdl.ContentDocumentId);
                        if (cDoc == null || cDoc.FileExtension == null || 
                            cDoc.FileExtension.toLowerCase() != 'pdf') {
                            cdl.addError('Only PDF files are allowed to be uploaded to Quote files.');
                            Logger.error('Non-PDF file upload attempted on Quote record')
                                .setRecord(cdl)
                                .setMessage('ContentDocumentId: ' + cdl.ContentDocumentId + 
                                            ' | LinkedEntityId: ' + cdl.LinkedEntityId +
                                            ' | FileExtension: ' + (cDoc != null ? cDoc.FileExtension : 'Unknown'));
                            continue;
                        }

                        SBQQ__RelatedContent__c relatedContent = new SBQQ__RelatedContent__c();
                        relatedContent.SBQQ__ExternalId__c = cdl.ContentDocumentId;
                        relatedContent.SBQQ__Quote__c = cdl.LinkedEntityId;
                        relatedContent.Name = cDoc.Title;
                        relatedContentList.add(relatedContent);
                    }
                } catch (Exception e) {
                    Logger.error('Error processing ContentDocumentLink record during PDF validation loop', e);
                  } finally {
                        Logger.saveLog();
                        }
            }

            if (!relatedContentList.isEmpty()) {
                try {
                    insert relatedContentList;
                } catch (DmlException dmlEx) {
                    Logger.error('DML Error inserting SBQQ__RelatedContent__c records', dmlEx);
                    
                }
                 finally {
                        Logger.saveLog();
                        }
            }
        }
    }
}