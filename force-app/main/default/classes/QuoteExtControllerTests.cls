@isTest
private class QuoteExtControllerTests {
    
    @isTest
    static void testSubmit() {
        // Create a Quote record using TestFactory
        SBQQ__Quote__c[] testQuoteList = (SBQQ__Quote__c[])TestFactory.createSObjectList(new SBQQ__Quote__c(), 1);
        insert testQuoteList;
        SBQQ__Quote__c quote = testQuoteList[0];
        
        Test.startTest();
        QuoteExtController con = new QuoteExtController(new ApexPages.StandardController(quote));
        con.onSubmit();
        quote = [SELECT ApprovalStatus__c FROM SBQQ__Quote__c WHERE Id = :quote.Id LIMIT 1];
        Test.stopTest();
        
        System.assertEquals('Approved', quote.ApprovalStatus__c);
    }
    
    @isTest
    static void testRecall() {
        // Create a Quote record using TestFactory
        SBQQ__Quote__c[] testQuoteList = (SBQQ__Quote__c[])TestFactory.createSObjectList(new SBQQ__Quote__c(), 1);
        insert testQuoteList;
        SBQQ__Quote__c quote = testQuoteList[0];
        
        Test.startTest();
        QuoteExtController con = new QuoteExtController(new ApexPages.StandardController(quote));
        con.onRecall();
        quote = [SELECT ApprovalStatus__c FROM SBQQ__Quote__c WHERE Id = :quote.Id LIMIT 1];
        Test.stopTest();
        
        System.assertEquals('Recalled', quote.ApprovalStatus__c);
    }
}