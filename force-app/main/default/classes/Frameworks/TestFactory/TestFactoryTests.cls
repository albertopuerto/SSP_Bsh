/**
* @author       APC
* @date         08/04/2025
* @description  TestFactoryTests
*/
@IsTest
private with sharing class TestFactoryTests {

    /**
    * @description  Test that default fields are populated when an object is created
    */    
    @IsTest
    static void testCreateObject_DefaultFieldsPopulated() {
        Account acc = (Account)TestFactory.createSObject(new Account());
        
        Test.startTest();
        System.assertEquals('Customer_B2B Account', acc.Name, 'Default field value is not set correctly');
        Test.stopTest();
    }

    /**
    * @description  Test that default fields are populated when an object is inserted
    */
    @IsTest
    static void testInsertObject_DefaultFieldsPopulated() {
        Account acc = (Account)TestFactory.createSObject(new Account(), true);
        
        Test.startTest();
        acc = [SELECT Name FROM Account WHERE Id = :acc.Id];
        System.assertEquals('Customer_B2B Account', acc.Name, 'Default field value is not set correctly');
        Test.stopTest();
    }

    /**
    * @description  Test that specific default fields are populated when an object is created
    */
    @IsTest
    static void testCreateObject_SpecificDefaultsPopulated() {
        Account acc = (Account)TestFactory.createSObject(new Account(), 'TestFactoryDefaults.SupplierAccountDefault');
        
        Test.startTest();
        System.assertEquals('Supplier Account', acc.Name, 'Specific default field value is not set correctly');
        Test.stopTest();
    }

    /**
    * @description  Test that specific default fields are populated when an object is inserted
    */    
    @IsTest
    static void testInsertObject_SpecificDefaultsPopulated() {
        Account acc = (Account)TestFactory.createSObject(new Account(), 'TestFactoryDefaults.SupplierAccountDefault', true);
        
        Test.startTest();
        acc = [SELECT Name FROM Account WHERE Id = :acc.Id];
        System.assertEquals('Supplier Account', acc.Name, 'Specific default field value is not set correctly');
        Test.stopTest();
    }

    /**
    * @description  Test that default fields are populated for a list of objects when created
    */
    @IsTest
    static void testCreateObjectList_DefaultFieldsPopulated() {
        Account[] aList = (Account[])TestFactory.createSObjectList(new Account(), 200);
        
        Test.startTest();
        for (Account acc : aList) {
            System.assert(acc.Name.startsWith('Customer_B2B Account'), 'Default field value is not set correctly');
        }
        Test.stopTest();
    }

    /**
    * @description  Test that default fields are populated for a list of objects when inserted
    */
    @IsTest
    static void testInsertObjectList_DefaultFieldsPopulated() {
        Account[] aList = (Account[])TestFactory.createSObjectList(new Account(), 200, true);
        
        Test.startTest();
        aList = [SELECT Name FROM Account WHERE Id IN :aList ORDER BY Name];
        for (Account acc : aList) {
            System.assert(acc.Name.startsWith('Customer_B2B Account'), 'Default field value is not set correctly');
        }
        Test.stopTest();
    }

    /**
    * @description  Test that specific default fields are populated for a list of objects when created
    */
    @IsTest
    static void testCreateObjectList_SpecificDefaultsPopulated() {
        Account[] aList = (Account[])TestFactory.createSObjectList(new Account(), 200, 'TestFactoryDefaults.SupplierAccountDefault');
        
        Test.startTest();
        for (Account acc : aList) {
            System.assert(acc.Name.startsWith('Supplier Account'), 'Specific default field value is not set correctly');
        }
        Test.stopTest();
    }

    /**
    * @description  Test that specific default fields are populated for a list of objects when inserted
    */
    @IsTest
    static void testInsertObjectList_SpecificDefaultsPopulated() {
        Account[] aList = (Account[])TestFactory.createSObjectList(new Account(), 200, 'TestFactoryDefaults.SupplierAccountDefault', true);
        
        Test.startTest();
        aList = [SELECT Name FROM Account WHERE Id IN :aList ORDER BY Name];
        for (Account acc : aList) {
            System.assert(acc.Name.startsWith('Supplier Account'), 'Specific default field value is not set correctly');
        }
        Test.stopTest();
    }

    /**
    * @description  Test that an exception is thrown for an invalid defaults class
    */
    @IsTest
    static void testCreateSObject_InvalidDefaultsClassThrowsException() {
        Test.startTest();
        try {
            Account acc = (Account)TestFactory.createSObject(new Account(), 'InvalidDefaultsClass');
            System.assert(false, 'Expected exception was not thrown');
        } catch (TestFactory.TestFactoryException e) {
            System.assertEquals('Invalid defaults class.', e.getMessage(), 'Exception message does not match');
        }
        Test.stopTest();
    }

    /**
    * @description  Test that autonumber fields are handled correctly
    */
    @IsTest
    static void testCreateSObjectList_AutoNumberFieldHandled() {
        Account acc = new Account();
        acc.put('Name', null); // Simulate an autonumber field
        Account[] aList = (Account[])TestFactory.createSObjectList(acc, 5);
        
        Test.startTest();
        for (Account a : aList) {
            System.assert(a.Name == null, 'Autonumber field should not be modified');
        }
        Test.stopTest();
    }

    /**
    * @description  Test that the record type IDs are built correctly
    */
    @IsTest
    static void testBuildProfileIds() {
        Map<String, Id> mapProfileIds = TestFactoryConstants.MAP_PROFILE_IDS;
        System.assertNotEquals(null, mapProfileIds.get('SalesRead'), 'SalesRead profile ID should not be null');
        System.assertNotEquals(null, mapProfileIds.get('ProductManager'), 'ProductManager profile ID should not be null');
    }

    /**
    * @description  Test that the record type IDs are built correctly
    */
    @IsTest
    static void testBuildRecordTypeIds() {
        Map<String, Map<String, Id>> mapRecordTypeIds = TestFactoryConstants.MAP_OBJ_RECORD_TYPE_IDS;
        System.assertNotEquals(null, mapRecordTypeIds, 'MAP_OBJ_RECORD_TYPE_IDS should not be null');

        System.assertNotEquals(null, mapRecordTypeIds.get('Account'), 'RecordType IDs for Account should not be null');
        System.assertNotEquals(null, mapRecordTypeIds.get('Account').get('Customer_B2B'), 'Customer RecordType ID for Account should not be null');
        System.assertNotEquals(null, mapRecordTypeIds.get('Account').get('Competitor'), 'Competitor RecordType ID for Account should not be null');

        System.assertNotEquals(null, mapRecordTypeIds.get('Opportunity'), 'RecordType IDs for Opportunity should not be null');
        System.assertNotEquals(null, mapRecordTypeIds.get('Opportunity').get('StandardSolutionOrder'), 'StandardSolutionOrder RecordType ID for Opportunity should not be null');
        System.assertNotEquals(null, mapRecordTypeIds.get('Opportunity').get('FrameContract'), 'FrameContract RecordType ID for Opportunity should not be null');

    }
    /**
    * @description  Test that a Product Manager user is created and behaves correctly creating one account
    */
    @IsTest
    static void insertAccountAsProductManagerUser() {
        User productManagerUser = (User)TestFactory.createSObject(new User(), 'TestFactoryDefaults.ProductManagerUserDefaults', true);

        System.runAs(productManagerUser) {
            Test.startTest();
            Account acc = (Account)TestFactory.createSObject(new Account(), true);
            System.assertEquals('Customer_B2B Account', acc.Name, 'Default field value is not set correctly for Product Manager user');
            Test.stopTest();
        }
    }
}