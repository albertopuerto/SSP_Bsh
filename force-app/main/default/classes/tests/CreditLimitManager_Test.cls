@isTest
public class CreditLimitManager_Test {
    @testSetup
    public static void initRecords(){
        
        Account[] testAccountList = (Account[])TestFactory.createSObjectList(new Account(), 1);
        testAccountList[0].CurrencyIsoCode = 'EUR';
        testAccountList[0].txt_AthenaUUID__c= '3123213';
        testAccountList[0].BillingCountry= 'DE';
        insert testAccountList;
        
        SBQQ__Quote__c[] quoteList = (SBQQ__Quote__c [])TestFactory.createSObjectList(new SBQQ__Quote__c(),1);
        quoteList[0].SBQQ__Status__c = 'Draft';
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
        
        List<VertexMethods.ResponseTaxes> listTaxes = new List<VertexMethods.ResponseTaxes>();
        
        VertexMethods.ResponseTaxes taxes= new VertexMethods.ResponseTaxes();
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
       // taxes.taxAdditionalInformation additionalInformation 
        listTaxes.add(taxes);
        
        VertexMethods.ItemAdditionalInformation additional = new VertexMethods.ItemAdditionalInformation ();
        additional.totalTax ='10';
        additional.totalRate ='10';
        additional.taxAssist2 = 'a';
        additional.taxAssist3 = 'a';
        additional.taxAssist0 = 'a';
        additional.taxAssist1 = 'a';
        additional.taxAssist4 = 'a';
        additional.taxCode = 'a';
        additional.outFcode25 = 'a';
        
        CreditLimitWrappers.BlockingReasonCodeDescription blockReasonDesc = new CreditLimitWrappers.BlockingReasonCodeDescription();
        blockReasonDesc.languageCode = 'EUR';
        
        CreditLimitWrappers.CreditSegmentDescription segmentDesc = new CreditLimitWrappers.CreditSegmentDescription();
        segmentDesc.languageCode = 'EUR';
        
        CreditLimitWrappers.AccountCreditLimitAmount accLimitAmount = new CreditLimitWrappers.AccountCreditLimitAmount();
        accLimitAmount.currencyCode = 'EUR';
        accLimitAmount.dollar='1232';
        
        CreditLimitWrappers.AccountCreditLimitValidityPeriod validityPeriod = new CreditLimitWrappers.AccountCreditLimitValidityPeriod();
        validityPeriod.startDate = '2025-09-09';
        validityPeriod.endDate = '2025-09-09';
        
        CreditLimitWrappers.AccountCreditExposureAmount exposureAmount = new CreditLimitWrappers.AccountCreditExposureAmount();
        exposureAmount.currencyCode = 'EUR';
        exposureAmount.dollar='1232';
        
        CreditLimitWrappers.AccountCreditExposure accCreditExposure = new CreditLimitWrappers.AccountCreditExposure();
        accCreditExposure.percent = '232';
        accCreditExposure.dynamicCheckCreditHorizonEndDate='2025-09-09';
        accCreditExposure.amount=exposureAmount;
        
        CreditLimitWrappers.CreditRiskDescription riskDescription = new CreditLimitWrappers.CreditRiskDescription();
        riskDescription.languageCode = 'EUR';
        riskDescription.dollar='1232';
        
        CreditLimitWrappers.CreditRiskValidityPeriod riskValidity = new CreditLimitWrappers.CreditRiskValidityPeriod();
        riskValidity.startDate = '2025-09-09';
        riskValidity.endDate = '2025-09-09';
        
        CreditLimitWrappers.CreditRiskClass creditRisk = new CreditLimitWrappers.CreditRiskClass();
        creditRisk.description = riskDescription;
        creditRisk.code='9907';
        creditRisk.validityPeriod=riskValidity;
              
        CreditLimitWrappers.CreditRatingValidityPeriod creditRatingValidity = new CreditLimitWrappers.CreditRatingValidityPeriod();
        creditRatingValidity.startDate = '2025-09-09';
        creditRatingValidity.endDate = '2025-09-09';
        
        CreditLimitWrappers.CreditRating creditRating = new CreditLimitWrappers.CreditRating();
        creditRating.code = '2235245332';
        creditRating.validityPeriod=creditRatingValidity;
        
       
        CreditLimitWrappers.accountDebtorPartyInternalID accDebtorParty = new CreditLimitWrappers.accountDebtorPartyInternalID();
        accDebtorParty.schemeID = '232';
        accDebtorParty.schemeAgencyID='323535';
        accDebtorParty.dollar='323535';

    
   		CreditLimitWrappers.CreditManagementAccount creditAccount = new CreditLimitWrappers.CreditManagementAccount();
        creditAccount.debtorPartyInternalID = accDebtorParty;
        creditAccount.creditsegmentInternalID = '142234';
        creditAccount.creditSegmentDescription = segmentDesc;
        creditAccount.creditWorthinessCheckingRuleCode = '254534';
        creditAccount.creditWorthinessCheckingSchemeCode = '10';
        creditAccount.specialAttentionRequiredIndicator = '23';
        creditAccount.blockedIndicator = '10';
        creditAccount.blockingReasonCodeDescription = blockReasonDesc;
        creditAccount.creditLimitAmount = accLimitAmount;
        creditAccount.creditLimitValidityPeriod = validityPeriod;
        creditAccount.creditExposure = accCreditExposure;
        creditAccount.creditRating = creditRating;
        creditAccount.creditRiskClass = creditRisk;
      //  creditAccount.PaymentBehaviourSummary = '';
     //   creditAccount.CommitmentTotal = '';
        
        CreditLimitWrappers.MessageHeader messageHeader = new CreditLimitWrappers.MessageHeader();
        messageHeader.id = '232';
        messageHeader.creationDateTime='323535';
       
        CreditLimitWrappers.CreditManagementAccountByIDResponse creditAccountResponse = new CreditLimitWrappers.CreditManagementAccountByIDResponse();
        creditAccountResponse.messageHeader= messageHeader;
        
        CreditLimitWrappers.AccountBody body = new CreditLimitWrappers.AccountBody();
      
        body.creditManagementAccountByIDResponse = creditAccountResponse;
     
        CreditLimitWrappers.AccountEnvelope envelope = new CreditLimitWrappers.AccountEnvelope();
        envelope.body = body;
        envelope.header='321';
        
        CreditLimitWrappers.AccountWrapperResponse wrapper = new CreditLimitWrappers.AccountWrapperResponse();
      
        wrapper.envelope = envelope;
        
     
        
        
        
        
        
        
        CreditLimitWrappers.DebtorPartyInternalID worthinessDebtorParty = new CreditLimitWrappers.DebtorPartyInternalID();
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
              
        CreditLimitWrappers.RatingValidityPeriod ratingValidity = new CreditLimitWrappers.RatingValidityPeriod();
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
    }
    

