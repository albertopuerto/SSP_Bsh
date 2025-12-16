/**
* @author       APB
* @description  ContentDocumentLinkSelector: Selector class for content document links
*/
public with sharing class ContentDocumentLinkSelector extends fflib_SObjectSelector {

    /**
	* @author       APB
	* @description  contentDocumentLink getSObjectFieldList method
	* @return		List<Schema.SObjectField>
	*/
     public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
           ContentDocumentLink.Id,
           ContentDocumentLink.LinkedEntityId,
           ContentDocumentLink.ContentDocumentId
        };
    }

    /**
	* @author       APB
	* @description  contentDocumentLink selectContentDocumentLink method
    * @param		idSet Set<ID>
	* @return		List<ContentDocumentLink>
	*/
    public List<ContentDocumentLink> selectContentDocumentLink(Set<Id> idSet) {
    List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
    for(ContentDocumentLink contentDocumentLink : Database.query(
        newQueryFactory(false)
        .selectField(ContentDocumentLink.LinkedEntityId)
        .selectField(ContentDocumentLink.Id)
        .selectField(ContentDocumentLink.ContentDocumentId)
        .setCondition('LinkedEntityId in :idSet')
        .toSOQL()))
    {
        contentDocumentLinks.add(contentDocumentLink);
    }
        return contentDocumentLinks;
    }

    /**
	* @author       APB
	* @description  contentDocumentLink getSObjectType method
	* @return		Schema.SObjectType
	*/
    public Schema.SObjectType getSObjectType() {
        return ContentDocumentLink.sObjectType;
    }
}