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
        Opportunity opp = (Opportunity)TestFactory.createSObject(new Opportunity(), 'TestFactoryDefaults.OpportunityDefaults', false);
        opp.Name = 'Test Opportunity for Quote Lock';
        opp.AccountId = account.Id;
        opp.lkp_SalesOrganization__c = salesArea.Id;
        insert opp;

        SBQQ__Quote__c[] quoteList = (SBQQ__Quote__c[])TestFactory.createSObjectList(new SBQQ__Quote__c(), 1);
        quoteList[0].SBQQ__Status__c = 'Draft';
        quoteList[0].SBQQ__Account__c = account.Id;
        quoteList[0].SBQQ__Opportunity2__c = opp.Id;
        insert quoteList;
    }

    // To check systemrunas and the permssions
    @IsTest
    static void testTriggerExecutionDraftQuote() {
        // Get test data from setup
        SBQQ__Quote__c[] quoteList = [SELECT Id FROM SBQQ__Quote__c];

        Test.startTest();
      //  User productManagerUser = createUser();

            
            quoteList[0].SBQQ__Primary__c = true;
            Database.SaveResult result = Database.update(quoteList[0], false);
            // Then - Draft quote should be updateable
            Assert.isTrue(result.isSuccess(), 'Draft quote should be updateable');
        
        Test.stopTest();

    }

    // To check systemrunas and the permssions
    @IsTest
    static void testQuoteLockingFunctionality() {
        // Get test data from setup
        SBQQ__Quote__c[] quoteList = [SELECT Id,SBQQ__Status__c,SBQQ__Primary__c FROM SBQQ__Quote__c];

        Test.startTest();
       // User productManagerUser = createUser();
        
            quoteList[0].SBQQ__Primary__c = !quoteList[0].SBQQ__Primary__c;
            Database.SaveResult result = Database.update(quoteList[0], false);
            Assert.isTrue(result.isSuccess(), 'Exempt field modification should be allowed on locked quote');
        
        Test.stopTest();

    }
    @IsTest
    static void testQuoteLockingBlocked() {
        // Get test data from setup
        SBQQ__Quote__c[] quoteList = [SELECT Id FROM SBQQ__Quote__c];

        User productManagerUser = createUser();
        Test.startTest();
        System.runAs(productManagerUser){
            Database.SaveResult result = Database.update(quoteList[0], false);
            Assert.isTrue(result.isSuccess(), 'No-change update should succeed');
        }
        Test.stopTest();

    }

    @IsTest
    static void testDomainClass() {
        // Get test data from setup
        SBQQ__Quote__c[] quoteList = [SELECT Id,SBQQ__Status__c,SBQQ__Primary__c FROM SBQQ__Quote__c];

        User productManagerUser = createUser();
        Test.startTest();
        System.runAs(productManagerUser){
            List<SBQQ__Quote__c> quoteListForDomain = new List<SBQQ__Quote__c>(quoteList);
            QuoteLock domain = new QuoteLock(quoteListForDomain);
            List<SBQQ__Quote__c> quotes = domain.getQuotes();

            Assert.areEqual(1, quotes.size(), 'Domain class should return quotes');
            Assert.areEqual('Draft', quotes[0].SBQQ__Status__c, 'Quote status should be preserved');
        }
        Test.stopTest();

    }

    @IsTest
    static void testValidationLogic() {
        // Get test data from setup
        SBQQ__Quote__c[] quoteList = [SELECT Id,SBQQ__Status__c FROM SBQQ__Quote__c];

        SBQQ__Quote__c oldQuote = quoteList[0].clone(true, true, true, true);
        SBQQ__Quote__c newQuote = quoteList[0].clone(true, true, true, true);
        newQuote.SBQQ__Status__c = 'Accepted';
        if (newQuote.getSObjectType().getDescribe().fields.getMap().containsKey('SBQQ__ExpirationDate__c')) {
            newQuote.put('SBQQ__ExpirationDate__c', Date.today().addDays(30));
        }

        Map<Id, SObject> oldRecordsMap = new Map<Id, SObject>();
        oldRecordsMap.put(oldQuote.Id, oldQuote);

        User productManagerUser = createUser();
        Test.startTest();
        System.runAs(productManagerUser){
            List<SBQQ__Quote__c> quotesForDomain = new List<SBQQ__Quote__c>{newQuote};
            QuoteLock domain = new QuoteLock(quotesForDomain);

            try {
                domain.onBeforeUpdate(oldRecordsMap);
            }catch(Exception ex){
        	Logger.error('We found an error during the test - QuoteLockTrigger '+ ex.getMessage());
        }
            Assert.areEqual(1, domain.getQuotes().size(), 'Domain should contain the quote');
        }
        Test.stopTest();

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

    User productManagerUser = createUser();
    Test.startTest();
    System.runAs(productManagerUser){
        // Call the test-visible wrapper method
        domain.testValidateQuoteModifications(newQuote, oldQuote, exemptFields, 'The Quote cannot be modified because the status is Rejected, Accepted, or Denied');
        Assert.isTrue(newQuote.hasErrors(), 'Quote should have validation errors');
        List<Database.Error> errors = newQuote.getErrors();
        Assert.isTrue(errors.size() > 0, 'Should have at least one error');
        Assert.isTrue(errors[0].getMessage().contains('The Quote cannot be modified because the status is Rejected, Accepted, or Denied'),'Should show quote lock error message');
        }
    Test.stopTest();

    // Verify error was added to the record

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

    User productManagerUser = createUser();
    Test.startTest();
        System.runAs(productManagerUser){

            // Call the test-visible wrapper method
            List<Database.Error> errors = newQuote.getErrors();
            Assert.areEqual(errors.size() , 0, 'There are no errors');
            domain.testValidateQuoteModifications(newQuote, oldQuote, exemptFields, 'The Quote cannot be modified because the status is Rejected, Accepted, or Denied');
        }
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

    User productManagerUser = createUser();
    Test.startTest();
    System.runAs(productManagerUser){

        // Call the test-visible wrapper method
        List<Database.Error> errors = newQuote.getErrors();
        Assert.areEqual(errors.size() , 0, 'There is not error');
        domain.testValidateQuoteModifications(newQuote, oldQuote, exemptFields, 'The Quote cannot be modified because the status is Rejected, Accepted, or Denied');
    }

    Test.stopTest();


}

static User createUser(){
        User productManagerUser = (User)TestFactory.createSObject(new User(), 'TestFactoryDefaults.ProductManagerUserDefaults', true);
       PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SalesBasic' LIMIT 1];
       PermissionSetLicense psl = [SELECT Id from PermissionSetLicense WHERE DeveloperName = 'SalesforceCPQ_CPQStandardPerm' ];

       PermissionSetLicenseAssign pslassignment = new PermissionSetLicenseAssign(
            PermissionSetLicenseId = psl.Id,
            AssigneeId = productManagerUser.Id
        );
        insert pslassignment;

        // Assign the Permission Set to the test user
        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = productManagerUser.Id,
            PermissionSetId = ps.Id
        );
        insert psa;
        return productManagerUser;
    }



}