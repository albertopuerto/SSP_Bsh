/**
 * @description Domain class for ContentDocument
 * BSSP-7090: Handles deletion of relevant Additional Documents (SBQQ__RelatedContent__c)
 * when a ContentDocument is deleted.
 *
 * @author Iliana Dimitrova
 * @date 10.10.2025
 */
public with sharing class ContentDocumentDomain extends fflib_SObjectDomain{

    /**
     * @description Constructor for the ContentDocumentDomain class
     * @param records List of ContentDocument records from the trigger.
     */
    public ContentDocumentDomain(List<ContentDocument> records){
        super(records);
    }

    /**
     * @description Factory method required by the fflib_SObjectDomain
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description fflib construct method implementation.
         * @param sObjectList List of ContentDomain records passed by fflib
         * @return a new instance of ContentDocumentDomain
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new ContentDocumentDomain(sObjectList);
        }
    }

    /**
     * @description fflib trigger event - executed after ContentDocument records are deleted
     */
    public override void onAfterDelete() {
        try{
            Set<Id> deletedIds = new Map<Id, ContentDocument>((List<ContentDocument>) Records).keySet();
            if (deletedIds.isEmpty()) {
                return;
            }

            List<SBQQ__RelatedContent__c> relatedContentsToDelete = [SELECT Id FROM  SBQQ__RelatedContent__c WHERE SBQQ__ExternalId__c IN :deletedIds WITH SYSTEM_MODE];

            if(!relatedContentsToDelete.isEmpty()){
                delete as system relatedContentsToDelete;
            }
        }
        catch(Exception ex) {
            Logger.error('Error in ContentDocumentDomain.onAfterDelete', ex);
            throw ex;
        } finally {
            Logger.saveLog();
        }
    }
}