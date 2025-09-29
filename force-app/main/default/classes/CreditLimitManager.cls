public with sharing class CreditLimitManager {
    public static List<SBQQ__Quote__c> listQuotesToUpdate = new List<SBQQ__Quote__c>();
    public static List<Order> listOrdersToUpdate = new List<Order>();

    @AuraEnabled
    public static String  getObjectCurrency(Boolean isAccount, Boolean isQuote,Boolean isOrder,String objectRecordId) {

    	String objCurrency;
        if(isAccount){
            Account acc = [Select Id,CurrencyIsoCode from Account where Id =: objectRecordId ];
            objCurrency = acc.CurrencyIsoCode;
        }

        return objCurrency;
    }

    @AuraEnabled
    public static Boolean  checkAthenaId(String objectRecordId) {

        Boolean hasAthenaId;
        Account acc = [Select Id,CurrencyIsoCode,txt_AthenaUUID__c from Account where Id =: objectRecordId ];
        
        if(acc.txt_AthenaUUID__c != null){
            hasAthenaId = true;
        }else{
            hasAthenaId = false;
        }
        

        return hasAthenaId;
    }
    
    
    @AuraEnabled
    public static CreditLimitWrappers.creditLimitInfoWrapper callGetLimit(Boolean isAccount, Boolean isQuote,Boolean isOrder,String objectRecordId) {

    	String creditLimit = '';
        String orgId =  [SELECT Id FROM Organization LIMIT 1 ].Id;
        SBQQ__Quote__c quotetoCalculate = new SBQQ__Quote__c();
        Order orderToCalculate= new Order();
        Account actualAccount = new Account();
        HttpResponse vertexResponse= new HttpResponse();
        VertexMethods.wrapperResponse vertexResponseBody = new VertexMethods.wrapperResponse();

        CreditLimitWrappers.creditLimitInfoWrapper lastInfoWrapper = new CreditLimitWrappers.creditLimitInfoWrapper();
        try{

        	if(isQuote){
                quoteToCalculate = [SELECT Id,SBQQ__Quote__c.SBQQ__Status__c,SBQQ__Account__r.txt_AthenaUUID__c,Current_Credit_Limit_including_VAT__c, Bill_To_Country__c,SBQQ__NetAmount__c,CurrencyIsoCode from SBQQ__Quote__c where Id=: objectRecordId];
            }else if(isOrder){
                orderToCalculate = [SELECT Id,Account.txt_AthenaUUID__c,Account.BillingCountry,Current_Credit_Limit_including_VAT__c, AccountId,TotalAmount,CurrencyIsoCode from Order where Id=: objectRecordId];
            }else if(isAccount){
                actualAccount = [SELECT Id, BillingCountry,txt_AthenaUUID__c from Account where Id=: objectRecordId];
            }

            if(!isAccount && !Test.isRunningTest()){ // !Test.isRunningTest()
            	vertexResponse = CreditLimitCallouts.startVertexCallouts(isAccount, isQuote,isOrder,objectRecordId,quoteToCalculate,orderToCalculate);
            	System.debug('bodyWithoutSerialize -------- '+ vertexResponse.getBody());
            }if(Test.isRunningTest()){
                
                vertexResponse.setBody('{"id":"723E4D234A111FD087EC4B69ED931D18","date":"2025-09-04T14:56:10.428Z","currencyCode":"EUR","amountTypeCode":"NET","items":[{"id":"000001","countryRegionCode":"DE","taxEventCode":"IGSTC","taxes":[{"taxTypeCode":"1","taxRate":19.00,"taxableBaseAmount":1.0,"taxAmount":0.19,"dueCategoryCode":"RECEIVABLE","isTaxDeferred":false,"deductibleTaxRate":100.0,"nonDeductibleTaxRate":0.0,"deductibleTaxAmount":0.19,"nonDeductibleTaxAmount":0.0,"additionalInformation":{"taxAssist0":"tax.taxCode&#124;POST&#124;&#124;IGSTC&#124;G_Set_Vertex_TaxDecisionCode_P","JurisdictionLevel":"COUNTRY","SellerRegistrationId":"XXX","Imposition":"VAT","JurisdictionName":"GERMANY","SitusCtry":"DE","RateClassification":"Standard Rate","ImpositionType":"VAT","DeductibleRate":"1.0","Level":"1","InvoiceTextCode":"&#124;21&#124;","BuyerRegistrationId":"DE811128135","Situs":"DE"}}],"additionalInformation":{"totalTax":"0.19","totalRate":"19.0000","taxAssist2":"buyer.department&#124;PRE&#124;&#124;5000&#124;G_Set Tax Payer Hierarchy_P","taxAssist3":"buyer.division&#124;PRE&#124;&#124;EMEA&#124;G_Set Tax Payer Hierarchy_P","taxAssist0":"FLEX.input.Error_Msg&#124;PRE&#124;&#124;UMTD&#124;G_Set_Default_Mapping_UMTD_P","taxAssist1":"buyer.company&#124;PRE&#124;5000&#124;GLOBAL SHELL&#124;G_Set Tax Payer Hierarchy_P","taxAssist4":"purchase.purchaseClass&#124;PRE&#124;&#124;null&#124;G_Set_Default_Mapping_UMTD_P","taxCode":"IGSTC","outFcode25":"UMTD"}}],"additionalInformation":{"partnerName":"Vertex"}}');
            	vertexResponse.setStatusCode(200);
            }

            if(vertexResponse != null ){

            	if(vertexResponse.getStatusCode()== 200){
                	VertexMethods vertexWrapper = new VertexMethods();
                	String finalBodyresponse =vertexResponse.getBody().replace ('"id"','"auxId"').replace ('"date"','"actualDate"').replace ('"number"','"taxNumber"');

                	vertexResponseBody= (VertexMethods.wrapperResponse)JSON.deserialize(finalBodyresponse, VertexMethods.wrapperResponse.class);

                	System.debug('body'+ vertexResponseBody);
                    
                	for(VertexMethods.responseItem taxItem: vertexResponseBody.items){
                		for(VertexMethods.responseTaxes tax: taxItem.taxes){

                    		if(isQuote){
                        		quoteToCalculate.Current_Credit_Limit_including_VAT__c = (quoteToCalculate.SBQQ__NetAmount__c * tax.taxRate)/100 + quoteToCalculate.SBQQ__NetAmount__c;
                            	listQuotesToUpdate.add(quoteToCalculate);
                        	}
                        	if(isOrder){
                                orderToCalculate.Current_Credit_Limit_including_VAT__c = (orderToCalculate.TotalAmount * tax.taxRate)/100 + orderToCalculate.TotalAmount;
                                listOrdersToUpdate.add(orderToCalculate);
                        	}
                           
                        	System.debug('taxes'+ tax.taxRate);
                    	}
                	}
                 	//   updateOrderAndQuotes();

                }else{
                /*    Logger.error('Request error details - '+ response.getStatusCode() +'-'+response.getStatus())
                    .addTags(('API,TEST').split(','))
                    .setRecordId(objectRecordId);*/
                }
            }

            if(!isAccount || isAccount && actualAccount.txt_AthenaUUID__c != null){

                HttpResponse creditLimitresponse = new HttpResponse();

                CreditLimitWrappers.wrapperResponse responseBody;
                CreditLimitWrappers.accountWrapperResponse accountResponseBody;
                String finalBodyresponse;

                CreditLimitWrappers.CreditWorthiness creditWorthiness= new CreditLimitWrappers.CreditWorthiness();
                CreditLimitWrappers.CreditManagementAccount creditManagement = new CreditLimitWrappers.CreditManagementAccount(); 

                CreditLimitWrappers.LogAccount logAccount = new CreditLimitWrappers.LogAccount();

                if(!Test.isRunningTest()){
                    creditLimitresponse = creditLimitCallouts.startCreditLimitCallouts(isAccount, isQuote,isOrder,objectRecordId,orgId,quoteToCalculate,orderToCalculate,actualAccount);
                }
                if(Test.isRunningTest() && isAccount){
                    creditLimitresponse.setBody('{"Envelope":{"Header":"","Body":{"CreditManagementAccountByIDResponse":{"MessageHeader":{"ID":"D6B2D2D3CE021FD0A399EAD2F9065196","CreationDateTime":"2025-09-08T16:17:38.739Z"},"CreditManagementAccount":{"DebtorPartyInternalID":{"@schemeID":"PartyID","@schemeAgencyID":"SAP0BHL011","$":"4001831001"},"CreditsegmentInternalID":"5370","CreditSegmentDescription":{"@languageCode":"de"},"CreditWorthinessCheckingRuleCode":"ZR","CreditWorthinessCheckingSchemeCode":"ZB","SpecialAttentionRequiredIndicator":"false","BlockedIndicator":"false","BlockingReasonCodeDescription":{"@languageCode":"de"},"CreditLimitAmount":{"@currencyCode":"EUR","$":"500000.0"},"CreditLimitValidityPeriod":{"StartDate":"2025-09-08","EndDate":"2026-09-30"},"CreditExposure":{"Amount":{"@currencyCode":"EUR","$":"0.0"},"DynamicCheckCreditHorizonEndDate":"2025-10-08"},"CreditRating":{"Code":"       93","ValidityPeriod":{"StartDate":"2025-06-13","EndDate":"2026-03-07"}},"CreditRiskClass":{"Code":"B","ValidityPeriod":{"StartDate":"2025-06-13","EndDate":"2026-03-07"},"Description":{"@languageCode":"de","$":"Geringes Ausfallrisiko"}},"PaymentBehaviourSummary":{"DaysOfSalesOutstandingAverageDuration":"0 "}}}}}}');
                	creditLimitresponse.setStatusCode(200);
                }
                if(Test.isRunningTest() && !isAccount){
                    creditLimitResponse.setBody('{"Envelope":{"Header":"","Body":{"CreditWorthinessResponse":{"CreditWorthiness":{"CreditSegmentInternalID":"5370","Indicator":"true","CheckingDescription":[{"@languageCode":"en","$":"Credit segment 5370 of partner 4001831001"},{"@languageCode":"EN","$":"ID: 510936342"}],"DebtorPartyBlockedIndicator":"false","DebtorPartySpecialAttentionRequiredIndicator":"false","DynamicCheckHorizonEndDate":"2025-10-04","DebtorParty":{"InternalID":{"@schemeID":"PartyID","@schemeAgencyID":"SAP0BHL011","$":"4001831001"}},"Rating":{"Code":"       93","ValidityPeriod":{"EndDateTime":"2026-03-03T00:00:00Z"}},"RiskClass":{"Code":"B","ValidityPeriod":{"EndDateTime":"2026-03-03T00:00:00Z"}},"CreditLimit":{"Amount":{"@currencyCode":"EUR","$":"500000.0"},"ValidityPeriod":{"EndDateTime":"2026-09-30T00:00:00Z"}},"CreditExposure":{"Amount":{"@currencyCode":"EUR","$":"0.0"}}}}}}}');
                	creditLimitresponse.setStatusCode(200);
                }

                if(creditLimitresponse != null ){
                    if(creditLimitresponse.getStatusCode()== 200){
                        System.debug(creditLimitresponse.getBody());
                    
                        CreditLimitWrappers creditLimitWrapper = new CreditLimitWrappers();
                        finalBodyresponse =creditLimitresponse.getBody().replace ('"$"','"dollar"').replace ('"@languageCode"','"languageCode"').replace ('"@schemeID"','"schemeID"').replace ('"@schemeAgencyID"','"schemeAgencyID"').replace ('"@currencyCode"','"currencyCode"');

                        if(isQuote || isOrder){
                    	    responseBody= (CreditLimitWrappers.wrapperResponse)JSON.deserialize(finalBodyresponse, CreditLimitWrappers.wrapperResponse.class);

                            System.debug('finalBodyResponse: '+finalBodyresponse);
                
                            System.debug('body '+ responseBody);
                    
                            creditWorthiness= responseBody.Envelope.Body.CreditWorthinessResponse.CreditWorthiness;
                            System.debug('creditWorthiness '+creditWorthiness);
                            System.debug('creditWorthinessDescs22'+creditWorthiness.CheckingDescription);
                    
                            for(CreditLimitWrappers.CheckingDescs description :creditWorthiness.CheckingDescription){
                        	    if(description.dollar.contains('Credit limit')){
                            	    System.debug(description.dollar);
                                    // creditLimit = description.dollar;
                                    lastInfoWrapper.message= description.dollar; 
                    			    lastInfoWrapper.status= creditLimitresponse.getStatusCode();
                    			    lastInfoWrapper.success= false;
                                }
                            }
                        }else if(isAccount){
                    	    accountResponseBody= (CreditLimitWrappers.accountWrapperResponse)JSON.deserialize(finalBodyresponse, CreditLimitWrappers.accountWrapperResponse.class);

                            System.debug('finalBodyResponse: '+finalBodyresponse);
                
                            System.debug('body '+ accountResponseBody);

                            if(accountResponseBody.Envelope.Body.CreditManagementAccountByIDResponse.Log != null){
                                logAccount = accountResponseBody.Envelope.Body.CreditManagementAccountByIDResponse.Log;
                                System.debug('lognote '+ logAccount.Item.Note);
                                System.debug('log account '+logAccount);
                                lastInfoWrapper.message= logAccount.Item.Note; 
                    	        lastInfoWrapper.status= creditLimitresponse.getStatusCode();
                    	        lastInfoWrapper.success= false;

                            }else if(accountResponseBody.Envelope.Body.CreditManagementAccountByIDResponse.CreditManagementAccount != null){
                                String curr;
                                curr= getObjectCurrency(true,false,false,actualAccount.Id);
                                creditManagement= accountResponseBody.Envelope.Body.CreditManagementAccountByIDResponse.CreditManagementAccount;
                                System.debug('creditWorthiness '+creditManagement);
                                System.debug('creditWorthinessDescs22'+creditManagement.CreditLimitAmount);
                                System.debug('aaaa'+creditManagement.CreditLimitAmount.dollar);
                                lastInfoWrapper.message= creditManagement.CreditLimitAmount.dollar; 
                    	        lastInfoWrapper.status= creditLimitresponse.getStatusCode();
                    	        lastInfoWrapper.success= true;
                            }

                        //creditLimit = creditManagement.CreditLimitAmount.dollar;

                        }
                    
                    /*
                    if(!listQuotesToUpdate.isEmpty()){
                        update listQuotesToUpdate;
                    }
                    if(!listOrdersToUpdate.isEmpty()){
                        update listOrdersToUpdate;
                    }*/

                    return lastInfoWrapper;
                    
                    }else{
                        lastInfoWrapper.message= ' Error during the http request - '+ creditLimitresponse.getStatusCode() +'-'+creditLimitresponse.getStatus(); 
                        lastInfoWrapper.status= creditLimitresponse.getStatusCode();
                        lastInfoWrapper.success= false;
                        /*    Logger.error('Request error details - '+ response.getStatusCode() +'-'+response.getStatus())
                        .addTags(('API,TEST').split(','))
                        .setRecordId(objectRecordId);*/
                    }
                    updateOrderAndQuotes();
                }
                 
            }
           
        }catch(Exception ex){
            lastInfoWrapper.message= ex.getMessage(); 
           // lastInfoWrapper.status= creditLimitresponse.getStatusCode();
            lastInfoWrapper.success= false;

        	Logger.error('Error while creating the log - '+ ex.getMessage()).setRecordId(objectRecordId);
        }finally{
        	saveLog();
        }
            
        return lastInfoWrapper;
         
    }
    @future(callout=true)
   	public static void saveLog(){
        Logger.saveLog();
    }

    public static void updateOrderAndQuotes(){
        
    	if(!listQuotesToUpdate.isEmpty()){
            update listQuotesToUpdate;
        }
        if(!listOrdersToUpdate.isEmpty()){
            update listOrdersToUpdate;
        }
                
    }

           
}