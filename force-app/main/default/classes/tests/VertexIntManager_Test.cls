/**
* @author       APB
* @description  CreditLimitWrapperManager_Test: Class used to create the vertex wrappers
*/
@isTest
public class VertexIntManager_Test {

    @testSetup
    static void initObjects(){
        Account[] testAccountList = (Account[])TestFactory.createSObjectList(new Account(), 1);
        testAccountList[0].CurrencyIsoCode = 'EUR';
        testAccountList[0].txt_AthenaUUID__c='123213123';
        testAccountList[0].BillingCountryCode= 'DE';
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

        List<VertexMethods.responseTaxes> listTaxes = new List<VertexMethods.responseTaxes>();

        VertexMethods.responseTaxes taxes= new VertexMethods.responseTaxes();
        taxes.id ='1';
        taxes.taxTypeCode ='1';
        taxes.taxRate = 2;
        taxes.taxableBaseAmount = 23;
        taxes.taxAmount =23;
        taxes.dueCategoryCode = '21';
        taxes.isTaxDeferred = false;
        taxes.deductibleTaxRate = 10;
        taxes.nonDeductibleTaxRate =30;
        taxes.deductibleTaxAmount = 10;
        taxes.nonDeductibleTaxAmount = 10;
        listTaxes.add(taxes);

        VertexMethods.itemAdditionalInformation additional = new VertexMethods.itemAdditionalInformation ();
        additional.totalTax ='10';
        additional.totalRate ='10';
        additional.taxAssist2 = 'a';
        additional.taxAssist3 = 'a';
        additional.taxAssist0 = 'a';
        additional.taxAssist1 = 'a';
        additional.taxAssist4 = 'a';
        additional.taxCode = 'a';
        additional.outFcode25 = 'a';

        List<VertexMethods.responseItem> items= new List<VertexMethods.responseItem> ();

        VertexMethods.responseItem item = new VertexMethods.responseItem();
        item.Id='1';
        item.countryRegionCode='DE';
        item.taxEventCode='de';
    	item.additionalInformation=additional;
        item.taxes= listTaxes;

        VertexMethods.wrapperResponse wrapper = (VertexMethods.wrapperResponse)JSON.deserialize('{"id":"723E4D234A111FD087EC4B69ED931D18","date":"2025-09-04T14:56:10.428Z","currencyCode":"EUR","amountTypeCode":"NET","items":[{"id":"000001","countryRegionCode":"DE","taxEventCode":"IGSTC","taxes":[{"taxTypeCode":"1","taxRate":19.00,"taxableBaseAmount":1.0,"taxAmount":0.19,"dueCategoryCode":"RECEIVABLE","isTaxDeferred":false,"deductibleTaxRate":100.0,"nonDeductibleTaxRate":0.0,"deductibleTaxAmount":0.19,"nonDeductibleTaxAmount":0.0,"additionalInformation":{"taxAssist0":"tax.taxCode&#124;POST&#124;&#124;IGSTC&#124;G_Set_Vertex_TaxDecisionCode_P","JurisdictionLevel":"COUNTRY","SellerRegistrationId":"XXX","Imposition":"VAT","JurisdictionName":"GERMANY","SitusCtry":"DE","RateClassification":"Standard Rate","ImpositionType":"VAT","DeductibleRate":"1.0","Level":"1","InvoiceTextCode":"&#124;21&#124;","BuyerRegistrationId":"DE811128135","Situs":"DE"}}],"additionalInformation":{"totalTax":"0.19","totalRate":"19.0000","taxAssist2":"buyer.department&#124;PRE&#124;&#124;5000&#124;G_Set Tax Payer Hierarchy_P","taxAssist3":"buyer.division&#124;PRE&#124;&#124;EMEA&#124;G_Set Tax Payer Hierarchy_P","taxAssist0":"FLEX.input.Error_Msg&#124;PRE&#124;&#124;UMTD&#124;G_Set_Default_Mapping_UMTD_P","taxAssist1":"buyer.company&#124;PRE&#124;5000&#124;GLOBAL SHELL&#124;G_Set Tax Payer Hierarchy_P","taxAssist4":"purchase.purchaseClass&#124;PRE&#124;&#124;null&#124;G_Set_Default_Mapping_UMTD_P","taxCode":"IGSTC","outFcode25":"UMTD"}}],"additionalInformation":{"partnerName":"Vertex"}}', VertexMethods.wrapperResponse.class);
        wrapper.auxId ='11';
        wrapper.actualDate= '2025-09-09';
        wrapper.currencyCode= 'EUR';
        wrapper.amountTypeCode='EUR';
        wrapper.items= items;
    }
    @isTest
	static void createQuoteVertexRequest() {
        User productManagerUser = (User)TestFactory.createSObject(new User(), 'TestFactoryDefaults.ProductManagerUserDefaults', true);
    	DateTime todayDateTime = DateTime.now();
    	SBQQ__Quote__c quoteTest = [SELECT Id,SBQQ__Status__c,Bill_To_Country__c,cur_Current_Credit_Limit_including_VAT__c,CurrencyIsoCode,SBQQ__Account__r.txt_AthenaUUID__c,SBQQ__Account__c from SBQQ__Quote__c LIMIT 1];
        quoteTest.SBQQ__Status__c='Accepted';
        update quoteTest;

    	Test.startTest();
    	System.runAs(productManagerUser){
            VertexMethods vertexRequest = VertexIntManager.createRequest(todayDateTime, quoteTest.Bill_To_Country__c);
            Assert.areNotEqual(null, vertexRequest,'Vertex request is not null');
        }
        Test.stopTest();
	}
    @isTest
	static void createOrderVertexRequest() {
        User productManagerUser = (User)TestFactory.createSObject(new User(), 'TestFactoryDefaults.ProductManagerUserDefaults', true);
        DateTime todayDateTime = DateTime.now();

    	Order orderTest = [SELECT Id,Status,cur_Current_Credit_Limit_including_VAT__c,CurrencyIsoCode,Account.txt_AthenaUUID__c,Account.BillingCountry from Order LIMIT 1];
        orderTest.cur_Current_Credit_Limit_including_VAT__c= 10;
        orderTest.Status= 'Activated';
        update orderTest;
        Test.startTest();
    	System.runAs(productManagerUser){
            VertexMethods vertexRequest = VertexIntManager.createRequest(todayDateTime, orderTest.Account.BillingCountry);
            Assert.areNotEqual(null, vertexRequest,'Vertex request is not null');
        }
        Test.stopTest();
	}
}