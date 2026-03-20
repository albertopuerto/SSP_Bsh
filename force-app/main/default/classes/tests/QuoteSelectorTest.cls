@isTest
public class QuoteSelectorTest {

    @testSetup
    static void initRecords(){

        Account[] testAccountList = (Account[])TestFactory.createSObjectList(new Account(), 1);
        testAccountList[0].CurrencyIsoCode = 'EUR';
        testAccountList[0].txt_AthenaUUID__c= '3123213';
        testAccountList[0].BillingCountry= 'Germany';
        testAccountList[0].BillingCountryCode= 'DE';
        insert testAccountList;
        
        SBQQ__Quote__c[] quoteList = (SBQQ__Quote__c [])TestFactory.createSObjectList(new SBQQ__Quote__c(),1);
        quoteList[0].SBQQ__Status__c = 'Accepted';
        quoteList[0].CurrencyIsoCode = 'EUR';
        quoteList[0].SBQQ__Account__r = testAccountList[0];
        quoteList[0].lkp_BillToAccount__c= testAccountList[0].Id;
        insert quoteList;
        
    }
    
    @isTest
    static void getQuote(){
        
        Set<Id> idSet = new Set<Id>();
        Test.startTest();
        SBQQ__Quote__c quoteTest = [SELECT Id,SBQQ__Status__c,Bill_To_Country__c,cur_Current_Credit_Limit_including_VAT__c,CurrencyIsoCode,SBQQ__Account__r.txt_AthenaUUID__c from SBQQ__Quote__c LIMIT 1];
		idSet.add(quoteTest.Id);        
        QuoteSelector qs = new QuoteSelector();
        List<SBQQ__Quote__c> selectQuote = qs.selectQuoteInfo(idSet);
        Assert.areNotEqual(null, selectQuote[0], 'The quote was retrieved succesfully');
        Test.stopTest();
    }
    
    @isTest
    static void getQuoteCoordinator(){
        
        Set<Id> idSet = new Set<Id>();
        Test.startTest();
        SBQQ__Quote__c quoteTest = [SELECT Id,SBQQ__Status__c,Bill_To_Country__c,cur_Current_Credit_Limit_including_VAT__c,CurrencyIsoCode,SBQQ__Account__r.txt_AthenaUUID__c from SBQQ__Quote__c LIMIT 1];
		idSet.add(quoteTest.Id);        
        QuoteSelector qs = new QuoteSelector();
        List<SBQQ__Quote__c> selectQuote = qs.selectQuoteToolCoordinator(idSet);
        Assert.areNotEqual(null, selectQuote[0], 'The quote was retrieved succesfully');
        Test.stopTest();
    }
}