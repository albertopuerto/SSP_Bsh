public with sharing class QuoteLineEmailController {
    
     public Id quoteIdParam { get; set; }
    
     public List<SBQQ__QuoteLine__c> quoteLineItems {
         get {
             return quoteIdParam != null ? [SELECT Id, SBQQ__Product__r.Name, SBQQ__Quantity__c,  pkl_SolutionField__c, SBQQ__ListPrice__c, SBQQ__TotalDiscountAmount__c, SBQQ__NetTotal__c, ftxt_ShortDescription__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quoteIdParam]: new List<SBQQ__QuoteLine__c>();
            }
           private set;
   	}
}