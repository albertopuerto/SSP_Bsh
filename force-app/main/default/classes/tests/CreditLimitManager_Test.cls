/**
* @author       APB
* @description  CreditLimitManager_Test: Class used to get the credit limit from accounts, order and quotes called from the lwc
*/
@isTest
public class CreditLimitManager_Test {

    @testSetup
    static void initRecords(){

        Account[] testAccountList = (Account[])TestFactory.createSObjectList(new Account(), 1);
        testAccountList[0].CurrencyIsoCode = 'EUR';
        testAccountList[0].txt_AthenaUUID__c= '3123213';
        testAccountList[0].BillingCountry= 'DE';
        insert testAccountList;

        SBQQ__Quote__c[] quoteList = (SBQQ__Quote__c [])TestFactory.createSObjectList(new SBQQ__Quote__c(),1);
        quoteList[0].SBQQ__Status__c = 'Accepted';
        quoteList[0].CurrencyIsoCode = 'EUR';
        quoteList[0].SBQQ__Account__r = testAccountList[0];
        quoteList[0].lkp_BillToAccount__c= testAccountList[0].Id;
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
        
        orderList[0].cur_Current_Credit_Limit_including_VAT__c= 10;
        orderList[0].Status= 'Activated';
        update orderList;

        CreditLimitWrappers.BlockingReasonCodeDescription blockReasonDesc = new CreditLimitWrappers.BlockingReasonCodeDescription();
        blockReasonDesc.languageCode = 'EUR';

        CreditLimitWrappers.CreditSegmentDescription segmentDesc = new CreditLimitWrappers.CreditSegmentDescription();
        segmentDesc.languageCode = 'EUR';

        CreditLimitWrappers.accountCreditLimitAmount accLimitAmount = new CreditLimitWrappers.accountCreditLimitAmount();
        accLimitAmount.currencyCode = 'EUR';
        accLimitAmount.dollar='1232';

        CreditLimitWrappers.accountCreditLimitValidityPeriod validityPeriod = new CreditLimitWrappers.accountCreditLimitValidityPeriod();
        validityPeriod.startDate = '2025-09-09';
        validityPeriod.endDate = '2025-09-09';

        CreditLimitWrappers.accountCreditExposureAmount exposureAmount = new CreditLimitWrappers.accountCreditExposureAmount();
        exposureAmount.currencyCode = 'EUR';
        exposureAmount.dollar='1232';

        CreditLimitWrappers.accountCreditExposure accCreditExposure = new CreditLimitWrappers.accountCreditExposure();
        accCreditExposure.Percent = '232';
        accCreditExposure.DynamicCheckCreditHorizonEndDate='2025-09-09';
        accCreditExposure.Amount=exposureAmount;

        CreditLimitWrappers.CreditRiskDescription riskDescription = new CreditLimitWrappers.CreditRiskDescription();
        riskDescription.languageCode = 'EUR';
        riskDescription.dollar='1232';

        CreditLimitWrappers.CreditRiskValidityPeriod riskValidity = new CreditLimitWrappers.CreditRiskValidityPeriod();
        riskValidity.startDate = '2025-09-09';
        riskValidity.endDate = '2025-09-09';

        CreditLimitWrappers.CreditRiskClass creditRisk = new CreditLimitWrappers.CreditRiskClass();
        creditRisk.Description = riskDescription;
        creditRisk.Code='9907';
        creditRisk.ValidityPeriod=riskValidity;

        CreditLimitWrappers.CreditRatingValidityPeriod creditRatingValidity = new CreditLimitWrappers.CreditRatingValidityPeriod();
        creditRatingValidity.startDate = '2025-09-09';
        creditRatingValidity.endDate = '2025-09-09';

        CreditLimitWrappers.CreditRating creditRating = new CreditLimitWrappers.CreditRating();
        creditRating.Code = '2235245332';
        creditRating.ValidityPeriod=creditRatingValidity;

        CreditLimitWrappers.accountDebtorPartyInternalID accDebtorParty = new CreditLimitWrappers.accountDebtorPartyInternalID();
        accDebtorParty.schemeID = '232';
        accDebtorParty.schemeAgencyID='323535';
        accDebtorParty.dollar='323535';

        CreditLimitWrappers.CreditManagementAccount creditAccount = new CreditLimitWrappers.CreditManagementAccount();
        creditAccount.DebtorPartyInternalID = accDebtorParty;
        creditAccount.CreditsegmentInternalID = '142234';
        creditAccount.CreditSegmentDescription = segmentDesc;
        creditAccount.CreditWorthinessCheckingRuleCode = '254534';
        creditAccount.CreditWorthinessCheckingSchemeCode = '10';
        creditAccount.SpecialAttentionRequiredIndicator = '23';
        creditAccount.BlockedIndicator = '10';
        creditAccount.BlockingReasonCodeDescription = blockReasonDesc;
        creditAccount.CreditLimitAmount = accLimitAmount;
        creditAccount.CreditLimitValidityPeriod = validityPeriod;
        creditAccount.CreditExposure = accCreditExposure;
        creditAccount.CreditRating = creditRating;
        creditAccount.CreditRiskClass = creditRisk;
        CreditLimitWrappers.MessageHeader messageHeader = new CreditLimitWrappers.MessageHeader();
        messageHeader.Id = '232';
        messageHeader.CreationDateTime='323535';

        CreditLimitWrappers.CreditManagementAccountByIDResponse creditAccountResponse = new CreditLimitWrappers.CreditManagementAccountByIDResponse();
        creditAccountResponse.MessageHeader= messageHeader;

        CreditLimitWrappers.accountBody body = new CreditLimitWrappers.accountBody();
        body.CreditManagementAccountByIDResponse = creditAccountResponse;

        CreditLimitWrappers.accountEnvelope envelope = new CreditLimitWrappers.accountEnvelope();
        envelope.Body = body;
        envelope.Header='321';

        CreditLimitWrappers.accountWrapperResponse wrapper = new CreditLimitWrappers.accountWrapperResponse();
        wrapper.Envelope = envelope;

        CreditLimitWrappers.debtorPartyInternalID worthinessDebtorParty = new CreditLimitWrappers.debtorPartyInternalID();
        worthinessDebtorParty.schemeID = '232';
        worthinessDebtorParty.schemeAgencyID='323535';
        worthinessDebtorParty.dollar='323535';

        CreditLimitWrappers.DebtorPartyResponse worthinessDebtorResponse = new CreditLimitWrappers.DebtorPartyResponse();
        worthinessDebtorResponse.InternalID= worthinessDebtorParty;

        CreditLimitWrappers.creditLimitAmount creditAmount = new CreditLimitWrappers.creditLimitAmount();
        creditAmount.currencyCode = 'EUR';
        creditAmount.dollar='1232';

        CreditLimitWrappers.creditExposureAmount creditExposureAmount = new CreditLimitWrappers.creditExposureAmount();
        creditExposureAmount.currencyCode = 'EUR';
        creditExposureAmount.dollar='1232';

        CreditLimitWrappers.creditExposure creditExposure = new CreditLimitWrappers.creditExposure();
        creditExposure.Amount= creditExposureAmount;

        CreditLimitWrappers.RiskClassValidityPeriod worthRiskValidity = new CreditLimitWrappers.RiskClassValidityPeriod();
        worthRiskValidity.endDateTime = '2025-09-09';

        CreditLimitWrappers.RiskClass risk = new CreditLimitWrappers.RiskClass();
        risk.Code='9907';
        risk.ValidityPeriod=worthRiskValidity;

        CreditLimitWrappers.ratingValidityPeriod ratingValidity = new CreditLimitWrappers.ratingValidityPeriod();
        ratingValidity.endDateTime = '2025-09-09';

        CreditLimitWrappers.Rating rating = new CreditLimitWrappers.Rating();
        rating.Code = '2235245332';
        rating.ValidityPeriod=ratingValidity;

        CreditLimitWrappers.CreditWorthiness creditWorthiness = new CreditLimitWrappers.CreditWorthiness();
        creditWorthiness.CreditSegmentInternalID= '12426456';
        creditWorthiness.Indicator= 'i24329090';
     //   creditWorthiness.CheckingDescription= messageHeader;
        creditWorthiness.DebtorPartyBlockedIndicator= 'true';
        creditWorthiness.DebtorPartySpecialAttentionRequiredIndicator= 'true';
        creditWorthiness.DynamicCheckHorizonEndDate= 'true';
        creditWorthiness.DebtorParty= worthinessDebtorResponse;
        creditWorthiness.Rating= rating;
        creditWorthiness.RiskClass= risk;
       // creditWorthiness.creditLimit= creditLimit;
        creditWorthiness.CreditExposure= creditExposure;

        CreditLimitWrappers.CreditWorthinessResponse creditWorthinessResponse = new CreditLimitWrappers.CreditWorthinessResponse();
        creditWorthinessResponse.CreditWorthiness = creditWorthiness;

        CreditLimitWrappers.Body worthinessBody = new CreditLimitWrappers.Body();
        worthinessBody.CreditWorthinessResponse = creditWorthinessResponse ;

        CreditLimitWrappers.Envelope worthinessEnvelope = new CreditLimitWrappers.Envelope();
        worthinessEnvelope.Body = worthinessBody;
        worthinessEnvelope.Header='321';

        CreditLimitWrappers.wrapperResponse worthinessWrapper = new CreditLimitWrappers.wrapperResponse();
        worthinessWrapper.Envelope = worthinessEnvelope;

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
        VertexMethods.wrapperResponse vertexWrapper = (VertexMethods.wrapperResponse)JSON.deserialize('{"id":"723E4D234A111FD087EC4B69ED931D18","date":"2025-09-04T14:56:10.428Z","currencyCode":"EUR","amountTypeCode":"NET","items":[{"id":"000001","countryRegionCode":"DE","taxEventCode":"IGSTC","taxes":[{"taxTypeCode":"1","taxRate":19.00,"taxableBaseAmount":1.0,"taxAmount":0.19,"dueCategoryCode":"RECEIVABLE","isTaxDeferred":false,"deductibleTaxRate":100.0,"nonDeductibleTaxRate":0.0,"deductibleTaxAmount":0.19,"nonDeductibleTaxAmount":0.0,"additionalInformation":{"taxAssist0":"tax.taxCode&#124;POST&#124;&#124;IGSTC&#124;G_Set_Vertex_TaxDecisionCode_P","JurisdictionLevel":"COUNTRY","SellerRegistrationId":"XXX","Imposition":"VAT","JurisdictionName":"GERMANY","SitusCtry":"DE","RateClassification":"Standard Rate","ImpositionType":"VAT","DeductibleRate":"1.0","Level":"1","InvoiceTextCode":"&#124;21&#124;","BuyerRegistrationId":"DE811128135","Situs":"DE"}}],"additionalInformation":{"totalTax":"0.19","totalRate":"19.0000","taxAssist2":"buyer.department&#124;PRE&#124;&#124;5000&#124;G_Set Tax Payer Hierarchy_P","taxAssist3":"buyer.division&#124;PRE&#124;&#124;EMEA&#124;G_Set Tax Payer Hierarchy_P","taxAssist0":"FLEX.input.Error_Msg&#124;PRE&#124;&#124;UMTD&#124;G_Set_Default_Mapping_UMTD_P","taxAssist1":"buyer.company&#124;PRE&#124;5000&#124;GLOBAL SHELL&#124;G_Set Tax Payer Hierarchy_P","taxAssist4":"purchase.purchaseClass&#124;PRE&#124;&#124;null&#124;G_Set_Default_Mapping_UMTD_P","taxCode":"IGSTC","outFcode25":"UMTD"}}],"additionalInformation":{"partnerName":"Vertex"}}', VertexMethods.wrapperResponse.class);
        vertexWrapper.auxId ='11';
        vertexWrapper.actualDate= '2025-09-09';
        vertexWrapper.currencyCode= 'EUR';
        vertexWrapper.amountTypeCode='EUR';
        vertexWrapper.items= items;
    }

