/**
* @author       APC
* @date         08/04/2025
* @description  TestFactory framework: TestFactory parent class
*/
@isTest
public with sharing class TestFactory {
	/**
	* @author       APC
	* @description  createSObject constructor
	* @param		sObj SObject
	* @return		SObject
	*/
	public static SObject createSObject(SObject sObj) {
		// Check what type of object we are creating and add any defaults that are needed.
		String objectName = String.valueOf(sObj.getSObjectType());
		// Construct the default values class. Salesforce doesn't allow '__' in class names
		String defaultClassName = objectName.replaceAll('__(c|C)$|__', '') + 'Defaults';
		// If there is a class that exists for the default values, then use them
		if (Type.forName('TestFactoryDefaults.' + defaultClassName) != null) {
			sObj = createSObject(sObj, 'TestFactoryDefaults.' + defaultClassName);
		}
		return sObj;
	}

	/**
	* @author       APC
	* @description  createSObject constructor with boolean to choose between insert the row or not
	* @param		sObj SObject
	* @param		doInsert Boolean
	* @return		SObject
	*/
	public static SObject createSObject(SObject sObj, Boolean doInsert) {
		SObject retObject = createSObject(sObj);
		if (doInsert) {
			insert retObject;
		}
		return retObject;
	}

	/**
	* @author       APC
	* @description  createSObject constructor with defaultClassName param
	* @param		sObj SObject
	* @param		defaultClassName String
	* @return		SObject
	*/
	public static SObject createSObject(SObject sObj, String defaultClassName) {
		// Create an instance of the defaults class so we can get the Map of field defaults
		Type typ = Type.forName(defaultClassName);
		if (typ == null) {
			Throw new TestFactoryException('Invalid defaults class.');
		}
		FieldDefaults defaults = (FieldDefaults)typ.newInstance();
		addFieldDefaults(sObj, defaults.getFieldDefaults());
		return sObj;
	}

	/**
	* @author       APC
	* @description  createSObject constructor
	* @param		sObj SObject
	* @param		defaultClassName String
	* @param		doInsert Boolean
	* @return		SObject
	*/
	public static SObject createSObject(SObject sObj, String defaultClassName, Boolean doInsert) {
		SObject retObject = createSObject(sObj, defaultClassName);
		if (doInsert) {
			insert retObject;
		}
		return retObject;
	}

	/**
	* @author       APC
	* @description  createSObject constructor
	* @param		sObj SObject
	* @param		numberOfObjects Integer
	* @return		SObject[]
	*/
	public static SObject[] createSObjectList(Sobject sObj, Integer numberOfObjects) {
		return createSObjectList(sObj, numberOfObjects, (String)null);
	}

	/**
	* @author       APC
	* @description  createSObject constructor
	* @param		sObj SObject
	* @param		numberOfObjects Integer
	* @param		doInsert Boolean
	* @return		SObject[]
	*/
	public static SObject[] createSObjectList(SObject sObj, Integer numberOfObjects, Boolean doInsert) {
		SObject[] retList = createSObjectList(sObj, numberOfObjects, (String)null);
		if (doInsert) {
			insert retList;
		}
		return retList;
	}

	/**
	* @author       APC
	* @description  createSObject constructor
	* @param		sObj SObject
	* @param		numberOfObjects Integer
	* @param		defaultClassName String
	* @param		doInsert Boolean
	* @return		SObject[]
	*/
	public static SObject[] createSObjectList(SObject sObj, Integer numberOfObjects, String defaultClassName, Boolean doInsert) {
		SObject[] retList = createSObjectList(sObj, numberOfObjects, defaultClassName);
		if (doInsert) {
			insert retList;
		}
		return retList;
	}

	/**
	* @author       APC
	* @description  createSObject constructor
	* @param		sObj SObject
	* @param		numberOfObjects Integer
	* @param		defaultClassName String
	* @return		SObject[]
	*/
	public static SObject[] createSObjectList(Sobject sObj, Integer numberOfObjects, String defaultClassName) {
		SObject[] sObjs = new SObject[] {};
		SObject newObj;

		// Get one copy of the object
		if (defaultClassName == null) {
			newObj = createSObject(sObj);
		} else {
			newObj = createSObject(sObj, defaultClassName);
		}

		// Get the name field for the object
		String nameField = String.valueOf(nameFieldMap.get(sObj.getSObjectType()));
	// namefield is 
        if (nameField == null) {
			nameField = 'Name';
		}
		Boolean nameIsAutoNumber = sObj.getSobjectType().getDescribe().fields.getMap().get(nameField).getDescribe().isAutoNumber();
         // Boolean nameIsAutoNumber = sObj.getSobjectType().getDescribe().fields.getMap().get(nameField).getDescribe().isAutoNumber() != null ? sObj.getSobjectType().getDescribe().fields.getMap().get(nameField).getDescribe().isAutoNumber() : false;
		// Clone the object the number of times requested. Increment the name field so each record is unique
		for (Integer i = 0; i < numberOfObjects; i++) {
			SObject clonedSObj = newObj.clone(false, true);
			if (!nameIsAutoNumber) {
				clonedSObj.put(nameField, (String)clonedSObj.get(nameField) + ' ' + i);
			}
			sObjs.add(clonedSObj);
		}
		return sObjs;
	}

	/**
	* @author       APC
	* @description  createSObject constructor
	* @param		sObj SObject
	* @param		defaults Map<Schema.SObjectField, Object>
	*/
	private static void addFieldDefaults(SObject sObj, Map<Schema.SObjectField, Object> defaults) {
		// Loop through the map of fields and if they weren't specifically assigned, fill them.
		Map<String, Object> populatedFields = sObj.getPopulatedFieldsAsMap();
		for (Schema.SObjectField field : defaults.keySet()) {
			if (!populatedFields.containsKey(String.valueOf(field))) {
				sObj.put(field, defaults.get(field));
			}
		}
	}

	/**
	* @author       APC
	* @description  When we create a list of SObjects, we need to have a unique field for the insert if there isn't an autonumber field.
					Usually we use the Name field, but some objects don't have a name field.
	*/
	private static Map<Schema.SObjectType, Schema.SObjectField> nameFieldMap = new Map<Schema.SObjectType, Schema.SObjectField> {
		Account.sObjectType => Account.txt_AthenaUUID__c,
		Contact.sObjectType => Contact.LastName,
		Opportunity.sObjectType => Opportunity.Name,
		Order.sObjectType => Order.Name,
		Product2.sObjectType => Product2.Name,
		Quote.sObjectType => Quote.Name,
		Apttus__Agreement_Clause__c.sObjectType => Apttus__Agreement_Clause__c.Apttus__ContentId__c,
        sbaa__Approval__c.SObjectType => sbaa__Approval__c.Name,
        sbaa__Approver__c.SObjectType => sbaa__Approver__c.Name,
        ContentVersion.SObjectType => ContentVersion.Title,
        ContentDocumentLink.SObjectType => ContentDocumentLink.ContentDocumentId,
		OrderItem.sObjectType => OrderItem.txt_SAPExternalLineItemId__c,
		PricebookEntry.sObjectType => PricebookEntry.GearsetExternalId__c,
		SBQQ__QuoteLine__c.sObjectType => SBQQ__QuoteLine__c.Name
	};
     

	public class TestFactoryException extends Exception {}

	/**
	* @author       APC
	* @description  Use the FieldDefaults interface to set up values you want to default in for all objects.
	*/
	public interface FieldDefaults {
		Map<Schema.SObjectField, Object> getFieldDefaults();
	}

}