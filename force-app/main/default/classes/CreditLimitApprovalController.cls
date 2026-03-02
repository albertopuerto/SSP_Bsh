public class CreditLimitApprovalController {

    @AuraEnabled
	public static Boolean hasSubsProducts(Id quoteId) {
    
        Set<Id> quoteIds= new Set<Id>();
        quoteIds.add(quoteId);
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
    	quote = new QuoteSelector().selectQuoteToolCoordinator(quoteIds)[0];
        
        Set<String> swTypes = new Set<String>{ 'SUBS', 'SUBP' };
        if (quote.lkp_ToolCoordinator__c != null){
      		return false;
    	}
        
        List<SBQQ__QuoteLine__c>  quoteLineItems = new QuoteLineItemSelector().selectQuoteLineItems(quoteIds);
    	for (SBQQ__QuoteLine__c ql : quoteLineItems) {
        	if (ql.SBQQ__Product__r != null &&
            	swTypes.contains(ql.SBQQ__Product__r.pkl_MaterialType__c)) {
            	return true;
        	}
    	}

    	return false;
	}

	@AuraEnabled
	public static SBQQ__Quote__c callCreditLimit(Id quoteId) {

		SBQQ__Quote__c quote = new SBQQ__Quote__c();
    
        CreditLimitManager.callGetLimit('SBQQ__Quote__c', quoteId);
		quote =  [select id,CurrencyIsoCode,SBQQ__Account__r.Name,SBQQ__Account__r.BillingCountry,cur_CreditLimit__c,pkl_PaymentTerms__c,cur_Current_Credit_Limit_including_VAT__c,SBQQ__NetAmount__c from SBQQ__Quote__c where id = :quoteId];

		return quote;
	}

}