@IsTest
private class OrderItemHandler_test {
 
    @testSetup
    static void initRecords() {
        // Create base data
        Account[] testAccountList = (Account[])TestFactory.createSObjectList(new Account(), 1);
        insert testAccountList;
 
        // Get or create Standard Pricebook
        Id standardPricebookId = Test.getStandardPricebookId();
 
        // Create Product
        Product2[] productList = (Product2 [])TestFactory.createSObjectList(new Product2(),1);
        insert productList;
 
        // 2️⃣ Create custom Pricebook (optional)
        Pricebook2 pb = new Pricebook2(Name = 'Custom Pricebook', IsActive = true);
        insert pb;
 
        // 3️⃣ Create Pricebook entry for custom Pricebook
        PricebookEntry[] pricebookEntryList = (PricebookEntry [])TestFactory.createSObjectList(new PricebookEntry(),1);
  pricebookEntryList[0].Product2Id = productList[0].Id;
  insert pricebookEntryList;
 
        Order[] orderList = (Order [])TestFactory.createSObjectList(new Order(),1);
        orderList[0].Status= 'Draft';
        orderList[0].AccountId= testAccountList[0].Id;
        insert orderList;
 
    }
    
    @isTest
    public static void testPriceElementCreation_Success(){
        
        Order order = [SELECT Id from Order LIMIT 1];
        Product2 prod = [SELECT Id from Product2 LIMIT 1];
        PricebookEntry priceEntry = [SELECT Id from PricebookEntry LIMIT 1];
        Test.startTest();
        // 5️⃣ Create OrderItem → should trigger PriceElement creation
     OrderItem[] orderItemList = (OrderItem [])TestFactory.createSObjectList(new OrderItem(),1);
  orderItemList[0].OrderId= order.Id;
  orderItemList[0].Product2Id= prod.Id;
  orderItemList[0].PricebookEntryId= PriceEntry.Id;
  insert orderItemList;
        PriceElement__c pe = [SELECT Id, lkp_OrderItem__c FROM PriceElement__c WHERE lkp_OrderItem__c = :orderItemList[0].Id LIMIT 1];
        System.assertEquals(orderItemList[0].Id, pe.lkp_OrderItem__c, 'PriceElement should be linked to the OrderItem');
    Test.stopTest();
    } 
}