/**
* @author       APB
* @description  CreditLimitWrapperManager_Test: Class used to create the credit limit wrappers
*/
@isTest
public class CreditLimitWrapperManager_Test {

    @testSetup
    static void initObjects(){
        Account[] testAccountList = (Account[])TestFactory.createSObjectList(new Account(), 1);
        testAccountList[0].CurrencyIsoCode = 'EUR';
        testAccountList[0].txt_AthenaUUID__c='123213123';
        insert testAccountList;

        SBQQ__Quote__c[] quoteList = (SBQQ__Quote__c [])TestFactory.createSObjectList(new SBQQ__Quote__c(),1);
        quoteList[0].SBQQ__Status__c = 'Draft';
        quoteList[0].CurrencyIsoCode = 'EUR';
        quoteList[0].SBQQ__Account__r = testAccountList[0];
        insert quoteList;

        Order[] orderList = (Order [])TestFactory.createSObjectList(new Order(),1);
        orderList[0].Status= 'Draft';
        orderList[0].AccountId= testAccountList[0].Id;
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

        User user = (User)TestFactory.createSObject(new User(), 'TestFactoryDefaults.ProductManagerUserDefaults', true);
		insert user;
    }

    @isTest
	static void createAccountCreditLimitRequest() {
        User productManagerUser = [SELECT Id from User LIMIT 1];
    	Account testAccount = [SELECT Id,BillingCountry,CurrencyIsoCode from Account LIMIT 1];

    	Test.startTest();
    	System.runAs(productManagerUser){
            CreditLimitWrappers.AccountRequest creditLimitWrapper =CreditLimitWrapperManager.createAccountRequest('321323', testAccount.CurrencyIsoCode, testAccount.Id);
            Assert.areNotEqual(null, creditLimitWrapper,'Credit limit request is not null');
        }
        Test.stopTest();
	}

    @isTest
	static void createQuoteCreditLimitRequest() {
        User productManagerUser = [SELECT Id from User LIMIT 1];
    	SBQQ__Quote__c quoteTest = [SELECT Id,SBQQ__Status__c,Bill_To_Country__c,cur_Current_Credit_Limit_including_VAT__c,CurrencyIsoCode,SBQQ__Account__r.txt_AthenaUUID__c,SBQQ__Account__c from SBQQ__Quote__c LIMIT 1];
        quoteTest.cur_Current_Credit_Limit_including_VAT__c=10;
        quoteTest.SBQQ__Status__c='Accepted';
        update quoteTest;

    	Test.startTest();
    	System.runAs(productManagerUser){
            CreditLimitWrappers.CreditWorthinessQueryRequest creditLimitWrapper =CreditLimitWrapperManager.createCreditWorthinessRequest(quoteTest.cur_Current_Credit_Limit_including_VAT__c, quoteTest.CurrencyIsoCode, quoteTest.SBQQ__Account__c);
            Assert.areNotEqual(null, creditLimitWrapper,'Credit limit request is not null');
        }
        Test.stopTest();
	}

    @isTest
	static void createOrderCreditLimitRequest() {
        User productManagerUser = [SELECT Id from User LIMIT 1];
    	Order orderTest = [SELECT Id,Status,cur_Current_Credit_Limit_including_VAT__c,CurrencyIsoCode,Account.txt_AthenaUUID__c from Order LIMIT 1];
        orderTest.cur_Current_Credit_Limit_including_VAT__c= 10;
        orderTest.Status= 'Activated';
        update orderTest;
        Test.startTest();
    	System.runAs(productManagerUser){
            CreditLimitWrappers.CreditWorthinessQueryRequest creditLimitWrapper =CreditLimitWrapperManager.createCreditWorthinessRequest(orderTest.cur_Current_Credit_Limit_including_VAT__c, orderTest.CurrencyIsoCode, orderTest.AccountId);
            Assert.areNotEqual(null, creditLimitWrapper,'Credit limit request is not null');
        }
        Test.stopTest();
	}
}