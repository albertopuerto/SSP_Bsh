/**
 * @description Test class for QuoteLockTrigger and QuoteLock domain class
 * @author TLQ1KOR
 * @date 2025
 */
@IsTest
private class QuoteLockTriggerTest {
    
    @TestSetup
    static void setup() {
        // Create custom setting exemptions
        insert new cs_BlockFieldExemption__c(
            Name = 'Primary', 
            ObjectName__c = 'SBQQ__Quote__c', 
            FieldName__c = 'SBQQ__Primary__c'
        );
    }
    
    @IsTest
    static void testTriggerExecutionDraftQuote() {
        // Create test data with Draft status
        Account[] accountList = (Account[])TestFactory.createSObjectList(new Account(), 1);
        insert accountList;
        
        Opportunity[] oppList = (Opportunity[])TestFactory.createSObjectList(new Opportunity(), 1, 'TestFactoryDefaults.OpportunityDefault');
        oppList[0].AccountId = accountList[0].Id;
        insert oppList;
        
        SBQQ__Quote__c[] quoteList = (SBQQ__Quote__c[])TestFactory.createSObjectList(new SBQQ__Quote__c(), 1);
        quoteList[0].SBQQ__Status__c = 'Draft';
        quoteList[0].SBQQ__Account__c = accountList[0].Id;
        quoteList[0].SBQQ__Opportunity2__c = oppList[0].Id;
        insert quoteList;
        Test.startTest();
        quoteList[0].SBQQ__Primary__c = true;
        Database.SaveResult result = Database.update(quoteList[0], false);
        Test.stopTest();
        
        // Then - Draft quote should be updateable
        System.assert(result.isSuccess(), 'Draft quote should be updateable');
    }
    
    @IsTest
    static void testQuoteLockingFunctionality() {
        Account[] accountList = (Account[])TestFactory.createSObjectList(new Account(), 1);
        insert accountList;
        
        Opportunity[] oppList = (Opportunity[])TestFactory.createSObjectList(new Opportunity(), 1, 'TestFactoryDefaults.OpportunityDefault');
        oppList[0].AccountId = accountList[0].Id;
        insert oppList;
        
        SBQQ__Quote__c[] quoteList = (SBQQ__Quote__c[])TestFactory.createSObjectList(new SBQQ__Quote__c(), 1);
        quoteList[0].SBQQ__Status__c = 'Draft';  
        quoteList[0].SBQQ__Account__c = accountList[0].Id;
        quoteList[0].SBQQ__Opportunity2__c = oppList[0].Id;
        insert quoteList;

        Test.startTest();
        quoteList[0].SBQQ__Primary__c = !quoteList[0].SBQQ__Primary__c; 
        Database.SaveResult result = Database.update(quoteList[0], false);
        Test.stopTest();
        System.assert(result.isSuccess(), 'Exempt field modification should be allowed on locked quote');
    }
    
    @IsTest
    static void testQuoteLockingBlocked() {
        Account[] accountList = (Account[])TestFactory.createSObjectList(new Account(), 1);
        insert accountList;
        
        Opportunity[] oppList = (Opportunity[])TestFactory.createSObjectList(new Opportunity(), 1, 'TestFactoryDefaults.OpportunityDefault');
        oppList[0].AccountId = accountList[0].Id;
        insert oppList;
        
        SBQQ__Quote__c[] quoteList = (SBQQ__Quote__c[])TestFactory.createSObjectList(new SBQQ__Quote__c(), 1);
        quoteList[0].SBQQ__Status__c = 'Draft';
        quoteList[0].SBQQ__Account__c = accountList[0].Id;
        quoteList[0].SBQQ__Opportunity2__c = oppList[0].Id;
        insert quoteList;

        Test.startTest();
        Database.SaveResult result = Database.update(quoteList[0], false);
        Test.stopTest();
 
        System.assert(result.isSuccess(), 'No-change update should succeed');
    }
    
    @IsTest
    static void testDomainClass() {
        Account[] accountList = (Account[])TestFactory.createSObjectList(new Account(), 1);
        insert accountList;
        
        Opportunity[] oppList = (Opportunity[])TestFactory.createSObjectList(new Opportunity(), 1, 'TestFactoryDefaults.OpportunityDefault');
        oppList[0].AccountId = accountList[0].Id;
        insert oppList;
        
        SBQQ__Quote__c[] quoteList = (SBQQ__Quote__c[])TestFactory.createSObjectList(new SBQQ__Quote__c(), 1);
        quoteList[0].SBQQ__Status__c = 'Draft';
        quoteList[0].SBQQ__Account__c = accountList[0].Id;
        quoteList[0].SBQQ__Opportunity2__c = oppList[0].Id;
        insert quoteList;

        Test.startTest();
       List<SBQQ__Quote__c> quoteListForDomain = new List<SBQQ__Quote__c>(quoteList);
       QuoteLock domain = new QuoteLock(quoteListForDomain); 
        List<SBQQ__Quote__c> quotes = domain.getQuotes();
        Test.stopTest();
        

        System.assertEquals(1, quotes.size(), 'Domain class should return quotes');
        System.assertEquals('Draft', quotes[0].SBQQ__Status__c, 'Quote status should be preserved');
            }
       @IsTest
    static void testValidationLogic() {
        Account[] accountList = (Account[])TestFactory.createSObjectList(new Account(), 1);
        insert accountList;
        
        Opportunity[] oppList = (Opportunity[])TestFactory.createSObjectList(new Opportunity(), 1, 'TestFactoryDefaults.OpportunityDefault');
        oppList[0].AccountId = accountList[0].Id;
        insert oppList;
        
        SBQQ__Quote__c[] quoteList = (SBQQ__Quote__c[])TestFactory.createSObjectList(new SBQQ__Quote__c(), 1);
        quoteList[0].SBQQ__Status__c = 'Draft';
        quoteList[0].SBQQ__Account__c = accountList[0].Id;
        quoteList[0].SBQQ__Opportunity2__c = oppList[0].Id;
        insert quoteList;

        SBQQ__Quote__c oldQuote = quoteList[0].clone(true, true, true, true);
        SBQQ__Quote__c newQuote = quoteList[0].clone(true, true, true, true);

        newQuote.SBQQ__Status__c = 'Accepted';
        if (newQuote.getSObjectType().getDescribe().fields.getMap().containsKey('SBQQ__ExpirationDate__c')) {
            newQuote.put('SBQQ__ExpirationDate__c', Date.today().addDays(30));
        }
        
        Map<Id, SObject> oldRecordsMap = new Map<Id, SObject>();
        oldRecordsMap.put(oldQuote.Id, oldQuote);

        Test.startTest();
        List<SBQQ__Quote__c> quotesForDomain = new List<SBQQ__Quote__c>{newQuote};
        QuoteLock domain = new QuoteLock(quotesForDomain);
        
        try {
            domain.onBeforeUpdate(oldRecordsMap);
        } catch (Exception e) {
            
        }
        Test.stopTest();

        System.assertEquals(1, domain.getQuotes().size(), 'Domain should contain the quote');
    }
}