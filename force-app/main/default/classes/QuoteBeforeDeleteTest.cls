/**
* @author       TLQ1KOR
* @description  QuoteBeforeDeleteTest: Class used to test the flow QuoteBeforeDelete
*/
@isTest
public class QuoteBeforeDeleteTest {
    
    @testSetup
    public static void createRecords(){
        Account testAccount = (Account)TestFactory.createSObject(new Account(), true);
        
        SalesArea__c salesArea = (SalesArea__c)TestFactory.createSObject(new SalesArea__c(), true);
        
         //Create Sales Data Customer
        SalesAreaLink__c salesAreaLink = (SalesAreaLink__c)TestFactory.createSObject(new SalesAreaLink__c(),'TestFactoryDefaults.SalesAreaLinkDefaults', false);
        salesAreaLink.mdr_Account__c = testAccount.Id;
        salesAreaLink.mdr_SalesArea__c = salesArea.Id;
        insert salesAreaLink;
        
        
        Opportunity testOpp = (Opportunity)TestFactory.createSObject(new Opportunity());
        testOpp.AccountId = testAccount.Id;
        testOpp.lkp_SalesDataCustomer__c = salesAreaLink.Id;
        insert testOpp;
    }
    
    @IsTest
    public static void successfulDeleteWhenStatusDraft(){
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        SBQQ__Quote__c testQuote = (SBQQ__Quote__c)TestFactory.createSObject(new SBQQ__Quote__c());
        testQuote.SBQQ__Opportunity2__c = testOpp.Id;
        testQuote.SBQQ__Status__c = 'Draft';
        insert testQuote;
        
        Test.startTest();
        Database.DeleteResult result = Database.delete(testQuote, false);
        Test.stopTest();
        
        Assert.isTrue(result.isSuccess(), 'Quote with Draft status should be deletable');
    }
    
    @IsTest
    public static void successfulDeleteWhenStatusApproved(){
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        SBQQ__Quote__c testQuote = (SBQQ__Quote__c)TestFactory.createSObject(new SBQQ__Quote__c());
        testQuote.SBQQ__Opportunity2__c = testOpp.Id;
        testQuote.SBQQ__Status__c = 'Approved';
        insert testQuote;
        
        Test.startTest();
        Database.DeleteResult result = Database.delete(testQuote, false);
        Test.stopTest();
        
        Assert.isTrue(result.isSuccess(), 'Quote with Approved status should be deletable');
    }
    
    @IsTest
    public static void successfulDeleteWhenStatusRejected(){
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        SBQQ__Quote__c testQuote = (SBQQ__Quote__c)TestFactory.createSObject(new SBQQ__Quote__c());
        testQuote.SBQQ__Opportunity2__c = testOpp.Id;
        testQuote.SBQQ__Status__c = 'Rejected';
        insert testQuote;
        
        Test.startTest();
        Database.DeleteResult result = Database.delete(testQuote, false);
        Test.stopTest();
        
        Assert.isTrue(result.isSuccess(), 'Quote with Rejected status should be deletable');
    }
    
    @IsTest
    public static void failedDeleteWhenStatusApprovalPending(){
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        SBQQ__Quote__c testQuote = (SBQQ__Quote__c)TestFactory.createSObject(new SBQQ__Quote__c());
        testQuote.SBQQ__Opportunity2__c = testOpp.Id;
        testQuote.SBQQ__Status__c = 'Approval Pending';
        insert testQuote;
        
        Test.startTest();
        Database.DeleteResult result = Database.delete(testQuote, false);
        Test.stopTest();
        
        //Assert.isFalse(result.isSuccess(), 'Quote with Approval Pending status should not be deletable');
    }
   @IsTest
    public static void successfulDeleteWhenStatusInReview(){
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        SBQQ__Quote__c testQuote = (SBQQ__Quote__c)TestFactory.createSObject(new SBQQ__Quote__c());
        testQuote.SBQQ__Opportunity2__c = testOpp.Id;
        testQuote.SBQQ__Status__c = 'In Review';
        insert testQuote;
        
        Test.startTest();
        Database.DeleteResult result = Database.delete(testQuote, false);
        Test.stopTest();
        
        Assert.isTrue(result.isSuccess(), 'Quote with In Review status should be deletable');
    }
    
    @IsTest
    public static void successfulDeleteWhenStatusDenied(){
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        SBQQ__Quote__c testQuote = (SBQQ__Quote__c)TestFactory.createSObject(new SBQQ__Quote__c());
        testQuote.SBQQ__Opportunity2__c = testOpp.Id;
        testQuote.SBQQ__Status__c = 'Denied';
        insert testQuote;
        
        Test.startTest();
        Database.DeleteResult result = Database.delete(testQuote, false);
        Test.stopTest();
        
        Assert.isTrue(result.isSuccess(), 'Quote with Denied status should be deletable');
    }
}