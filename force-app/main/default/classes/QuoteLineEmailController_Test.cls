@isTest
public class QuoteLineEmailController_Test {    
    
    @isTest
    static void testQuoteLineEmailController() {
        // Create a test Account
        Account testAccount = new Account(
            Name = 'Test Account',
            pkm_BoschPartnerRole__c='BBCUEX',
            pkl_Language__c='English'
        );
        insert testAccount;
        
        SalesArea__c sal = new SalesArea__c(
            pkl_DistributionChannel__c = 'A1',
            pkl_Division__c = '01',
            pkl_SalesOrg__c = 'DEM5'
        );
        insert sal;

        // Create a test Opportunity associated with the Account
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity', 
            AccountId = testAccount.Id, 
            StageName = 'Prospecting', 
            CloseDate = Date.today().addDays(30),
            pklTypeOfOpportunity__c = 'LTA',
            pklLeadingSolutionField__c = 'DAP',
            pklTypeOfOffering__c = 'SW',
            lkp_SalesOrganization__c = sal.Id
        );
        insert testOpportunity;

        // Create a test Quote associated with the Opportunity
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(SBQQ__Opportunity2__c = testOpportunity.Id);
        insert testQuote;
        
        Product2 prod = new Product2(Name = 'test Product');
        insert prod;

        // Create test QuoteLine records associated with the Quote
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        for (Integer i = 0; i < 5; i++) {
            quoteLines.add(new SBQQ__QuoteLine__c(
                SBQQ__Quote__c = testQuote.Id,
                SBQQ__Product__c = prod.Id,
                SBQQ__Quantity__c = 10,
                pkl_SolutionField__c = 'DEV',
                SBQQ__ListPrice__c = 100.0,
                pkl_QuantityUnit__c = 'Each',
                pkl_INCOTerms1__c='DAP – Delivered at Place',  
                txt_INCOTerms2__c = 'Inco Terms',
                pkl_PaymentTerms__c = 'Net 15'
            ));
        }
        insert quoteLines;

        // Initialize the QuoteLineEmailController with the quote ID
        QuoteLineEmailController controller = new QuoteLineEmailController();
        controller.quoteIdParam = testQuote.Id;

        // Test that the quoteLineItems are populated correctly
        List<SBQQ__QuoteLine__c> resultQuoteLines = controller.quoteLineItems;

        // Assert that the quoteLineItems list is not empty
        System.assertNotEquals(resultQuoteLines.size(), 0, 'QuoteLineItems should not be empty.');

        // Assert that the number of quote lines returned matches what was inserted
        System.assertEquals(resultQuoteLines.size(), 5, 'The number of QuoteLineItems should be 5.');

        // You can also assert that the expected field values are correct
        SBQQ__QuoteLine__c firstQuoteLine = resultQuoteLines[0];
        System.assertEquals(firstQuoteLine.SBQQ__Product__r.Name, 'test Product', 'The Product name should match.');
        //System.assertEquals(firstQuoteLine.SBQQ__Quantity__c, 10, 'The quantity should match.');
        //System.assertEquals(firstQuoteLine.ftxt_ShortDescription__c, 'Description 0', 'The short description should match.');
    }
}