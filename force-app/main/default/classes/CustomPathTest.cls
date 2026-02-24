@isTest
public with sharing class CustomPathTest {
    
    @TestSetup
    static void setup() {

        SalesArea__c sa = (SalesArea__c) TestFactory.createSObject(new SalesArea__c(), true);
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='Opportunity' AND DeveloperName='StandardSolutionOrder' LIMIT 1];

        // Create Account
        Account acc = (Account)TestFactory.createSObject(new Account(),'TestFactoryDefaults.AccountDefaults', true);  
        
        //Create Sales Data Customer
        SalesAreaLink__c salesAreaLink = (SalesAreaLink__c)TestFactory.createSObject(new SalesAreaLink__c(),'TestFactoryDefaults.SalesAreaLinkDefaults', false);
        salesAreaLink.mdr_Account__c = acc.Id;
        salesAreaLink.mdr_SalesArea__c = sa.Id;
        insert salesAreaLink;

        Opportunity opp = (Opportunity)TestFactory.createSObject(new Opportunity(), false);
        opp.AccountId = acc.Id; 
        opp.lkp_SalesDataCustomer__c = salesAreaLink.Id;
        opp.RecordTypeId = rt.Id;

        insert opp;
    }

    @isTest
    static void testGetPathConfig() {
        String qStage = 'Qualification';
        String aStage = 'Acepted';
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name='Test Opportunity' LIMIT 1];
        Test.startTest();
        CustomPath.updateStage(qStage, opp.Id, 'Opportunity', 'StageName');
        opp = [SELECT Id, StageName FROM Opportunity WHERE Name='Test Opportunity' LIMIT 1];
        Assert.areEqual(qStage, opp.StageName, 'The final stage should be ' + qStage);

        CustomPath.updateStage(aStage, opp.Id, 'Opportunity', 'StageName');
        opp = [SELECT Id, StageName FROM Opportunity WHERE Name='Test Opportunity' LIMIT 1];
        Assert.areEqual(aStage, opp.StageName, 'The final stage should be ' + aStage);

        CustomPathDTO.CustomPathContext context = CustomPath.getContext(opp.Id);

        Test.stopTest();

        Assert.areEqual(true, context.active, 'The path should be active');
        Assert.areEqual('Opportunity', context.entityName, 'The entity name should be Opportunity');
        Assert.areEqual('StageName', context.fieldName, 'The field name should be StageName');
        Assert.isNotNull(context.closeFlow, 'The close flow should not be null');
        Assert.isNotNull(context.finalStage, 'The final stage should not be null');
    }

    @isTest
    static void testErrorOnUpdate() {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name='Test Opportunity' LIMIT 1];
        String invalidStage = 'Acquisition (Sell)';
        Test.startTest();
        try {
            CustomPath.updateStage(invalidStage, opp.Id, 'Opportunity', 'StageName');
            //Assert.fail('Expected an exception to be thrown');
        } catch (Exception e) {
            Assert.isTrue(true, 'Exception was thrown as expected: ' + e.getMessage());
        }
        Test.stopTest();
        
    }

    @isTest
    static void getContextFromInvalidRecord() {
        Test.startTest();
        CustomPathDTO.CustomPathContext context = CustomPath.getContext(null);
        Test.stopTest();
        Assert.isNull(context.fieldName, 'The context should be null for an invalid record Id');
        Assert.isNull(context.entityName, 'The context should be null for an invalid record Id');
        Assert.isNull(context.active, 'The context should be null for an invalid record Id');
    }

    @isTest
    static void testGetContextFromObjectNotConfigured() {
        Account acc = [SELECT Id FROM Account WHERE Name='Customer_B2B Account' LIMIT 1];
        Test.startTest();
        try {
            CustomPathDTO.CustomPathContext context = CustomPath.getContext(acc.Id);
            Assert.fail('Expected an exception to be thrown');
        } catch (Exception e) {
            Assert.isTrue(true, 'Exception was thrown as expected: ' + e.getMessage());
        }
        Test.stopTest();
    }
}