    @isTest
    public static void checkAccount(){
        
        Account testAccount = [SELECT Id,BillingCountry,CurrencyIsoCode,txt_AthenaUUID__c from Account LIMIT 1];
        
        Test.startTest();
        CreditLimitManager.checkAthenaId(testAccount.Id);
        Test.setMock(HttpCalloutMock.class, new CreditLimitMockClass());
    	
    	HttpResponse response = CreditLimitCallouts.startCreditLimitCallouts(true, false, false,'1111', null, null, testAccount);
    	
    	String contentType = response.getHeader('Content-Type');
    	Assert.isTrue(contentType == 'application/json');
    	String actualValue = response.getBody();
    	System.debug(response.getBody());
    	String expectedValue = '{"CreditManagementAccountByIDResponse":{"MessageHeader":{"ID":"D6B2D2D3CE021FD0A2B358C6DE278E94","CreationDateTime":"2025-09-04T14:23:49.194Z"}';
    	//Assert.areEqual(expectedValue, actualValue);
    	Assert.areEqual(200, response.getStatusCode());
        CreditLimitManager.getObjectCurrency(true,testAccount.Id);
        CreditLimitManager.callGetLimit(true,false,false,testAccount.Id);

              Test.stopTest();
    }
   
     @isTest
	static void checkQuote() {
        
    	
        SBQQ__Quote__c quoteTest = [SELECT Id,SBQQ__Status__c,Bill_To_Country__c,cur_Current_Credit_Limit_including_VAT__c,CurrencyIsoCode,SBQQ__Account__r.txt_AthenaUUID__c from SBQQ__Quote__c LIMIT 1];
        quoteTest.cur_Current_Credit_Limit_including_VAT__c= 10;
        quoteTest.SBQQ__Status__c='Accepted';
        update quoteTest;
    	Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CreditLimitWorthinessMock());
    	
