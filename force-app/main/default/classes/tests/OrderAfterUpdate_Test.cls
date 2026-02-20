/**
* @author       APB
* @description  OrderAfterUpdate_Test: Class used to test the flow propagate main contact before update
*/
@isTest
public class OrderAfterUpdate_Test {

    /**
    * @author       APB
    * @description  Method used to create the records
    */
    @testSetup
    public static void createRecords(){

        Account[] testAccountList = (Account[])TestFactory.createSObjectList(new Account(), 1);
        testAccountList[0].CurrencyIsoCode = 'EUR';
        testAccountList[0].txt_AthenaUUID__c= '3123213';
        testAccountList[0].BillingCountryCode= 'DE';
        insert testAccountList;

        User productManagerUser = (User)TestFactory.createSObject(new User(), 'TestFactoryDefaults.ProductManagerUserDefaults', false);
        productManagerUser.Email= 'tes238091893t@email.invalid';
        insert productManagerUser;
        Order[] orderList = (Order [])TestFactory.createSObjectList(new Order(),1);
        orderList[0].Status= 'Draft';
        orderList[0].AccountId= testAccountList[0].Id;
        orderList[0].OwnerId = productManagerUser.Id;
        insert orderList;

        Product2[] productList = (Product2 [])TestFactory.createSObjectList(new Product2(),1);
        insert productList;

		PricebookEntry[] pricebookEntryList = (PricebookEntry [])TestFactory.createSObjectList(new PricebookEntry(),1);
		pricebookEntryList[0].Product2Id = productList[0].Id;
		insert pricebookEntryList;

        OrderItem[] orderItemList = (OrderItem [])TestFactory.createSObjectList(new OrderItem(),1);
		orderItemList[0].OrderId= orderList[0].Id;
		orderItemList[0].Product2Id= productList[0].Id;
		orderItemList[0].PricebookEntryId= pricebookEntryList[0].Id;
		insert orderItemList;
    }

    @IsTest
    public static void succesfulSendOfTheEmail(){
        User productManagerUser = (User)TestFactory.createSObject(new User(), 'TestFactoryDefaults.ProductManagerUserDefaults', true);
        System.runAs(productManagerUser){

            Order orderTest = [SELECT Id,Status,cur_Current_Credit_Limit_including_VAT__c,CurrencyIsoCode,Account.txt_AthenaUUID__c from Order LIMIT 1];

            orderTest.Status= 'OrderReceivedBySAP';
            update orderTest;

            Order updatedOrder = [SELECT Status FROM Order WHERE Id = :orderTest.Id];

            Assert.areEqual('OrderReceivedBySAP', updatedOrder.Status, 'Status should be Order Received by SAP');
        }
    }

}