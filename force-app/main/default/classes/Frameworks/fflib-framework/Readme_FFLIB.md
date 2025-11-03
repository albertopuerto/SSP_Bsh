# Mastering fflib in Apex: Clean Architecture for Salesforce

## Chapter 1: Why fflib? Why Clean Architecture?

🔧 **Problem:**

- ⚠️ **Triggers become spaghetti code**: As your org grows, business logic gets scattered across multiple triggers. Over time, these become hard to read, debug, or extend, leading to brittle systems.
- 💥 **DML scattered everywhere**: You may find DML operations spread across different classes, methods, or even in loops, increasing the risk of hitting governor limits and causing inconsistent data states.
- 🧩 **No separation of concerns**: Business logic, validation, data access, and orchestration are often tangled together. This makes the code difficult to understand, reuse, or test independently.
- 🧪 **Poor testability**: Without clear structure or dependency injection, unit testing becomes difficult. Most tests end up being integration tests that are slow, fragile, and hard to maintain.

💡 **Solution:**

- There are several frameworks, we were wondering mainly to use fflib or kevin o´hara frameworks
- Use **fflib (Apex Common)** to apply **Enterprise Design Patterns (EDP)** in Apex

📐 **What are Enterprise Design Patterns (EDP)?**

Enterprise Design Patterns are proven architectural strategies for building scalable, testable, and maintainable software in large systems. These patterns were introduced in Martin Fowler’s "Patterns of Enterprise Application Architecture" and adapted for Salesforce by the fflib library.

🧱 **How fflib applies EDP in Apex:**

- **Domain-Driven Design (DDD)**: Logic lives inside Domain classes, not triggers.
- **Separation of Concerns**: Each layer (service, domain, selector) has a distinct responsibility.
- **Unit of Work**: Manages DML to ensure consistency.
- **Repository/Selector Pattern**: Reuse SOQL queries.
- **Dependency Injection & Mocking**: Enables real unit tests.

🎯 **Benefits:**

- ✅ Maintainable & scalable code
- ♻️ Reusable logic
- 🧪 Easy to test
- 🐞 Fewer bugs in production

---

## Chapter 2: 🧭 Overview of the Architecture

```
               +-------------------------+
               |     Presentation        |
               +-----------+-------------+
                           ↓
               +-----------+-------------+
               |     Service Layer       |
               +-----------+-------------+
                           ↓
               +-----------+-------------+
               |     Domain Layer        |
               +-----------+-------------+
                           ↓
               +-----------+-------------+
               |     Selector Layer      |
               +-----------+-------------+
                           ↓
               +-----------+-------------+
               |   UnitOfWork / DML Mgmt |
               +-------------------------+


```
🧾 **Summary or layers:**
- **Selector** – all of your queries go into this layer.
- **Domain** – the layer which contains reusable pieces of code for working with sObjects and is the entry point for handling trigger events.
- **Service** – business logic orchestration layer which can be called from anywhere in your application.
- **Unit of work** – a pattern for managing transactions on the platform.
- **Application** - an application class is responsible for defining which classes are responsible for handling the different types of business logic requests within our code base. More info [FFLIB Application Structure](https://quirkyapex.com/2017/12/03/fflib-application-structure/)

---

## Chapter 3: Domain Layer (`fflib_SObjectDomain`)

**Purpose:** Encapsulate object-specific logic\
**Extends:** `fflib_SObjectDomain`\
**Triggers delegate to this**

```apex
public class AccountDomain extends fflib_SObjectDomain {
    public override void onBeforeInsert() {
        for (Account acc : (List<Account>) Records) {
            if (acc.Industry == null) {
                acc.Industry = 'Technology';
            }
        }
    }
}
```

✅ Keeps validation logic out of triggers
✅ Keeps your logic deduplicated and central
✅ One trigger and one Domain Layer per sObject
✏️ We can use different handler classes inside the Domain Layer

---

## Chapter 4: ⚡ Triggers + Domain

```apex
trigger AccountTrigger on Account (before insert, before update) {
    fflib_SObjectDomain.triggerHandler(Account.class);
}
```

**Why?**

- Triggers become 1-liners
- All logic is moved to domain layer
- Easy to test

---

## Chapter 5: 🧾 Unit of Work (`fflib_SObjectUnitOfWork`)

**Purpose:** Manage DML operations declaratively and in bulk

```apex
fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
    new Schema.SObjectType[]{ Account.SObjectType, Opportunity.SObjectType }
);

Account acc = new Account(Name = 'New Corp');
uow.registerNew(acc);

Opportunity opp = new Opportunity(...);
uow.registerNew(opp);

uow.commitWork();
```

✅ DML is centralized and safe\
✅ No partial commits

Method	Description
🆕 registerNew	       - To INSERT
✏️ registerDirty	   - To UPDATE
🗑️ registerDeleted	    - To DELETE
✅ registerClean	      - No DML needed

---

## Chapter 6: 🔍 Selector Layer (`fflib_SObjectSelector`)

**Purpose:** Centralize and reuse SOQL logic\
**Built using:** `fflib_QueryFactory`

```apex
public class AccountSelector extends fflib_SObjectSelector {
    public List<Account> getAccountsByIndustry(List<String> lstcountries) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition(
            'BillingCountry IN :lstcountries'
        );
        return (List<Account>) Database.query(query.toSOQL());
    }
}
```

✅ DRY: Don’t Repeat Yourself\
✅ Dynamically build queries\
✅ Use in services or domain classes

---

## Chapter 7: 🧠 Service Layer

**Purpose:** Orchestrate actions using selectors, domains, unit of work

```apex
public class AccountService {
    public static void createAccountWithOpportunity() {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(...);

        Account acc = new Account(Name = 'New Corp');
        uow.registerNew(acc);

        Opportunity opp = new Opportunity(...);
        uow.registerNew(opp);

        uow.commitWork();
    }
}
```

✅ Keeps coordination logic separate\
✅ Supports mocking & testing

---

## Chapter 8: 🧪 Testing with ApexMocks

**Using ApexMocks:**

- Inject mocked selectors, domains, or unit of work
- Test services in isolation
- Simulate and verify behavior without depending on actual database calls

```apex
@isTest
private class AccountServiceTest {
    static testMethod void testCreateAccount() {
        // Arrange
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountSelector mockSelector = (IAccountSelector) mocks.mock(IAccountSelector.class);
        IApplication.UnitOfWork mockUow = (IApplication.UnitOfWork) mocks.mock(IApplication.UnitOfWork.class);

        // Inject mocks into the application class (your DI layer)
        Application.UnitOfWork.setMock(mockUow);
        Application.AccountSelector.setMock(mockSelector);

        // Act
        AccountService.createAccountWithOpportunity();

        // Assert
        ((fflib_ApexMocks) mocks).verify(mockUow, 1).registerNew(fflib_Match.anyObject());
        ((fflib_ApexMocks) mocks).verify(mockUow, 1).commitWork();
    }
}
```

✅ Focus on behavior, not plumbing\
✅ Easy to fake dependencies = real unit tests

---

## Chapter 9: 📌 Summary & Best Practices

✅ Triggers → Domain
✅ Domain → Object logic
✅ Service → Coordination
✅ UnitOfWork → DML
✅ Selector → SOQL
✅ ApexMocks → Test


🏁 **Result:**

- 🧹 Code is clean
- 📈 Easy to scale
- 🐞 Fewer bugs
- 😄 Happy developers


With ❤️ by Alberto Puerto

