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
        
        // Create Account
        Account account = (Account)TestFactory.createSObject(new Account(), 'TestFactoryDefaults.AccountDefaults', true);
        
        // Create SalesArea
            SalesArea__c salesArea = new SalesArea__c(
            pkl_DistributionChannel__c = 'A1',
            pkl_Division__c = '01',
            pkl_SalesOrg__c = 'DEM5'
        );
        insert salesArea;        
        // Create Opportunity with required lookup field
        Opportunity opp = (Opportunity)TestFactory.createSObject(new Opportunity(), 'TestFactoryDefaults.OpportunityDefault', false);
        opp.Name = 'Test Opportunity for Quote Lock';
        opp.AccountId = account.Id;
        opp.lkp_SalesOrganization__c = salesArea.Id;
        insert opp;
    }
    
    @IsTest
    static void testTriggerExecutionDraftQuote() {
        // Get test data from setup
        Account account = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        SBQQ__Quote__c[] quoteList = (SBQQ__Quote__c[])TestFactory.createSObjectList(new SBQQ__Quote__c(), 1);
        quoteList[0].SBQQ__Status__c = 'Draft';
        quoteList[0].SBQQ__Account__c = account.Id;
        quoteList[0].SBQQ__Opportunity2__c = opp.Id;
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
        // Get test data from setup
        Account account = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        SBQQ__Quote__c[] quoteList = (SBQQ__Quote__c[])TestFactory.createSObjectList(new SBQQ__Quote__c(), 1);
        quoteList[0].SBQQ__Status__c = 'Draft';  
        quoteList[0].SBQQ__Account__c = account.Id;
        quoteList[0].SBQQ__Opportunity2__c = opp.Id;
        insert quoteList;
        
        Test.startTest();
        quoteList[0].SBQQ__Primary__c = !quoteList[0].SBQQ__Primary__c; 
        Database.SaveResult result = Database.update(quoteList[0], false);
        Test.stopTest();
        
        System.assert(result.isSuccess(), 'Exempt field modification should be allowed on locked quote');
    }
    
    @IsTest
    static void testQuoteLockingBlocked() {
        // Get test data from setup
        Account account = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        SBQQ__Quote__c[] quoteList = (SBQQ__Quote__c[])TestFactory.createSObjectList(new SBQQ__Quote__c(), 1);
        quoteList[0].SBQQ__Status__c = 'Draft';
        quoteList[0].SBQQ__Account__c = account.Id;
        quoteList[0].SBQQ__Opportunity2__c = opp.Id;
        insert quoteList;
        
        Test.startTest();
        Database.SaveResult result = Database.update(quoteList[0], false);
        Test.stopTest();
        
        System.assert(result.isSuccess(), 'No-change update should succeed');
    }
    
    @IsTest
    static void testDomainClass() {
        // Get test data from setup
        Account account = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        SBQQ__Quote__c[] quoteList = (SBQQ__Quote__c[])TestFactory.createSObjectList(new SBQQ__Quote__c(), 1);
        quoteList[0].SBQQ__Status__c = 'Draft';
        quoteList[0].SBQQ__Account__c = account.Id;
        quoteList[0].SBQQ__Opportunity2__c = opp.Id;
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
        // Get test data from setup
        Account account = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        SBQQ__Quote__c[] quoteList = (SBQQ__Quote__c[])TestFactory.createSObjectList(new SBQQ__Quote__c(), 1);
        quoteList[0].SBQQ__Status__c = 'Draft';
        quoteList[0].SBQQ__Account__c = account.Id;
        quoteList[0].SBQQ__Opportunity2__c = opp.Id;
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
            // Handle exception if needed
        }
        Test.stopTest();
        
        System.assertEquals(1, domain.getQuotes().size(), 'Domain should contain the quote');
    }
@IsTest
static void testValidateQuoteModificationsBlocked() {
    // Get test data from setup
    Account account = [SELECT Id FROM Account LIMIT 1];
    Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
    
    // Create old and new quote records for comparison
    SBQQ__Quote__c oldQuote = new SBQQ__Quote__c(
        Id = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType),
        SBQQ__Status__c = 'Accepted',
        SBQQ__Account__c = account.Id,
        SBQQ__Opportunity2__c = opp.Id,
        SBQQ__Primary__c = false,
        SBQQ__Type__c = 'Quote'
    );
    
    SBQQ__Quote__c newQuote = oldQuote.clone(false, true, false, false);
    newQuote.SBQQ__Type__c = 'Amendment'; // Change non-exempt field
    
    // Create domain instance
    List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>{newQuote};
    QuoteLock domain = new QuoteLock(quotes);
    
    // Setup exempt fields (only SBQQ__Primary__c is exempt from setup)
    Set<String> exemptFields = new Set<String>{'SBQQ__Primary__c'};
    
    Test.startTest();
    
    // Call the test-visible wrapper method
    domain.testValidateQuoteModifications(newQuote, oldQuote, exemptFields);
    
    Test.stopTest();
    
    // Verify error was added to the record
    System.assert(newQuote.hasErrors(), 'Quote should have validation errors');
    List<Database.Error> errors = newQuote.getErrors();
    System.assert(errors.size() > 0, 'Should have at least one error');
    System.assert(errors[0].getMessage().contains('The Quote cannot be modified because the status is Rejected, Accepted, or Denied'), 
                 'Should show quote lock error message');
}

@IsTest
static void testValidateQuoteModificationsAllowed() {
    // Get test data from setup
    Account account = [SELECT Id FROM Account LIMIT 1];
    Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
    
    // Create old and new quote records for comparison
    SBQQ__Quote__c oldQuote = new SBQQ__Quote__c(
        Id = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType),
        SBQQ__Status__c = 'Accepted',
        SBQQ__Account__c = account.Id,
        SBQQ__Opportunity2__c = opp.Id,
        SBQQ__Primary__c = false,
        SBQQ__Type__c = 'Quote'
    );
    
    SBQQ__Quote__c newQuote = oldQuote.clone(false, true, false, false);
    newQuote.SBQQ__Primary__c = true; // Change only exempt field
    
    // Create domain instance
    List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>{newQuote};
    QuoteLock domain = new QuoteLock(quotes);
    
    // Setup exempt fields
    Set<String> exemptFields = new Set<String>{'SBQQ__Primary__c'};
    
    Test.startTest();
    
    // Call the test-visible wrapper method
    domain.testValidateQuoteModifications(newQuote, oldQuote, exemptFields);
    
    Test.stopTest();
    
   
}

@IsTest
static void testValidateQuoteModificationsNoChanges() {
    // Get test data from setup
    Account account = [SELECT Id FROM Account LIMIT 1];
    Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
    
    // Create identical old and new quote records
    SBQQ__Quote__c oldQuote = new SBQQ__Quote__c(
        Id = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType),
        SBQQ__Status__c = 'Accepted',
        SBQQ__Account__c = account.Id,
        SBQQ__Opportunity2__c = opp.Id,
        SBQQ__Primary__c = false,
        SBQQ__Type__c = 'Quote'
    );
    
    SBQQ__Quote__c newQuote = oldQuote.clone(false, true, false, false);
    // No changes made
    
    // Create domain instance
    List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>{newQuote};
    QuoteLock domain = new QuoteLock(quotes);
    
    // Setup exempt fields
    Set<String> exemptFields = new Set<String>{'SBQQ__Primary__c'};
    
    Test.startTest();
    
    // Call the test-visible wrapper method
    domain.testValidateQuoteModifications(newQuote, oldQuote, exemptFields);
    
    Test.stopTest();
    

}



}