@isTest
public class QuoteLineEmailController_Test {	
    
    @isTest
    static void testQuoteLineEmailController() {
        // Create a test Account using TestFactory
        Account[] testAccountList = (Account[])TestFactory.createSObjectList(new Account(), 1);
        insert testAccountList;
        Account testAccount = testAccountList[0];
        
        // Create a test Opportunity using TestFactory
            Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity', 
            AccountId = testAccount.Id, 
            StageName = 'Prospecting', 
            CloseDate = Date.today().addDays(30),
            pklTypeOfOpportunity__c = 'LTA',
            pklLeadingSolutionField__c = 'DAP',
            pklTypeOfOffering__c = 'SW'
        );
        insert testOpportunity;
        
        // Create a test Quote using TestFactory
        SBQQ__Quote__c[] testQuoteList = (SBQQ__Quote__c[])TestFactory.createSObjectList(new SBQQ__Quote__c(), 1);
        testQuoteList[0].SBQQ__Opportunity2__c = testOpportunity.Id; // Set the Opportunity relationship
        insert testQuoteList;
        SBQQ__Quote__c testQuote = testQuoteList[0];
        
        // Create a test Product using TestFactory
        Product2[] testProductList = (Product2[])TestFactory.createSObjectList(new Product2(), 1);
        insert testProductList;
        Product2 testProduct = testProductList[0];
        
        // Create test QuoteLine records using TestFactory
        SBQQ__QuoteLine__c[] quoteLinesList = (SBQQ__QuoteLine__c[])TestFactory.createSObjectList(new SBQQ__QuoteLine__c(), 5);
        for (Integer i = 0; i < quoteLinesList.size(); i++) {
            quoteLinesList[i].SBQQ__Quote__c = testQuote.Id;
            quoteLinesList[i].SBQQ__Product__c = testProduct.Id;
            quoteLinesList[i].pkl_SolutionField__c = 'DEV';
            quoteLinesList[i].pkl_QuantityUnit__c = 'Month';
            quoteLinesList[i].pkl_INCOTerms1__c = 'DAP – Delivered at Place';
            quoteLinesList[i].txt_INCOTerms2__c = 'Inco Terms';
            quoteLinesList[i].pkl_PaymentTerms__c = 'Net 15';
        }
        insert quoteLinesList;
        
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
        //System.assertEquals(firstQuoteLine.SBQQ__Product__r.Name, 'Test Product', 'The Product name should match.');
        //System.assertEquals(firstQuoteLine.SBQQ__Quantity__c, 10, 'The quantity should match.');
        //System.assertEquals(firstQuoteLine.ftxt_ShortDescription__c, 'Description 0', 'The short description should match.');
    }
}