# 🧪 TestFactory Framework

The **TestFactory** framework is designed to simplify the creation of test data in Salesforce. It provides a structured way to define default values for various objects and profiles, making test cases more efficient and reusable.

---

## 📁 Class Structure

### 1️⃣ `TestFactory.cls`
Main class of the framework. It provides static methods to create one or multiple `SObjects` with default values, with the option to insert them into the database.

**Key Methods:**
- `createSObject(SObject sObj)`
- `createSObject(SObject sObj, Boolean doInsert)`
- `createSObject(SObject sObj, String defaultClassName)`
- `createSObject(SObject sObj, String defaultClassName, Boolean doInsert)`
- `createSObjectList(SObject sObj, Integer numberOfObjects)`
- `createSObjectList(SObject sObj, Integer numberOfObjects, Boolean doInsert)`
- `createSObjectList(SObject sObj, Integer numberOfObjects, String defaultClassName)`
- `createSObjectList(SObject sObj, Integer numberOfObjects, String defaultClassName, Boolean doInsert)`

---

### 2️⃣ `TestFactoryDefaults.cls`
Defines default values for different objects and profiles. Each inner class must implement the `TestFactory.FieldDefaults` interface, which requires a `getFieldDefaults()` method returning a map of default field values.

✨ Define one method per object, and customize methods for different record types if needed.

---

### 3️⃣ `TestFactoryConstants.cls`
Centralizes constants and utilities for the framework. It avoids unnecessary queries by storing IDs for profiles and record types.

**Key Components:**
- `MAP_PROFILE_IDS`: Map of profile developer names to IDs.
- `MAP_OBJ_RECORD_TYPE_IDS`: Map of object names to their RecordType IDs.

---

### 4️⃣ `TestFactoryTests.cls`
Contains test methods to validate the functionality of the TestFactory framework, including object creation, insertion, and handling of default values.

---

## 🚀 How to Use TestFactory in Tests

### 1. ⚒️ Define Default Values
```apex
public class AccountDefaults implements TestFactory.FieldDefaults {
    public Map<Schema.SObjectField, Object> getFieldDefaults() {
        return new Map<Schema.SObjectField, Object> {
            Account.Name => 'Customer Account',
            Account.RecordTypeID => TestFactoryConstants.MAP_OBJ_RECORD_TYPE_IDS.get('Account').get('Customer'),
            Account.Phone => '0123456'
        };
    }
}
```

---

### 2. 📝 Create Objects in Tests
```apex
@IsTest
static void testCreateAccount() {
    Account acc = (Account)TestFactory.createSObject(new Account());
    System.assertEquals('Customer Account', acc.Name);
    acc.Phone = '666555444';
    insert acc;
}
```

---

### 3. 📥 Insert Objects into Database
```apex
@IsTest
static void testInsertAccount() {
    Account acc = (Account)TestFactory.createSObject(new Account(), true);
    System.assertNotEquals(null, acc.Id);
}
```

---

### 4. 📋 Create Lists of Objects
```apex
@IsTest
static void testCreateAccountList() {
    Account[] accounts = (Account[])TestFactory.createSObjectList(new Account(), 5);
    System.assertEquals(5, accounts.size());
}
```

---

### 5. 🎯 Use Specific Defaults
```apex
@IsTest
static void testCreateSupplierAccount() {
    Account acc = (Account)TestFactory.createSObject(new Account(), 'TestFactoryDefaults.SupplierAccountDefault');
    System.assertEquals('Supplier Account', acc.Name);
}
```

---

### 6. 👤 Run Tests as Specific User
```apex
@IsTest
static void testRunAsProductManager() {
    User productManagerUser = (User)TestFactory.createSObject(new User(), 'TestFactoryDefaults.ProductManagerUserDefaults', true);
    System.runAs(productManagerUser) {
        Account acc = (Account)TestFactory.createSObject(new Account(), true);
        System.assertEquals('Customer Account', acc.Name);
    }
}
```

---

## ✅ Best Practices

- 🧰 **Centralize default values** in `TestFactoryDefaults.cls`.
- ♻️ **Reuse defaults** for similar objects to avoid duplication.
- 🆔 **Use constants** from `TestFactoryConstants.cls` instead of hardcoded IDs.
- 🔍 **Validate the created data** to ensure default values are correctly applied.
- 👥 **Test different user contexts** using `System.runAs`.

---

With ❤️ by Alberto Puerto


