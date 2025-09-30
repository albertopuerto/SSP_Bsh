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
        testAccountList[0].BillingCountry= 'DE';
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
    		Test.setMock(HttpCalloutMock.class, new VertexMockClass());

    		HttpResponse response = CreditLimitCallouts.getVertexInformation(quoteTest, null);
    		// Verify that the response received contains fake values
    		String contentType = response.getHeader('Content-Type');
    		Assert.isTrue(contentType == 'application/json','The content type is of Content-Type');
    		String actualValue = response.getBody();
    		String expectedValue = '{"id":"723E4D234A111FD087EC4B69ED931D18","date":"2025-09-04T14:56:10.428Z","currencyCode":"EUR","amountTypeCode":"NET","items":[{"id":"000001","countryRegionCode":"DE","taxEventCode":"IGSTC","taxes":[{"taxTypeCode":"1","taxRate":19.00,"taxableBaseAmount":1.0,"taxAmount":0.19,"dueCategoryCode":"RECEIVABLE","isTaxDeferred":false,"deductibleTaxRate":100.0,"nonDeductibleTaxRate":0.0,"deductibleTaxAmount":0.19,"nonDeductibleTaxAmount":0.0,"additionalInformation":{"taxAssist0":"tax.taxCode&#124;POST&#124;&#124;IGSTC&#124;G_Set_Vertex_TaxDecisionCode_P","JurisdictionLevel":"COUNTRY","SellerRegistrationId":"XXX","Imposition":"VAT","JurisdictionName":"GERMANY","SitusCtry":"DE","RateClassification":"Standard Rate","ImpositionType":"VAT","DeductibleRate":"1.0","Level":"1","InvoiceTextCode":"&#124;21&#124;","BuyerRegistrationId":"DE811128135","Situs":"DE"}}],"additionalInformation":{"totalTax":"0.19","totalRate":"19.0000","taxAssist2":"buyer.department&#124;PRE&#124;&#124;5000&#124;G_Set Tax Payer Hierarchy_P","taxAssist3":"buyer.division&#124;PRE&#124;&#124;EMEA&#124;G_Set Tax Payer Hierarchy_P","taxAssist0":"FLEX.input.Error_Msg&#124;PRE&#124;&#124;UMTD&#124;G_Set_Default_Mapping_UMTD_P","taxAssist1":"buyer.company&#124;PRE&#124;5000&#124;GLOBAL SHELL&#124;G_Set Tax Payer Hierarchy_P","taxAssist4":"purchase.purchaseClass&#124;PRE&#124;&#124;null&#124;G_Set_Default_Mapping_UMTD_P","taxCode":"IGSTC","outFcode25":"UMTD"}}],"additionalInformation":{"partnerName":"Vertex"}}';
			Assert.areEqual(expectedValue, actualValue,'The response body is the expected value');
    		Assert.areEqual(200, response.getStatusCode(), 'The status code is 200');
		}
        Test.stopTest();
	}

    @isTest
	static void testCreditLimitCalloutAccount() {

		User productManagerUser = (User)TestFactory.createSObject(new User(), 'TestFactoryDefaults.ProductManagerUserDefaults', true);
		Account testAccount = [SELECT Id,BillingCountry,txt_AthenaUUID__c from Account LIMIT 1];

    	Test.startTest();
		System.runAs(productManagerUser){
        	Test.setMock(HttpCalloutMock.class, new CreditLimitMockClass());

    		HttpResponse response = CreditLimitCallouts.startCreditLimitCallouts(null, null, testAccount);

    		// Verify that the response received contains fake values
    		String contentType = response.getHeader('Content-Type');
    		Assert.isTrue(contentType == 'application/json','The content type is of Content-Type');
    		String actualValue = response.getBody();
    		String expectedValue = '{"CreditManagementAccountByIDResponse":{"MessageHeader":{"ID":"D6B2D2D3CE021FD0A2B358C6DE278E94","CreationDateTime":"2025-09-04T14:23:49.194Z"}';
    		Assert.areEqual(expectedValue, actualValue,'The response body is the expected value');
			Assert.areEqual(200, response.getStatusCode(), 'The status code is 200');
        	Test.stopTest();
		}
	}

    @isTest
	static void testCreditLimitCalloutQuote() {

		User productManagerUser = (User)TestFactory.createSObject(new User(), 'TestFactoryDefaults.ProductManagerUserDefaults', true);

        SBQQ__Quote__c quoteTest = [SELECT Id,SBQQ__Status__c,Bill_To_Country__c,cur_Current_Credit_Limit_including_VAT__c,CurrencyIsoCode,SBQQ__Account__r.txt_AthenaUUID__c from SBQQ__Quote__c LIMIT 1];
        quoteTest.SBQQ__Status__c='Accepted';
        update quoteTest;
    	Test.startTest();
		System.runAs(productManagerUser){
        	Test.setMock(HttpCalloutMock.class, new CreditLimitWorthinessMock());

    		HttpResponse response = CreditLimitCallouts.startCreditLimitCallouts(quoteTest, null, null);

    		String contentType = response.getHeader('Content-Type');
    		Assert.isTrue(contentType == 'application/json','The content type is of Content-Type');
    		String actualValue = response.getBody();

    		String expectedValue = '{"Envelope":{"Header":"","Body":{"CreditWorthinessResponse":{"CreditWorthiness":{"CreditSegmentInternalID":"5370","Indicator":"true","CheckingDescription":[{"@languageCode":"en","$":"Credit segment 5370 of partner 4001831001"},{"@languageCode":"EN","$":"ID: 510936342"}],"DebtorPartyBlockedIndicator":"false","DebtorPartySpecialAttentionRequiredIndicator":"false","DynamicCheckHorizonEndDate":"2025-10-04","DebtorParty":{"InternalID":{"@schemeID":"PartyID","@schemeAgencyID":"SAP0BHL011","$":"4001831001"}},"Rating":{"Code":"       93","ValidityPeriod":{"EndDateTime":"2026-03-03T00:00:00Z"}},"RiskClass":{"Code":"B","ValidityPeriod":{"EndDateTime":"2026-03-03T00:00:00Z"}},"CreditLimit":{"Amount":{"@currencyCode":"EUR","$":"500000.0"},"ValidityPeriod":{"EndDateTime":"2026-09-30T00:00:00Z"}},"CreditExposure":{"Amount":{"@currencyCode":"EUR","$":"0.0"}}}}}}}';
    		Assert.areEqual(expectedValue, actualValue,'The response body is the expected value');
    		Assert.areEqual(200, response.getStatusCode(), 'The status code is 200');
        	Test.stopTest();
		}
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
        	Test.setMock(HttpCalloutMock.class, new CreditLimitWorthinessMock());
    		HttpResponse response = CreditLimitCallouts.startCreditLimitCallouts(null, orderTest, null);

    		String contentType = response.getHeader('Content-Type');
    		Assert.isTrue(contentType == 'application/json','The content type is of Content-Type');
    		String actualValue = response.getBody();
    		String expectedValue = '{"Envelope":{"Header":"","Body":{"CreditWorthinessResponse":{"CreditWorthiness":{"CreditSegmentInternalID":"5370","Indicator":"true","CheckingDescription":[{"@languageCode":"en","$":"Credit segment 5370 of partner 4001831001"},{"@languageCode":"EN","$":"ID: 510936342"}],"DebtorPartyBlockedIndicator":"false","DebtorPartySpecialAttentionRequiredIndicator":"false","DynamicCheckHorizonEndDate":"2025-10-04","DebtorParty":{"InternalID":{"@schemeID":"PartyID","@schemeAgencyID":"SAP0BHL011","$":"4001831001"}},"Rating":{"Code":"       93","ValidityPeriod":{"EndDateTime":"2026-03-03T00:00:00Z"}},"RiskClass":{"Code":"B","ValidityPeriod":{"EndDateTime":"2026-03-03T00:00:00Z"}},"CreditLimit":{"Amount":{"@currencyCode":"EUR","$":"500000.0"},"ValidityPeriod":{"EndDateTime":"2026-09-30T00:00:00Z"}},"CreditExposure":{"Amount":{"@currencyCode":"EUR","$":"0.0"}}}}}}}';
    		Assert.areEqual(expectedValue, actualValue,'The response body is the expected value');
    		Assert.areEqual(200, response.getStatusCode(), 'The status code is 200');
        Test.stopTest();
		}
	}
}