    @isTest
    public static void checkAccount(){

        User productManagerUser = createUser();
        Account testAccount = [SELECT Id,BillingCountry,CurrencyIsoCode,txt_AthenaUUID__c from Account LIMIT 1];
        Test.startTest();
        System.runAs(productManagerUser){
            Test.setMock(HttpCalloutMock.class, new CreditLimitMockClass());

    	    HttpResponse response = CreditLimitCallouts.startCreditLimitCallouts(null, null, testAccount);

    	    String contentType = response.getHeader('Content-Type');
    	    Assert.isTrue(contentType == 'application/json','The content type is of Content-Type');
    	    String actualValue = response.getBody();
    	    String expectedValue = '{"Envelope":{"Header":"","Body":{"CreditManagementAccountByIDResponse":{"MessageHeader":{"ID":"D6B2D2D3CE021FD0A399EAD2F9065196","CreationDateTime":"2025-09-08T16:17:38.739Z"},"CreditManagementAccount":{"DebtorPartyInternalID":{"@schemeID":"PartyID","@schemeAgencyID":"SAP0BHL011","$":"4001831001"},"CreditsegmentInternalID":"5370","CreditSegmentDescription":{"@languageCode":"de"},"CreditWorthinessCheckingRuleCode":"ZR","CreditWorthinessCheckingSchemeCode":"ZB","SpecialAttentionRequiredIndicator":"false","BlockedIndicator":"false","BlockingReasonCodeDescription":{"@languageCode":"de"},"CreditLimitAmount":{"@currencyCode":"EUR","$":"500000.0"},"CreditLimitValidityPeriod":{"StartDate":"2025-09-08","EndDate":"2026-09-30"},"CreditExposure":{"Amount":{"@currencyCode":"EUR","$":"0.0"},"DynamicCheckCreditHorizonEndDate":"2025-10-08"},"CreditRating":{"Code":"       93","ValidityPeriod":{"StartDate":"2025-06-13","EndDate":"2026-03-07"}},"CreditRiskClass":{"Code":"B","ValidityPeriod":{"StartDate":"2025-06-13","EndDate":"2026-03-07"},"Description":{"@languageCode":"de","$":"Geringes Ausfallrisiko"}},"PaymentBehaviourSummary":{"DaysOfSalesOutstandingAverageDuration":"0 "}}}}}}';
    	    Assert.areEqual(expectedValue, actualValue,'The response body is the expected value');
    	    Assert.areEqual(200, response.getStatusCode(), 'The status code is 200');
            CreditLimitManager.getObjectCurrency('Account',testAccount.Id);
            CreditLimitManager.getAccountFields(testAccount.Id);
            CreditLimitManager.callGetLimit('Account',testAccount.Id);
        }

        Test.stopTest();
    }