    	HttpResponse response = CreditLimitCallouts.startCreditLimitCallouts(false, true, false, '1111', quoteTest, null, null);
    
    	String contentType = response.getHeader('Content-Type');
    	Assert.isTrue(contentType == 'application/json');
    	String actualValue = response.getBody();
    	System.debug(response.getBody());
    	String expectedValue = '{"Envelope":{"Header":"","Body":{"CreditWorthinessResponse":{"CreditWorthiness":{"CreditSegmentInternalID":"5370","Indicator":"true","CheckingDescription":[{"@languageCode":"en","$":"Credit segment 5370 of partner 4001831001"},{"@languageCode":"EN","$":"ID: 510936342"}],"DebtorPartyBlockedIndicator":"false","DebtorPartySpecialAttentionRequiredIndicator":"false","DynamicCheckHorizonEndDate":"2025-10-04","DebtorParty":{"InternalID":{"@schemeID":"PartyID","@schemeAgencyID":"SAP0BHL011","$":"4001831001"}},"Rating":{"Code":"       93","ValidityPeriod":{"EndDateTime":"2026-03-03T00:00:00Z"}},"RiskClass":{"Code":"B","ValidityPeriod":{"EndDateTime":"2026-03-03T00:00:00Z"}},"CreditLimit":{"Amount":{"@currencyCode":"EUR","$":"500000.0"},"ValidityPeriod":{"EndDateTime":"2026-09-30T00:00:00Z"}},"CreditExposure":{"Amount":{"@currencyCode":"EUR","$":"0.0"}}}}}}}';
    	Assert.areEqual(expectedValue, actualValue);
    	Assert.areEqual(200, response.getStatusCode());
        CreditLimitManager.callGetLimit(false,true,false,quoteTest.Id);
        Test.stopTest();
	}
    
        @isTest
	static void checkOrder() {
    	
        Order orderTest = [SELECT Id,Status,cur_Current_Credit_Limit_including_VAT__c,CurrencyIsoCode,Account.txt_AthenaUUID__c from Order LIMIT 1];
        orderTest.cur_Current_Credit_Limit_including_VAT__c= 10;
        orderTest.Status= 'Activated';
        update orderTest;
  
    	Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CreditLimitWorthinessMock());
    	
    	HttpResponse response = CreditLimitCallouts.startCreditLimitCallouts(false, false, true,'1111', null, orderTest, null);
    
    	String contentType = response.getHeader('Content-Type');
    	Assert.isTrue(contentType == 'application/json');
    	String actualValue = response.getBody();
    	System.debug(response.getBody());
    	String expectedValue = '{"Envelope":{"Header":"","Body":{"CreditWorthinessResponse":{"CreditWorthiness":{"CreditSegmentInternalID":"5370","Indicator":"true","CheckingDescription":[{"@languageCode":"en","$":"Credit segment 5370 of partner 4001831001"},{"@languageCode":"EN","$":"ID: 510936342"}],"DebtorPartyBlockedIndicator":"false","DebtorPartySpecialAttentionRequiredIndicator":"false","DynamicCheckHorizonEndDate":"2025-10-04","DebtorParty":{"InternalID":{"@schemeID":"PartyID","@schemeAgencyID":"SAP0BHL011","$":"4001831001"}},"Rating":{"Code":"       93","ValidityPeriod":{"EndDateTime":"2026-03-03T00:00:00Z"}},"RiskClass":{"Code":"B","ValidityPeriod":{"EndDateTime":"2026-03-03T00:00:00Z"}},"CreditLimit":{"Amount":{"@currencyCode":"EUR","$":"500000.0"},"ValidityPeriod":{"EndDateTime":"2026-09-30T00:00:00Z"}},"CreditExposure":{"Amount":{"@currencyCode":"EUR","$":"0.0"}}}}}}}';
    	Assert.areEqual(expectedValue, actualValue);
    	Assert.areEqual(200, response.getStatusCode());
        CreditLimitManager.callGetLimit(false,false,true,orderTest.Id);
        CreditLimitManager.updateOrderAndQuotes();
        Test.stopTest();
	}
}