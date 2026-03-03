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

		Set<Id> quoteIds = new Set<Id>();
        quoteIds.add(quoteId);
		SBQQ__Quote__c quote = new SBQQ__Quote__c();
    
        CreditLimitManager.callGetLimit('SBQQ__Quote__c', quoteId);
		quote = new QuoteSelector().selectQuoteInfo(quoteIds)[0];

		return quote;
	}

}