    @isTest
	static void checkQuote() {

    	User productManagerUser = createUser();
    	Test.startTest();
        System.runAs(productManagerUser){
            SBQQ__Quote__c quoteTest = [SELECT Id,SBQQ__Status__c,Bill_To_Country__c,cur_Current_Credit_Limit_including_VAT__c,CurrencyIsoCode,SBQQ__Account__r.txt_AthenaUUID__c from SBQQ__Quote__c LIMIT 1];
        	 
            StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = 'vertexSuccess'];
			String vertexBody = sr.Body.toString();
           	HttpCalloutMock res1 = new HTTPMockGenerator(200, vertexBody);
            
            StaticResource sr2 = [SELECT Body FROM StaticResource WHERE Name = 'creditLimitQuoteOrderExceded'];
			String creditLimitBody = sr2.Body.toString();
            HttpCalloutMock res2 = new HTTPMockGenerator(200, creditLimitBody);
            String remainingUrlVertex = '/sap-tax-service/tax/v1/quote';
            HttpMultiRequestMockGenerator multiMock = new HttpMultiRequestMockGenerator();
            multiMock.putMock('https://api.status.salesforce.com/v1/instances/DEU114S/status',new HTTPMockGenerator(200, '{"status":"OK"}'));
			multiMock.putMock('callout:vertex_usernamePass'+ remainingUrlVertex,res1);
			multiMock.putMock('callout:creditLimitCheckOuathCallout',res2);
        
            Test.setMock(HttpCalloutMock.class, multiMock);
    	    //HttpResponse response = CreditLimitCallouts.startCreditLimitCallouts(quoteTest, null, null);
            /*String contentType = response.getHeader('Content-Type');
    	    Assert.isTrue(contentType == 'application/json','The content type is of Content-Type');
    	    String actualValue = response.getBody();
    	    String expectedValue = '{"Envelope":{"Header":"","Body":{"CreditWorthinessResponse":{"CreditWorthiness":{"CreditSegmentInternalID":"5370","Indicator":"true","CheckingDescription":[{"@languageCode":"en","$":"Credit segment 5370 of partner 4001831001"},{"@languageCode":"EN","$":"ID: 510936342"}],"DebtorPartyBlockedIndicator":"false","DebtorPartySpecialAttentionRequiredIndicator":"false","DynamicCheckHorizonEndDate":"2025-10-04","DebtorParty":{"InternalID":{"@schemeID":"PartyID","@schemeAgencyID":"SAP0BHL011","$":"4001831001"}},"Rating":{"Code":"       93","ValidityPeriod":{"EndDateTime":"2026-03-03T00:00:00Z"}},"RiskClass":{"Code":"B","ValidityPeriod":{"EndDateTime":"2026-03-03T00:00:00Z"}},"CreditLimit":{"Amount":{"@currencyCode":"EUR","$":"500000.0"},"ValidityPeriod":{"EndDateTime":"2026-09-30T00:00:00Z"}},"CreditExposure":{"Amount":{"@currencyCode":"EUR","$":"0.0"}}}}}}}';
    	    Assert.areEqual(expectedValue, actualValue,'The response body is the expected value');
    	    Assert.areEqual(200, response.getStatusCode(), 'The status code is 200');*/
            CreditLimitManager.callGetLimit('SBQQ__Quote__c',quoteTest.Id);
        }
        Test.stopTest();
	}

        @isTest
	static void checkOrder() {

       User productManagerUser = createUser();
        Test.startTest();
        System.runAs(productManagerUser){
            Order orderTest = [SELECT Id,Status,cur_Current_Credit_Limit_including_VAT__c,CurrencyIsoCode,Account.txt_AthenaUUID__c from Order LIMIT 1];
            
          StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = 'vertexSuccess'];
			String vertexBody = sr.Body.toString();

           	HttpCalloutMock res1 = new HTTPMockGenerator(200, vertexBody);
            
            StaticResource sr2 = [SELECT Body FROM StaticResource WHERE Name = 'creditLimitQuoteOrderExceded'];
			String creditLimitBody = sr2.Body.toString();
       
            HttpCalloutMock res2 = new HTTPMockGenerator(200, creditLimitBody);
    
            String remainingUrlVertex = '/sap-tax-service/tax/v1/quote';
            HttpMultiRequestMockGenerator multiMock = new HttpMultiRequestMockGenerator();
            multiMock.putMock('https://api.status.salesforce.com/v1/instances/DEU114S/status',new HTTPMockGenerator(200, '{"status":"OK"}'));
			multiMock.putMock('callout:vertex_usernamePass'+ remainingUrlVertex,res1);
			multiMock.putMock('callout:creditLimitCheckOuathCallout',res2);
        
            Test.setMock(HttpCalloutMock.class, multiMock);
            CreditLimitManager.callGetLimit('Order',orderTest.Id);
           /* String actualValue = response.getBody();
    	    String expectedValue = '{"Envelope":{"Header":"","Body":{"CreditWorthinessResponse":{"CreditWorthiness":{"CreditSegmentInternalID":"5370","Indicator":"true","CheckingDescription":[{"@languageCode":"en","$":"Credit segment 5370 of partner 4001831001"},{"@languageCode":"EN","$":"ID: 510936342"}],"DebtorPartyBlockedIndicator":"false","DebtorPartySpecialAttentionRequiredIndicator":"false","DynamicCheckHorizonEndDate":"2025-10-04","DebtorParty":{"InternalID":{"@schemeID":"PartyID","@schemeAgencyID":"SAP0BHL011","$":"4001831001"}},"Rating":{"Code":"       93","ValidityPeriod":{"EndDateTime":"2026-03-03T00:00:00Z"}},"RiskClass":{"Code":"B","ValidityPeriod":{"EndDateTime":"2026-03-03T00:00:00Z"}},"CreditLimit":{"Amount":{"@currencyCode":"EUR","$":"500000.0"},"ValidityPeriod":{"EndDateTime":"2026-09-30T00:00:00Z"}},"CreditExposure":{"Amount":{"@currencyCode":"EUR","$":"0.0"}}}}}}}';
    	    Assert.areEqual(expectedValue, actualValue,'The response body is the expected value');
    	    Assert.areEqual(200, response.getStatusCode(), 'The status code is 200');*/
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