/**
* @author       APB
* @description  CreditLimitCallouts_Test: Class used to test the vertex and credit limit callouts
*/
@isTest
public class CreditLimitCallouts_Test {

    @testSetup
    static void initObjects(){
        Account[] testAccountList = (Account[])TestFactory.createSObjectList(new Account(), 1);
        testAccountList[0].CurrencyIsoCode = 'EUR';
        testAccountList[0].txt_AthenaUUID__c='123213123';
<<<<<<< gs-pipeline/feature/BSSP-17864-modificationOfValidationRuleInApex_-_uat
        testAccountList[0].BillingCountry= 'Germany';
=======
        testAccountList[0].BillingCountryCode= 'DE';
>>>>>>> uat
        insert testAccountList;

        SBQQ__Quote__c[] quoteList = (SBQQ__Quote__c [])TestFactory.createSObjectList(new SBQQ__Quote__c(),1);
        quoteList[0].SBQQ__Status__c = 'Draft';
        quoteList[0].CurrencyIsoCode = 'EUR';
        quoteList[0].SBQQ__Account__r = testAccountList[0];
        quoteList[0].cur_Current_Credit_Limit_including_VAT__c = 10;
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

    }

    @isTest
	static void testVertexCallout() {

		User productManagerUser = (User)TestFactory.createSObject(new User(), 'TestFactoryDefaults.ProductManagerUserDefaults', true);

        SBQQ__Quote__c quoteTest = [SELECT Id,SBQQ__Status__c,Bill_To_Country__c,SBQQ__Account__r.BillingCountry,SBQQ__Account__r.txt_AthenaUUID__c from SBQQ__Quote__c LIMIT 1];
        quoteTest.SBQQ__Status__c='Accepted';
        update quoteTest;

        Test.startTest();
		System.runAs(productManagerUser){
        	StaticResource sr2 = [SELECT Body FROM StaticResource WHERE Name = 'vertexSuccess'];
			String vertexBody = sr2.Body.toString();

            HTTPMockGenerator res2 = new HTTPMockGenerator(200, vertexBody);

            Test.setMock(HttpCalloutMock.class, res2);

    	    Assert.isTrue(res2.responseHeaders.get('Content-Type') == 'application/json','The content type is of Content-Type');

    	    Assert.areEqual(200, res2.code, 'The status code is 200');
		}
		Test.stopTest();
	}

    @isTest
	static void testCreditLimitCalloutAccount() {

		User productManagerUser = (User)TestFactory.createSObject(new User(), 'TestFactoryDefaults.ProductManagerUserDefaults', true);
		Account testAccount = [SELECT Id,BillingCountry,txt_AthenaUUID__c from Account LIMIT 1];

    	Test.startTest();
		System.runAs(productManagerUser){
            StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = 'creditLimitAccountGreater0'];
			String creditLimitBody = sr.Body.toString();
            HTTPMockGenerator res1 = new HTTPMockGenerator(200, creditLimitBody);

            Test.setMock(HttpCalloutMock.class, res1);
    	    Assert.isTrue(res1.responseHeaders.get('Content-Type') == 'application/json','The content type is of Content-Type');

    	    Assert.areEqual(200, res1.code, 'The status code is 200');
            CreditLimitManager.getObjectCurrency('Account',testAccount.Id);
            CreditLimitManager.getAccountFields(testAccount.Id);
            CreditLimitManager.callGetLimit('Account',testAccount.Id);
        }
		Test.stopTest();
	}

    @isTest
	static void testCreditLimitCalloutQuote() {

		User productManagerUser = (User)TestFactory.createSObject(new User(), 'TestFactoryDefaults.ProductManagerUserDefaults', true);

        SBQQ__Quote__c quoteTest = [SELECT Id,SBQQ__Status__c,Bill_To_Country__c,cur_Current_Credit_Limit_including_VAT__c,CurrencyIsoCode,SBQQ__Account__r.txt_AthenaUUID__c from SBQQ__Quote__c LIMIT 1];
        quoteTest.SBQQ__Status__c='Accepted';
        update quoteTest;
    	Test.startTest();
		System.runAs(productManagerUser){
        	StaticResource sr2 = [SELECT Body FROM StaticResource WHERE Name = 'creditLimitQuoteOrderExceded'];
			String creditLimitBody = sr2.Body.toString();

            HTTPMockGenerator res2 = new HTTPMockGenerator(200, creditLimitBody);

            Test.setMock(HttpCalloutMock.class, res2);

    	    Assert.isTrue(res2.responseHeaders.get('Content-Type') == 'application/json','The content type is of Content-Type');

    	    Assert.areEqual(200, res2.code, 'The status code is 200');
		}
		Test.stopTest();
	}

    @isTest
	static void testCreditLimitCalloutOrder() {

		User productManagerUser = (User)TestFactory.createSObject(new User(), 'TestFactoryDefaults.ProductManagerUserDefaults', true);
        Order orderTest = [SELECT Id,Status,cur_Current_Credit_Limit_including_VAT__c,CurrencyIsoCode,Account.txt_AthenaUUID__c from Order LIMIT 1];
        orderTest.cur_Current_Credit_Limit_including_VAT__c= 10;
        orderTest.Status= 'Activated';
        update orderTest;

    	Test.startTest();
		System.runAs(productManagerUser){
        	StaticResource sr2 = [SELECT Body FROM StaticResource WHERE Name = 'creditLimitQuoteOrderExceded'];
			String creditLimitBody = sr2.Body.toString();

            HTTPMockGenerator res2 = new HTTPMockGenerator(200, creditLimitBody);

            Test.setMock(HttpCalloutMock.class, res2);

    	    Assert.isTrue(res2.responseHeaders.get('Content-Type') == 'application/json','The content type is of Content-Type');

    	    Assert.areEqual(200, res2.code, 'The status code is 200');
		}
		Test.stopTest();
	}
}