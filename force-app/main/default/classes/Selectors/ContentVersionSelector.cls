/**
* @author       APB
* @description  ContentVersionSelector: Selector class for content versions
*/
public with sharing class ContentVersionSelector extends fflib_SObjectSelector {

    /**
	* @author       APB
	* @description  contentVersion getSObjectFieldList method
	* @return		List<Schema.SObjectField>
	*/
     public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
           ContentVersion.VersionData
        };
    }

    /**
	* @author       APB
	* @description  contentVersion selectContentVersion method
    * @param		idSet Set<ID>
	* @return		List<ContentVersion>
	*/
    public List<ContentVersion> selectContentVersion(Set<Id> idSet) {
    List<ContentVersion> contentVersions = new List<ContentVersion>();
    for(ContentVersion contentVersion : Database.query(
        newQueryFactory(false)
        .selectField(ContentVersion.VersionData)
        .setCondition('ContentDocumentId in :idSet')
        .toSOQL()))
    {
        contentVersions.add(contentVersion);
    }
        return contentVersions;
    }

    /**
	* @author       APB
	* @description  contentVersion selectContentVersion method
    * @param		idSet Set<ID>
	* @return		List<ContentVersion>
	*/
    public List<ContentVersion> selectLastContentVersion(Set<Id> idSet) {
    List<ContentVersion> contentVersions = new List<ContentVersion>();
    for(ContentVersion contentVersion : Database.query(
        newQueryFactory(false)
        .selectField(ContentVersion.VersionData)
        .setCondition('ContentDocumentId in :idSet')
        .setCondition('IsLatest = true')
        .toSOQL()))
    {
        contentVersions.add(contentVersion);
    }
        return contentVersions;
    }

    /**
	* @author       APB
	* @description  contentVersion getSObjectType method
	* @return		Schema.SObjectType
	*/
    public Schema.SObjectType getSObjectType() {
        return ContentVersion.sObjectType;
    }

    /**
	* @author       APB
	* @description  contentVersion selectById method
    * @param		idSet Set<ID>
	* @return		List<contentVersion>
	*/
    public List<ContentVersion> selectById(Set<ID> idSet) {
        return (List<ContentVersion>) selectSObjectsById(idSet);
    }
}