@isTest
private class GroupLineItems_controllerTest {
    
    @testSetup
    static void setupTestData() {
        // Create test account
        Account testAccount = new Account(
            Name = 'Test Account',
            pkl_Language__c='English',
            pkm_BoschPartnerRole__c = 'BBCUEX'

        );
        insert testAccount;
        SalesArea__c sal = new SalesArea__c(
            pkl_DistributionChannel__c = 'A1',
            pkl_Division__c = '01',
            pkl_SalesOrg__c = 'DEM5'
        );
        insert sal;
        
        // Create test opportunity
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
        
        // Create test quote
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
            SBQQ__Account__c = testAccount.Id,
            SBQQ__Opportunity2__c = testOpportunity.Id,
            SBQQ__Status__c = 'Draft'
        );
        insert testQuote;
        
        // Create test quote groups
        SBQQ__QuoteLineGroup__c group1 = new SBQQ__QuoteLineGroup__c(
            Name = 'Group 1',
            SBQQ__Quote__c = testQuote.Id
        );
        
        SBQQ__QuoteLineGroup__c group2 = new SBQQ__QuoteLineGroup__c(
            Name = 'Group 2',
            SBQQ__Quote__c = testQuote.Id
        );
        
        insert new List<SBQQ__QuoteLineGroup__c>{group1, group2};
        
        // Create test products
        List<Product2> testProducts = new List<Product2>();
        for(Integer i = 1; i <= 4; i++) {
            testProducts.add(new Product2(
                Name = 'Test Product ' + i,
                ProductCode = 'TP-00' + i,
                IsActive = true
            ));
        }
        insert testProducts;
        
        // Create price book and entries
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        for(Product2 product : testProducts) {
            pricebookEntries.add(new PricebookEntry(
                Pricebook2Id = standardPricebook.Id,
                Product2Id = product.Id,
                UnitPrice = 100.00,
                IsActive = true
            ));
        }
        insert pricebookEntries;
        
        // Create quote lines
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        // Group 1 lines
        quoteLines.add(new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = testQuote.Id,
            SBQQ__Group__c = group1.Id,
            SBQQ__Product__c = testProducts[0].Id,
            SBQQ__Quantity__c = 2,
            SBQQ__NetPrice__c = 100.00
        ));
        quoteLines.add(new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = testQuote.Id,
            SBQQ__Group__c = group1.Id,
            SBQQ__Product__c = testProducts[1].Id,
            SBQQ__Quantity__c = 1,
            SBQQ__NetPrice__c = 100.00
        ));
        
        // Group 2 lines
        quoteLines.add(new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = testQuote.Id,
            SBQQ__Group__c = group2.Id,
            SBQQ__Product__c = testProducts[2].Id,
            SBQQ__Quantity__c = 3,
            SBQQ__NetPrice__c = 100.00
        ));
        quoteLines.add(new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = testQuote.Id,
            SBQQ__Group__c = group2.Id,
            SBQQ__Product__c = testProducts[3].Id,
            SBQQ__Quantity__c = 1,
            SBQQ__NetPrice__c = 100.00
        ));
        
        insert quoteLines;
        
        // Create test order
        Order testOrder = new Order(
            AccountId = testAccount.Id,
            OpportunityId = testOpportunity.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = standardPricebook.Id,
            pkl_PaymentTerms__c = 'Net 15',
            pkl_INCOTerms1__c='DAP',  
            txt_INCOTerms2__c = 'Inco Terms'
        );
        insert testOrder;
        
        // Create order items with reference to quote lines
        List<OrderItem> orderItems = new List<OrderItem>();
        for(Integer i = 0; i < quoteLines.size(); i++) {
            orderItems.add(new OrderItem(
                OrderId = testOrder.Id,
                PricebookEntryId = pricebookEntries[i].Id,
                Product2Id = testProducts[i].Id,
                SBQQ__QuoteLine__c = quoteLines[i].Id,
                Quantity = quoteLines[i].SBQQ__Quantity__c,
                UnitPrice = 100.00,
                pkl_PaymentTerms__c = 'Net 15',
                pkl_QuantityUnit__c = 'Each',
                pkl_INCOTerms1__c='DAP',  
                txt_INCOTerms2__c = 'Inco Terms'
            ));
        }
        insert orderItems;
    }
    
    @isTest
    static void testLoadOrderGroups() {
        // Get the test order
        Order testOrder = [SELECT Id FROM Order LIMIT 1];
        
        Test.startTest();
        List<AggregateResult> results = GroupLineItems_controller.loadOrderGroups(testOrder.Id);
        Test.stopTest();
        
        // Validate results
        System.assertEquals(2, results.size(), 'Should have 2 order groups');
        
        // Verify the total price and count for each group
        Map<String, Decimal> totalPriceByGroup = new Map<String, Decimal>();
        Map<String, Integer> countByGroup = new Map<String, Integer>();
        
        for(AggregateResult result : results) {
            String groupName = (String)result.get('Name');
            Decimal totalPrice = (Decimal)result.get('totalPrice');
            Integer count = (Integer)result.get('itemsGroup');
            
            totalPriceByGroup.put(groupName, totalPrice);
            countByGroup.put(groupName, count);
        }
        
        // Check if both groups are present with correct counts and totals
        System.assert(totalPriceByGroup.containsKey('Group 1'), 'Group 1 should be in results');
        System.assert(totalPriceByGroup.containsKey('Group 2'), 'Group 2 should be in results');
        
        System.assertEquals(300.00, totalPriceByGroup.get('Group 1'), 'Group 1 should have total price of 300');
        System.assertEquals(400.00, totalPriceByGroup.get('Group 2'), 'Group 2 should have total price of 400');
        
        System.assertEquals(2, countByGroup.get('Group 1'), 'Group 1 should have 2 items');
        System.assertEquals(2, countByGroup.get('Group 2'), 'Group 2 should have 2 items');
    }
    
    @isTest
    static void testLoadOrderItems() {
        // Get the ID of a test group
        SBQQ__QuoteLineGroup__c testGroup = [SELECT Id FROM SBQQ__QuoteLineGroup__c WHERE Name = 'Group 1' LIMIT 1];
        
        Test.startTest();
        List<OrderItem> items = GroupLineItems_controller.loadOrderItems(testGroup.Id);
        Test.stopTest();
        
        // Validate results
        System.assertEquals(2, items.size(), 'Should have 2 order items in Group 1');
        
        // Verify order item details
        for(OrderItem item : items) {
            System.assert(item.Product2.Name.startsWith('Test Product'), 'Product name should start with Test Product');
            System.assert(item.ftxt_ProductCode__c.startsWith('TP-00'), 'Product code should start with TP-00');
            System.assert(item.Quantity > 0, 'Quantity should be greater than 0');
            System.assert(item.TotalPrice > 0, 'Total price should be greater than 0');
        }
    }
    
    @isTest
    static void testWithNoData() {
        // Test with a non-existent ID to ensure proper handling of empty results
        String nonExistentId = '001000000000000AAA';
        
        Test.startTest();
        List<AggregateResult> groupResults = GroupLineItems_controller.loadOrderGroups(nonExistentId);
        List<OrderItem> itemResults = GroupLineItems_controller.loadOrderItems(nonExistentId);
        Test.stopTest();
        
        // Verify empty results
        System.assertEquals(0, groupResults.size(), 'Should have no order groups for non-existent ID');
        System.assertEquals(0, itemResults.size(), 'Should have no order items for non-existent ID');
    }
}