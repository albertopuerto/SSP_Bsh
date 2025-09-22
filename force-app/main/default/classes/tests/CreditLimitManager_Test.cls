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
       // taxes.taxAdditionalInformation additionalInformation 
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
        creditAccount.debtorPartyInternalID = accDebtorParty;
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
      //  creditAccount.PaymentBehaviourSummary = '';
     //   creditAccount.CommitmentTotal = '';
        
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
        CreditLimitManager.getObjectCurrency(true,false,false,testAccount.Id);
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