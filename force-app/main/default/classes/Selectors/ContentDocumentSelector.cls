/**
* @author       APB
* @description  ContentDocumentSelector: Selector class for content documents
*/
public with sharing class ContentDocumentSelector extends fflib_SObjectSelector {

    /**
	* @author       APB
	* @description  contentDocuments getSObjectFieldList method
	* @return		List<Schema.SObjectField>
	*/
     public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            ContentDocument.Title,
            ContentDocument.Id
        };
    }

    /**
	* @author       APB
	* @description  contentDocuments getSObjectType method
	* @return		Schema.SObjectType
	*/
    public Schema.SObjectType getSObjectType() {
        return ContentDocument.sObjectType;
    }

    /**
	* @author       APB
	* @description  contentDocuments selectById method
    * @param		idSet Set<ID>
	* @return		List<ContentDocument>
	*/
    public List<ContentDocument> selectById(Set<ID> idSet) {
        return (List<ContentDocument>) selectSObjectsById(idSet);
    }
}