/**
* @author       APB
* @description  UserSelector: Selector class for users
*/
public with sharing class UserSelector extends fflib_SObjectSelector {

    public static final String SIGNERS = 'Signers';
    /**
	* @author       APB
	* @description  user getSObjectFieldList method
	* @return		List<Schema.SObjectField>
	*/
     public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            User.Name,
            User.Email
        };
    }

    /**
	* @author       APB
	* @description  user getActiveSignerUsers method
	* @return		List<ContentVersion>
	*/
    public List<User> selectGetActiveSignerUsers() {
    List<User> users = new List<User>();
    for(User user : Database.query(
        newQueryFactory(false)
        .selectField(User.Name)
        .selectField(User.Email)
        .setCondition('Id IN ( SELECT UserOrGroupId FROM GroupMember WHERE Group.Name =: SIGNERS) AND IsActive = TRUE')
        .toSOQL()))
    {
        users.add(user);
    }
        return users;
    }

    /**
	* @author       APB
	* @description  user getSObjectType method
	* @return		Schema.SObjectType
	*/
    public Schema.SObjectType getSObjectType() {
        return User.sObjectType;
    }

    /**
	* @author       APB
	* @description  user selectById method
    * @param		idSet Set<ID>
	* @return		List<contentVersion>
	*/
    public List<User> selectById(Set<ID> idSet) {
        return (List<User>) selectSObjectsById(idSet);
    }
}